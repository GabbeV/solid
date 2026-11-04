# The settlement walk now stages CONFIG_STAGED_ERROR on derivations. Its
# footprint preserves every OTHER configuration bit, kind, subscribers and
# intrusive edges. The stronger raw-config frame remains a separate module.
# This changed conclusion is due to upstream stageMark, not a new input gate.
import Base
import ../runtime/constants.bend as K
import ./word-mask-laws.bend as Mask
import ./subscriber-topology-frame.bend as Raw
import ../representation/records.bend as R
import ../representation/base.bend as B

# The shape needed by traversal and empty-release reasoning. Source time,
# status, extension allocation, heap flags and transaction caches may change.
type Shape is Data:
  Shape{kind: R.NodeKind, config: U32, subscribers: Nat}

def shape(+node: R.Node) -> Shape:
  Shape{R.Node.kind(node), B.clear(R.Node.config(node),K.CONFIG_STAGED_ERROR()), R.Node.subs(node)}

type View is Data:
  View{shapes: List<&2, Shape>, links: List<&2, R.Link>}

def shapes(nodes: List<&2, R.Node>) -> List<&2, Shape>:
  match nodes:
    case Nil{}: []
    case node <> rest: shape(node) <> shapes(rest)

def observe(+w: R.World) -> View:
  View{shapes(R.World.nodes(w)), R.World.links(w)}

def setShapes(+nodes: List<&2, R.Node>, +id: Nat, +next: R.Node,
  same: {shape(next) == shape(B.get(R.Node, nodes, id, B.blank_node())) : Shape}) ->
  {shapes(List.set(&2, R.Node, nodes, id, next)) == shapes(nodes) : List<&2, Shape>}:
  match nodes id:
    case Nil{} n: {==}
    case first <> +rest 0n:
      Equal.cong(Shape, List<&2, Shape>, value => value <> shapes(rest), shape(next), shape(first), same)
    case +first <> +rest 1n+previous:
      Equal.cong(List<&2, Shape>, List<&2, Shape>, result => shape(first) <> result, shapes(List.set(&2, R.Node, rest, previous, next)), shapes(rest), setShapes(rest, previous, next, same))

def store(+w: R.World, +id: Nat, +next: R.Node,
  same: {shape(next) == shape(B.node(w, id)) : Shape}) ->
  {observe(B.store_node(w, id, next)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2, Shape>, View, shapes => View{shapes, links}, shapes(List.set(&2, R.Node, nodes, id, next)), shapes(nodes), setShapes(nodes, id, next, same))


def shapeFlags(+node: R.Node, next: U32) ->
  {shape(R.Node.with_flags(node, next)) == shape(node) : Shape}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}


def flags(+w: R.World, +id: Nat, +next: U32) ->
  {observe(B.store_node(w, id, R.Node.with_flags(B.node(w, id), next))) == observe(w) : View}:
  store(w, id, R.Node.with_flags(B.node(w, id), next), shapeFlags(B.node(w, id), next))


def shapeStatus(+node: R.Node, next: U32) ->
  {shape(R.Node.with_status(node, next)) == shape(node) : Shape}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}


def status(+w: R.World, +id: Nat, +next: U32) ->
  {observe(B.store_node(w, id, R.Node.with_status(B.node(w, id), next))) == observe(w) : View}:
  store(w, id, R.Node.with_status(B.node(w, id), next), shapeStatus(B.node(w, id), next))


def shapeHeight(+node: R.Node, next: Nat) ->
  {shape(R.Node.with_height(node, next)) == shape(node) : Shape}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}


def height(+w: R.World, +id: Nat, +next: Nat) ->
  {observe(B.store_node(w, id, R.Node.with_height(B.node(w, id), next))) == observe(w) : View}:
  store(w, id, R.Node.with_height(B.node(w, id), next), shapeHeight(B.node(w, id), next))


def shapeNextHeap(+node: R.Node, next: Nat) ->
  {shape(R.Node.with_nextHeap(node, next)) == shape(node) : Shape}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}


def nextHeap(+w: R.World, +id: Nat, +next: Nat) ->
  {observe(B.store_node(w, id, R.Node.with_nextHeap(B.node(w, id), next))) == observe(w) : View}:
  store(w, id, R.Node.with_nextHeap(B.node(w, id), next), shapeNextHeap(B.node(w, id), next))


def shapePrevHeap(+node: R.Node, next: Nat) ->
  {shape(R.Node.with_prevHeap(node, next)) == shape(node) : Shape}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}


def prevHeap(+w: R.World, +id: Nat, +next: Nat) ->
  {observe(B.store_node(w, id, R.Node.with_prevHeap(B.node(w, id), next))) == observe(w) : View}:
  store(w, id, R.Node.with_prevHeap(B.node(w, id), next), shapePrevHeap(B.node(w, id), next))


def shapeTime(+node: R.Node, next: Nat) ->
  {shape(R.Node.with_time(node, next)) == shape(node) : Shape}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}


def time(+w: R.World, +id: Nat, +next: Nat) ->
  {observe(B.store_node(w, id, R.Node.with_time(B.node(w, id), next))) == observe(w) : View}:
  store(w, id, R.Node.with_time(B.node(w, id), next), shapeTime(B.node(w, id), next))


def shapeX(+node: R.Node, next: Nat) ->
  {shape(R.Node.with_x(node, next)) == shape(node) : Shape}:
  match node:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram}:
      {==}


def x(+w: R.World, +id: Nat, +next: Nat) ->
  {observe(B.store_node(w, id, R.Node.with_x(B.node(w, id), next))) == observe(w) : View}:
  store(w, id, R.Node.with_x(B.node(w, id), next), shapeX(B.node(w, id), next))


def worldMinimum(+w: R.World, next: Nat) ->
  {observe(R.World.with_minimum(w, next)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def worldMaximum(+w: R.World, next: Nat) ->
  {observe(R.World.with_maximum(w, next)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def worldFault(+w: R.World, next: R.Fault) ->
  {observe(R.World.with_fault(w, next)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def worldBuckets(+w: R.World, next: List<&2, Nat>) ->
  {observe(R.World.with_buckets(w, next)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def worldExtensions(+w: R.World, next: List<&2, R.NodeExtension>) ->
  {observe(R.World.with_extensions(w, next)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def worldTxArena(+w: R.World, next: List<&2, R.Transaction>) ->
  {observe(R.World.with_txArena(w, next)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def worldTransactions(+w: R.World, next: List<&2, Nat>) ->
  {observe(R.World.with_transactions(w, next)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def worldFlushTransaction(+w: R.World, next: Nat) ->
  {observe(R.World.with_flushTransaction(w, next)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def schedule(+w: R.World) -> {observe(B.schedule(w)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match running scheduled halted haltNotified syncDepth:
        case _ _ True{} True{} _: {==}
        case _ _ True{} False{} _: {==}
        case _ True{} False{} _ _: {==}
        case True{} False{} False{} _ 0n: {==}
        case True{} False{} False{} _ 1n+p: {==}
        case False{} False{} False{} _ 0n: {==}
        case False{} False{} False{} _ 1n+p: {==}

# Composition works at opaque World boundaries, including exhausted/faulted
# Worlds. Preservation does not turn exhaustion into successful progress.
def compose(+a: R.World, +b: R.World, +c: R.World,
  second: {observe(c) == observe(b) : View},
  first: {observe(b) == observe(a) : View}) -> {observe(c) == observe(a) : View}:
  Equal.trans(View, observe(c), observe(b), observe(a), second, first)

def choice(+condition: Bool, +origin: R.World, +left: R.World, +right: R.World,
  leftFrame: {observe(left) == observe(origin) : View},
  rightFrame: {observe(right) == observe(origin) : View}) ->
  {observe(B.choose(~R.World, condition, _ => left, _ => right)) == observe(origin) : View}:
  match condition:
    case True{}: leftFrame
    case False{}: rightFrame

def storeBucket(+w: R.World, +height: Nat, +id: Nat) ->
  {observe(B.store_bucket(w, height, id)) == observe(w) : View}:
  worldBuckets(w, B.put(Nat, R.World.buckets(w), height, 0n, id))

def storeExtension(+w: R.World, +id: Nat, +next: R.NodeExtension) ->
  {observe(B.store_extension(w, id, next)) == observe(w) : View}:
  worldExtensions(w, List.set(&2, R.NodeExtension, R.World.extensions(w), R.Node.x(B.node(w, id)), next))

def storeTransaction(+w: R.World, +id: Nat, +next: R.Transaction) ->
  {observe(B.store_transaction(w, id, next)) == observe(w) : View}:
  worldTxArena(w, List.set(&2, R.Transaction, R.World.txArena(w), id, next))


def worldErrorSerial(+w: R.World, next: Nat) ->
  {observe(R.World.with_errorSerial(w, next)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def worldPendingSets(+w: R.World, next: List<&2, List<&2, Nat>>) ->
  {observe(R.World.with_pendingSets(w, next)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def firstBoolChoice( +condition: Bool, +origin: R.World, +left: B.Bundle<R.World, Bool>, +right: B.Bundle<R.World, Bool>,
  leftFrame: {observe(B.first(R.World, Bool, left)) == observe(origin) : View},
  rightFrame: {observe(B.first(R.World, Bool, right)) == observe(origin) : View}) ->
  {observe(B.first(R.World, Bool, B.choose(~B.Bundle<R.World, Bool>, condition, _ => left, _ => right))) == observe(origin) : View}:
  match condition:
    case True{}: leftFrame
    case False{}: rightFrame

def storePendingSet(+w: R.World, +set: Nat, +items: List<&2, Nat>) ->
  {observe(B.store_pendingSet(w, set, items)) == observe(w) : View}:
  worldPendingSets(w, List.set(&2, List<&2, Nat>, R.World.pendingSets(w), set, items))


def nodes(view: View) -> List<&2, Shape>:
  match view:
    case View{shapes, links}: shapes

def edges(view: View) -> List<&2, R.Link>:
  match view:
    case View{shapes, links}: links

def readValues(+xs: List<&2, R.Node>, +id: Nat) ->
  {B.get(Shape, shapes(xs), id, shape(B.blank_node())) == shape(B.get(R.Node, xs, id, B.blank_node())) : Shape}:
  match xs id:
    case Nil{} n: {==}
    case first <> rest 0n: {==}
    case first <> rest 1n+p: readValues(rest, p)

def read(+w: R.World, +next: R.World, +id: Nat, same: {observe(next) == observe(w) : View}) ->
  {shape(B.node(next, id)) == shape(B.node(w, id)) : Shape}:
  Equal.trans(Shape, shape(B.node(next, id)), B.get(Shape, nodes(observe(next)), id, shape(B.blank_node())), shape(B.node(w, id)),
    Equal.sym(Shape, B.get(Shape, shapes(R.World.nodes(next)), id, shape(B.blank_node())), shape(B.node(next, id)), readValues(R.World.nodes(next), id)),
    Equal.trans(Shape, B.get(Shape, nodes(observe(next)), id, shape(B.blank_node())), B.get(Shape, nodes(observe(w)), id, shape(B.blank_node())), shape(B.node(w, id)),
      Equal.cong(View, Shape, view => B.get(Shape, nodes(view), id, shape(B.blank_node())), observe(next), observe(w), same), readValues(R.World.nodes(w), id)))

def shapePending(+node: R.Node,+value: R.Slot) -> {shape(R.Node.with_pending(node,value)) == shape(node) : Shape}:
  match node:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram}: {==}

def pending(+w: R.World,+id: Nat,+value: R.Slot) -> {observe(B.store_node(w,id,R.Node.with_pending(B.node(w,id),value))) == observe(w) : View}:
  store(w,id,R.Node.with_pending(B.node(w,id),value),shapePending(B.node(w,id),value))

def shapeNotified(+node: R.Node,+value: R.Stamp) -> {shape(R.Node.with_notified(node,value)) == shape(node) : Shape}:
  match node:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram}: {==}

def notified(+w: R.World,+id: Nat,+value: R.Stamp) -> {observe(B.store_node(w,id,R.Node.with_notified(B.node(w,id),value))) == observe(w) : View}:
  store(w,id,R.Node.with_notified(B.node(w,id),value),shapeNotified(B.node(w,id),value))

def rawShape(value: Raw.Shape) -> Shape:
  match value:
    case Raw.Shape{kind,config,subscribers}: Shape{kind,B.clear(config,K.CONFIG_STAGED_ERROR()),subscribers}

def rawShapes(values: List<&2,Raw.Shape>) -> List<&2,Shape>:
  match values:
    case Nil{}: []
    case value <> rest: rawShape(value) <> rawShapes(rest)

def rawView(value: Raw.View) -> View:
  match value:
    case Raw.View{nodes,links}: View{rawShapes(nodes),links}

def projectedNodes(+values: List<&2,R.Node>) -> {rawShapes(Raw.shapes(values)) == shapes(values) : List<&2,Shape>}:
  match values:
    case Nil{}: {==}
    case +node <> +rest:
      Equal.cong(List<&2,Shape>,List<&2,Shape>,tail=>shape(node) <> tail,rawShapes(Raw.shapes(rest)),shapes(rest),projectedNodes(rest))

def projected(+w: R.World) -> {rawView(Raw.observe(w)) == observe(w) : View}:
  Equal.cong(List<&2,Shape>,View,nodes=>View{nodes,R.World.links(w)},rawShapes(Raw.shapes(R.World.nodes(w))),shapes(R.World.nodes(w)),projectedNodes(R.World.nodes(w)))

def exact(+w: R.World,+next: R.World,same: {Raw.observe(next) == Raw.observe(w) : Raw.View}) -> {observe(next) == observe(w) : View}:
  Equal.trans(View,observe(next),rawView(Raw.observe(next)),observe(w),Equal.sym(View,rawView(Raw.observe(next)),observe(next),projected(next)),Equal.trans(View,rawView(Raw.observe(next)),rawView(Raw.observe(w)),observe(w),Equal.cong(Raw.View,View,view=>rawView(view),Raw.observe(next),Raw.observe(w),same),projected(w)))

def stagedShape(+node: R.Node) -> {shape(R.Node.with_config(node,B.set(R.Node.config(node),K.CONFIG_STAGED_ERROR()))) == shape(node) : Shape}:
  match node:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram}:
      Equal.cong(U32,Shape,word=>Shape{kind,word,subs},B.clear(B.set(config,K.CONFIG_STAGED_ERROR()),K.CONFIG_STAGED_ERROR()),B.clear(config,K.CONFIG_STAGED_ERROR()),Mask.clearStagedSet(config))

def stageErrorConfig(+w: R.World,+id: Nat) -> {observe(B.store_node(w,id,R.Node.with_config(B.node(w,id),B.set(R.Node.config(B.node(w,id)),K.CONFIG_STAGED_ERROR())))) == observe(w) : View}:
  store(w,id,R.Node.with_config(B.node(w,id),B.set(R.Node.config(B.node(w,id)),K.CONFIG_STAGED_ERROR())),stagedShape(B.node(w,id)))


def worldPendingNodes(+w: R.World, next: List<&2,Nat>) ->
  {observe(R.World.with_pendingNodes(w, next)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldUnflushedStaged(+w: R.World, next: Bool) ->
  {observe(R.World.with_unflushedStaged(w, next)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def configuration(value: Shape) -> U32:
  match value:
    case Shape{kind,config,subscribers}: config

def autoProjection(+w: R.World,+id: Nat) -> {B.has(configuration(shape(B.node(w,id))),K.CONFIG_AUTO_DISPOSE()) == B.has(R.Node.config(B.node(w,id)),K.CONFIG_AUTO_DISPOSE()) : Bool}:
  Mask.autoAfterStagedClear(R.Node.config(B.node(w,id)))

def autoRead(+w: R.World,+next: R.World,+id: Nat,same: {observe(next) == observe(w) : View}) -> {B.has(R.Node.config(B.node(next,id)),K.CONFIG_AUTO_DISPOSE()) == B.has(R.Node.config(B.node(w,id)),K.CONFIG_AUTO_DISPOSE()) : Bool}:
  Equal.trans(Bool,B.has(R.Node.config(B.node(next,id)),K.CONFIG_AUTO_DISPOSE()),B.has(configuration(shape(B.node(next,id))),K.CONFIG_AUTO_DISPOSE()),B.has(R.Node.config(B.node(w,id)),K.CONFIG_AUTO_DISPOSE()),Equal.sym(Bool,B.has(configuration(shape(B.node(next,id))),K.CONFIG_AUTO_DISPOSE()),B.has(R.Node.config(B.node(next,id)),K.CONFIG_AUTO_DISPOSE()),autoProjection(next,id)),Equal.trans(Bool,B.has(configuration(shape(B.node(next,id))),K.CONFIG_AUTO_DISPOSE()),B.has(configuration(shape(B.node(w,id))),K.CONFIG_AUTO_DISPOSE()),B.has(R.Node.config(B.node(w,id)),K.CONFIG_AUTO_DISPOSE()),Equal.cong(Shape,Bool,shape=>B.has(configuration(shape),K.CONFIG_AUTO_DISPOSE()),shape(B.node(next,id)),shape(B.node(w,id)),read(w,next,id,same)),autoProjection(w,id)))
