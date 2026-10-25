# Auxiliary writes/extension allocation preserve graph storage size and health.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/extension.bend as E
import ./graph-allocation-properties.bend as Storage
import ./pending-add-frame.bend as Generic

def worldExtensions(+w: R.World, next: List<&2, R.NodeExtension>) -> {Storage.storage(R.World.with_extensions(w, next)) == Storage.storage(w) : Storage.Storage}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def worldPendingSets(+w: R.World, next: List<&2, List<&2, Nat>>) -> {Storage.storage(R.World.with_pendingSets(w, next)) == Storage.storage(w) : Storage.Storage}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def storeExtension(+w: R.World, +id: Nat, +record: R.NodeExtension) -> {Storage.storage(B.store_extension(w, id, record)) == Storage.storage(w) : Storage.Storage}:
  worldExtensions(w, List.set(&2, R.NodeExtension, R.World.extensions(w), R.Node.x(B.node(w, id)), record))

def storePendingSet(+w: R.World, +set: Nat, +items: List<&2, Nat>) -> {Storage.storage(B.store_pendingSet(w, set, items)) == Storage.storage(w) : Storage.Storage}:
  worldPendingSets(w, List.set(&2, List<&2, Nat>, R.World.pendingSets(w), set, items))

def ext(+w: R.World, +id: Nat) -> {Storage.storage(E.ext(w, id)) == Storage.storage(w) : Storage.Storage}:
  +slot = B.length(R.NodeExtension, R.World.extensions(w))
  +extensions = B.append(R.NodeExtension, R.World.extensions(w), [B.blank_extension()])
  +next = R.World.with_extensions(w, extensions)
  +stored = B.store_node(next, id, R.Node.with_x(B.node(next, id), slot))
  Generic.choice(Storage.Storage, state => Storage.storage(state), Nat.is_ne(R.Node.x(B.node(w, id)), 0n), w, w, stored, {==}, Storage.compose(w, next, stored, Storage.nodeStorage(next, id, R.Node.with_x(B.node(next, id), slot)), worldExtensions(w, extensions)))
