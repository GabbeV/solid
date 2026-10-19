# An accessor escapes its allocating root via an updater return, then is read
# from a separate effect after that root dies. The source signal is unowned.
import Base
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/ambient.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R


def scenario() -> R.World:
  w = A.createSignal(A.createWorld(), R.Undefined{}, True{})
  +m = A.createRoot(1024n, w, R.SignalScope{R.Literal{R.Number{7n}}, N.defaults(), R.LocalAccessor{0n}}, 1n, False{})
  w = A.setUpdater(1024n, A.resultWorld(m), 2n, R.Literal{A.resultValue(m)})
  w = A.flush(1024n, w)
  w = A.createEffect(1024n, w, R.Add{R.Literal{R.Number{10n}}, R.Invoke{R.Read{2n}}}, False{}, 2n, False{}, False{}, 1n)
  w = A.flush(1024n, w)
  w = A.flush(1024n, A.setSignal(w, 4n, R.Number{9n}))
  w = A.dispose(w, 3n)
  A.flush(1024n, A.setSignal(w, 4n, R.Number{11n}))


type View is Data:
  View{function: R.Value, local: R.Value, rootDead: Bool, localDead: Bool,
    localParent: Nat, effectDead: Bool, effectParent: Nat, dep: Nat,
    screen: R.Value, context: Nat, tracking: Bool, running: Bool,
    scheduled: Bool, pending: List<&2, Nat>, fault: R.Fault}


def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 2n)), R.Node.value(B.node(w, 4n)), L.isDisposed(w, 3n), L.isDisposed(w, 4n),
    R.Node.parent(B.node(w, 4n)), L.isDisposed(w, 5n), R.Node.parent(B.node(w, 5n)),
    R.Link.dep(B.link(w, R.Node.depsTail(B.node(w, 5n)))),
    R.TreeNode.text(B.get(R.TreeNode, R.World.tree(w), 2n, B.blank_tree())),
    R.World.context(w), R.World.tracking(w), R.World.running(w), R.World.scheduled(w),
    R.World.pendingNodes(w), R.World.fault(w)}


def expected() -> View:
  View{R.AccessorReference{4n}, R.Number{11n}, True{}, False{}, 0n, False{}, 1n, 4n,
    R.Number{21n}, 0n, False{}, False{}, False{}, [], R.Healthy{}}
