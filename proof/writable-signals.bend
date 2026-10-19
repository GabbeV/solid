# createSignal(fn), source setter policy and a preserved upstream failure.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/ambient.bend as L
import ../runtime/constants.bend as K


def pairBody(get: Nat, set: Nat) -> R.Expr:
  R.Then{R.WriteExpr{get, R.LocalAccessor{0n}, True{}}, R.WriteExpr{set, R.LocalSetter{0n}, True{}}}


def writable() -> R.World:
  w = A.createSignal(A.createWorld(), R.Number{1n}, True{})
  w = A.createSignal(A.createSignal(w, R.Undefined{}, True{}), R.Undefined{}, True{})
  expr = {R.Add{R.Select{R.Previous{}, R.Previous{}, R.Literal{R.Number{0n}}}, R.Read{2n}} : R.Expr}
  m = A.createRoot(2048n, w, R.SignalComputeScope{expr, R.NodeOptions.with_lazy(N.defaults(), True{}), pairBody(3n, 4n)}, 1n, False{})
  w = A.flush(2048n, A.resultWorld(m))
  w = A.createEffect(2048n, w, R.Invoke{R.Read{3n}}, False{}, 2n, False{}, False{}, 1n)
  w = A.flush(2048n, w)
  m = A.evaluateExpression(2048n, w, R.InvokeWith{R.Read{4n}, R.Literal{R.Number{10n}}, False{}}, R.Undefined{})
  A.flush(2048n, A.setSignal(A.resultWorld(m), 2n, R.Number{3n}))


type View is Data:
  View{input: R.Value, getter: R.Value, setter: R.Value, derived: R.Value,
    pending: R.Slot, autoDispose: Bool, manual: Bool, dead: Bool, parent: Nat,
    dependency: Nat, screen: R.Value, context: Nat, tracking: Bool, running: Bool,
    scheduled: Bool, intake: List<&2, Nat>, fault: R.Fault}


def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 2n)), R.Node.value(B.node(w, 3n)), R.Node.value(B.node(w, 4n)),
    R.Node.value(B.node(w, 6n)), R.Node.pending(B.node(w, 6n)), B.has(R.Node.config(B.node(w, 6n)), K.CONFIG_AUTO_DISPOSE()),
    B.has(R.Node.flags(B.node(w, 6n)), K.REACTIVE_MANUAL_WRITE()), L.isDisposed(w, 6n), R.Node.parent(B.node(w, 6n)),
    R.Link.dep(B.link(w, R.Node.deps(B.node(w, 6n)))), A.displayed(w, 2n),
    R.World.context(w), R.World.tracking(w), R.World.running(w), R.World.scheduled(w), R.World.pendingNodes(w), R.World.fault(w)}


def expected() -> View:
  View{R.Number{3n}, R.AccessorReference{6n}, R.SetterReference{6n}, R.Number{13n}, R.Empty{},
    False{}, False{}, False{}, 5n, 2n, R.Number{13n}, 0n, False{}, False{}, False{}, [], R.Healthy{}}


# Negative baseline evidence: a held updater's function result is invoked by
# setSignal a second time. The replacement disposer unexpectedly kills root 5.
def heldFunction() -> R.World:
  w = A.createThenable(A.createWorld(), True{})
  w = A.createSignal(w, R.Boolean{False{}}, True{})
  w = A.createSignal(A.createSignal(w, R.Undefined{}, True{}), R.Undefined{}, True{})
  w = A.resultWorld(A.createRoot(2048n, w, R.Literal{R.Undefined{}}, 0n, False{}))
  w = A.resultWorld(A.createRoot(2048n, w, R.Literal{R.Undefined{}}, 0n, False{}))
  w = A.resultWorld(A.createRoot(2048n, w, R.Literal{R.Undefined{}}, 0n, False{}))
  compute = {R.Select{R.Read{2n}, R.Literal{R.RootDisposerReference{7n}}, R.Literal{R.RootDisposerReference{6n}}} : R.Expr}
  w = A.resultWorld(A.createRoot(2048n, w, R.SignalComputeScope{compute, N.defaults(), pairBody(3n, 4n)}, 1n, False{}))
  w = A.flush(2048n, w)
  w = A.createMemoWithOptions(2048n, w, R.Select{R.Read{2n}, R.Literal{R.AsyncValue{1n}}, R.Literal{R.Number{0n}}}, N.defaults(), 1n)
  w = A.createEffect(2048n, w, R.Then{R.Read{2n}, R.Then{R.Invoke{R.Read{3n}}, R.Read{10n}}}, False{}, 2n, False{}, False{}, 1n)
  w = A.flush(2048n, w)
  A.flush(2048n, A.setSignal(w, 2n, R.Boolean{True{}}))


type Counterexample is Data:
  Counterexample{heldBefore: Bool, returned: R.Value, replacementDead: Bool,
    committed: R.Value, proposal: R.Slot, dirty: Bool, manual: Bool,
    scheduled: Bool, context: Nat, tracking: Bool, running: Bool, fault: R.Fault}


def counterexample() -> Counterexample:
  +w = heldFunction()
  before = B.has(R.Node.config(B.node(w, 9n)), K.CONFIG_HELD())
  +m = A.evaluateExpression(2048n, w, R.InvokeWith{R.Read{4n}, R.Literal{R.RootDisposerReference{5n}}, True{}}, R.Undefined{})
  +w = A.resultWorld(m)
  Counterexample{before, A.resultValue(m), L.isDisposed(w, 5n), R.Node.value(B.node(w, 9n)), R.Node.pending(B.node(w, 9n)),
    B.has(R.Node.flags(B.node(w, 9n)), K.REACTIVE_DIRTY()), B.has(R.Node.flags(B.node(w, 9n)), K.REACTIVE_MANUAL_WRITE()),
    R.World.scheduled(w), R.World.context(w), R.World.tracking(w), R.World.running(w), R.World.fault(w)}


def expectedCounterexample() -> Counterexample:
  Counterexample{True{}, R.Undefined{}, True{}, R.RootDisposerReference{6n}, R.Present{R.Undefined{}},
    True{}, False{}, True{}, 0n, False{}, False{}, R.Healthy{}}
