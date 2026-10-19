# A returned lazy accessor pulls the real computed. Its allocating root owns
# that computed, so disposal freezes the escaped getter's last value.
import Base
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/ambient.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R


def scenario() -> R.World:
  w = A.createSignal(A.createWorld(), R.Number{1n}, True{})
  w = A.createSignal(w, R.Undefined{}, True{})
  +m = A.createRoot(2048n, w, R.MemoAccessor{R.Add{R.Read{2n}, R.Literal{R.Number{2n}}}, R.NodeOptions.with_lazy(N.defaults(), True{})}, 1n, False{})
  w = A.setUpdater(2048n, A.resultWorld(m), 3n, R.Literal{A.resultValue(m)})
  w = A.flush(2048n, w)
  w = A.createEffect(2048n, w, R.Invoke{R.Read{3n}}, False{}, 2n, False{}, False{}, 1n)
  w = A.flush(2048n, w)
  w = A.flush(2048n, A.setSignal(w, 2n, R.Number{4n}))
  w = A.dispose(w, 4n)
  A.flush(2048n, A.setSignal(w, 2n, R.Number{9n}))


type View is Data:
  View{input: R.Value, function: R.Value, computed: R.Value, rootDead: Bool,
    computedDead: Bool, effectDead: Bool, computedParent: Nat, screen: R.Value,
    context: Nat, tracking: Bool, running: Bool, scheduled: Bool,
    pending: List<&2, Nat>, fault: R.Fault}


def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 2n)), R.Node.value(B.node(w, 3n)), R.Node.value(B.node(w, 5n)),
    L.isDisposed(w, 4n), L.isDisposed(w, 5n), L.isDisposed(w, 6n), R.Node.parent(B.node(w, 5n)),
    R.TreeNode.text(B.get(R.TreeNode, R.World.tree(w), 2n, B.blank_tree())),
    R.World.context(w), R.World.tracking(w), R.World.running(w), R.World.scheduled(w), R.World.pendingNodes(w), R.World.fault(w)}


def expected() -> View:
  View{R.Number{9n}, R.AccessorReference{5n}, R.Number{6n}, True{}, True{}, False{}, 4n,
    R.Number{6n}, 0n, False{}, False{}, False{}, [], R.Healthy{}}
