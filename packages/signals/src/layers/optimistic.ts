/** User guesses and their action lifetime, published by the common layer core. */
import { computed, read, signal, runWithOwner, untrack, stageSelectedValue } from "../core/core.js";
import { enqueueSub } from "../core/heap.js";
import { registerGraph } from "../core/dev.js";
import { dispose, getOwner } from "../core/owner.js";
import { attrHooks } from "../core/attribution-hooks.js";
import {
  $REFRESH,
  CONFIG_AUTO_DISPOSE,
  CONFIG_HELD,
  CONFIG_REDERIVE,
  CONFIG_LOADING,
  CONFIG_SYNC,
  REACTIVE_WRITABLE_COMPUTED,
  NOT_PENDING,
  REACTIVE_CHECK,
  REACTIVE_DIRTY,
  REACTIVE_IN_HEAP,
  REACTIVE_ZOMBIE,
  REACTIVE_DISPOSED,
  REACTIVE_RECOMPUTING_DEPS,
  STATUS_PENDING
} from "../core/constants.js";
import {
  blocked,
  flushTransaction,
  GlobalQueue,
  holdNode,
  joinFuture,
  liveTx,
  merge,
  newTransaction,
  resolveTx,
  setLayerBlocked,
  txOf,
  inEffectCallback,
  setEffectCallback,
  stageValueInUpdate,
  type Transaction
} from "../core/scheduler.js";
import type { Computed, NodeOptions, Signal, Root } from "../core/types.js";
import { boundaries } from "./boundary.js";
import { layerPosition } from "./committed-dependencies.js";
import {
  createLayerBoundary,
  inputTime,
  inputUpdate,
  observed,
  positionOf,
  resumeInput,
  readOverride,
  setGuessLifecycle,
  stageLayer,
  wakeLayers,
  type Layer
} from "./coordination.js";

const proposals = new Map<Layer<any>, unknown>();
// One writer's changed outputs publish together. These records last only
// until their proposals acquire ordinary output transactions; scopes are not
// members of the group and retain their independent action lifetimes.
const proposalGroups = new Set<Set<Layer<any>>>();
const scopes = new Map<Transaction, Set<Layer<any>>>();
if (__OBSERVE__)
  GlobalQueue._layerGuesses = update =>
    Array.from(scopes.get(resolveTx(update)) ?? [], layer => layer._output);
if (__OBSERVE__)
  GlobalQueue._layerPublished = (output, previous) => {
    const layer = boundaries.get(output) as (Layer<any> & { _shownGuess?: boolean }) | undefined;
    if (!layer?._inputStatus) return;
    const guessed = layer._override !== NOT_PENDING;
    if (
      layer._shownGuess &&
      !guessed &&
      !Object.is(previous, output._value) &&
      attrHooks !== null &&
      observed(output, null)
    )
      attrHooks.optimisticReverted(
        output,
        previous,
        output._value,
        inputTime(layer._input) === layer._inputTime ? "reverted" : "superseded"
      );
    layer._shownGuess = guessed;
  };
// Only valid inside the synchronous retirement loop, which runs no input
// calculations. Merging invalidates it before admitting any new work.
let settledInputs: Transaction | null = null;

/** A guessed input's own flight keeps its action alive even without readers,
 * as in next. It does not hold a different update merely because the
 * override is displayed. Its eventual correction uses ordinary joining. */
function pendingScope(update: Transaction): boolean {
  if (update === settledInputs) return false;
  const layers = scopes.get(update);
  if (!layers) return false;
  for (const layer of layers) if (layer._input._statusFlags & STATUS_PENDING) return true;
  return false;
}

function retire(layer: Layer<any>): void {
  // An input hidden by an override can outlive the action transaction. Its
  // eventual answer resumes in live ordinary work, never a completed hold.
  const scope = liveTx(layer._scope!);
  if (!scope) joinFuture(null);
  resumeInput(layer, scope ?? resolveTx(flushTransaction!));
  removeScope(layer);
  const input = layer._input,
    output = layer._output,
    owner = output._parent as Root | null;
  // A plain selector of a settled input has no calculation to discover. Keep
  // the correction in its ordinary update; descendants can still suspend it.
  // Held/dirty inputs and unpublished owners retain the complete read path.
  if (
    output._x !== null &&
    (!owner || (owner._root && !owner._parentComputed)) &&
    !(input._config & CONFIG_HELD) &&
    input._pendingValue === NOT_PENDING &&
    !(
      input._flags &
      (REACTIVE_CHECK |
        REACTIVE_DIRTY |
        REACTIVE_IN_HEAP |
        REACTIVE_RECOMPUTING_DEPS |
        REACTIVE_ZOMBIE |
        REACTIVE_DISPOSED)
    )
  )
    stageSelectedValue(output, input._value, input);
}

function prepareGuesses(): boolean {
  let changed = false;
  // Ambient writes acquire the update that actually parks this flush. A
  // setter cannot know that update before downstream calculations have run.
  for (const layer of proposals.keys()) {
    if (layer._output._flags & REACTIVE_DISPOSED) {
      proposals.delete(layer);
      continue;
    }
    if (!layer._automatic || layer._scope) continue;
    let scope = inputUpdate(layer) ?? (flushTransaction && resolveTx(flushTransaction));
    if (!scope && layer._input._statusFlags & STATUS_PENDING) {
      // Keep this new lifetime alive until the guess has propagated once;
      // its displayed consumers then determine the ordinary input hold.
      scope = newTransaction(false);
      scope._open++;
      layer._opening = true;
      holdNode(layer._input, scope);
    }
    if (!scope) proposals.delete(layer);
    else bindScope(layer, scope);
  }
  // Scope membership follows ordinary merging. Output updates which own
  // no guesses do not scan unrelated lifetimes when checking readiness.
  for (const [scope, layers] of scopes) {
    // Absence of a flight is stable during retirement; newly merged work
    // invalidates this shortcut before another readiness check.
    if (!scope._open) {
      settledInputs = scope;
      for (const layer of layers)
        if (layer._input._statusFlags & STATUS_PENDING) {
          settledInputs = null;
          break;
        }
    }
    try {
      for (const layer of layers) {
        if (layer._output._flags & REACTIVE_DISPOSED) {
          releaseLayer(layer);
          continue;
        }
        // A correction can merge more work into this scope. Recheck after
        // each retirement, retaining the ordinary readiness rule.
        if (blocked(resolveTx(scope))) break;
        proposals.delete(layer);
        retire(layer);
        changed = true;
      }
    } finally {
      settledInputs = null;
    }
  }
  return changed;
}

function selectProposal(proposal: unknown, layer: Layer<any>): void {
  layer._override = proposal;
  layer._position = undefined;
}

function positionProposal(_proposal: unknown, layer: Layer<any>): void {
  layer._position = 1 + Math.max(layerPosition(layer._input), positionOf(inputUpdate(layer)));
}

function applyProposal(proposal: unknown, layer: Layer<any>): void {
  if (!(layer._output._flags & REACTIVE_DISPOSED)) stageLayer(layer, proposal, layer._position);
  if (layer._opening) {
    resolveTx(layer._scope!)._open--;
    layer._opening = undefined;
  }
}

setGuessLifecycle({
  _write: (layer, update, proposal) =>
    !!layer._inputStatus &&
    proposal !== NOT_PENDING &&
    layer._output._deps?._dep === layer._input &&
    stageValueInUpdate(layer._output, update, proposal),
  _notify: forwardInput,
  _merge: (from, into) => {
    settledInputs = null;
    const layers = scopes.get(from);
    if (!layers) return;
    const target = scopes.get(into);
    if (target) for (const layer of layers) target.add(layer);
    else scopes.set(into, layers);
    scopes.delete(from);
  },
  _prepare: prepareGuesses,
  _settle: () => {
    if (!proposals.size) {
      proposalGroups.clear();
      return false;
    }
    // Freeze the whole batch's selections before assigning contexts. This
    // prevents simultaneous nested guesses from depending on setter order.
    proposals.forEach(selectProposal);
    proposals.forEach(positionProposal);
    proposals.forEach(applyProposal);
    for (const group of proposalGroups) {
      const updates = new Set<Transaction>();
      let position: number | undefined;
      for (const layer of group) {
        if (!proposals.has(layer) || !(layer._output._config & CONFIG_HELD)) continue;
        const update = txOf(layer._output);
        const depth = positionOf(update);
        if (position !== undefined && position !== depth)
          throw new Error("Optimistic store writer groups require outputs at the same depth.");
        position = depth;
        updates.add(update);
      }
      let first: Transaction | undefined;
      for (const update of updates) {
        if (first) merge(update, first);
        else first = update;
      }
    }
    proposalGroups.clear();
    proposals.clear();
    return true;
  },
  _active: () => !!(scopes.size || proposals.size)
});

/** Only guesses have a side-effect-free selector. Keep this specialization
 * out of observation-only bundles; both paths still use ordinary staging. */
function forwardInput(
  source: Signal<any>,
  reader: Computed<any>,
  update: Transaction
): boolean | void {
  if (
    flushTransaction === update &&
    reader._config & CONFIG_HELD &&
    reader._x!._transaction === update &&
    !(reader._flags & (REACTIVE_RECOMPUTING_DEPS | REACTIVE_DISPOSED)) &&
    source._subs!._nextSub === null
  ) {
    const layer = boundaries.get(reader);
    if (layer?._inputStatus && layer._input === source && layer._override === NOT_PENDING)
      return stageSelectedValue(
        reader,
        source._pendingValue !== NOT_PENDING ? source._pendingValue : source._value,
        source as Computed<any>
      );
  }
}

type Input<T> = T | ((previous: NoInfer<T> | undefined) => T | PromiseLike<T> | AsyncIterable<T>);

/** Public scalar path: allocate only the pair that the API returns. */
export function createOptimisticPair<T>(input: Input<T>, config?: NodeOptions<T>) {
  const layer = createBoundary(input, config);
  layer._automatic = true;
  return layerAccessors(layer);
}

/** Explicit proposal/clear adapter used by the model tests. Its extra closure
 * and tuple are absent from applications importing the public scalar API. */
export function createLayer<T>(
  input: Input<T>,
  options?: { lifetime: "action"; node?: NodeOptions<T> }
) {
  const layer = createBoundary(input, options?.node);
  if (options?.lifetime === "action") layer._automatic = true;
  const pair = layerAccessors(layer);
  return [
    ...pair,
    () => {
      proposals.set(layer, NOT_PENDING);
      wakeLayers();
    }
  ] as const;
}

function createBoundary<T>(input: Input<T>, config?: NodeOptions<T>) {
  // The producer records each input evaluation. Equality belongs at the
  // output: an answer equal to an earlier input may still replace a guess.
  // A readonly sync memo promises synchronous values. Borrow it without
  // changing its owner or auto-disposal. An async-aware memo can emit raw
  // thenables as stream values, which this input must normalize again. Those
  // memos, writable/optimistic outputs, seeds and configured inputs keep a node.
  const source =
    typeof input === "function" && !config
      ? ((input as any)[$REFRESH] as Computed<T> | undefined)
      : undefined;
  const shared =
    source &&
    typeof source._fn === "function" &&
    source._config & CONFIG_SYNC &&
    !(source._config & (CONFIG_REDERIVE | CONFIG_LOADING)) &&
    !(source._flags & REACTIVE_WRITABLE_COMPUTED)
      ? source
      : undefined;
  const producer =
    shared ??
    ((typeof input === "function"
      ? computed<T>(input as (previous?: T) => T, {
          ...config,
          equals: false,
          unobserved: undefined
        })
      : signal<T>(input, config)) as Computed<T>);
  if (__OBSERVE__ && typeof input !== "function") registerGraph(producer, getOwner());
  const layer = createLayerBoundary<T>(producer, selectGuess, !shared, config?.lazy, config);
  if (shared) layer._refreshInput = materializeInput;
  layer._output._config &= ~CONFIG_AUTO_DISPOSE;
  layer._inputStatus = true;
  return layer;
}

function materializeInput(layer: Layer<any>): void {
  const source = layer._input;
  // Refresh re-reads the boundary input, never the borrowed source's callback.
  // Install that producer only when needed. This internal allocation is also
  // valid when refresh is requested by an effect's imperative callback.
  const callback = __DEV__ && inEffectCallback;
  if (__DEV__) setEffectCallback(false);
  try {
    layer._input = runWithOwner(layer._output._parent, () =>
      computed(() => read(source), { equals: false })
    );
  } finally {
    if (__DEV__) setEffectCallback(callback);
  }
  layer._input._config &= ~CONFIG_AUTO_DISPOSE;
  layer._refreshInput = undefined;
  enqueueSub(layer._output);
}

function selectGuess<T>(layer: Layer<T>): T {
  // The override selects this boundary's output. Advancing its input does
  // not join the input update to the guessing action.
  // Once the override retires, the ordinary read coordinates the correction.
  return layer._override === NOT_PENDING ? read(layer._input) : readOverride(layer);
}

function removeScope(layer: Layer<any>): void {
  if (!layer._scope) return;
  const scope = resolveTx(layer._scope),
    layers = scopes.get(scope);
  layers?.delete(layer);
  if (!layers?.size) scopes.delete(scope);
  layer._scope = null;
  if (!scopes.size) setLayerBlocked();
}

function releaseLayer(layer: Layer<any>): void {
  if (layer._opening && layer._scope) resolveTx(layer._scope)._open--;
  layer._opening = undefined;
  removeScope(layer);
  proposals.delete(layer);
  layer._scope = null;
  // Disposal can be the last event while an input is permanently pending.
  // Recheck the shared transaction list and disable idle hooks without requiring
  // an unrelated future write to visit the disposed boundary.
  wakeLayers();
}

function bindScope(layer: Layer<any>, scope: Transaction): void {
  if (layer._scope) merge(scope, layer._scope);
  layer._scope = resolveTx(scope);
  // Only repeated guesses share this lifetime. Incoming input updates keep
  // their own publication context while the override is selected.
  const current = resolveTx(layer._scope);
  let layers = scopes.get(current);
  if (!layers) scopes.set(current, (layers = new Set()));
  layers.add(layer);
  setLayerBlocked(pendingScope);
}

/** A store-owned truth slot and its ordinary selected output. Like a source
 * observation, the companion is independent of creator and reader owners. */
export function createOptimisticSlot<T>(input: Signal<T>, onUnobserved?: () => void) {
  const layer = runWithOwner(null, () =>
    createLayerBoundary<T>(input as Computed<T>, selectGuess, false, false, { unobserved: onUnobserved })
  );
  layer._automatic = true;
  layer._inputStatus = true;
  layer._output._config &= ~CONFIG_AUTO_DISPOSE;
  const [, propose] = layerAccessors(layer);
  // Establish the initial published value even when the first operation is a
  // setter. No function/thenable normalization: slot contents are raw values.
  untrack(() => read(layer._output));
  return {
    output: layer._output,
    propose: (value: T) => propose(() => value),
    writerValue: () => previousProposal(layer),
    // The store retries only companions whose readers left. A live guess or
    // an unfinished correction is state, even with no subscribers.
    tryRelease: () => {
      const output = layer._output;
      if (output._subs !== null || layer._scope !== null || proposals.has(layer) ||
          layer._override !== NOT_PENDING ||
          (output._config | input._config) & CONFIG_HELD ||
          output._pendingValue !== NOT_PENDING || input._pendingValue !== NOT_PENDING ||
          (output._statusFlags | layer._input._statusFlags) & STATUS_PENDING ||
          output._flags & (REACTIVE_CHECK | REACTIVE_DIRTY | REACTIVE_IN_HEAP |
            REACTIVE_RECOMPUTING_DEPS | REACTIVE_ZOMBIE)) return false;
      dispose(output as Computed<any>);
      return true;
    }
  };
}

/** Submit one static-record setter's changes. Scalar proposals and distinct
 * setters still select their own publication transactions normally. */
export function proposeOptimisticSlots(
  entries: readonly (readonly [ReturnType<typeof createOptimisticSlot>, unknown])[]
): void {
  const group = new Set<Layer<any>>();
  for (const [slot, value] of entries) {
    slot.propose(value);
    group.add(boundaries.get(slot.output)!);
  }
  if (group.size > 1) proposalGroups.add(group);
}

// A first proposal starts from the published output. Its pending slot can
// belong to a held correction, rather than to an earlier user proposal.
function previousProposal<T>(layer: Layer<T>): T {
  const pending = proposals.get(layer);
  return (proposals.has(layer) && pending !== NOT_PENDING
    ? pending
    : layer._override !== NOT_PENDING
      ? layer._override
      : layer._output._value) as T;
}

function layerAccessors<T>(layer: Layer<T>) {
  const output = layer._output;
  const propose = (value: T | ((previous: T) => T)) => {
    const previous = previousProposal(layer);
    const next = typeof value === "function" ? (value as (v: T) => T)(previous as T) : value;
    if (output._flags & REACTIVE_DISPOSED) return next;
    if (__OBSERVE__ && attrHooks !== null) attrHooks.write(output, previous, next);
    if (layer._automatic) {
      const scope = flushTransaction ?? (layer._scope && liveTx(layer._scope));
      if (scope) bindScope(layer, scope);
    }
    output._cleanup ??= releaseLayer.bind(null, layer);
    proposals.set(layer, next);
    wakeLayers();
    return next;
  };
  const accessor = () => read(output);
  (accessor as any)[$REFRESH] = output;
  return [accessor, propose] as const;
}
