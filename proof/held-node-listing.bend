# Actual holding of an allocated, previously unowned node. Only config and
# group membership change; its child pointer and existing extension survive.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ./transaction-list-construction.bend as Listed
import ./node-store-lookup.bend as Lens

def record(+w: R.World,+id: Nat) -> R.Node:
  R.Node.with_config(B.node(w,id),B.set(R.Node.config(B.node(w,id)),K.CONFIG_HELD()))

def configured(+w: R.World,+id: Nat) -> R.World:
  B.store_node(w,id,record(w,id))

def node(+w: R.World,+id: Nat,valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool}) -> {B.node(configured(w,id),id) == record(w,id) : R.Node}:
  Lens.nodeSame(w,id,record(w,id),valid)

def configX(+entry: R.Node,+config: U32) -> {R.Node.x(R.Node.with_config(entry,config)) == R.Node.x(entry) : Nat}:
  match entry:
    case R.Node{kind,value,pending,equals,old,flags,status,time,notified,deps,depsTail,depGen,subs,subsTail,height,nextHeap,prevHeap,parent,firstChild,nextSibling,prevSibling,expr,modified,prevValue,target,loading,x,parentComputed,scope,childCount,disposal,cleanup,effectProgram,returnedCleanup,errorProgram}: {==}

def configChild(+entry: R.Node,+config: U32) -> {R.Node.firstChild(R.Node.with_config(entry,config)) == R.Node.firstChild(entry) : Nat}:
  match entry:
    case R.Node{kind,value,pending,equals,old,flags,status,time,notified,deps,depsTail,depGen,subs,subsTail,height,nextHeap,prevHeap,parent,firstChild,nextSibling,prevSibling,expr,modified,prevValue,target,loading,x,parentComputed,scope,childCount,disposal,cleanup,effectProgram,returnedCleanup,errorProgram}: {==}

def pointer(+w: R.World,+id: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool}) -> {R.Node.x(B.node(configured(w,id),id)) == R.Node.x(B.node(w,id)) : Nat}:
  Equal.trans(Nat,R.Node.x(B.node(configured(w,id),id)),R.Node.x(record(w,id)),R.Node.x(B.node(w,id)),Equal.cong(R.Node,Nat,entry=>R.Node.x(entry),B.node(configured(w,id),id),record(w,id),node(w,id,valid)),configX(B.node(w,id),B.set(R.Node.config(B.node(w,id)),K.CONFIG_HELD())))

def extensions(+w: R.World,+id: Nat) -> {R.World.extensions(configured(w,id)) == R.World.extensions(w) : List<&2,R.NodeExtension>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def extension(+w: R.World,+id: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool}) -> {B.extension(configured(w,id),id) == B.extension(w,id) : R.NodeExtension}:
  Equal.trans(R.NodeExtension,B.extension(configured(w,id),id),B.get(R.NodeExtension,R.World.extensions(w),R.Node.x(B.node(configured(w,id),id)),B.blank_extension()),B.extension(w,id),Equal.cong(List<&2,R.NodeExtension>,R.NodeExtension,rows=>B.get(R.NodeExtension,rows,R.Node.x(B.node(configured(w,id),id)),B.blank_extension()),R.World.extensions(configured(w,id)),R.World.extensions(w),extensions(w,id)),Equal.cong(Nat,R.NodeExtension,at=>B.get(R.NodeExtension,R.World.extensions(w),at,B.blank_extension()),R.Node.x(B.node(configured(w,id),id)),R.Node.x(B.node(w,id)),pointer(w,id,valid)))

def exact(+w: R.World,+id: Nat,+offset: Nat,+slot: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},allocated: {R.Node.x(B.node(w,id)) == 1n+slot : Nat},unowned: {R.NodeExtension.transaction(B.extension(w,id)) == 0n : Nat}) -> {X.holdNode(w,id,1n+offset) == Listed.raw(configured(w,id),id,1n+offset) : R.World}:
  Listed.fresh(configured(w,id),id,offset,slot,Equal.trans(Nat,R.Node.x(B.node(configured(w,id),id)),R.Node.x(B.node(w,id)),1n+slot,pointer(w,id,valid),allocated),Equal.trans(Nat,R.NodeExtension.transaction(B.extension(configured(w,id),id)),R.NodeExtension.transaction(B.extension(w,id)),0n,Equal.cong(R.NodeExtension,Nat,entry=>R.NodeExtension.transaction(entry),B.extension(configured(w,id),id),B.extension(w,id),extension(w,id,valid)),unowned))

def read(+w: R.World,+id: Nat,+offset: Nat,+slot: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},+allocated: {R.Node.x(B.node(w,id)) == 1n+slot : Nat},+unowned: {R.NodeExtension.transaction(B.extension(w,id)) == 0n : Nat}) -> {B.node(X.holdNode(w,id,1n+offset),id) == record(w,id) : R.Node}:
  Equal.trans(R.Node,B.node(X.holdNode(w,id,1n+offset),id),B.node(Listed.raw(configured(w,id),id,1n+offset),id),record(w,id),Equal.cong(R.World,R.Node,state=>B.node(state,id),X.holdNode(w,id,1n+offset),Listed.raw(configured(w,id),id,1n+offset),exact(w,id,offset,slot,valid,allocated,unowned)),Equal.trans(R.Node,B.node(Listed.raw(configured(w,id),id,1n+offset),id),B.node(configured(w,id),id),record(w,id),Listed.nodeRaw(configured(w,id),id,1n+offset,id),node(w,id,valid)))

def setEmpty(+nodes: List<&2,R.Node>,+id: Nat,+entry: R.Node) -> {List.is_empty(&2,R.Node,List.set(&2,R.Node,nodes,id,entry)) == List.is_empty(&2,R.Node,nodes) : Bool}:
  match nodes id:
    case Nil{} n: {==}
    case head <> tail 0n: {==}
    case head <> tail 1n+p: {==}

def configuredEmpty(+w: R.World,+id: Nat) -> {List.is_empty(&2,R.Node,R.World.nodes(configured(w,id))) == List.is_empty(&2,R.Node,R.World.nodes(w)) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      setEmpty(nodes,id,record(w,id))

def configuredHealth(+w: R.World,+id: Nat) -> {B.ok(configured(w,id)) == B.ok(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def heldEmpty(+w: R.World,+id: Nat,+offset: Nat,+slot: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},+allocated: {R.Node.x(B.node(w,id)) == 1n+slot : Nat},+unowned: {R.NodeExtension.transaction(B.extension(w,id)) == 0n : Nat}) -> {List.is_empty(&2,R.Node,R.World.nodes(X.holdNode(w,id,1n+offset))) == List.is_empty(&2,R.Node,R.World.nodes(w)) : Bool}:
  +after = Listed.raw(configured(w,id),id,1n+offset)
  Equal.trans(Bool,List.is_empty(&2,R.Node,R.World.nodes(X.holdNode(w,id,1n+offset))),List.is_empty(&2,R.Node,R.World.nodes(after)),List.is_empty(&2,R.Node,R.World.nodes(w)),Equal.cong(R.World,Bool,state=>List.is_empty(&2,R.Node,R.World.nodes(state)),X.holdNode(w,id,1n+offset),after,exact(w,id,offset,slot,valid,allocated,unowned)),Equal.trans(Bool,List.is_empty(&2,R.Node,R.World.nodes(after)),List.is_empty(&2,R.Node,R.World.nodes(configured(w,id))),List.is_empty(&2,R.Node,R.World.nodes(w)),Equal.cong(List<&2,R.Node>,Bool,rows=>List.is_empty(&2,R.Node,rows),R.World.nodes(after),R.World.nodes(configured(w,id)),Listed.nodesRaw(configured(w,id),id,1n+offset)),configuredEmpty(w,id)))

def heldHealth(+w: R.World,+id: Nat,+offset: Nat,+slot: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},+allocated: {R.Node.x(B.node(w,id)) == 1n+slot : Nat},+unowned: {R.NodeExtension.transaction(B.extension(w,id)) == 0n : Nat}) -> {B.ok(X.holdNode(w,id,1n+offset)) == B.ok(w) : Bool}:
  +after = Listed.raw(configured(w,id),id,1n+offset)
  Equal.trans(Bool,B.ok(X.holdNode(w,id,1n+offset)),B.ok(after),B.ok(w),Equal.cong(R.World,Bool,state=>B.ok(state),X.holdNode(w,id,1n+offset),after,exact(w,id,offset,slot,valid,allocated,unowned)),Equal.trans(Bool,B.ok(after),B.ok(configured(w,id)),B.ok(w),Listed.healthyRaw(configured(w,id),id,1n+offset),configuredHealth(w,id)))
