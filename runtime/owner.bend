# Owned synchronous nodes only; no cleanup callbacks, parked frames, dormant
# nodes, or reentrant teardown are admitted by the current callback grammar.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./graph.bend as G
import ./heap.bend as H

# core/owner.ts:linkChild. _parent was stored by the constructor literal.
def linkChild(+w: R.World, +parent: Nat, +id: Nat) -> R.World:
  +head = R.Node.firstChild(B.node(w, parent))
  +w = B.store_node(w, id, R.Node.with_prevSibling(B.node(w, id), 0n))
  +w = B.store_node(w, id, R.Node.with_nextSibling(B.node(w, id), head))
  +w = B.choose(~R.World, Nat.is_ne(head, 0n),
    _ => B.store_node(w, head, R.Node.with_prevSibling(B.node(w, head), id)), _ => w)
  B.store_node(w, parent, R.Node.with_firstChild(B.node(w, parent), id))

def splice(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  +parent = R.Node.parent(n)
  +prev = R.Node.prevSibling(n)
  +next = R.Node.nextSibling(n)
  B.choose(~R.World, Bool.and(Nat.is_ne(parent, 0n), Bool.not(B.has(R.Node.flags(B.node(w, parent)), 64))),
    _ =>
      +w = B.choose(~R.World, Nat.is_ne(prev, 0n),
        _ => B.store_node(w, prev, R.Node.with_nextSibling(B.node(w, prev), next)),
        _ => B.store_node(w, parent, R.Node.with_firstChild(B.node(w, parent), next)))
      +w = B.choose(~R.World, Nat.is_ne(next, 0n),
        _ => B.store_node(w, next, R.Node.with_prevSibling(B.node(w, next), prev)), _ => w)
      B.store_node(w, id, R.Node.with_prevSibling(B.node(w, id), 0n)), _ => w)

def children(fuel: Nat, +w: R.World, +id: Nat) -> List<&2, Nat>:
  match fuel:
    case 0n:
      []
    case 1n+p:
      B.choose(~List<&2, Nat>, Nat.is_eq(id, 0n), _ => [], _ => id <> children(p, w, R.Node.nextSibling(B.node(w, id))))

def dispose_work(fuel: Nat, +w: R.World, ids: List<&2, Nat>) -> R.World:
  match fuel ids:
    case _ Nil{}:
      w
    case 0n _:
      R.World.with_fault(w, R.Exhausted{})
    case 1n+ +p +id <> +rest:
      +n = B.node(w, id)
      B.choose(~R.World, B.has(R.Node.flags(n), 64), _ => dispose_work(p, w, rest),
        _ =>
          +kids = children(B.budget(w), w, R.Node.firstChild(n))
          +w = G.clearDeps(H.deleteFromHeap(w, id), id)
          +w = B.store_node(w, id, R.Node.with_firstChild(R.Node.with_config(R.Node.with_flags(B.node(w, id), B.set(R.Node.flags(B.node(w, id)), 64)), B.clear(R.Node.config(n), 32)), 0n))
          dispose_work(p, splice(w, id), B.append(Nat, kids, rest)))

def dispose(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, B.valid(w, id), _ => dispose_work(B.budget(w), w, [id]), _ => R.World.with_fault(w, R.BadId{}))
