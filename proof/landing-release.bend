# The queued source release callback executes the real releaseQueues operation,
# preserving the caller's remaining tasks and value stack. No queue fixture or
# alternate callback implementation is assumed; arbitrary healthy Worlds pass.
import Base
import ../runtime/core.bend as C
import ../runtime/scheduler.bend as S
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./memo-setter-cuts.bend as Step

def callback(+w: R.World, +transaction: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, ready: {B.ok(w) == True{} : Bool}) ->
  {C.step(C.Machine{w, C.ReleaseTransactionQueues{transaction} <> rest, stack}) == C.Machine{S.releaseQueues(w, transaction), rest, stack} : C.Machine}:
  Equal.trans(C.Machine, C.step(C.Machine{w, C.ReleaseTransactionQueues{transaction} <> rest, stack}), C.dispatch(w, C.ReleaseTransactionQueues{transaction} <> rest, stack), C.Machine{S.releaseQueues(w, transaction), rest, stack},
    Step.step_head(w, C.ReleaseTransactionQueues{transaction}, rest, stack, ready), {==})

# Only renderQueue, userQueue and txArena may change, for every World.
def eraseQueueState(w: R.World) -> R.World:
  R.World.with_txArena(R.World.with_userQueue(R.World.with_renderQueue(w, []), []), [])

def frame(+w: R.World, transaction: Nat) -> {eraseQueueState(S.releaseQueues(w, transaction)) == eraseQueueState(w) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      {==}
