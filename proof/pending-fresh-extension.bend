# Actual fresh extension supplies pointer/default/membership facts used by the
# source Set constructor. The selected node is an existing allocated slot.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/extension.bend as E
import ./extension-laws.bend as Extension
import ./node-store-lookup.bend as Store
import ./arena.bend as Arena
import ./node-allocation-validity.bend as Arithmetic

def resized(+w: R.World) -> R.World:
  R.World.with_extensions(w, B.append(R.NodeExtension, R.World.extensions(w), [B.blank_extension()]))

def index(w: R.World) -> Nat:
  B.length(R.NodeExtension, R.World.extensions(w))

def resizedNode(+w: R.World, +id: Nat) ->
  {B.node(resized(w), id) == B.node(w, id) : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def resizedCount(+w: R.World) ->
  {B.length(R.Node, R.World.nodes(resized(w))) == B.length(R.Node, R.World.nodes(w)) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def grownExtensions(+w: R.World, +id: Nat) ->
  {R.World.extensions(Extension.grow(w, id)) == B.append(R.NodeExtension, R.World.extensions(w), [B.blank_extension()]) : List<&2, R.NodeExtension>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def grownSets(+w: R.World, +id: Nat) ->
  {R.World.pendingSets(Extension.grow(w, id)) == R.World.pendingSets(w) : List<&2, List<&2, Nat>>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def node(+w: R.World, +id: Nat, room: {Nat.is_lt(id, B.length(R.Node, R.World.nodes(w))) == True{} : Bool}) ->
  {B.node(Extension.grow(w, id), id) == R.Node.with_x(B.node(w, id), index(w)) : R.Node}:
  +fits = Equal.trans(Bool, Nat.is_lt(id, B.length(R.Node, R.World.nodes(resized(w)))), Nat.is_lt(id, B.length(R.Node, R.World.nodes(w))), True{}, Equal.cong(Nat, Bool, size => Nat.is_lt(id, size), B.length(R.Node, R.World.nodes(resized(w))), B.length(R.Node, R.World.nodes(w)), resizedCount(w)), room)
  Equal.trans(R.Node, B.node(Extension.grow(w, id), id), R.Node.with_x(B.node(resized(w), id), index(w)), R.Node.with_x(B.node(w, id), index(w)), Store.nodeSame(resized(w), id, R.Node.with_x(B.node(resized(w), id), index(w)), fits), Equal.cong(R.Node, R.Node, record => R.Node.with_x(record, index(w)), B.node(resized(w), id), B.node(w, id), resizedNode(w, id)))

def pointer(+w: R.World, +id: Nat, room: {Nat.is_lt(id, B.length(R.Node, R.World.nodes(w))) == True{} : Bool}) ->
  {R.Node.x(B.node(Extension.grow(w, id), id)) == index(w) : Nat}:
  Equal.trans(Nat, R.Node.x(B.node(Extension.grow(w, id), id)), R.Node.x(R.Node.with_x(B.node(w, id), index(w))), index(w), Equal.cong(R.Node, Nat, record => R.Node.x(record), B.node(Extension.grow(w, id), id), R.Node.with_x(B.node(w, id), index(w)), node(w, id, room)), Extension.get_set_x(B.node(w, id), index(w)))

def record(+w: R.World, +id: Nat, room: {Nat.is_lt(id, B.length(R.Node, R.World.nodes(w))) == True{} : Bool}) ->
  {B.extension(Extension.grow(w, id), id) == B.blank_extension() : R.NodeExtension}:
  Equal.trans(R.NodeExtension, B.extension(Extension.grow(w, id), id), B.get(R.NodeExtension, B.append(R.NodeExtension, R.World.extensions(w), [B.blank_extension()]), index(w), B.blank_extension()), B.blank_extension(), Extension.readKnown(Extension.grow(w, id), id, index(w), B.append(R.NodeExtension, R.World.extensions(w), [B.blank_extension()]), pointer(w, id, room), grownExtensions(w, id)), Arena.getPrefix(R.NodeExtension, R.World.extensions(w), B.blank_extension(), [], B.blank_extension()))

def count(+w: R.World, +id: Nat) ->
  {B.length(R.NodeExtension, R.World.extensions(Extension.grow(w, id))) == Nat.add(index(w), 1n) : Nat}:
  Equal.trans(Nat, B.length(R.NodeExtension, R.World.extensions(Extension.grow(w, id))), B.length(R.NodeExtension, B.append(R.NodeExtension, R.World.extensions(w), [B.blank_extension()])), Nat.add(index(w), 1n), Equal.cong(List<&2, R.NodeExtension>, Nat, values => B.length(R.NodeExtension, values), R.World.extensions(Extension.grow(w, id)), B.append(R.NodeExtension, R.World.extensions(w), [B.blank_extension()]), grownExtensions(w, id)), Arena.appendLength(R.NodeExtension, R.World.extensions(w), [B.blank_extension()]))

def room(+w: R.World, +id: Nat, +fits: {Nat.is_lt(id, B.length(R.Node, R.World.nodes(w))) == True{} : Bool}) ->
  {Nat.is_lt(R.Node.x(B.node(Extension.grow(w, id), id)), B.length(R.NodeExtension, R.World.extensions(Extension.grow(w, id)))) == True{} : Bool}:
  Equal.trans(Bool, Nat.is_lt(R.Node.x(B.node(Extension.grow(w, id), id)), B.length(R.NodeExtension, R.World.extensions(Extension.grow(w, id)))), Nat.is_lt(index(w), B.length(R.NodeExtension, R.World.extensions(Extension.grow(w, id)))), True{}, Equal.cong(Nat, Bool, slot => Nat.is_lt(slot, B.length(R.NodeExtension, R.World.extensions(Extension.grow(w, id)))), R.Node.x(B.node(Extension.grow(w, id), id)), index(w), pointer(w, id, fits)), Equal.trans(Bool, Nat.is_lt(index(w), B.length(R.NodeExtension, R.World.extensions(Extension.grow(w, id)))), Nat.is_lt(index(w), Nat.add(index(w), 1n)), True{}, Equal.cong(Nat, Bool, size => Nat.is_lt(index(w), size), B.length(R.NodeExtension, R.World.extensions(Extension.grow(w, id))), Nat.add(index(w), 1n), count(w, id)), Arithmetic.nextRoom(index(w))))

def exact(+w: R.World, +id: Nat, empty: {R.Node.x(B.node(w, id)) == 0n : Nat}) ->
  {E.ext(w, id) == Extension.grow(w, id) : R.World}:
  Equal.cong(Nat, R.World, x => B.choose(~R.World, Nat.is_ne(x, 0n), _ => w, _ => Extension.grow(w, id)), R.Node.x(B.node(w, id)), 0n, empty)
