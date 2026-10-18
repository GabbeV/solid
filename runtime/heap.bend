# Solid src/core/heap.ts, intrusive height buckets. Pointer walks are bounded
# explicitly; exhaustion is an error, never a completed schedule.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

type Mark is Data:
  Mark{id: Nat, state: U32}

def subscriber_marks(fuel: Nat, +w: R.World, +edge: Nat) -> List<&2, Mark>:
  match fuel:
    case 0n:
      []
    case 1n+p:
      B.choose(~List<&2, Mark>, Nat.is_eq(edge, 0n), _ => [],
        _ => Mark{R.Link.sub(B.link(w, edge)), 1} <> subscriber_marks(p, w, R.Link.nextSub(B.link(w, edge))))

def mark_work(fuel: Nat, +w: R.World, work: List<&2, Mark>) -> R.World:
  match fuel work:
    case _ Nil{}:
      w
    case 0n _:
      R.World.with_fault(w, R.Exhausted{})
    case 1n+ +p Mark{+id, +state} <> +rest:
      +n = B.node(w, id)
      B.choose(~R.World, U32.is_ge(U32.and(R.Node.flags(n), 3), state),
        _ => mark_work(p, w, rest),
        _ =>
          +w = B.store_node(w, id, R.Node.with_flags(n, B.set(B.clear(R.Node.flags(n), 3), state)))
          mark_work(p, w, B.append(Mark, subscriber_marks(B.budget(w), w, R.Node.subs(n)), rest)))

def markNode(+w: R.World, id: Nat, state: U32) -> R.World:
  mark_work(B.budget(w), w, [Mark{id, state}])

def actualInsertIntoHeap(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  +parent = B.parentComputed(w, R.Node.parent(n))
  +parentHeight = R.Node.height(B.node(w, parent))
  +height = B.choose(~Nat, Bool.and(Nat.is_ne(parent, 0n), B.computed(R.Node.kind(B.node(w, parent)))),
    _ => Nat.max(R.Node.height(n), 1n+parentHeight), _ => R.Node.height(n))
  +w = B.store_node(w, id, R.Node.with_height(n, height))
  +head = B.bucket(w, height)
  +w = B.choose(~R.World, Nat.is_eq(head, 0n), _ => B.store_bucket(w, height, id),
    _ =>
      +tail = R.Node.prevHeap(B.node(w, head))
      +w = B.store_node(w, tail, R.Node.with_nextHeap(B.node(w, tail), id))
      +w = B.store_node(w, id, R.Node.with_prevHeap(B.node(w, id), tail))
      B.store_node(w, head, R.Node.with_prevHeap(B.node(w, head), id)))
  R.World.with_maximum(w, Nat.max(height, R.World.maximum(w)))

def insertIntoHeap(+w: R.World, +id: Nat) -> R.World:
  +flags = R.Node.flags(B.node(w, id))
  B.choose(~R.World, B.has(flags, 12), _ => w,
    _ =>
      +w = B.choose(~R.World, B.has(flags, 1),
        _ => B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(B.clear(flags, 3), 10))),
        _ =>
          +w = B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(flags, 8)))
          B.choose(~R.World, R.World.marked(w), _ => markNode(w, id, 2), _ => w))
      B.choose(~R.World, B.has(flags, 16), _ => w, _ => actualInsertIntoHeap(w, id)))

def enqueueSub(+w: R.World, +id: Nat) -> R.World:
  insertIntoHeap(R.World.with_minimum(w, Nat.min(R.World.minimum(w), R.Node.height(B.node(w, id)))), id)

def insertIntoHeapHeight(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  B.choose(~R.World, B.has(R.Node.flags(n), 28), _ => w,
    _ => actualInsertIntoHeap(B.store_node(w, id, R.Node.with_flags(n, B.set(R.Node.flags(n), 16))), id))

def deleteFromHeap(+w: R.World, +id: Nat) -> R.World:
  +n = B.node(w, id)
  B.choose(~R.World, Bool.not(B.has(R.Node.flags(n), 24)), _ => w,
    _ =>
      +w = B.store_node(w, id, R.Node.with_flags(n, B.clear(R.Node.flags(n), 24)))
      +w = B.choose(~R.World, Nat.is_eq(R.Node.prevHeap(n), id),
        _ => B.store_bucket(w, R.Node.height(n), 0n),
        _ =>
          +head = B.bucket(w, R.Node.height(n))
          +next = R.Node.nextHeap(n)
          +end = B.choose(~Nat, Nat.is_eq(next, 0n), _ => head, _ => next)
          +w = B.choose(~R.World, Nat.is_eq(head, id),
            _ => B.store_bucket(w, R.Node.height(n), next),
            _ => B.store_node(w, R.Node.prevHeap(n), R.Node.with_nextHeap(B.node(w, R.Node.prevHeap(n)), next)))
          B.store_node(w, end, R.Node.with_prevHeap(B.node(w, end), R.Node.prevHeap(n))))
      B.store_node(w, id, R.Node.with_nextHeap(R.Node.with_prevHeap(B.node(w, id), id), 0n)))

def mark_bucket(fuel: Nat, +w: R.World, +id: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World, Nat.is_eq(id, 0n), _ => w, _ => R.World.with_fault(w, R.Exhausted{}))
    case 1n+p:
      B.choose(~R.World, Nat.is_eq(id, 0n), _ => w,
        _ =>
          +n = B.node(w, id)
          +w = B.choose(~R.World, B.has(R.Node.flags(n), 8), _ => markNode(w, id, 2), _ => w)
          mark_bucket(p, w, R.Node.nextHeap(n)))

def mark_heights(fuel: Nat, +w: R.World, +height: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World, Nat.is_gt(height, R.World.maximum(w)), _ => w, _ => R.World.with_fault(w, R.Exhausted{}))
    case 1n+p:
      B.choose(~R.World, Nat.is_gt(height, R.World.maximum(w)), _ => w,
        _ => mark_heights(p, mark_bucket(B.budget(w), w, B.bucket(w, height)), 1n+height))

def markHeap(+w: R.World) -> R.World:
  B.choose(~R.World, R.World.marked(w), _ => w,
    _ => mark_heights(1n+R.World.maximum(w), R.World.with_marked(w, True{}), 0n))

def height_subs(fuel: Nat, +w: R.World, +edge: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w, _ => R.World.with_fault(w, R.Exhausted{}))
    case 1n+p:
      B.choose(~R.World, Nat.is_eq(edge, 0n), _ => w,
        _ => height_subs(p, insertIntoHeapHeight(w, R.Link.sub(B.link(w, edge))), R.Link.nextSub(B.link(w, edge))))

def max_dep_height(fuel: Nat, +w: R.World, +edge: Nat, +height: Nat) -> Nat:
  match fuel:
    case 0n:
      height
    case 1n+p:
      B.choose(~Nat, Nat.is_eq(edge, 0n), _ => height,
        _ =>
          +dep = B.node(w, R.Link.dep(B.link(w, edge)))
          nextHeight = B.choose(~Nat, B.computed(R.Node.kind(dep)), _ => Nat.max(height, 1n+R.Node.height(dep)), _ => height)
          max_dep_height(p, w, R.Link.nextDep(B.link(w, edge)), nextHeight))

def adjustHeight(+w: R.World, +id: Nat) -> R.World:
  +w = deleteFromHeap(w, id)
  +n = B.node(w, id)
  +height = max_dep_height(B.budget(w), w, R.Node.deps(n), R.Node.height(n))
  B.choose(~R.World, Nat.is_eq(height, R.Node.height(n)), _ => w,
    _ => height_subs(B.budget(w), B.store_node(w, id, R.Node.with_height(n, height)), R.Node.subs(n)))
