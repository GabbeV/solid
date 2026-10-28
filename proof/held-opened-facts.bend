# The actual raw create/open/hold constructor supplies fresh resume's facts.
# No successful intermediate state or final count is supplied by a caller.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./held-body-opened-normal.bend as Opened
import ./action-constructor-state.bend as Normal
import ./ordinary-graph-data.bend as Graph
import ./held-opened-state.bend as Input
import ./held-hold-control.bend as Control

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
