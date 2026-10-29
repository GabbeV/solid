# Eight actual steps: retain the seam's callbacks, skip empty zombies, finish
# the round, and restore the caller question without executing its work/stack.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../proof/action-body-return.bend as Step
import ../proof/pending-stack-history.bend as Steps
import ../proof/core-run-prefix.bend as Driver
import ../proof/core-prefix-compose.bend as Prefix
import ../proof/committed-storage-frame.bend as Content
import ./held-queue-parking.bend as Park
import ./held-queue-frame.bend as Frame
import ./quiet-round-return.bend as Return

type Flow is Data:
  Flow{health: Bool,heap: Bool,pending: List<&2,Nat>,cleanup: R.Slot}

def flow(+w: R.World) -> Flow:
  Flow{B.ok(w),Nat.is_ge(R.World.maximum(w),R.World.minimum(w)),R.World.pendingNodes(w),R.World.cleanupError(w)}

def health(frame: Flow) -> Bool:
  match frame:
    case Flow{health,heap,pending,cleanup}: health

def heap(frame: Flow) -> Bool:
  match frame:
    case Flow{health,heap,pending,cleanup}: heap

def pending(frame: Flow) -> List<&2,Nat>:
  match frame:
    case Flow{health,heap,pending,cleanup}: pending

def cleanup(frame: Flow) -> R.Slot:
  match frame:
    case Flow{health,heap,pending,cleanup}: cleanup

def retained(+w: R.World,+tx: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>) -> {flow(Park.world(w,tx,renders,users)) == flow(w) : Flow}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def rendersEmpty(+w: R.World,+tx: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>) -> {R.World.renderQueue(Park.world(w,tx,renders,users)) == [] : List<&2,Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def usersEmpty(+w: R.World,+tx: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>) -> {R.World.userQueue(Park.world(w,tx,renders,users)) == [] : List<&2,R.QueueEntry>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def complete(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>,+question: R.Question,+healthy: {B.ok(w) == True{} : Bool},terminal: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat},member: {B.contains(R.World.transactions(w),1n+offset) == True{} : Bool},ambient: {List.is_empty(&2,Nat,R.World.ambientMarks(w)) == True{} : Bool},renderEmpty: {R.World.renderQueue(w) == [] : List<&2,Nat>},userEmpty: {R.World.userQueue(w) == [] : List<&2,R.QueueEntry>},zombies: {R.World.deferredZombies(w) == [] : List<&2,Nat>},heapEmpty: {Nat.is_ge(R.World.maximum(w),R.World.minimum(w)) == False{} : Bool},pendingEmpty: {R.World.pendingNodes(w) == [] : List<&2,Nat>},cleanupEmpty: {R.World.cleanupError(w) == R.Empty{} : R.Slot}) -> {Steps.iterate(8n,C.Machine{w,C.CompleteSettle{C.SeamFrame{1n+offset,renders,users,[],[]}} <> Return.work(question,rest),stack}) == C.Machine{Return.restored(Park.world(w,1n+offset,renders,users),question),rest,stack} : C.Machine}:
  +tx = {1n+offset : Nat}
  +ending = Return.work(question,rest)
  +before = {C.Machine{w,C.CompleteSettle{C.SeamFrame{tx,renders,users,[],[]}} <> ending,stack} : C.Machine}
  +next = Park.world(w,tx,renders,users)
  +zombie = {C.Machine{next,C.ZombieLoop{[]} <> ending,stack} : C.Machine}
  +atReturn = {C.Machine{next,ending,stack} : C.Machine}
  +after = {C.Machine{Return.restored(next,question),rest,stack} : C.Machine}
  +same = retained(w,tx,renders,users)
  +good = Equal.trans(Bool,B.ok(next),B.ok(w),True{},Equal.cong(Flow,Bool,f=>health(f),flow(next),flow(w),same),healthy)
  +heapReady = Equal.trans(Bool,Nat.is_ge(R.World.maximum(next),R.World.minimum(next)),Nat.is_ge(R.World.maximum(w),R.World.minimum(w)),False{},Equal.cong(Flow,Bool,f=>heap(f),flow(next),flow(w),same),heapEmpty)
  +pendingReady = Equal.trans(List<&2,Nat>,R.World.pendingNodes(next),R.World.pendingNodes(w),[],Equal.cong(Flow,List<&2,Nat>,f=>pending(f),flow(next),flow(w),same),pendingEmpty)
  +cleanupReady = Equal.trans(R.Slot,R.World.cleanupError(next),R.World.cleanupError(w),R.Empty{},Equal.cong(Flow,R.Slot,f=>cleanup(f),flow(next),flow(w),same),cleanupEmpty)
  +first = Equal.trans(C.Machine,C.step(before),C.completeSettle(w,ending,stack,C.SeamFrame{tx,renders,users,[],[]}),zombie,Step.healthyStep(w,C.CompleteSettle{C.SeamFrame{tx,renders,users,[],[]}},ending,stack,healthy),Park.complete(w,ending,stack,offset,renders,users,terminal,member,ambient,renderEmpty,userEmpty,zombies))
  +two = Driver.appendStep(1n,before,zombie,atReturn,first,Step.healthyStep(next,C.ZombieLoop{[]},ending,stack,good))
  Prefix.compose(2n,6n,before,atReturn,after,two,Return.complete(next,question,rest,stack,good,heapReady,pendingReady,rendersEmpty(w,tx,renders,users),usersEmpty(w,tx,renders,users),cleanupReady))

def committed(+w: R.World,+tx: Nat,+renders: List<&2,Nat>,+users: List<&2,R.QueueEntry>,+question: R.Question) -> {Content.observe(Return.restored(Park.world(w,tx,renders,users),question)) == Content.observe(w) : Content.View}:
  Equal.trans(Content.View,Content.observe(Return.restored(Park.world(w,tx,renders,users),question)),Content.observe(Park.world(w,tx,renders,users)),Content.observe(w),Return.committed(Park.world(w,tx,renders,users),question),Frame.committed(w,tx,renders,users))
