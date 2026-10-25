# Pending-source/error bookkeeping preserves committed storage/tree/trace. No
# owner release/callback traversal is hidden in these local source operations.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/extension.bend as E
import ./subscriber-topology-frame.bend as Frame

def ext(+w: R.World, +id: Nat) ->
  {Frame.observe(E.ext(w, id)) == Frame.observe(w) : Frame.View}:
  +slot = B.length(R.NodeExtension, R.World.extensions(w))
  +extensions = B.append(R.NodeExtension, R.World.extensions(w), [B.blank_extension()])
  +next = R.World.with_extensions(w, extensions)
  +stored = B.store_node(next, id, R.Node.with_x(B.node(next, id), slot))
  Frame.choice(Nat.is_ne(R.Node.x(B.node(w, id)), 0n), w, w, stored, {==},
    Frame.compose(w, next, stored, Frame.x(next, id, slot), Frame.worldExtensions(w, extensions)))

def clear(+w: R.World, +id: Nat) ->
  {Frame.observe(P.clearPendingSources(w, id)) == Frame.observe(w) : Frame.View}:
  +record = R.NodeExtension.with_pendingSources(B.extension(w, id), 0n)
  Frame.choice(Nat.is_ne(R.Node.x(B.node(w, id)), 0n), w, B.store_extension(w, id, record), w, Frame.storeExtension(w, id, record), {==})

def removeTail(+w: R.World, +id: Nat, +source: Nat) -> R.World:
  +set = R.NodeExtension.pendingSources(B.extension(w, id))
  +items = P.removeSlot(B.pendingSlots(w, set), source)
  +w = B.store_pendingSet(w, set, items)
  B.choose(~R.World, List.is_empty(&2, Nat, B.liveIds(items)), _ => B.store_extension(w, id, R.NodeExtension.with_pendingSources(B.extension(w, id), 0n)), _ => w)

def removeTailFrame(+w: R.World, +id: Nat, +source: Nat) ->
  {Frame.observe(removeTail(w, id, source)) == Frame.observe(w) : Frame.View}:
  +set = R.NodeExtension.pendingSources(B.extension(w, id))
  +items = P.removeSlot(B.pendingSlots(w, set), source)
  +next = B.store_pendingSet(w, set, items)
  +record = R.NodeExtension.with_pendingSources(B.extension(next, id), 0n)
  Frame.compose(w, next, removeTail(w, id, source), Frame.choice(List.is_empty(&2, Nat, B.liveIds(items)), next, B.store_extension(next, id, record), next, Frame.storeExtension(next, id, record), {==}), Frame.storePendingSet(w, set, items))

def remove(+w: R.World, +id: Nat, +source: Nat) ->
  {Frame.observe(B.first(R.World, Bool, P.removePendingSource(w, id, source))) == Frame.observe(w) : Frame.View}:
  Frame.firstBoolChoice( P.hasSource(w, id, source), w, B.Bundle{removeTail(w, id, source), True{}}, B.Bundle{w, False{}}, removeTailFrame(w, id, source), {==})

def notReady(+w: R.World, +source: Nat) ->
  {Frame.observe(B.first(R.World, R.Value, P.notReadyError(w, source))) == Frame.observe(w) : Frame.View}:
  Frame.worldErrorSerial(w, Nat.add(1n, R.World.errorSerial(w)))

def preservedErrorTail(+w: R.World, +id: Nat, +source: Nat) -> R.World:
  +pair = P.notReadyError(w, source)
  +w = E.ext(B.first(R.World, R.Value, pair), id)
  B.store_extension(w, id, R.NodeExtension.with_error(B.extension(w, id), B.second(R.World, R.Value, pair)))

def preservedErrorTailFrame(+w: R.World, +id: Nat, +source: Nat) ->
  {Frame.observe(preservedErrorTail(w, id, source)) == Frame.observe(w) : Frame.View}:
  +pair = P.notReadyError(w, source)
  +first = B.first(R.World, R.Value, pair)
  +second = E.ext(first, id)
  +record = R.NodeExtension.with_error(B.extension(second, id), B.second(R.World, R.Value, pair))
  Frame.compose(w, first, preservedErrorTail(w, id, source), Frame.compose(first, second, preservedErrorTail(w, id, source), Frame.storeExtension(second, id, record), ext(first, id)), notReady(w, source))

def preserveError(+w: R.World, +id: Nat, +source: Nat, +current: R.Value) ->
  {Frame.observe(P.preserveOrCreate(w, id, source, current)) == Frame.observe(w) : Frame.View}:
  Frame.choice(Bool.and(P.isNotReady(current), Nat.is_eq(P.notReadySource(current), source)), w, w, preservedErrorTail(w, id, source), {==}, preservedErrorTailFrame(w, id, source))

def setError(+w: R.World, +id: Nat, +source: Nat, +error: R.Value) ->
  {Frame.observe(P.setPendingError(w, id, source, error)) == Frame.observe(w) : Frame.View}:
  +nullRecord = R.NodeExtension.with_error(B.extension(w, id), R.Null{})
  +clear = B.choose(~R.World, Nat.is_ne(R.Node.x(B.node(w, id)), 0n), _ => B.store_extension(w, id, nullRecord), _ => w)
  +next = E.ext(w, id)
  +errorRecord = R.NodeExtension.with_error(B.extension(next, id), error)
  +preserved = B.choose(~R.World, Bool.and(P.isNotReady(error), Nat.is_eq(P.notReadySource(error), source)), _ => B.store_extension(next, id, errorRecord), _ => P.preserveOrCreate(w, id, source, R.NodeExtension.error(B.extension(w, id))))
  Frame.choice(Nat.is_eq(source, 0n), w, clear, preserved,
    Frame.choice(Nat.is_ne(R.Node.x(B.node(w, id)), 0n), w, B.store_extension(w, id, nullRecord), w, Frame.storeExtension(w, id, nullRecord), {==}),
    Frame.choice(Bool.and(P.isNotReady(error), Nat.is_eq(P.notReadySource(error), source)), w, B.store_extension(next, id, errorRecord), P.preserveOrCreate(w, id, source, R.NodeExtension.error(B.extension(w, id))),
      Frame.compose(w, next, B.store_extension(next, id, errorRecord), Frame.storeExtension(next, id, errorRecord), ext(w, id)), preserveError(w, id, source, R.NodeExtension.error(B.extension(w, id)))))
