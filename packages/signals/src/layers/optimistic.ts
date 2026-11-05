/** User guesses and their action lifetime, published by the common layer core. */
import { computed, read, signal, runWithOwner, stageSelectedValue } from "../core/core.js";
import { enqueueSub } from "../core/heap.js";
import { registerGraph } from "../core/dev.js";
import { getOwner } from "../core/owner.js";
import { attrHooks } from "../core/attribution-hooks.js";
import {
  $REFRESH, CONFIG_AUTO_DISPOSE, CONFIG_HELD, CONFIG_REDERIVE, CONFIG_LOADING, CONFIG_SYNC,
  REACTIVE_WRITABLE_COMPUTED, NOT_PENDING,
  REACTIVE_CHECK, REACTIVE_DIRTY, REACTIVE_IN_HEAP, REACTIVE_ZOMBIE,
  REACTIVE_DISPOSED, REACTIVE_RECOMPUTING_DEPS, STATUS_PENDING
} from "../core/constants.js";
import {
  blocked, flushTransaction, GlobalQueue, holdNode, joinFuture, liveTx, merge,
  newTransaction, resolveTx, setLayerBlocked, txOf, inEffectCallback, setEffectCallback, stageValueInUpdate,
  type Transaction
} from "../core/scheduler.js";
import type { Computed, NodeOptions, Signal, Root } from "../core/types.js";
import { boundaries } from "./boundary.js";
import { layerPosition } from "./committed-dependencies.js";
import {
  createLayerBoundary, inputTime, inputUpdate, observed, positionOf,
  resumeInput, readOverride, setGuessLifecycle, stageLayer, wakeLayers, type Layer
} from "./coordination.js";

const proposals = new Map<Layer<any>, unknown>();
const scopes = new Map<Transaction, Set<Layer<any>>>();
if (__OBSERVE__) GlobalQueue._layerGuesses = update =>
  Array.from(scopes.get(resolveTx(update)) ?? [], layer => layer._output);
if (__OBSERVE__) GlobalQueue._layerPublished = (output, previous) => {
  const layer = boundaries.get(output) as (Layer<any> & { _shownGuess?: boolean }) | undefined;
  if (!layer?._inputStatus) return;
  const guessed = layer._override !== NOT_PENDING;
  if (layer._shownGuess && !guessed && !Object.is(previous, output._value) &&
      attrHooks !== null && observed(output, null))
    attrHooks.optimisticReverted(output, previous, output._value,
      inputTime(layer._input) === layer._inputTime ? "reverted" : "superseded");
  layer._shownGuess = guessed;
};
// Only valid inside the synchronous retirement loop, which runs no input
// calculations. Merging invalidates it before admitting any new work.
let settledInputs: Transaction | null = null;

/** A guessed input's own flight keeps its action alive, as in next. This
 * does not make that input hold a different update merely because the
 * override is displayed. Its eventual correction uses ordinary joining. */
function pendingScope(update: Transaction): boolean {
  if (update === settledInputs) return false;
  const layers = scopes.get(update);
  if (!layers) return false;
  for (const layer of layers)
    if (
      layer._input._statusFlags & STATUS_PENDING &&
      observed(layer._output, update)
    ) return true;
  return false;
}

function retire(layer: Layer<any>): void {
  // An input hidden by an override can outlive the action transaction. Its
  // eventual answer resumes in live ordinary work, never a completed hold.
  const scope = liveTx(layer._scope!);
  if (!scope) joinFuture(null);
  resumeInput(layer, scope ?? resolveTx(flushTransaction!));
  removeScope(layer);
  const input = layer._input, output = layer._output, owner = output._parent as Root | null;
  // A plain selector of a settled input has no calculation to discover. Keep
  // the correction in its ordinary update; descendants can still suspend it.
  // Held/dirty inputs and unpublished owners retain the complete read path.
  if (output._x !== null && (!owner || (owner._root && !owner._parentComputed)) &&
      !(input._config & CONFIG_HELD) && input._pendingValue === NOT_PENDING &&
      !(input._flags & (REACTIVE_CHECK | REACTIVE_DIRTY | REACTIVE_IN_HEAP |
        REACTIVE_RECOMPUTING_DEPS | REACTIVE_ZOMBIE | REACTIVE_DISPOSED)))
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
    // Absence of a flight is stable during retirement. Observedness is not:
    // never cache a readiness verdict for inputs which are actually pending.
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
    !!layer._inputStatus && proposal !== NOT_PENDING && layer._output._deps?._dep === layer._input &&
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
    if (!proposals.size) return false;
    // Freeze the whole batch's selections before assigning contexts. This
    // prevents simultaneous nested guesses from depending on setter order.
    proposals.forEach(selectProposal);
    proposals.forEach(positionProposal);
    proposals.forEach(applyProposal);
    proposals.clear();
    return true;
  },
  _active: () => !!(scopes.size || proposals.size)
});

/** Only guesses have a side-effect-free selector. Keep this specialization
 * out of observation-only bundles; both paths still use ordinary staging. */
function forwardInput(source: Signal<any>, reader: Computed<any>, update: Transaction): boolean | void {
  if (
    flushTransaction === update &&
    reader._config & CONFIG_HELD && reader._x!._transaction === update &&
    !(reader._flags & (REACTIVE_RECOMPUTING_DEPS | REACTIVE_DISPOSED)) &&
    source._subs!._nextSub === null
  ) {
    const layer = boundaries.get(reader);
    if (layer?._inputStatus && layer._input === source && layer._override === NOT_PENDING)
      return stageSelectedValue(reader,
        source._pendingValue !== NOT_PENDING ? source._pendingValue : source._value,
        source as Computed<any>);
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
  return [...pair, () => {
    proposals.set(layer, NOT_PENDING);
    wakeLayers();
  }] as const;
}

function createBoundary<T>(input: Input<T>, config?: NodeOptions<T>) {
  // The producer records each input evaluation. Equality belongs at the
  // output: an answer equal to an earlier input may still replace a guess.
  // A readonly sync memo promises synchronous values. Borrow it without
  // changing its owner or auto-disposal. An async-aware memo can emit raw
  // thenables as stream values, which this input must normalize again. Those
  // memos, writable/optimistic outputs, seeds and configured inputs keep a node.
  const source = typeof input === "function" && !config
    ? (input as any)[$REFRESH] as Computed<T> | undefined : undefined;
  const shared = source && typeof source._fn === "function" &&
    source._config & CONFIG_SYNC &&
    !(source._config & (CONFIG_REDERIVE | CONFIG_LOADING)) &&
    !(source._flags & REACTIVE_WRITABLE_COMPUTED)
    ? source : undefined;
  const producer = shared ?? (typeof input === "function"
    ? computed<T>(input as (previous?: T) => T, { ...config, equals: false, unobserved: undefined })
    : signal<T>(input, config)) as Computed<T>;
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
  const producer = layer._input;
  if (
    layer._scope !== null &&
    layer._override !== NOT_PENDING &&
    !(producer._statusFlags & STATUS_PENDING) &&
    inputTime(producer) !== layer._inputTime
  ) {
    // An input answer joins the guessing actions, but the selector stays
    // overridden until their shared lifetime ends. Intermediate answers
    // must not start downstream work beneath the selected guess.
    const scope = liveTx(layer._scope);
    if (scope) {
      if (producer._config & CONFIG_HELD) merge(txOf(producer), scope);
      // A ready input can still be an unparked proposal in this flush.
      // Couple that input frame, not an independently preparing override.
      if (!(layer._output._config & CONFIG_HELD) || txOf(layer._output) !== flushTransaction)
        joinFuture(scope);
    }
    // The pre-commit phase releases the group once all its inputs are ready.
  }
  return layer._override === NOT_PENDING ? read(producer) : readOverride(layer);
}

function removeScope(layer: Layer<any>): void {
  if (!layer._scope) return;
  const scope = resolveTx(layer._scope), layers = scopes.get(scope);
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
  // Incoming input proposals share the override's lifetime; the selected
  // output retains its independent publication update until correction.
  if (layer._input._config & CONFIG_HELD && !(layer._input._statusFlags & STATUS_PENDING))
    merge(txOf(layer._input), layer._scope);
  const current = resolveTx(layer._scope);
  let layers = scopes.get(current);
  if (!layers) scopes.set(current, (layers = new Set()));
  layers.add(layer);
  setLayerBlocked(pendingScope);
}

function layerAccessors<T>(layer: Layer<T>) {
  const output = layer._output;
  const propose = (value: T | ((previous: T) => T)) => {
    const pending = proposals.get(layer);
    const previous =
      proposals.has(layer) && pending !== NOT_PENDING
        ? pending
        : layer._override !== NOT_PENDING
          ? layer._override
          // Without a guess, the pending slot belongs to the input update.
          // A first guess starts from what this output has published.
          : output._value;
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
