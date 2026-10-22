# General existing-slot lenses for the actual persistent arenas.
# No reactivity, scheduler or callback implementation is supplied here.
import Base
import ../representation/base.bend as B
import ../representation/records.bend as R

def getPrefix(-A: Data, +prefix: List<&2, A>, +value: A, +suffix: List<&2, A>, +fallback: A) ->
  {B.get(A, B.append(A, prefix, value <> suffix), B.length(A, prefix), fallback) == value : A}:
  match prefix:
    case Nil{}:
      {==}
    case head <> tail:
      getPrefix(A, tail, value, suffix, fallback)

def setPrefix(-A: Data, +prefix: List<&2, A>, +old: A, +suffix: List<&2, A>, +value: A) ->
  {List.set(&2, A, B.append(A, prefix, old <> suffix), B.length(A, prefix), value)
    == B.append(A, prefix, value <> suffix) : List<&2, A>}:
  match prefix:
    case Nil{}:
      {==}
    case +head <> +tail:
      Equal.cong(List<&2, A>, List<&2, A>, xs => head <> xs,
        List.set(&2, A, B.append(A, tail, old <> suffix), B.length(A, tail), value),
        B.append(A, tail, value <> suffix), setPrefix(A, tail, old, suffix, value))

def arena(+w: R.World, prefix: List<&2, R.Node>, node: R.Node, suffix: List<&2, R.Node>) -> R.World:
  R.World.with_nodes(w, B.append(R.Node, prefix, node <> suffix))

def peek(+w: R.World, +prefix: List<&2, R.Node>, +node: R.Node, +suffix: List<&2, R.Node>) ->
  {B.node(arena(w, prefix, node, suffix), B.length(R.Node, prefix)) == node : R.Node}:
  match w:
    case R.World{nodes, links, buckets, minimum, maximum, marked, pendingNodes, trims, renderQueue, userQueue, context, tracking, running, scheduled, clock, epoch, tree, events, fault, unflushedStaged, promotedWrites, extensions, cleanupPrograms, dormantNodes, errorSerial, halted, haltNotified, reports, callbackEffect, txArena, transactions, flushTransaction, passTx, passLane, judge, deferredZombies, question, pendingSets, asyncObjects, asyncObservers, hostJobs, syncDepth, streamPlans, iterators, streams, iteratorEvents, awaiters, truthReadHook, truthConfirmedHook, questions, abortInputs, contextKeys, contextRecords, deferredReleases, releaseLists, stale, settledCallbacks, reactions, comparators, actionDepth, actions, actionWaits, arrays, repeats, maps, activeMarks, laneState}:
      getPrefix(R.Node, prefix, node, suffix, B.blank_node())

def store(+w: R.World, +prefix: List<&2, R.Node>, +old: R.Node, +suffix: List<&2, R.Node>, +node: R.Node) ->
  {B.store_node(arena(w, prefix, old, suffix), B.length(R.Node, prefix), node) == arena(w, prefix, node, suffix) : R.World}:
  match w:
    case R.World{nodes, links, buckets, minimum, maximum, marked, pendingNodes, trims, renderQueue, userQueue, context, tracking, running, scheduled, clock, epoch, tree, events, fault, unflushedStaged, promotedWrites, extensions, cleanupPrograms, dormantNodes, errorSerial, halted, haltNotified, reports, callbackEffect, txArena, transactions, flushTransaction, passTx, passLane, judge, deferredZombies, question, pendingSets, asyncObjects, asyncObservers, hostJobs, syncDepth, streamPlans, iterators, streams, iteratorEvents, awaiters, truthReadHook, truthConfirmedHook, questions, abortInputs, contextKeys, contextRecords, deferredReleases, releaseLists, stale, settledCallbacks, reactions, comparators, actionDepth, actions, actionWaits, arrays, repeats, maps, activeMarks, laneState}:
      Equal.cong(List<&2, R.Node>, R.World,
        xs => R.World.with_nodes(R.World{nodes, links, buckets, minimum, maximum, marked, pendingNodes, trims, renderQueue, userQueue, context, tracking, running, scheduled, clock, epoch, tree, events, fault, unflushedStaged, promotedWrites, extensions, cleanupPrograms, dormantNodes, errorSerial, halted, haltNotified, reports, callbackEffect, txArena, transactions, flushTransaction, passTx, passLane, judge, deferredZombies, question, pendingSets, asyncObjects, asyncObservers, hostJobs, syncDepth, streamPlans, iterators, streams, iteratorEvents, awaiters, truthReadHook, truthConfirmedHook, questions, abortInputs, contextKeys, contextRecords, deferredReleases, releaseLists, stale, settledCallbacks, reactions, comparators, actionDepth, actions, actionWaits, arrays, repeats, maps, activeMarks, laneState}, xs),
        List.set(&2, R.Node, B.append(R.Node, prefix, old <> suffix), B.length(R.Node, prefix), node),
        B.append(R.Node, prefix, node <> suffix), setPrefix(R.Node, prefix, old, suffix, node))
