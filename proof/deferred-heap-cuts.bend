# Algebraic heap call/field boundaries for proof transport only. The runtime
# remains heap.bend; the shape equations check these exact source segments.
import Base
import ../runtime/heap.bend as H
import ../representation/base.bend as B
import ../representation/records.bend as R

def height(+w: R.World, id: Nat) -> Nat:
  +n = B.node(w, id)
  +parent = B.parentComputed(w, R.Node.parent(n))
  +parentHeight = R.Node.height(B.node(w, parent))
  B.choose(~Nat, Bool.and(Nat.is_ne(parent, 0n), B.computed(R.Node.kind(B.node(w, parent)))), _ => Nat.max(R.Node.height(n), 1n+parentHeight), _ => R.Node.height(n))

def heightPrefix(+w: R.World, +id: Nat) -> R.World:
  B.store_node(w, id, R.Node.with_height(B.node(w, id), height(w, id)))

def actualTail(+w: R.World, +id: Nat, +height: Nat) -> R.World:
  +head = B.bucket(w, height)
  +w = B.choose(~R.World, Nat.is_eq(head, 0n), _ => B.store_bucket(w, height, id),
    _ =>
      +tail = R.Node.prevHeap(B.node(w, head))
      +w = B.store_node(w, tail, R.Node.with_nextHeap(B.node(w, tail), id))
      +w = B.store_node(w, id, R.Node.with_prevHeap(B.node(w, id), tail))
      B.store_node(w, head, R.Node.with_prevHeap(B.node(w, head), id)))
  R.World.with_maximum(w, Nat.max(height, R.World.maximum(w)))

def actualShape(+w: R.World, +id: Nat) -> {H.actualInsertIntoHeap(w, id) == actualTail(heightPrefix(w, id), id, height(w, id)) : R.World}:
  match w:
    case R.World{+w_nodes, +w_links, +w_buckets, +w_minimum, +w_maximum, +w_marked, +w_pendingNodes, +w_trims, +w_renderQueue, +w_userQueue, +w_context, +w_tracking, +w_running, +w_scheduled, +w_clock, +w_epoch, +w_tree, +w_events, +w_fault, +w_unflushedStaged, +w_promotedWrites, +w_extensions, +w_cleanupPrograms, +w_dormantNodes, +w_errorSerial, +w_halted, +w_haltNotified, +w_reports, +w_callbackEffect, +w_txArena, +w_transactions, +w_flushTransaction, +w_passTx, +w_passLane, +w_judge, +w_deferredZombies, +w_question, +w_pendingSets, +w_asyncObjects, +w_asyncObservers, +w_hostJobs, +w_syncDepth, +w_streamPlans, +w_iterators, +w_streams, +w_iteratorEvents, +w_awaiters, +w_truthReadHook, +w_truthConfirmedHook, +w_questions, +w_abortInputs, +w_contextKeys, +w_contextRecords, +w_deferredReleases, +w_releaseLists, +w_stale, +w_settledCallbacks, +w_reactions, +w_comparators, +w_actionDepth, +w_actions, +w_actionWaits, +w_arrays, +w_repeats, +w_maps, +w_activeMarks, +w_laneState, +w_verdictState, +w_cleanupError, +w_ambientMarks, +w_deferredArena}:
      {==}

def actualCut(+w: R.World, +id: Nat, +prefix: R.World, +h: Nat, prefixEq: {heightPrefix(w, id) == prefix : R.World}, heightEq: {height(w, id) == h : Nat}) -> {H.actualInsertIntoHeap(w, id) == actualTail(prefix, id, h) : R.World}:
  Equal.trans(R.World, H.actualInsertIntoHeap(w, id), actualTail(heightPrefix(w, id), id, height(w, id)), actualTail(prefix, id, h), actualShape(w, id),
    Equal.trans(R.World, actualTail(heightPrefix(w, id), id, height(w, id)), actualTail(prefix, id, height(w, id)), actualTail(prefix, id, h),
      Equal.cong(R.World, R.World, next => actualTail(next, id, height(w, id)), heightPrefix(w, id), prefix, prefixEq),
      Equal.cong(Nat, R.World, next => actualTail(prefix, id, next), height(w, id), h, heightEq)))

# The source's captured flags and two following calls, without concrete Worlds.
def insertAt(+w: R.World, +id: Nat, +flags: U32) -> R.World:
  B.choose(~R.World, B.has(flags, 12), _ => w,
    _ =>
      +w = B.choose(~R.World, B.has(flags, 1),
        _ => B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(B.clear(flags, 3), 10))),
        _ =>
          +w = B.store_node(w, id, R.Node.with_flags(B.node(w, id), B.set(flags, 8)))
          B.choose(~R.World, R.World.marked(w), _ => H.markNode(w, id, 2), _ => w))
      B.choose(~R.World, B.has(flags, 16), _ => w, _ => H.actualInsertIntoHeap(w, id)))

def insertFlags(+w: R.World, +id: Nat, +flags: U32, same: {R.Node.flags(B.node(w, id)) == flags : U32}) -> {H.insertIntoHeap(w, id) == insertAt(w, id, flags) : R.World}:
  Equal.cong(U32, R.World, next => insertAt(w, id, next), R.Node.flags(B.node(w, id)), flags, same)

def flagPrefix(+w: R.World, +id: Nat) -> R.World:
  B.store_node(w, id, R.Node.with_flags(B.node(w, id), 8))

def markChoice(+w: R.World, +id: Nat, marked: Bool) -> R.World:
  B.choose(~R.World, marked, _ => H.markNode(w, id, 2), _ => w)

def enqueueAt(+w: R.World, +id: Nat, +prefix: R.World, same: {R.World.with_minimum(w, Nat.min(R.World.minimum(w), R.Node.height(B.node(w, id)))) == prefix : R.World}) -> {H.enqueueSub(w, id) == H.insertIntoHeap(prefix, id) : R.World}:
  Equal.cong(R.World, R.World, next => H.insertIntoHeap(next, id), R.World.with_minimum(w, Nat.min(R.World.minimum(w), R.Node.height(B.node(w, id)))), prefix, same)
