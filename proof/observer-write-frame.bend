# Primitive observer-arena writes and the actual synchronous/stream clients.
# Action waits and committed content are retained; observer captures may change.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/flight.bend as F
import ../runtime/iterator-state.bend as I
import ./committed-storage-frame.bend as Content
import ./action-wait-allocation.bend as Allocation
import ./arena.bend as Arena

def waitsField(+w: R.World,+rows: List<&2,R.AsyncObserver>) -> {R.World.actionWaits(R.World.with_asyncObservers(w,rows)) == R.World.actionWaits(w) : List<&2,R.ActionWait>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def rowsField(+w: R.World,+rows: List<&2,R.AsyncObserver>) -> {R.World.asyncObservers(R.World.with_asyncObservers(w,rows)) == rows : List<&2,R.AsyncObserver>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def contentField(+w: R.World,+rows: List<&2,R.AsyncObserver>) -> {Content.observe(R.World.with_asyncObservers(w,rows)) == Content.observe(w) : Content.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def setLength(-A: Data,+rows: List<&2,A>,+id: Nat,+record: A) -> {B.length(A,List.set(&2,A,rows,id,record)) == B.length(A,rows) : Nat}:
  match rows id:
    case Nil{} n: {==}
    case head <> tail 0n: {==}
    case head <> +tail 1n+p: Equal.cong(Nat,Nat,n=>1n+n,B.length(A,List.set(&2,A,tail,p,record)),B.length(A,tail),setLength(A,tail,p,record))

def storeWaits(+w: R.World,+id: Nat,+record: R.AsyncObserver) -> {R.World.actionWaits(B.store_asyncObserver(w,id,record)) == R.World.actionWaits(w) : List<&2,R.ActionWait>}:
  waitsField(w,List.set(&2,R.AsyncObserver,R.World.asyncObservers(w),id,record))

def storeContent(+w: R.World,+id: Nat,+record: R.AsyncObserver) -> {Content.observe(B.store_asyncObserver(w,id,record)) == Content.observe(w) : Content.View}:
  contentField(w,List.set(&2,R.AsyncObserver,R.World.asyncObservers(w),id,record))

def storeSize(+w: R.World,+id: Nat,+record: R.AsyncObserver) -> {Allocation.index(B.store_asyncObserver(w,id,record)) == Allocation.index(w) : Nat}:
  Equal.trans(Nat,Allocation.index(B.store_asyncObserver(w,id,record)),B.length(R.AsyncObserver,List.set(&2,R.AsyncObserver,R.World.asyncObservers(w),id,record)),Allocation.index(w),Equal.cong(List<&2,R.AsyncObserver>,Nat,rows=>B.length(R.AsyncObserver,rows),R.World.asyncObservers(B.store_asyncObserver(w,id,record)),List.set(&2,R.AsyncObserver,R.World.asyncObservers(w),id,record),rowsField(w,List.set(&2,R.AsyncObserver,R.World.asyncObservers(w),id,record))),setLength(R.AsyncObserver,R.World.asyncObservers(w),id,record))

def append(+w: R.World,record: R.AsyncObserver) -> R.World:
  R.World.with_asyncObservers(w,B.append(R.AsyncObserver,R.World.asyncObservers(w),[record]))

def appendWaits(+w: R.World,+record: R.AsyncObserver) -> {R.World.actionWaits(append(w,record)) == R.World.actionWaits(w) : List<&2,R.ActionWait>}:
  waitsField(w,B.append(R.AsyncObserver,R.World.asyncObservers(w),[record]))

def appendContent(+w: R.World,+record: R.AsyncObserver) -> {Content.observe(append(w,record)) == Content.observe(w) : Content.View}:
  contentField(w,B.append(R.AsyncObserver,R.World.asyncObservers(w),[record]))

def appendSize(+w: R.World,+record: R.AsyncObserver) -> {Allocation.index(append(w,record)) == Nat.add(Allocation.index(w),1n) : Nat}:
  Equal.trans(Nat,Allocation.index(append(w,record)),B.length(R.AsyncObserver,B.append(R.AsyncObserver,R.World.asyncObservers(w),[record])),Nat.add(Allocation.index(w),1n),Equal.cong(List<&2,R.AsyncObserver>,Nat,rows=>B.length(R.AsyncObserver,rows),R.World.asyncObservers(append(w,record)),B.append(R.AsyncObserver,R.World.asyncObservers(w),[record]),rowsField(w,B.append(R.AsyncObserver,R.World.asyncObservers(w),[record]))),Arena.appendLength(R.AsyncObserver,R.World.asyncObservers(w),[record]))

def stepRecord(+w: R.World,+stream: Nat) -> R.AsyncObserver:
  R.AsyncObserver{R.StreamState.node(B.stream(w,stream)),R.StreamState.result(B.stream(w,stream)),True{},False{},False{},R.Undefined{},R.Undefined{},stream, 0n}

def stepWorld(w: R.World,stream: Nat) -> R.World:
  B.first(R.World,Nat,I.newStepObserver(w,stream))

def streamWaits(+w: R.World,+stream: Nat) -> {R.World.actionWaits(stepWorld(w,stream)) == R.World.actionWaits(w) : List<&2,R.ActionWait>}:
  appendWaits(w,stepRecord(w,stream))

def streamContent(+w: R.World,+stream: Nat) -> {Content.observe(stepWorld(w,stream)) == Content.observe(w) : Content.View}:
  appendContent(w,stepRecord(w,stream))

def streamSize(+w: R.World,+stream: Nat) -> {Allocation.index(stepWorld(w,stream)) == Nat.add(Allocation.index(w),1n) : Nat}:
  appendSize(w,stepRecord(w,stream))


type View is Data:
  View{waits: List<&2,R.ActionWait>,rows: List<&2,R.AsyncObserver>,content: Content.View}

def observe(+w: R.World) -> View:
  View{R.World.actionWaits(w),R.World.asyncObservers(w),Content.observe(w)}

def waitEntries(view: View) -> List<&2,R.ActionWait>:
  match view:
    case View{waits,rows,content}: waits

def observerEntries(view: View) -> List<&2,R.AsyncObserver>:
  match view:
    case View{waits,rows,content}: rows

def committed(view: View) -> Content.View:
  match view:
    case View{waits,rows,content}: content

def objectsField(+w: R.World,rows: List<&2,R.AsyncObject>) -> {observe(R.World.with_asyncObjects(w,rows)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def jobsField(+w: R.World,rows: List<&2,R.HostJob>) -> {observe(R.World.with_hostJobs(w,rows)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def objectStore(+w: R.World,+id: Nat,+record: R.AsyncObject) -> {observe(B.store_asyncObject(w,id,record)) == observe(w) : View}:
  objectsField(w,List.set(&2,R.AsyncObject,R.World.asyncObjects(w),id,record))

def ignoreState(+w: R.World,+observer: Nat,+immediate: Bool,+state: R.AsyncSettlement) -> {observe(I.ignoreState(w,observer,immediate,state)) == observe(w) : View}:
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
        case R.Rejected{+error}: jobsField(w,B.append(R.HostJob,R.World.hostJobs(w),[R.DeliveryJob{observer,True{},error}]))


def ignoreRecord(result: Nat) -> R.AsyncObserver:
  R.AsyncObserver{0n,result,False{},False{},False{},R.Undefined{},R.Undefined{},0n, 0n}

def ignoreTail(+w: R.World,+observer: Nat,+result: Nat) -> R.World:
  +object = B.asyncObject(w,result)
  +w = B.store_asyncObject(w,result,R.AsyncObject.with_observers(object,B.append(Nat,R.AsyncObject.observers(object),[observer])))
  I.ignoreState(w,observer,R.AsyncObject.immediate(object),R.AsyncObject.state(object))

def ignoreTailFrame(+w: R.World,+observer: Nat,+result: Nat) -> {observe(ignoreTail(w,observer,result)) == observe(w) : View}:
  +object = B.asyncObject(w,result)
  +record = R.AsyncObject.with_observers(object,B.append(Nat,R.AsyncObject.observers(object),[observer]))
  +next = B.store_asyncObject(w,result,record)
  Equal.trans(View,observe(ignoreTail(w,observer,result)),observe(next),observe(w),ignoreState(next,observer,R.AsyncObject.immediate(object),R.AsyncObject.state(object)),objectStore(w,result,record))

def ignoreFrame(+w: R.World,+result: Nat) -> {observe(I.ignoreThen(w,result)) == observe(append(w,ignoreRecord(result))) : View}:
  ignoreTailFrame(append(w,ignoreRecord(result)),Allocation.index(w),result)

def ignoreWaits(+w: R.World,+result: Nat) -> {R.World.actionWaits(I.ignoreThen(w,result)) == R.World.actionWaits(w) : List<&2,R.ActionWait>}:
  Equal.trans(List<&2,R.ActionWait>,R.World.actionWaits(I.ignoreThen(w,result)),R.World.actionWaits(append(w,ignoreRecord(result))),R.World.actionWaits(w),Equal.cong(View,List<&2,R.ActionWait>,view=>waitEntries(view),observe(I.ignoreThen(w,result)),observe(append(w,ignoreRecord(result))),ignoreFrame(w,result)),appendWaits(w,ignoreRecord(result)))

def ignoreSize(+w: R.World,+result: Nat) -> {Allocation.index(I.ignoreThen(w,result)) == Nat.add(Allocation.index(w),1n) : Nat}:
  Equal.trans(Nat,Allocation.index(I.ignoreThen(w,result)),Allocation.index(append(w,ignoreRecord(result))),Nat.add(Allocation.index(w),1n),Equal.cong(View,Nat,view=>B.length(R.AsyncObserver,observerEntries(view)),observe(I.ignoreThen(w,result)),observe(append(w,ignoreRecord(result))),ignoreFrame(w,result)),appendSize(w,ignoreRecord(result)))

def ignoreContent(+w: R.World,+result: Nat) -> {Content.observe(I.ignoreThen(w,result)) == Content.observe(w) : Content.View}:
  Equal.trans(Content.View,Content.observe(I.ignoreThen(w,result)),Content.observe(append(w,ignoreRecord(result))),Content.observe(w),Equal.cong(View,Content.View,view=>committed(view),observe(I.ignoreThen(w,result)),observe(append(w,ignoreRecord(result))),ignoreFrame(w,result)),appendContent(w,ignoreRecord(result)))

def fulfilledRecord(+w: R.World,+observer: Nat,value: R.Value) -> R.AsyncObserver:
  R.AsyncObserver.with_resolved(R.AsyncObserver.with_syncValue(B.asyncObserver(w,observer),value),True{})

def rejectedRecord(+w: R.World,+observer: Nat,error: R.Value) -> R.AsyncObserver:
  R.AsyncObserver.with_rejected(R.AsyncObserver.with_syncError(B.asyncObserver(w,observer),error),True{})


def streamIdentity(+w: R.World,+stream: Nat) -> {B.second(R.World,Nat,I.newStepObserver(w,stream)) == Allocation.index(w) : Nat}:
  {==}

def streamRows(+w: R.World,+stream: Nat) -> {R.World.asyncObservers(stepWorld(w,stream)) == B.append(R.AsyncObserver,R.World.asyncObservers(w),[stepRecord(w,stream)]) : List<&2,R.AsyncObserver>}:
  rowsField(w,B.append(R.AsyncObserver,R.World.asyncObservers(w),[stepRecord(w,stream)]))

def streamRecord(+w: R.World,+stream: Nat) -> {B.asyncObserver(stepWorld(w,stream),Allocation.index(w)) == stepRecord(w,stream) : R.AsyncObserver}:
  Equal.trans(R.AsyncObserver,B.asyncObserver(stepWorld(w,stream),Allocation.index(w)),B.get(R.AsyncObserver,B.append(R.AsyncObserver,R.World.asyncObservers(w),[stepRecord(w,stream)]),Allocation.index(w),B.blank_asyncObserver()),stepRecord(w,stream),Equal.cong(List<&2,R.AsyncObserver>,R.AsyncObserver,rows=>B.get(R.AsyncObserver,rows,Allocation.index(w),B.blank_asyncObserver()),R.World.asyncObservers(stepWorld(w,stream)),B.append(R.AsyncObserver,R.World.asyncObservers(w),[stepRecord(w,stream)]),streamRows(w,stream)),Arena.getPrefix(R.AsyncObserver,R.World.asyncObservers(w),stepRecord(w,stream),[],B.blank_asyncObserver()))
