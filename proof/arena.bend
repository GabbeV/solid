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
    case R.World{nodes, links, buckets, minimum, maximum, marked, pendingNodes, trims, renderQueue, userQueue, context, tracking, running, scheduled, clock, epoch, tree, events, fault, unflushedStaged, promotedWrites, extensions, cleanupPrograms, dormantNodes, errorSerial, halted, haltNotified, reports, callbackEffect, txArena, transactions, flushTransaction, passTx, passLane, judge, deferredZombies, question, pendingSets, asyncObjects, asyncObservers, hostJobs, syncDepth, streamPlans, iterators, streams, iteratorEvents, awaiters, truthReadHook, truthConfirmedHook, questions, abortInputs, contextKeys, contextRecords, deferredReleases, releaseLists, stale, settledCallbacks, reactions, comparators, actionDepth, actions, actionWaits, arrays, repeats, maps, activeMarks, laneState, verdictState, cleanupError, +w_ambientMarks, +w_deferredArena}:
      getPrefix(R.Node, prefix, node, suffix, B.blank_node())

def store(+w: R.World, +prefix: List<&2, R.Node>, +old: R.Node, +suffix: List<&2, R.Node>, +node: R.Node) ->
  {B.store_node(arena(w, prefix, old, suffix), B.length(R.Node, prefix), node) == arena(w, prefix, node, suffix) : R.World}:
  match w:
    case R.World{nodes, links, buckets, minimum, maximum, marked, pendingNodes, trims, renderQueue, userQueue, context, tracking, running, scheduled, clock, epoch, tree, events, fault, unflushedStaged, promotedWrites, extensions, cleanupPrograms, dormantNodes, errorSerial, halted, haltNotified, reports, callbackEffect, txArena, transactions, flushTransaction, passTx, passLane, judge, deferredZombies, question, pendingSets, asyncObjects, asyncObservers, hostJobs, syncDepth, streamPlans, iterators, streams, iteratorEvents, awaiters, truthReadHook, truthConfirmedHook, questions, abortInputs, contextKeys, contextRecords, deferredReleases, releaseLists, stale, settledCallbacks, reactions, comparators, actionDepth, actions, actionWaits, arrays, repeats, maps, activeMarks, laneState, verdictState, cleanupError, +w_ambientMarks, +w_deferredArena}:
      Equal.cong(List<&2, R.Node>, R.World,
        xs => R.World.with_nodes(R.World{nodes, links, buckets, minimum, maximum, marked, pendingNodes, trims, renderQueue, userQueue, context, tracking, running, scheduled, clock, epoch, tree, events, fault, unflushedStaged, promotedWrites, extensions, cleanupPrograms, dormantNodes, errorSerial, halted, haltNotified, reports, callbackEffect, txArena, transactions, flushTransaction, passTx, passLane, judge, deferredZombies, question, pendingSets, asyncObjects, asyncObservers, hostJobs, syncDepth, streamPlans, iterators, streams, iteratorEvents, awaiters, truthReadHook, truthConfirmedHook, questions, abortInputs, contextKeys, contextRecords, deferredReleases, releaseLists, stale, settledCallbacks, reactions, comparators, actionDepth, actions, actionWaits, arrays, repeats, maps, activeMarks, laneState, verdictState, cleanupError, w_ambientMarks, w_deferredArena}, xs),
        List.set(&2, R.Node, B.append(R.Node, prefix, old <> suffix), B.length(R.Node, prefix), node),
        B.append(R.Node, prefix, node <> suffix), setPrefix(R.Node, prefix, old, suffix, node))

# Structural append facts used to connect repeated actual allocations to
# adjacent allocated slots; no numeric size is guessed.
def appendSingletons(-A: Data, +xs: List<&2, A>, +first: A, +second: A) ->
  {B.append(A, B.append(A, xs, [first]), [second]) == B.append(A, xs, [first, second]) : List<&2, A>}:
  match xs:
    case Nil{}: {==}
    case +head <> +tail:
      Equal.cong(List<&2, A>, List<&2, A>, rest => head <> rest,
        B.append(A, B.append(A, tail, [first]), [second]), B.append(A, tail, [first, second]), appendSingletons(A, tail, first, second))

def appendLength(-A: Data, +xs: List<&2, A>, +ys: List<&2, A>) ->
  {B.length(A, B.append(A, xs, ys)) == Nat.add(B.length(A, xs), B.length(A, ys)) : Nat}:
  match xs:
    case Nil{}: {==}
    case head <> +tail:
      Equal.cong(Nat, Nat, size => 1n+size, B.length(A, B.append(A, tail, ys)), Nat.add(B.length(A, tail), B.length(A, ys)), appendLength(A, tail, ys))

def firstOfAppendedPair(-A: Data, +xs: List<&2, A>, +first: A, +second: A, +fallback: A) ->
  {B.get(A, B.append(A, B.append(A, xs, [first]), [second]), B.length(A, xs), fallback) == first : A}:
  Equal.trans(A, B.get(A, B.append(A, B.append(A, xs, [first]), [second]), B.length(A, xs), fallback), B.get(A, B.append(A, xs, [first, second]), B.length(A, xs), fallback), first,
    Equal.cong(List<&2, A>, A, values => B.get(A, values, B.length(A, xs), fallback), B.append(A, B.append(A, xs, [first]), [second]), B.append(A, xs, [first, second]), appendSingletons(A, xs, first, second)), getPrefix(A, xs, first, [second], fallback))
