# Retiring the body keeps its actual settled-yield guard. Later helper events
# and stale deliveries preserve the current Machine, including live group debt.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./action-body-constructed.bend as Body
import ./action-body-entry.bend as Entry
import ./action-body-retirement.bend as Retire
import ./action-output-frame.bend as Output
import ./action-method-first-history.bend as First
import ./action-method-wait-fixture.bend as Input
import ./action-resume-frame.bend as Frame
import ./observer-write-frame.bend as Observer
import ./action-wait-history.bend as History
import ./action-laws.bend as Guard

def waitsOuter(+w: R.World) -> {R.World.actionWaits(Output.outer(w)) == R.World.actionWaits(w) : List<&2,R.ActionWait>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameWaits(+a: R.World,+b: R.World,same: {Output.outer(a) == Output.outer(b) : R.World}) -> {R.World.actionWaits(a) == R.World.actionWaits(b) : List<&2,R.ActionWait>}:
  Equal.trans(List<&2,R.ActionWait>,R.World.actionWaits(a),R.World.actionWaits(Output.outer(a)),R.World.actionWaits(b),Equal.sym(List<&2,R.ActionWait>,R.World.actionWaits(Output.outer(a)),R.World.actionWaits(a),waitsOuter(a)),Equal.trans(List<&2,R.ActionWait>,R.World.actionWaits(Output.outer(a)),R.World.actionWaits(Output.outer(b)),R.World.actionWaits(b),Equal.cong(R.World,List<&2,R.ActionWait>,w=>R.World.actionWaits(w),Output.outer(a),Output.outer(b),same),waitsOuter(b)))

def targetWaits(+w: R.World,+root: Nat,+remaining: Nat) -> {R.World.actionWaits(Retire.target(w,root,remaining)) == R.World.actionWaits(w) : List<&2,R.ActionWait>}:
  +exited = A.exit(w)
  +record = R.Transaction.with_open(B.transaction(exited,root),remaining)
  +stored = B.store_transaction(exited,root,record)
  +same = Frame.compose(w,exited,Retire.target(w,root,remaining),Frame.compose(exited,stored,Retire.target(w,root,remaining),Frame.schedule(stored),Frame.storeTransaction(exited,root,record)),Frame.worldDepth(w,Nat.sub(R.World.actionDepth(w),1n)))
  Equal.cong(Frame.View,List<&2,R.ActionWait>,view=>Observer.waitEntries(Frame.observer(view)),Frame.observe(Retire.target(w,root,remaining)),Frame.observe(w),same)

def entryFound(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {A.find(R.World.actionWaits(Body.ready(values,value,tail,prefix)),Input.fresh(values,Entry.method(value,tail),prefix)) == Some{R.ActionWait{Input.fresh(values,Entry.method(value,tail),prefix),Input.action(values,Entry.method(value,tail)),0,True{}}} : Maybe<&2,R.ActionWait>}:
  +method = Entry.method(value,tail)
  +observer = Input.fresh(values,method,prefix)
  +before = First.first(values,method,prefix,rest,stack,rejected,incoming)
  +work = {C.ActionSliceEnd{R.World.question(Body.marked(values,value,tail,prefix))} <> rest : List<&2,C.Task>}
  +after = {C.Machine{Body.ready(values,value,tail,prefix),C.Evaluate{R.Literal{R.StepResult{True{},value}},R.Undefined{}} <> C.ActionStepReturn{Input.action(values,method),stack} <> work,stack} : C.Machine}
  Equal.trans(Maybe<&2,R.ActionWait>,A.find(R.World.actionWaits(Body.ready(values,value,tail,prefix)),observer),A.find(R.World.actionWaits(C.world(before)),observer),Some{R.ActionWait{observer,Input.action(values,method),0,True{}}},Equal.sym(Maybe<&2,R.ActionWait>,A.find(R.World.actionWaits(C.world(before)),observer),A.find(R.World.actionWaits(C.world(after)),observer),Equal.cong(C.Machine,Maybe<&2,R.ActionWait>,m=>A.find(R.World.actionWaits(C.world(m)),observer),before,after,Body.firstExact(values,value,tail,prefix,rest,stack,incoming,rejected))),First.firstFound(values,method,prefix,rest,stack,rejected,incoming))

def returnedFound(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {A.find(R.World.actionWaits(C.world(Body.returned(values,value,tail,prefix,rest,stack,incoming,rejected))),Input.fresh(values,Entry.method(value,tail),prefix)) == Some{R.ActionWait{Input.fresh(values,Entry.method(value,tail),prefix),Input.action(values,Entry.method(value,tail)),0,True{}}} : Maybe<&2,R.ActionWait>}:
  +w = Body.ready(values,value,tail,prefix)
  +after = C.world(Body.returned(values,value,tail,prefix,rest,stack,incoming,rejected))
  +observer = Input.fresh(values,Entry.method(value,tail),prefix)
  +same = Equal.trans(List<&2,R.ActionWait>,R.World.actionWaits(after),R.World.actionWaits(Retire.target(w,1n,0n)),R.World.actionWaits(w),sameWaits(after,Retire.target(w,1n,0n),Body.completedOuter(values,value,tail,prefix,rest,stack,incoming,rejected)),targetWaits(w,1n,0n))
  Equal.trans(Maybe<&2,R.ActionWait>,A.find(R.World.actionWaits(after),observer),A.find(R.World.actionWaits(w),observer),Some{R.ActionWait{observer,Input.action(values,Entry.method(value,tail)),0,True{}}},Equal.cong(List<&2,R.ActionWait>,Maybe<&2,R.ActionWait>,rows=>A.find(rows,observer),R.World.actionWaits(after),R.World.actionWaits(w),same),entryFound(values,value,tail,prefix,rest,stack,incoming,rejected))


def after(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,events: List<&2,History.WaitEvent>) -> C.Machine:
  +done = Body.returned(values,value,tail,prefix,rest,stack,incoming,rejected)
  C.Machine{History.run(events,C.world(done)),First.tasks(done),C.values(done)}

def afterFound(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+events: List<&2,History.WaitEvent>) -> {A.find(R.World.actionWaits(C.world(after(values,value,tail,prefix,rest,stack,incoming,rejected,events))),Input.fresh(values,Entry.method(value,tail),prefix)) == Some{R.ActionWait{Input.fresh(values,Entry.method(value,tail),prefix),Input.action(values,Entry.method(value,tail)),0,True{}}} : Maybe<&2,R.ActionWait>}:
  +observer = Input.fresh(values,Entry.method(value,tail),prefix)
  History.historyFound(events,C.world(Body.returned(values,value,tail,prefix,rest,stack,incoming,rejected)),observer,observer,Input.action(values,Entry.method(value,tail)),0,returnedFound(values,value,tail,prefix,rest,stack,incoming,rejected))

def duplicate(+values: List<&2,R.Value>,+value: R.Value,+tail: R.Expr,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+events: List<&2,History.WaitEvent>,+lateRejected: Bool,+lateValue: R.Value) -> {C.asyncActionDelivery(C.world(after(values,value,tail,prefix,rest,stack,incoming,rejected,events)),First.tasks(after(values,value,tail,prefix,rest,stack,incoming,rejected,events)),C.values(after(values,value,tail,prefix,rest,stack,incoming,rejected,events)),Input.fresh(values,Entry.method(value,tail),prefix),lateRejected,lateValue,A.find(R.World.actionWaits(C.world(after(values,value,tail,prefix,rest,stack,incoming,rejected,events))),Input.fresh(values,Entry.method(value,tail),prefix))) == after(values,value,tail,prefix,rest,stack,incoming,rejected,events) : C.Machine}:
  +machine = after(values,value,tail,prefix,rest,stack,incoming,rejected,events)
  +w = C.world(machine)
  +work = First.tasks(machine)
  +saved = C.values(machine)
  +observer = Input.fresh(values,Entry.method(value,tail),prefix)
  +actor = Input.action(values,Entry.method(value,tail))
  +entry = {R.ActionWait{observer,actor,0,True{}} : R.ActionWait}
  Equal.trans(C.Machine,C.asyncActionDelivery(w,work,saved,observer,lateRejected,lateValue,A.find(R.World.actionWaits(w),observer)),C.asyncActionDelivery(w,work,saved,observer,lateRejected,lateValue,Some{entry}),machine,Equal.cong(Maybe<&2,R.ActionWait>,C.Machine,found=>C.asyncActionDelivery(w,work,saved,observer,lateRejected,lateValue,found),A.find(R.World.actionWaits(w),observer),Some{entry},afterFound(values,value,tail,prefix,rest,stack,incoming,rejected,events)),Guard.duplicate_yield(w,work,saved,observer,actor,lateRejected,lateValue))
