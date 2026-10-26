# Initial certificate for selecting an already-known fresh captured group.
# The virtual selection changes only the ambient field that actual joinFuture
# will choose; all source, allocation, cache and health facts concern the input.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./action-body-entry.bend as Entry
import ./held-write-profile.bend as P
import ./held-source-view.bend as View
import ./held-source-transfer.bend as Transfer
import ./held-preparation-source.bend as Prepare

def originalTerminal(+w: R.World,+root: Nat) -> {R.Transaction.into(B.transaction(Prepare.flush(w,root),root)) == R.Transaction.into(B.transaction(w,root)) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def actual(+w: R.World,+id: Nat,+actor: Nat,+offset: Nat,+tail: R.Expr,+initial: P.Profile<Prepare.flush(w,1n+offset),id,offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == 1n+offset : Nat},empty: {R.World.flushTransaction(w) == 0n : Nat}) -> P.Profile<Entry.prepared(w,actor,tail),id,offset>:
  +root = {1n+offset : Nat}
  +selected = Prepare.flush(w,root)
  +next = Entry.prepared(w,actor,tail)
  +stopped = Equal.trans(Nat,R.Transaction.into(B.transaction(w,root)),R.Transaction.into(B.transaction(selected,root)),0n,Equal.sym(Nat,R.Transaction.into(B.transaction(selected,root)),R.Transaction.into(B.transaction(w,root)),originalTerminal(w,root)),P.terminal(selected,id,offset,initial))
  Transfer.transfer(selected,next,id,offset,initial,Prepare.actual(w,actor,offset,tail,captured,empty,stopped))

def current(+w: R.World,+id: Nat,+actor: Nat,+offset: Nat,+tail: R.Expr,+initial: P.Profile<w,id,offset>,captured: {R.ActionState.transaction(A.get(w,actor)) == 1n+offset : Nat}) -> P.Profile<Entry.prepared(w,actor,tail),id,offset>:
  Transfer.transfer(w,Entry.prepared(w,actor,tail),id,offset,initial,Prepare.current(w,actor,offset,tail,captured,P.future(w,id,offset,initial),P.terminal(w,id,offset,initial)))
