# Escaping createSignal(data)'s bound setter preserves its unowned target.
import Base
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/ambient.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R


def scenario() -> R.World:
  w = A.createSignal(A.createWorld(), R.Undefined{}, True{})
  +m = A.createRoot(2048n, w, R.SignalScope{R.Literal{R.Number{1n}}, N.defaults(), R.LocalSetter{0n}}, 1n, False{})
  w = A.setUpdater(2048n, A.resultWorld(m), 2n, R.Literal{A.resultValue(m)})
  w = A.flush(2048n, A.dispose(w, 3n))
  w = A.createEffect(2048n, w, R.Invoke{R.Literal{R.AccessorReference{4n}}}, False{}, 2n, False{}, False{}, 1n)
  w = A.flush(2048n, w)
  m = A.evaluateExpression(2048n, w, R.Then{
    R.InvokeWith{R.Read{2n}, R.Add{R.Previous{}, R.Literal{R.Number{2n}}}, True{}},
    R.InvokeWith{R.Read{2n}, R.Add{R.Previous{}, R.Literal{R.Number{4n}}}, True{}}}, R.Undefined{})
  A.flush(2048n, A.resultWorld(m))


type View is Data:
  View{function: R.Value, local: R.Value, rootDead: Bool, localDead: Bool,
    localParent: Nat, effectDead: Bool, dep: Nat, screen: R.Value,
    context: Nat, tracking: Bool, running: Bool, scheduled: Bool,
    pending: List<&2, Nat>, fault: R.Fault}


def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 2n)), R.Node.value(B.node(w, 4n)), L.isDisposed(w, 3n), L.isDisposed(w, 4n),
    R.Node.parent(B.node(w, 4n)), L.isDisposed(w, 5n), R.Link.dep(B.link(w, R.Node.depsTail(B.node(w, 5n)))),
    R.TreeNode.text(B.get(R.TreeNode, R.World.tree(w), 2n, B.blank_tree())),
    R.World.context(w), R.World.tracking(w), R.World.running(w), R.World.scheduled(w), R.World.pendingNodes(w), R.World.fault(w)}


def expected() -> View:
  View{R.SetterReference{4n}, R.Number{7n}, True{}, False{}, 0n, False{}, 4n,
    R.Number{7n}, 0n, False{}, False{}, False{}, [], R.Healthy{}}


type CaptureView is Data:
  CaptureView{returned: R.Value, staged: R.Slot, committed: R.Value,
    settled: R.Value, pending: List<&2, Nat>, fault: R.Fault}


def capture() -> CaptureView:
  w = A.createSignal(A.createWorld(), R.Number{1n}, True{})
  w = A.registerProgram(w, A.programWrite(2n, R.Number{9n}, A.programReturn(R.Literal{R.Number{1n}}, A.emptyProgram())))
  +m = A.updateValue(2048n, w, 2n, R.CallProgram{1n})
  +w = A.resultWorld(m)
  CaptureView{A.resultValue(m), R.Node.pending(B.node(w, 2n)), R.Node.value(B.node(w, 2n)),
    R.Node.value(B.node(A.flush(2048n, w), 2n)), R.World.pendingNodes(w), R.World.fault(w)}


def expectedCapture() -> CaptureView:
  CaptureView{R.Number{1n}, R.Present{R.Number{9n}}, R.Number{1n}, R.Number{9n}, [2n], R.Healthy{}}
