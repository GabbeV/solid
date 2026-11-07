/**
 * Shared layer coordination: an input producer and an ordinary output computation.
 * Explicit propose/clear isolates publication; the optional action lifetime
 * retires overrides through the same ordinary derivation and commit paths.
 * Updates at every depth use the ordinary scheduler and publication path.
 */
import { releaseFlightTeardown } from "../core/async.js";
import { clearThrownRead } from "../core/dev.js";
import { computed, tracking } from "../core/core.js";
import { link } from "../core/graph.js";
import { NotReadyError } from "../core/error.js";
import { enqueueSub } from "../core/heap.js";
import { disposeChildren } from "../core/owner.js";
import {
  LEGACY_LANES,
  CONFIG_AUTO_DISPOSE,
  CONFIG_FRAME,
  CONFIG_HELD,
  REACTIVE_LAYER_EFFECT,
  REACTIVE_PREVIOUS_COMMITTED,
  CONFIG_REDERIVE,
  CONFIG_STAGED,
  EFFECT_RENDER,
  NOT_PENDING,
  REACTIVE_DISPOSED,
  REACTIVE_FRAME_READ,
  REACTIVE_IN_HEAP,
  REACTIVE_JOINED,
  REACTIVE_LANE_DIRTY,
  REACTIVE_RECOMPUTING_DEPS,
  REACTIVE_STAGED_READ,
  REACTIVE_ZOMBIE,
  STATUS_UNINITIALIZED,
  STATUS_NO_VALUE,
  STATUS_PENDING,
  STATUS_ERROR
} from "../core/constants.js";
import {
  blocked,
  cleanupReruns,
  deferZombie,
  removalStagedBy,
  onScreen,
  setLayerVisibility,
  flushTransaction,
  freshHook,
  globalQueue,
  setLayerCommit,
  setLayerReads,
  setLayerCompute,
  layerCompute,
  transactions,
  setLayerTransactions,
  holdNode,
  holdQueuedProposals,
  recomputeInUpdate,
  setCalculationUpdate,
  hasUnheldProposals,
  insertSubs,
  joinFuture,
  liveTx,
  merge,
  newTransaction,
  resolveTx,
  schedule,
  staleReader,
  queueRerun,
  rerunHolders,
  txOf,
  type NormalizeCalculation,
  type Transaction
} from "../core/scheduler.js";
import type { Computed, NodeOptions, Signal } from "../core/types.js";
import { boundaries, RETRY } from "./boundary.js";
import {
  committedDependencies,
  insertedDependencyCount,
  layerPosition
} from "./committed-dependencies.js";

export function inputTime(input: Computed<any>): number {
  return typeof input._fn === "function" ? input._time : input._notifiedAt;
}

export type Layer<T> = {
  _input: Computed<any>;
  _output: Computed<T>;
  _override: T | typeof NOT_PENDING;
  _scope: Transaction | null;
  _inputTime?: number;
  _inputStatus?: true;
  _statusInput?: Computed<any>;
  _position?: number;
  _automatic?: true;
  _opening?: true;
  _refreshInput?: (layer: Layer<any>) => void;
};

/** Value overrides retain the pending calculation of their relative input.
 * Observation boundaries do not inherit the pending state they describe. */
export function pendingInput(source: Signal<any>): Computed<any> | undefined {
  const boundary = boundaries.get(source);
  return boundary?._statusInput ?? (boundary?._inputStatus ? boundary._input : undefined);
}

export function observed(
  node: Computed<any>,
  update: Transaction | null,
  seen = new Set<Computed<any>>()
): boolean {
  if (seen.has(node) || node._flags & REACTIVE_DISPOSED || !onScreen(node, update)) return false;
  seen.add(node);
  if ((node as any)._type === EFFECT_RENDER) return true;
  for (let edge = node._subs; edge; edge = edge._nextSub) {
    const reader = edge._sub;
    // An override retains its input subscription to receive future answers,
    // but does not consume that input. This cut also applies when tracing
    // demand through otherwise transparent, inactive boundaries.
    const boundary = boundaries.get(reader);
    if (boundary?._input === node && boundary._override !== NOT_PENDING) continue;
    const replaces =
      update &&
      !(reader._statusFlags & (STATUS_PENDING | STATUS_ERROR)) &&
      reader._config & CONFIG_HELD &&
      txOf(reader) === resolveTx(update);
    let reads = edge._gen === reader._depGen;
    // A different pending update has not removed the displayed dependency.
    // The retained frame journal distinguishes old reads from new insertions.
    if (!reads && !replaces)
      for (const dependency of committedDependencies(reader))
        if (dependency === node) {
          reads = true;
          break;
        }
    if (reads && observed(reader, update, seen)) return true;
  }
  return false;
}

// CONFIG_REDERIVE absorbs status at the selector. Unlike a display boundary,
// an optimistic selector is not itself an observer once its readers disappear.
setLayerVisibility((output, update) => !boundaries.get(output) || observed(output, update));
// A child update may observe its input update's published frame without
// consuming that update's proposal. Only live child updates have this record.
// The optional coordinator gives every participating update a numeric depth.
// Settled ordinary reads and ordinary nodes keep their existing fast paths.
export function positionOf(update: Transaction | null): number {
  return update ? (resolveTx(update)._level ?? 0) : 0;
}
let releasingInput: Transaction | null = null;
let evaluation: Computed<any> | null = null;
let evaluationReads: Set<Transaction> | null = null;
// Untracked reads select a calculation context without adding subscriptions.
// Keep their discovered depth only for this attempt, not on ordinary nodes.
let evaluationPosition = 0;
let retryEvaluation = false;
let creating: Computed<any> | null = null;
// First render calculations inherit proposals their still-running creators
// have consumed, even before those tentative peer joins are accepted.
let creatingReads: Set<Transaction>[] | null = null;
// Only a new child consuming several distinct holds needs deferred admission.
// The list lasts for one enclosing calculation, never for an update's lifetime.
let creationReads:
  | {
      node: Computed<any>;
      update: Transaction;
      reads: Set<Transaction>;
    }[]
  | null = null;
const layerOwn = (node: Signal<any>, update: Transaction) => {
  if (!(node._config & CONFIG_REDERIVE)) return;
  const layer = boundaries.get(node);
  if (layer === undefined) return;
  // A settled selector propagates normally. If its consequences suspend,
  // ordinary parking supplies the output update and we record only its cut.
  // The selector retires its override before proposing any input answer.
  // list() calls this before stamping ownership. The ordinary output stamp
  // therefore also tells us whether this cut already has a publication update.
  if (
    !node._x?._transaction &&
    layer._override !== NOT_PENDING &&
    node._pendingValue !== NOT_PENDING &&
    !Object.is(node._value, node._pendingValue)
  )
    setOutputDepth(layer, update);
};

/** User guesses settle before observations sample their downstream work.
 * Each feature installs only its own lifetime; both use common publication. */
type BoundaryLifecycle = {
  _merge?: (from: Transaction, into: Transaction) => void;
  _write?: (layer: Layer<any>, update: Transaction, proposal: unknown) => boolean;
  _notify?: (source: Signal<any>, reader: Computed<any>, update: Transaction) => boolean | void;
  _prepare: () => boolean;
  _settle: () => boolean | void;
  _active: () => boolean;
};
let guesses: BoundaryLifecycle | undefined;
let observations: BoundaryLifecycle | undefined;
export function setGuessLifecycle(lifecycle: BoundaryLifecycle): void {
  guesses = lifecycle;
}
export function setObservationLifecycle(lifecycle: BoundaryLifecycle): void {
  observations = lifecycle;
}

export function wakeLayers(): void {
  setLayerCommit(prepareLayers, settleLayers, canPublish, holdsLifetime);
  schedule();
}

function enableReads(): void {
  setLayerReads(layerOwn, mergeLayers, frameRead, rederiveStatus, notifyLayer);
}

function stopIfIdle(): void {
  if (transactions.length || guesses?._active() || observations?._active()) return;
  setLayerCommit();
  setLayerReads();
  setLayerCompute();
}

// Updates of every depth live in the scheduler's ordinary transaction list.
// Activate once for the first hold; no second registry or merge/landing cleanup.
function enableCoordination(): void {
  if (layerCompute) return;
  enableReads();
  setLayerCompute(computeLayer, rerunLayer, readContext, deferJoin, detachedOutput);
}

function isChildUpdate(update: Transaction | null): boolean {
  return positionOf(update) > 0;
}

export function inputUpdate(layer: Layer<any>): Transaction | null {
  if (layer._input._config & CONFIG_HELD) return txOf(layer._input);
  if (layer._scope) return liveTx(layer._scope);
  const boundary = boundaries.get(layer._input);
  return boundary?._inputStatus ? inputUpdate(boundary) : null;
}

/** Retire the override in its input update, or in an ordinary flush when the
 * input is unheld. Reading below then uses normal derivation joining.
 * Published output and owned children stay in the common committed slots. */
export function resumeInput(
  layer: Layer<any>,
  update: Transaction | null,
  prepare = false
): Transaction | null {
  layer._override = NOT_PENDING;
  // Retiring the cut makes its suspended consequences input work again.
  // Recompute will supersede obsolete flights in that common update.
  if (layer._output._config & CONFIG_HELD)
    merge(txOf(layer._output), (update ??= newTransaction(false)));
  // A prepared restoration belongs to its selected input update even when
  // another update triggered the seam. Scoped recomputation keeps unrelated
  // flush work separate; actual reads still perform the usual peer joins.
  if (prepare) recomputeInUpdate(layer._output, update, true);
  else {
    if (update) joinFuture(update);
    enqueueSub(layer._output);
  }
  return update;
}

let orderPublication = false;

/** A speculative pass can add or drop inputs without replacing the displayed
 * result. Only a change reaching that committed result requires preparation
 * before the lower update publishes. */
function committedUsesUpdate(
  node: Computed<any>,
  update: Transaction,
  seen = new Set<Signal<any>>()
): boolean {
  if (seen.has(node)) return false;
  seen.add(node);
  const boundary = boundaries.get(node);
  if (boundary && boundary._override !== NOT_PENDING) return false;
  for (const input of committedDependencies(node)) {
    if (input._config & CONFIG_HELD && txOf(input) === update) return true;
    if (
      typeof (input as Computed<any>)._fn === "function" &&
      committedUsesUpdate(input as Computed<any>, update, seen)
    )
      return true;
  }
  return false;
}

/** A published observation can leave a newly mounted lower reader waiting
 * on its old frame. Prepare that frame's incoming proposal on demand; waiting
 * for the consumer first would make its correction depend on its own finish.
 * Active overrides remain cuts, as in ordinary observation accounting. */
function pendingConsumer(
  node: Computed<any>,
  parent: Transaction,
  seen = new Set<Computed<any>>()
): boolean {
  if (seen.has(node)) return false;
  seen.add(node);
  for (let edge = node._subs; edge; edge = edge._nextSub) {
    const reader = edge._sub;
    if (reader._flags & REACTIVE_DISPOSED || edge._gen !== reader._depGen) continue;
    const boundary = boundaries.get(reader);
    if (boundary?._input === node && boundary._override !== NOT_PENDING) continue;
    if (
      (reader as any)._type === EFFECT_RENDER &&
      reader._statusFlags & STATUS_PENDING &&
      reader._config & CONFIG_HELD &&
      txOf(reader) === parent &&
      onScreen(reader, parent)
    )
      return true;
    if (pendingConsumer(reader, parent, seen)) return true;
  }
  return false;
}

function prepareLayers(): boolean {
  // This round can discover a lower flight after a child already re-ran.
  // Include all its proposals before deciding whether that input is ready.
  if (flushTransaction) holdQueuedProposals(resolveTx(flushTransaction));
  let changed = false;
  // Retire observations before replaying readers of the now-ready input.
  // A callback probe also reads that input for control flow. Replaying it
  // against a stale true observation would join the ready input to the
  // obsolete async consequence that the false observation must supersede.
  changed = !!guesses?._prepare();
  changed = !!observations?._prepare() || changed;
  // Only updates with waiting readers require preparation. The scheduler
  // already indexes these for disposal, and maintains the index on merges.
  // A replay sets changed, so transferred readers are reconsidered before
  // any publication even if their surviving update was already visited.
  for (const parent of rerunHolders) {
    if (!parent._reruns?.size) continue;
    const waiting = blocked(parent);
    for (const reader of parent._reruns) {
      // Only settled publications can be replayed before the input is ready.
      // Do not supersede an unfinished higher proposal to satisfy this demand.
      if (
        waiting &&
        (reader._config & CONFIG_HELD ||
          reader._statusFlags & STATUS_PENDING ||
          !pendingConsumer(reader, parent))
      )
        continue;
      const heldAbove =
        reader._config & CONFIG_HELD && positionOf(txOf(reader)) > positionOf(parent);
      // A newly selected output has already queued this reader in its
      // higher context. Run that pass before the input's restoration can
      // take it back; other ready readers can still prepare this round.
      if (changed && heldAbove && reader._flags & REACTIVE_IN_HEAP) continue;
      const affectsCommitted = heldAbove && committedUsesUpdate(reader, parent);
      // Structural boundary readers use the same post-publication replay as
      // direct bindings. Preparing them independently for sibling updates
      // can keep registering each other's already-ready frames forever.
      if (
        !(reader as any)._type &&
        !(reader._config & CONFIG_FRAME) &&
        (reader._flags & REACTIVE_FRAME_READ || affectsCommitted) &&
        !(reader._flags & REACTIVE_DISPOSED)
      ) {
        // A lower input used only by an unpublished upper branch can commit
        // independently. Its ordinary post-commit rerun refreshes that branch.
        if (heldAbove && !affectsCommitted) continue;
        const frame = unpublishedFrame(reader);
        if (frame && positionOf(frame) < positionOf(parent)) {
          orderPublication = true;
          continue;
        }
        // Derivations of a committed parent frame must discover their next
        // async work before that parent publishes. A post-commit rerun is
        // sufficient for a direct binding, but would let a memo lag behind
        // an already-published input after its boundary dependency changes.
        parent._reruns!.delete(reader);
        reader._flags &= ~REACTIVE_FRAME_READ;
        const previous = releasingInput;
        releasingInput = parent;
        try {
          recomputeInUpdate(reader, parent);
        } finally {
          releasingInput = previous;
        }
        changed = true;
        // This pass can merge its holder into another update. Its remaining
        // readers moved there; reconsider that holder's readiness on the
        // next iteration instead of continuing against the emptied record.
        if (resolveTx(parent) !== parent) break;
      }
    }
  }
  return changed;
}

function mergeLayers(from: Transaction, into: Transaction): void {
  guesses?._merge?.(from, into);
  const fromPosition = positionOf(from),
    intoPosition = positionOf(into);
  if (fromPosition !== intoPosition) {
    const higher = fromPosition > intoPosition ? from : into;
    for (
      let i = 0, node = LEGACY_LANES ? higher._nodes[0] : higher._firstHeld;
      node;
      node = LEGACY_LANES ? higher._nodes[++i] : node._x!._nextHeld
    )
      if (
        node._config & CONFIG_HELD &&
        (!LEGACY_LANES || txOf(node) === higher) &&
        node._pendingValue !== NOT_PENDING
      )
        if ((node as Computed<any>)._fn)
          (node as Computed<any>)._flags |= REACTIVE_PREVIOUS_COMMITTED;
    into._level = Math.min(fromPosition, intoPosition);
  }
}

function includesBoundary(reader: Computed<any>, holder: Transaction): boolean {
  return (
    Math.max(currentPosition(reader), evaluation === reader ? evaluationPosition : 0) >
    positionOf(holder)
  );
}

/** A new owned frame belongs to its creator's proposal until that creator
 * publishes. Parked children are the old visible frame and are not excluded. */
function unpublishedFrame(node: Computed<any>): Transaction | null {
  let child = node;
  for (let owner = node._parent; owner; child = owner as Computed<any>, owner = owner._parent) {
    if (child._flags & REACTIVE_ZOMBIE) return null;
    const parent = owner as Computed<any>;
    if (
      parent._flags & REACTIVE_RECOMPUTING_DEPS &&
      parent._flags & (REACTIVE_JOINED | REACTIVE_STAGED_READ)
    )
      return parent._config & CONFIG_HELD ? txOf(parent) : flushTransaction;
    if (parent._config & CONFIG_STAGED && parent._config & CONFIG_HELD) return txOf(parent);
  }
  return null;
}

function frameRead(reader: Computed<any>, source: Signal<any>): boolean | null {
  const update = flushTransaction;
  // An unobserved lower flight can outlive its input update's publication.
  // Its initialized value is still the lower frame of a higher calculation;
  // releasing the update must not make that reader inherit the flight again.
  // A source still deriving from a peer override is not lower merely because
  // it lost its holder. Reuse context discovery on this pending-only path.
  if (!(source._config & CONFIG_HELD))
    return (
      positionOf(update) > 0 &&
      !((source as Computed<any>)._statusFlags & STATUS_UNINITIALIZED) &&
      positionOf(update) > currentPosition(source)
    );
  // Most active propagation reads a proposal from this exact update. Merged
  // holders still take the resolving path below.
  if (update && source._x!._transaction === update) return false;
  const uninitialized = (source as Computed<any>)._statusFlags & STATUS_UNINITIALIZED;
  const holder = txOf(source);
  if (update && holder === resolveTx(update)) return false;
  const ownPosition = positionOf(update),
    heldPosition = positionOf(holder);
  if (
    creating === reader &&
    (reader as any)._type === EFFECT_RENDER &&
    ownPosition === heldPosition &&
    creatingReads
  ) {
    for (const reads of creatingReads)
      for (const input of reads)
        if (resolveTx(input) === holder) {
          reader._flags |= REACTIVE_JOINED;
          return null;
        }
  }
  const frame = heldPosition > ownPosition && unpublishedFrame(reader);
  if (frame) {
    staleReader(reader, holder);
    orderPublication = true;
    // Private calculations retain the creator's input context. A higher
    // proposal is not an older published input of that context. Preserve
    // its dependency and replay obligation without merging the two updates.
    // Structural readers still wait; only a first render initializes private
    // DOM here. Pending/error proposals take the ordinary status path.
    if (
      reader._config & CONFIG_FRAME &&
      !(creating === reader && (reader as any)._type === EFFECT_RENDER)
    )
      throw new NotReadyError(source);
    return null;
  }
  if (ownPosition > heldPosition) {
    staleReader(reader, holder);
    // There is no lower published frame to read yet. Wait for its first
    // publication instead of repeatedly consuming a proposal that this
    // higher context cannot use on its retry either.
    if (uninitialized) throw new NotReadyError(source);
    return true;
  }
  if (uninitialized) return false;
  if (ownPosition > 0 && heldPosition > 0) return false;
  // Direct bindings already have the common committed-frame read rule.
  // They do not need a speculative derivation or a provisional transaction.
  if ((reader as any)._type === EFFECT_RENDER) return false;
  // An unpublished parent's provisional update may not yet be merged with
  // the peer whose proposal opened it. Its new children still consume that
  // proposal, even after reading an observation. Higher/lower contexts were
  // handled above; this preserves the parent's frame without an early merge.
  if (includesBoundary(reader, holder) && !unpublishedFrame(reader)) {
    staleReader(reader, holder);
    return true;
  }
  return false;
}

/** A lower pending/error notification is an obligation to check, not a read
 * of its proposal. Let the existing higher calculation select its inputs;
 * inheriting status here would merge the contexts before that selection. */
function rederiveStatus(reader: Computed<any>, source: Computed<any>): boolean {
  if (!(reader._config & CONFIG_HELD)) return false;
  // A published error is the current input, not a lower proposal. Propagate
  // it normally; explicit selectors still choose their own output.
  if (source._statusFlags & STATUS_ERROR && !(source._config & CONFIG_HELD)) return false;
  const incoming = source._config & CONFIG_HELD ? txOf(source) : flushTransaction;
  const ownPosition = positionOf(txOf(reader)),
    incomingPosition = positionOf(incoming);
  if (
    ownPosition <= incomingPosition &&
    !(ownPosition < incomingPosition && unpublishedFrame(reader))
  )
    return false;
  enqueueSub(reader);
  schedule();
  return true;
}

/** A notification does not consume its update's proposal. A held child's
 * pass first keeps its own context; actual reads can still merge peer work.
 * Ready input releases explicitly run in the input context instead. */
function rerunLayer(node: Computed<any>, create: boolean, fromHeap: boolean): boolean {
  if (create) {
    const parent = node._parent as Computed<any> | null;
    // A nested pull may temporarily switch the ambient update. Preserve the
    // creator's actual frame before its child can discover such an output;
    // this stamps its provisional update without merging consumed peers.
    if (
      flushTransaction &&
      parent &&
      parent._flags & REACTIVE_RECOMPUTING_DEPS &&
      parent._flags & (REACTIVE_JOINED | REACTIVE_STAGED_READ) &&
      !(parent._config & CONFIG_HELD)
    )
      holdNode(parent, resolveTx(flushTransaction));
    const effect = (node as any)._type;
    if (!effect && (evaluation ? detachedOutput(node) : globalQueue._running || flushTransaction))
      return scopedCalculation(node, flushTransaction, create, fromHeap);
    const reads = evaluationReads;
    if (reads) (creatingReads ??= []).push(reads);
    const previous = creating;
    creating = node;
    // A scope isolates discovery and staging; it is not itself a transaction.
    // A held read or async result acquires one through the ordinary join path.
    // An owned child inherits only an update its creator actually entered.
    try {
      if (effect) return scopedCalculation(node, flushTransaction, create, fromHeap);
      recomputeInUpdate(node, flushTransaction, false, true);
    } finally {
      creating = previous;
      if (reads) creatingReads!.pop();
      if (!creatingReads?.length) creatingReads = null;
    }
    return true;
  }
  // A notification can precede the parking that makes this node retained.
  // Decide removal ownership now: only another update may run it ahead.
  if (
    fromHeap &&
    node._flags & REACTIVE_ZOMBIE &&
    node._config & CONFIG_HELD &&
    removalStagedBy(node, txOf(node))
  ) {
    deferZombie(node);
    return true;
  }
  // A re-armed Loading catches this pass independently of the notifying
  // flush. Discover and accept its inputs inside that scope, so tentative
  // peer joins do not pull the re-arm's unrelated writes into the old hold.
  if (flushTransaction === null && freshHook?.(node)) {
    recomputeInUpdate(node, null);
    return true;
  }
  // A retained producer without a first value cannot supply a committed
  // answer to an optimistic caller. Finish its initialization in its input
  // context, not in the caller's higher context; that would retry a lower
  // recovery against the old input and dispose it before it can recover.
  if (
    node._flags & REACTIVE_ZOMBIE &&
    node._statusFlags & (STATUS_UNINITIALIZED | STATUS_NO_VALUE) &&
    !(node as any)._type &&
    !(node._config & (CONFIG_HELD | CONFIG_FRAME | CONFIG_REDERIVE)) &&
    positionOf(flushTransaction) > currentPosition(node)
  ) {
    let update: Transaction | null = null;
    for (let edge = node._deps; edge; edge = edge._nextDep)
      if (edge._dep._config & CONFIG_HELD) {
        update = txOf(edge._dep);
        break;
      }
    recomputeInUpdate(node, update);
    return true;
  }
  const frame = unpublishedFrame(node);
  if (
    frame &&
    flushTransaction &&
    frame !== resolveTx(flushTransaction) &&
    positionOf(frame) < positionOf(flushTransaction)
  ) {
    node._flags &= ~REACTIVE_LAYER_EFFECT;
    recomputeInUpdate(node, frame, true);
    return true;
  }
  if ((node as any)._type) {
    if (!(node._flags & REACTIVE_LAYER_EFFECT))
      return scopedCalculation(node, flushTransaction, false, fromHeap);
    node._flags &= ~REACTIVE_LAYER_EFFECT;
  }
  const own = node._config & CONFIG_HELD ? txOf(node) : null;
  if (!isChildUpdate(own)) return scopedCalculation(node, flushTransaction, false, fromHeap);
  if (!flushTransaction && hasUnheldProposals()) joinFuture(null);
  const incoming = flushTransaction && resolveTx(flushTransaction);
  if (incoming === own || (incoming && incoming === releasingInput))
    return scopedCalculation(node, flushTransaction, false, fromHeap);
  if (positionOf(incoming) >= positionOf(own))
    return scopedCalculation(node, flushTransaction, false, fromHeap);
  if (incoming) holdQueuedProposals(incoming);
  recomputeInUpdate(node, own, true, false, fromHeap);
  // The displayed frame can still depend on the notifying update even when
  // this speculative pass drops that input. Its publication obligation must
  // survive independently of the reads performed by the replacement. Queue
  // preparation without stamping a stale value read: that flag also forwards
  // pending demand, which would incorrectly undo a Loading fallback's release.
  if (incoming && committedUsesUpdate(node, resolveTx(incoming))) {
    queueRerun(incoming, node);
  }
  return true;
}

function scopedCalculation(
  node: Computed<any>,
  update: Transaction | null,
  create: boolean,
  fromHeap: boolean
): true {
  recomputeInUpdate(node, update, false, create, fromHeap, true);
  return true;
}

function deferJoin(reader: Computed<any>, source: Signal<any>): boolean {
  if (evaluation !== reader || (reader as any)._type === EFFECT_RENDER) return false;
  const holder = txOf(source);
  if (flushTransaction && resolveTx(flushTransaction) === holder) return false;
  (evaluationReads ??= new Set()).add(holder);
  // Isolate tentative reads before merging their holders. A fresh frame
  // adopts its accepted input context in computeLayer, after discovery.
  joinFuture(null);
  reader._flags |= REACTIVE_JOINED;
  return true;
}

/** The dependency prefix of this attempt selects its retry context. Existing
 * overrides retain their frozen position; discovering inputs cannot move them. */
function currentPosition(node: Signal<any>, seen = new Set<Signal<any>>()): number {
  if (seen.has(node)) return 0;
  seen.add(node);
  const boundary = boundaries.get(node);
  // A settled observation can retain its selector (pending=false) without
  // retaining an update context. Active overrides keep their frozen depth.
  if (
    boundary &&
    boundary._override !== NOT_PENDING &&
    (node._config & CONFIG_HELD || inputUpdate(boundary))
  )
    return boundary._position ?? 1;
  const computed = node as Computed<any>;
  let position = 0;
  for (let edge = computed._deps; edge; edge = edge._nextDep)
    if (edge._gen === computed._depGen)
      position = Math.max(position, currentPosition(edge._dep, seen));
  return position;
}

function readContext(reader: Computed<any>, source: Computed<any>): void {
  if (evaluation !== reader) return;
  // Selecting an existing observation can move a running binding into its
  // output update. Retry in that exact update, so direct frame reads do not
  // mistake its proposals for a different update at the same depth.
  if (
    (reader as any)._type === EFFECT_RENDER &&
    reader._flags & REACTIVE_LAYER_EFFECT &&
    reader._config & CONFIG_HELD &&
    flushTransaction
  ) {
    const selected = txOf(reader);
    if (positionOf(selected) > positionOf(flushTransaction)) {
      holdQueuedProposals(resolveTx(flushTransaction));
      setCalculationUpdate(selected);
      retryEvaluation = true;
      throw RETRY;
    }
  }
  if (!tracking) evaluationPosition = Math.max(evaluationPosition, currentPosition(source));
  // A tracked proposal also selects the whole calculation before its next
  // ordinary read. Direct bindings retain their committed-frame read rule.
  else if ((reader as any)._type !== EFFECT_RENDER && source._config & CONFIG_HELD)
    evaluationPosition = Math.max(evaluationPosition, positionOf(txOf(source)));
  // A read in the update already being executed bypasses deferred joins.
  // An untracked boundary can still require leaving that update and retrying
  // the entire body. Publication preparation has explicitly selected the
  // incoming update instead: it consumes ready inputs beside published outputs.
  if (
    evaluationPosition &&
    evaluationPosition > positionOf(flushTransaction) &&
    flushTransaction &&
    resolveTx(flushTransaction) !== (releasingInput && resolveTx(releasingInput)) &&
    !unpublishedFrame(reader)
  ) {
    holdQueuedProposals(resolveTx(flushTransaction));
    const update = newTransaction(false);
    update._level = evaluationPosition;
    if (adoptOutput(reader, update)) {
      setCalculationUpdate(update);
      retryEvaluation = true;
      throw RETRY;
    }
  }
  if (!evaluationReads) return;
  const ownPosition = positionOf(flushTransaction);
  let depth: number | undefined;
  for (const holder of evaluationReads) {
    const parent = resolveTx(holder);
    if (flushTransaction && parent === resolveTx(flushTransaction)) continue;
    const heldPosition = positionOf(parent);
    if (ownPosition > 0 && heldPosition >= ownPosition) continue;
    if ((depth ??= Math.max(currentPosition(reader), evaluationPosition)) <= heldPosition) continue;
    staleReader(reader, parent);
    joinFuture(null);
    const update = resolveTx(flushTransaction!);
    update._level = Math.max(positionOf(update), depth);
    retryEvaluation = true;
    throw RETRY;
  }
}

function detachedOutput(node: Computed<any>): boolean {
  const layer = boundaries.get(node);
  return !!layer && !layer._inputStatus;
}

/** Initial observation is already an explicitly selected output, not a lower
 * proposal inherited from whichever computation happened to call it first. */
export function initialObservation<T>(layer: Layer<T>, value: T): T {
  const input = inputUpdate(layer);
  if (input) {
    layer._override = value;
    layer._position = 1 + Math.max(layerPosition(layer._input), positionOf(input));
  }
  return value;
}

/** Finish context discovery on success or error. Unchanged same-update reads
 * need none of this work; retries must finish before any peer joins occur. */
function acceptCalculation(
  node: Computed<any>,
  incoming: Transaction | null,
  outer: Computed<any> | null,
  outerReads: Set<Transaction> | null
): Set<Transaction> | null {
  const reads = evaluationReads as Set<Transaction> | null;
  if (reads) {
    const first = resolveTx(reads.values().next().value!);
    if (outer && creating === node && incoming === null) {
      const update = resolveTx(flushTransaction!);
      if (!positionOf(update)) update._level = positionOf(first);
      let peers = false;
      for (const holder of reads) if (resolveTx(holder) !== first) peers = true;
      // Adopting one existing hold cannot entangle peers. Multiple holds
      // wait until the owner accepts its context; a retry can dispose
      // this child before those irreversible joins take place.
      if (peers) (creationReads ??= []).push({ node, update, reads });
      else merge(update, first);
    } else if (outer && node._parent === outer) {
      for (const holder of reads) (outerReads ??= new Set()).add(holder);
    } else {
      // Accept the calculation before adopting its first consumed
      // context. During discovery a fresh frame must remain free to
      // retry above a deeper proposal encountered later in the body.
      if (incoming === null && flushTransaction && !positionOf(flushTransaction))
        flushTransaction._level = positionOf(first);
      for (const holder of reads) joinFuture(resolveTx(holder));
    }
  }
  if (!outer && creationReads) {
    for (const record of creationReads) {
      if (record.node._flags & REACTIVE_DISPOSED) {
        // This attempt read a provisional child which its retry discarded.
        // That child's empty update must not replay the accepted parent.
        // A merged record has already transferred and cleared _reruns;
        // do not remove obligations from its surviving, accepted update.
        record.update._reruns?.delete(node);
        continue;
      }
      for (const holder of record.reads) merge(resolveTx(holder), resolveTx(record.update));
    }
  }
  return outerReads;
}

function retryCalculation(
  node: Computed<any>,
  previous: any,
  result: any,
  previousPosition: number,
  normalize?: NormalizeCalculation
): any {
  for (;;) {
    if (result && typeof result.then === "function") Promise.resolve(result).catch(() => {});
    if (positionOf(flushTransaction) !== previousPosition) {
      previous = node._value;
      node._flags |= REACTIVE_PREVIOUS_COMMITTED;
    }
    if (node._x !== null) node._x._inFlight = null;
    releaseFlightTeardown(node);
    disposeChildren(node);
    node._depsTail = null;
    node._depGen++;
    evaluationReads = null;
    evaluationPosition = 0;
    retryEvaluation = false;
    result = undefined;
    if (__DEV__) clearThrownRead(node);
    try {
      const previousFlight = node._x?._inFlight;
      result = node._fn(previous);
      if (!retryEvaluation && normalize) result = normalize(node, result, previousFlight);
    } catch (error) {
      if (!retryEvaluation) throw error;
    }
    if (!retryEvaluation) return result;
  }
}

function computeLayer(node: Computed<any>, previous: any, normalize?: NormalizeCalculation): any {
  // A private frame has no displayed dependency set to preserve. Replace
  // its publication waits when it recalculates, including untracked reads.
  if (cleanupReruns && unpublishedFrame(node)) cleanupReruns(node);
  const incoming = flushTransaction;
  const previousPosition = positionOf(incoming);
  const inheritedReads = creatingReads;
  // Pulling an existing node does not make it a child of the calling pass.
  // Only synchronous creation carries the caller's tentative input context.
  if (creating !== node) creatingReads = null;
  const outer = evaluation,
    outerRetry = retryEvaluation,
    outerPosition = evaluationPosition;
  let outerReads = evaluationReads;
  if (!outer) creationReads = null;
  evaluation = node;
  evaluationReads = null;
  evaluationPosition = 0;
  retryEvaluation = false;
  try {
    let result: any;
    try {
      const previousFlight = node._x?._inFlight;
      result = node._fn(previous);
      if (!retryEvaluation && normalize) result = normalize(node, result, previousFlight);
    } catch (error) {
      if (!retryEvaluation) throw error;
    }
    return retryEvaluation
      ? retryCalculation(node, previous, result, previousPosition, normalize)
      : result;
  } finally {
    try {
      if (!retryEvaluation && (evaluationReads || (!outer && creationReads)))
        outerReads = acceptCalculation(node, incoming, outer, outerReads);
    } finally {
      evaluation = outer;
      creatingReads = inheritedReads;
      evaluationReads = outerReads;
      evaluationPosition = outerPosition;
      retryEvaluation = outerRetry;
      if (!outer) creationReads = null;
    }
  }
}

// Transactions, rather than ordinary node creation, activate coordination.
function holdsLifetime(node: Computed<any>, update: Transaction): boolean {
  // Judge the requests actually holding this node, not every dependency in
  // its body. A pending observation beside an ordinary pending read does not
  // turn that ordinary request into an optimistic consequence.
  const sources = node._x?._pendingSources;
  const position = positionOf(update);
  if (!sources) return sourceHoldsLifetime(node, position);
  for (const source of sources)
    if (sourceHoldsLifetime(source, position)) return true;
  return false;
}

function sourceHoldsLifetime(source: Computed<any>, position: number): boolean {
  if (source._config & CONFIG_HELD && positionOf(txOf(source)) > position) {
    // A ready upper publication can finish this flush before correction.
    // Waiting for its async work, however, cannot extend the lower lifetime.
    return !(source._statusFlags & STATUS_PENDING) && !blocked(txOf(source));
  }
  return !(
    unpublishedFrame(source) &&
    currentPosition(source) > position
  );
}

function canPublish(update: Transaction): boolean {
  // Reuse the pending-reader registry: ownership gates the private frame's
  // attachment, while the recorded higher read gates its publication. This
  // relation is one-way and deliberately absent from blocked()'s lifetime
  // judgment. A higher output may publish while the creating action is open.
  for (const higher of rerunHolders) {
    if (!liveTx(higher) || positionOf(higher) <= positionOf(update)) continue;
    for (const reader of higher._reruns ?? []) {
      if (reader._flags & REACTIVE_DISPOSED) continue;
      const frame = unpublishedFrame(reader);
      if (frame && resolveTx(frame) === update) return false;
    }
  }
  return true;
}

function orderUpdates(updates: Transaction[]): void {
  // Only a ready output with unpublished lower readers needs a landing order.
  // Independent ready updates and ordinary visible readers impose no order.
  if (!orderPublication) return;
  orderPublication = false;
  for (let i = 1; i < updates.length; i++) {
    if (positionOf(updates[i - 1]) <= positionOf(updates[i])) continue;
    updates.sort((a, b) => positionOf(a) - positionOf(b));
    return;
  }
}
setLayerTransactions(update => {
  // Keep parent and child transactions on the same object layout. The optional
  // coordinator initializes depth; ordinary-only applications erase this hook.
  update._level = 0;
  enableCoordination();
  wakeLayers();
}, orderUpdates);

/** Assign notified work to its output update, preserving the committed frame.
 * Active boundaries and unpublished lower owners remain propagation cuts. */
function adoptOutput(
  node: Computed<any>,
  update: Transaction,
  origin = false,
  unchanged = false
): boolean {
  const effect = node as Computed<any> & {
    _modified?: boolean;
    _boundRunEffect?: (type: number) => void;
    _type?: number;
  };
  if (effect._type) node._flags |= REACTIVE_LAYER_EFFECT;
  const own = node._config & CONFIG_HELD ? txOf(node) : null;
  // A lower notification cannot change an already selected upper context.
  // Its normal re-pass will read the lower update's committed value.
  if (!origin && own && positionOf(own) > positionOf(update)) return false;
  // A never-published binding may be holding its creator's staged control
  // even when that effect assigns its private value directly. Notifications
  // must not remove that mount obligation. A root's initial binding has no
  // such control and can still follow an optimistic first value normally.
  if (
    !origin &&
    own &&
    effect._type === EFFECT_RENDER &&
    node._statusFlags & STATUS_UNINITIALIZED &&
    positionOf(own) < positionOf(update)
  ) {
    for (let owner = node._parent; owner; owner = owner._parent) {
      const parent = owner as Computed<any>;
      if (!(parent._flags & REACTIVE_STAGED_READ)) continue;
      for (let edge = parent._deps; edge; edge = edge._nextDep)
        if (edge._dep._config & CONFIG_HELD && txOf(edge._dep) === own) {
          staleReader(node, update);
          return false;
        }
    }
  }
  const frame = unpublishedFrame(node);
  if (!origin && frame && positionOf(frame) < positionOf(update)) {
    staleReader(node, update);
    return false;
  }
  const boundary = node._config & CONFIG_REDERIVE ? boundaries.get(node) : undefined;
  if (!origin && boundary && boundary._override !== NOT_PENDING) return false;
  // A retained child still displays its owner's committed frame. Adoption by
  // an independent output update must bypass the ordinary removal deferral,
  // just as the legacy engine's independently published notifications do.
  // Remember the notification even if its owner parks it later this round.
  node._flags |= REACTIVE_LANE_DIRTY;
  // Another input can notify an already-adopted reader in this same pass.
  // With no new dependency links and no callback to transfer, its ownership
  // and publication lists are already complete. Preserve pending detection.
  if (
    own === update &&
    node._x!._transaction === update &&
    !effect._modified &&
    insertedDependencyCount === 0
  ) {
    if (node._statusFlags & STATUS_PENDING) update._mayPend = true;
    return true;
  }
  // An executing selector has not produced its replacement yet. Its normal
  // outcome notification must run before subscribers see that replacement.
  const transferredProposal =
    !(node._flags & REACTIVE_RECOMPUTING_DEPS) &&
    (node._pendingValue !== NOT_PENDING || node._statusFlags & (STATUS_PENDING | STATUS_ERROR)) &&
    own !== update;
  if (node._pendingValue !== NOT_PENDING && positionOf(own) !== positionOf(update))
    node._flags |= REACTIVE_PREVIOUS_COMMITTED;
  if (effect._modified && effect._boundRunEffect) {
    update._queues[effect._type! - 1].push(effect._boundRunEffect);
  }
  holdNode(node, update);
  // A previously computed proposal may compare equal on its next pass, and
  // repeated status propagation may short-circuit. Its consumers must still
  // follow that existing proposal/status into this update.
  if (transferredProposal && !unchanged) insertSubs(node);
  else if (transferredProposal) {
    // First selection can move an already calculated, identical proposal
    // into its output context. Preserve that work when every other read is
    // settled; a changed/held sibling input still requires a fresh pass.
    // Owned subtrees require their own frame transfer and are not reused here.
    for (let edge = node._subs; edge; edge = edge._nextSub) {
      const reader = edge._sub;
      let preserve =
        !reader._firstChild &&
        !(reader as any)._type &&
        !(reader._statusFlags & STATUS_ERROR) &&
        (!(reader._statusFlags & STATUS_PENDING) || !!reader._x?._inFlight);
      if (preserve) {
        for (let dependency = reader._deps; dependency; dependency = dependency._nextDep) {
          if (dependency._gen !== reader._depGen || dependency._dep === node) continue;
          const source = dependency._dep as Computed<any>;
          if (
            (source._pendingValue !== NOT_PENDING &&
              !Object.is(source._pendingValue, source._value)) ||
            source._statusFlags & STATUS_PENDING
          ) {
            preserve = false;
            break;
          }
        }
      }
      adoptOutput(reader, update, false, preserve);
      if (!preserve) enqueueSub(reader);
    }
  }
  return true;
}

/** Transfer context along value and status notifications. An unchanged
 * memo is a propagation stop for optimistic updates just as for ordinary ones. */
function notifyLayer(source: Signal<any>, reader: Computed<any>, value = false): boolean | void {
  if (!(source._config & CONFIG_HELD)) return;
  const update = txOf(source);
  if (!isChildUpdate(update)) return;
  if (!adoptOutput(reader, update)) return;
  if (value && reader._config & CONFIG_REDERIVE) return guesses?._notify?.(source, reader, update);
}

function setOutputDepth(layer: Layer<any>, update: Transaction) {
  resolveTx(update)._level = layer._position ?? 1 + layerPosition(layer._input);
}

export function stageLayer(layer: Layer<any>, proposal: unknown, position?: number): void {
  const inputHolder = inputUpdate(layer);
  const selecting = layer._override === NOT_PENDING;
  // Snapshot the context at the new proposal. A subsequently discovered input
  // dependency cannot promote this existing override or split its peer joins.
  layer._position = position ?? 1 + Math.max(layerPosition(layer._input), positionOf(inputHolder));
  layer._override = proposal;
  // Input revisions only classify attribution events now; selection and
  // lifetime coordination do not need to remember them in production.
  if (__OBSERVE__) layer._inputTime = inputTime(layer._input);
  enableReads();
  // Selecting an equal, settled scalar output has no downstream proposal.
  // In particular a newly allocated pending observation must not replay its
  // consumers just to install its initial false selector.
  if (
    inputHolder === null &&
    !(layer._output._config & CONFIG_HELD) &&
    layer._output._pendingValue === NOT_PENDING &&
    proposal !== NOT_PENDING &&
    layer._output._equals &&
    layer._output._equals(layer._output._value, proposal)
  ) {
    enqueueSub(layer._output);
    return;
  }
  // Publication and transaction merging already maintain the output's stamp.
  // No separate layer transaction or finished-layer cleanup is needed.
  const previous = layer._output._config & CONFIG_HELD ? txOf(layer._output) : null;
  // A correction may have merged the old output back into its input. A new
  // guess needs a new cut, rather than reusing that now-lower update.
  const update =
    previous &&
    previous !== inputHolder &&
    isChildUpdate(previous) &&
    positionOf(previous) === layer._position
      ? previous
      : newTransaction(false);
  setOutputDepth(layer, update);
  const output = layer._output;
  const unchanged =
    selecting &&
    Object.is(
      output._pendingValue !== NOT_PENDING ? output._pendingValue : output._value,
      proposal
    );
  adoptOutput(output, update, true, unchanged);
  if (!guesses?._write?.(layer, update, proposal)) enqueueSub(output);
}

function settleLayers(): void {
  if (!transactions.length) setLayerCompute();
  // Value guesses must propagate before observations sample their resulting
  // work. A lifecycle which stages them defers the later phases one round.
  if (guesses?._settle()) return;
  observations?._settle();
  stopIfIdle();
}

/** Read the override while retaining the input subscription, without
 * consuming the input proposal. Feature selectors choose when to use it. */
export function readOverride<T>(layer: Layer<T>): T {
  // Choosing an override subscribes to the input's changes, but does not
  // consume its proposal. No other read in the graph has this exemption.
  // The subscription keeps input work current without making readers of the
  // override hold the update producing that input. Correction rejoins normally.
  link(layer._input, layer._output);
  return layer._override as T;
}

/** Internal construction shared by guesses and observations. */
export function createLayerBoundary<T>(
  producer: Computed<any>,
  select: (layer: Layer<T>) => T,
  ownInput = true,
  lazy = false,
  options?: NodeOptions<T>
) {
  if (ownInput) producer._config &= ~CONFIG_AUTO_DISPOSE;
  const layer = {
    _input: producer,
    _override: NOT_PENDING,
    _scope: null
  } as Layer<T>;
  if (__OBSERVE__) layer._inputTime = inputTime(producer);
  // Choose the feature selector once at allocation. Its calls into common
  // selection/publication are direct; no per-evaluation lifecycle dispatch.
  const output = computed<T>(select.bind(null, layer), {
    name: options?.name,
    equals: options?.equals,
    unobserved: options?.unobserved,
    lazy,
    sync: true,
    _extraConfig: CONFIG_REDERIVE
  });
  if (!lazy) output._config &= ~CONFIG_AUTO_DISPOSE;
  layer._output = output;
  boundaries.set(output, layer);
  return layer;
}
