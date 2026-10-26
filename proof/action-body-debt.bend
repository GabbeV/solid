# A direct debt corollary of constructed actual body completion. Output adoption
# and helper suffixes cannot reopen the retired scheduling-group obligation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ./action-body-constructed.bend as Body
import ./action-body-retirement.bend as Retire
import ./action-body-guard.bend as Guard
import ./action-output-frame.bend as Output
import ./action-helper-context.bend as Context
import ./action-wait-history.bend as History

def count(w: R.World) -> Nat:
  R.Transaction.open(B.transaction(w,1n))

def outerCount(+w: R.World) -> {count(Output.outer(w)) == count(w) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def modelZero(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {count(Retire.target(Body.model(values,value,tail,prefix),1n,0n)) == 0n : Nat}:
  {==}

def targetZero(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {count(Retire.target(Body.ready(values,value,tail,prefix),1n,0n)) == 0n : Nat}:
  Equal.trans(Nat,count(Retire.target(Body.ready(values,value,tail,prefix),1n,0n)),count(Retire.target(Body.model(values,value,tail,prefix),1n,0n)),0n,Equal.cong(R.World,Nat,w=>count(Retire.target(w,1n,0n)),Body.ready(values,value,tail,prefix),Body.model(values,value,tail,prefix),Body.shape(values,value,tail,prefix)),modelZero(values,value,tail,prefix))

def zero(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {count(C.world(Body.returned(values,value,tail,prefix,rest,stack,incoming,rejected))) == 0n : Nat}:
  +w = C.world(Body.returned(values,value,tail,prefix,rest,stack,incoming,rejected))
  +target = Retire.target(Body.ready(values,value,tail,prefix),1n,0n)
  Equal.trans(Nat,count(w),count(Output.outer(w)),0n,Equal.sym(Nat,count(Output.outer(w)),count(w),outerCount(w)),Equal.trans(Nat,count(Output.outer(w)),count(Output.outer(target)),0n,Equal.cong(R.World,Nat,next=>count(next),Output.outer(w),Output.outer(target),Body.completedOuter(values,value,tail,prefix,rest,stack,incoming,rejected)),Equal.trans(Nat,count(Output.outer(target)),count(target),0n,outerCount(target),targetZero(values,value,tail,prefix))))

def suffixZero(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+events: List<&2,History.WaitEvent>) -> {count(C.world(Guard.after(values,value,tail,prefix,rest,stack,incoming,rejected,events))) == 0n : Nat}:
  +before = C.world(Body.returned(values,value,tail,prefix,rest,stack,incoming,rejected))
  Equal.trans(Nat,count(History.run(events,before)),count(before),0n,Equal.cong(List<&2,R.Transaction>,Nat,rows=>R.Transaction.open(B.get(R.Transaction,rows,1n,B.blank_transaction())),R.World.txArena(History.run(events,before)),R.World.txArena(before),Context.historyArena(events,before)),zero(values,value,tail,prefix,rest,stack,incoming,rejected))
