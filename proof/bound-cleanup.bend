# One init-bound function has one canonical disposal identity. Repeated
# registrations retain LIFO array shape and invoke detached-root cleanup once.
import Base
import ../runtime/api.bend as A
import ../runtime/ambient.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R


def register(w: R.World, function: R.Value) -> R.World:
  A.resultWorld(A.evaluateExpression(512n, w,
    R.WithOwner{R.Literal{R.OwnerReference{1n}}, R.OnCleanup{R.Literal{function}}}, R.Undefined{}))


def initial() -> R.World:
  w = A.registerProgram(A.createWorld(), A.programEmit(9n, A.emptyProgram()))
  w = A.registerProgram(w, A.programCleanup(1n, A.programReturn(R.Argument{0n}, A.emptyProgram())))
  +m = A.createRoot(512n, w, R.CallWith{2n, R.Argument{0n}, R.Literal{R.Undefined{}}}, 0n, False{})
  register(register(A.resultWorld(m), A.resultValue(m)), R.RootDisposerReference{2n})


type View is Data:
  View{registered: R.Disposal, callables: Nat, parentDead: Bool,
    targetDead: Bool, targetParent: Nat, disposal: R.Disposal,
    events: List<&2, R.TraceEvent>, context: Nat, tracking: Bool, fault: R.Fault}


def view(+before: R.World) -> View:
  +after = A.dispose(before, 1n)
  View{R.Node.disposal(B.node(before, 1n)), B.length(R.CleanupProgram, R.World.cleanupPrograms(before)),
    L.isDisposed(after, 1n), L.isDisposed(after, 2n), R.Node.parent(B.node(after, 2n)),
    R.Node.disposal(B.node(after, 2n)), R.World.events(after),
    R.World.context(after), R.World.tracking(after), R.World.fault(after)}


def expected() -> View:
  View{R.ManyDisposals{[3n, 3n]}, 4n, True{}, True{}, 0n, R.NoDisposal{},
    [R.CleanupObserved{1n, 9n}], 0n, False{}, R.Healthy{}}
