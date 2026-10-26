# Source stage intake, including already-held snapshot saving. Only initial
# representation facts are assumed; the retained nodes/links/clock come from
# actual stash/queue operations, not assumed successful traversal or health.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ../runtime/read-state.bend as Read
import ../runtime/constants.bend as K
import ./staging-committed-frame.bend as Stage
import ./ordinary-stage-intake.bend as Queue
import ./ordinary-write-outer.bend as Outer
import ./held-stash-frame.bend as Stash
import ./held-write-outer.bend as Frame
import ./ordinary-profile-transport.bend as Transfer

def readNodes(+w: R.World,+slot: Nat) -> {R.World.nodes(Stash.observe(w,slot)) == R.World.nodes(w) : List<&2,R.Node>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def stashNodes(+w: R.World,+id: Nat,existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}) -> {R.World.nodes(Read.stashFlushed(w,id)) == R.World.nodes(w) : List<&2,R.Node>}:
  +next = Read.stashFlushed(w,id)
  +slot = R.Node.x(B.node(w,id))
  Equal.trans(List<&2,R.Node>,R.World.nodes(next),R.World.nodes(Stash.observe(next,slot)),R.World.nodes(w),Equal.sym(List<&2,R.Node>,R.World.nodes(Stash.observe(next,slot)),R.World.nodes(next),readNodes(next,slot)),Equal.trans(List<&2,R.Node>,R.World.nodes(Stash.observe(next,slot)),R.World.nodes(Stash.observe(w,slot)),R.World.nodes(w),Equal.cong(R.World,List<&2,R.Node>,state=>R.World.nodes(state),Stash.observe(next,slot),Stash.observe(w,slot),Stash.actual(w,id,existing)),readNodes(w,slot)))

def choiceNodes(+flag: Bool,+w: R.World,+yes: R.World,+no: R.World,left: {R.World.nodes(yes) == R.World.nodes(w) : List<&2,R.Node>},right: {R.World.nodes(no) == R.World.nodes(w) : List<&2,R.Node>}) -> {R.World.nodes(B.choose(~R.World,flag,_=>yes,_=>no)) == R.World.nodes(w) : List<&2,R.Node>}:
  match flag:
    case True{}: left
    case False{}: right

def entered(+w: R.World,+id: Nat) -> R.World:
  Stage.intake(w,id,B.node(w,id),B.present(R.Node.pending(B.node(w,id))))

def frameAt(+w: R.World,+id: Nat,+staged: Bool,existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}) -> {Frame.observe(Stage.intake(w,id,B.node(w,id),staged),R.Node.x(B.node(w,id))) == Frame.observe(w,R.Node.x(B.node(w,id))) : R.World}:
  +slot = R.Node.x(B.node(w,id))
  +inside = Bool.and(B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),Bool.not(R.World.running(w)))
  +saved = B.choose(~R.World,inside,_=>Read.stashFlushed(w,id),_=>w)
  Frame.choice(staged,w,saved,W.queuePendingNode(w,id),slot,Frame.choice(inside,w,Read.stashFlushed(w,id),w,slot,Frame.fromStash(w,Read.stashFlushed(w,id),slot,Stash.actual(w,id,existing)),{==}),Frame.fromOuter(w,W.queuePendingNode(w,id),slot,Queue.queuedFrame(w,id)))

def nodesAt(+w: R.World,+id: Nat,+staged: Bool,existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}) -> {R.World.nodes(Stage.intake(w,id,B.node(w,id),staged)) == R.World.nodes(w) : List<&2,R.Node>}:
  +inside = Bool.and(B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),Bool.not(R.World.running(w)))
  +saved = B.choose(~R.World,inside,_=>Read.stashFlushed(w,id),_=>w)
  choiceNodes(staged,w,saved,W.queuePendingNode(w,id),choiceNodes(inside,w,Read.stashFlushed(w,id),w,stashNodes(w,id,existing),{==}),Queue.queuedNodes(w,id))

def frame(+w: R.World,+id: Nat,existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}) -> {Frame.observe(entered(w,id),R.Node.x(B.node(w,id))) == Frame.observe(w,R.Node.x(B.node(w,id))) : R.World}:
  frameAt(w,id,B.present(R.Node.pending(B.node(w,id))),existing)

def nodes(+w: R.World,+id: Nat,existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}) -> {R.World.nodes(entered(w,id)) == R.World.nodes(w) : List<&2,R.Node>}:
  nodesAt(w,id,B.present(R.Node.pending(B.node(w,id))),existing)

def budget(+w: R.World,+id: Nat,+existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}) -> {B.budget(entered(w,id)) == B.budget(w) : Nat}:
  Transfer.budget(w,entered(w,id),nodes(w,id,existing),Frame.sameLinks(w,entered(w,id),R.Node.x(B.node(w,id)),frame(w,id,existing)))
