# scheduler.ts:insertSubs and its intrusive subscriber walk. Shared by writes
# and held-frame re-entry, extracted only to break the TS module import cycle.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./heap.bend as H

def insert_subs(fuel: Nat, +w: R.World, +edge: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w, _ => R.World.with_fault(w, R.Exhausted{}))
    case 1n+p:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w,
        _ =>
          +e = B.link(w, edge)
          +id = R.Link.sub(e)
          +sub = B.node(w, id)
          missed = Bool.and(B.has(R.Node.flags(sub), 4), Bool.and(Nat.is_eq(R.Link.gen(e), R.Node.depGen(sub)), Nat.is_ne(edge, R.Node.depsTail(sub))))
          +w = B.choose(~R.World, missed,
            _ => B.store_node(w, id, R.Node.with_flags(sub, B.set(R.Node.flags(sub), 4096))), _ => w)
          insert_subs(p, H.enqueueSub(w, id), R.Link.nextSub(e)))

def insertSubs(+w: R.World, +id: Nat) -> R.World:
  +w = B.store_node(w, id, R.Node.with_notified(B.node(w, id), R.Stamped{R.World.epoch(w)}))
  insert_subs(B.budget(w), w, R.Node.subs(B.node(w, id)))
