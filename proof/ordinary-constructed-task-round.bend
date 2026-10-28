# A real outer AsyncFulfill/AsyncReject core task in the constructed ordinary
# family reaches Round after its finite body and output-request prefix. Initial
# program arguments supply every fact. Host event transport, public factory/
# parking and executing Round/publication remain separate obligations.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ./ordinary-graph-data.bend as Graph
import ./held-delivery-constructor-state.bend as State
import ./held-delivery-constructed-input.bend as Input
import ./held-resume-retirement.bend as Resume
import ./held-action-delivery.bend as Delivery
import ./ordinary-outer-entry.bend as Outer
import ./held-constructed-round-boundary.bend as Round
import ./held-preparation-source.bend as Source
import ./held-write-profile.bend as P
import ./action-body-return.bend as Body
import ./action-wait-history.bend as History
import ./pending-stack-history.bend as Steps
import ./held-body-evaluation.bend as Eval
import ./core-prefix-compose.bend as Prefix

def task(+observer: Nat,rejected: Bool,+incoming: R.Value) -> C.Task:
  B.choose(~C.Task,rejected,_=>C.AsyncReject{observer,incoming},_=>C.AsyncFulfill{observer,incoming})

def start(+w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,observer: Nat,rejected: Bool,incoming: R.Value) -> C.Machine:
  C.Machine{w,task(observer,rejected,incoming) <> rest,stack}

def flushFault(+w: R.World) -> {R.World.fault(Source.flush(w,1n)) == R.World.fault(w) : R.Fault}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def healthy(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>) -> {R.World.fault(State.registered(value,methods,prefix)) == R.Healthy{} : R.Fault}:
  +w = State.registered(value,methods,prefix)
  Equal.trans(R.Fault,R.World.fault(w),R.World.fault(Source.flush(w,1n)),R.Healthy{},Equal.sym(R.Fault,R.World.fault(Source.flush(w,1n)),R.World.fault(w),flushFault(w)),P.healthy(Source.flush(w,1n),Graph.source(value),0n,Input.profile(value,methods,prefix)))

def dispatch(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+observer: Nat,+rejected: Bool,+incoming: R.Value,healthy: {R.World.fault(w) == R.Healthy{} : R.Fault}) -> {C.step(start(w,rest,stack,observer,rejected,incoming)) == C.fromWrapDelivery(w,rest,stack,observer,rejected,incoming) : C.Machine}:
  match rejected:
    case True{}: Body.healthyStep(w,C.AsyncReject{observer,incoming},rest,stack,Body.health(w,healthy))
    case False{}: Body.healthyStep(w,C.AsyncFulfill{observer,incoming},rest,stack,Body.health(w,healthy))

def first(+value: R.Value,+methods: R.Expr,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {C.step(start(State.registered(value,methods,prefix),rest,stack,State.observer(value,methods,prefix),rejected,incoming)) == Delivery.start(State.registered(value,methods,prefix),rest,stack,State.observer(value,methods,prefix),rejected,incoming) : C.Machine}:
  +w = State.registered(value,methods,prefix)
  +observer = State.observer(value,methods,prefix)
  Equal.trans(C.Machine,C.step(start(w,rest,stack,observer,rejected,incoming)),C.fromWrapDelivery(w,rest,stack,observer,rejected,incoming),Delivery.start(w,rest,stack,observer,rejected,incoming),dispatch(w,rest,stack,observer,rejected,incoming,healthy(value,methods,prefix)),Outer.constructed(value,methods,prefix,rest,stack,rejected,incoming))

def complete(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+prefix: List<&2,History.WaitEvent>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Steps.iterate(Nat.add(1n,Nat.add(1n+Eval.cost(values),1n+Round.cost(value,values,answer,prefix,rest,stack,incoming,rejected))),start(State.registered(value,Resume.methods(values,Graph.source(value),answer),prefix),rest,stack,State.observer(value,Resume.methods(values,Graph.source(value),answer),prefix),rejected,incoming)) == Round.target(value,values,answer,prefix,rest,stack,incoming,rejected) : C.Machine}:
  +method = Resume.methods(values,Graph.source(value),answer)
  +w = State.registered(value,method,prefix)
  +observer = State.observer(value,method,prefix)
  Prefix.compose(1n,Nat.add(1n+Eval.cost(values),1n+Round.cost(value,values,answer,prefix,rest,stack,incoming,rejected)),start(w,rest,stack,observer,rejected,incoming),Delivery.start(w,rest,stack,observer,rejected,incoming),Round.target(value,values,answer,prefix,rest,stack,incoming,rejected),first(value,method,prefix,rest,stack,incoming,rejected),Round.complete(value,values,answer,prefix,rest,stack,incoming,rejected))
