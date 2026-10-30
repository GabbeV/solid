# Actual queued Round entry with no promoted companions or dormant sweep.
# Normalization changes are explicit; caller/heap work is not assumed done.
import Base
import ../runtime/owner.bend as O
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/read-state.bend as Reads
import ../proof/action-body-return.bend as Step
import ../proof/pending-stack-history.bend as Steps
import ../proof/core-run-prefix.bend as Driver
import ../proof/committed-storage-frame.bend as Content

import ./sweep-input-frame.bend as Sweep

def seated(w: R.World) -> R.World:
  R.World.with_passTx(R.World.with_passLane(R.World.with_unflushedStaged(R.World.with_running(w,True{}),False{}),0n),0n)

def entered(w: R.World) -> R.World:
  R.World.with_minimum(R.World.with_marked(seated(w),False{}),0n)

def resync(+w: R.World,empty: {R.World.promotedWrites(w) == [] : List<&2,Nat>}) -> {Reads.resyncUnflushedCompanions(w) == R.World.with_unflushedStaged(w,False{}) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      +next = R.World.with_unflushedStaged(w,False{})
      Equal.cong(List<&2,Nat>,R.World,rows=>B.choose(~R.World,List.is_empty(&2,Nat,rows),_=>next,_=>R.World.with_promotedWrites(Reads.clearPromoted(rows,next),[])),promotedWrites,[],empty)

def normalized(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,empty: {R.World.promotedWrites(w) == [] : List<&2,Nat>}) -> {C.round(w,rest,stack) == C.Machine{seated(w),B.choose(~List<&2,C.Task>,List.is_empty(&2,Nat,R.World.dormantNodes(w)),_=>C.RoundAfterSweep{} <> C.FlushFinally{} <> C.RoundEnd{} <> rest,_=>C.OwnerTasks{[O.SweepDormant{0n}]} <> C.RoundAfterSweep{} <> C.FlushFinally{} <> C.RoundEnd{} <> rest),stack} : C.Machine}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(R.World,C.Machine,next=>
        +next = R.World.with_passTx(R.World.with_passLane(next,0n),0n)
        C.Machine{next,B.choose(~List<&2,C.Task>,List.is_empty(&2,Nat,R.World.dormantNodes(next)),_=>C.RoundAfterSweep{} <> C.FlushFinally{} <> C.RoundEnd{} <> rest,_=>C.OwnerTasks{[O.SweepDormant{0n}]} <> C.RoundAfterSweep{} <> C.FlushFinally{} <> C.RoundEnd{} <> rest),stack},Reads.resyncUnflushedCompanions(R.World.with_running(w,True{})),R.World.with_unflushedStaged(R.World.with_running(w,True{}),False{}),resync(R.World.with_running(w,True{}),empty))

def health(+w: R.World) -> {B.ok(seated(w)) == B.ok(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def first(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,promoted: {R.World.promotedWrites(w) == [] : List<&2,Nat>},dormant: {R.World.dormantNodes(w) == [] : List<&2,Nat>}) -> {C.round(w,rest,stack) == C.Machine{seated(w),C.RoundAfterSweep{} <> C.FlushFinally{} <> C.RoundEnd{} <> rest,stack} : C.Machine}:
  Equal.trans(C.Machine,C.round(w,rest,stack),C.Machine{seated(w),B.choose(~List<&2,C.Task>,List.is_empty(&2,Nat,R.World.dormantNodes(w)),_=>C.RoundAfterSweep{} <> C.FlushFinally{} <> C.RoundEnd{} <> rest,_=>C.OwnerTasks{[O.SweepDormant{0n}]} <> C.RoundAfterSweep{} <> C.FlushFinally{} <> C.RoundEnd{} <> rest),stack},C.Machine{seated(w),C.RoundAfterSweep{} <> C.FlushFinally{} <> C.RoundEnd{} <> rest,stack},normalized(w,rest,stack,promoted),Equal.cong(List<&2,Nat>,C.Machine,rows=>C.Machine{seated(w),B.choose(~List<&2,C.Task>,List.is_empty(&2,Nat,rows),_=>C.RoundAfterSweep{} <> C.FlushFinally{} <> C.RoundEnd{} <> rest,_=>C.OwnerTasks{[O.SweepDormant{0n}]} <> C.RoundAfterSweep{} <> C.FlushFinally{} <> C.RoundEnd{} <> rest),stack},R.World.dormantNodes(w),[],dormant))

def complete(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,promoted: {R.World.promotedWrites(w) == [] : List<&2,Nat>},dormant: {R.World.dormantNodes(w) == [] : List<&2,Nat>},+healthy: {B.ok(w) == True{} : Bool}) -> {Steps.iterate(2n,C.Machine{w,C.Round{} <> rest,stack}) == C.Machine{entered(w),C.HeapLoop{} <> C.FlushFinally{} <> C.RoundEnd{} <> rest,stack} : C.Machine}:
  +before = {C.Machine{w,C.Round{} <> rest,stack} : C.Machine}
  +middle = {C.Machine{seated(w),C.RoundAfterSweep{} <> C.FlushFinally{} <> C.RoundEnd{} <> rest,stack} : C.Machine}
  +after = {C.Machine{entered(w),C.HeapLoop{} <> C.FlushFinally{} <> C.RoundEnd{} <> rest,stack} : C.Machine}
  +ready = Equal.trans(Bool,B.ok(seated(w)),B.ok(w),True{},health(w),healthy)
  Driver.appendStep(1n,before,middle,after,Equal.trans(C.Machine,C.step(before),C.round(w,rest,stack),middle,Step.healthyStep(w,C.Round{},rest,stack,healthy),first(w,rest,stack,promoted,dormant)),Step.healthyStep(seated(w),C.RoundAfterSweep{},C.FlushFinally{} <> C.RoundEnd{} <> rest,stack,ready))

def committed(+w: R.World) -> {Content.observe(entered(w)) == Content.observe(w) : Content.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def count(+w: R.World,tx: Nat) -> {R.Transaction.open(B.transaction(entered(w),tx)) == R.Transaction.open(B.transaction(w,tx)) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def promoted(view: Sweep.View) -> List<&2,Nat>:
  match view:
    case Sweep.Lists{promoted,dormant}: promoted

def dormant(view: Sweep.View) -> List<&2,Nat>:
  match view:
    case Sweep.Lists{promoted,dormant}: dormant

def promotedRead(+w: R.World) -> {promoted(Sweep.observe(w)) == R.World.promotedWrites(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def dormantRead(+w: R.World) -> {dormant(Sweep.observe(w)) == R.World.dormantNodes(w) : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def fromSweep(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+empty: {Sweep.observe(w) == Sweep.Lists{[],[]} : Sweep.View},healthy: {B.ok(w) == True{} : Bool}) -> {Steps.iterate(2n,C.Machine{w,C.Round{} <> rest,stack}) == C.Machine{entered(w),C.HeapLoop{} <> C.FlushFinally{} <> C.RoundEnd{} <> rest,stack} : C.Machine}:
  +noPromoted = Equal.trans(List<&2,Nat>,R.World.promotedWrites(w),promoted(Sweep.observe(w)),[],Equal.sym(List<&2,Nat>,promoted(Sweep.observe(w)),R.World.promotedWrites(w),promotedRead(w)),Equal.cong(Sweep.View,List<&2,Nat>,view=>promoted(view),Sweep.observe(w),Sweep.Lists{[],[]},empty))
  +noDormant = Equal.trans(List<&2,Nat>,R.World.dormantNodes(w),dormant(Sweep.observe(w)),[],Equal.sym(List<&2,Nat>,dormant(Sweep.observe(w)),R.World.dormantNodes(w),dormantRead(w)),Equal.cong(Sweep.View,List<&2,Nat>,view=>dormant(view),Sweep.observe(w),Sweep.Lists{[],[]},empty))
  complete(w,rest,stack,noPromoted,noDormant,healthy)
