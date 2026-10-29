# After a parked settlement, empty execution queues return through the actual
# clock update, flush finally, cleanup check and saved-question restoration.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/cleanup-state.bend as Cleanup
import ../proof/action-body-return.bend as Step
import ../proof/pending-stack-history.bend as Steps
import ../proof/core-run-prefix.bend as Driver
import ../proof/committed-storage-frame.bend as Content

def ticked(+w: R.World) -> R.World:
  R.World.with_scheduled(R.World.with_clock(w,1n+R.World.clock(w)),False{})

def ended(w: R.World) -> R.World:
  R.World.with_passTx(R.World.with_running(ticked(w),False{}),0n)

def restored(w: R.World,question: R.Question) -> R.World:
  R.World.with_question(ended(w),question)

def work(question: R.Question,rest: List<&2,C.Task>) -> List<&2,C.Task>:
  C.AfterSettle{} <> C.FlushFinally{} <> C.RoundEnd{} <> C.ActionRestoreQuestion{question} <> rest

def clean(+w: R.World,+empty: {R.World.cleanupError(w) == R.Empty{} : R.Slot}) -> {Cleanup.rethrowCleanupError(w,False{}) == w : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +ambientQuestion, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.trans(R.World,Cleanup.rethrowCleanupError(w,False{}),R.World.with_cleanupError(w,R.Empty{}),w,Equal.cong(R.Slot,R.World,slot=>Cleanup.rethrowSlot(R.World.with_cleanupError(w,R.Empty{}),False{},slot),cleanupError,R.Empty{},empty),Equal.sym(R.World,w,R.World.with_cleanupError(w,R.Empty{}),Equal.cong(R.Slot,R.World,slot=>R.World.with_cleanupError(w,slot),cleanupError,R.Empty{},empty)))

def guard(+w: R.World,heap: {Nat.is_ge(R.World.maximum(w),R.World.minimum(w)) == False{} : Bool},pending: {R.World.pendingNodes(w) == [] : List<&2,Nat>}) -> {Bool.or(Nat.is_ge(R.World.maximum(w),R.World.minimum(w)),Bool.not(List.is_empty(&2,Nat,R.World.pendingNodes(w)))) == False{} : Bool}:
  Equal.trans(Bool,Bool.or(Nat.is_ge(R.World.maximum(w),R.World.minimum(w)),Bool.not(List.is_empty(&2,Nat,R.World.pendingNodes(w)))),Bool.or(False{},Bool.not(List.is_empty(&2,Nat,R.World.pendingNodes(w)))),False{},Equal.cong(Bool,Bool,armed=>Bool.or(armed,Bool.not(List.is_empty(&2,Nat,R.World.pendingNodes(w)))),Nat.is_ge(R.World.maximum(w),R.World.minimum(w)),False{},heap),Equal.cong(List<&2,Nat>,Bool,rows=>Bool.or(False{},Bool.not(List.is_empty(&2,Nat,rows))),R.World.pendingNodes(w),[],pending))

def complete(+w: R.World,+question: R.Question,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+healthy: {B.ok(w) == True{} : Bool},heap: {Nat.is_ge(R.World.maximum(w),R.World.minimum(w)) == False{} : Bool},pending: {R.World.pendingNodes(w) == [] : List<&2,Nat>},renderEmpty: {R.World.renderQueue(w) == [] : List<&2,Nat>},userEmpty: {R.World.userQueue(w) == [] : List<&2,R.QueueEntry>},cleanupEmpty: {R.World.cleanupError(w) == R.Empty{} : R.Slot}) -> {Steps.iterate(6n,C.Machine{w,work(question,rest),stack}) == C.Machine{restored(w,question),rest,stack} : C.Machine}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +ambientQuestion, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      +ending = {C.FlushFinally{} <> C.RoundEnd{} <> C.ActionRestoreQuestion{question} <> rest : List<&2,C.Task>}
      +m0 = {C.Machine{w,work(question,rest),stack} : C.Machine}
      +m1 = {C.Machine{ticked(w),C.RenderQueue{} <> ending,stack} : C.Machine}
      +m2 = {C.Machine{ticked(w),C.UserQueue{} <> ending,stack} : C.Machine}
      +m3 = {C.Machine{ticked(w),ending,stack} : C.Machine}
      +m4 = {C.Machine{ended(w),C.RoundEnd{} <> C.ActionRestoreQuestion{question} <> rest,stack} : C.Machine}
      +m5 = {C.Machine{ended(w),C.ActionRestoreQuestion{question} <> rest,stack} : C.Machine}
      +m6 = {C.Machine{restored(w,question),rest,stack} : C.Machine}
      +first = Equal.trans(C.Machine,C.step(m0),C.afterSettle(w,ending,stack),m1,Step.healthyStep(w,C.AfterSettle{},ending,stack,healthy),Equal.cong(Bool,C.Machine,scheduled=>C.Machine{R.World.with_scheduled(R.World.with_clock(w,1n+clock),scheduled),C.RenderQueue{} <> ending,stack},Bool.or(Nat.is_ge(maximum,minimum),Bool.not(List.is_empty(&2,Nat,pendingNodes))),False{},guard(w,heap,pending)))
      +renderKnown = Equal.cong(List<&2,Nat>,Bool,rows=>List.is_empty(&2,Nat,rows),renderQueue,[],renderEmpty)
      +renderStep = Equal.trans(C.Machine,C.step(m1),C.dispatch(ticked(w),C.RenderQueue{} <> ending,stack),m2,Step.healthyStep(ticked(w),C.RenderQueue{},ending,stack,healthy),Equal.cong(Bool,C.Machine,empty=>B.choose(~C.Machine,empty,_=>m2,_=>C.Machine{R.World.with_renderQueue(ticked(w),[]),B.append(C.Task,C.queue_tasks(ticked(w),renderQueue),C.UserQueue{} <> ending),stack}),List.is_empty(&2,Nat,renderQueue),True{},renderKnown))
      +userKnown = Equal.cong(List<&2,R.QueueEntry>,Bool,rows=>List.is_empty(&2,R.QueueEntry,rows),userQueue,[],userEmpty)
      +userStep = Equal.trans(C.Machine,C.step(m2),C.dispatch(ticked(w),C.UserQueue{} <> ending,stack),m3,Step.healthyStep(ticked(w),C.UserQueue{},ending,stack,healthy),Equal.cong(Bool,C.Machine,empty=>B.choose(~C.Machine,empty,_=>m3,_=>C.Machine{R.World.with_userQueue(ticked(w),[]),B.append(C.Task,C.user_tasks(ticked(w),userQueue),ending),stack}),List.is_empty(&2,R.QueueEntry,userQueue),True{},userKnown))
      +flushStep = Step.healthyStep(ticked(w),C.FlushFinally{},C.RoundEnd{} <> C.ActionRestoreQuestion{question} <> rest,stack,healthy)
      +roundStep = Equal.trans(C.Machine,C.step(m4),C.dispatch(ended(w),C.RoundEnd{} <> C.ActionRestoreQuestion{question} <> rest,stack),m5,Step.healthyStep(ended(w),C.RoundEnd{},C.ActionRestoreQuestion{question} <> rest,stack,healthy),Equal.cong(R.World,C.Machine,next=>C.Machine{next,C.ActionRestoreQuestion{question} <> rest,stack},Cleanup.rethrowCleanupError(ended(w),False{}),ended(w),clean(ended(w),cleanupEmpty)))
      +restoreStep = Step.healthyStep(ended(w),C.ActionRestoreQuestion{question},rest,stack,healthy)
      +second = Driver.appendStep(1n,m0,m1,m2,first,renderStep)
      +third = Driver.appendStep(2n,m0,m2,m3,second,userStep)
      +fourth = Driver.appendStep(3n,m0,m3,m4,third,flushStep)
      +fifth = Driver.appendStep(4n,m0,m4,m5,fourth,roundStep)
      Driver.appendStep(5n,m0,m5,m6,fifth,restoreStep)

def committed(+w: R.World,question: R.Question) -> {Content.observe(restored(w,question)) == Content.observe(w) : Content.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +ambientQuestion, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def count(+w: R.World,question: R.Question,id: Nat) -> {R.Transaction.open(B.transaction(restored(w,question),id)) == R.Transaction.open(B.transaction(w,id)) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +ambientQuestion, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}
