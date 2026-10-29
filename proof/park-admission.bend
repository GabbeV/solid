# Finite initial-state admission rules, with later Worlds computed by the real
# operation. No endpoint World/count/health is stored in the certificate.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/scheduler.bend as S
import ../runtime/constants.bend as K
import ../proof/held-park-intake.bend as Quiet
import ./parkable-leaf.bend as Leaf
import ../proof/natural-addition.bend as NatProof

type Entry<-w: R.World,-id: Nat,-offset: Nat> is Data:
  AlreadyHeld{held: {B.has(R.Node.config(B.node(w,id)),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())) == True{} : Bool},unstaged: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_STAGED()) == False{} : Bool}}
  Childless{ready: Leaf.Ready<w,id,offset>}

def health(+w: R.World,+id: Nat,+offset: Nat,entry: Entry<w,id,offset>) -> {B.ok(S.parkPendingNode(w,id,1n+offset)) == B.ok(w) : Bool}:
  match entry:
    case AlreadyHeld{held,unstaged}:
      Equal.cong(R.World,Bool,state=>B.ok(state),S.parkPendingNode(w,id,1n+offset),w,Quiet.node(w,id,1n+offset,held,unstaged))
    case Childless{ready}: Leaf.health(w,id,offset,ready)

def next(+w: R.World,+offset: Nat,+index: Nat) -> R.World:
  S.parkPendingNode(w,B.get(Nat,R.World.pendingNodes(w),index,0n),1n+offset)

def Admitted(amount: Nat,+w: R.World,+offset: Nat,+index: Nat,+count: Nat) -> Data:
  match amount:
    case 0n: {index == count : Nat}
    case 1n+p:
      B.Bundle<{Nat.is_ge(index,count) == False{} : Bool},B.Bundle<Entry<w,B.get(Nat,R.World.pendingNodes(w),index,0n),offset>,Admitted(p,next(w,offset,index),offset,1n+index,count)>>

def walk(amount: Nat,+w: R.World,+offset: Nat,+index: Nat) -> R.World:
  match amount:
    case 0n: w
    case 1n+p: walk(p,next(w,offset,index),offset,1n+index)

def walkHealth(+amount: Nat,+w: R.World,+offset: Nat,+index: Nat,+count: Nat,admitted: Admitted(amount,w,offset,index,count)) -> {B.ok(walk(amount,w,offset,index)) == B.ok(w) : Bool}:
  match amount:
    case 0n: {==}
    case 1n+p:
      +body = B.second({Nat.is_ge(index,count) == False{} : Bool},B.Bundle<Entry<w,B.get(Nat,R.World.pendingNodes(w),index,0n),offset>,Admitted(p,next(w,offset,index),offset,1n+index,count)>,admitted)
      +head = B.first(Entry<w,B.get(Nat,R.World.pendingNodes(w),index,0n),offset>,Admitted(p,next(w,offset,index),offset,1n+index,count),body)
      +tail = B.second(Entry<w,B.get(Nat,R.World.pendingNodes(w),index,0n),offset>,Admitted(p,next(w,offset,index),offset,1n+index,count),body)
      Equal.trans(Bool,B.ok(walk(1n+p,w,offset,index)),B.ok(next(w,offset,index)),B.ok(w),walkHealth(p,next(w,offset,index),offset,1n+index,count,tail),health(w,B.get(Nat,R.World.pendingNodes(w),index,0n),offset,head))

def distance(+amount: Nat,+w: R.World,+offset: Nat,+index: Nat,+count: Nat,admitted: Admitted(amount,w,offset,index,count)) -> {Nat.add(index,amount) == count : Nat}:
  match amount:
    case 0n: Equal.trans(Nat,Nat.add(index,0n),index,count,NatProof.zero(index),admitted)
    case 1n+p:
      +body = B.second({Nat.is_ge(index,count) == False{} : Bool},B.Bundle<Entry<w,B.get(Nat,R.World.pendingNodes(w),index,0n),offset>,Admitted(p,next(w,offset,index),offset,1n+index,count)>,admitted)
      +tail = B.second(Entry<w,B.get(Nat,R.World.pendingNodes(w),index,0n),offset>,Admitted(p,next(w,offset,index),offset,1n+index,count),body)
      Equal.trans(Nat,Nat.add(index,1n+p),Nat.add(1n+index,p),count,NatProof.successor(index,p),distance(p,next(w,offset,index),offset,1n+index,count,tail))
