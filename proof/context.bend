# Closed composed root allocation / captured owner / explicit disposal law.
import Base
import ../runtime/api.bend as A
import ../runtime/ambient.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R

# The init ignores its bound disposer argument and keeps its actual owner in
# a signal. The root's public dispose method later runs the registered cleanup.
def allocated() -> R.World:
  w = A.createSignal(A.createWorld(), R.Null{}, True{})
  w = A.registerProgram(w, A.programEmit(9n, A.emptyProgram()))
  w = A.registerProgram(w, A.programCleanup(1n, A.programWriteExpr(2n,
    R.CurrentOwner{}, A.programReturn(R.CurrentObserver{}, A.emptyProgram()))))
  m = A.evaluateExpression(512n, w,
    R.WithOwner{R.Literal{R.OwnerReference{1n}}, R.RootScope{R.CallProgram{2n}, False{}}}, R.Undefined{})
  A.flush(512n, A.resultWorld(m))

def disposed() -> R.World:
  A.resultWorld(A.evaluateExpression(512n, allocated(), R.DisposeRoot{R.Read{2n}}, R.Undefined{}))

def cleanupEvents(events: List<&2, R.TraceEvent>) -> List<&2, R.TraceEvent>:
  match events:
    case Nil{}:
      []
    case R.CleanupObserved{callback, code} <> rest:
      R.CleanupObserved{callback, code} <> cleanupEvents(rest)
    case other <> rest:
      cleanupEvents(rest)

type View is Data:
  View{saved: R.Value, dead: Bool, parent: Nat, computed: Nat,
    first: Nat, disposal: R.Disposal, events: List<&2, R.TraceEvent>,
    context: Nat, tracking: Bool, pending: List<&2, Nat>,
    running: Bool, scheduled: Bool, fault: R.Fault}

def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 2n)), L.isDisposed(w, 3n),
    R.Node.parent(B.node(w, 3n)), R.Node.parentComputed(B.node(w, 3n)),
    R.Node.firstChild(B.node(w, 1n)), R.Node.disposal(B.node(w, 3n)),
    cleanupEvents(R.World.events(w)), R.World.context(w), R.World.tracking(w),
    R.World.pendingNodes(w), R.World.running(w), R.World.scheduled(w), R.World.fault(w)}

def expected() -> View:
  View{R.OwnerReference{3n}, True{}, 1n, 0n, 0n, R.NoDisposal{},
    [R.CleanupObserved{1n, 9n}], 0n, False{}, [], False{}, False{}, R.Healthy{}}
