# The non-held stage intake changes only pending-queue bookkeeping. This
# includes both first-write and already-staged paths, preserving actual nodes.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ../runtime/read-state.bend as Read
import ../runtime/constants.bend as K
import ./staging-committed-frame.bend as Stage
import ./ordinary-write-outer.bend as Frame

def queuedFrame(+w: R.World,+id: Nat) -> {Frame.observe(W.queuePendingNode(w,id)) == Frame.observe(w) : R.World}:
  +next = R.World.with_pendingNodes(w,B.append(Nat,R.World.pendingNodes(w),[id]))
  Frame.compose(w,next,W.queuePendingNode(w,id),Frame.choice(Bool.not(R.World.running(next)),next,R.World.with_unflushedStaged(next,True{}),next,Frame.worldUnflushedStaged(next,True{}),{==}),Frame.worldPendingNodes(w,B.append(Nat,R.World.pendingNodes(w),[id])))

def simple(+w: R.World,+id: Nat,staged: Bool) -> R.World:
  B.choose(~R.World,staged,_=>w,_=>W.queuePendingNode(w,id))

def exact(+w: R.World,+id: Nat,staged: Bool,ordinary: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()) == False{} : Bool}) -> {Stage.intake(w,id,B.node(w,id),staged) == simple(w,id,staged) : R.World}:
  match staged:
    case False{}: {==}
    case True{}:
      Equal.cong(Bool,R.World,held=>B.choose(~R.World,Bool.and(held,Bool.not(R.World.running(w))),_=>Read.stashFlushed(w,id),_=>w),B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),False{},ordinary)

def frame(+w: R.World,+id: Nat,+staged: Bool) -> {Frame.observe(simple(w,id,staged)) == Frame.observe(w) : R.World}:
  Frame.choice(staged,w,w,W.queuePendingNode(w,id),{==},queuedFrame(w,id))

def queuedNodes(+w: R.World,+id: Nat) -> {R.World.nodes(W.queuePendingNode(w,id)) == R.World.nodes(w) : List<&2,R.Node>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match running:
        case False{}: {==}
        case True{}: {==}

def nodes(+w: R.World,+id: Nat,staged: Bool) -> {R.World.nodes(simple(w,id,staged)) == R.World.nodes(w) : List<&2,R.Node>}:
  match staged:
    case True{}: {==}
    case False{}: queuedNodes(w,id)
