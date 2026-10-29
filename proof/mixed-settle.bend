# Actual settlement after a mixed source/reader intake. Initial facts construct
# the admission; all post-park health, hooks and scanner work are derived.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/transaction.bend as X
import ../runtime/scheduler.bend as S
import ../runtime/constants.bend as K
import ./parkable-leaf.bend as Leaf
import ../proof/held-settle-intake.bend as Intake
import ../proof/held-settle-frame.bend as Frame
import ../proof/settle-lane-empty.bend as Lane
import ./park-mixed-construction.bend as Mixed
import ./holding-seam-view.bend as Holding

type Ready<-w: R.World,-source: Nat,-reader: Nat,-offset: Nat> is Data:
  SourceReader{pending: {R.World.pendingNodes(w) == [source,reader] : List<&2,Nat>},held: {B.has(R.Node.config(B.node(w,source)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())) == True{} : Bool},unstaged: {B.has(R.Node.config(B.node(w,source)),K.CONFIG_STAGED()) == False{} : Bool},leaf: Leaf.Ready<w,reader,offset>,healthy: {B.ok(w) == True{} : Bool},comparators: {List.is_empty(&2,R.ComparatorBinding,R.World.comparators(w)) == True{} : Bool},lane: {R.Transaction.lane(B.transaction(w,1n+offset)) == False{} : Bool},terminal: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat},zombies: {R.World.deferredZombies(w) == [] : List<&2,Nat>},quiet: {Lane.quiet(w) == True{} : Bool}}

def held(w: R.World,reader: Nat,offset: Nat) -> R.World:
  X.holdNode(w,reader,1n+offset)

def parked(w: R.World,reader: Nat,offset: Nat) -> R.World:
  R.World.with_pendingNodes(held(w,reader,offset),[])

def target(w: R.World,reader: Nat,+offset: Nat,rest: List<&2,C.Task>,stack: List<&2,R.Value>) -> C.Machine:
  Intake.target(held(w,reader,offset),rest,stack,1n+offset)

def parking(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,pending: {R.World.pendingNodes(w) == [source,reader] : List<&2,Nat>},sourceHeld: {B.has(R.Node.config(B.node(w,source)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())) == True{} : Bool},unstaged: {B.has(R.Node.config(B.node(w,source)),K.CONFIG_STAGED()) == False{} : Bool},leaf: Leaf.Ready<w,reader,offset>,+healthy: {B.ok(w) == True{} : Bool},comparators: {List.is_empty(&2,R.ComparatorBinding,R.World.comparators(w)) == True{} : Bool}) -> {Intake.selected(B.Bundle{w,1n+offset},rest,stack) == C.afterParkIntake(parked(w,reader,offset),rest,stack,1n+offset) : C.Machine}:
  +tx = {1n+offset : Nat}
  +next = parked(w,reader,offset)
  +walk = Equal.cong(R.World,C.Machine,state=>Intake.afterWalk(state,rest,stack,tx),S.parkPendingNodes(w,tx),next,Mixed.complete(w,source,reader,offset,pending,sourceHeld,unstaged,leaf,healthy))
  +ready = Equal.trans(Bool,B.ok(next),B.ok(held(w,reader,offset)),True{},Intake.pendingHealth(held(w,reader,offset)),Equal.trans(Bool,B.ok(held(w,reader,offset)),B.ok(w),True{},Holding.nodeHealth(w,reader,tx),healthy))
  Equal.trans(C.Machine,Intake.selected(B.Bundle{w,tx},rest,stack),Intake.afterWalk(S.parkPendingNodes(w,tx),rest,stack,tx),C.afterParkIntake(next,rest,stack,tx),Intake.noComparators(w,rest,stack,offset,comparators),Equal.trans(C.Machine,Intake.afterWalk(S.parkPendingNodes(w,tx),rest,stack,tx),Intake.afterWalk(next,rest,stack,tx),C.afterParkIntake(next,rest,stack,tx),walk,Intake.walkHealthy(next,rest,stack,tx,ready)))

def finish(+w: R.World,+reader: Nat,+offset: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,zombies: {R.World.deferredZombies(w) == [] : List<&2,Nat>},quiet: {Lane.quiet(w) == True{} : Bool}) -> {C.afterParkIntake(parked(w,reader,offset),rest,stack,1n+offset) == target(w,reader,offset,rest,stack) : C.Machine}:
  +tx = {1n+offset : Nat}
  +node = held(w,reader,offset)
  +next = parked(w,reader,offset)
  +empty = Equal.trans(List<&2,Nat>,R.World.deferredZombies(next),R.World.deferredZombies(node),[],Intake.pendingZombies(node),Equal.trans(List<&2,Nat>,R.World.deferredZombies(node),R.World.deferredZombies(w),[],Holding.nodeZombies(w,reader,tx),zombies))
  +ready = Equal.trans(Bool,Lane.quiet(Intake.trimmed(node)),Lane.quiet(node),True{},Intake.trimmedQuiet(node),Equal.trans(Bool,Lane.quiet(node),Lane.quiet(w),True{},Holding.nodeQuiet(w,reader,tx),quiet))
  Equal.trans(C.Machine,C.afterParkIntake(next,rest,stack,tx),C.finishSettleIntake(Intake.trimmed(node),rest,stack,tx),target(w,reader,offset,rest,stack),Intake.afterPark(next,rest,stack,tx,empty),Lane.finish(Intake.trimmed(node),rest,stack,tx,ready))

def complete(+w: R.World,+source: Nat,+reader: Nat,+offset: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,ready: Ready<w,source,reader,offset>) -> {C.settleApplied(w,rest,stack,1n+offset) == target(w,reader,offset,rest,stack) : C.Machine}:
  match ready:
    case SourceReader{pending,held,unstaged,leaf,healthy,comparators,lane,terminal,zombies,quiet}:
      +tx = {1n+offset : Nat}
      +first = Intake.resolved(w,rest,stack,offset,lane,terminal)
      +park = parking(w,source,reader,offset,rest,stack,pending,held,unstaged,leaf,healthy,comparators)
      Equal.trans(C.Machine,C.settleApplied(w,rest,stack,tx),Intake.selected(B.Bundle{w,tx},rest,stack),target(w,reader,offset,rest,stack),first,Equal.trans(C.Machine,Intake.selected(B.Bundle{w,tx},rest,stack),C.afterParkIntake(parked(w,reader,offset),rest,stack,tx),target(w,reader,offset,rest,stack),park,finish(w,reader,offset,rest,stack,zombies,quiet)))
