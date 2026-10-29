# Actual two-step settlement/scan with a newly parked computed reader.
# Initial group/health/intake premises are not repeated on the resulting World.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../proof/held-settle-frame.bend as Frame
import ../proof/held-settle-scan.bend as Quiet
import ../proof/action-body-return.bend as Step
import ../proof/pending-stack-history.bend as Steps
import ../proof/core-run-prefix.bend as Driver
import ../proof/transaction-membership-frame.bend as Count
import ./mixed-settle.bend as Mixed
import ./holding-seam-view.bend as Holding
import ./holding-committed.bend as Content
import ../proof/committed-storage-frame.bend as Committed

# Extract the only initial health fact from the admission package.
def health(-w: R.World,-source: Nat,-reader: Nat,-offset: Nat,ready: Mixed.Ready<w,source,reader,offset>) -> {B.ok(w) == True{} : Bool}:
  match ready:
    case Mixed.SourceReader{pending,held,unstaged,leaf,healthy,comparators,lane,terminal,zombies,quiet}: healthy

def scanning(w: R.World,reader: Nat,+offset: Nat,rest: List<&2,C.Task>,stack: List<&2,R.Value>) -> C.Machine:
  Quiet.scanning(Mixed.held(w,reader,offset),rest,stack,offset)

def skipped(w: R.World,reader: Nat,+offset: Nat,rest: List<&2,C.Task>,stack: List<&2,R.Value>) -> C.Machine:
  Quiet.skipped(Mixed.held(w,reader,offset),rest,stack,offset)

def begins(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+ready: Mixed.Ready<w,source,reader,offset>) -> {C.step(Quiet.start(w,rest,stack,offset)) == scanning(w,reader,offset,rest,stack) : C.Machine}:
  Equal.trans(C.Machine,C.step(Quiet.start(w,rest,stack,offset)),C.settleApplied(w,rest,stack,1n+offset),scanning(w,reader,offset,rest,stack),Step.healthyStep(w,C.SettleApplied{1n+offset},rest,stack,health(w,source,reader,offset,ready)),Equal.trans(C.Machine,C.settleApplied(w,rest,stack,1n+offset),Mixed.target(w,reader,offset,rest,stack),scanning(w,reader,offset,rest,stack),Mixed.complete(w,source,reader,offset,rest,stack,ready),Frame.shape(Mixed.held(w,reader,offset),rest,stack,1n+offset)))

def skips(+w: R.World,+reader: Nat,+offset: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+remaining: Nat,healthy: {B.ok(w) == True{} : Bool},live: {R.World.transactions(w) == [1n+offset] : List<&2,Nat>},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}) -> {C.step(scanning(w,reader,offset,rest,stack)) == skipped(w,reader,offset,rest,stack) : C.Machine}:
  +held = Mixed.held(w,reader,offset)
  +tx = {1n+offset : Nat}
  +postHealth = Equal.trans(Bool,B.ok(held),B.ok(w),True{},Holding.nodeHealth(w,reader,tx),healthy)
  +postLive = Equal.trans(List<&2,Nat>,R.World.transactions(held),R.World.transactions(w),[tx],Holding.nodeLive(w,reader,tx),live)
  +postCount = Equal.trans(Nat,R.Transaction.open(B.transaction(held,tx)),R.Transaction.open(B.transaction(w,tx)),1n+remaining,Count.count(w,held,tx,Count.node(w,reader,tx)),open)
  Quiet.skips(held,rest,stack,offset,remaining,postHealth,postLive,postCount)

def complete(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+remaining: Nat,+ready: Mixed.Ready<w,source,reader,offset>,live: {R.World.transactions(w) == [1n+offset] : List<&2,Nat>},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}) -> {Steps.iterate(2n,Quiet.start(w,rest,stack,offset)) == skipped(w,reader,offset,rest,stack) : C.Machine}:
  Driver.appendStep(1n,Quiet.start(w,rest,stack,offset),scanning(w,reader,offset,rest,stack),skipped(w,reader,offset,rest,stack),begins(w,source,reader,offset,rest,stack,ready),skips(w,reader,offset,rest,stack,remaining,health(w,source,reader,offset,ready),live,open))

def committed(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+remaining: Nat,+ready: Mixed.Ready<w,source,reader,offset>,+live: {R.World.transactions(w) == [1n+offset] : List<&2,Nat>},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}) -> {Committed.observe(C.world(Steps.iterate(2n,Quiet.start(w,rest,stack,offset)))) == Committed.observe(w) : Committed.View}:
  +held = Mixed.held(w,reader,offset)
  Equal.trans(Committed.View,Committed.observe(C.world(Steps.iterate(2n,Quiet.start(w,rest,stack,offset)))),Committed.observe(Frame.world(held)),Committed.observe(w),Equal.cong(C.Machine,Committed.View,m=>Committed.observe(C.world(m)),Steps.iterate(2n,Quiet.start(w,rest,stack,offset)),skipped(w,reader,offset,rest,stack),complete(w,source,reader,offset,rest,stack,remaining,ready,live,open)),Equal.trans(Committed.View,Committed.observe(Frame.world(held)),Committed.observe(held),Committed.observe(w),Frame.committed(held),Content.node(w,reader,1n+offset)))
