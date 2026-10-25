# Actual fresh graph allocation supplies the input shape for bounded return.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/constants.bend as K
import ./graph-empty-allocation.bend as Allocation
import ./node-store-lookup.bend as Store
import ./subscriber-topology-frame.bend as Shape
import ./arena.bend as Arena

type Storage is Data:
  Storage{links: List<&2, R.Link>, count: Nat, fault: R.Fault}

def storage(+w: R.World) -> Storage:
  Storage{R.World.links(w), B.length(R.Node, R.World.nodes(w)), R.World.fault(w)}

def links(view: Storage) -> List<&2, R.Link>:
  match view:
    case Storage{links, count, fault}: links

def count(view: Storage) -> Nat:
  match view:
    case Storage{links, count, fault}: count

def fault(view: Storage) -> R.Fault:
  match view:
    case Storage{links, count, fault}: fault

def compose(+a: R.World, +b: R.World, +c: R.World, last: {storage(c) == storage(b) : Storage}, first: {storage(b) == storage(a) : Storage}) ->
  {storage(c) == storage(a) : Storage}:
  Equal.trans(Storage, storage(c), storage(b), storage(a), last, first)


def nodeStorage(+w: R.World, +id: Nat, +value: R.Node) ->
  {storage(B.store_node(w, id, value)) == storage(w) : Storage}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(Nat, Storage, size => Storage{links, size, fault}, B.length(R.Node, List.set(&2, R.Node, nodes, id, value)), B.length(R.Node, nodes), Store.lengthSet(R.Node, nodes, id, value))


def bumpStorage(+w: R.World) ->
  {storage(B.bump(w)) == storage(w) : Storage}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def bumpNode(+w: R.World, +id: Nat) ->
  {B.node(B.bump(w), id) == B.node(w, id) : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def appendedNode(+w: R.World, +root: Nat, +leaf: Nat, +read: Nat) ->
  {B.node(Allocation.appended(w, root, leaf), read) == B.node(w, read) : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def appendedCount(+w: R.World, +root: Nat, +leaf: Nat) ->
  {B.length(R.Node, R.World.nodes(Allocation.appended(w, root, leaf))) == B.length(R.Node, R.World.nodes(w)) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def appendedHealth(+w: R.World, +root: Nat, +leaf: Nat) ->
  {B.ok(Allocation.appended(w, root, leaf)) == B.ok(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def appendedLink(+w: R.World, +root: Nat, +leaf: Nat) ->
  {B.link(Allocation.appended(w, root, leaf), Allocation.index(w)) == Allocation.record(w, root, leaf) : R.Link}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Arena.getPrefix(R.Link, links, Allocation.record(w, root, leaf), [], B.blank_link())


def depsTailShape(+node: R.Node, +value: Nat) ->
  {Shape.shape(R.Node.with_depsTail(node, value)) == Shape.shape(node) : Shape.Shape}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}


def subsTailShape(+node: R.Node, +value: Nat) ->
  {Shape.shape(R.Node.with_subsTail(node, value)) == Shape.shape(node) : Shape.Shape}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}


def depsShape(+node: R.Node, +value: Nat) ->
  {Shape.shape(R.Node.with_deps(node, value)) == Shape.shape(node) : Shape.Shape}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}


def subsWritten(node: R.Node, +value: Nat) -> {R.Node.subs(R.Node.with_subs(node, value)) == value : Nat}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}

def firstShape(+w: R.World, +leaf: Nat, +edge: Nat) ->
  {Shape.observe(Allocation.first(w, leaf, edge)) == Shape.observe(w) : Shape.View}:
  Shape.store(w, leaf, R.Node.with_depsTail(B.node(w, leaf), edge), depsTailShape(B.node(w, leaf), edge))

def secondShape(+w: R.World, +root: Nat, +edge: Nat) ->
  {Shape.observe(Allocation.second(w, root, edge)) == Shape.observe(w) : Shape.View}:
  Shape.store(w, root, R.Node.with_subsTail(B.node(w, root), edge), subsTailShape(B.node(w, root), edge))

def thirdShape(+w: R.World, +leaf: Nat, +edge: Nat) ->
  {Shape.observe(Allocation.third(w, leaf, edge)) == Shape.observe(w) : Shape.View}:
  Shape.store(w, leaf, R.Node.with_deps(B.node(w, leaf), edge), depsShape(B.node(w, leaf), edge))

def firstThree(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat) -> R.World:
  Allocation.third(Allocation.second(Allocation.first(w, leaf, edge), root, edge), leaf, edge)

def firstThreeShape(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat) ->
  {Shape.observe(firstThree(w, root, leaf, edge)) == Shape.observe(w) : Shape.View}:
  +first = Allocation.first(w, leaf, edge)
  +second = Allocation.second(first, root, edge)
  Shape.compose(w, first, firstThree(w, root, leaf, edge), Shape.compose(first, second, firstThree(w, root, leaf, edge), thirdShape(second, leaf, edge), secondShape(first, root, edge)), firstShape(w, leaf, edge))

def firstThreeStorage(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat) ->
  {storage(firstThree(w, root, leaf, edge)) == storage(w) : Storage}:
  +first = Allocation.first(w, leaf, edge)
  +second = Allocation.second(first, root, edge)
  compose(w, first, firstThree(w, root, leaf, edge), compose(first, second, firstThree(w, root, leaf, edge), nodeStorage(second, leaf, R.Node.with_deps(B.node(second, leaf), edge)), nodeStorage(first, root, R.Node.with_subsTail(B.node(first, root), edge))), nodeStorage(w, leaf, R.Node.with_depsTail(B.node(w, leaf), edge)))

def writesStorage(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat) ->
  {storage(Allocation.writes(w, root, leaf, edge)) == storage(w) : Storage}:
  +third = firstThree(w, root, leaf, edge)
  +fourth = Allocation.fourth(third, root, edge)
  compose(w, third, Allocation.writes(w, root, leaf, edge), compose(third, fourth, Allocation.writes(w, root, leaf, edge), bumpStorage(fourth), nodeStorage(third, root, R.Node.with_subs(B.node(third, root), edge))), firstThreeStorage(w, root, leaf, edge))

def writesRoot(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat, room: {Nat.is_lt(root, B.length(R.Node, R.World.nodes(w))) == True{} : Bool}) ->
  {R.Node.subs(B.node(Allocation.writes(w, root, leaf, edge), root)) == edge : Nat}:
  +third = firstThree(w, root, leaf, edge)
  +fourth = Allocation.fourth(third, root, edge)
  +size = Equal.cong(Storage, Nat, view => count(view), storage(third), storage(w), firstThreeStorage(w, root, leaf, edge))
  +fits = Equal.trans(Bool, Nat.is_lt(root, B.length(R.Node, R.World.nodes(third))), Nat.is_lt(root, B.length(R.Node, R.World.nodes(w))), True{}, Equal.cong(Nat, Bool, count => Nat.is_lt(root, count), B.length(R.Node, R.World.nodes(third)), B.length(R.Node, R.World.nodes(w)), size), room)
  +stored = Store.nodeSame(third, root, R.Node.with_subs(B.node(third, root), edge), fits)
  Equal.trans(Nat, R.Node.subs(B.node(Allocation.writes(w, root, leaf, edge), root)), R.Node.subs(B.node(fourth, root)), edge,
    Equal.cong(R.Node, Nat, node => R.Node.subs(node), B.node(Allocation.writes(w, root, leaf, edge), root), B.node(fourth, root), bumpNode(fourth, root)),
    Equal.trans(Nat, R.Node.subs(B.node(fourth, root)), R.Node.subs(R.Node.with_subs(B.node(third, root), edge)), edge, Equal.cong(R.Node, Nat, node => R.Node.subs(node), B.node(fourth, root), R.Node.with_subs(B.node(third, root), edge), stored), subsWritten(B.node(third, root), edge)))

def writesLeaf(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat, different: {Nat.is_eq(leaf, root) == False{} : Bool}) ->
  {Shape.shape(B.node(Allocation.writes(w, root, leaf, edge), leaf)) == Shape.shape(B.node(w, leaf)) : Shape.Shape}:
  +third = firstThree(w, root, leaf, edge)
  +fourth = Allocation.fourth(third, root, edge)
  Equal.trans(Shape.Shape, Shape.shape(B.node(Allocation.writes(w, root, leaf, edge), leaf)), Shape.shape(B.node(third, leaf)), Shape.shape(B.node(w, leaf)),
    Equal.cong(R.Node, Shape.Shape, node => Shape.shape(node), B.node(Allocation.writes(w, root, leaf, edge), leaf), B.node(third, leaf), Equal.trans(R.Node, B.node(Allocation.writes(w, root, leaf, edge), leaf), B.node(fourth, leaf), B.node(third, leaf), bumpNode(fourth, leaf), Store.nodeOther(third, root, leaf, R.Node.with_subs(B.node(third, root), edge), different))), Shape.read(w, third, leaf, firstThreeShape(w, root, leaf, edge)))
