# A root callback's local signal is retained by two source effect closures.
# The user callback accumulates input into the local; the render reads it.
import Base
import ../runtime/api.bend as A
import ../runtime/construct.bend as N
import ../runtime/ambient.bend as L
import ../representation/base.bend as B
import ../representation/records.bend as R


def scenario() -> R.World:
  w = A.createSignal(A.createWorld(), R.Number{1n}, True{})
  m = A.createRoot(2048n, w, R.SignalScope{R.Literal{R.Number{0n}}, N.defaults(),
    R.Then{
      A.nestedEffectBody(R.Read{2n}, True{}, 0n, N.defaults(), False{}, False{},
        R.LocalWrite{0n, R.Add{R.Previous{}, R.Argument{0n}}, True{}}, 0n, 0n),
      A.nestedEffect(R.LocalRead{0n}, False{}, 3n, N.defaults(), False{}, False{}, 0n, 0n, 0n)}}, 1n, False{})
  w = A.flush(2048n, A.resultWorld(m))
  w = A.flush(2048n, A.setSignal(w, 2n, R.Number{3n}))
  w = A.flush(2048n, A.setSignal(w, 2n, R.Number{5n}))
  A.flush(2048n, A.setSignal(A.dispose(w, 3n), 2n, R.Number{8n}))


type View is Data:
  View{input: R.Value, local: R.Value, pending: R.Slot, localParent: Nat,
    localDead: Bool, userDead: Bool, renderDead: Bool, child: Nat,
    screen: R.Value, size: Nat, programs: Nat, context: Nat, tracking: Bool,
    running: Bool, scheduled: Bool, fault: R.Fault}


def view(+w: R.World) -> View:
  View{R.Node.value(B.node(w, 2n)), R.Node.value(B.node(w, 4n)), R.Node.pending(B.node(w, 4n)),
    R.Node.parent(B.node(w, 4n)), L.isDisposed(w, 4n), L.isDisposed(w, 5n), L.isDisposed(w, 6n),
    R.Node.firstChild(B.node(w, 3n)), R.TreeNode.text(B.get(R.TreeNode, R.World.tree(w), 3n, B.blank_tree())),
    B.length(R.Node, R.World.nodes(w)), B.length(R.CleanupProgram, R.World.cleanupPrograms(w)),
    R.World.context(w), R.World.tracking(w), R.World.running(w), R.World.scheduled(w), R.World.fault(w)}


def expected() -> View:
  View{R.Number{8n}, R.Number{9n}, R.Empty{}, 0n, False{}, True{}, True{}, 0n,
    R.Number{9n}, 7n, 2n, 0n, False{}, False{}, False{}, R.Healthy{}}
