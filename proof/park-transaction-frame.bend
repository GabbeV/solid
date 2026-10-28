# All default parking branches preserve group fields other than membership.
# This is a safety frame even on exhausted/unsupported paths, not success.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/scheduler.bend as S
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ../runtime/equality.bend as EQ
import ./transaction-membership-frame.bend as F

def equal(+w: R.World,+id: Nat) -> {F.observe(S.parkEqual(w,id)) == F.observe(w) : List<&2,R.Transaction>}:
  F.storeNode(w,id,R.Node.with_pending(R.Node.with_config(B.node(w,id),B.clear(R.Node.config(B.node(w,id)),K.CONFIG_STAGED())),R.Empty{}))

def changed(+w: R.World,+id: Nat,+tx: Nat,+eligible: Bool) -> {F.observe(S.parkChanged(w,id,tx,eligible)) == F.observe(w) : List<&2,R.Transaction>}:
  +next = B.choose(~R.World,eligible,_=>X.holdNode(w,id,tx),_=>w)
  +held = F.choice(eligible,w,X.holdNode(w,id,tx),w,F.node(w,id,tx),{==})
  F.compose(w,next,S.parkChanged(w,id,tx,eligible),F.choice(B.has(R.Node.config(B.node(next,id)),K.CONFIG_STAGED()),next,X.holdFrame(next,id,tx),next,F.frame(next,id,tx),{==}),held)

def compare(+w: R.World,+id: Nat,+tx: Nat,+eligible: Bool) -> R.World:
  B.choose(~R.World,Nat.is_ne(EQ.custom(w,id),0n),_=>R.World.with_fault(w,R.Unsupported{23n}),_=>B.choose(~R.World,EQ.isSame(w,id,R.Node.value(B.node(w,id)),B.current(B.node(w,id))),_=>S.parkEqual(w,id),_=>S.parkChanged(w,id,tx,eligible)))

def compareFrame(+w: R.World,+id: Nat,+tx: Nat,+eligible: Bool) -> {F.observe(compare(w,id,tx,eligible)) == F.observe(w) : List<&2,R.Transaction>}:
  F.choice(Nat.is_ne(EQ.custom(w,id),0n),w,R.World.with_fault(w,R.Unsupported{23n}),B.choose(~R.World,EQ.isSame(w,id,R.Node.value(B.node(w,id)),B.current(B.node(w,id))),_=>S.parkEqual(w,id),_=>S.parkChanged(w,id,tx,eligible)),F.fault(w,R.Unsupported{23n}),F.choice(EQ.isSame(w,id,R.Node.value(B.node(w,id)),B.current(B.node(w,id))),w,S.parkEqual(w,id),S.parkChanged(w,id,tx,eligible),equal(w,id),changed(w,id,tx,eligible)))

def select(+w: R.World,+id: Nat,+tx: Nat,+eligible: Bool) -> R.World:
  B.choose(~R.World,Bool.and(eligible,S.parkLoading(w,id)),_=>w,_=>B.choose(~R.World,Bool.and(eligible,S.parkCanCompare(w,id)),_=>compare(w,id,tx,eligible),_=>S.parkChanged(w,id,tx,eligible)))

def selectFrame(+w: R.World,+id: Nat,+tx: Nat,+eligible: Bool) -> {F.observe(select(w,id,tx,eligible)) == F.observe(w) : List<&2,R.Transaction>}:
  F.choice(Bool.and(eligible,S.parkLoading(w,id)),w,w,B.choose(~R.World,Bool.and(eligible,S.parkCanCompare(w,id)),_=>compare(w,id,tx,eligible),_=>S.parkChanged(w,id,tx,eligible)),{==},F.choice(Bool.and(eligible,S.parkCanCompare(w,id)),w,compare(w,id,tx,eligible),S.parkChanged(w,id,tx,eligible),compareFrame(w,id,tx,eligible),changed(w,id,tx,eligible)))

def node(+w: R.World,+id: Nat,+tx: Nat) -> {F.observe(S.parkPendingNode(w,id,tx)) == F.observe(w) : List<&2,R.Transaction>}:
  selectFrame(w,id,tx,S.parkEligible(w,id))

def loop(+fuel: Nat,+w: R.World,+tx: Nat,+index: Nat,+count: Nat) -> {F.observe(S.park_list(fuel,w,tx,index,count)) == F.observe(w) : List<&2,R.Transaction>}:
  match fuel:
    case 0n: F.fault(w,R.Exhausted{})
    case 1n+p:
      +id = B.get(Nat,R.World.pendingNodes(w),index,0n)
      +next = S.parkPendingNode(w,id,tx)
      +continued = B.choose(~R.World,B.ok(next),_=>S.park_list(p,next,tx,1n+index,count),_=>next)
      F.choice(Nat.is_ge(index,count),w,w,continued,{==},F.compose(w,next,continued,F.choice(B.ok(next),next,S.park_list(p,next,tx,1n+index,count),next,loop(p,next,tx,1n+index,count),{==}),node(w,id,tx)))

def pending(+w: R.World) -> {F.observe(R.World.with_pendingNodes(w,[])) == F.observe(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def captured(+w: R.World,+tx: Nat) -> {F.observe(S.parkPendingNodes(w,tx)) == F.observe(w) : List<&2,R.Transaction>}:
  +next = S.park_list(1n+Nat.add(B.budget(w),B.length(Nat,R.World.pendingNodes(w))),w,tx,0n,B.length(Nat,R.World.pendingNodes(w)))
  F.compose(w,next,S.parkPendingNodes(w,tx),F.choice(B.ok(next),next,R.World.with_pendingNodes(next,[]),next,pending(next),{==}),loop(1n+Nat.add(B.budget(w),B.length(Nat,R.World.pendingNodes(w))),w,tx,0n,B.length(Nat,R.World.pendingNodes(w))))

def count(+w: R.World,+tx: Nat,+group: Nat) -> {R.Transaction.open(B.transaction(S.parkPendingNodes(w,tx),group)) == R.Transaction.open(B.transaction(w,group)) : Nat}:
  F.count(w,S.parkPendingNodes(w,tx),group,captured(w,tx))
