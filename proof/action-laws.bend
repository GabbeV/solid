# Quantified laws of the actual action/depth/callback helpers. These do not
# assert arbitrary-generator termination or TypeScript equivalence.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/action-state.bend as Action
import ../representation/records.bend as R
import ../representation/base.bend as B

def subZero(n: Nat) -> {Nat.sub(n, 0n) == n : Nat}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      {==}

def balanced(+w: R.World) -> {Action.exit(Action.enter(w)) == w : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState}:
      Equal.cong(Nat, R.World, d => R.World.with_actionDepth(w, d), Nat.sub(R.World.actionDepth(w), 0n), R.World.actionDepth(w), subZero(R.World.actionDepth(w)))

def guarded_callback(+w: R.World, +depth: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +body: R.Expr, +previous: R.Value) ->
  {C.flushEntry(R.World.with_actionDepth(w, 1n+depth), rest, stack, body, previous)
    == C.Machine{R.World.with_actionDepth(w, 1n+depth), C.Evaluate{body, previous} <> rest, stack} : C.Machine}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState}:
      {==}

def guarded_flush(+fuel: Nat, +w: R.World, +depth: Nat) ->
  {A.flush(fuel, R.World.with_actionDepth(w, 1n+depth)) == R.World.with_actionDepth(w, 1n+depth) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState}:
      {==}

def duplicate_yield(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, observer: Nat, action: Nat, rejected: Bool, value: R.Value) ->
  {C.actionDelivery(w, rest, stack, R.ActionWait{observer, action, 0, True{}}, rejected, value) == C.Machine{w, rest, stack} : C.Machine}:
  {==}

def throw_after_settlement(+w: R.World, +rest: List<&2, C.Task>, +saved: List<&2, R.Value>, error: R.Value, observer: Nat, action: Nat) ->
  {C.actionYieldCaught(w, rest, saved, error, Some{R.ActionWait{observer, action, 0, True{}}})
    == C.Machine{R.World.with_fault(w, R.Healthy{}), rest, saved} : C.Machine}:
  {==}

# Concrete execution: a public action parks its first write and releases the
# reconciled value on an immediate external thenable's callback. The callback
# uses the actual action seam and scheduler, not a synthetic open-count change.
def base() -> R.World:
  A.createThenable(A.createSignal(A.createWorld(), R.Number{0n}, True{}), True{})

def program() -> R.Expr:
  R.ActionInvoke{R.Literal{R.Undefined{}},
    R.ActionMethods{R.Then{R.WriteExpr{2n, R.Literal{R.Number{1n}}, False{}}, R.IteratorResult{False{}, R.Literal{R.AsyncValue{1n}}}}, False{}, R.Literal{R.Undefined{}},
    R.ActionMethods{R.Then{R.WriteExpr{2n, R.Argument{0n}, False{}}, R.IteratorResult{True{}, R.Literal{R.Number{7n}}}}, False{}, R.Literal{R.Undefined{}}, R.ActionEnd{}}}}

def parked() -> R.World:
  A.flush(1024n, A.resultWorld(A.evaluateExpression(1024n, base(), program(), R.Undefined{})))

def landed() -> R.World:
  A.resolveThenable(2048n, parked(), 1n, False{}, R.Number{3n})

type View is Data:
  View{value: R.Value, pending: Bool, open: Nat, depth: Nat, healthy: Bool}

def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 2n)), B.present(R.Node.pending(B.node(w, 2n))), R.Transaction.open(B.transaction(w, 1n)), R.World.actionDepth(w), B.ok(w)}

def holds() -> {view(parked()) == View{R.Number{0n}, True{}, 1n, 0n, True{}} : View}:
  {==}

def lands() -> {view(landed()) == View{R.Number{3n}, False{}, 0n, 0n, True{}} : View}:
  {==}
