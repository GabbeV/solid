/** User guesses and their action lifetime, published by the common layer core. */
import { computed, read, signal, runWithOwner, untrack, stageSelectedValue } from "../core/core.js";
import { enqueueSub } from "../core/heap.js";
import { registerGraph, forgetThrownRead } from "../core/dev.js";
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
  STATUS_PENDING,
  STATUS_ERROR
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
  recomputeInUpdate,
  setLayerBlocked,
  txOf,
  inEffectCallback,
  setEffectCallback,
  stageValueInUpdate,
  type Transaction
} from "../core/scheduler.js";
import type { Computed, NodeOptions, Signal, Root } from "../core/types.js";
import { boundaries } from "./boundary.js";
import { ContextRetry, NotReadyError } from "../core/error.js";
import { committedDependencies, layerPosition } from "./committed-dependencies.js";
import {
  createLayerBoundary,
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
// A store setter can discover changed slots across several recursive writes.
// Each invocation owns its group; nested changed outputs also participate in
// the enclosing setter's compound publication.
let proposalBatch: Set<Layer<any>> | null = null;
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
        layer._input._notifiedAt === layer._inputTime ? "reverted" : "superseded"
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
  for (const layer of layers) if (pendingInput(layer)) return true;
  return false;
}

/** A projection leaf is a plain signal: its producer's flight reaches it as
 * a pending source rather than its own status flag. Both forms justify a
 * guess made while that question is unanswered. */
function pendingInput(layer: Layer<any>): boolean {
  const input = layer._input;
  if (input._statusFlags & STATUS_PENDING) return true;
  for (const source of input._x?._pendingSources ?? [])
    if (source._statusFlags & STATUS_PENDING) return true;
  return false;
}

function retire(layer: Layer<any>): void {
  // An input hidden by an override can outlive the action transaction. Its
  // eventual answer resumes in live ordinary work, never a completed hold.
  const scope = liveTx(layer._scope!);
  if (!scope) joinFuture(null);
  resumeInput(layer, scope ?? resolveTx(flushTransaction!));
  removeScope(layer);
  layer._onRetired?.();
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
    // A pending lower input is evidence that an ambient guess can outlive
    // this flush; its preexisting transaction does not own the new guess's
    // action lifetime. The layer core coordinates output publication apart
    // from this scope.
    let scope = flushTransaction && resolveTx(flushTransaction);
    if (!scope && !pendingInput(layer)) scope = inputUpdate(layer);
    if (!scope && pendingInput(layer)) {
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
        if (pendingInput(layer)) {
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

/** One setter is one selected-output boundary, even when its members' inputs
 * pass through other members. Collapse overlapping setters and dependency
 * cycles before assigning any positions; neither proposal nor group order can
 * then determine the selected frame. */
function positionProposals(): Iterable<Set<Layer<any>>> {
  // The normal store setter has independent truth slots at one depth. Keep
  // its existing one-pass positioning and group merge without allocating a
  // component graph. Clear proposals can still hold a correction output, so
  // include them in this check just as the later merge loop does.
  for (const layer of proposals.keys())
    layer._position = 1 + Math.max(layerPosition(layer._input), positionOf(inputUpdate(layer)));
  if (!proposalGroups.size) return [];
  let uniform = true;
  for (const group of proposalGroups) {
    let position: number | undefined;
    for (const layer of group) {
      if (!proposals.has(layer) || layer._output._flags & REACTIVE_DISPOSED) continue;
      if (position !== undefined && position !== layer._position) {
        uniform = false;
        break;
      }
      position = layer._position;
    }
    if (!uniform) break;
  }
  if (uniform) return proposalGroups;
  const parent = new Map<Layer<any>, Layer<any>>();
  for (const layer of proposals.keys()) parent.set(layer, layer);
  const root = (layer: Layer<any>): Layer<any> => {
    const next = parent.get(layer)!;
    if (next === layer) return layer;
    const result = root(next);
    parent.set(layer, result);
    return result;
  };
  const union = (a: Layer<any>, b: Layer<any>) => {
    a = root(a);
    b = root(b);
    if (a !== b) parent.set(b, a);
  };
  for (const group of proposalGroups) {
    let first: Layer<any> | undefined;
    for (const layer of group) {
      if (!parent.has(layer)) continue;
      if (first) union(first, layer);
      else first = layer;
    }
  }
  const components = () => {
    const result = new Map<Layer<any>, Set<Layer<any>>>();
    for (const layer of parent.keys()) {
      const representative = root(layer);
      let members = result.get(representative);
      if (!members) result.set(representative, (members = new Set()));
      members.add(layer);
    }
    return result;
  };
  const edges = (members: ReadonlySet<Layer<any>>) => {
    const dependencies = new Set<Layer<any>>();
    const walk = (source: Signal<any>, path: Set<Signal<any>>) => {
      if (path.has(source) || typeof (source as Computed<any>)._fn !== "function") return;
      path.add(source);
      try {
        const boundary = boundaries.get(source);
        if (boundary) {
          if (parent.has(boundary) && proposals.get(boundary) !== NOT_PENDING) {
            if (members.has(boundary)) walk(boundary._input, path);
            else dependencies.add(root(boundary));
          } else if (boundary._override === NOT_PENDING) walk(boundary._input, path);
        } else {
          for (const dependency of committedDependencies(source as Computed<any>))
            walk(dependency, path);
        }
      } finally {
        path.delete(source);
      }
    };
    for (const layer of members) walk(layer._input, new Set());
    return dependencies;
  };
  // A cycle between setter groups is itself one publication boundary. Tarjan
  // runs only for queued proposals; ordinary reads acquire no graph work.
  const groups = components();
  const index = new Map<Layer<any>, number>();
  const low = new Map<Layer<any>, number>();
  const stack: Layer<any>[] = [];
  const onStack = new Set<Layer<any>>();
  let nextIndex = 0;
  const visit = (group: Layer<any>) => {
    index.set(group, nextIndex);
    low.set(group, nextIndex++);
    stack.push(group);
    onStack.add(group);
    for (const dependency of edges(groups.get(group)!)) {
      if (!index.has(dependency)) {
        visit(dependency);
        low.set(group, Math.min(low.get(group)!, low.get(dependency)!));
      } else if (onStack.has(dependency))
        low.set(group, Math.min(low.get(group)!, index.get(dependency)!));
    }
    if (low.get(group) !== index.get(group)) return;
    const members: Layer<any>[] = [];
    let member: Layer<any>;
    do {
      member = stack.pop()!;
      onStack.delete(member);
      members.push(member);
    } while (member !== group);
    for (let i = 1; i < members.length; i++) union(members[0], members[i]);
  };
  for (const group of groups.keys()) if (!index.has(group)) visit(group);

  const merged = components();
  const positioned = new Set<Layer<any>>();
  const position = (group: Layer<any>): number => {
    group = root(group);
    if (positioned.has(group)) return merged.get(group)!.values().next().value!._position!;
    const members = merged.get(group)!;
    for (const dependency of edges(members)) position(dependency);
    const transparent = new Set<Signal<any>>();
    for (const layer of members) transparent.add(layer._output);
    const throughMember = (source: Signal<any>, path = new Set<Signal<any>>()): boolean => {
      if (transparent.has(source)) return true;
      if (path.has(source) || typeof (source as Computed<any>)._fn !== "function") return false;
      path.add(source);
      try {
        const boundary = boundaries.get(source);
        if (boundary)
          return boundary._override === NOT_PENDING && throughMember(boundary._input, path);
        for (const dependency of committedDependencies(source as Computed<any>))
          if (throughMember(dependency, path)) return true;
        return false;
      } finally {
        path.delete(source);
      }
    };
    let depth = 0;
    for (const layer of members) {
      depth = Math.max(depth, layerPosition(layer._input, undefined, transparent));
      // An input update reached through this group's selected output is an
      // earlier version of the same cut. Count its external graph inputs in
      // layerPosition above, but do not count its held transaction again on
      // every supersession. An unheld input returns the action scope instead.
      if (!(layer._input._config & CONFIG_HELD) || !throughMember(layer._input))
        depth = Math.max(depth, positionOf(inputUpdate(layer)));
    }
    for (const layer of members) layer._position = depth + 1;
    positioned.add(group);
    return depth + 1;
  };
  for (const group of merged.keys()) position(group);
  return merged.values();
}

function applyProposal(proposal: unknown, layer: Layer<any>): void {
  const surviving = proposal !== NOT_PENDING && !(layer._output._flags & REACTIVE_DISPOSED);
  if (!(layer._output._flags & REACTIVE_DISPOSED)) stageLayer(layer, proposal, layer._position);
  if (layer._opening) {
    resolveTx(layer._scope!)._open--;
    layer._opening = undefined;
  }
  if (surviving && layer._onSelected) {
    const onSelected = layer._onSelected;
    layer._onSelected = undefined;
    onSelected();
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
    const groups = positionProposals();
    proposals.forEach(applyProposal);
    for (const group of groups) {
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

/** Initialize a store-owned truth input outside the setter action. Its
 * pending producer must not acquire the lifetime of a new independent guess. */
export function createOptimisticStoreInput<T>(fn: () => T, options?: NodeOptions<T>) {
  return runWithOwner(null, () => {
    const input = computed(fn, { ...options, lazy: true });
    recomputeInUpdate(input, null, false, true);
    return input;
  });
}

/** A store-owned truth slot and its ordinary selected output. Like a source
 * observation, the companion is independent of creator and reader owners. */
export function createOptimisticSlot<T>(
  input: Signal<T>,
  onUnobserved?: () => void,
  onSelected?: () => void,
  onRetired?: () => void,
  published?: { value: T }
) {
  const layer = runWithOwner(null, () =>
    createLayerBoundary<T>(input as Computed<T>, selectGuess, false, true, {
      ...(published ? { loadingValue: published.value } : {}),
      unobserved: onUnobserved
    })
  );
  layer._automatic = true;
  layer._inputStatus = true;
  layer._onSelected = onSelected;
  layer._onRetired = onRetired;
  layer._output._config &= ~CONFIG_AUTO_DISPOSE;
  if (__OBSERVE__ && attrHooks !== null) {
    (layer._output as any)._name = (input as any)._name;
    (layer._output as any)._loc = (input as any)._loc;
  }
  recomputeInUpdate(layer._output, null, false, true);
  const [, propose] = layerAccessors(layer);
  // Establish the initial published value even when the first operation is a
  // setter. No function/thenable normalization: slot contents are raw values.
  try {
    untrack(() => read(layer._output));
  } catch (error) {
    // Pending and failed truth inputs retain their ordinary output status;
    // an explicit first proposal can still replace that published answer.
    if (
      error instanceof ContextRetry ||
      (!(error instanceof NotReadyError) && !(layer._output._statusFlags & STATUS_ERROR))
    )
      throw error;
    if (__DEV__) forgetThrownRead();
  }
  const isIdle = (unobserved = false) => {
    const output = layer._output;
    // A subscriber-free CHECK owns no publication: a later reader can rebuild
    // it. Association cleanup with readers still present uses the strict check.
    const busy =
      (unobserved ? 0 : REACTIVE_CHECK) |
      REACTIVE_DIRTY |
      REACTIVE_IN_HEAP |
      REACTIVE_RECOMPUTING_DEPS |
      REACTIVE_ZOMBIE;
    return (
      layer._scope === null &&
      !proposals.has(layer) &&
      layer._override === NOT_PENDING &&
      !((output._config | input._config) & CONFIG_HELD) &&
      output._pendingValue === NOT_PENDING &&
      input._pendingValue === NOT_PENDING &&
      !((output._statusFlags | layer._input._statusFlags) & STATUS_PENDING) &&
      !((output._flags | layer._input._flags) & busy)
    );
  };
  return {
    output: layer._output,
    propose: (value: T) => {
      // A changed proposal can introduce a different child in the same
      // action. Repeated equal proposals do not need another discovery pass.
      if (
        onSelected &&
        !layer._onSelected &&
        (layer._scope === null || !Object.is(value, previousProposal(layer)))
      )
        layer._onSelected = onSelected;
      const next = propose(() => value);
      if (proposalBatch && !(layer._output._flags & REACTIVE_DISPOSED)) proposalBatch.add(layer);
      return next;
    },
    writerValue: () => previousProposal(layer),
    // This is the action that owns the selected guess, not the output's
    // publication transaction. A pending proposal can also be consumed by a
    // later setter before the selection pass runs.
    activeOwner: (): Transaction | null => {
      if (
        layer._scope === null ||
        (layer._override === NOT_PENDING &&
          (!proposals.has(layer) || proposals.get(layer) === NOT_PENDING))
      )
        return null;
      return liveTx(layer._scope);
    },
    // A structural candidate can retire before its readers unlink. The
    // store first invalidates their discovery node, then retries release.
    isIdle,
    // The store retries only companions whose readers left. A live guess or
    // an unfinished correction is state, even with no subscribers. A disposed
    // producer cannot finish its correction; once its action closes an
    // unobserved companion may release that abandoned input.
    tryRelease: (abandoned = false) => {
      const output = layer._output;
      const ownsGuess =
        (layer._scope !== null && (liveTx(layer._scope)?._open ?? 0) > 0) || proposals.has(layer);
      if (output._subs !== null || (!isIdle(true) && (!abandoned || ownsGuess))) return false;
      dispose(output as Computed<any>);
      return true;
    }
  };
}

/** An actual store-setter read of another selected guess joins its action.
 * Output publication alone must not join these independent lifetimes. */
export function entangleOptimisticSlotRead(slot: ReturnType<typeof createOptimisticSlot>): void {
  const owner = slot.activeOwner();
  if (owner && flushTransaction) merge(flushTransaction, owner);
}

/** Collect every changed slot submitted during one store setter, including
 * recursive writes. Nested setters also keep their own output groups. */
export function withOptimisticSlotBatch<T>(setter: () => T): T {
  const previous = proposalBatch;
  const group = new Set<Layer<any>>();
  proposalBatch = group;
  try {
    return setter();
  } finally {
    proposalBatch = previous;
    if (previous) for (const layer of group) previous.add(layer);
    if (group.size > 1) proposalGroups.add(group);
  }
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
  return (
    proposals.has(layer) && pending !== NOT_PENDING
      ? pending
      : layer._override !== NOT_PENDING
        ? layer._override
        : layer._output._value
  ) as T;
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
