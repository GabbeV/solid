# Actual constructor append and existing-slot membership. Prefix lookups and
# fresh slot validity are proved from list structure, not a final node equation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct-state.bend as N
import ./arena.bend as Arena
import ./list-update-lookup.bend as Lookup

def fresh(+w: R.World, +value: R.Node) ->
  {B.node(N.append(w, value), B.length(R.Node, R.World.nodes(w))) == value : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Arena.getPrefix(R.Node, nodes, value, [], B.blank_node())

def count(+w: R.World, +value: R.Node) ->
  {B.length(R.Node, R.World.nodes(N.append(w, value))) == Nat.add(B.length(R.Node, R.World.nodes(w)), 1n) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Arena.appendLength(R.Node, nodes, [value])

def stored(+w: R.World, +old: R.Node, +value: R.Node) ->
  {B.store_node(N.append(w, old), B.length(R.Node, R.World.nodes(w)), value) == N.append(w, value) : R.World}:
  Arena.store(w, R.World.nodes(w), old, [], value)

# Nonempty prefix gives a real nonzero slot. The caller supplies no identity.
def positive(+w: R.World, +first: R.Node, +tail: List<&2, R.Node>, known: {R.World.nodes(w) == first <> tail : List<&2, R.Node>}) ->
  {B.length(R.Node, R.World.nodes(w)) == 1n+B.length(R.Node, tail) : Nat}:
  Equal.cong(List<&2, R.Node>, Nat, xs => B.length(R.Node, xs), R.World.nodes(w), first <> tail, known)

# Existing prefix reads are unchanged by append. An explicit index bound rules
# out interpreting the newly allocated slot as an old blank record.
def oldRead(-A: Data, +xs: List<&2, A>, +id: Nat, +value: A, +fallback: A, room: {Nat.is_lt(id, B.length(A, xs)) == True{} : Bool}) ->
  {B.get(A, B.append(A, xs, [value]), id, fallback) == B.get(A, xs, id, fallback) : A}:
  match xs id:
    case Nil{} 0n:
      Empty.absurd({B.get(A, B.append(A, [], [value]), 0n, fallback) == B.get(A, [], 0n, fallback) : A}, Lookup.impossible(Equal.sym(Bool, False{}, True{}, room)))
    case Nil{} 1n+p:
      Empty.absurd({B.get(A, B.append(A, [], [value]), 1n+p, fallback) == B.get(A, [], 1n+p, fallback) : A}, Lookup.impossible(Equal.sym(Bool, False{}, True{}, room)))
    case head <> tail 0n: {==}
    case head <> tail 1n+p: oldRead(A, tail, p, value, fallback, room)


def oldNode(+w: R.World, +value: R.Node, +read: Nat, room: {Nat.is_lt(read, B.length(R.Node, R.World.nodes(w))) == True{} : Bool}) ->
  {B.node(N.append(w, value), read) == B.node(w, read) : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      oldRead(R.Node, nodes, read, value, B.blank_node(), room)


def health(+w: R.World, +value: R.Node) -> {B.ok(N.append(w, value)) == B.ok(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def links(+w: R.World, +value: R.Node) -> {R.World.links(N.append(w, value)) == R.World.links(w) : List<&2, R.Link>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def nodes(+w: R.World, +value: R.Node) -> {R.World.nodes(N.append(w, value)) == B.append(R.Node, R.World.nodes(w), [value]) : List<&2, R.Node>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def zeroRoom(+w: R.World, +first: R.Node, +tail: List<&2, R.Node>, known: {R.World.nodes(w) == first <> tail : List<&2, R.Node>}) ->
  {Nat.is_lt(0n, B.length(R.Node, R.World.nodes(w))) == True{} : Bool}:
  Equal.cong(List<&2, R.Node>, Bool, xs => Nat.is_lt(0n, B.length(R.Node, xs)), R.World.nodes(w), first <> tail, known)
