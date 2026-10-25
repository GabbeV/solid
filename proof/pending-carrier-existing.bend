# Actual addPendingSource on an allocated empty nonzero Set. Initial storage
# membership is explicit; fresh Set/extension allocation is composed separately.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/extension.bend as E
import ./transaction-list-construction.bend as Extension
import ./node-store-lookup.bend as Store
import ./list-update-lookup.bend as Lookup

def finish(+w: R.World, +source: Nat, +set: Nat, slots: List<&2, Nat>) -> B.Bundle<R.World, Bool>:
  B.Bundle{B.store_pendingSet(w, set, B.append(Nat, slots, [source])), True{}}

def setPart(+w: R.World, +id: Nat, +source: Nat, +set: Nat) -> B.Bundle<R.World, Bool>:
  +w = B.choose(~R.World, Nat.is_eq(set, 0n),
    _ =>
      +pair = B.newPendingSet(w, [])
      +w = B.first(R.World, Nat, pair)
      B.store_extension(w, id, R.NodeExtension.with_pendingSources(B.extension(w, id), B.second(R.World, Nat, pair))), _ => w)
  +set = R.NodeExtension.pendingSources(B.extension(w, id))
  finish(w, source, set, B.pendingSlots(w, set))

def addPart(+w: R.World, +id: Nat, +source: Nat) -> B.Bundle<R.World, Bool>:
  +w = E.ext(w, id)
  setPart(w, id, source, R.NodeExtension.pendingSources(B.extension(w, id)))

def exact(+w: R.World, +id: Nat, +source: Nat) ->
  {P.addPendingSource(w, id, source) == B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{w, False{}}, _ => addPart(w, id, source)) : B.Bundle<R.World, Bool>}:
  {==}

def absent(+w: R.World, +id: Nat, +source: Nat, +set: Nat,
  known: {R.NodeExtension.pendingSources(B.extension(w, id)) == 1n+set : Nat},
  slots: {B.pendingSlots(w, 1n+set) == [] : List<&2, Nat>}) ->
  {P.hasSource(w, id, source) == False{} : Bool}:
  Equal.trans(Bool, P.hasSource(w, id, source), B.contains(B.liveIds(B.pendingSlots(w, 1n+set)), source), False{},
    Equal.cong(Nat, Bool, slot => B.contains(B.pendingItems(w, slot), source), R.NodeExtension.pendingSources(B.extension(w, id)), 1n+set, known),
    Equal.cong(List<&2, Nat>, Bool, xs => B.contains(B.liveIds(xs), source), B.pendingSlots(w, 1n+set), [], slots))

def prepared(+w: R.World, +id: Nat, +source: Nat, +extension: Nat, +set: Nat,
  allocated: {R.Node.x(B.node(w, id)) == 1n+extension : Nat},
  +known: {R.NodeExtension.pendingSources(B.extension(w, id)) == 1n+set : Nat},
  slots: {B.pendingSlots(w, 1n+set) == [] : List<&2, Nat>}) ->
  {addPart(w, id, source) == finish(w, source, 1n+set, []) : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, addPart(w, id, source), setPart(w, id, source, R.NodeExtension.pendingSources(B.extension(w, id))), finish(w, source, 1n+set, []),
    Equal.cong(R.World, B.Bundle<R.World, Bool>, state => setPart(state, id, source, R.NodeExtension.pendingSources(B.extension(state, id))), E.ext(w, id), w, Extension.existing(w, id, extension, allocated)),
    Equal.trans(B.Bundle<R.World, Bool>, setPart(w, id, source, R.NodeExtension.pendingSources(B.extension(w, id))), setPart(w, id, source, 1n+set), finish(w, source, 1n+set, []),
      Equal.cong(Nat, B.Bundle<R.World, Bool>, value => setPart(w, id, source, value), R.NodeExtension.pendingSources(B.extension(w, id)), 1n+set, known),
      Equal.trans(B.Bundle<R.World, Bool>, finish(w, source, R.NodeExtension.pendingSources(B.extension(w, id)), B.pendingSlots(w, R.NodeExtension.pendingSources(B.extension(w, id)))), finish(w, source, 1n+set, B.pendingSlots(w, 1n+set)), finish(w, source, 1n+set, []),
        Equal.cong(Nat, B.Bundle<R.World, Bool>, value => finish(w, source, value, B.pendingSlots(w, value)), R.NodeExtension.pendingSources(B.extension(w, id)), 1n+set, known),
        Equal.cong(List<&2, Nat>, B.Bundle<R.World, Bool>, xs => finish(w, source, 1n+set, xs), B.pendingSlots(w, 1n+set), [], slots))))

def add(+w: R.World, +id: Nat, +source: Nat, +extension: Nat, +set: Nat,
  allocated: {R.Node.x(B.node(w, id)) == 1n+extension : Nat},
  +known: {R.NodeExtension.pendingSources(B.extension(w, id)) == 1n+set : Nat},
  +slots: {B.pendingSlots(w, 1n+set) == [] : List<&2, Nat>}) ->
  {P.addPendingSource(w, id, source) == B.Bundle{B.store_pendingSet(w, 1n+set, [source]), True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, P.addPendingSource(w, id, source), B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{w, False{}}, _ => addPart(w, id, source)), finish(w, source, 1n+set, []), exact(w, id, source),
    Equal.trans(B.Bundle<R.World, Bool>, B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{w, False{}}, _ => addPart(w, id, source)), addPart(w, id, source), finish(w, source, 1n+set, []),
      Equal.cong(Bool, B.Bundle<R.World, Bool>, flag => B.choose(~B.Bundle<R.World, Bool>, flag, _ => B.Bundle{w, False{}}, _ => addPart(w, id, source)), P.hasSource(w, id, source), False{}, absent(w, id, source, set, known, slots)), prepared(w, id, source, extension, set, allocated, known, slots)))


def storedSlots(+w: R.World, +set: Nat, +items: List<&2, Nat>, room: {Nat.is_lt(set, B.length(List<&2, Nat>, R.World.pendingSets(w))) == True{} : Bool}) ->
  {B.pendingSlots(B.store_pendingSet(w, set, items), set) == items : List<&2, Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Store.setSame(List<&2, Nat>, pendingSets, set, items, [], room)


def storedExtension(+w: R.World, +set: Nat, +items: List<&2, Nat>, +id: Nat) ->
  {B.extension(B.store_pendingSet(w, set, items), id) == B.extension(w, id) : R.NodeExtension}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def storedX(+w: R.World, +set: Nat, +items: List<&2, Nat>, +id: Nat) ->
  {R.Node.x(B.node(B.store_pendingSet(w, set, items), id)) == R.Node.x(B.node(w, id)) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def self(+n: Nat) -> {Nat.is_eq(n, n) == True{} : Bool}:
  match n:
    case 0n: {==}
    case 1n+p: self(p)

def singletonContains(+w: R.World, +id: Nat, +source: Nat, +set: Nat,
  +known: {R.NodeExtension.pendingSources(B.extension(w, id)) == 1n+set : Nat},
  room: {Nat.is_lt(1n+set, B.length(List<&2, Nat>, R.World.pendingSets(w))) == True{} : Bool}) ->
  {P.hasSource(B.store_pendingSet(w, 1n+set, [1n+source]), id, 1n+source) == True{} : Bool}:
  +next = B.store_pendingSet(w, 1n+set, [1n+source])
  +slot = Equal.trans(Nat, R.NodeExtension.pendingSources(B.extension(next, id)), R.NodeExtension.pendingSources(B.extension(w, id)), 1n+set, Equal.cong(R.NodeExtension, Nat, record => R.NodeExtension.pendingSources(record), B.extension(next, id), B.extension(w, id), storedExtension(w, 1n+set, [1n+source], id)), known)
  +items = storedSlots(w, 1n+set, [1n+source], room)
  Equal.trans(Bool, P.hasSource(next, id, 1n+source), B.contains(B.liveIds(B.pendingSlots(next, 1n+set)), 1n+source), True{}, Equal.cong(Nat, Bool, index => B.contains(B.pendingItems(next, index), 1n+source), R.NodeExtension.pendingSources(B.extension(next, id)), 1n+set, slot),
    Equal.trans(Bool, B.contains(B.liveIds(B.pendingSlots(next, 1n+set)), 1n+source), B.contains([1n+source], 1n+source), True{}, Equal.cong(List<&2, Nat>, Bool, values => B.contains(B.liveIds(values), 1n+source), B.pendingSlots(next, 1n+set), [1n+source], items), Equal.cong(Bool, Bool, flag => Bool.or(flag, False{}), Nat.is_eq(1n+source, 1n+source), True{}, self(1n+source))))


def addedContains(+w: R.World, +id: Nat, +source: Nat, +extension: Nat, +set: Nat,
  allocated: {R.Node.x(B.node(w, id)) == 1n+extension : Nat},
  +known: {R.NodeExtension.pendingSources(B.extension(w, id)) == 1n+set : Nat},
  slots: {B.pendingSlots(w, 1n+set) == [] : List<&2, Nat>},
  room: {Nat.is_lt(1n+set, B.length(List<&2, Nat>, R.World.pendingSets(w))) == True{} : Bool}) ->
  {P.hasSource(B.first(R.World, Bool, P.addPendingSource(w, id, 1n+source)), id, 1n+source) == True{} : Bool}:
  Equal.trans(Bool, P.hasSource(B.first(R.World, Bool, P.addPendingSource(w, id, 1n+source)), id, 1n+source), P.hasSource(B.store_pendingSet(w, 1n+set, [1n+source]), id, 1n+source), True{},
    Equal.cong(B.Bundle<R.World, Bool>, Bool, pair => P.hasSource(B.first(R.World, Bool, pair), id, 1n+source), P.addPendingSource(w, id, 1n+source), B.Bundle{B.store_pendingSet(w, 1n+set, [1n+source]), True{}}, add(w, id, 1n+source, extension, set, allocated, known, slots)), singletonContains(w, id, source, set, known, room))

def duplicate(+w: R.World, +id: Nat, +source: Nat, present: {P.hasSource(w, id, source) == True{} : Bool}) ->
  {P.addPendingSource(w, id, source) == B.Bundle{w, False{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, P.addPendingSource(w, id, source), B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{w, False{}}, _ => addPart(w, id, source)), B.Bundle{w, False{}}, exact(w, id, source),
    Equal.cong(Bool, B.Bundle<R.World, Bool>, flag => B.choose(~B.Bundle<R.World, Bool>, flag, _ => B.Bundle{w, False{}}, _ => addPart(w, id, source)), P.hasSource(w, id, source), True{}, present))
