# Callback-free staging/notification preserves committed storage, rendered tree
# and application trace. Queue/heap/pending/extension/report/fault changes remain
# real and are not asserted to be identities or successful progress.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/constants.bend as K
import ../runtime/write.bend as W
import ../runtime/read-state.bend as V
import ../runtime/heap.bend as H
import ./committed-storage-frame.bend as Frame
import ./heap-committed-frame.bend as Heap

def stashTail(+w: R.World, +id: Nat) -> R.World:
  +w = B.store_extension(w, id, R.NodeExtension.with_flushed(B.extension(w, id), R.Node.pending(B.node(w, id))))
  +w = B.store_extension(w, id, R.NodeExtension.with_flushedAt(B.extension(w, id), R.Stamped{R.World.clock(w)}))
  R.World.with_unflushedStaged(w, True{})

def stashTailFrame(+w: R.World, +id: Nat) ->
  {Frame.observe(stashTail(w, id)) == Frame.observe(w) : Frame.View}:
  +firstRecord = R.NodeExtension.with_flushed(B.extension(w, id), R.Node.pending(B.node(w, id)))
  +first = B.store_extension(w, id, firstRecord)
  +secondRecord = R.NodeExtension.with_flushedAt(B.extension(first, id), R.Stamped{R.World.clock(first)})
  +second = B.store_extension(first, id, secondRecord)
  Frame.compose(w, first, stashTail(w, id), Frame.compose(first, second, stashTail(w, id), Frame.worldUnflushedStaged(second, True{}), Frame.storeExtension(first, id, secondRecord)), Frame.storeExtension(w, id, firstRecord))

def stash(+w: R.World, +id: Nat) ->
  {Frame.observe(V.stashFlushed(w, id)) == Frame.observe(w) : Frame.View}:
  +saved = B.choose(~R.World, B.stampMatches(R.NodeExtension.flushedAt(B.extension(w, id)), R.World.clock(w)), _ => w, _ => stashTail(w, id))
  Frame.choice(Nat.is_eq(R.Node.x(B.node(w, id)), 0n), w, R.World.with_fault(w, R.Unsupported{3n}), saved, Frame.worldFault(w, R.Unsupported{3n}),
    Frame.choice(B.stampMatches(R.NodeExtension.flushedAt(B.extension(w, id)), R.World.clock(w)), w, w, stashTail(w, id), {==}, stashTailFrame(w, id)))

def promoted(+w: R.World, +id: Nat) ->
  {Frame.observe(V.notePromotedWrite(w, id)) == Frame.observe(w) : Frame.View}:
  +next = B.store_node(w, id, R.Node.with_config(B.node(w, id), B.set(R.Node.config(B.node(w, id)), K.CONFIG_PROMOTED())))
  +changed = R.World.with_promotedWrites(next, B.append(Nat, R.World.promotedWrites(next), [id]))
  Frame.choice(Bool.or(R.World.running(w), B.has(R.Node.config(B.node(w, id)), K.CONFIG_PROMOTED())), w, w, changed, {==},
    Frame.compose(w, next, changed, Frame.worldPromotedWrites(next, B.append(Nat, R.World.promotedWrites(next), [id])), Frame.config(w, id, B.set(R.Node.config(B.node(w, id)), K.CONFIG_PROMOTED()))))

def queued(+w: R.World, +id: Nat) ->
  {Frame.observe(W.queuePendingNode(w, id)) == Frame.observe(w) : Frame.View}:
  +pending = B.append(Nat, R.World.pendingNodes(w), [id])
  +next = R.World.with_pendingNodes(w, pending)
  Frame.compose(w, next, W.queuePendingNode(w, id), Frame.choice(Bool.not(R.World.running(next)), next, V.markUnflushedStaged(next), next, Frame.worldUnflushedStaged(next, True{}), {==}), Frame.worldPendingNodes(w, pending))

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

# The helper split is at source locals/return points. The source function itself
# remains unchanged and is used in the final theorem's conclusion.
def intake(+w: R.World, +id: Nat, +node: R.Node, +staged: Bool) -> R.World:
  B.choose(~R.World, staged,
    _ => B.choose(~R.World, Bool.and(B.has(R.Node.config(node), K.CONFIG_HELD()), Bool.not(R.World.running(w))), _ => V.stashFlushed(w, id), _ => w),
    _ => W.queuePendingNode(w, id))

def intakeFrame(+w: R.World, +id: Nat, +node: R.Node, +staged: Bool) ->
  {Frame.observe(intake(w, id, node, staged)) == Frame.observe(w) : Frame.View}:
  Frame.choice(staged, w, B.choose(~R.World, Bool.and(B.has(R.Node.config(node), K.CONFIG_HELD()), Bool.not(R.World.running(w))), _ => V.stashFlushed(w, id), _ => w), W.queuePendingNode(w, id),
    Frame.choice(Bool.and(B.has(R.Node.config(node), K.CONFIG_HELD()), Bool.not(R.World.running(w))), w, V.stashFlushed(w, id), w, stash(w, id), {==}), queued(w, id))

def tail(+w: R.World, +id: Nat, +value: R.Value, +node: R.Node, +staged: Bool) -> R.World:
  +w = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value}))
  +w = B.choose(~R.World, Nat.is_ne(R.World.context(w), 0n), _ => V.notePromotedWrite(w, id), _ => w)
  +w = B.choose(~R.World, B.computed(R.Node.kind(node)), _ => B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w))), _ => w)
  B.choose(~R.World, Bool.and(staged, B.stampMatches(R.Node.notified(node), R.World.epoch(w))), _ => w, _ => B.schedule(W.insertSubs(w, id)))

def tailFrame(+w: R.World, +id: Nat, +value: R.Value, +node: R.Node, +staged: Bool) ->
  {Frame.observe(tail(w, id, value, node, staged)) == Frame.observe(w) : Frame.View}:
  +pending = B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value}))
  +noted = B.choose(~R.World, Nat.is_ne(R.World.context(pending), 0n), _ => V.notePromotedWrite(pending, id), _ => pending)
  +timed = B.choose(~R.World, B.computed(R.Node.kind(node)), _ => B.store_node(noted, id, R.Node.with_time(B.node(noted, id), R.World.clock(noted))), _ => noted)
  Frame.compose(w, pending, tail(w, id, value, node, staged),
    Frame.compose(pending, noted, tail(w, id, value, node, staged),
      Frame.compose(noted, timed, tail(w, id, value, node, staged),
        Frame.choice(Bool.and(staged, B.stampMatches(R.Node.notified(node), R.World.epoch(timed))), timed, timed, B.schedule(W.insertSubs(timed, id)), {==},
          Frame.compose(timed, W.insertSubs(timed, id), B.schedule(W.insertSubs(timed, id)), Frame.schedule(W.insertSubs(timed, id)), insertSubs(timed, id))),
        Frame.choice(B.computed(R.Node.kind(node)), noted, B.store_node(noted, id, R.Node.with_time(B.node(noted, id), R.World.clock(noted))), noted, Frame.time(noted, id, R.World.clock(noted)), {==})),
      Frame.choice(Nat.is_ne(R.World.context(pending), 0n), pending, V.notePromotedWrite(pending, id), pending, promoted(pending, id), {==})), Frame.pending(w, id, R.Present{value}))

def stages(+w: R.World, +id: Nat, +value: R.Value) ->
  {Frame.observe(W.stageResolved(w, id, value)) == Frame.observe(w) : Frame.View}:
  +node = B.node(w, id)
  +staged = B.present(R.Node.pending(node))
  +next = intake(w, id, node, staged)
  Frame.compose(w, next, W.stageResolved(w, id, value), tailFrame(next, id, value, node, staged), intakeFrame(w, id, node, staged))
