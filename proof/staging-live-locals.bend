# Source staging rereads kind/notified after intake and intermediate stores.
# The stores preserve those locals even for absent slots. Prove this once,
# then connect cached-local proof helpers without altering the runtime.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ../runtime/read-state.bend as V
import ../runtime/constants.bend as K
import ./staging-committed-frame.bend as Stage
import ./ordinary-stage-intake.bend as Queue

type Locals is Data:
  Locals{kind: R.NodeKind, notified: R.Stamp}

def locals(+node: R.Node) -> Locals:
  Locals{R.Node.kind(node),R.Node.notified(node)}

def read(+w: R.World,id: Nat) -> Locals:
  locals(B.node(w,id))

def kind(value: Locals) -> R.NodeKind:
  match value:
    case Locals{kind,notified}: kind

def notified(value: Locals) -> R.Stamp:
  match value:
    case Locals{kind,notified}: notified

def setRead(+nodes: List<&2,R.Node>,+id: Nat,+record: R.Node,same: {locals(record) == locals(B.get(R.Node,nodes,id,B.blank_node())) : Locals}) -> {locals(B.get(R.Node,List.set(&2,R.Node,nodes,id,record),id,B.blank_node())) == locals(B.get(R.Node,nodes,id,B.blank_node())) : Locals}:
  match nodes id:
    case Nil{} n: {==}
    case first <> rest 0n: same
    case first <> tail 1n+p: setRead(tail,p,record,same)

def store(+w: R.World,+id: Nat,+record: R.Node,same: {locals(record) == read(w,id) : Locals}) -> {read(B.store_node(w,id,record),id) == read(w,id) : Locals}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      setRead(nodes,id,record,same)

def pendingNode(+node: R.Node,slot: R.Slot) -> {locals(R.Node.with_pending(node,slot)) == locals(node) : Locals}:
  match node:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram, +rebaseOwed}:
      {==}

def configNode(+node: R.Node,value: U32) -> {locals(R.Node.with_config(node,value)) == locals(node) : Locals}:
  match node:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram, +rebaseOwed}:
      {==}

def timeNode(+node: R.Node,value: Nat) -> {locals(R.Node.with_time(node,value)) == locals(node) : Locals}:
  match node:
    case R.Node{+kind,+value,+pending,+equals,+config,+flags,+status,+time,+notified,+deps,+depsTail,+depGen,+subs,+subsTail,+height,+nextHeap,+prevHeap,+parent,+firstChild,+nextSibling,+prevSibling,+expr,+modified,+prevValue,+target,+loading,+x,+parentComputed,+scope,+childCount,+disposal,+cleanup,+effectProgram,+returnedCleanup,+errorProgram, +rebaseOwed}:
      {==}

def pending(+w: R.World,+id: Nat,+value: R.Value) -> {read(B.store_node(w,id,R.Node.with_pending(B.node(w,id),R.Present{value})),id) == read(w,id) : Locals}:
  store(w,id,R.Node.with_pending(B.node(w,id),R.Present{value}),pendingNode(B.node(w,id),R.Present{value}))

def config(+w: R.World,+id: Nat,+value: U32) -> {read(B.store_node(w,id,R.Node.with_config(B.node(w,id),value)),id) == read(w,id) : Locals}:
  store(w,id,R.Node.with_config(B.node(w,id),value),configNode(B.node(w,id),value))

def time(+w: R.World,+id: Nat,+value: Nat) -> {read(B.store_node(w,id,R.Node.with_time(B.node(w,id),value)),id) == read(w,id) : Locals}:
  store(w,id,R.Node.with_time(B.node(w,id),value),timeNode(B.node(w,id),value))

def promotedList(+w: R.World,+id: Nat,values: List<&2,Nat>) -> {read(R.World.with_promotedWrites(w,values),id) == read(w,id) : Locals}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def choice(+condition: Bool,+w: R.World,+id: Nat,+left: R.World,+right: R.World,yes: {read(left,id) == read(w,id) : Locals},no: {read(right,id) == read(w,id) : Locals}) -> {read(B.choose(~R.World,condition,_=>left,_=>right),id) == read(w,id) : Locals}:
  match condition:
    case True{}: yes
    case False{}: no

def promoted(+w: R.World,+id: Nat) -> {read(V.notePromotedWrite(w,id),id) == read(w,id) : Locals}:
  +bits = B.set(R.Node.config(B.node(w,id)),K.CONFIG_PROMOTED())
  +next = B.store_node(w,id,R.Node.with_config(B.node(w,id),bits))
  +changed = R.World.with_promotedWrites(next,B.append(Nat,R.World.promotedWrites(next),[id]))
  choice(Bool.or(R.World.running(w),B.has(R.Node.config(B.node(w,id)),K.CONFIG_PROMOTED())),w,id,w,changed,{==},Equal.trans(Locals,read(changed,id),read(next,id),read(w,id),promotedList(next,id,B.append(Nat,R.World.promotedWrites(next),[id])),config(w,id,bits)))

def finish(+w: R.World,+id: Nat,+staged: Bool,stamp: R.Stamp) -> R.World:
  B.choose(~R.World,Bool.and(staged,B.stampMatches(stamp,R.World.epoch(w))),_=>w,_=>B.schedule(W.insertSubs(w,id)))

def timed(+w: R.World,+id: Nat,k: R.NodeKind) -> R.World:
  B.choose(~R.World,B.computed(k),_=>B.store_node(w,id,R.Node.with_time(B.node(w,id),R.World.clock(w))),_=>w)

# No validity, health, node-kind or transaction assumptions are needed.
def stored(+w: R.World,+id: Nat,+value: R.Value,+staged: Bool) -> {W.stageStored(w,id,value,staged) == Stage.tail(w,id,value,B.node(w,id),staged) : R.World}:
  +put = B.store_node(w,id,R.Node.with_pending(B.node(w,id),R.Present{value}))
  +noted = B.choose(~R.World,Nat.is_ne(R.World.context(put),0n),_=>V.notePromotedWrite(put,id),_=>put)
  +notedSame = Equal.trans(Locals,read(noted,id),read(put,id),read(w,id),choice(Nat.is_ne(R.World.context(put),0n),put,id,V.notePromotedWrite(put,id),put,promoted(put,id),{==}),pending(w,id,value))
  +live = timed(noted,id,R.Node.kind(B.node(noted,id)))
  +cached = timed(noted,id,R.Node.kind(B.node(w,id)))
  +timeSame = Equal.trans(Locals,read(live,id),read(noted,id),read(w,id),choice(B.computed(R.Node.kind(B.node(noted,id))),noted,id,B.store_node(noted,id,R.Node.with_time(B.node(noted,id),R.World.clock(noted))),noted,time(noted,id,R.World.clock(noted)),{==}),notedSame)
  +sameKind = Equal.cong(Locals,R.NodeKind,x=>kind(x),read(noted,id),read(w,id),notedSame)
  +sameStamp = Equal.cong(Locals,R.Stamp,x=>notified(x),read(live,id),read(w,id),timeSame)
  +sameTime = Equal.cong(R.NodeKind,R.World,k=>timed(noted,id,k),R.Node.kind(B.node(noted,id)),R.Node.kind(B.node(w,id)),sameKind)
  Equal.trans(R.World,W.stageStored(w,id,value,staged),finish(live,id,staged,R.Node.notified(B.node(w,id))),Stage.tail(w,id,value,B.node(w,id),staged),Equal.cong(R.Stamp,R.World,stamp=>finish(live,id,staged,stamp),R.Node.notified(B.node(live,id)),R.Node.notified(B.node(w,id)),sameStamp),Equal.cong(R.World,R.World,state=>finish(state,id,staged,R.Node.notified(B.node(w,id))),live,cached,sameTime))

# Consumers derive both premises from the actual intake, not an assumed tail.
def resolved(+w: R.World,+next: R.World,+id: Nat,+value: R.Value,entered: {W.stageIntake(w,id,B.present(R.Node.pending(B.node(w,id)))) == next : R.World},nodes: {R.World.nodes(next) == R.World.nodes(w) : List<&2,R.Node>}) -> {W.stageResolved(w,id,value) == Stage.tail(next,id,value,B.node(w,id),B.present(R.Node.pending(B.node(w,id)))) : R.World}:
  +staged = B.present(R.Node.pending(B.node(w,id)))
  +sameNode = Equal.cong(List<&2,R.Node>,R.Node,rows=>B.get(R.Node,rows,id,B.blank_node()),R.World.nodes(next),R.World.nodes(w),nodes)
  Equal.trans(R.World,W.stageResolved(w,id,value),W.stageStored(next,id,value,staged),Stage.tail(next,id,value,B.node(w,id),staged),Equal.cong(R.World,R.World,state=>W.stageStored(state,id,value,staged),W.stageIntake(w,id,staged),next,entered),Equal.trans(R.World,W.stageStored(next,id,value,staged),Stage.tail(next,id,value,B.node(next,id),staged),Stage.tail(next,id,value,B.node(w,id),staged),stored(next,id,value,staged),Equal.cong(R.Node,R.World,node=>Stage.tail(next,id,value,node,staged),B.node(next,id),B.node(w,id),sameNode)))

def choiceNodes(+flag: Bool,+w: R.World,+yes: R.World,+no: R.World,left: {R.World.nodes(yes) == R.World.nodes(w) : List<&2,R.Node>},right: {R.World.nodes(no) == R.World.nodes(w) : List<&2,R.Node>}) -> {R.World.nodes(B.choose(~R.World,flag,_=>yes,_=>no)) == R.World.nodes(w) : List<&2,R.Node>}:
  match flag:
    case True{}: left
    case False{}: right

# Intake does not change node records, even when stashFlushed reports a
# missing-extension fault. No validity or extension-presence premise is needed.
def stashTailNodes(+w: R.World,+id: Nat) -> {R.World.nodes(Stage.stashTail(w,id)) == R.World.nodes(w) : List<&2,R.Node>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def faultNodes(+w: R.World,error: R.Fault) -> {R.World.nodes(R.World.with_fault(w,error)) == R.World.nodes(w) : List<&2,R.Node>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def stashNodes(+w: R.World,+id: Nat) -> {R.World.nodes(V.stashFlushed(w,id)) == R.World.nodes(w) : List<&2,R.Node>}:
  +saved = B.choose(~R.World,B.stampMatches(R.NodeExtension.flushedAt(B.extension(w,id)),R.World.clock(w)),_=>w,_=>Stage.stashTail(w,id))
  choiceNodes(Nat.is_eq(R.Node.x(B.node(w,id)),0n),w,R.World.with_fault(w,R.Unsupported{3n}),saved,faultNodes(w,R.Unsupported{3n}),choiceNodes(B.stampMatches(R.NodeExtension.flushedAt(B.extension(w,id)),R.World.clock(w)),w,w,Stage.stashTail(w,id),{==},stashTailNodes(w,id)))

def intakeNodes(+w: R.World,+id: Nat,+staged: Bool) -> {R.World.nodes(W.stageIntake(w,id,staged)) == R.World.nodes(w) : List<&2,R.Node>}:
  +inside = Bool.and(B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),Bool.not(R.World.running(w)))
  +saved = B.choose(~R.World,inside,_=>V.stashFlushed(w,id),_=>w)
  choiceNodes(staged,w,saved,W.queuePendingNode(w,id),choiceNodes(inside,w,V.stashFlushed(w,id),w,stashNodes(w,id),{==}),Queue.queuedNodes(w,id))
