# Actual Settle task includes capture clearing/applyGuesses, parking, then the
# actual positive-debt scan. Post-entry admission and count facts are derived.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../proof/mixed-settle.bend as Mixed
import ../proof/mixed-settle-scan.bend as Scan
import ../proof/held-settle-frame.bend as Frame
import ../proof/holding-committed.bend as Content
import ../proof/committed-storage-frame.bend as Committed
import ../proof/pending-stack-history.bend as Steps
import ../proof/core-run-prefix.bend as Driver
import ../proof/action-body-return.bend as Step
import ./settle-entry.bend as Entry
import ./settle-entered-ready.bend as Ready

def start(w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>) -> C.Machine:
  C.Machine{w,C.Settle{} <> rest,stack}

def begins(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+ready: Mixed.Ready<w,source,reader,offset>,capture: {R.World.flushTransaction(w) == 1n+offset : Nat},live: {List.is_empty(&2,Nat,R.LaneState.live(R.World.laneState(w))) == True{} : Bool},empty: {List.is_empty(&2,R.Guess,R.LaneState.pendingGuesses(R.World.laneState(w))) == True{} : Bool}) -> {C.step(start(w,rest,stack)) == Scan.scanning(Entry.entered(w),reader,offset,rest,stack) : C.Machine}:
  +next = Entry.entered(w)
  +first = Equal.trans(C.Machine,C.step(start(w,rest,stack)),C.beginSettle(w,rest,stack),C.settleApplied(next,rest,stack,R.World.flushTransaction(w)),Step.healthyStep(w,C.Settle{},rest,stack,Scan.health(w,source,reader,offset,ready)),Entry.begin(w,rest,stack,live,empty))
  +chosen = Equal.cong(Nat,C.Machine,tx=>C.settleApplied(next,rest,stack,tx),R.World.flushTransaction(w),1n+offset,capture)
  +actual = Mixed.complete(next,source,reader,offset,rest,stack,Ready.mixed(w,source,reader,offset,ready))
  Equal.trans(C.Machine,C.step(start(w,rest,stack)),C.settleApplied(next,rest,stack,R.World.flushTransaction(w)),Scan.scanning(next,reader,offset,rest,stack),first,Equal.trans(C.Machine,C.settleApplied(next,rest,stack,R.World.flushTransaction(w)),C.settleApplied(next,rest,stack,1n+offset),Scan.scanning(next,reader,offset,rest,stack),chosen,Equal.trans(C.Machine,C.settleApplied(next,rest,stack,1n+offset),Mixed.target(next,reader,offset,rest,stack),Scan.scanning(next,reader,offset,rest,stack),actual,Frame.shape(Mixed.held(next,reader,offset),rest,stack,1n+offset))))

def complete(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+remaining: Nat,+ready: Mixed.Ready<w,source,reader,offset>,capture: {R.World.flushTransaction(w) == 1n+offset : Nat},lanes: {List.is_empty(&2,Nat,R.LaneState.live(R.World.laneState(w))) == True{} : Bool},empty: {List.is_empty(&2,R.Guess,R.LaneState.pendingGuesses(R.World.laneState(w))) == True{} : Bool},live: {R.World.transactions(w) == [1n+offset] : List<&2,Nat>},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}) -> {Steps.iterate(2n,start(w,rest,stack)) == Scan.skipped(Entry.entered(w),reader,offset,rest,stack) : C.Machine}:
  +next = Entry.entered(w)
  +health = Scan.health(next,source,reader,offset,Ready.mixed(w,source,reader,offset,ready))
  +nextLive = Equal.trans(List<&2,Nat>,R.World.transactions(next),R.World.transactions(w),[1n+offset],Ready.live(w),live)
  +nextCount = Equal.trans(Nat,R.Transaction.open(B.transaction(next,1n+offset)),R.Transaction.open(B.transaction(w,1n+offset)),1n+remaining,Ready.count(w,1n+offset),open)
  Driver.appendStep(1n,start(w,rest,stack),Scan.scanning(next,reader,offset,rest,stack),Scan.skipped(next,reader,offset,rest,stack),begins(w,source,reader,offset,rest,stack,ready,capture,lanes,empty),Scan.skips(next,reader,offset,rest,stack,remaining,health,nextLive,nextCount))

def committed(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+remaining: Nat,+ready: Mixed.Ready<w,source,reader,offset>,+capture: {R.World.flushTransaction(w) == 1n+offset : Nat},+lanes: {List.is_empty(&2,Nat,R.LaneState.live(R.World.laneState(w))) == True{} : Bool},+empty: {List.is_empty(&2,R.Guess,R.LaneState.pendingGuesses(R.World.laneState(w))) == True{} : Bool},+live: {R.World.transactions(w) == [1n+offset] : List<&2,Nat>},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}) -> {Committed.observe(C.world(Steps.iterate(2n,start(w,rest,stack)))) == Committed.observe(w) : Committed.View}:
  +next = Entry.entered(w)
  +held = Mixed.held(next,reader,offset)
  +actual = Equal.cong(C.Machine,Committed.View,m=>Committed.observe(C.world(m)),Steps.iterate(2n,start(w,rest,stack)),Scan.skipped(next,reader,offset,rest,stack),complete(w,source,reader,offset,rest,stack,remaining,ready,capture,lanes,empty,live,open))
  Equal.trans(Committed.View,Committed.observe(C.world(Steps.iterate(2n,start(w,rest,stack)))),Committed.observe(Frame.world(held)),Committed.observe(w),actual,Equal.trans(Committed.View,Committed.observe(Frame.world(held)),Committed.observe(held),Committed.observe(w),Frame.committed(held),Equal.trans(Committed.View,Committed.observe(held),Committed.observe(next),Committed.observe(w),Content.node(next,reader,1n+offset),Ready.committed(w))))
