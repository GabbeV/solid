# Notification/heap stores retain actual subscriber shape and link storage,
# even if a malformed walk exhausts. Successful health is a separate contract.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ../runtime/heap.bend as H
import ./subscriber-topology-frame.bend as Frame
import ./topology-heap-frame.bend as Heap

def insertSubsLoop(+fuel: Nat, +w: R.World, +edge: Nat) ->
  {Frame.observe(W.insert_subs(fuel, w, edge)) == Frame.observe(w) : Frame.View}:
  match fuel:
    case 0n:
      Frame.choice(Nat.is_eq(edge, 0n), w, w, R.World.with_fault(w, R.Exhausted{}), {==}, Frame.worldFault(w, R.Exhausted{}))
    case 1n+p:
      +e = B.link(w, edge)
      +id = R.Link.sub(e)
      +sub = B.node(w, id)
      +missed = Bool.and(B.has(R.Node.flags(sub), 4), Bool.and(Nat.is_eq(R.Link.gen(e), R.Node.depGen(sub)), Nat.is_ne(edge, R.Node.depsTail(sub))))
      +changed = B.store_node(w, id, R.Node.with_flags(sub, B.set(R.Node.flags(sub), 4096)))
      +marked = B.choose(~R.World, missed, _ => changed, _ => w)
      +next = H.enqueueSub(marked, id)
      +after = W.insert_subs(p, next, R.Link.nextSub(e))
      Frame.choice(Nat.is_eq(edge, 0n), w, w, after, {==},
        Frame.compose(w, marked, after,
          Frame.compose(marked, next, after, insertSubsLoop(p, next, R.Link.nextSub(e)), Heap.enqueue(marked, id)),
          Frame.choice(missed, w, changed, w, Frame.flags(w, id, B.set(R.Node.flags(sub), 4096)), {==})))

def insertSubs(+w: R.World, +id: Nat) ->
  {Frame.observe(W.insertSubs(w, id)) == Frame.observe(w) : Frame.View}:
  +next = B.store_node(w, id, R.Node.with_notified(B.node(w, id), R.Stamped{R.World.epoch(w)}))
  Frame.compose(w, next, W.insertSubs(w, id), insertSubsLoop(B.budget(next), next, R.Node.subs(B.node(next, id))), Frame.notified(w, id, R.Stamped{R.World.epoch(w)}))
