# Source Promise/iterator closure frame: arbitrary pending/observer lists,
# arbitrary Worlds. These helpers cannot change the reactive graph or ambient
# state; Promise objects, host jobs and closure plans are the explicit mask.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/promise-input.bend as P
import ../runtime/from-wrap.bend as W

def erase(w: R.World) -> R.World:
  R.World.with_streamPlans(R.World.with_asyncObjects(R.World.with_hostJobs(w, []), []), [])

def erase_jobs(+w: R.World, value: List<&2, R.HostJob>) ->
  {erase(R.World.with_hostJobs(w, value)) == erase(w) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      {==}

def erase_objects(+w: R.World, value: List<&2, R.AsyncObject>) ->
  {erase(R.World.with_asyncObjects(w, value)) == erase(w) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      {==}

def erase_plans(+w: R.World, value: List<&2, R.StreamPlan>) ->
  {erase(R.World.with_streamPlans(w, value)) == erase(w) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      {==}

def storeObject(+w: R.World, id: Nat, object: R.AsyncObject) ->
  {erase(B.store_asyncObject(w, id, object)) == erase(w) : R.World}:
  erase_objects(w, List.set(&2, R.AsyncObject, R.World.asyncObjects(w), id, object))

def storePlan(+w: R.World, +plan: Nat, state: R.FromWrapped) ->
  {erase(W.store(w, plan, state)) == erase(w) : R.World}:
  erase_plans(w, List.set(&2, R.StreamPlan, R.World.streamPlans(w), plan, R.StreamPlan.with_fromState(B.streamPlan(w, plan), R.FromWrappedState{state})))

def deliveries(observers: List<&2, Nat>, +w: R.World, +rejected: Bool, +value: R.Value) ->
  {erase(P.deliveries(observers, w, rejected, value)) == erase(w) : R.World}:
  match observers:
    case Nil{}: {==}
    case +head <> +tail:
      +next = R.World.with_hostJobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.DeliveryJob{head, rejected, value}]))
      Equal.trans(R.World, erase(P.deliveries(tail, next, rejected, value)), erase(next), erase(w), deliveries(tail, next, rejected, value), erase_jobs(w, B.append(R.HostJob, R.World.hostJobs(w), [R.DeliveryJob{head, rejected, value}])))

def settlement(+w: R.World, +id: Nat, +rejected: Bool, +value: R.Value, +object: R.AsyncObject, state: R.AsyncSettlement) ->
  {erase(P.settleState(w, id, rejected, value, object, state)) == erase(w) : R.World}:
  match state:
    case R.Unresolved{}:
      +updated = R.AsyncObject.with_state(object, B.choose(~R.AsyncSettlement, rejected, _ => R.Rejected{value}, _ => R.Fulfilled{value}))
      +next = B.store_asyncObject(w, id, updated)
      Equal.trans(R.World, erase(P.deliveries(R.AsyncObject.observers(object), next, rejected, value)), erase(next), erase(w), deliveries(R.AsyncObject.observers(object), next, rejected, value), storeObject(w, id, updated))
    case R.Fulfilled{prior}: {==}
    case R.Rejected{prior}: {==}

def settle(+w: R.World, +id: Nat, +rejected: Bool, +value: R.Value) ->
  {erase(P.settle(w, id, rejected, value)) == erase(w) : R.World}:
  settlement(w, id, rejected, value, B.asyncObject(w, id), R.AsyncObject.state(B.asyncObject(w, id)))

def pending(items: List<&2, Nat>, +w: R.World) ->
  {erase(W.resolvePending(items, w)) == erase(w) : R.World}:
  match items:
    case Nil{}: {==}
    case +head <> tail:
      +next = P.settle(w, head, False{}, R.StepResult{True{}, R.Undefined{}})
      Equal.trans(R.World, erase(W.resolvePending(tail, next)), erase(next), erase(w), pending(tail, next), settle(w, head, False{}, R.StepResult{True{}, R.Undefined{}}))

def finish(+w: R.World, +plan: Nat) ->
  {erase(W.finish(w, plan)) == erase(w) : R.World}:
  +s = W.get(w, plan)
  +initial = W.store(w, plan, R.FromWrapped.with_closed(s, True{}))
  +resolved = W.resolvePending(R.FromWrapped.pending(s), initial)
  +final = W.store(resolved, plan, R.FromWrapped.with_pending(W.get(resolved, plan), []))
  Equal.trans(R.World, erase(final), erase(resolved), erase(w), storePlan(resolved, plan, R.FromWrapped.with_pending(W.get(resolved, plan), [])),
    Equal.trans(R.World, erase(resolved), erase(initial), erase(w), pending(R.FromWrapped.pending(s), initial), storePlan(w, plan, R.FromWrapped.with_closed(s, True{}))))

def deliverChoice(+w: R.World, +plan: Nat, +output: Nat, +rejected: Bool, +value: R.Value, present: Bool) -> R.World:
  +s = W.get(w, plan)
  B.choose(~R.World, present,
    _ => P.settle(W.store(w, plan, R.FromWrapped.with_pending(s, W.remove(R.FromWrapped.pending(s), output))), output, rejected, value), _ => w)

def deliverSelected(+w: R.World, +plan: Nat, +output: Nat, +rejected: Bool, +value: R.Value, present: Bool) ->
  {erase(deliverChoice(w, plan, output, rejected, value, present)) == erase(w) : R.World}:
  match present:
    case False{}: {==}
    case True{}:
      +s = W.get(w, plan)
      +next = W.store(w, plan, R.FromWrapped.with_pending(s, W.remove(R.FromWrapped.pending(s), output)))
      Equal.trans(R.World, erase(P.settle(next, output, rejected, value)), erase(next), erase(w), settle(next, output, rejected, value), storePlan(w, plan, R.FromWrapped.with_pending(s, W.remove(R.FromWrapped.pending(s), output))))

def deliver(+w: R.World, +plan: Nat, +output: Nat, +rejected: Bool, +value: R.Value) ->
  {erase(W.deliver(w, plan, output, rejected, value)) == erase(w) : R.World}:
  deliverSelected(w, plan, output, rejected, value, W.has(R.FromWrapped.pending(W.get(w, plan)), output))
