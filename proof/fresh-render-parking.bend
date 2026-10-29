# The source render arm parks even with no pending value. A fresh extension
# is allocated by actual holdNode; it is not an initial certificate premise.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/scheduler.bend as S
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K
import ../runtime/owner.bend as O
import ../proof/park-transaction-frame.bend as Parking
import ../proof/natural-logic.bend as Logic
import ./fresh-node-holding.bend as Fresh
import ./holding-seam-view.bend as Holding

type Ready<-w: R.World,-id: Nat> is Data:
  FreshRender{valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},fresh: {R.Node.x(B.node(w,id)) == 0n : Nat},child: {R.Node.firstChild(B.node(w,id)) == 0n : Nat},eligible: {S.parkEligible(w,id) == True{} : Bool},rendered: {X.isRender(R.Node.kind(B.node(w,id))) == True{} : Bool},absent: {B.present(R.Node.pending(B.node(w,id))) == False{} : Bool}}

def loading(+w: R.World,+id: Nat,rendered: {X.isRender(R.Node.kind(B.node(w,id))) == True{} : Bool}) -> {S.parkLoading(w,id) == False{} : Bool}:
  +unready = B.has(R.Node.status(B.node(w,id)),K.STATUS_UNINITIALIZED())
  +absent = Bool.not(B.present(R.Node.pending(B.node(w,id))))
  +inner = Equal.trans(Bool,Bool.and(unready,Bool.not(X.isRender(R.Node.kind(B.node(w,id))))),Bool.and(unready,False{}),False{},Equal.cong(Bool,Bool,render=>Bool.and(unready,Bool.not(render)),X.isRender(R.Node.kind(B.node(w,id))),True{},rendered),Logic.andFalse(unready))
  Equal.trans(Bool,S.parkLoading(w,id),Bool.and(absent,False{}),False{},Equal.cong(Bool,Bool,flag=>Bool.and(absent,flag),Bool.and(unready,Bool.not(X.isRender(R.Node.kind(B.node(w,id))))),False{},inner),Logic.andFalse(absent))

def noComparison(+w: R.World,+id: Nat,absent: {B.present(R.Node.pending(B.node(w,id))) == False{} : Bool}) -> {S.parkCanCompare(w,id) == False{} : Bool}:
  Equal.cong(Bool,Bool,present=>Bool.and(present,Bool.and(Bool.not(B.has(R.Node.status(B.node(w,id)),B.set(K.STATUS_PENDING(),K.STATUS_UNINITIALIZED()))),Bool.not(O.parked(w,id)))),B.present(R.Node.pending(B.node(w,id))),False{},absent)

def selected(+w: R.World,+id: Nat,+tx: Nat,rendered: {X.isRender(R.Node.kind(B.node(w,id))) == True{} : Bool},absent: {B.present(R.Node.pending(B.node(w,id))) == False{} : Bool}) -> {Parking.select(w,id,tx,True{}) == S.parkChanged(w,id,tx,True{}) : R.World}:
  +skip = Equal.cong(Bool,R.World,flag=>B.choose(~R.World,flag,_=>w,_=>B.choose(~R.World,S.parkCanCompare(w,id),_=>Parking.compare(w,id,tx,True{}),_=>S.parkChanged(w,id,tx,True{}))),S.parkLoading(w,id),False{},loading(w,id,rendered))
  +compare = Equal.cong(Bool,R.World,flag=>B.choose(~R.World,flag,_=>Parking.compare(w,id,tx,True{}),_=>S.parkChanged(w,id,tx,True{})),S.parkCanCompare(w,id),False{},noComparison(w,id,absent))
  Equal.trans(R.World,Parking.select(w,id,tx,True{}),B.choose(~R.World,S.parkCanCompare(w,id),_=>Parking.compare(w,id,tx,True{}),_=>S.parkChanged(w,id,tx,True{})),S.parkChanged(w,id,tx,True{}),skip,compare)

def actual(+w: R.World,+id: Nat,+offset: Nat,ready: Ready<w,id>) -> {S.parkPendingNode(w,id,1n+offset) == X.holdNode(w,id,1n+offset) : R.World}:
  match ready:
    case FreshRender{+valid,+fresh,+child,eligible,rendered,absent}:
      +tx = {1n+offset : Nat}
      +first = Equal.cong(Bool,R.World,flag=>Parking.select(w,id,tx,flag),S.parkEligible(w,id),True{},eligible)
      Equal.trans(R.World,S.parkPendingNode(w,id,tx),Parking.select(w,id,tx,True{}),X.holdNode(w,id,tx),first,Equal.trans(R.World,Parking.select(w,id,tx,True{}),S.parkChanged(w,id,tx,True{}),X.holdNode(w,id,tx),selected(w,id,tx,rendered,absent),Fresh.changed(w,id,offset,valid,fresh,child)))

def health(+w: R.World,+id: Nat,+offset: Nat,ready: Ready<w,id>) -> {B.ok(S.parkPendingNode(w,id,1n+offset)) == B.ok(w) : Bool}:
  Equal.trans(Bool,B.ok(S.parkPendingNode(w,id,1n+offset)),B.ok(X.holdNode(w,id,1n+offset)),B.ok(w),Equal.cong(R.World,Bool,state=>B.ok(state),S.parkPendingNode(w,id,1n+offset),X.holdNode(w,id,1n+offset),actual(w,id,offset,ready)),Holding.nodeHealth(w,id,1n+offset))
