# Small source-changing frame probes, independent of the history constructor.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P

def initial(value: R.Value) -> R.World:
  R.World.with_nodes(B.empty(), [B.blank_node(), R.Node.with_kind(B.blank_node(), R.Memo{}), R.Node.with_kind(R.Node.with_value(B.blank_node(), value), R.Render{})])

def removed(value: R.Value) -> R.World:
  +w = B.first(R.World, Bool, P.addPendingSource(initial(value), 2n, 1n))
  B.first(R.World, Bool, P.removePendingSource(w, 2n, 1n))

def cache(+value: R.Value) -> {R.Node.value(B.node(removed(value), 2n)) == value : R.Value}:
  {==}

def subscriberHead(value: R.Value) -> {R.Node.subs(B.node(removed(value), 2n)) == 0n : Nat}:
  {==}

def nodeCount(value: R.Value) -> {B.length(R.Node, R.World.nodes(removed(value))) == 3n : Nat}:
  {==}
