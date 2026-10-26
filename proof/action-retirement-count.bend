# A valid live-group slot receives the scheduled count store. Output processing
# cannot change the projected count. These are actual record/store/schedule laws.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./node-store-lookup.bend as Lens
import ./transaction-positive-update.bend as Update
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output

def count(w: R.World,root: Nat) -> Nat:
  R.Transaction.open(B.transaction(w,root))

def store(+w: R.World,+root: Nat,+record: R.Transaction,valid: {Nat.is_lt(root,B.length(R.Transaction,R.World.txArena(w))) == True{} : Bool}) -> {B.transaction(B.store_transaction(w,root,record),root) == record : R.Transaction}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Lens.setSame(R.Transaction,txArena,root,record,B.blank_transaction(),valid)

def target(+w: R.World,+root: Nat,+remaining: Nat,valid: {Nat.is_lt(root,B.length(R.Transaction,R.World.txArena(w))) == True{} : Bool}) -> {count(Exit.target(w,root,remaining),root) == remaining : Nat}:
  +next = A.exit(w)
  +record = R.Transaction.with_open(B.transaction(next,root),remaining)
  +stored = B.store_transaction(next,root,record)
  +fits = Equal.trans(Bool,Nat.is_lt(root,B.length(R.Transaction,R.World.txArena(next))),Nat.is_lt(root,B.length(R.Transaction,R.World.txArena(w))),True{},Equal.cong(List<&2,R.Transaction>,Bool,rows=>Nat.is_lt(root,B.length(R.Transaction,rows)),R.World.txArena(next),R.World.txArena(w),Exit.exitArena(w)),valid)
  Equal.trans(Nat,count(Exit.target(w,root,remaining),root),count(stored,root),remaining,Equal.cong(R.Transaction,Nat,t=>R.Transaction.open(t),B.transaction(B.schedule(stored),root),B.transaction(stored,root),Update.scheduledRecord(stored,root)),Equal.trans(Nat,count(stored,root),R.Transaction.open(record),remaining,Equal.cong(R.Transaction,Nat,t=>R.Transaction.open(t),B.transaction(stored,root),record,store(next,root,record,fits)),Update.openSetter(B.transaction(next,root),remaining)))

def output(+w: R.World,+root: Nat) -> {count(Output.outer(w),root) == count(w,root) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}
