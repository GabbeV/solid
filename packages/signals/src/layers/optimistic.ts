/** User guesses and their action lifetime, published by the common layer core. */
import {
  computed,
  creatorPass,
  read,
  signal,
  verdict,
  runWithOwner,
  untrack,
  stageSelectedValue
} from "../core/core.js";
import { enqueueSub } from "../core/heap.js";
import { registerGraph, forgetThrownRead } from "../core/dev.js";
import { dispose, getObserver, getOwner } from "../core/owner.js";
import { attrHooks, setLayerShowsGuess } from "../core/attribution-hooks.js";
import {
  $REFRESH,
  CONFIG_AUTO_DISPOSE,
  CONFIG_HELD,
  CONFIG_REDERIVE,
  CONFIG_LOADING,
  CONFIG_INPUTS_PUBLISHED,
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
  STATUS_ERROR,
  STATUS_UNINITIALIZED
} from "../core/constants.js";
import {
  blocked,
  currentAction,
  flushTransaction,
  GlobalQueue,
  holdNode,
  joinFuture,
  liveTx,
  merge,
  newTransaction,
  resolveTx,
  recomputeInUpdate,
  readyToPublish,
  transactionNodes,
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
  GuessLifetime,
  inputUpdate,
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
let stageGroups: (() => void) | undefined;

function addGroup(group: Set<Layer<any>>): void {
  if (group.size > 1) {
    proposalGroups.add(group);
    stageGroups = stageGroupedProposals;
  }
}
// A store setter can discover changed slots across several recursive writes.
// Each invocation owns its group; nested changed outputs also participate in
// the enclosing setter's compound publication.
let proposalBatch: Set<Layer<any>> | null = null;
const scopes = new Map<Transaction, Set<Layer<any>>>();
// A write that consumes a live guess depends on two different commits. Its
// action shares the source's lifetime; its preview waits only for the
// particular output publication it read. An already displayed guess has
// no such publication. Keep the original action identity across yields.
type GuessRead = { _source: Layer<any>; _scope: Transaction; _publication: Transaction | null };
type GuessWriter = { _guessReads?: Map<Layer<any>, GuessRead> };
let activeSetter: GuessWriter | undefined;
function writer(): GuessWriter | undefined {
  return (currentAction as GuessWriter | null) ?? activeSetter;
}

// Optional data of a queued proposal. Drafts can consume it before it has
// an output transaction; stamp that shared read when the proposal is staged.
type ProposalReads = { _sample?: GuessRead; _uses?: GuessRead[] };
const incoming = new Map<Layer<any>, ProposalReads>();
const publicationReads = new Map<Signal<any>, GuessRead[]>();

function proposalReads(layer: Layer<any>): ProposalReads {
  let reads = incoming.get(layer);
  if (!reads) incoming.set(layer, (reads = {}));
  return reads;
}

function outputUpdate(layer: Layer<any>): Transaction | null {
  return layer._output._config & CONFIG_HELD ? txOf(layer._output) : null;
}

function unpublished(read: GuessRead): Transaction | null {
  const held = read._publication && resolveTx(read._publication);
  return held && held === outputUpdate(read._source) ? held : null;
}

function rememberGuess(source: Layer<any>, queued = false): void {
  const owner = writer();
  if (!owner || !source._scope) return;
  const reads = (owner._guessReads ??= new Map());
  const pending = queued && proposalReads(source);
  let read = pending ? pending._sample : reads.get(source);
  const publication = pending ? null : outputUpdate(source);
  if (!read || read._scope !== source._scope || (!pending && read._publication !== publication)) {
    read = { _source: source, _scope: source._scope, _publication: publication };
    if (pending) pending._sample = read;
  }
  reads.set(source, read);
}

export function inGuessWriter(): boolean {
  return (
    !!writer() &&
    !getObserver() &&
    !verdict &&
    !((creatorPass(getOwner())?._flags ?? 0) & REACTIVE_RECOMPUTING_DEPS)
  );
}

function readGuess<T>(layer: Layer<T>, consume = true): T {
  if (layer._override !== NOT_PENDING && inGuessWriter()) {
    if (consume) rememberGuess(layer);
    return layer._override as T;
  }
  return read(layer._output);
}

/** Publications consumed by this update which still own the version read.
 * Landing a source removes its ordinary held stamp. Retirement of the
 * target removes its edge even if its old preview's flight never resolves. */
function* prerequisites(update: Transaction): Iterable<Transaction> {
  for (const node of transactionNodes(update)) {
    const reads = publicationReads.get(node);
    if (!reads) continue;
    for (const read of reads) {
      const holder = unpublished(read);
      if (holder && holder !== update) yield holder;
    }
  }
}

/** Tarjan components in dependency order. A finished vertex can no longer
 * lower an ancestor's index. The visitor may stop at the first component. */
function visitComponents<T>(
  roots: Iterable<T>,
  dependencies: (node: T) => Iterable<T>,
  accept: (members: T[]) => boolean
): boolean {
  const indices = new Map<T, number>();
  const stack: T[] = [];
  let stopped = false;
  function visit(node: T): number {
    const seen = indices.get(node);
    if (seen !== undefined) return seen;
    const index = indices.size;
    indices.set(node, index);
    stack.push(node);
    let low = index;
    for (const dep of dependencies(node)) {
      low = Math.min(low, visit(dep));
      if (stopped) break;
    }
    if (!stopped && low === index) {
      const members: T[] = [];
      let member: T;
      do {
        member = stack.pop()!;
        indices.set(member, Infinity);
        members.push(member);
      } while (member !== node);
      stopped = !accept(members);
    }
    return low;
  }
  for (const root of roots) {
    visit(root);
    if (stopped) return false;
  }
  return true;
}

let checkingMembers = false;
function awaitingGuess(update: Transaction): boolean {
  if (!publicationReads.size || checkingMembers) return false;
  for (const before of prerequisites(update)) {
    // Land a one-way dependency first. Only a cycle containing this update
    // can land together, and every member still needs its ordinary readiness.
    if (publicationReads.size === 1) return true;
    checkingMembers = true;
    try {
      return !visitComponents(
        [before],
        prerequisites,
        members =>
          members.includes(update) &&
          members.every(member => member === update || readyToPublish(member))
      );
    } finally {
      checkingMembers = false;
    }
  }
  return false;
}

type OptimisticLayer = Layer<any> & { _shownGuess?: boolean };
if (__OBSERVE__) {
  GlobalQueue._layerGuesses = update =>
    Array.from(scopes.get(resolveTx(update)) ?? [], layer => layer._output);
  GlobalQueue._layerPublished = output => {
    const layer = boundaries.get(output) as OptimisticLayer | undefined;
    if (layer?._inputStatus) layer._shownGuess = layer._override !== NOT_PENDING;
  };
  setLayerShowsGuess(output => {
    const layer = boundaries.get(output) as OptimisticLayer | undefined;
    return layer?._inputStatus ? !!layer._shownGuess : undefined;
  });
}
// Only valid inside the synchronous retirement loop, which runs no input
// calculations. Merging invalidates it before admitting any new work.
let settledInputs: Transaction | null = null;

/** Check the work that gives this scope a lifetime. A request whose
 * inputs had already published before a scalar guess belongs to its revert. */
function pendingScope(update: Transaction): boolean {
  if (update === settledInputs) return false;
  const layers = scopes.get(update);
  if (!layers) return false;
  for (const layer of layers) {
    if (layer._lifetime === GuessLifetime.Preview) {
      // Let this guess propagate, then publish ahead of the revert only
      // while its output is synchronously ready.
      if (proposals.has(layer)) return true;
      const output = outputUpdate(layer);
      if (output && output !== update && readyToPublish(output)) return true;
    } else if (pendingInput(layer)) return true;
  }
  return false;
}

/** A store slot can inherit a producer's pending status through its sources. */
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
  publicationReads.delete(layer._output);
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
    !(input._statusFlags & STATUS_PENDING) &&
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
    if (!layer._lifetime || layer._scope) continue;
    // A pending lower input is evidence that an ambient guess can outlive
    // this flush; its preexisting transaction does not own the new guess's
    // action lifetime. The layer core coordinates output publication apart
    // from this scope.
    let scope = flushTransaction && resolveTx(flushTransaction);
    if (!scope && pendingInput(layer)) {
      scope = newTransaction(false);
      bindScope(layer, scope);
      if (layer._lifetime !== GuessLifetime.Preview) holdNode(layer._input, scope);
      continue;
    }
    scope ??= inputUpdate(layer);
    if (scope) bindScope(layer, scope);
    else proposals.delete(layer);
  }
  // Scope membership follows ordinary merging. Output updates which own
  // no guesses do not scan unrelated lifetimes when checking readiness.
  for (const [scope, layers] of scopes) {
    // Absence of a flight is stable during retirement; newly merged work
    // invalidates this shortcut before another readiness check.
    if (!scope._open && !pendingScope(scope)) settledInputs = scope;
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
  // Once either end has published, the dependency has done its job. A
  // later publication of the same output belongs to a different proposal.
  for (const [output, reads] of publicationReads)
    if (!(output._config & CONFIG_HELD) || !reads.some(unpublished))
      publicationReads.delete(output);
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
function positionProposals(): Iterable<Iterable<Layer<any>>> {
  // The normal store setter has independent truth slots at one depth. Keep
  // its existing one-pass positioning and group merge without allocating a
  // component graph. Clear proposals can still hold a correction output, so
  // include them in this check just as the later merge loop does.
  for (const group of proposalGroups) {
    let position: number | undefined;
    for (const layer of group) {
      if (!proposals.has(layer) || layer._output._flags & REACTIVE_DISPOSED) continue;
      if (position !== undefined && position !== layer._position) return groupByDependencies();
      position = layer._position;
    }
  }
  return proposalGroups;
}

function groupByDependencies(): Layer<any>[][] {
  // A compound write adds edges in both directions. Overlapping setters
  // and cycles through their inputs therefore use the same component rule.
  const peers = new Map<Layer<any>, Layer<any>[]>();
  function link(layer: Layer<any>, peer: Layer<any>) {
    const adjacent = peers.get(layer);
    if (adjacent) adjacent.push(peer);
    else peers.set(layer, [peer]);
  }
  for (const group of proposalGroups) {
    let first: Layer<any> | undefined;
    for (const layer of group) {
      if (!proposals.has(layer)) continue;
      if (first) {
        link(first, layer);
        link(layer, first);
      } else first = layer;
    }
  }

  function reachesBoundary(
    source: Signal<any>,
    match: (layer: Layer<any>) => boolean,
    seen = new Set<Signal<any>>()
  ): boolean {
    if (seen.has(source) || typeof (source as Computed<any>)._fn !== "function") return false;
    seen.add(source);
    const layer = boundaries.get(source);
    if (layer)
      return (
        match(layer) ||
        (layer._override === NOT_PENDING && reachesBoundary(layer._input, match, seen))
      );
    for (const dep of committedDependencies(source as Computed<any>))
      if (reachesBoundary(dep, match, seen)) return true;
    return false;
  }

  const groups: Layer<any>[][] = [];
  visitComponents(
    proposals.keys(),
    layer => {
      const deps = peers.get(layer) ?? [];
      reachesBoundary(layer._input, input => {
        if (input._override !== NOT_PENDING && proposals.has(input)) deps.push(input);
        return false;
      });
      return deps;
    },
    members => {
      const transparent = new Set(members.map(member => member._output));
      let depth = 0;
      for (const layer of members) {
        depth = Math.max(depth, layerPosition(layer._input, undefined, transparent));
        // A held input reached through this component already counts in its
        // external inputs. Counting its old transaction would inflate depth
        // on every supersession.
        if (
          !(layer._input._config & CONFIG_HELD) ||
          !reachesBoundary(layer._input, input => transparent.has(input._output))
        )
          depth = Math.max(depth, positionOf(inputUpdate(layer)));
      }
      for (const layer of members) layer._position = depth + 1;
      groups.push(members);
      return true;
    }
  );
  return groups;
}

function applyProposal(proposal: unknown, layer: Layer<any>): void {
  const surviving = proposal !== NOT_PENDING && !(layer._output._flags & REACTIVE_DISPOSED);
  if (!(layer._output._flags & REACTIVE_DISPOSED)) stageLayer(layer, proposal, layer._position);
  if (surviving && layer._onSelected) {
    const onSelected = layer._onSelected;
    layer._onSelected = undefined;
    onSelected();
  }
}

// Only store setters submit compound writes. Installing this entry at the
// first group also lets scalar-only bundles discard the grouping algorithm.
function stageGroupedProposals(): void {
  const groups = positionProposals();
  proposals.forEach(applyProposal);
  for (const group of groups) {
    let first: Transaction | undefined;
    for (const layer of group) {
      if (!proposals.has(layer) || !(layer._output._config & CONFIG_HELD)) continue;
      const update = txOf(layer._output);
      if (!first) first = update;
      else if (first !== update) {
        if (positionOf(first) !== positionOf(update))
          throw new Error("Optimistic store writer groups require outputs at the same depth.");
        merge(update, first);
      }
    }
  }
  proposalGroups.clear();
  stageGroups = undefined;
}

setGuessLifecycle({
  _write: (layer, update, proposal) =>
    !!layer._inputStatus &&
    proposal !== NOT_PENDING &&
    layer._output._deps?._dep === layer._input &&
    stageValueInUpdate(layer._output, update, proposal),
  _notify: forwardInput,
  _awaitingPreview: awaitingGuess,
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
    const changed = proposals.size !== 0;
    if (changed) {
      // Freeze the selections before assigning a context to any of them.
      proposals.forEach(selectProposal);
      for (const layer of proposals.keys())
        layer._position = 1 + Math.max(layerPosition(layer._input), positionOf(inputUpdate(layer)));
    }
    if (stageGroups) stageGroups();
    else if (changed) proposals.forEach(applyProposal);
    // Stamp same-tick reads only after every output has acquired its final
    // holder. A new proposal replaces the previous publication's inputs.
    if (incoming.size || publicationReads.size) {
      for (const layer of proposals.keys()) {
        const reads = incoming.get(layer);
        if (reads?._sample) reads._sample._publication = outputUpdate(layer);
        if (reads?._uses && layer._override !== NOT_PENDING)
          publicationReads.set(layer._output, reads._uses);
        else publicationReads.delete(layer._output);
      }
      incoming.clear();
    }
    if (changed) proposals.clear();
    return changed;
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
  layer._lifetime = GuessLifetime.Action;
  return layerAccessors(layer);
}

/** Explicit proposal/clear adapter used by the model tests. Its extra closure
 * and tuple are absent from applications importing the public scalar API. */
export function createLayer<T>(
  input: Input<T>,
  options?: { lifetime: "action"; node?: NodeOptions<T> }
) {
  const layer = createBoundary(input, options?.node);
  if (options?.lifetime === "action") layer._lifetime = GuessLifetime.Action;
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
  if (layer._lifetime === GuessLifetime.Preview) layer._lifetime = GuessLifetime.Action;
  if (!scopes.size) setLayerBlocked();
}

function releaseLayer(layer: Layer<any>): void {
  publicationReads.delete(layer._output);
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
  // Writes to this slot share its lifetime. Reads consumed by this write
  // join their owners separately; an incoming answer alone does neither.
  const uses = incoming.get(layer)?._uses;
  if (uses) {
    for (const read of uses) {
      const owner = liveTx(read._scope);
      if (owner) merge(scope, owner);
    }
  }
  const current = resolveTx(scope);
  if (
    !layer._scope &&
    layer._lifetime === GuessLifetime.Action &&
    layer._input._config & CONFIG_INPUTS_PUBLISHED &&
    (layer._input._statusFlags & (STATUS_PENDING | STATUS_UNINITIALIZED)) === STATUS_PENDING
  ) {
    // The input outlived its update before this guess was made. It may
    // suspend the correction, but does not keep the setting update open.
    // Re-enter preparation after publication even with no other queued work.
    layer._lifetime = GuessLifetime.Preview;
    current._queues[0].push(wakeLayers);
  }
  layer._scope = current;
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
  published?: { value: T },
  selectInput?: () => T
) {
  const layer = runWithOwner(null, () =>
    createLayerBoundary<T>(
      input as Computed<T>,
      selectInput
        ? layer => (layer._override === NOT_PENDING ? selectInput() : readOverride(layer))
        : selectGuess,
      false,
      true,
      {
        ...(published ? { loadingValue: published.value } : {}),
        unobserved: onUnobserved
      }
    )
  );
  // Store slots share their producer's outstanding request across the
  // compound write (including properties that have no answer of their own).
  layer._lifetime = GuessLifetime.Store;
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
    read: (consume = true) => readGuess(layer, consume),
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

/** A draft can consume an unflushed guess. Its publication is identified
 * when the queued proposal acquires its ordinary output transaction. */
export function entangleOptimisticSlotRead(slot: ReturnType<typeof createOptimisticSlot>): void {
  if (slot.activeOwner()) {
    const layer = boundaries.get(slot.output)!;
    rememberGuess(layer, proposals.has(layer));
  }
}

/** Collect every changed slot submitted during one store setter, including
 * recursive writes. Nested setters also keep their own output groups. */
export function withOptimisticSlotBatch<T>(setter: () => T): T {
  const previous = proposalBatch;
  const previousSetter = activeSetter;
  const group = new Set<Layer<any>>();
  proposalBatch = group;
  activeSetter ??= group as GuessWriter;
  try {
    return setter();
  } finally {
    activeSetter = previousSetter;
    proposalBatch = previous;
    if (previous) for (const layer of group) previous.add(layer);
    addGroup(group);
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
  addGroup(group);
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
  const propose = (value: T | ((previous: T) => T)): T => {
    const owner = writer();
    if (!owner && scopes.size && typeof value === "function") {
      activeSetter = {};
      try {
        return propose(value);
      } finally {
        activeSetter = undefined;
      }
    }
    const previous = previousProposal(layer);
    const next = typeof value === "function" ? (value as (v: T) => T)(previous as T) : value;
    if (output._flags & REACTIVE_DISPOSED) return next;
    if (__OBSERVE__ && attrHooks !== null) {
      attrHooks.write(output, previous, next);
      attrHooks.staged(output);
    }
    const reads = owner?._guessReads;
    if (reads && (reads.size > 1 || !reads.has(layer)))
      proposalReads(layer)._uses = Array.from(reads.values()).filter(
        read => read._source !== layer
      );
    else if (incoming.has(layer)) incoming.get(layer)!._uses = undefined;
    if (layer._lifetime) {
      const scope = flushTransaction ?? (layer._scope && liveTx(layer._scope));
      if (scope) bindScope(layer, scope);
    }
    output._cleanup ??= releaseLayer.bind(null, layer);
    proposals.set(layer, next);
    wakeLayers();
    return next;
  };
  const accessor = () => readGuess(layer);
  (accessor as any)[$REFRESH] = output;
  return [accessor, propose] as const;
}
