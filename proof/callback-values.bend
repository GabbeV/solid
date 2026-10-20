# A named callback value is invoked with arguments, initializes a computed
# signal, and shares a distinct canonical function in two owner cleanup slots.
import Base
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/core.bend as C
import ../runtime/ambient.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R

type View is Data:
  View{call: R.Value, returned: R.Value, registered: R.Disposal, callables: Nat,
    initial: R.Value, marker: R.Value, derived: R.Value, rootDead: Bool,
    derivedDead: Bool, context: Nat, tracking: Bool, fault: R.Fault}

def register(w: R.World) -> C.Machine:
  A.evaluateExpression(1024n, w, R.WithOwner{R.Literal{R.OwnerReference{1n}}, R.OnCleanup{R.Literal{R.ProgramReference{2n}}}}, R.Undefined{})

def scenario() -> View:
  w = A.createSignal(A.createWorld(), R.Number{1n}, True{})
  first = {R.Select{R.Argument{0n}, R.Argument{0n}, R.Literal{R.Number{0n}}} : R.Expr}
  second = {R.Select{R.Argument{1n}, R.Argument{1n}, R.Read{2n}} : R.Expr}
  w = A.registerProgram(w, A.programReturn(R.Add{first, second}, A.emptyProgram()))
  w = A.registerProgram(w, A.programWrite(2n, R.Number{9n}, A.emptyProgram()))
  +initial = A.createSignalInput(2048n, w, R.ProgramReference{1n}, N.defaults())
  +called = A.evaluateExpression(2048n, initial, R.InvokeArguments{R.Literal{R.ProgramReference{1n}}, R.Literal{R.Number{3n}}, R.Literal{R.Number{4n}}}, R.Undefined{})
  +m = register(A.resultWorld(register(A.resultWorld(called))))
  +before = A.resultWorld(m)
  +done = A.resultWorld(A.read(2048n, A.flush(2048n, A.dispose(before, 1n)), 3n))
  View{A.resultValue(called), A.resultValue(m), R.Node.disposal(B.node(before, 1n)), B.length(R.CleanupProgram, R.World.cleanupPrograms(before)),
    R.Node.value(B.node(initial, 3n)), R.Node.value(B.node(done, 2n)), R.Node.value(B.node(done, 3n)),
    L.isDisposed(done, 1n), L.isDisposed(done, 3n), R.World.context(done), R.World.tracking(done), R.World.fault(done)}

def expected() -> View:
  View{R.Number{7n}, R.ProgramReference{2n}, R.ManyDisposals{[3n, 3n]}, 4n,
    R.Number{1n}, R.Number{9n}, R.Number{10n}, True{}, False{}, 0n, False{}, R.Healthy{}}
