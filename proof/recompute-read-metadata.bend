# Metadata transported through the actual prepared-render body setup.
# Recompute changes bookkeeping fields; source slots and transaction records
# are retained. The source/reader split is explicit for full source flags.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/scheduler.bend as S
import ./recompute-read-setup.bend as Setup
import ./read-entry-metadata.bend as M
import ./node-observation-lens.bend as Lens
import ./node-store-lookup.bend as Store
import ./list-update-lookup.bend as Lookup
import ./tracked-read-input.bend as I

type Control is Data:
  Controls{rows: List<&2,R.Node>,metadata: M.GlobalView,context: Nat,unflushed: Bool,dispatch: Bool}

def control(w: R.World) -> Control:
  +copy = w
  Controls{R.World.nodes(copy),M.globals(copy),R.World.context(copy),R.World.unflushedStaged(copy),R.VerdictState.dispatch(R.World.verdictState(copy))}

def rows(view: Control) -> List<&2,R.Node>:
  match view:
    case Controls{rows,metadata,context,unflushed,dispatch}: rows

def metadata(view: Control) -> M.GlobalView:
  match view:
    case Controls{rows,metadata,context,unflushed,dispatch}: metadata

def context(view: Control) -> Nat:
  match view:
    case Controls{rows,metadata,context,unflushed,dispatch}: context

def unflushed(view: Control) -> Bool:
  match view:
    case Controls{rows,metadata,context,unflushed,dispatch}: unflushed

def dispatch(view: Control) -> Bool:
  match view:
    case Controls{rows,metadata,context,unflushed,dispatch}: dispatch

def refreshed(+n: R.Node,time: Nat) -> {M.node(Setup.refreshed(n,time)) == M.node(n) : M.NodeView}:
  match n:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram, +rebaseOwed}: {==}

def expression(+n: R.Node,time: Nat) -> {R.Node.expr(Setup.refreshed(n,time)) == R.Node.expr(n) : R.Expr}:
  match n:
    case R.Node{+n_kind, +n_value, +n_pending, +n_equals, +n_config, +n_flags, +n_status, +n_time, +n_notified, +n_deps, +n_depsTail, +n_depGen, +n_subs, +n_subsTail, +n_height, +n_nextHeap, +n_prevHeap, +n_parent, +n_firstChild, +n_nextSibling, +n_prevSibling, +n_expr, +n_modified, +n_prevValue, +n_target, +n_loading, +n_x, +n_parentComputed, +n_scope, +n_childCount, +n_disposal, +n_cleanup, +n_effectProgram, +n_returnedCleanup, +n_errorProgram, +rebaseOwed}: {==}

def decorated(+w: R.World,id: Nat,stale: Bool,tracked: Bool) -> {control(Setup.decorate(w,id,stale,tracked)) == control(w) : Control}:
  match w tracked:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena} True{}: {==}
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena} False{}: {==}

def tracking(+w: R.World,id: Nat,stale: Bool,tracked: Bool) -> {R.World.tracking(Setup.decorate(w,id,stale,tracked)) == True{} : Bool}:
  match w tracked:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena} True{}: {==}
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena} False{}: {==}

def storedNodes(+w: R.World,+id: Nat) -> {M.nodes(Setup.stored(w,id)) == M.nodes(w) : List<&2,M.NodeView>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: Lens.set(M.NodeView,M.node,nodes,id,Setup.row(w,id),refreshed(B.node(w,id),R.World.clock(R.World.with_context(w,id))))

def storedGlobals(+w: R.World,id: Nat) -> {M.globals(Setup.stored(w,id)) == M.globals(w) : M.GlobalView}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: {==}

def storedContext(+w: R.World,id: Nat) -> {R.World.context(Setup.stored(w,id)) == id : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: {==}

def storedUnflushed(+w: R.World,id: Nat) -> {R.World.unflushedStaged(Setup.stored(w,id)) == R.World.unflushedStaged(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: {==}

def storedDispatch(+w: R.World,id: Nat) -> {R.VerdictState.dispatch(R.World.verdictState(Setup.stored(w,id))) == R.VerdictState.dispatch(R.World.verdictState(w)) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: {==}

def storedSource(+w: R.World,+reader: Nat,+id: Nat,different: {Nat.is_eq(id,reader) == False{} : Bool}) -> {B.node(Setup.stored(w,reader),id) == B.node(w,id) : R.Node}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: Lookup.setOther(R.Node,nodes,reader,id,B.blank_node(),Setup.row(w,reader),different)

def storedLength(+w: R.World,+id: Nat) -> {B.length(R.Node,R.World.nodes(Setup.stored(w,id))) == B.length(R.Node,R.World.nodes(w)) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: Store.lengthSet(R.Node,nodes,id,Setup.row(w,id))

def decoration(+w: R.World,+id: Nat) -> {control(Setup.world(w,id)) == control(Setup.stored(w,id)) : Control}:
  +n = Setup.row(w,id)
  +next = Setup.stored(w,id)
  decorated(next,id,Bool.or(R.World.stale(next),Bool.and(B.effect(R.Node.kind(n)),Bool.not(S.is_user(R.Node.kind(n))))),B.tracked(R.Node.kind(n)))

def nodes(+w: R.World,+id: Nat) -> {M.nodes(Setup.world(w,id)) == M.nodes(w) : List<&2,M.NodeView>}:
  Equal.trans(List<&2,M.NodeView>,M.nodes(Setup.world(w,id)),M.nodes(Setup.stored(w,id)),M.nodes(w),Equal.cong(Control,List<&2,M.NodeView>,view=>Lens.map(M.NodeView,M.node,rows(view)),control(Setup.world(w,id)),control(Setup.stored(w,id)),decoration(w,id)),storedNodes(w,id))

def node(+w: R.World,+reader: Nat,id: Nat) -> {M.node(B.node(Setup.world(w,reader),id)) == M.node(B.node(w,id)) : M.NodeView}:
  Lens.readWorld(M.NodeView,M.node,w,Setup.world(w,reader),id,nodes(w,reader))

def globals(+w: R.World,+id: Nat) -> {M.globals(Setup.world(w,id)) == M.globals(w) : M.GlobalView}:
  Equal.trans(M.GlobalView,M.globals(Setup.world(w,id)),M.globals(Setup.stored(w,id)),M.globals(w),Equal.cong(Control,M.GlobalView,metadata,control(Setup.world(w,id)),control(Setup.stored(w,id)),decoration(w,id)),storedGlobals(w,id))

def current(+w: R.World,+id: Nat) -> {R.World.context(Setup.world(w,id)) == id : Nat}:
  Equal.trans(Nat,R.World.context(Setup.world(w,id)),R.World.context(Setup.stored(w,id)),id,Equal.cong(Control,Nat,context,control(Setup.world(w,id)),control(Setup.stored(w,id)),decoration(w,id)),storedContext(w,id))

def tracked(+w: R.World,+id: Nat) -> {R.World.tracking(Setup.world(w,id)) == True{} : Bool}:
  +n = Setup.row(w,id)
  +next = Setup.stored(w,id)
  tracking(next,id,Bool.or(R.World.stale(next),Bool.and(B.effect(R.Node.kind(n)),Bool.not(S.is_user(R.Node.kind(n))))),B.tracked(R.Node.kind(n)))

def unflushedSame(+w: R.World,+id: Nat) -> {R.World.unflushedStaged(Setup.world(w,id)) == R.World.unflushedStaged(w) : Bool}:
  Equal.trans(Bool,R.World.unflushedStaged(Setup.world(w,id)),R.World.unflushedStaged(Setup.stored(w,id)),R.World.unflushedStaged(w),Equal.cong(Control,Bool,unflushed,control(Setup.world(w,id)),control(Setup.stored(w,id)),decoration(w,id)),storedUnflushed(w,id))

def dispatchSame(+w: R.World,+id: Nat) -> {R.VerdictState.dispatch(R.World.verdictState(Setup.world(w,id))) == R.VerdictState.dispatch(R.World.verdictState(w)) : Bool}:
  Equal.trans(Bool,R.VerdictState.dispatch(R.World.verdictState(Setup.world(w,id))),R.VerdictState.dispatch(R.World.verdictState(Setup.stored(w,id))),R.VerdictState.dispatch(R.World.verdictState(w)),Equal.cong(Control,Bool,dispatch,control(Setup.world(w,id)),control(Setup.stored(w,id)),decoration(w,id)),storedDispatch(w,id))

def source(+w: R.World,+reader: Nat,+id: Nat,different: {Nat.is_eq(id,reader) == False{} : Bool}) -> {B.node(Setup.world(w,reader),id) == B.node(w,id) : R.Node}:
  Equal.trans(R.Node,B.node(Setup.world(w,reader),id),B.node(Setup.stored(w,reader),id),B.node(w,id),Equal.cong(Control,R.Node,view=>B.get(R.Node,rows(view),id,B.blank_node()),control(Setup.world(w,reader)),control(Setup.stored(w,reader)),decoration(w,reader)),storedSource(w,reader,id,different))

def length(+w: R.World,+reader: Nat) -> {B.length(R.Node,R.World.nodes(Setup.world(w,reader))) == B.length(R.Node,R.World.nodes(w)) : Nat}:
  Equal.trans(Nat,B.length(R.Node,R.World.nodes(Setup.world(w,reader))),B.length(R.Node,R.World.nodes(Setup.stored(w,reader))),B.length(R.Node,R.World.nodes(w)),Equal.cong(Control,Nat,view=>B.length(R.Node,rows(view)),control(Setup.world(w,reader)),control(Setup.stored(w,reader)),decoration(w,reader)),storedLength(w,reader))

def input(+w: R.World,+reader: Nat,+id: Nat,+root: Nat,ready: I.Input<w,reader,id,root>) -> I.Input<Setup.world(w,reader),reader,id,root>:
  I.transport(w,Setup.world(w,reader),reader,id,root,node(w,reader,id),node(w,reader,reader),globals(w,reader),ready)
