# Output masking and actual retirement/schedule stores retain the body fault.
# Together with the body invariant this derives a healthy output-prefix entry.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./action-body-return.bend as Body
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./held-source-view.bend as View
import ./held-source-operations.bend as Source

def outputFault(+w: R.World) -> {R.World.fault(Output.outer(w)) == R.World.fault(w) : R.Fault}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def storeFault(+w: R.World,+root: Nat,+record: R.Transaction) -> {R.World.fault(B.store_transaction(w,root,record)) == R.World.fault(w) : R.Fault}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def scheduleFault(+w: R.World) -> {R.World.fault(B.schedule(w)) == R.World.fault(w) : R.Fault}:
  View.sameFault(w,B.schedule(w),Source.schedule(w))

def targetFault(+w: R.World,+root: Nat,+remaining: Nat) -> {R.World.fault(Exit.target(w,root,remaining)) == R.World.fault(w) : R.Fault}:
  +next = A.exit(w)
  +record = R.Transaction.with_open(B.transaction(next,root),remaining)
  +stored = B.store_transaction(next,root,record)
  Equal.trans(R.Fault,R.World.fault(Exit.target(w,root,remaining)),R.World.fault(stored),R.World.fault(w),scheduleFault(stored),Equal.trans(R.Fault,R.World.fault(stored),R.World.fault(next),R.World.fault(w),storeFault(next,root,record),Body.exitFault(w)))

def healthy(+written: R.World,+actual: R.World,+root: Nat,+remaining: Nat,body: {R.World.fault(written) == R.Healthy{} : R.Fault},completed: {Output.outer(actual) == Output.outer(Exit.target(written,root,remaining)) : R.World}) -> {R.World.fault(actual) == R.Healthy{} : R.Fault}:
  +target = Exit.target(written,root,remaining)
  Equal.trans(R.Fault,R.World.fault(actual),R.World.fault(Output.outer(actual)),R.Healthy{},Equal.sym(R.Fault,R.World.fault(Output.outer(actual)),R.World.fault(actual),outputFault(actual)),Equal.trans(R.Fault,R.World.fault(Output.outer(actual)),R.World.fault(Output.outer(target)),R.Healthy{},Equal.cong(R.World,R.Fault,w=>R.World.fault(w),Output.outer(actual),Output.outer(target),completed),Equal.trans(R.Fault,R.World.fault(Output.outer(target)),R.World.fault(target),R.Healthy{},outputFault(target),Equal.trans(R.Fault,R.World.fault(target),R.World.fault(written),R.Healthy{},targetFault(written,root,remaining),body))))
