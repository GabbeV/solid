# The actual graph.allocate path with empty previous dependency/subscriber
# tails. These helpers name its unchanged source statement segments for proofs.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/graph-state.bend as G

def index(w: R.World) -> Nat:
  B.length(R.Link, R.World.links(w))

def record(+w: R.World, root: Nat, +leaf: Nat) -> R.Link:
  R.Link{root, leaf, 0n, 0n, 0n, R.Node.depGen(B.node(w, leaf))}

def appended(+w: R.World, +root: Nat, +leaf: Nat) -> R.World:
  R.World.with_links(w, B.append(R.Link, R.World.links(w), [record(w, root, leaf)]))

def first(+w: R.World, +leaf: Nat, edge: Nat) -> R.World:
  B.store_node(w, leaf, R.Node.with_depsTail(B.node(w, leaf), edge))

def second(+w: R.World, +root: Nat, edge: Nat) -> R.World:
  B.store_node(w, root, R.Node.with_subsTail(B.node(w, root), edge))

def third(+w: R.World, +leaf: Nat, edge: Nat) -> R.World:
  B.store_node(w, leaf, R.Node.with_deps(B.node(w, leaf), edge))

def fourth(+w: R.World, +root: Nat, edge: Nat) -> R.World:
  B.store_node(w, root, R.Node.with_subs(B.node(w, root), edge))

def writes(w: R.World, +root: Nat, +leaf: Nat, +edge: Nat) -> R.World:
  B.bump(fourth(third(second(first(w, leaf, edge), root, edge), leaf, edge), root, edge))

def source(w: R.World, root: Nat, leaf: Nat) -> R.World:
  G.allocate(w, root, leaf, 0n, 0n, 0n)

def exact(+w: R.World, +root: Nat, +leaf: Nat) ->
  {source(w, root, leaf) == writes(appended(w, root, leaf), root, leaf, index(w)) : R.World}:
  {==}
