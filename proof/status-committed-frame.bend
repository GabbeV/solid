# Status clearing/notifier queue or halt bookkeeping preserves committed
# storage/tree/trace. Queued effects and owner cleanups are not executed here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/constants.bend as K
import ../runtime/status.bend as S
import ../runtime/write.bend as W
import ../runtime/transaction.bend as X
import ../runtime/cleanup-state.bend as Cleanup
import ../runtime/pending-state.bend as P
import ./committed-storage-frame.bend as Frame
import ./pending-source-committed-frame.bend as Pending
import ./setter-committed-frame.bend as Setter

def queue(+w: R.World, +id: Nat, +lane: Nat) -> R.World:
  B.choose(~R.World, Nat.is_ne(lane, 0n),
    _ => B.choose(~R.World, W.userQueue(R.Node.kind(B.node(w, id))),
      _ => B.store_transaction(w, lane, R.Transaction.with_userQueue(B.transaction(w, lane), B.append(R.QueueEntry, R.Transaction.userQueue(B.transaction(w, lane)), [R.NodeRun{id}]))),
      _ => B.store_transaction(w, lane, R.Transaction.with_renderQueue(B.transaction(w, lane), B.append(Nat, R.Transaction.renderQueue(B.transaction(w, lane)), [id])))),
    _ => B.choose(~R.World, W.userQueue(R.Node.kind(B.node(w, id))),
      _ => R.World.with_userQueue(w, B.append(R.QueueEntry, R.World.userQueue(w), [R.NodeRun{id}])),
      _ => R.World.with_renderQueue(w, B.append(Nat, R.World.renderQueue(w), [id]))))

def queueFrame(+w: R.World, +id: Nat, +lane: Nat) ->
  {Frame.observe(queue(w, id, lane)) == Frame.observe(w) : Frame.View}:
  +userRecord = R.Transaction.with_userQueue(B.transaction(w, lane), B.append(R.QueueEntry, R.Transaction.userQueue(B.transaction(w, lane)), [R.NodeRun{id}]))
  +renderRecord = R.Transaction.with_renderQueue(B.transaction(w, lane), B.append(Nat, R.Transaction.renderQueue(B.transaction(w, lane)), [id]))
  +userQueue = B.append(R.QueueEntry, R.World.userQueue(w), [R.NodeRun{id}])
  +renderQueue = B.append(Nat, R.World.renderQueue(w), [id])
  Frame.choice(Nat.is_ne(lane, 0n), w,
    B.choose(~R.World, W.userQueue(R.Node.kind(B.node(w, id))), _ => B.store_transaction(w, lane, userRecord), _ => B.store_transaction(w, lane, renderRecord)),
    B.choose(~R.World, W.userQueue(R.Node.kind(B.node(w, id))), _ => R.World.with_userQueue(w, userQueue), _ => R.World.with_renderQueue(w, renderQueue)),
    Frame.choice(W.userQueue(R.Node.kind(B.node(w, id))), w, B.store_transaction(w, lane, userRecord), B.store_transaction(w, lane, renderRecord), Frame.storeTransaction(w, lane, userRecord), Frame.storeTransaction(w, lane, renderRecord)),
    Frame.choice(W.userQueue(R.Node.kind(B.node(w, id))), w, R.World.with_userQueue(w, userQueue), R.World.with_renderQueue(w, renderQueue), Frame.worldUserQueue(w, userQueue), Frame.worldRenderQueue(w, renderQueue)))

def enqueue(+w: R.World, +id: Nat) ->
  {Frame.observe(W.enqueue(w, id)) == Frame.observe(w) : Frame.View}:
  +next = queue(w, id, R.World.passLane(w))
  Frame.choice(B.effect(R.Node.kind(B.node(w, id))), w, B.schedule(next), B.schedule(w), Frame.compose(w, next, B.schedule(next), Frame.schedule(next), queueFrame(w, id, R.World.passLane(w))), Frame.schedule(w))

def rethrowSlot(+w: R.World, error: R.Slot) ->
  {Frame.observe(Cleanup.rethrowSlot(w, True{}, error)) == Frame.observe(w) : Frame.View}:
  match error:
    case R.Empty{}: {==}
    case R.Present{cause}: {==}

def cleanupDrop(+w: R.World) ->
  {Frame.observe(Cleanup.rethrowCleanupError(w, True{})) == Frame.observe(w) : Frame.View}:
  +next = R.World.with_cleanupError(w, R.Empty{})
  Frame.compose(w, next, Cleanup.rethrowCleanupError(w, True{}), rethrowSlot(next, R.World.cleanupError(w)), Frame.worldCleanupError(w, R.Empty{}))

def report(+w: R.World, +kind: U32, +cause: R.Slot) ->
  {Frame.observe(B.report(w, kind, cause)) == Frame.observe(w) : Frame.View}:
  Frame.worldReports(w, B.append(R.Report, R.World.reports(w), [R.RuntimeReport{kind, cause}]))

def halt(+w: R.World, +cause: R.Value) ->
  {Frame.observe(S.haltReactivity(w, cause)) == Frame.observe(w) : Frame.View}:
  +halted = R.World.with_halted(w, True{})
  +clean = Cleanup.rethrowCleanupError(halted, True{})
  +slot = B.choose(~R.Slot, B.equal(cause, R.Undefined{}), _ => R.Empty{}, _ => R.Present{cause})
  Frame.choice(R.World.halted(w), w, w, B.report(clean, 0, slot), {==},
    Frame.compose(w, halted, B.report(clean, 0, slot), Frame.compose(halted, clean, B.report(clean, 0, slot), report(clean, 0, slot), cleanupDrop(halted)), Frame.worldHalted(w, True{})))

def escalate(+w: R.World, +id: Nat, +cause: R.Value) ->
  {Frame.observe(S.escalate(w, id, cause)) == Frame.observe(w) : Frame.View}:
  +next = S.haltReactivity(w, cause)
  Frame.compose(w, next, S.escalate(w, id, cause), Frame.worldFault(next, R.CallbackThrown{cause}), halt(w, cause))

def notify(+w: R.World, +id: Nat) ->
  {Frame.observe(S.notifyEffectStatus(w, id)) == Frame.observe(w) : Frame.View}:
  +node = B.node(w, id)
  +status = R.Node.status(node)
  +error = R.NodeExtension.error(B.extension(w, id))
  +modified = B.store_node(w, id, R.Node.with_modified(node, True{}))
  +user = B.choose(~R.World, B.has(R.Node.status(node), K.STATUS_ERROR()), _ => W.enqueue(modified, id), _ => w)
  +actualError = B.choose(~R.World, W.is_user(R.Node.kind(node)), _ => user, _ => S.escalate(w, id, S.unwrapStatusError(error)))
  +pending = B.choose(~R.World, Nat.is_eq(R.World.passLane(w), 0n), _ => X.joinFuture(w, 0n), _ => w)
  +ordinary = B.choose(~R.World, Bool.and(X.isRender(R.Node.kind(node)), B.has(status, K.STATUS_PENDING())), _ => pending, _ => w)
  Frame.choice(B.has(status, K.STATUS_ERROR()), w, actualError, ordinary,
    Frame.choice(W.is_user(R.Node.kind(node)), w, user, S.escalate(w, id, S.unwrapStatusError(error)),
      Frame.choice(B.has(R.Node.status(node), K.STATUS_ERROR()), w, W.enqueue(modified, id), w, Frame.compose(w, modified, W.enqueue(modified, id), enqueue(modified, id), Frame.modified(w, id, True{})), {==}), escalate(w, id, S.unwrapStatusError(error))),
    Frame.choice(Bool.and(X.isRender(R.Node.kind(node)), B.has(status, K.STATUS_PENDING())), w, pending, w, Frame.choice(Nat.is_eq(R.World.passLane(w), 0n), w, X.joinFuture(w, 0n), w, Setter.joinFuture(w, 0n), {==}), {==}))

def clear(+w: R.World, +id: Nat, +clearUninitialized: Bool) ->
  {Frame.observe(S.clearStatus(w, id, clearUninitialized)) == Frame.observe(w) : Frame.View}:
  +sources = P.clearPendingSources(w, id)
  +blockedRecord = R.NodeExtension.with_blocked(B.extension(sources, id), R.Present{R.Boolean{False{}}})
  +blocked = B.choose(~R.World, B.truth(B.selected(R.NodeExtension.blocked(B.extension(sources, id)), R.Undefined{})), _ => B.store_extension(sources, id, blockedRecord), _ => sources)
  +flags = B.choose(~U32, clearUninitialized, _ => 0, _ => U32.and(R.Node.status(B.node(blocked, id)), K.STATUS_UNINITIALIZED()))
  +status = B.store_node(blocked, id, R.Node.with_status(B.node(blocked, id), flags))
  +errorRecord = R.NodeExtension.with_error(B.extension(status, id), R.Null{})
  +error = B.choose(~R.World, B.truth(R.NodeExtension.error(B.extension(status, id))), _ => B.store_extension(status, id, errorRecord), _ => status)
  +result = B.choose(~R.World, B.effect(R.Node.kind(B.node(error, id))), _ => S.notifyEffectStatus(error, id), _ => error)
  Frame.compose(w, sources, result,
    Frame.compose(sources, blocked, result,
      Frame.compose(blocked, status, result,
        Frame.compose(status, error, result,
          Frame.choice(B.effect(R.Node.kind(B.node(error, id))), error, S.notifyEffectStatus(error, id), error, notify(error, id), {==}),
          Frame.choice(B.truth(R.NodeExtension.error(B.extension(status, id))), status, B.store_extension(status, id, errorRecord), status, Frame.storeExtension(status, id, errorRecord), {==})), Frame.status(blocked, id, flags)),
      Frame.choice(B.truth(B.selected(R.NodeExtension.blocked(B.extension(sources, id)), R.Undefined{})), sources, B.store_extension(sources, id, blockedRecord), sources, Frame.storeExtension(sources, id, blockedRecord), {==})), Pending.clear(w, id))
