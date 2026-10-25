# Actual shared observer allocation extends its arena and retains action waits.
import Base
import ./committed-storage-frame.bend as Content
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/flight.bend as F
import ./action-wait-allocation.bend as Allocation
import ./arena.bend as Arena


def after(w: R.World,node: Nat,result: Nat) -> R.World:
  B.first(R.World,Nat,F.newObserver(w,node,result))

def waits(+w: R.World,+node: Nat,+result: Nat) ->
  {R.World.actionWaits(after(w,node,result)) == R.World.actionWaits(w) : List<&2,R.ActionWait>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def observers(+w: R.World,+node: Nat,+result: Nat) ->
  {R.World.asyncObservers(after(w,node,result)) == B.append(R.AsyncObserver,R.World.asyncObservers(w),[R.AsyncObserver{node,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n}]) : List<&2,R.AsyncObserver>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def size(+w: R.World,+node: Nat,+result: Nat) -> {Allocation.index(after(w,node,result)) == Nat.add(Allocation.index(w),1n) : Nat}:
  Equal.trans(Nat,Allocation.index(after(w,node,result)),B.length(R.AsyncObserver,B.append(R.AsyncObserver,R.World.asyncObservers(w),[R.AsyncObserver{node,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n}])),Nat.add(Allocation.index(w),1n),Equal.cong(List<&2,R.AsyncObserver>,Nat,entries=>B.length(R.AsyncObserver,entries),R.World.asyncObservers(after(w,node,result)),B.append(R.AsyncObserver,R.World.asyncObservers(w),[R.AsyncObserver{node,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n}]),observers(w,node,result)),Arena.appendLength(R.AsyncObserver,R.World.asyncObservers(w),[R.AsyncObserver{node,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n}]))


def content(+w: R.World,+node: Nat,+result: Nat) -> {Content.observe(after(w,node,result)) == Content.observe(w) : Content.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}
