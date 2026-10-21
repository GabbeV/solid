# General local isSame properties and closed executions of actual callers.
import Base
import ../runtime/core.bend as C
import ../runtime/api.bend as A
import ../runtime/equality.bend as EQ
import ../runtime/status.bend as Status
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K
import ../runtime/construct-state.bend as N
import ../representation/base.bend as B
import ../representation/records.bend as R

# Proof-only loaded form of isSame, checked against the actual function below.
# This merely names its already-looked-up callback, not another comparator engine.
def selected(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +a: R.Value, +b: R.Value, +callback: Nat) -> C.Machine:
  B.choose(~C.Machine, Nat.is_eq(callback, 0n),
    _ => C.Machine{w, rest, R.Boolean{EQ.isSame(w, id, a, b)} <> stack},
    _ => C.Machine{w, C.Evaluate{R.CallWith{callback, R.Literal{a}, R.Literal{b}}, R.Undefined{}} <> C.EqualityCatch{id, stack} <> rest, stack})

def selectedEq(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +a: R.Value, +b: R.Value, callback: Nat, known: {EQ.custom(w, id) == callback : Nat}) ->
  {C.isSame(w, rest, stack, id, a, b) == selected(w, rest, stack, id, a, b, callback) : C.Machine}:
  Equal.cong(Nat, C.Machine, c => selected(w, rest, stack, id, a, b, c), EQ.custom(w, id), callback, known)

def default_fast(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +a: R.Value, +b: R.Value, known: {EQ.custom(w, id) == 0n : Nat}) ->
  {C.isSame(w, rest, stack, id, a, b) == C.Machine{w, rest, R.Boolean{EQ.isSame(w, id, a, b)} <> stack} : C.Machine}:
  selectedEq(w, rest, stack, id, a, b, 0n, known)

def custom_call(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +a: R.Value, +b: R.Value, +callback: Nat, known: {EQ.custom(w, id) == 1n+callback : Nat}) ->
  {C.isSame(w, rest, stack, id, a, b) == C.Machine{w, C.Evaluate{R.CallWith{1n+callback, R.Literal{a}, R.Literal{b}}, R.Undefined{}} <> C.EqualityCatch{id, stack} <> rest, stack} : C.Machine}:
  selectedEq(w, rest, stack, id, a, b, 1n+callback, known)

def not_ready(+w: R.World, rest: List<&2, C.Task>, saved: List<&2, R.Value>, id: Nat, identity: Nat, source: Nat) ->
  {C.equalityCatch(w, rest, saved, id, R.CallbackThrown{R.NotReadyFailure{identity, source}})
    == C.Machine{R.World.with_fault(w, R.Healthy{}), rest, R.Undefined{} <> saved} : C.Machine}:
  {==}

# Another proof-only loaded form: the predicate is the source instanceof check.
def classified(+w: R.World, +rest: List<&2, C.Task>, +saved: List<&2, R.Value>, id: Nat, error: R.Value, notReady: Bool) -> C.Machine:
  +w = R.World.with_fault(w, R.Healthy{})
  B.choose(~C.Machine, notReady,
    _ => C.Machine{w, rest, R.Undefined{} <> saved},
    _ => C.Machine{Status.notifyStatusWith(w, id, K.STATUS_ERROR(), error, False{}), rest, R.Boolean{True{}} <> saved})

def ordinary_error(+w: R.World, +rest: List<&2, C.Task>, +saved: List<&2, R.Value>, +id: Nat, +error: R.Value, known: {P.isNotReady(error) == False{} : Bool}) ->
  {C.equalityCatch(w, rest, saved, id, R.CallbackThrown{error})
    == C.Machine{Status.notifyStatusWith(R.World.with_fault(w, R.Healthy{}), id, K.STATUS_ERROR(), error, False{}), rest, R.Boolean{True{}} <> saved} : C.Machine}:
  Equal.cong(Bool, C.Machine, pending => classified(w, rest, saved, id, error, pending), P.isNotReady(error), False{}, known)

# Registry metadata must not manufacture a source _x allocation or mutate any
# graph/queue/ambient state. Restoring only the registry gives the exact World.
def registry_preserves_world(+w: R.World, id: Nat, callback: Nat) ->
  {R.World.with_comparators(EQ.register(w, id, callback), R.World.comparators(w)) == w : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits}:
      match callback:
        case 0n:
          {==}
        case 1n+p:
          {==}

type View is Data:
  View{returned: R.Value, value: R.Value, pending: R.Slot, status: U32, error: R.Value,
    bindings: Nat, context: Nat, tracking: Bool, halted: Bool, fault: R.Fault}

def view(+m: C.Machine, +id: Nat) -> View:
  +w = C.world(m)
  +done = A.flush(1024n, w)
  View{A.resultValue(m), R.Node.value(B.node(done, id)), R.Node.pending(B.node(done, id)), R.Node.status(B.node(done, id)), R.NodeExtension.error(B.extension(done, id)),
    B.length(R.ComparatorBinding, R.World.comparators(done)), R.World.context(done), R.World.tracking(done), R.World.halted(done), R.World.fault(done)}

def verdict(equal: Bool) -> View:
  w = A.registerProgram(A.createWorld(), A.programReturn(R.Literal{R.Boolean{equal}}, A.emptyProgram()))
  w = A.createSignalWithOptions(w, R.Number{0n}, A.nodeComparator(N.defaults(), 1n))
  view(A.setValue(512n, w, 2n, R.Number{1n}), 2n)

def expectedVerdict(value: Nat) -> View:
  View{R.Number{1n}, R.Number{value}, R.Empty{}, 0, R.Undefined{}, 1n, 0n, False{}, False{}, R.Healthy{}}

def caught_error() -> View:
  w = A.registerProgram(A.createWorld(), A.programThrow(R.Number{8n}, A.emptyProgram()))
  w = A.createSignalWithOptions(w, R.Number{0n}, A.nodeComparator(N.defaults(), 1n))
  view(A.setValue(512n, w, 2n, R.Number{1n}), 2n)

def expectedError() -> View:
  View{R.Number{1n}, R.Number{0n}, R.Empty{}, 2, R.StatusFailure{1n, 2n, R.Number{8n}, "8"}, 1n, 0n, False{}, False{}, R.Healthy{}}

def pending_read() -> View:
  w = A.createThenable(A.createWorld(), True{})
  w = A.createMemo(512n, w, R.Literal{R.AsyncValue{1n}}, True{}, False{}, 1n)
  w = A.flush(512n, w)
  w = A.registerProgram(w, A.programReturn(R.Read{2n}, A.emptyProgram()))
  w = A.createSignalWithOptions(w, R.Number{0n}, A.nodeComparator(N.defaults(), 1n))
  view(A.setValue(1024n, w, 3n, R.Number{1n}), 3n)

law equal_case:
  {verdict(True{}) == expectedVerdict(0n) : View}

def equal_case():
  {==}

law changed_case:
  {verdict(False{}) == expectedVerdict(1n) : View}

def changed_case():
  {==}

law error_case:
  {caught_error() == expectedError() : View}

def error_case():
  {==}

law pending_case:
  {pending_read() == expectedVerdict(1n) : View}

def pending_case():
  {==}
