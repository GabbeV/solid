# Two actual core steps from SettleApplied to the skipped positive-debt group.
# Every fact about the scanner's World is transported from the initial input.
# Reaching SettleApplied from the queued Round remains a separate obligation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ./held-park-intake.bend as I
import ./held-settle-intake.bend as Intake
import ./held-settle-frame.bend as Frame
import ./settle-lane-empty.bend as Lane
import ./action-landing-scan.bend as Scan
import ./action-body-return.bend as Step
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver
import ./committed-storage-frame.bend as Committed

type Ready<-w: R.World,-offset: Nat> is Data:
  Quiet{intake: I.Intake<w,B.length(Nat,R.World.pendingNodes(w))>,first: {I.cursor(w,B.length(Nat,R.World.pendingNodes(w)),intake) == 0n : Nat},healthy: {B.ok(w) == True{} : Bool},comparators: {List.is_empty(&2,R.ComparatorBinding,R.World.comparators(w)) == True{} : Bool},lane: {R.Transaction.lane(B.transaction(w,1n+offset)) == False{} : Bool},terminal: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat},zombies: {R.World.deferredZombies(w) == [] : List<&2,Nat>},quiet: {Lane.quiet(w) == True{} : Bool}}

def health(-w: R.World,-offset: Nat,ready: Ready<w,offset>) -> {B.ok(w) == True{} : Bool}:
  match ready:
    case Quiet{intake,first,healthy,comparators,lane,terminal,zombies,quiet}: healthy

def initial(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,ready: Ready<w,offset>) -> {C.settleApplied(w,rest,stack,1n+offset) == Intake.target(w,rest,stack,1n+offset) : C.Machine}:
  match ready:
    case Quiet{intake,first,healthy,comparators,lane,terminal,zombies,quiet}:
      Intake.complete(w,rest,stack,offset,intake,first,healthy,comparators,lane,terminal,zombies,quiet)

def start(w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,offset: Nat) -> C.Machine:
  C.Machine{w,C.SettleApplied{1n+offset} <> rest,stack}

def scanning(+w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,offset: Nat) -> C.Machine:
  C.Machine{Frame.world(w),C.LandTransactions{Frame.frame(w,1n+offset),B.length(Nat,R.World.transactions(w))} <> rest,stack}

def skipped(+w: R.World,rest: List<&2,C.Task>,stack: List<&2,R.Value>,offset: Nat) -> C.Machine:
  C.Machine{Frame.world(w),C.LandTransactions{Frame.frame(w,1n+offset),0n} <> rest,stack}

def begins(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+ready: Ready<w,offset>) -> {C.step(start(w,rest,stack,offset)) == scanning(w,rest,stack,offset) : C.Machine}:
  Equal.trans(C.Machine,C.step(start(w,rest,stack,offset)),C.settleApplied(w,rest,stack,1n+offset),scanning(w,rest,stack,offset),Step.healthyStep(w,C.SettleApplied{1n+offset},rest,stack,health(w,offset,ready)),Equal.trans(C.Machine,C.settleApplied(w,rest,stack,1n+offset),Intake.target(w,rest,stack,1n+offset),scanning(w,rest,stack,offset),initial(w,rest,stack,offset,ready),Frame.shape(w,rest,stack,1n+offset)))

def skips(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+remaining: Nat,+healthy: {B.ok(w) == True{} : Bool},+live: {R.World.transactions(w) == [1n+offset] : List<&2,Nat>},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}) -> {C.step(scanning(w,rest,stack,offset)) == skipped(w,rest,stack,offset) : C.Machine}:
  +next = Frame.world(w)
  +tx = {1n+offset : Nat}
  +frame = Frame.frame(w,tx)
  +size = Equal.cong(List<&2,Nat>,Nat,rows=>B.length(Nat,rows),R.World.transactions(w),[tx],live)
  +one = Equal.cong(Nat,C.Machine,n=>C.step(C.Machine{next,C.LandTransactions{frame,n} <> rest,stack}),B.length(Nat,R.World.transactions(w)),1n,size)
  +postHealth = Equal.trans(Bool,B.ok(next),B.ok(w),True{},Frame.health(w),healthy)
  +postLive = Equal.trans(List<&2,Nat>,R.World.transactions(next),R.World.transactions(w),[tx],Frame.live(w),live)
  +lookup = Equal.cong(List<&2,Nat>,Nat,rows=>B.get(Nat,rows,0n,0n),R.World.transactions(next),[tx],postLive)
  +count = Equal.trans(Nat,R.Transaction.open(B.transaction(next,tx)),R.Transaction.open(B.transaction(w,tx)),1n+remaining,Equal.cong(List<&2,R.Transaction>,Nat,rows=>R.Transaction.open(B.get(R.Transaction,rows,tx,B.blank_transaction())),R.World.txArena(next),R.World.txArena(w),Frame.arena(w)),open)
  Equal.trans(C.Machine,C.step(scanning(w,rest,stack,offset)),C.step(C.Machine{next,C.LandTransactions{frame,1n} <> rest,stack}),skipped(w,rest,stack,offset),one,Equal.trans(C.Machine,C.step(C.Machine{next,C.LandTransactions{frame,1n} <> rest,stack}),C.landTransactions(next,rest,stack,frame,1n),skipped(w,rest,stack,offset),Step.healthyStep(next,C.LandTransactions{frame,1n},rest,stack,postHealth),Scan.positive(next,rest,stack,frame,0n,tx,remaining,lookup,postHealth,count)))

def complete(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+remaining: Nat,+ready: Ready<w,offset>,live: {R.World.transactions(w) == [1n+offset] : List<&2,Nat>},open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}) -> {Steps.iterate(2n,start(w,rest,stack,offset)) == skipped(w,rest,stack,offset) : C.Machine}:
  Driver.appendStep(1n,start(w,rest,stack,offset),scanning(w,rest,stack,offset),skipped(w,rest,stack,offset),begins(w,rest,stack,offset,ready),skips(w,rest,stack,offset,remaining,health(w,offset,ready),live,open))

def committed(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+remaining: Nat,+ready: Ready<w,offset>,+live: {R.World.transactions(w) == [1n+offset] : List<&2,Nat>},+open: {R.Transaction.open(B.transaction(w,1n+offset)) == 1n+remaining : Nat}) -> {Committed.observe(C.world(Steps.iterate(2n,start(w,rest,stack,offset)))) == Committed.observe(w) : Committed.View}:
  Equal.trans(Committed.View,Committed.observe(C.world(Steps.iterate(2n,start(w,rest,stack,offset)))),Committed.observe(Frame.world(w)),Committed.observe(w),Equal.cong(C.Machine,Committed.View,m=>Committed.observe(C.world(m)),Steps.iterate(2n,start(w,rest,stack,offset)),skipped(w,rest,stack,offset),complete(w,rest,stack,offset,remaining,ready,live,open)),Frame.committed(w))
