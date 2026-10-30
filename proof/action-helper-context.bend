# Actual callback-table helper histories retain every other World field.
# This supplies captured action context, not legality of the whole IO protocol.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/flight.bend as F
import ../runtime/iterator-state.bend as I
import ./action-wait-history.bend as History
import ./observer-capture-history.bend as Capture
import ./observer-write-frame.bend as Observer
import ./action-wait-allocation.bend as Allocation
import ./action-wait-fixture.bend as Input


def erase(w: R.World) -> R.World:
  R.World.with_actionWaits(R.World.with_asyncObservers(R.World.with_asyncObjects(R.World.with_hostJobs(w,[]),[]),[]),[])

def jobs(+w: R.World,value: List<&2,R.HostJob>) -> {erase(R.World.with_hostJobs(w,value)) == erase(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def objects(+w: R.World,value: List<&2,R.AsyncObject>) -> {erase(R.World.with_asyncObjects(w,value)) == erase(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def observers(+w: R.World,value: List<&2,R.AsyncObserver>) -> {erase(R.World.with_asyncObservers(w,value)) == erase(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def waits(+w: R.World,value: List<&2,R.ActionWait>) -> {erase(R.World.with_actionWaits(w,value)) == erase(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def compose(+a: R.World,+b: R.World,+c: R.World,last: {erase(c) == erase(b) : R.World},first: {erase(b) == erase(a) : R.World}) -> {erase(c) == erase(a) : R.World}:
  Equal.trans(R.World,erase(c),erase(b),erase(a),last,first)

def objectStore(+w: R.World,+id: Nat,+record: R.AsyncObject) -> {erase(B.store_asyncObject(w,id,record)) == erase(w) : R.World}:
  objects(w,List.set(&2,R.AsyncObject,R.World.asyncObjects(w),id,record))

def observerStore(+w: R.World,+id: Nat,+record: R.AsyncObserver) -> {erase(B.store_asyncObserver(w,id,record)) == erase(w) : R.World}:
  observers(w,List.set(&2,R.AsyncObserver,R.World.asyncObservers(w),id,record))

def addObserver(+w: R.World,+result: Nat,+id: Nat) -> {erase(F.addObserver(w,result,id)) == erase(w) : R.World}:
  objectStore(w,result,R.AsyncObject.with_observers(B.asyncObject(w,result),B.append(Nat,R.AsyncObject.observers(B.asyncObject(w,result)),[id])))

def allocated(+w: R.World,+node: Nat,+result: Nat) -> {erase(B.first(R.World,Nat,F.newObserver(w,node,result))) == erase(w) : R.World}:
  observers(w,B.append(R.AsyncObserver,R.World.asyncObservers(w),[R.AsyncObserver{node,result,True{},False{},False{},R.Undefined{},R.Undefined{},0n, 0n}]))

def registered(+w: R.World,+action: Nat,+result: Nat,+kind: U32) -> {erase(Allocation.after(w,action,result,kind)) == erase(w) : R.World}:
  +first = B.first(R.World,Nat,F.newObserver(w,0n,result))
  +entries = B.append(R.ActionWait,R.World.actionWaits(first),[R.ActionWait{Allocation.index(w),action,kind,False{}}])
  +marked = R.World.with_actionWaits(first,entries)
  compose(w,first,Allocation.after(w,action,result,kind),compose(first,marked,Allocation.after(w,action,result,kind),addObserver(marked,result,Allocation.index(w)),waits(first,entries)),allocated(w,0n,result))

def ignoredState(+w: R.World,+id: Nat,+immediate: Bool,+state: R.AsyncSettlement) -> {erase(I.ignoreState(w,id,immediate,state)) == erase(w) : R.World}:
  match immediate:
    case True{}:
      match state:
        case R.Unresolved{}: {==}
        case R.Fulfilled{value}: {==}
        case R.Rejected{error}: {==}
    case False{}:
      match state:
        case R.Unresolved{}: {==}
        case R.Fulfilled{value}: {==}
        case R.Rejected{+error}: jobs(w,B.append(R.HostJob,R.World.hostJobs(w),[R.DeliveryJob{id,True{},error}]))

def ignoredTail(+w: R.World,+id: Nat,+result: Nat) -> {erase(Observer.ignoreTail(w,id,result)) == erase(w) : R.World}:
  +object = B.asyncObject(w,result)
  +record = R.AsyncObject.with_observers(object,B.append(Nat,R.AsyncObject.observers(object),[id]))
  +next = B.store_asyncObject(w,result,record)
  compose(w,next,Observer.ignoreTail(w,id,result),ignoredState(next,id,R.AsyncObject.immediate(object),R.AsyncObject.state(object)),objectStore(w,result,record))

def ignored(+w: R.World,+result: Nat) -> {erase(I.ignoreThen(w,result)) == erase(w) : R.World}:
  +rows = B.append(R.AsyncObserver,R.World.asyncObservers(w),[Observer.ignoreRecord(result)])
  +grown = R.World.with_asyncObservers(w,rows)
  compose(w,grown,I.ignoreThen(w,result),ignoredTail(grown,Allocation.index(w),result),observers(w,rows))

def captured(+w: R.World,+operation: Capture.Operation) -> {erase(Capture.after(w,operation)) == erase(w) : R.World}:
  match operation:
    case Capture.CaptureFulfilled{observer,value}: observerStore(w,observer,Observer.fulfilledRecord(w,observer,value))
    case Capture.CaptureRejected{observer,error}: observerStore(w,observer,Observer.rejectedRecord(w,observer,error))
    case Capture.CaptureStream{stream}: observers(w,B.append(R.AsyncObserver,R.World.asyncObservers(w),[Observer.stepRecord(w,stream)]))
    case Capture.CaptureIgnored{result}: ignored(w,result)

def step(+w: R.World,+event: History.WaitEvent) -> {erase(History.step(w,event)) == erase(w) : R.World}:
  match event:
    case History.WaitRegister{action,result,kind}: registered(w,action,result,kind)
    case History.ObserverAllocate{node,result}: allocated(w,node,result)
    case History.WaitMark{id}: waits(w,A.settleWait(R.World.actionWaits(w),id))
    case History.ObserverCapture{operation}: captured(w,operation)

def history(+events: List<&2,History.WaitEvent>,+w: R.World) -> {erase(History.run(events,w)) == erase(w) : R.World}:
  match events:
    case Nil{}: {==}
    case +head <> +tail: compose(w,History.step(w,head),History.run(tail,History.step(w,head)),history(tail,History.step(w,head)),step(w,head))

def actionsErased(+w: R.World) -> {R.World.actions(erase(w)) == R.World.actions(w) : List<&2,R.ActionState>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def historyActions(+events: List<&2,History.WaitEvent>,+w: R.World) -> {R.World.actions(History.run(events,w)) == R.World.actions(w) : List<&2,R.ActionState>}:
  +next = History.run(events,w)
  Equal.trans(List<&2,R.ActionState>,R.World.actions(next),R.World.actions(erase(next)),R.World.actions(w),Equal.sym(List<&2,R.ActionState>,R.World.actions(erase(next)),R.World.actions(next),actionsErased(next)),Equal.trans(List<&2,R.ActionState>,R.World.actions(erase(next)),R.World.actions(erase(w)),R.World.actions(w),Equal.cong(R.World,List<&2,R.ActionState>,state=>R.World.actions(state),erase(next),erase(w),history(events,w)),actionsErased(w)))

def beforeAllocated(+values: List<&2,R.Value>,+prefix: List<&2,History.WaitEvent>) -> {Nat.is_lt(Input.action(values),B.length(R.ActionState,R.World.actions(Input.before(values,prefix)))) == True{} : Bool}:
  Equal.trans(Bool,Nat.is_lt(Input.action(values),B.length(R.ActionState,R.World.actions(Input.before(values,prefix)))),Nat.is_lt(Input.action(values),B.length(R.ActionState,R.World.actions(Input.initial(values)))),True{},Equal.cong(List<&2,R.ActionState>,Bool,rows=>Nat.is_lt(Input.action(values),B.length(R.ActionState,rows)),R.World.actions(Input.before(values,prefix)),R.World.actions(Input.initial(values)),historyActions(prefix,Input.initial(values))),Input.allocated(values))

def beforeCell(+values: List<&2,R.Value>,+prefix: List<&2,History.WaitEvent>) -> {A.get(Input.before(values,prefix),Input.action(values)) == A.get(Input.initial(values),Input.action(values)) : R.ActionState}:
  Equal.cong(List<&2,R.ActionState>,R.ActionState,rows=>B.get(R.ActionState,rows,Input.action(values),A.blank()),R.World.actions(Input.before(values,prefix)),R.World.actions(Input.initial(values)),historyActions(prefix,Input.initial(values)))


def arenaErased(+w: R.World) -> {R.World.txArena(erase(w)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def historyArena(+events: List<&2,History.WaitEvent>,+w: R.World) -> {R.World.txArena(History.run(events,w)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  +next = History.run(events,w)
  Equal.trans(List<&2,R.Transaction>,R.World.txArena(next),R.World.txArena(erase(next)),R.World.txArena(w),Equal.sym(List<&2,R.Transaction>,R.World.txArena(erase(next)),R.World.txArena(next),arenaErased(next)),Equal.trans(List<&2,R.Transaction>,R.World.txArena(erase(next)),R.World.txArena(erase(w)),R.World.txArena(w),Equal.cong(R.World,List<&2,R.Transaction>,state=>R.World.txArena(state),erase(next),erase(w),history(events,w)),arenaErased(w)))
