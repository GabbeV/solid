# Frames of the actual allocated carrier fields through status-only node stores
# and non-carrier extension stores. These are not full node/status invariants.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./node-store-lookup.bend as Store
import ./pending-auxiliary-lookup.bend as Aux
import ./pending-carrier-arena.bend as Arena
import ./node-pointer-observation.bend as Pointers

type Frame<-a: R.World, -b: R.World, -node: Nat> is Data:
  Frame{x: {R.Node.x(B.node(b, node)) == R.Node.x(B.node(a, node)) : Nat}, count: {B.length(R.Node, R.World.nodes(b)) == B.length(R.Node, R.World.nodes(a)) : Nat}, room: {Nat.is_lt(R.Node.x(B.node(b, node)), B.length(R.NodeExtension, R.World.extensions(b))) == Nat.is_lt(R.Node.x(B.node(a, node)), B.length(R.NodeExtension, R.World.extensions(a))) : Bool}, pointer: {R.NodeExtension.pendingSources(B.extension(b, node)) == R.NodeExtension.pendingSources(B.extension(a, node)) : Nat}, sets: {R.World.pendingSets(b) == R.World.pendingSets(a) : List<&2, List<&2, Nat>>}}

def nodeExtensions(+w: R.World, +node: Nat, +record: R.Node) ->
  {R.World.extensions(B.store_node(w, node, record)) == R.World.extensions(w) : List<&2, R.NodeExtension>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def nodeSets(+w: R.World, +node: Nat, +record: R.Node) ->
  {R.World.pendingSets(B.store_node(w, node, record)) == R.World.pendingSets(w) : List<&2, List<&2, Nat>>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def extensionCount(+w: R.World, +node: Nat, +record: R.NodeExtension) ->
  {B.length(R.Node, R.World.nodes(B.store_extension(w, node, record))) == B.length(R.Node, R.World.nodes(w)) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def nodeX(+w: R.World, +node: Nat, +record: R.Node, same: {R.Node.x(record) == R.Node.x(B.node(w, node)) : Nat}) ->
  {R.Node.x(B.node(B.store_node(w, node, record), node)) == R.Node.x(B.node(w, node)) : Nat}:
  Pointers.read(w, B.store_node(w, node, record), node, Pointers.store(w, node, record, same))

def nodePointer(+w: R.World, +node: Nat, +record: R.Node, +same: {R.Node.x(record) == R.Node.x(B.node(w, node)) : Nat}) ->
  {R.NodeExtension.pendingSources(B.extension(B.store_node(w, node, record), node)) == R.NodeExtension.pendingSources(B.extension(w, node)) : Nat}:
  +next = B.store_node(w, node, record)
  Equal.trans(Nat, R.NodeExtension.pendingSources(B.extension(next, node)), R.NodeExtension.pendingSources(B.get(R.NodeExtension, R.World.extensions(next), R.Node.x(B.node(w, node)), B.blank_extension())), R.NodeExtension.pendingSources(B.extension(w, node)),
    Equal.cong(Nat, Nat, x => R.NodeExtension.pendingSources(B.get(R.NodeExtension, R.World.extensions(next), x, B.blank_extension())), R.Node.x(B.node(next, node)), R.Node.x(B.node(w, node)), nodeX(w, node, record, same)),
    Equal.cong(List<&2, R.NodeExtension>, Nat, xs => R.NodeExtension.pendingSources(B.get(R.NodeExtension, xs, R.Node.x(B.node(w, node)), B.blank_extension())), R.World.extensions(next), R.World.extensions(w), nodeExtensions(w, node, record)))

def nodeRoom(+w: R.World, +node: Nat, +record: R.Node, +same: {R.Node.x(record) == R.Node.x(B.node(w, node)) : Nat}) ->
  {Nat.is_lt(R.Node.x(B.node(B.store_node(w, node, record), node)), B.length(R.NodeExtension, R.World.extensions(B.store_node(w, node, record)))) == Nat.is_lt(R.Node.x(B.node(w, node)), B.length(R.NodeExtension, R.World.extensions(w))) : Bool}:
  +next = B.store_node(w, node, record)
  Equal.trans(Bool, Nat.is_lt(R.Node.x(B.node(next, node)), B.length(R.NodeExtension, R.World.extensions(next))), Nat.is_lt(R.Node.x(B.node(w, node)), B.length(R.NodeExtension, R.World.extensions(next))), Nat.is_lt(R.Node.x(B.node(w, node)), B.length(R.NodeExtension, R.World.extensions(w))),
    Equal.cong(Nat, Bool, x => Nat.is_lt(x, B.length(R.NodeExtension, R.World.extensions(next))), R.Node.x(B.node(next, node)), R.Node.x(B.node(w, node)), nodeX(w, node, record, same)),
    Equal.cong(List<&2, R.NodeExtension>, Bool, xs => Nat.is_lt(R.Node.x(B.node(w, node)), B.length(R.NodeExtension, xs)), R.World.extensions(next), R.World.extensions(w), nodeExtensions(w, node, record)))

def node(+w: R.World, +node: Nat, +record: R.Node, +same: {R.Node.x(record) == R.Node.x(B.node(w, node)) : Nat}) -> Frame<w, B.store_node(w, node, record), node>:
  Frame{nodeX(w, node, record, same), Store.nodeLength(w, node, record), nodeRoom(w, node, record, same), nodePointer(w, node, record, same), nodeSets(w, node, record)}

def extension(+w: R.World, +node: Nat, +record: R.NodeExtension, same: {R.NodeExtension.pendingSources(record) == R.NodeExtension.pendingSources(B.extension(w, node)) : Nat}, fits: {Nat.is_lt(R.Node.x(B.node(w, node)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool}) -> Frame<w, B.store_extension(w, node, record), node>:
  Frame{Aux.extensionX(w, node, record, node), extensionCount(w, node, record), Aux.extensionRoom(w, node, record), Equal.trans(Nat, R.NodeExtension.pendingSources(B.extension(B.store_extension(w, node, record), node)), R.NodeExtension.pendingSources(record), R.NodeExtension.pendingSources(B.extension(w, node)), Equal.cong(R.NodeExtension, Nat, value => R.NodeExtension.pendingSources(value), B.extension(B.store_extension(w, node, record), node), record, Aux.extensionRead(w, node, record, fits)), same), Arena.extensionStorage(w, node, record)}

def compose(-a: R.World, -b: R.World, -c: R.World, -node: Nat, first: Frame<a,b,node>, last: Frame<b,c,node>) -> Frame<a,c,node>:
  match first last:
    case Frame{ax, ac, ar, ap, aset} Frame{bx, bc, br, bp, bset}:
      Frame{Equal.trans(Nat, R.Node.x(B.node(c,node)), R.Node.x(B.node(b,node)), R.Node.x(B.node(a,node)), bx, ax), Equal.trans(Nat, B.length(R.Node,R.World.nodes(c)), B.length(R.Node,R.World.nodes(b)), B.length(R.Node,R.World.nodes(a)), bc, ac), Equal.trans(Bool, Nat.is_lt(R.Node.x(B.node(c,node)),B.length(R.NodeExtension,R.World.extensions(c))), Nat.is_lt(R.Node.x(B.node(b,node)),B.length(R.NodeExtension,R.World.extensions(b))), Nat.is_lt(R.Node.x(B.node(a,node)),B.length(R.NodeExtension,R.World.extensions(a))), br, ar), Equal.trans(Nat,R.NodeExtension.pendingSources(B.extension(c,node)),R.NodeExtension.pendingSources(B.extension(b,node)),R.NodeExtension.pendingSources(B.extension(a,node)),bp,ap),Equal.trans(List<&2,List<&2,Nat>>,R.World.pendingSets(c),R.World.pendingSets(b),R.World.pendingSets(a),bset,aset)}
