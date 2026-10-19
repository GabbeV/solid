# Closed context-record snapshots through actual API/root/callback operations.
import Base
import ../runtime/api.bend as A
import ../representation/base.bend as B
import ../representation/records.bend as R


def write(w: R.World, owner: Nat, value: R.Value) -> R.World:
  A.resultWorld(A.evaluateExpression(512n, w,
    R.ContextSet{1n, R.Literal{value}, R.Literal{R.OwnerReference{owner}}}, R.Undefined{}))


def initial() -> R.World:
  w = A.createContext(A.createWorld(), R.Number{7n}, A.noDescription())
  w = write(w, 1n, R.Number{11n})
  w = A.resultWorld(A.createRoot(512n, w, R.ContextGet{1n, R.Literal{R.Undefined{}}}, 1n, False{}))
  w = write(w, 1n, R.Number{13n})
  A.resultWorld(A.createRoot(512n, w, R.ContextGet{1n, R.Literal{R.Undefined{}}}, 1n, False{}))


def childOverride() -> R.World:
  write(initial(), 2n, R.Null{})


type View is Data:
  View{parent: R.Value, first: R.Value, late: R.Value,
    parentScope: Nat, firstScope: Nat, lateScope: Nat,
    context: Nat, tracking: Bool, pending: List<&2, Nat>, fault: R.Fault}


def view(+w: R.World) -> View:
  +parent = A.evaluateExpression(512n, w, R.ContextGet{1n, R.Literal{R.OwnerReference{1n}}}, R.Undefined{})
  +first = A.evaluateExpression(512n, A.resultWorld(parent), R.ContextGet{1n, R.Literal{R.OwnerReference{2n}}}, R.Undefined{})
  +late = A.evaluateExpression(512n, A.resultWorld(first), R.ContextGet{1n, R.Literal{R.OwnerReference{3n}}}, R.Undefined{})
  +w = A.resultWorld(late)
  View{A.resultValue(parent), A.resultValue(first), A.resultValue(late),
    R.Node.scope(B.node(w, 1n)), R.Node.scope(B.node(w, 2n)), R.Node.scope(B.node(w, 3n)),
    R.World.context(w), R.World.tracking(w), R.World.pendingNodes(w), R.World.fault(w)}


def expectedInitial() -> View:
  View{R.Number{13n}, R.Number{11n}, R.Number{13n}, 2n, 1n, 2n, 0n, False{}, [], R.Healthy{}}


def expectedOverride() -> View:
  View{R.Number{13n}, R.Null{}, R.Number{13n}, 2n, 3n, 2n, 0n, False{}, [], R.Healthy{}}
