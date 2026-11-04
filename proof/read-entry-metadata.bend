# Read-entry metadata projection of the proved graph-link footprint.
# No final metadata or successful read is assumed; payloads and aliases are arbitrary.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/graph-state.bend as G
import ./graph-link-frame.bend as Graph
import ./node-observation-lens.bend as Lens
import ./masked-projection.bend as Masked

type NodeView is Data:
  ReadMetadataNode{kind: R.NodeKind,value: R.Value,pending: R.Slot,config: U32,status: U32,x: Nat}

def node(n: R.Node) -> NodeView:
  +row = n
  ReadMetadataNode{R.Node.kind(row),R.Node.value(row),R.Node.pending(row),R.Node.config(row),R.Node.status(row),R.Node.x(row)}

def kind(view: NodeView) -> R.NodeKind:
  match view:
    case ReadMetadataNode{kind,value,pending,config,status,x}: kind

def value(view: NodeView) -> R.Value:
  match view:
    case ReadMetadataNode{kind,value,pending,config,status,x}: value

def pending(view: NodeView) -> R.Slot:
  match view:
    case ReadMetadataNode{kind,value,pending,config,status,x}: pending

def config(view: NodeView) -> U32:
  match view:
    case ReadMetadataNode{kind,value,pending,config,status,x}: config

def status(view: NodeView) -> U32:
  match view:
    case ReadMetadataNode{kind,value,pending,config,status,x}: status

def x(view: NodeView) -> Nat:
  match view:
    case ReadMetadataNode{kind,value,pending,config,status,x}: x

def current(+view: NodeView) -> R.Value:
  B.selected(pending(view),value(view))

def nodes(w: R.World) -> List<&2,NodeView>:
  Lens.observe(NodeView,node,w)

def clean(+n: R.Node) -> {node(Graph.clean(n)) == node(n) : NodeView}:
  match n:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram, +rebaseOwed}: {==}

def flags(+n: R.Node,bits: U32) -> {node(R.Node.with_flags(n,bits)) == node(n) : NodeView}:
  match n:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram, +rebaseOwed}: {==}

def cleaned(rows: List<&2,R.Node>) -> {Lens.map(NodeView,node,Lens.map(R.Node,Graph.clean,rows)) == Lens.map(NodeView,node,rows) : List<&2,NodeView>}:
  match rows:
    case Nil{}: {==}
    case +first <> +tail:
      +changed = Lens.map(NodeView,node,Lens.map(R.Node,Graph.clean,tail))
      +original = Lens.map(NodeView,node,tail)
      Equal.trans(List<&2,NodeView>,node(Graph.clean(first)) <> changed,node(first) <> changed,node(first) <> original,
        Equal.cong(NodeView,List<&2,NodeView>,head=>head <> changed,node(Graph.clean(first)),node(first),clean(first)),
        Equal.cong(List<&2,NodeView>,List<&2,NodeView>,rest=>node(first) <> rest,changed,original,cleaned(tail)))

def maskNodes(+w: R.World) -> {nodes(Graph.observe(w)) == nodes(w) : List<&2,NodeView>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: cleaned(nodes)

def linkNodes(+w: R.World,+dep: Nat,+sub: Nat) -> {nodes(G.link(w,dep,sub)) == nodes(w) : List<&2,NodeView>}:
  Masked.transport(List<&2,NodeView>,nodes,Graph.observe,w,G.link(w,dep,sub),Graph.link(w,dep,sub),maskNodes(w),maskNodes(G.link(w,dep,sub)))

def linkNode(+w: R.World,+dep: Nat,+sub: Nat,id: Nat) -> {node(B.node(G.link(w,dep,sub),id)) == node(B.node(w,id)) : NodeView}:
  Lens.readWorld(NodeView,node,w,G.link(w,dep,sub),id,linkNodes(w,dep,sub))

type GlobalView is Data:
  ReadMetadataGlobals{fault: R.Fault,flush: Nat,lane: Nat,extensions: List<&2,R.NodeExtension>,groups: List<&2,R.Transaction>}

def globals(w: R.World) -> GlobalView:
  +copy = w
  ReadMetadataGlobals{R.World.fault(copy),R.World.flushTransaction(copy),R.World.passLane(copy),R.World.extensions(copy),R.World.txArena(copy)}

def fault(view: GlobalView) -> R.Fault:
  match view:
    case ReadMetadataGlobals{fault,flush,lane,extensions,groups}: fault

def flush(view: GlobalView) -> Nat:
  match view:
    case ReadMetadataGlobals{fault,flush,lane,extensions,groups}: flush

def lane(view: GlobalView) -> Nat:
  match view:
    case ReadMetadataGlobals{fault,flush,lane,extensions,groups}: lane

def extensions(view: GlobalView) -> List<&2,R.NodeExtension>:
  match view:
    case ReadMetadataGlobals{fault,flush,lane,extensions,groups}: extensions

def groups(view: GlobalView) -> List<&2,R.Transaction>:
  match view:
    case ReadMetadataGlobals{fault,flush,lane,extensions,groups}: groups

def maskGlobals(+w: R.World) -> {globals(Graph.observe(w)) == globals(w) : GlobalView}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: {==}

def storeGlobals(+w: R.World,id: Nat,row: R.Node) -> {globals(B.store_node(w,id,row)) == globals(w) : GlobalView}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: {==}

def linkGlobals(+w: R.World,+dep: Nat,+sub: Nat) -> {globals(G.link(w,dep,sub)) == globals(w) : GlobalView}:
  Masked.transport(GlobalView,globals,Graph.observe,w,G.link(w,dep,sub),Graph.link(w,dep,sub),maskGlobals(w),maskGlobals(G.link(w,dep,sub)))

def sameHealthy(+after: R.World,+before: R.World,same: {globals(after) == globals(before) : GlobalView}) -> {B.ok(after) == B.ok(before) : Bool}:
  Equal.cong(GlobalView,Bool,view=>B.healthy(fault(view)),globals(after),globals(before),same)

def sameTransaction(+after: R.World,+before: R.World,id: Nat,same: {globals(after) == globals(before) : GlobalView}) -> {B.transaction(after,id) == B.transaction(before,id) : R.Transaction}:
  Equal.cong(GlobalView,R.Transaction,view=>B.get(R.Transaction,groups(view),id,B.blank_transaction()),globals(after),globals(before),same)

def sameExtension(+after: R.World,+before: R.World,+id: Nat,globalSame: {globals(after) == globals(before) : GlobalView},nodeSame: {node(B.node(after,id)) == node(B.node(before,id)) : NodeView}) -> {B.extension(after,id) == B.extension(before,id) : R.NodeExtension}:
  +indexSame = Equal.cong(NodeView,Nat,x,node(B.node(after,id)),node(B.node(before,id)),nodeSame)
  +rowsSame = Equal.cong(GlobalView,List<&2,R.NodeExtension>,extensions,globals(after),globals(before),globalSame)
  Equal.trans(R.NodeExtension,B.extension(after,id),B.get(R.NodeExtension,R.World.extensions(after),R.Node.x(B.node(before,id)),B.blank_extension()),B.extension(before,id),
    Equal.cong(Nat,R.NodeExtension,index=>B.get(R.NodeExtension,R.World.extensions(after),index,B.blank_extension()),R.Node.x(B.node(after,id)),R.Node.x(B.node(before,id)),indexSame),
    Equal.cong(List<&2,R.NodeExtension>,R.NodeExtension,rows=>B.get(R.NodeExtension,rows,R.Node.x(B.node(before,id)),B.blank_extension()),R.World.extensions(after),R.World.extensions(before),rowsSame))

# Flag stores retain this projection even when the writer aliases the source.
def flagsNodes(+w: R.World,+id: Nat,+bits: U32) -> {nodes(B.store_node(w,id,R.Node.with_flags(B.node(w,id),bits))) == nodes(w) : List<&2,NodeView>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Lens.set(NodeView,node,nodes,id,R.Node.with_flags(B.node(w,id),bits),flags(B.node(w,id),bits))

def flagsNode(+w: R.World,+writer: Nat,+bits: U32,id: Nat) -> {node(B.node(B.store_node(w,writer,R.Node.with_flags(B.node(w,writer),bits)),id)) == node(B.node(w,id)) : NodeView}:
  Lens.readWorld(NodeView,node,w,B.store_node(w,writer,R.Node.with_flags(B.node(w,writer),bits)),id,flagsNodes(w,writer,bits))

def eventGlobals(+w: R.World,event: R.TraceEvent) -> {globals(B.event(w,event)) == globals(w) : GlobalView}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: {==}
