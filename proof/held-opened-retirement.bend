# The actual raw create/open/hold constructor supplies fresh resume's facts.
# No successful intermediate state or final count is supplied by a caller.
import Base
import ./held-preparation-profile.bend as Profile
import ./held-write-profile.bend as P
import ./action-retirement-count.bend as Count
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./held-body-opened-normal.bend as Opened
import ./action-constructor-state.bend as Normal
import ./ordinary-graph-data.bend as Graph
import ./held-opened-profile.bend as Input
import ./held-hold-control.bend as Control
import ./held-resume-retirement.bend as Resume
import ./action-body-entry.bend as Prepared
import ./held-write-history.bend as History
import ./held-body-evaluation.bend as Eval
import ./pending-stack-history.bend as Steps
import ./action-output-frame.bend as Output
import ./action-body-retirement.bend as Exit

def captureGeneric(+w: R.World,+methods: R.Expr) -> {R.ActionState.transaction(A.get(Opened.openedNormalized(w,methods),0n)) == 1n : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def methodsGeneric(+w: R.World,+methods: R.Expr) -> {R.ActionState.methods(A.get(Opened.openedNormalized(w,methods),0n)) == methods : R.Expr}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def holdActions(+initial: R.Value,+method: R.Expr) -> {R.World.actions(Input.opened(initial,method)) == R.World.actions(Normal.opened(initial,method)) : List<&2,R.ActionState>}:
  +w = Normal.opened(initial,method)
  Equal.cong(Control.View,List<&2,R.ActionState>,view=>Control.actions(view),Control.observe(Input.opened(initial,method)),Control.observe(w),Control.hold(w,Graph.source(initial),1n))

def capture(+initial: R.Value,+method: R.Expr) -> {R.ActionState.transaction(A.get(Input.opened(initial,method),0n)) == 1n : Nat}:
  +w = Normal.opened(initial,method)
  +normal = Opened.openedNormalized(Graph.linked(initial),method)
  Equal.trans(Nat,R.ActionState.transaction(A.get(Input.opened(initial,method),0n)),R.ActionState.transaction(A.get(w,0n)),1n,Equal.cong(List<&2,R.ActionState>,Nat,rows=>R.ActionState.transaction(B.get(R.ActionState,rows,0n,A.blank())),R.World.actions(Input.opened(initial,method)),R.World.actions(w),holdActions(initial,method)),Equal.trans(Nat,R.ActionState.transaction(A.get(w,0n)),R.ActionState.transaction(A.get(normal,0n)),1n,Equal.cong(R.World,Nat,next=>R.ActionState.transaction(A.get(next,0n)),w,normal,Opened.openedExact(initial,method)),captureGeneric(Graph.linked(initial),method)))

def methods(+initial: R.Value,+method: R.Expr) -> {R.ActionState.methods(A.get(Input.opened(initial,method),0n)) == method : R.Expr}:
  +w = Normal.opened(initial,method)
  +normal = Opened.openedNormalized(Graph.linked(initial),method)
  Equal.trans(R.Expr,R.ActionState.methods(A.get(Input.opened(initial,method),0n)),R.ActionState.methods(A.get(w,0n)),method,Equal.cong(List<&2,R.ActionState>,R.Expr,rows=>R.ActionState.methods(B.get(R.ActionState,rows,0n,A.blank())),R.World.actions(Input.opened(initial,method)),R.World.actions(w),holdActions(initial,method)),Equal.trans(R.Expr,R.ActionState.methods(A.get(w,0n)),R.ActionState.methods(A.get(normal,0n)),method,Equal.cong(R.World,R.Expr,next=>R.ActionState.methods(A.get(next,0n)),w,normal,Opened.openedExact(initial,method)),methodsGeneric(Graph.linked(initial),method)))

def emptyBefore(+initial: R.Value,+method: R.Expr) -> {R.World.flushTransaction(Normal.opened(initial,method)) == 0n : Nat}:
  {==}

def openBefore(+initial: R.Value,+method: R.Expr) -> {R.Transaction.open(B.transaction(Normal.opened(initial,method),1n)) == 1n : Nat}:
  {==}

def empty(+initial: R.Value,+method: R.Expr) -> {R.World.flushTransaction(Input.opened(initial,method)) == 0n : Nat}:
  +w = Normal.opened(initial,method)
  Equal.trans(Nat,R.World.flushTransaction(Input.opened(initial,method)),R.World.flushTransaction(w),0n,Equal.cong(Control.View,Nat,view=>Control.future(view),Control.observe(Input.opened(initial,method)),Control.observe(w),Control.hold(w,Graph.source(initial),1n)),emptyBefore(initial,method))

def openCount(+initial: R.Value,+method: R.Expr) -> {R.Transaction.open(B.transaction(Input.opened(initial,method),1n)) == 1n : Nat}:
  +w = Normal.opened(initial,method)
  Equal.trans(Nat,R.Transaction.open(B.transaction(Input.opened(initial,method),1n)),R.Transaction.open(B.transaction(w,1n)),1n,Control.openCount(w,Input.opened(initial,method),1n,Control.hold(w,Graph.source(initial),1n)),openBefore(initial,method))

def complete(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Resume.start(Input.opened(initial,Resume.methods(values,Graph.source(initial),answer)),0n,rest,stack,incoming,rejected)))) == Output.outer(Exit.target(History.run(values,Prepared.prepared(Input.opened(initial,Resume.methods(values,Graph.source(initial),answer)),0n,R.ActionEnd{}),Graph.source(initial)),1n,0n)) : R.World}:
  Resume.fresh(Input.opened(initial,Resume.methods(values,Graph.source(initial),answer)),0n,values,Graph.source(initial),answer,rest,stack,incoming,rejected,0n,0n,Input.profile(initial,Resume.methods(values,Graph.source(initial),answer)),capture(initial,Resume.methods(values,Graph.source(initial),answer)),empty(initial,Resume.methods(values,Graph.source(initial),answer)),openCount(initial,Resume.methods(values,Graph.source(initial),answer)),methods(initial,Resume.methods(values,Graph.source(initial),answer)))

def afterValid(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> {Nat.is_lt(1n,B.length(R.Transaction,R.World.txArena(History.run(values,Prepared.prepared(Input.opened(initial,Resume.methods(values,Graph.source(initial),answer)),0n,R.ActionEnd{}),Graph.source(initial))))) == True{} : Bool}:
  +id = Graph.source(initial)
  +method = Resume.methods(values,id,answer)
  +w = Input.opened(initial,method)
  +next = Prepared.prepared(w,0n,R.ActionEnd{})
  +profile = Profile.actual(w,id,0n,0n,R.ActionEnd{},Input.profile(initial,method),capture(initial,method),empty(initial,method))
  P.groupValid(History.run(values,next,id),id,0n,History.invariant(values,next,id,0n,profile))

def zero(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Count.count(C.world(Steps.iterate(1n+Eval.cost(values),Resume.start(Input.opened(initial,Resume.methods(values,Graph.source(initial),answer)),0n,rest,stack,incoming,rejected))),1n) == 0n : Nat}:
  +id = Graph.source(initial)
  +w = Input.opened(initial,Resume.methods(values,id,answer))
  +actual = C.world(Steps.iterate(1n+Eval.cost(values),Resume.start(w,0n,rest,stack,incoming,rejected)))
  +written = History.run(values,Prepared.prepared(w,0n,R.ActionEnd{}),id)
  +target = Exit.target(written,1n,0n)
  Equal.trans(Nat,Count.count(actual,1n),Count.count(Output.outer(actual),1n),0n,Equal.sym(Nat,Count.count(Output.outer(actual),1n),Count.count(actual,1n),Count.output(actual,1n)),Equal.trans(Nat,Count.count(Output.outer(actual),1n),Count.count(Output.outer(target),1n),0n,Equal.cong(R.World,Nat,next=>Count.count(next,1n),Output.outer(actual),Output.outer(target),complete(initial,values,answer,rest,stack,incoming,rejected)),Equal.trans(Nat,Count.count(Output.outer(target),1n),Count.count(target,1n),0n,Count.output(target,1n),Count.target(written,1n,0n,afterValid(initial,values,answer)))))
