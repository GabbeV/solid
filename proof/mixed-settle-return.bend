# Real Settle through positive-group scan, callback parking and round return.
# Every intermediate queue/health/control premise is derived from initial facts.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../proof/mixed-settle.bend as Mixed
import ../proof/mixed-settle-scan.bend as Scan
import ../proof/held-settle-frame.bend as Frame
import ../proof/action-body-return.bend as Step
import ../proof/core-run-prefix.bend as Driver
import ../proof/core-prefix-compose.bend as Prefix
import ../proof/pending-stack-history.bend as Steps
import ../proof/committed-storage-frame.bend as Content
import ./settle-entry.bend as Entry
import ./mixed-settle-entry-scan.bend as Start
import ./mixed-parked-scope.bend as Scope
import ./held-queue-parking.bend as Park
import ./held-queue-return.bend as End
import ./held-queue-frame.bend as QueueFrame
import ./settle-entered-ready.bend as EntryReady
import ../proof/holding-committed.bend as HeldContent
import ./quiet-round-return.bend as Return

def held(w: R.World,reader: Nat,offset: Nat) -> R.World:
  Mixed.held(Entry.entered(w),reader,offset)

def renders(w: R.World,reader: Nat,offset: Nat) -> List<&2,Nat>:
  R.World.renderQueue(Frame.prepared(held(w,reader,offset)))

def users(w: R.World,reader: Nat,offset: Nat) -> List<&2,R.QueueEntry>:
  R.World.userQueue(Frame.prepared(held(w,reader,offset)))

def world(+w: R.World,+reader: Nat,+offset: Nat,question: R.Question) -> R.World:
  Return.restored(Park.world(Scope.world(w,reader,offset),1n+offset,renders(w,reader,offset),users(w,reader,offset)),question)

def complete(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+remaining: Nat,+ready: Mixed.Ready<w,source,reader,offset>,+capture: {R.World.flushTransaction(w) == 1n+offset : Nat},+lanes: {List.is_empty(&2,Nat,R.LaneState.live(R.World.laneState(w))) == True{} : Bool},+guesses: {List.is_empty(&2,R.Guess,R.LaneState.pendingGuesses(R.World.laneState(w))) == True{} : Bool},+live: {R.World.transactions(w) == [1n+offset] : List<&2,Nat>},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+question: R.Question,heap: {Nat.is_ge(R.World.maximum(w),R.World.minimum(w)) == False{} : Bool},ambient: {List.is_empty(&2,Nat,R.World.ambientMarks(w)) == True{} : Bool},cleanup: {R.World.cleanupError(w) == R.Empty{} : R.Slot}) -> {Steps.iterate(11n,Start.start(w,Return.work(question,rest),stack)) == C.Machine{world(w,reader,offset,question),rest,stack} : C.Machine}:
  +ending = Return.work(question,rest)
  +before = Start.start(w,ending,stack)
  +atScan = Scan.skipped(Entry.entered(w),reader,offset,ending,stack)
  +next = Scope.world(w,reader,offset)
  +frame = Frame.frame(held(w,reader,offset),1n+offset)
  +atComplete = {C.Machine{next,C.CompleteSettle{frame} <> ending,stack} : C.Machine}
  +good = Scope.health(w,source,reader,offset,ready)
  +prefix = Driver.appendStep(2n,before,atScan,atComplete,Start.complete(w,source,reader,offset,ending,stack,remaining,ready,capture,lanes,guesses,live,open),Step.healthyStep(next,C.LandTransactions{frame,0n},ending,stack,good))
  +same = Scope.controls(w,reader,offset)
  +heapReady = Equal.trans(Bool,Nat.is_ge(R.World.maximum(next),R.World.minimum(next)),Nat.is_ge(R.World.maximum(w),R.World.minimum(w)),False{},Equal.cong(Scope.Controls,Bool,f=>Scope.heap(f),Scope.observe(next),Scope.observe(w),same),heap)
  +ambientReady = Equal.trans(Bool,List.is_empty(&2,Nat,R.World.ambientMarks(next)),List.is_empty(&2,Nat,R.World.ambientMarks(w)),True{},Equal.cong(Scope.Controls,Bool,f=>Scope.ambient(f),Scope.observe(next),Scope.observe(w),same),ambient)
  +cleanupReady = Equal.trans(R.Slot,R.World.cleanupError(next),R.World.cleanupError(w),R.Empty{},Equal.cong(Scope.Controls,R.Slot,f=>Scope.cleanup(f),Scope.observe(next),Scope.observe(w),same),cleanup)
  +empty = Scope.emptyQueues(held(w,reader,offset))
  +pendingReady = Equal.cong(Scope.Queues,List<&2,Nat>,f=>Scope.pending(f),Scope.queues(next),Scope.Queues{[],[],[],[]},empty)
  +renderReady = Equal.cong(Scope.Queues,List<&2,Nat>,f=>Scope.renders(f),Scope.queues(next),Scope.Queues{[],[],[],[]},empty)
  +userReady = Equal.cong(Scope.Queues,List<&2,R.QueueEntry>,f=>Scope.users(f),Scope.queues(next),Scope.Queues{[],[],[],[]},empty)
  +zombieReady = Equal.cong(Scope.Queues,List<&2,Nat>,f=>Scope.zombies(f),Scope.queues(next),Scope.Queues{[],[],[],[]},empty)
  +suffix = End.complete(next,rest,stack,offset,renders(w,reader,offset),users(w,reader,offset),question,good,Scope.terminal(w,source,reader,offset,ready),Scope.member(w,reader,offset,live),ambientReady,renderReady,userReady,zombieReady,heapReady,pendingReady,cleanupReady)
  Prefix.compose(3n,8n,before,atComplete,C.Machine{world(w,reader,offset,question),rest,stack},prefix,suffix)


def worldCommitted(+w: R.World,+reader: Nat,+offset: Nat,+question: R.Question) -> {Content.observe(world(w,reader,offset,question)) == Content.observe(w) : Content.View}:
  +next = Scope.world(w,reader,offset)
  +beforeHold = Entry.entered(w)
  +held = held(w,reader,offset)
  Equal.trans(Content.View,Content.observe(world(w,reader,offset,question)),Content.observe(next),Content.observe(w),End.committed(next,1n+offset,renders(w,reader,offset),users(w,reader,offset),question),Equal.trans(Content.View,Content.observe(next),Content.observe(held),Content.observe(w),Frame.committed(held),Equal.trans(Content.View,Content.observe(held),Content.observe(beforeHold),Content.observe(w),HeldContent.node(beforeHold,reader,1n+offset),EntryReady.committed(w))))

def worldCount(+w: R.World,+reader: Nat,+offset: Nat,+question: R.Question,+id: Nat) -> {R.Transaction.open(B.transaction(world(w,reader,offset,question),id)) == R.Transaction.open(B.transaction(w,id)) : Nat}:
  +next = Scope.world(w,reader,offset)
  +parked = Park.world(next,1n+offset,renders(w,reader,offset),users(w,reader,offset))
  Equal.trans(Nat,R.Transaction.open(B.transaction(world(w,reader,offset,question),id)),R.Transaction.open(B.transaction(parked,id)),R.Transaction.open(B.transaction(w,id)),Return.count(parked,question,id),Equal.trans(Nat,R.Transaction.open(B.transaction(parked,id)),R.Transaction.open(B.transaction(next,id)),R.Transaction.open(B.transaction(w,id)),QueueFrame.count(next,1n+offset,renders(w,reader,offset),users(w,reader,offset),id),Scope.count(w,reader,offset,id)))

def committed(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+remaining: Nat,+ready: Mixed.Ready<w,source,reader,offset>,+capture: {R.World.flushTransaction(w) == 1n+offset : Nat},+lanes: {List.is_empty(&2,Nat,R.LaneState.live(R.World.laneState(w))) == True{} : Bool},+guesses: {List.is_empty(&2,R.Guess,R.LaneState.pendingGuesses(R.World.laneState(w))) == True{} : Bool},+live: {R.World.transactions(w) == [1n+offset] : List<&2,Nat>},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+question: R.Question,heap: {Nat.is_ge(R.World.maximum(w),R.World.minimum(w)) == False{} : Bool},ambient: {List.is_empty(&2,Nat,R.World.ambientMarks(w)) == True{} : Bool},cleanup: {R.World.cleanupError(w) == R.Empty{} : R.Slot}) -> {Content.observe(C.world(Steps.iterate(11n,Start.start(w,Return.work(question,rest),stack)))) == Content.observe(w) : Content.View}:
  Equal.trans(Content.View,Content.observe(C.world(Steps.iterate(11n,Start.start(w,Return.work(question,rest),stack)))),Content.observe(world(w,reader,offset,question)),Content.observe(w),Equal.cong(C.Machine,Content.View,m=>Content.observe(C.world(m)),Steps.iterate(11n,Start.start(w,Return.work(question,rest),stack)),C.Machine{world(w,reader,offset,question),rest,stack},complete(w,source,reader,offset,rest,stack,remaining,ready,capture,lanes,guesses,live,open,question,heap,ambient,cleanup)),worldCommitted(w,reader,offset,question))

def count(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+remaining: Nat,+ready: Mixed.Ready<w,source,reader,offset>,+capture: {R.World.flushTransaction(w) == 1n+offset : Nat},+lanes: {List.is_empty(&2,Nat,R.LaneState.live(R.World.laneState(w))) == True{} : Bool},+guesses: {List.is_empty(&2,R.Guess,R.LaneState.pendingGuesses(R.World.laneState(w))) == True{} : Bool},+live: {R.World.transactions(w) == [1n+offset] : List<&2,Nat>},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat},+question: R.Question,heap: {Nat.is_ge(R.World.maximum(w),R.World.minimum(w)) == False{} : Bool},ambient: {List.is_empty(&2,Nat,R.World.ambientMarks(w)) == True{} : Bool},cleanup: {R.World.cleanupError(w) == R.Empty{} : R.Slot}) -> {R.Transaction.open(B.transaction(C.world(Steps.iterate(11n,Start.start(w,Return.work(question,rest),stack))),1n+offset)) == 1n+remaining : Nat}:
  Equal.trans(Nat,R.Transaction.open(B.transaction(C.world(Steps.iterate(11n,Start.start(w,Return.work(question,rest),stack))),1n+offset)),R.Transaction.open(B.transaction(world(w,reader,offset,question),1n+offset)),1n+remaining,Equal.cong(C.Machine,Nat,m=>R.Transaction.open(B.transaction(C.world(m),1n+offset)),Steps.iterate(11n,Start.start(w,Return.work(question,rest),stack)),C.Machine{world(w,reader,offset,question),rest,stack},complete(w,source,reader,offset,rest,stack,remaining,ready,capture,lanes,guesses,live,open,question,heap,ambient,cleanup)),Equal.trans(Nat,R.Transaction.open(B.transaction(world(w,reader,offset,question),1n+offset)),R.Transaction.open(B.transaction(w,1n+offset)),1n+remaining,worldCount(w,reader,offset,question,1n+offset),open))
