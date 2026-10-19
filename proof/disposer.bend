# Root init's bound disposer remains function data through an updater, then
# disposes its captured owner even when invoked under another live root.
import Base
import ../runtime/api.bend as A
import ../runtime/context.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R


def initial() -> R.World:
  w = A.createSignal(A.createWorld(), R.Null{}, True{})
  w = A.registerProgram(w, A.programEmit(9n, A.emptyProgram()))
  w = A.registerProgram(w, A.programCleanup(1n, A.programReturn(R.Argument{0n}, A.emptyProgram())))
  +m = A.evaluateExpression(512n, w,
    R.WithOwner{R.Literal{R.OwnerReference{1n}},
      R.RootScope{R.CallWith{2n, R.Argument{0n}, R.Literal{R.Undefined{}}}, False{}}}, R.Undefined{})
  w = A.setUpdater(512n, A.resultWorld(m), 2n, R.Literal{A.resultValue(m)})
  w = A.flush(512n, w)
  A.resultWorld(A.evaluateExpression(512n, w,
    R.WithOwner{R.Literal{R.OwnerReference{1n}}, R.RootScope{R.CurrentOwner{}, False{}}}, R.Undefined{}))

def invoked() -> R.World:
  A.resultWorld(A.evaluateExpression(512n, initial(),
    R.WithOwner{R.Literal{R.OwnerReference{4n}}, R.Invoke{R.Read{2n}}}, R.Undefined{}))

type View is Data:
  View{function: R.Value, capturedDead: Bool, otherDead: Bool,
    first: Nat, next: Nat, callback: R.Disposal, context: Nat,
    tracking: Bool, fault: R.Fault, pending: List<&2, Nat>, scheduled: Bool}

def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 2n)), L.isDisposed(w, 3n), L.isDisposed(w, 4n),
    R.Node.firstChild(B.node(w, 1n)), R.Node.nextSibling(B.node(w, 4n)),
    R.Node.disposal(B.node(w, 3n)), R.World.context(w), R.World.tracking(w),
    R.World.fault(w), R.World.pendingNodes(w), R.World.scheduled(w)}

def expected() -> View:
  View{R.RootDisposerReference{3n}, True{}, False{}, 4n, 0n, R.NoDisposal{},
    0n, False{}, R.Healthy{}, [], False{}}
