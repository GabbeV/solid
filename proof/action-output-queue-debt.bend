# Non-immediate observer delivery only appends host requests. The actual
# queue drain therefore retains obligation count; callbacks are not run here.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./action-output-continuation.bend as Queue
import ./action-output-delivery-loop.bend as Loop
import ./action-retirement-count.bend as Count
import ./held-count-certificate.bend as Debt
import ./pending-stack-history.bend as Steps

def masked(+w: R.World,+root: Nat) -> {Count.count(Loop.outer(w),root) == Count.count(w,root) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def frame(+machine: C.Machine,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+form: Queue.Queue<machine,rest,stack>,+root: Nat) -> {Count.count(Queue.world(machine,rest,stack,form),root) == Count.count(C.world(machine),root) : Nat}:
  +next = Queue.world(machine,rest,stack,form)
  Equal.trans(Nat,Count.count(next,root),Count.count(Loop.outer(next),root),Count.count(C.world(machine),root),Equal.sym(Nat,Count.count(Loop.outer(next),root),Count.count(next,root),masked(next,root)),Equal.trans(Nat,Count.count(Loop.outer(next),root),Count.count(Loop.outer(C.world(machine)),root),Count.count(C.world(machine),root),Equal.cong(R.World,Nat,w=>Count.count(w,root),Loop.outer(next),Loop.outer(C.world(machine)),Queue.frame(machine,rest,stack,form)),masked(C.world(machine),root)))

def remaining(+before: C.Machine,+steps: Nat,+id: Nat,+offset: Nat,+remaining: Nat,outcome: Debt.Outcome<before,steps,id,offset,remaining>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+form: Queue.Queue<Steps.iterate(steps,before),rest,stack>) -> {Count.count(Queue.world(Steps.iterate(steps,before),rest,stack,form),1n+offset) == remaining : Nat}:
  Equal.trans(Nat,Count.count(Queue.world(Steps.iterate(steps,before),rest,stack,form),1n+offset),Count.count(C.world(Steps.iterate(steps,before)),1n+offset),remaining,frame(Steps.iterate(steps,before),rest,stack,form,1n+offset),Debt.count(before,steps,id,offset,remaining,outcome))
