# Extension-pointer observation for graph writes. This is separate from the
# pending topology frame, which intentionally permits extension allocation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def pointers(nodes: List<&2, R.Node>) -> List<&2, Nat>:
  match nodes:
    case Nil{}: []
    case node <> tail: R.Node.x(node) <> pointers(tail)

def observe(w: R.World) -> List<&2, Nat>:
  pointers(R.World.nodes(w))

def setPointers(+nodes: List<&2, R.Node>, +id: Nat, +next: R.Node, same: {R.Node.x(next) == R.Node.x(B.get(R.Node, nodes, id, B.blank_node())) : Nat}) ->
  {pointers(List.set(&2, R.Node, nodes, id, next)) == pointers(nodes) : List<&2, Nat>}:
  match nodes id:
    case Nil{} n: {==}
    case head <> +tail 0n: Equal.cong(Nat, List<&2, Nat>, value => value <> pointers(tail), R.Node.x(next), R.Node.x(head), same)
    case +head <> +tail 1n+p: Equal.cong(List<&2, Nat>, List<&2, Nat>, values => R.Node.x(head) <> values, pointers(List.set(&2, R.Node, tail, p, next)), pointers(tail), setPointers(tail, p, next, same))

def store(+w: R.World, +id: Nat, +next: R.Node, same: {R.Node.x(next) == R.Node.x(B.node(w, id)) : Nat}) ->
  {observe(B.store_node(w, id, next)) == observe(w) : List<&2, Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      setPointers(nodes, id, next, same)


def readPointers(+nodes: List<&2, R.Node>, +id: Nat) ->
  {B.get(Nat, pointers(nodes), id, 0n) == R.Node.x(B.get(R.Node, nodes, id, B.blank_node())) : Nat}:
  match nodes id:
    case Nil{} n: {==}
    case head <> tail 0n: {==}
    case head <> tail 1n+p: readPointers(tail, p)

def read(+w: R.World, +next: R.World, +id: Nat, same: {observe(next) == observe(w) : List<&2, Nat>}) ->
  {R.Node.x(B.node(next, id)) == R.Node.x(B.node(w, id)) : Nat}:
  Equal.trans(Nat, R.Node.x(B.node(next, id)), B.get(Nat, observe(next), id, 0n), R.Node.x(B.node(w, id)), Equal.sym(Nat, B.get(Nat, observe(next), id, 0n), R.Node.x(B.node(next, id)), readPointers(R.World.nodes(next), id)), Equal.trans(Nat, B.get(Nat, observe(next), id, 0n), B.get(Nat, observe(w), id, 0n), R.Node.x(B.node(w, id)), Equal.cong(List<&2, Nat>, Nat, values => B.get(Nat, values, id, 0n), observe(next), observe(w), same), readPointers(R.World.nodes(w), id)))

def compose(+w: R.World, +next: R.World, +last: R.World, second: {observe(last) == observe(next) : List<&2, Nat>}, first: {observe(next) == observe(w) : List<&2, Nat>}) ->
  {observe(last) == observe(w) : List<&2, Nat>}:
  Equal.trans(List<&2, Nat>, observe(last), observe(next), observe(w), second, first)

def worldLinks(+w: R.World, next: List<&2, R.Link>) -> {observe(R.World.with_links(w, next)) == observe(w) : List<&2, Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def bump(+w: R.World) -> {observe(B.bump(w)) == observe(w) : List<&2, Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


type PointerWrite is Data:
  DependencyTail{}
  SubscriberTail{}
  DependencyHead{}
  SubscriberHead{}

def changed(node: R.Node, value: Nat, field: PointerWrite) -> R.Node:
  match field:
    case DependencyTail{}: R.Node.with_depsTail(node, value)
    case SubscriberTail{}: R.Node.with_subsTail(node, value)
    case DependencyHead{}: R.Node.with_deps(node, value)
    case SubscriberHead{}: R.Node.with_subs(node, value)


def changedX(+node: R.Node, +value: Nat, +field: PointerWrite) -> {R.Node.x(changed(node, value, field)) == R.Node.x(node) : Nat}:
  match node:
    case R.Node{kind, value, pending, equals, config, flags, status, time, notified, deps, depsTail, depGen, subs, subsTail, height, nextHeap, prevHeap, parent, firstChild, nextSibling, prevSibling, expr, modified, prevValue, target, loading, x, parentComputed, scope, childCount, disposal, cleanup, effectProgram, returnedCleanup, errorProgram}:
      match field:
        case DependencyTail{}: {==}
        case SubscriberTail{}: {==}
        case DependencyHead{}: {==}
        case SubscriberHead{}: {==}

def write(+w: R.World, +id: Nat, +value: Nat, +field: PointerWrite) ->
  {observe(B.store_node(w, id, changed(B.node(w, id), value, field))) == observe(w) : List<&2, Nat>}:
  store(w, id, changed(B.node(w, id), value, field), changedX(B.node(w, id), value, field))
