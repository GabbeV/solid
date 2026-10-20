# Two registrations retain the bound getter's identity. Its lazy read runs
# during the actual owner walk, with a live caller operand; its answer is ignored.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/ambient.bend as L
import ../runtime/construct.bend as N
import ../representation/base.bend as B
import ../representation/records.bend as R

def register(w: R.World) -> C.Machine:
  A.evaluateExpression(1024n, w,
    R.WithOwner{R.Literal{R.OwnerReference{1n}}, R.OnCleanup{R.Literal{R.AccessorReference{3n}}}}, R.Undefined{})

type View is Data:
  View{returned: R.Value, registered: R.Disposal, callables: Nat,
    result: R.Value, input: R.Value, pulled: R.Value, dead: Bool,
    disposal: R.Disposal, scheduled: Bool, context: Nat, tracking: Bool, fault: R.Fault}

def scenario() -> View:
  w = A.createSignal(A.createWorld(), R.Number{3n}, True{})
  w = A.createMemoWithOptions(1024n, w, R.Add{R.Read{2n}, R.Read{2n}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 0n)
  +registered = register(A.resultWorld(register(w)))
  +before = A.resultWorld(registered)
  +m = A.evaluateExpression(2048n, before,
    R.Add{R.Literal{R.Number{40n}}, R.Then{R.Invoke{R.Literal{R.RootDisposerReference{1n}}}, R.Literal{R.Number{2n}}}}, R.Undefined{})
  +done = A.flush(2048n, A.resultWorld(m))
  View{A.resultValue(registered), R.Node.disposal(B.node(before, 1n)), B.length(R.CleanupProgram, R.World.cleanupPrograms(before)),
    A.resultValue(m), R.Node.value(B.node(done, 2n)), R.Node.value(B.node(done, 3n)), L.isDisposed(done, 1n),
    R.Node.disposal(B.node(done, 1n)), R.World.scheduled(done), R.World.context(done), R.World.tracking(done), R.World.fault(done)}

def expected() -> View:
  View{R.AccessorReference{3n}, R.ManyDisposals{[1n, 1n]}, 2n,
    R.Number{42n}, R.Number{3n}, R.Number{6n}, True{}, R.NoDisposal{}, False{}, 0n, False{}, R.Healthy{}}
