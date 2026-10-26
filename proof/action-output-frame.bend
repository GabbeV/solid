# Actual action output handling changes only promise storage and host requests.
# In particular it cannot undo the group decrement or the settled-yield guard.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A


def outer(w: R.World) -> R.World:
  R.World.with_hostJobs(R.World.with_asyncObjects(w,[]),[])

def jobs(+w: R.World,+value: List<&2,R.HostJob>) -> {outer(R.World.with_hostJobs(w,value)) == outer(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def objects(+w: R.World,+value: List<&2,R.AsyncObject>) -> {outer(R.World.with_asyncObjects(w,value)) == outer(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def stored(+w: R.World,+id: Nat,+record: R.AsyncObject) -> {outer(B.store_asyncObject(w,id,record)) == outer(w) : R.World}:
  objects(w,List.set(&2,R.AsyncObject,R.World.asyncObjects(w),id,record))

def choice(+flag: Bool,+w: R.World,+yes: C.Machine,+no: C.Machine,left: {outer(C.world(yes)) == outer(w) : R.World},right: {outer(C.world(no)) == outer(w) : R.World}) -> {outer(C.world(B.choose(~C.Machine,flag,_=>yes,_=>no))) == outer(w) : R.World}:
  match flag:
    case True{}: left
    case False{}: right

def settled(+w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,+result: Nat,+rejected: Bool,+value: R.Value) -> {outer(C.world(C.actionSettled(w,rest,stack,result,rejected,value))) == outer(w) : R.World}:
  +object = B.asyncObject(w,result)
  +next = B.store_asyncObject(w,result,R.AsyncObject.with_state(object,B.choose(~R.AsyncSettlement,rejected,_=>R.Rejected{value},_=>R.Fulfilled{value})))
  Equal.trans(R.World,outer(C.world(C.actionSettled(w,rest,stack,result,rejected,value))),outer(next),outer(w),jobs(next,B.append(R.HostJob,R.World.hostJobs(next),[R.ActionOutcome{result,rejected,value}])),stored(w,result,R.AsyncObject.with_state(object,B.choose(~R.AsyncSettlement,rejected,_=>R.Rejected{value},_=>R.Fulfilled{value}))))

def asyncValue(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+result: Nat,+rejected: Bool,+source: Nat) -> {outer(C.world(C.actionOutputValue(w,rest,stack,id,result,rejected,R.AsyncValue{source}))) == outer(w) : R.World}:
  +next = R.World.with_hostJobs(w,B.append(R.HostJob,R.World.hostJobs(w),[R.ActionAdopt{id,R.AsyncValue{source}}]))
  choice(Bool.and(Bool.not(rejected),Nat.is_eq(R.AsyncObject.stream(B.asyncObject(w,source)),0n)),w,C.Machine{next,rest,stack},C.actionSettled(w,rest,stack,result,rejected,R.AsyncValue{source}),jobs(w,B.append(R.HostJob,R.World.hostJobs(w),[R.ActionAdopt{id,R.AsyncValue{source}}])),settled(w,rest,stack,result,rejected,R.AsyncValue{source}))

def value(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+result: Nat,+rejected: Bool,+answer: R.Value) -> {outer(C.world(C.actionOutputValue(w,rest,stack,id,result,rejected,answer))) == outer(w) : R.World}:
  match answer:
    case R.Undefined{}: settled(w,rest,stack,result,rejected,R.Undefined{})
    case R.Null{}: settled(w,rest,stack,result,rejected,R.Null{})
    case R.Boolean{b}: settled(w,rest,stack,result,rejected,R.Boolean{b})
    case R.Number{n}: settled(w,rest,stack,result,rejected,R.Number{n})
    case R.NegativeZero{}: settled(w,rest,stack,result,rejected,R.NegativeZero{})
    case R.Reference{id}: settled(w,rest,stack,result,rejected,R.Reference{id})
    case R.ArrayReference{id}: settled(w,rest,stack,result,rejected,R.ArrayReference{id})
    case R.OwnerReference{id}: settled(w,rest,stack,result,rejected,R.OwnerReference{id})
    case R.RootDisposerReference{owner}: settled(w,rest,stack,result,rejected,R.RootDisposerReference{owner})
    case R.AccessorReference{signal}: settled(w,rest,stack,result,rejected,R.AccessorReference{signal})
    case R.SetterReference{signal}: settled(w,rest,stack,result,rejected,R.SetterReference{signal})
    case R.ProgramReference{callback}: settled(w,rest,stack,result,rejected,R.ProgramReference{callback})
    case R.ContextFailure{identity,kind}: settled(w,rest,stack,result,rejected,R.ContextFailure{identity,kind})
    case R.NotANumber{}: settled(w,rest,stack,result,rejected,R.NotANumber{})
    case R.StringValue{s}: settled(w,rest,stack,result,rejected,R.StringValue{s})
    case R.StatusFailure{identity,source,cause,message}: settled(w,rest,stack,result,rejected,R.StatusFailure{identity,source,cause,message})
    case R.NotReadyFailure{identity,source}: settled(w,rest,stack,result,rejected,R.NotReadyFailure{identity,source})
    case R.NotPendingToken{}: settled(w,rest,stack,result,rejected,R.NotPendingToken{})
    case R.AsyncValue{identity}: asyncValue(w,rest,stack,id,result,rejected,identity)
    case R.IteratorReference{iterator}: settled(w,rest,stack,result,rejected,R.IteratorReference{iterator})
    case R.StepResult{done,value}: settled(w,rest,stack,result,rejected,R.StepResult{done,value})
    case R.StreamVerdict{stream,landed,value}: settled(w,rest,stack,result,rejected,R.StreamVerdict{stream,landed,value})
    case R.TimeoutFailure{identity}: settled(w,rest,stack,result,rejected,R.TimeoutFailure{identity})
    case R.ExternalError{id,explicit,kind,name,message,native,code}: settled(w,rest,stack,result,rejected,R.ExternalError{id,explicit,kind,name,message,native,code})

def state(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+result: Nat,+rejected: Bool,+answer: R.Value,condition: R.AsyncSettlement) -> {outer(C.world(C.actionOutputState(w,rest,stack,id,result,rejected,answer,condition))) == outer(w) : R.World}:
  match condition:
    case R.Unresolved{}: value(w,rest,stack,id,result,rejected,answer)
    case R.Fulfilled{value}: {==}
    case R.Rejected{error}: {==}

def output(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+rejected: Bool,+answer: R.Value) -> {outer(C.world(C.actionOutput(w,rest,stack,id,rejected,answer))) == outer(w) : R.World}:
  +result = R.ActionState.result(A.get(w,id))
  state(w,rest,stack,id,result,rejected,answer,R.AsyncObject.state(B.asyncObject(w,result)))


def stackChoice(+flag: Bool,+yes: C.Machine,+no: C.Machine,+stack: List<&2,R.Value>,left: {C.values(yes) == stack : List<&2,R.Value>},right: {C.values(no) == stack : List<&2,R.Value>}) -> {C.values(B.choose(~C.Machine,flag,_=>yes,_=>no)) == stack : List<&2,R.Value>}:
  match flag:
    case True{}: left
    case False{}: right

def stackAsync(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+result: Nat,+rejected: Bool,+source: Nat) -> {C.values(C.actionOutputValue(w,rest,stack,id,result,rejected,R.AsyncValue{source})) == stack : List<&2,R.Value>}:
  stackChoice(Bool.and(Bool.not(rejected),Nat.is_eq(R.AsyncObject.stream(B.asyncObject(w,source)),0n)),C.Machine{R.World.with_hostJobs(w,B.append(R.HostJob,R.World.hostJobs(w),[R.ActionAdopt{id,R.AsyncValue{source}}])),rest,stack},C.actionSettled(w,rest,stack,result,rejected,R.AsyncValue{source}),stack,{==},{==})

def stackValue(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+result: Nat,+rejected: Bool,answer: R.Value) -> {C.values(C.actionOutputValue(w,rest,stack,id,result,rejected,answer)) == stack : List<&2,R.Value>}:
  match answer:
    case R.Undefined{}: {==}
    case R.Null{}: {==}
    case R.Boolean{b}: {==}
    case R.Number{n}: {==}
    case R.NegativeZero{}: {==}
    case R.Reference{id}: {==}
    case R.ArrayReference{id}: {==}
    case R.OwnerReference{id}: {==}
    case R.RootDisposerReference{owner}: {==}
    case R.AccessorReference{signal}: {==}
    case R.SetterReference{signal}: {==}
    case R.ProgramReference{callback}: {==}
    case R.ContextFailure{identity,kind}: {==}
    case R.NotANumber{}: {==}
    case R.StringValue{s}: {==}
    case R.StatusFailure{identity,source,cause,message}: {==}
    case R.NotReadyFailure{identity,source}: {==}
    case R.NotPendingToken{}: {==}
    case R.AsyncValue{source}: stackAsync(w,rest,stack,id,result,rejected,source)
    case R.IteratorReference{iterator}: {==}
    case R.StepResult{done,value}: {==}
    case R.StreamVerdict{stream,landed,value}: {==}
    case R.TimeoutFailure{identity}: {==}
    case R.ExternalError{id,explicit,kind,name,message,native,code}: {==}

def stackState(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+result: Nat,+rejected: Bool,+answer: R.Value,state: R.AsyncSettlement) -> {C.values(C.actionOutputState(w,rest,stack,id,result,rejected,answer,state)) == stack : List<&2,R.Value>}:
  match state:
    case R.Unresolved{}: stackValue(w,rest,stack,id,result,rejected,answer)
    case R.Fulfilled{value}: {==}
    case R.Rejected{error}: {==}

def outputStack(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+rejected: Bool,+answer: R.Value) -> {C.values(C.actionOutput(w,rest,stack,id,rejected,answer)) == stack : List<&2,R.Value>}:
  +result = R.ActionState.result(A.get(w,id))
  stackState(w,rest,stack,id,result,rejected,answer,R.AsyncObject.state(B.asyncObject(w,result)))
