# A captured pending intake whose members are already held (or overridden)
# and have no staged child frame. The certificate names actual node flags;
# it does not assume a park result. The source loop still walks every member.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/scheduler.bend as S
import ../runtime/constants.bend as K
import ../runtime/transaction.bend as X
import ../runtime/equality.bend as EQ

type Intake<-w: R.World,-count: Nat> is Data:
  End{}
  Next{index: Nat,inside: {Nat.is_ge(index,count) == False{} : Bool},held: {B.has(R.Node.config(B.node(w,B.get(Nat,R.World.pendingNodes(w),index,0n))),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())) == True{} : Bool},unstaged: {B.has(R.Node.config(B.node(w,B.get(Nat,R.World.pendingNodes(w),index,0n))),K.CONFIG_STAGED()) == False{} : Bool},tail: Intake<w,count>,follows: {cursor(w,count,tail) == 1n+index : Nat}}

def cursor(-w: R.World,count: Nat,intake: Intake<w,count>) -> Nat:
  match intake:
    case End{}: count
    case Next{index,inside,held,unstaged,tail,follows}: index

def height(-w: R.World,-count: Nat,intake: Intake<w,count>) -> Nat:
  match intake:
    case End{}: 0n
    case Next{index,inside,held,unstaged,tail,follows}: 1n+height(w,count,tail)

def ineligible(+w: R.World,+id: Nat,held: {B.has(R.Node.config(B.node(w,id)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())) == True{} : Bool}) -> {S.parkEligible(w,id) == False{} : Bool}:
  Equal.cong(Bool,Bool,flag=>Bool.and(Bool.not(flag),Bool.not(R.Transaction.lane(B.transaction(w,R.NodeExtension.transaction(B.extension(w,id)))))),B.has(R.Node.config(B.node(w,id)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())),True{},held)

def changed(+w: R.World,+id: Nat,+tx: Nat,unstaged: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_STAGED()) == False{} : Bool}) -> {S.parkChanged(w,id,tx,False{}) == w : R.World}:
  Equal.cong(Bool,R.World,flag=>B.choose(~R.World,flag,_=>X.holdFrame(w,id,tx),_=>w),B.has(R.Node.config(B.node(w,id)),K.CONFIG_STAGED()),False{},unstaged)

def node(+w: R.World,+id: Nat,+tx: Nat,held: {B.has(R.Node.config(B.node(w,id)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())) == True{} : Bool},unstaged: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_STAGED()) == False{} : Bool}) -> {S.parkPendingNode(w,id,tx) == w : R.World}:
  +eligible = S.parkEligible(w,id)
  +empty = Equal.cong(Bool,R.World,flag=>B.choose(~R.World,Bool.and(flag,S.parkLoading(w,id)),_=>w,_=>B.choose(~R.World,Bool.and(flag,S.parkCanCompare(w,id)),_=>B.choose(~R.World,Nat.is_ne(EQ.custom(w,id),0n),_=>R.World.with_fault(w,R.Unsupported{23n}),_=>B.choose(~R.World,EQ.isSame(w,id,R.Node.value(B.node(w,id)),B.current(B.node(w,id))),_=>S.parkEqual(w,id),_=>S.parkChanged(w,id,tx,flag))),_=>S.parkChanged(w,id,tx,flag))),eligible,False{},ineligible(w,id,held))
  Equal.trans(R.World,S.parkPendingNode(w,id,tx),S.parkChanged(w,id,tx,False{}),w,empty,changed(w,id,tx,unstaged))
