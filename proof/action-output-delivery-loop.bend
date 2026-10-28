# Drain the non-immediate output observer prefix through actual Core.step.
# Each observer appends one host request, without executing its callback here.
# Source/transaction/action state and caller work/values remain exact.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/flight.bend as F
import ./action-body-return.bend as Body
import ./pending-stack-history.bend as Steps
import ./core-prefix-compose.bend as Prefix

def outer(w: R.World) -> R.World:
  R.World.with_hostJobs(w,[])

def run(observers: List<&2,Nat>,w: R.World,+rejected: Bool,+value: R.Value) -> R.World:
  match observers:
    case Nil{}: w
    case id <> tail: run(tail,F.enqueueDelivery(w,id,rejected,value),rejected,value)

def cost(observers: List<&2,Nat>) -> Nat:
  1n+B.length(Nat,observers)

def start(w: R.World,observers: List<&2,Nat>,rest: List<&2,C.Task>,stack: List<&2,R.Value>,rejected: Bool,value: R.Value) -> C.Machine:
  C.Machine{w,C.DeliverObservers{observers,False{},rejected,value} <> rest,stack}

def enqueueOuter(+w: R.World,+id: Nat,+rejected: Bool,+value: R.Value) -> {outer(F.enqueueDelivery(w,id,rejected,value)) == outer(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def enqueueFault(+w: R.World,+id: Nat,+rejected: Bool,+value: R.Value) -> {R.World.fault(F.enqueueDelivery(w,id,rejected,value)) == R.World.fault(w) : R.Fault}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def runOuter(+observers: List<&2,Nat>,+w: R.World,+rejected: Bool,+value: R.Value) -> {outer(run(observers,w,rejected,value)) == outer(w) : R.World}:
  match observers:
    case Nil{}: {==}
    case +id <> +tail:
      Equal.trans(R.World,outer(run(id <> tail,w,rejected,value)),outer(F.enqueueDelivery(w,id,rejected,value)),outer(w),runOuter(tail,F.enqueueDelivery(w,id,rejected,value),rejected,value),enqueueOuter(w,id,rejected,value))

def complete(+observers: List<&2,Nat>,+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,+healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}) -> {Steps.iterate(cost(observers),start(w,observers,rest,stack,rejected,value)) == C.Machine{run(observers,w,rejected,value),rest,stack} : C.Machine}:
  match observers:
    case Nil{}:
      Body.healthyStep(w,C.DeliverObservers{[],False{},rejected,value},rest,stack,Body.health(w,healthy))
    case +id <> +tail:
      +next = F.enqueueDelivery(w,id,rejected,value)
      +good = Equal.trans(R.Fault,R.World.fault(next),R.World.fault(w),R.Healthy{},enqueueFault(w,id,rejected,value),healthy)
      Prefix.compose(1n,cost(tail),start(w,id <> tail,rest,stack,rejected,value),start(next,tail,rest,stack,rejected,value),C.Machine{run(tail,next,rejected,value),rest,stack},Body.healthyStep(w,C.DeliverObservers{id <> tail,False{},rejected,value},rest,stack,Body.health(w,healthy)),complete(tail,next,rest,stack,rejected,value,good))
