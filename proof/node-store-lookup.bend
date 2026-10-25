# Actual existing-slot node/link writes. Membership is explicit; an out-of-range
# List.set is not an allocation or a successful write of the requested value.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./list-update-lookup.bend as Lookup

def lengthSet(-A: Data, +xs: List<&2, A>, +id: Nat, +value: A) ->
  {B.length(A, List.set(&2, A, xs, id, value)) == B.length(A, xs) : Nat}:
  match xs id:
    case Nil{} n: {==}
    case head <> tail 0n: {==}
    case head <> +tail 1n+p:
      Equal.cong(Nat, Nat, value => 1n+value, B.length(A, List.set(&2, A, tail, p, value)), B.length(A, tail), lengthSet(A, tail, p, value))

def setSame(-A: Data, +xs: List<&2, A>, +id: Nat, +value: A, +fallback: A, room: {Nat.is_lt(id, B.length(A, xs)) == True{} : Bool}) ->
  {B.get(A, List.set(&2, A, xs, id, value), id, fallback) == value : A}:
  match xs id:
    case Nil{} 0n: Empty.absurd({B.get(A, List.set(&2, A, [], 0n, value), 0n, fallback) == value : A}, Lookup.impossible(Equal.sym(Bool, False{}, True{}, room)))
    case Nil{} 1n+p: Empty.absurd({B.get(A, List.set(&2, A, [], 1n+p, value), 1n+p, fallback) == value : A}, Lookup.impossible(Equal.sym(Bool, False{}, True{}, room)))
    case head <> tail 0n: {==}
    case head <> tail 1n+p: setSame(A, tail, p, value, fallback, room)


def nodeSame(+w: R.World, +id: Nat, +value: R.Node, room: {Nat.is_lt(id, B.length(R.Node, R.World.nodes(w))) == True{} : Bool}) ->
  {B.node(B.store_node(w, id, value), id) == value : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      setSame(R.Node, nodes, id, value, B.blank_node(), room)


def nodeOther(+w: R.World, +write: Nat, +read: Nat, +value: R.Node, different: {Nat.is_eq(read, write) == False{} : Bool}) ->
  {B.node(B.store_node(w, write, value), read) == B.node(w, read) : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Lookup.setOther(R.Node, nodes, write, read, B.blank_node(), value, different)


def nodeLength(+w: R.World, +id: Nat, +value: R.Node) ->
  {B.length(R.Node, R.World.nodes(B.store_node(w, id, value))) == B.length(R.Node, R.World.nodes(w)) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      lengthSet(R.Node, nodes, id, value)


def linkSame(+w: R.World, +id: Nat, +value: R.Link, room: {Nat.is_lt(id, B.length(R.Link, R.World.links(w))) == True{} : Bool}) ->
  {B.link(B.store_link(w, id, value), id) == value : R.Link}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      setSame(R.Link, links, id, value, B.blank_link(), room)


def linkOther(+w: R.World, +write: Nat, +read: Nat, +value: R.Link, different: {Nat.is_eq(read, write) == False{} : Bool}) ->
  {B.link(B.store_link(w, write, value), read) == B.link(w, read) : R.Link}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Lookup.setOther(R.Link, links, write, read, B.blank_link(), value, different)
