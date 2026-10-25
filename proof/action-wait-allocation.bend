# Actual Action.wait/newObserver/addObserver allocation fields. No action
# callback, transaction debt or result delivery is replaced by these equations.
import Base
import ./committed-storage-frame.bend as Content
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/flight.bend as F
import ./arena.bend as Arena
import ./node-store-lookup.bend as Store


def index(w: R.World) -> Nat:
  B.length(R.AsyncObserver,R.World.asyncObservers(w))

def after(+w: R.World,action: Nat,result: Nat,kind: U32) -> R.World:
  B.first(R.World,Nat,A.wait(w,action,result,kind))

def identity(+w: R.World,+action: Nat,+result: Nat,+kind: U32) ->
  {B.second(R.World,Nat,A.wait(w,action,result,kind)) == index(w) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def waits(+w: R.World,+action: Nat,+result: Nat,+kind: U32) ->
  {R.World.actionWaits(after(w,action,result,kind)) == B.append(R.ActionWait,R.World.actionWaits(w),[R.ActionWait{index(w),action,kind,False{}}]) : List<&2,R.ActionWait>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def observers(+w: R.World,+action: Nat,+result: Nat,+kind: U32) ->
  {R.World.asyncObservers(after(w,action,result,kind)) == B.append(R.AsyncObserver,R.World.asyncObservers(w),[R.AsyncObserver{0n,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n}]) : List<&2,R.AsyncObserver>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def size(+w: R.World,+action: Nat,+result: Nat,+kind: U32) -> {index(after(w,action,result,kind)) == Nat.add(index(w),1n) : Nat}:
  Equal.trans(Nat,index(after(w,action,result,kind)),B.length(R.AsyncObserver,B.append(R.AsyncObserver,R.World.asyncObservers(w),[R.AsyncObserver{0n,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n}])),Nat.add(index(w),1n),Equal.cong(List<&2,R.AsyncObserver>,Nat,entries=>B.length(R.AsyncObserver,entries),R.World.asyncObservers(after(w,action,result,kind)),B.append(R.AsyncObserver,R.World.asyncObservers(w),[R.AsyncObserver{0n,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n}]),observers(w,action,result,kind)),Arena.appendLength(R.AsyncObserver,R.World.asyncObservers(w),[R.AsyncObserver{0n,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n}]))


def waitsStored(+w: R.World,+entries: List<&2,R.ActionWait>) -> {R.World.actionWaits(R.World.with_actionWaits(w,entries)) == entries : List<&2,R.ActionWait>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def observerRecord(+w: R.World,+action: Nat,+result: Nat,+kind: U32) -> {B.asyncObserver(after(w,action,result,kind),index(w)) == R.AsyncObserver{0n,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n} : R.AsyncObserver}:
  Equal.trans(R.AsyncObserver,B.asyncObserver(after(w,action,result,kind),index(w)),B.get(R.AsyncObserver,B.append(R.AsyncObserver,R.World.asyncObservers(w),[R.AsyncObserver{0n,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n}]),index(w),B.blank_asyncObserver()),R.AsyncObserver{0n,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n},Equal.cong(List<&2,R.AsyncObserver>,R.AsyncObserver,entries=>B.get(R.AsyncObserver,entries,index(w),B.blank_asyncObserver()),R.World.asyncObservers(after(w,action,result,kind)),B.append(R.AsyncObserver,R.World.asyncObservers(w),[R.AsyncObserver{0n,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n}]),observers(w,action,result,kind)),Arena.getPrefix(R.AsyncObserver,R.World.asyncObservers(w),R.AsyncObserver{0n,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n},[],B.blank_asyncObserver()))


def updated(+w: R.World,+result: Nat,observer: Nat) -> R.AsyncObject:
  R.AsyncObject.with_observers(B.asyncObject(w,result),B.append(Nat,R.AsyncObject.observers(B.asyncObject(w,result)),[observer]))

def objects(+w: R.World,+action: Nat,+result: Nat,+kind: U32) -> {R.World.asyncObjects(after(w,action,result,kind)) == List.set(&2,R.AsyncObject,R.World.asyncObjects(w),result,updated(w,result,index(w))) : List<&2,R.AsyncObject>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def subscribedObject(+w: R.World,+action: Nat,+result: Nat,+kind: U32,valid: {Nat.is_lt(result,B.length(R.AsyncObject,R.World.asyncObjects(w))) == True{} : Bool}) -> {B.asyncObject(after(w,action,result,kind),result) == updated(w,result,index(w)) : R.AsyncObject}:
  Equal.trans(R.AsyncObject,B.asyncObject(after(w,action,result,kind),result),B.get(R.AsyncObject,List.set(&2,R.AsyncObject,R.World.asyncObjects(w),result,updated(w,result,index(w))),result,B.blank_asyncObject()),updated(w,result,index(w)),Equal.cong(List<&2,R.AsyncObject>,R.AsyncObject,entries=>B.get(R.AsyncObject,entries,result,B.blank_asyncObject()),R.World.asyncObjects(after(w,action,result,kind)),List.set(&2,R.AsyncObject,R.World.asyncObjects(w),result,updated(w,result,index(w))),objects(w,action,result,kind)),Store.setSame(R.AsyncObject,R.World.asyncObjects(w),result,updated(w,result,index(w)),B.blank_asyncObject(),valid))


def content(+w: R.World,+action: Nat,+result: Nat,+kind: U32) -> {Content.observe(after(w,action,result,kind)) == Content.observe(w) : Content.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}
