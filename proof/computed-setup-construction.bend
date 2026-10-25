# Exact setupComputedNode segments. This names source expressions in the proof;
# the active runtime is unchanged and checked by the defining equation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct-state.bend as N
import ../runtime/owner.bend as O

def previous(+w: R.World, +id: Nat) -> R.World:
  B.store_node(w, id, R.Node.with_prevHeap(B.node(w, id), id))

def parentPart(+w: R.World, +id: Nat, +parent: Nat, +computed: Nat) -> R.World:
  +w = B.choose(~R.World, Nat.is_ne(parent, 0n), _ => O.linkChild(w, parent, id), _ => w)
  B.choose(~R.World, Nat.is_ne(computed, 0n), _ => B.store_node(w, id, R.Node.with_height(B.node(w, id), 1n+R.Node.height(B.node(w, computed)))), _ => w)

def tail(+w: R.World, +id: Nat, +parent: Nat) -> R.World:
  parentPart(w, id, parent, B.parentComputed(w, parent))

def exact(+w: R.World, +id: Nat) ->
  {N.setupComputedNode(w, id) == tail(previous(w, id), id, R.Node.parent(B.node(previous(w, id), id))) : R.World}:
  {==}

def cut(+w: R.World, +id: Nat, +next: R.World,
  written: {previous(w, id) == next : R.World},
  parent: {R.Node.parent(B.node(next, id)) == 0n : Nat},
  computed: {B.parentComputed(next, 0n) == 0n : Nat}) ->
  {N.setupComputedNode(w, id) == next : R.World}:
  Equal.trans(R.World, N.setupComputedNode(w, id), tail(previous(w, id), id, R.Node.parent(B.node(previous(w, id), id))), next, exact(w, id),
    Equal.trans(R.World, tail(previous(w, id), id, R.Node.parent(B.node(previous(w, id), id))), tail(next, id, R.Node.parent(B.node(next, id))), next,
      Equal.cong(R.World, R.World, state => tail(state, id, R.Node.parent(B.node(state, id))), previous(w, id), next, written),
      Equal.trans(R.World, tail(next, id, R.Node.parent(B.node(next, id))), tail(next, id, 0n), next,
        Equal.cong(Nat, R.World, value => tail(next, id, value), R.Node.parent(B.node(next, id)), 0n, parent),
        Equal.cong(Nat, R.World, value => parentPart(next, id, 0n, value), B.parentComputed(next, 0n), 0n, computed))))

def computedFromNode(+before: R.World, +after: R.World, node: {B.node(after, 0n) == B.node(before, 0n) : R.Node}) ->
  {B.parentComputed(after, 0n) == B.parentComputed(before, 0n) : Nat}:
  Equal.cong(R.Node, Nat, record => B.choose(~Nat, B.root(R.Node.kind(record)), _ => R.Node.parentComputed(record), _ => 0n), B.node(after, 0n), B.node(before, 0n), node)
