# A literal generator protocol result terminates without a callback-termination
# premise. Two real Core.step calls then enter the actual done/output operation.
# The caller's observer-delivery/slice-end/flush continuations remain queued.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver
import ./action-output-frame.bend as Output


def start(w: R.World,rest: List<&2,C.Task>,+stack: List<&2,R.Value>,id: Nat,value: R.Value) -> C.Machine:
  C.Machine{w,C.Evaluate{R.Literal{R.StepResult{True{},value}},R.Undefined{}} <> C.ActionStepReturn{id,stack} <> rest,stack}

def returned(w: R.World,rest: List<&2,C.Task>,+stack: List<&2,R.Value>,id: Nat,value: R.Value) -> C.Machine:
  C.Machine{w,C.ActionStepReturn{id,stack} <> rest,R.StepResult{True{},value} <> stack}

def healthyStep(+w: R.World,+task: C.Task,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,healthy: {B.ok(w) == True{} : Bool}) -> {C.step(C.Machine{w,task <> rest,stack}) == C.dispatch(w,task <> rest,stack) : C.Machine}:
  Equal.cong(Bool,C.Machine,flag=>B.choose(~C.Machine,flag,_=>C.dispatch(w,task <> rest,stack),_=>C.unwind(w,task <> rest,stack)),B.ok(w),True{},healthy)

def health(+w: R.World,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}) -> {B.ok(w) == True{} : Bool}:
  Equal.cong(R.Fault,Bool,fault=>B.healthy(fault),R.World.fault(w),R.Healthy{},healthy)

def exitFault(+w: R.World) -> {R.World.fault(A.exit(w)) == R.World.fault(w) : R.Fault}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def evaluated(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}) -> {C.step(start(w,rest,stack,id,value)) == returned(w,rest,stack,id,value) : C.Machine}:
  healthyStep(w,C.Evaluate{R.Literal{R.StepResult{True{},value}},R.Undefined{}},C.ActionStepReturn{id,stack} <> rest,stack,health(w,healthy))

def returnedExact(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}) -> {C.actionStepReturn(w,rest,R.StepResult{True{},value} <> stack,id,stack) == C.actionDone(A.exit(w),rest,stack,id,False{},value) : C.Machine}:
  Equal.cong(R.Fault,C.Machine,fault=>C.actionStepFault(A.exit(w),rest,R.StepResult{True{},value} <> stack,id,stack,fault),R.World.fault(A.exit(w)),R.Healthy{},Equal.trans(R.Fault,R.World.fault(A.exit(w)),R.World.fault(w),R.Healthy{},exitFault(w),healthy))

def finishes(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}) -> {C.step(returned(w,rest,stack,id,value)) == C.actionDone(A.exit(w),rest,stack,id,False{},value) : C.Machine}:
  Equal.trans(C.Machine,C.step(returned(w,rest,stack,id,value)),C.actionStepReturn(w,rest,R.StepResult{True{},value} <> stack,id,stack),C.actionDone(A.exit(w),rest,stack,id,False{},value),healthyStep(w,C.ActionStepReturn{id,stack},rest,R.StepResult{True{},value} <> stack,health(w,healthy)),returnedExact(w,rest,stack,id,value,healthy))

def complete(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,+healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}) -> {Steps.iterate(2n,start(w,rest,stack,id,value)) == C.actionDone(A.exit(w),rest,stack,id,False{},value) : C.Machine}:
  Driver.appendStep(1n,start(w,rest,stack,id,value),returned(w,rest,stack,id,value),C.actionDone(A.exit(w),rest,stack,id,False{},value),evaluated(w,rest,stack,id,value,healthy),finishes(w,rest,stack,id,value,healthy))

def outputFrame(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+value: R.Value,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}) -> {Output.outer(C.world(Steps.iterate(2n,start(w,rest,stack,id,value)))) == Output.outer(A.done(A.exit(w),id)) : R.World}:
  Equal.trans(R.World,Output.outer(C.world(Steps.iterate(2n,start(w,rest,stack,id,value)))),Output.outer(C.world(C.actionDone(A.exit(w),rest,stack,id,False{},value))),Output.outer(A.done(A.exit(w),id)),Equal.cong(C.Machine,R.World,m=>Output.outer(C.world(m)),Steps.iterate(2n,start(w,rest,stack,id,value)),C.actionDone(A.exit(w),rest,stack,id,False{},value),complete(w,rest,stack,id,value,healthy)),Output.output(A.done(A.exit(w),id),rest,stack,id,False{},value))
