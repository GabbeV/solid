# Generic normalization of only the second real create/open prefix. Keep the
# input source World opaque so later proofs do not unfold the whole raw graph.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./action-opening.bend as Opening
import ./held-controller-data.bend as Data

def cell(+w: R.World,methods: R.Expr) -> R.ActionState:
  R.ActionState{0n,R.QuestionZero{},methods,B.length(R.AsyncObject,R.World.asyncObjects(w))}

def created(+w: R.World,+methods: R.Expr) -> R.World:
  R.World.with_actions(R.World.with_asyncObjects(w,B.append(R.AsyncObject,R.World.asyncObjects(w),[R.AsyncObject{False{},R.Unresolved{},[],0n}])),B.append(R.ActionState,R.World.actions(w),[cell(w,methods)]))

def create(+w: R.World,+methods: R.Expr) -> {A.create(w,methods) == B.Bundle{created(w,methods),B.length(R.ActionState,R.World.actions(w))} : B.Bundle<R.World,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def shape(+w: R.World,+id: Nat,+methods: R.Expr) -> R.World:
  R.World.with_txArena(R.World.with_actions(w,[Data.first(methods)]),[B.blank_transaction(),Data.group(id)])

def shapedActor(+w: R.World,+id: Nat,+methods: R.Expr) -> {B.length(R.ActionState,R.World.actions(shape(w,id,methods))) == 1n : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def scoped(+w: R.World,+id: Nat,+first: R.Expr,+second: R.Expr) -> {Opening.scope(created(shape(w,id,first),second),[Data.group(id)],[Data.first(first)],cell(shape(w,id,first),second),[]) == created(shape(w,id,first),second) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def normalized(+w: R.World,+id: Nat,+first: R.Expr,+second: R.Expr) -> R.World:
  Opening.expected(created(shape(w,id,first),second),[Data.group(id)],[Data.first(first)],cell(shape(w,id,first),second),[])

def run(+w: R.World,+methods: R.Expr) -> R.World:
  +pair = A.create(w,methods)
  A.open(B.first(R.World,Nat,pair),B.second(R.World,Nat,pair))

def fromPair(+pair: B.Bundle<R.World,Nat>) -> R.World:
  A.open(B.first(R.World,Nat,pair),B.second(R.World,Nat,pair))

def exact(+w: R.World,+id: Nat,+first: R.Expr,+second: R.Expr) -> {run(shape(w,id,first),second) == normalized(w,id,first,second) : R.World}:
  +before = shape(w,id,first)
  +next = created(before,second)
  +scope = Opening.scope(next,[Data.group(id)],[Data.first(first)],cell(before,second),[])
  +firstEq = Equal.trans(R.World,run(before,second),A.open(next,B.length(R.ActionState,R.World.actions(before))),A.open(next,1n),Equal.cong(B.Bundle<R.World,Nat>,R.World,pair=>fromPair(pair),A.create(before,second),B.Bundle{next,B.length(R.ActionState,R.World.actions(before))},create(before,second)),Equal.cong(Nat,R.World,n=>A.open(next,n),B.length(R.ActionState,R.World.actions(before)),1n,shapedActor(w,id,first)))
  Equal.trans(R.World,run(before,second),A.open(scope,1n),normalized(w,id,first,second),Equal.trans(R.World,run(before,second),A.open(next,1n),A.open(scope,1n),firstEq,Equal.cong(R.World,R.World,state=>A.open(state,1n),next,scope,Equal.sym(R.World,scope,next,scoped(w,id,first,second)))),Opening.allocated(next,[Data.group(id)],[Data.first(first)],cell(before,second),[]))

def sameArrays(+w: R.World) -> {R.World.with_txArena(R.World.with_actions(w,R.World.actions(w)),R.World.txArena(w)) == w : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def shapeIdentity(+w: R.World,+id: Nat,+methods: R.Expr,arena: {R.World.txArena(w) == [B.blank_transaction(),Data.group(id)] : List<&2,R.Transaction>},actions: {R.World.actions(w) == [Data.first(methods)] : List<&2,R.ActionState>}) -> {shape(w,id,methods) == w : R.World}:
  +rows = {[B.blank_transaction(),Data.group(id)] : List<&2,R.Transaction>}
  +cells = {[Data.first(methods)] : List<&2,R.ActionState>}
  +middle = R.World.with_txArena(R.World.with_actions(w,R.World.actions(w)),rows)
  Equal.trans(R.World,shape(w,id,methods),middle,w,Equal.cong(List<&2,R.ActionState>,R.World,entries=>R.World.with_txArena(R.World.with_actions(w,entries),rows),cells,R.World.actions(w),Equal.sym(List<&2,R.ActionState>,R.World.actions(w),cells,actions)),Equal.trans(R.World,middle,R.World.with_txArena(R.World.with_actions(w,R.World.actions(w)),R.World.txArena(w)),w,Equal.cong(List<&2,R.Transaction>,R.World,entries=>R.World.with_txArena(R.World.with_actions(w,R.World.actions(w)),entries),rows,R.World.txArena(w),Equal.sym(List<&2,R.Transaction>,R.World.txArena(w),rows,arena)),sameArrays(w)))

def captureFirst(+w: R.World,+id: Nat,+first: R.Expr,+second: R.Expr) -> {R.ActionState.transaction(A.get(normalized(w,id,first,second),0n)) == 1n : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def captureSecond(+w: R.World,+id: Nat,+first: R.Expr,+second: R.Expr) -> {R.ActionState.transaction(A.get(normalized(w,id,first,second),1n)) == 2n : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def methodFirst(+w: R.World,+id: Nat,+first: R.Expr,+second: R.Expr) -> {R.ActionState.methods(A.get(normalized(w,id,first,second),0n)) == first : R.Expr}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def methodSecond(+w: R.World,+id: Nat,+first: R.Expr,+second: R.Expr) -> {R.ActionState.methods(A.get(normalized(w,id,first,second),1n)) == second : R.Expr}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}
