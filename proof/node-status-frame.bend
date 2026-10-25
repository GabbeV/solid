# All node status words survive source registration, including extension
# allocation. This derives notification's carry from the actual input status.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/extension.bend as E
import ../runtime/constants.bend as K
import ./node-observation-lens.bend as Lens
import ./pending-add-frame.bend as Add
import ./pending-notification-carrier.bend as Notify


def project(node: R.Node) -> U32:
  R.Node.status(node)

def observe(w: R.World) -> List<&2,U32>:
  Lens.observe(U32,project,w)

def store(+w: R.World,+node: Nat,+record: R.Node,same: {R.Node.status(record) == R.Node.status(B.node(w,node)) : U32}) -> {observe(B.store_node(w,node,record)) == observe(w) : List<&2,U32>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Lens.set(U32,project,nodes,node,record,same)

def extensions(+w: R.World,+extensions: List<&2,R.NodeExtension>) -> {observe(R.World.with_extensions(w,extensions)) == observe(w) : List<&2,U32>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def pending(+w: R.World,sets: List<&2,List<&2,Nat>>) -> {observe(R.World.with_pendingSets(w,sets)) == observe(w) : List<&2,U32>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def extension(+w: R.World,+node: Nat,+record: R.NodeExtension) -> {observe(B.store_extension(w,node,record)) == observe(w) : List<&2,U32>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def set(+w: R.World,+set: Nat,+items: List<&2,Nat>) -> {observe(B.store_pendingSet(w,set,items)) == observe(w) : List<&2,U32>}:
  pending(w,List.set(&2,List<&2,Nat>,R.World.pendingSets(w),set,items))

def statusX(+node: R.Node,+value: Nat) -> {R.Node.status(R.Node.with_x(node,value)) == R.Node.status(node) : U32}:
  match node:
    case R.Node{kind, value, pending, equals, config, flags, status, time, notified, deps, depsTail, depGen, subs, subsTail, height, nextHeap, prevHeap, parent, firstChild, nextSibling, prevSibling, expr, modified, prevValue, target, loading, x, parentComputed, scope, childCount, disposal, cleanup, effectProgram, returnedCleanup, errorProgram}:
      {==}

def ext(+w: R.World,+node: Nat) -> {observe(E.ext(w,node)) == observe(w) : List<&2,U32>}:
  +index = B.length(R.NodeExtension,R.World.extensions(w))
  +next = R.World.with_extensions(w,B.append(R.NodeExtension,R.World.extensions(w),[B.blank_extension()]))
  +grown = B.store_node(next,node,R.Node.with_x(B.node(next,node),index))
  Add.choice(List<&2,U32>,state=>observe(state),Nat.is_ne(R.Node.x(B.node(w,node)),0n),w,w,grown,{==},Equal.trans(List<&2,U32>,observe(grown),observe(next),observe(w),store(next,node,R.Node.with_x(B.node(next,node),index),statusX(B.node(next,node),index)),extensions(w,B.append(R.NodeExtension,R.World.extensions(w),[B.blank_extension()]))))

def added(+w: R.World,+node: Nat,+source: Nat) -> {observe(B.first(R.World,Bool,P.addPendingSource(w,node,source))) == observe(w) : List<&2,U32>}:
  Add.add(List<&2,U32>,state=>observe(state),pending,extension,set,ext,w,node,source)

def addStatus(+w: R.World,+node: Nat,+source: Nat,+read: Nat) -> {R.Node.status(B.node(B.first(R.World,Bool,P.addPendingSource(w,node,source)),read)) == R.Node.status(B.node(w,read)) : U32}:
  Lens.readWorld(U32,project,w,B.first(R.World,Bool,P.addPendingSource(w,node,source)),read,added(w,node,source))

def select(+flags: U32) -> U32:
  B.set(K.STATUS_PENDING(),B.choose(~U32,B.has(flags,K.STATUS_NO_VALUE()),_=>K.STATUS_UNINITIALIZED(),_=>U32.and(flags,K.STATUS_UNINITIALIZED())))

def inputFlags(+w: R.World,+node: Nat,+source: Nat) -> {Notify.flags(B.first(R.World,Bool,P.addPendingSource(w,node,source)),node) == select(R.Node.status(B.node(w,node))) : U32}:
  Equal.cong(U32,U32,status=>select(status),R.Node.status(B.node(B.first(R.World,Bool,P.addPendingSource(w,node,source)),node)),R.Node.status(B.node(w,node)),addStatus(w,node,source,node))
