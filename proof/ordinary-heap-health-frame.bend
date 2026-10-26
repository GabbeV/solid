# With the recursive-marking phase off, actual heap insertion performs only
# record stores. It retains fault and every non-heap/action/group field observed
# by Frame; this does not claim heap-pointer well-formedness or publication.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/heap.bend as H
import ./ordinary-write-outer.bend as Frame

# Source's parent/height computation, before its first store.
def height(+w: R.World, +id: Nat) -> Nat:
  +n = B.node(w, id)
  +parent = B.parentComputed(w, R.Node.parent(n))
  +parentHeight = R.Node.height(B.node(w, parent))
  B.choose(~Nat, Bool.and(Nat.is_ne(parent, 0n), B.computed(R.Node.kind(B.node(w, parent)))), _ => Nat.max(R.Node.height(n), 1n+parentHeight), _ => R.Node.height(n))

def tailStores(+w: R.World, +id: Nat, +head: Nat) -> R.World:
  +tail = R.Node.prevHeap(B.node(w, head))
  +w = B.store_node(w, tail, R.Node.with_nextHeap(B.node(w, tail), id))
  +w = B.store_node(w, id, R.Node.with_prevHeap(B.node(w, id), tail))
  B.store_node(w, head, R.Node.with_prevHeap(B.node(w, head), id))

def tailFrame(+w: R.World, +id: Nat, +head: Nat) ->
  {Frame.observe(tailStores(w, id, head)) == Frame.observe(w) : R.World}:
  +tail = R.Node.prevHeap(B.node(w, head))
  +first = B.store_node(w, tail, R.Node.with_nextHeap(B.node(w, tail), id))
  +second = B.store_node(first, id, R.Node.with_prevHeap(B.node(first, id), tail))
  Frame.compose(w, first, tailStores(w, id, head),
    Frame.compose(first, second, tailStores(w, id, head), Frame.prevHeap(second, head, id), Frame.prevHeap(first, id, tail)), Frame.nextHeap(w, tail, id))

def insertTail(+w: R.World, +id: Nat, +height: Nat) -> R.World:
  +head = B.bucket(w, height)
  +w = B.choose(~R.World, Nat.is_eq(head, 0n), _ => B.store_bucket(w, height, id), _ => tailStores(w, id, head))
  R.World.with_maximum(w, Nat.max(height, R.World.maximum(w)))

def insertTailFrame(+w: R.World, +id: Nat, +height: Nat) ->
  {Frame.observe(insertTail(w, id, height)) == Frame.observe(w) : R.World}:
  +head = B.bucket(w, height)
  +next = B.choose(~R.World, Nat.is_eq(head, 0n), _ => B.store_bucket(w, height, id), _ => tailStores(w, id, head))
  Frame.compose(w, next, insertTail(w, id, height), Frame.worldMaximum(next, Nat.max(height, R.World.maximum(next))), Frame.choice(Nat.is_eq(head, 0n), w, B.store_bucket(w, height, id), tailStores(w, id, head), Frame.storeBucket(w, height, id), tailFrame(w, id, head)))

def actual(+w: R.World, +id: Nat) ->
  {Frame.observe(H.actualInsertIntoHeap(w, id)) == Frame.observe(w) : R.World}:
  +next = B.store_node(w, id, R.Node.with_height(B.node(w, id), height(w, id)))
  Frame.compose(w, next, H.actualInsertIntoHeap(w, id), insertTailFrame(next, id, height(w, id)), Frame.height(w, id, height(w, id)))

def flagged(+w: R.World, +id: Nat, +flags: U32) -> R.World:
  B.choose(~R.World, B.has(flags, 1),
    _ => B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(B.clear(flags, 3), 10))),
    _ =>
      +w = B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(flags, 8)))
      B.choose(~R.World, R.World.marked(w), _ => H.markNode(w, id, 2), _ => w))

def flaggedFrame(+w: R.World,+id: Nat,+flags: U32,known: {R.World.marked(w) == False{} : Bool}) -> {Frame.observe(flagged(w,id,flags)) == Frame.observe(w) : R.World}:
  +dirty = B.store_node(w,id,R.Node.with_flags(B.node(w,id),B.set(B.clear(flags,3),10)))
  +clean = B.store_node(w,id,R.Node.with_flags(B.node(w,id),B.set(flags,8)))
  +marked = B.choose(~R.World,R.World.marked(clean),_=>H.markNode(clean,id,2),_=>clean)
  +unchanged = Equal.cong(Bool,R.World,flag=>Frame.observe(B.choose(~R.World,flag,_=>H.markNode(clean,id,2),_=>clean)),R.World.marked(clean),False{},Frame.unmarked(w,clean,Frame.flags(w,id,B.set(flags,8)),known))
  Frame.choice(B.has(flags,1),w,dirty,marked,Frame.flags(w,id,B.set(B.clear(flags,3),10)),Frame.compose(w,clean,marked,unchanged,Frame.flags(w,id,B.set(flags,8))))


def insert(+w: R.World, +id: Nat,known: {R.World.marked(w) == False{} : Bool}) ->
  {Frame.observe(H.insertIntoHeap(w, id)) == Frame.observe(w) : R.World}:
  +flags = R.Node.flags(B.node(w, id))
  +next = flagged(w, id, flags)
  +inserted = B.choose(~R.World, B.has(flags, 16), _ => next, _ => H.actualInsertIntoHeap(next, id))
  Frame.choice(B.has(flags, 12), w, w, inserted, {==},
    Frame.compose(w, next, inserted, Frame.choice(B.has(flags, 16), next, next, H.actualInsertIntoHeap(next, id), {==}, actual(next, id)), flaggedFrame(w, id, flags,known)))

def enqueue(+w: R.World, +id: Nat,known: {R.World.marked(w) == False{} : Bool}) ->
  {Frame.observe(H.enqueueSub(w, id)) == Frame.observe(w) : R.World}:
  +minimum = Nat.min(R.World.minimum(w), R.Node.height(B.node(w, id)))
  +next = R.World.with_minimum(w, minimum)
  Frame.compose(w, next, H.enqueueSub(w, id), insert(next, id,Frame.unmarked(w,next,Frame.worldMinimum(w,minimum),known)), Frame.worldMinimum(w, minimum))
