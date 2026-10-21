# scheduler.ts:flush(fn), through the same public/core machine as execution.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/construct-state.bend as N
import ../representation/base.bend as B
import ../representation/records.bend as R

# Arbitrary callback expression, caller continuation/operands and full world:
# entry changes only depth and installs the callback's finally continuation.
def entry(+w: R.World, +rest: List<&2, C.Task>, +saved: List<&2, R.Value>, body: R.Expr, prev: R.Value, outside: {Nat.is_ne(R.World.actionDepth(w), 0n) == False{} : Bool}) ->
  {C.evaluate(w, rest, saved, R.FlushCallback{body}, prev)
    == C.Machine{R.World.with_syncDepth(w, 1n+R.World.syncDepth(w)), C.Evaluate{body, prev} <> C.FlushCallbackFinally{saved} <> rest, saved} : C.Machine}:
  %Equal.sym(Bool, Nat.is_ne(R.World.actionDepth(w), 0n), False{}, outside) : {B.choose(~C.Machine, _, _ => C.Machine{w, C.Evaluate{body, prev} <> rest, saved}, _ => C.Machine{R.World.with_syncDepth(w, 1n+R.World.syncDepth(w)), C.Evaluate{body, prev} <> C.FlushCallbackFinally{saved} <> rest, saved}) == C.Machine{R.World.with_syncDepth(w, 1n+R.World.syncDepth(w)), C.Evaluate{body, prev} <> C.FlushCallbackFinally{saved} <> rest, saved} : C.Machine}
  {==}

def subZero(n: Nat) -> {Nat.sub(n, 0n) == n : Nat}:
  match n:
    case 0n:
      {==}
    case 1n+p:
      {==}

# After any drain-world changes, restore the immediately enclosing depth and
# exact saved operands. Every other world field survives, except the selected
# propagated fault (the drain's error on failure; the callback's on success).
def restores(+w: R.World, depth: Nat, rest: List<&2, C.Task>, saved: List<&2, R.Value>, fault: R.Fault) ->
  {C.flushCallbackRestore(R.World.with_syncDepth(w, 1n+depth), rest, saved, fault)
    == C.Machine{R.World.with_fault(R.World.with_syncDepth(w, depth), fault), rest, saved} : C.Machine}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats}:
      +world = {R.World{w_nodes, w_links, w_buckets, w_minimum, w_maximum, w_marked, w_pendingNodes, w_trims, w_renderQueue, w_userQueue, w_context, w_tracking, w_running, w_scheduled, w_clock, w_epoch, w_tree, w_events, w_fault, w_unflushedStaged, w_promotedWrites, w_extensions, w_cleanupPrograms, w_dormantNodes, w_errorSerial, w_halted, w_haltNotified, w_reports, w_callbackEffect, w_txArena, w_transactions, w_flushTransaction, w_passTx, w_passLane, w_judge, w_deferredZombies, w_question, w_pendingSets, w_asyncObjects, w_asyncObservers, w_hostJobs, w_syncDepth, w_streamPlans, w_iterators, w_streams, w_iteratorEvents, w_awaiters, w_truthReadHook, w_truthConfirmedHook, w_questions, w_abortInputs, w_contextKeys, w_contextRecords, w_deferredReleases, w_releaseLists, w_stale, w_settledCallbacks, w_reactions, w_comparators, w_actionDepth, w_actions, w_actionWaits, w_arrays, w_repeats} : R.World}
      Equal.cong(Nat, C.Machine, d => C.Machine{R.World.with_fault(R.World.with_syncDepth(world, d), fault), rest, saved}, Nat.sub(depth, 0n), depth, subZero(depth))

# A callback error enters the very same public drain with a healthy control
# state; the error is held in the finally task, not discarded or reclassified.
def thrown_drains(+w: R.World, +rest: List<&2, C.Task>, partial: List<&2, R.Value>, +saved: List<&2, R.Value>, +error: R.Value) ->
  {C.flushCallbackFinally(R.World.with_fault(w, R.CallbackThrown{error}), rest, partial, saved)
    == C.publicFlush(R.World.with_fault(w, R.Healthy{}), C.FlushCallbackRestore{R.CallbackThrown{error}, saved} <> rest, saved) : C.Machine}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats}:
      {==}

type View is Data:
  View{returned: R.Value, value: R.Value, depth: Nat, jobs: List<&2, R.HostJob>, scheduled: Bool, running: Bool, halted: Bool, fault: R.Fault}

def view(+m: C.Machine) -> View:
  +w = C.world(m)
  View{A.resultValue(m), R.Node.value(B.node(w, 2n)), R.World.syncDepth(w), R.World.hostJobs(w), R.World.scheduled(w), R.World.running(w), R.World.halted(w), R.World.fault(w)}

def nested() -> View:
  w = A.createSignal(A.createWorld(), R.Number{0n}, True{})
  body = {R.Then{R.WriteExpr{2n, R.Literal{R.Number{1n}}, False{}},
    R.Then{R.FlushCallback{R.WriteExpr{2n, R.Literal{R.Number{2n}}, False{}}},
      R.Then{R.WriteExpr{2n, R.Literal{R.Number{3n}}, False{}}, R.Read{2n}}}} : R.Expr}
  view(A.evaluateExpression(512n, w, R.FlushCallback{body}, R.Undefined{}))

def expectedNested() -> View:
  View{R.Number{2n}, R.Number{3n}, 0n, [], False{}, False{}, False{}, R.Healthy{}}

def override() -> View:
  w = A.createSignal(A.createWorld(), R.Number{0n}, True{})
  w = A.registerProgram(w, A.programThrow(R.Number{9n}, A.emptyProgram()))
  w = A.createEffectWithHandlers(512n, w, R.Read{2n}, True{}, 0n, False{}, True{}, N.defaults(), 1n, 1n, 0n, 0n)
  body = {R.Then{R.WriteExpr{2n, R.Literal{R.Number{1n}}, False{}}, R.Raise{R.Number{8n}}} : R.Expr}
  view(A.evaluateExpression(1024n, w, R.FlushCallback{body}, R.Undefined{}))

def expectedOverride() -> View:
  View{R.Undefined{}, R.Number{1n}, 0n, [], False{}, False{}, True{}, R.CallbackThrown{R.Number{9n}}}

law nested_case:
  {nested() == expectedNested() : View}

def nested_case():
  {==}

law override_case:
  {override() == expectedOverride() : View}

def override_case():
  {==}
