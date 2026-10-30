# Closed regressions for the reviewed d2ad8b28 -> 71153bf0 source update.
# Historical negative laws remain at baseline/solid-d2ad8b28, commit 76361a4.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/ambient.bend as L
import ../runtime/constants.bend as K

def invocation(event: R.TraceEvent, node: Nat) -> Nat:
  match event:
    case R.Invoked{id}:
      B.choose(~Nat, Nat.is_eq(id, node), _ => 1n, _ => 0n)
    case _:
      0n

def invocations(events: List<&2, R.TraceEvent>, +node: Nat) -> Nat:
  match events:
    case Nil{}:
      0n
    case event <> rest:
      Nat.add(invocation(event, node), invocations(rest, node))

type LazyView is Data:
  LazyView{runs: Nat, value: R.Value, subscribed: Bool, dead: Bool, screen: R.Value,
    activeReleases: Nat, context: Nat, tracking: Bool, running: Bool, fault: R.Fault}

def lazyReader() -> LazyView:
  w = A.createThenable(A.createWorld(), True{})
  w = A.createMemoWithOptions(4096n, w, R.Literal{R.AsyncValue{1n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)
  w = A.attach(w, 1n, 2n)
  w = A.flush(4096n, A.createEffect(4096n, w, R.MemoRead{R.Read{2n}, N.defaults()}, False{}, 2n, False{}, False{}, 1n))
  +w = A.resolveThenable(4096n, w, 1n, False{}, R.Number{7n})
  LazyView{invocations(R.World.events(w), 2n), R.Node.value(B.node(w, 2n)), Nat.is_ne(R.Node.subs(B.node(w, 2n)), 0n), L.isDisposed(w, 2n),
    A.displayed(w, 2n), R.World.deferredReleases(w), R.World.context(w), R.World.tracking(w), R.World.running(w), R.World.fault(w)}

def expectedLazy() -> LazyView:
  LazyView{1n, R.Number{7n}, True{}, False{}, R.Number{7n}, 0n, 0n, False{}, False{}, R.Healthy{}}

def cause(value: R.Value) -> R.Value:
  match value:
    case R.StatusFailure{identity, source, original, message}:
      original
    case other:
      other

def thrown(fault: R.Fault) -> R.Value:
  match fault:
    case R.CallbackThrown{value}:
      cause(value)
    case _:
      R.Undefined{}

type WritableView is Data:
  WritableView{before: R.Value, between: R.Value, after: R.Value, status: U32,
    stagedError: Bool, shown: R.Value, context: Nat, tracking: Bool, fault: R.Fault}

def writableRecovery() -> WritableView:
  w = A.createSignal(A.createWorld(), R.Boolean{False{}}, True{})
  expr = {R.Select{R.Read{2n}, R.Raise{R.Number{99n}}, R.Literal{R.Number{1n}}} : R.Expr}
  w = A.resultWorld(A.evaluateExpression(4096n, w, R.SignalComputeScope{expr, N.defaults(), R.Literal{R.Undefined{}}}, R.Undefined{}))
  w = A.flush(4096n, A.setSignal(w, 2n, R.Boolean{True{}}))
  +before = A.evaluateExpression(4096n, w, R.Read{3n}, R.Undefined{})
  w = A.clearException(A.resultWorld(before))
  w = A.resultWorld(A.setValue(4096n, w, 3n, R.Number{7n}))
  +between = A.evaluateExpression(4096n, w, R.Read{3n}, R.Undefined{})
  w = A.flush(4096n, A.clearException(A.resultWorld(between)))
  +after = A.evaluateExpression(4096n, w, R.Read{3n}, R.Undefined{})
  +done = A.resultWorld(after)
  WritableView{thrown(R.World.fault(A.resultWorld(before))), thrown(R.World.fault(A.resultWorld(between))), A.resultValue(after),
    R.Node.status(B.node(done, 3n)), B.has(R.Node.config(B.node(done, 3n)), K.CONFIG_STAGED_ERROR()), R.NodeExtension.shownError(B.extension(done, 3n)),
    R.World.context(done), R.World.tracking(done), R.World.fault(done)}

def expectedWritable() -> WritableView:
  WritableView{R.Number{99n}, R.Number{99n}, R.Number{7n}, 0, False{}, R.Null{}, 0n, False{}, R.Healthy{}}

type ProtocolView is Data:
  ProtocolView{last: R.Value, status: U32, error: R.Value, handlerCalls: Nat,
    context: Nat, tracking: Bool, running: Bool, fault: R.Fault}

def cleanupCall(event: R.TraceEvent) -> Nat:
  match event:
    case R.CleanupObserved{callback, code}:
      B.choose(~Nat, Nat.is_eq(code, 42n), _ => 1n, _ => 0n)
    case _:
      0n

def cleanupCalls(events: List<&2, R.TraceEvent>) -> Nat:
  match events:
    case Nil{}:
      0n
    case event <> rest:
      Nat.add(cleanupCall(event), cleanupCalls(rest))

def protocolThrow() -> ProtocolView:
  w = A.createThenable(A.createWorld(), True{})
  w = A.createStream(w, [R.PromiseNext{1n}, R.ThrowNext{R.Number{99n}}], True{}, False{}, R.Undefined{}, 0n)
  w = A.createMemoWithOptions(4096n, w, R.Literal{R.AsyncValue{2n}}, N.defaults(), 1n)
  w = A.registerProgram(w, A.programEmit(42n, A.emptyProgram()))
  w = A.flush(4096n, A.createEffectWithHandlers(4096n, w, R.Read{2n}, True{}, 2n, False{}, False{}, N.defaults(), 1n, 0n, 0n, 2n))
  +w = A.flush(4096n, A.resolveThenable(4096n, w, 1n, False{}, R.StepResult{False{}, R.Number{7n}}))
  ProtocolView{R.Node.value(B.node(w, 2n)), R.Node.status(B.node(w, 2n)), cause(R.NodeExtension.error(B.extension(w, 2n))),
    cleanupCalls(R.World.events(w)), R.World.context(w), R.World.tracking(w), R.World.running(w), R.World.fault(w)}

def expectedProtocol() -> ProtocolView:
  ProtocolView{R.Number{7n}, K.STATUS_ERROR(), R.Number{99n}, 1n, 0n, False{}, False{}, R.Healthy{}}

type EmptyView is Data:
  EmptyView{value: R.Value, status: U32, loading: Bool, completed: Bool, fault: R.Fault}

def emptyFlatten() -> EmptyView:
  w = A.createThenable(A.createWorld(), True{})
  w = A.createStream(w, [], True{}, False{}, R.Undefined{}, 0n)
  w = A.resolveThenable(4096n, w, 1n, False{}, R.AsyncValue{2n})
  +w = A.createMemoWithOptions(4096n, w, R.Literal{R.AsyncValue{1n}}, N.defaults(), 1n)
  EmptyView{R.Node.value(B.node(w, 2n)), R.Node.status(B.node(w, 2n)), R.Node.loading(B.node(w, 2n)), R.StreamState.completed(B.stream(w, 1n)), R.World.fault(w)}

def expectedEmpty() -> EmptyView:
  EmptyView{R.Undefined{}, 0, False{}, True{}, R.Healthy{}}

# Original #4176 regression stays positive at rc.17: cleanup is collected,
# collector restoration/drain finishes, and a later unrelated lazy release works.
type LeakView is Data:
  LeakView{escaped: R.Value, lazyDead: Bool, cleanups: Nat, collectorActive: Bool,
    queued: List<&2, Nat>, context: Nat, tracking: Bool, running: Bool, fault: R.Fault}

def releasedCall(event: R.TraceEvent) -> Nat:
  match event:
    case R.CleanupObserved{callback, code}:
      B.choose(~Nat, Nat.is_eq(code, 55n), _ => 1n, _ => 0n)
    case _:
      0n

def releasedCalls(events: List<&2, R.TraceEvent>) -> Nat:
  match events:
    case Nil{}:
      0n
    case event <> rest:
      Nat.add(releasedCall(event), releasedCalls(rest))

def collectorLeak() -> LeakView:
  w = A.createSignal(A.createWorld(), R.Number{0n}, True{})
  w = A.createThenable(w, True{})
  w = A.registerProgram(w, A.programThrow(R.Number{99n}, A.emptyProgram()))
  expr = {R.Then{R.Read{2n}, R.Then{R.OnCleanup{R.Literal{R.ProgramReference{1n}}}, R.Literal{R.AsyncValue{1n}}}} : R.Expr}
  w = A.flush(4096n, A.createMemoWithOptions(4096n, w, expr, N.defaults(), 1n))
  +broken = A.flush(4096n, A.setSignal(w, 2n, R.Number{1n}))
  escaped = thrown(R.World.fault(broken))
  w = A.clearException(broken)
  +w = A.resultWorld(A.createRoot(4096n, w, R.Literal{R.Undefined{}}, 1n, False{}))
  +program = B.length(R.CleanupProgram, R.World.cleanupPrograms(w))
  w = A.registerProgram(w, A.programEmit(55n, A.emptyProgram()))
  compute = {R.Then{R.OnCleanup{R.Literal{R.ProgramReference{program}}}, R.Literal{R.Number{1n}}} : R.Expr}
  w = A.createMemoWithOptions(4096n, w, compute, R.NodeOptions.with_lazy(N.defaults(), True{}), 4n)
  w = A.resultWorld(A.createRoot(4096n, w, R.Literal{R.Undefined{}}, 4n, False{}))
  w = A.flush(4096n, A.createEffect(4096n, w, R.Read{5n}, False{}, 2n, False{}, False{}, 6n))
  +done = A.flush(4096n, A.dispose(w, 6n))
  LeakView{escaped, L.isDisposed(done, 5n), releasedCalls(R.World.events(done)), Nat.is_ne(R.World.deferredReleases(done), 0n),
    B.get(List<&2, Nat>, R.World.releaseLists(done), R.World.deferredReleases(done), []),
    R.World.context(done), R.World.tracking(done), R.World.running(done), R.World.fault(done)}

def expectedCollectorRestored() -> LeakView:
  LeakView{R.Number{99n}, True{}, 1n, False{}, [], 0n, False{}, False{}, R.Healthy{}}
