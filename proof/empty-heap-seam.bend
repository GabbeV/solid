# The trailing zero bucket after a childless height-zero render pass. Actual
# heap tasks advance the cursor, exhaust the heap and construct Settle.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/heap.bend as H
import ../proof/action-body-return.bend as Step
import ../proof/pending-stack-history.bend as Steps
import ../proof/core-run-prefix.bend as Driver
import ../proof/committed-storage-frame.bend as Content

def moved(w: R.World) -> R.World:
  R.World.with_minimum(w,1n)

def ended(w: R.World) -> R.World:
  R.World.with_maximum(moved(w),0n)

# Pure loaded form of core.heapLoop's ordinary pass, before branch selection.
def loaded(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+at: Nat,limit: Nat,+id: Nat) -> C.Machine:
  B.choose(~C.Machine,Nat.is_gt(at,limit),_=>C.Machine{R.World.with_maximum(w,0n),C.Seam{} <> rest,stack},_=>B.choose(~C.Machine,Nat.is_eq(id,0n),_=>C.Machine{R.World.with_minimum(w,1n+at),C.HeapLoop{} <> rest,stack},_=>B.choose(~C.Machine,B.has(R.Node.flags(B.node(w,id)),8),_=>C.visitHeapInto(w,rest,stack,id,C.HeapLoop{}),_=>C.Machine{H.adjustHeight(w,id),C.HeapLoop{} <> rest,stack})))

def shape(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>) -> {C.heapLoop(w,rest,stack) == loaded(w,rest,stack,R.World.minimum(w),R.World.maximum(w),B.bucket(w,R.World.minimum(w))) : C.Machine}:
  {==}

def first(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,minimum: {R.World.minimum(w) == 0n : Nat},maximum: {R.World.maximum(w) == 0n : Nat},bucket: {B.bucket(w,0n) == 0n : Nat}) -> {C.heapLoop(w,rest,stack) == C.Machine{moved(w),C.HeapLoop{} <> rest,stack} : C.Machine}:
  +atZero = Equal.cong(Nat,C.Machine,at=>loaded(w,rest,stack,at,R.World.maximum(w),B.bucket(w,at)),R.World.minimum(w),0n,minimum)
  +atEnd = Equal.cong(Nat,C.Machine,limit=>loaded(w,rest,stack,0n,limit,B.bucket(w,0n)),R.World.maximum(w),0n,maximum)
  +empty = Equal.cong(Nat,C.Machine,id=>loaded(w,rest,stack,0n,0n,id),B.bucket(w,0n),0n,bucket)
  Equal.trans(C.Machine,C.heapLoop(w,rest,stack),loaded(w,rest,stack,R.World.minimum(w),R.World.maximum(w),B.bucket(w,R.World.minimum(w))),C.Machine{moved(w),C.HeapLoop{} <> rest,stack},shape(w,rest,stack),Equal.trans(C.Machine,loaded(w,rest,stack,R.World.minimum(w),R.World.maximum(w),B.bucket(w,R.World.minimum(w))),loaded(w,rest,stack,0n,R.World.maximum(w),B.bucket(w,0n)),C.Machine{moved(w),C.HeapLoop{} <> rest,stack},atZero,Equal.trans(C.Machine,loaded(w,rest,stack,0n,R.World.maximum(w),B.bucket(w,0n)),loaded(w,rest,stack,0n,0n,B.bucket(w,0n)),C.Machine{moved(w),C.HeapLoop{} <> rest,stack},atEnd,empty)))

def second(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,bound: {R.World.maximum(w) == 0n : Nat}) -> {C.heapLoop(moved(w),rest,stack) == C.Machine{ended(w),C.Seam{} <> rest,stack} : C.Machine}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.trans(C.Machine,C.heapLoop(moved(w),rest,stack),loaded(moved(w),rest,stack,1n,maximum,B.bucket(moved(w),1n)),C.Machine{ended(w),C.Seam{} <> rest,stack},shape(moved(w),rest,stack),Equal.cong(Nat,C.Machine,limit=>loaded(moved(w),rest,stack,1n,limit,B.bucket(moved(w),1n)),maximum,0n,bound))

def healthMoved(+w: R.World) -> {B.ok(moved(w)) == B.ok(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def healthEnded(+w: R.World) -> {B.ok(ended(w)) == B.ok(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def complete(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,minimum: {R.World.minimum(w) == 0n : Nat},+maximum: {R.World.maximum(w) == 0n : Nat},bucket: {B.bucket(w,0n) == 0n : Nat},+healthy: {B.ok(w) == True{} : Bool}) -> {Steps.iterate(3n,C.Machine{w,C.HeapLoop{} <> rest,stack}) == C.Machine{ended(w),C.Settle{} <> C.AfterSettle{} <> rest,stack} : C.Machine}:
  +before = {C.Machine{w,C.HeapLoop{} <> rest,stack} : C.Machine}
  +one = {C.Machine{moved(w),C.HeapLoop{} <> rest,stack} : C.Machine}
  +two = {C.Machine{ended(w),C.Seam{} <> rest,stack} : C.Machine}
  +after = {C.Machine{ended(w),C.Settle{} <> C.AfterSettle{} <> rest,stack} : C.Machine}
  +firstStep = Equal.trans(C.Machine,C.step(before),C.heapLoop(w,rest,stack),one,Step.healthyStep(w,C.HeapLoop{},rest,stack,healthy),first(w,rest,stack,minimum,maximum,bucket))
  +secondStep = Equal.trans(C.Machine,C.step(one),C.heapLoop(moved(w),rest,stack),two,Step.healthyStep(moved(w),C.HeapLoop{},rest,stack,Equal.trans(Bool,B.ok(moved(w)),B.ok(w),True{},healthMoved(w),healthy)),second(w,rest,stack,maximum))
  Driver.appendStep(2n,before,two,after,Driver.appendStep(1n,before,one,two,firstStep,secondStep),Step.healthyStep(ended(w),C.Seam{},rest,stack,Equal.trans(Bool,B.ok(ended(w)),B.ok(w),True{},healthEnded(w),healthy)))

def committed(+w: R.World) -> {Content.observe(ended(w)) == Content.observe(w) : Content.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}
