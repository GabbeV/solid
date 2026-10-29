# Source-budget completion of an admitted finite mixed pending intake.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/scheduler.bend as S
import ../proof/natural-addition.bend as NatProof
import ./park-admission.bend as A

def stopped(+w: R.World,+tx: Nat,+count: Nat,+extra: Nat) -> {S.park_list(1n+extra,w,tx,count,count) == w : R.World}:
  Equal.cong(Bool,R.World,done=>B.choose(~R.World,done,_=>w,_=>
    +next = S.parkPendingNode(w,B.get(Nat,R.World.pendingNodes(w),count,0n),tx)
    B.choose(~R.World,B.ok(next),_=>S.park_list(extra,next,tx,1n+count,count),_=>next)),Nat.is_ge(count,count),True{},NatProof.geSelf(count))

def stop(+w: R.World,+tx: Nat,+index: Nat,+count: Nat,+extra: Nat,done: {index == count : Nat}) -> {S.park_list(1n+extra,w,tx,index,count) == w : R.World}:
  Equal.trans(R.World,S.park_list(1n+extra,w,tx,index,count),S.park_list(1n+extra,w,tx,count,count),w,Equal.cong(Nat,R.World,at=>S.park_list(1n+extra,w,tx,at,count),index,count,done),stopped(w,tx,count,extra))

def advance(+w: R.World,+offset: Nat,+index: Nat,+count: Nat,+fuel: Nat,inside: {Nat.is_ge(index,count) == False{} : Bool},healthy: {B.ok(A.next(w,offset,index)) == True{} : Bool}) -> {S.park_list(1n+fuel,w,1n+offset,index,count) == S.park_list(fuel,A.next(w,offset,index),1n+offset,1n+index,count) : R.World}:
  +next = A.next(w,offset,index)
  +selected = Equal.cong(Bool,R.World,done=>B.choose(~R.World,done,_=>w,_=>B.choose(~R.World,B.ok(next),_=>S.park_list(fuel,next,1n+offset,1n+index,count),_=>next)),Nat.is_ge(index,count),False{},inside)
  Equal.trans(R.World,S.park_list(1n+fuel,w,1n+offset,index,count),B.choose(~R.World,B.ok(next),_=>S.park_list(fuel,next,1n+offset,1n+index,count),_=>next),S.park_list(fuel,next,1n+offset,1n+index,count),selected,Equal.cong(Bool,R.World,ready=>B.choose(~R.World,ready,_=>S.park_list(fuel,next,1n+offset,1n+index,count),_=>next),B.ok(next),True{},healthy))

def loop(+amount: Nat,+w: R.World,+offset: Nat,+index: Nat,+count: Nat,+admitted: A.Admitted(amount,w,offset,index,count),+extra: Nat,+healthy: {B.ok(w) == True{} : Bool}) -> {S.park_list(1n+Nat.add(amount,extra),w,1n+offset,index,count) == A.walk(amount,w,offset,index) : R.World}:
  match amount:
    case 0n: stop(w,1n+offset,index,count,extra,admitted)
    case 1n+p:
      +inside = B.first({Nat.is_ge(index,count) == False{} : Bool},B.Bundle<A.Entry<w,B.get(Nat,R.World.pendingNodes(w),index,0n),offset>,A.Admitted(p,A.next(w,offset,index),offset,1n+index,count)>,admitted)
      +body = B.second({Nat.is_ge(index,count) == False{} : Bool},B.Bundle<A.Entry<w,B.get(Nat,R.World.pendingNodes(w),index,0n),offset>,A.Admitted(p,A.next(w,offset,index),offset,1n+index,count)>,admitted)
      +head = B.first(A.Entry<w,B.get(Nat,R.World.pendingNodes(w),index,0n),offset>,A.Admitted(p,A.next(w,offset,index),offset,1n+index,count),body)
      +tail = B.second(A.Entry<w,B.get(Nat,R.World.pendingNodes(w),index,0n),offset>,A.Admitted(p,A.next(w,offset,index),offset,1n+index,count),body)
      +next = A.next(w,offset,index)
      +ready = Equal.trans(Bool,B.ok(next),B.ok(w),True{},A.health(w,B.get(Nat,R.World.pendingNodes(w),index,0n),offset,head),healthy)
      +fuel = {1n+Nat.add(p,extra) : Nat}
      Equal.trans(R.World,S.park_list(1n+fuel,w,1n+offset,index,count),S.park_list(fuel,next,1n+offset,1n+index,count),A.walk(1n+p,w,offset,index),advance(w,offset,index,count,fuel,inside,ready),loop(p,next,offset,1n+index,count,tail,extra,ready))

def captured(+amount: Nat,+w: R.World,+offset: Nat,+admitted: A.Admitted(amount,w,offset,0n,B.length(Nat,R.World.pendingNodes(w))),+healthy: {B.ok(w) == True{} : Bool}) -> {S.parkPendingNodes(w,1n+offset) == R.World.with_pendingNodes(A.walk(amount,w,offset,0n),[]) : R.World}:
  +count = B.length(Nat,R.World.pendingNodes(w))
  +budget = B.budget(w)
  +sameCount = A.distance(amount,w,offset,0n,count,admitted)
  +fuel = Equal.trans(Nat,Nat.add(budget,count),Nat.add(count,budget),Nat.add(amount,budget),NatProof.commute(budget,count),Equal.cong(Nat,Nat,n=>Nat.add(n,budget),count,amount,Equal.sym(Nat,amount,count,sameCount)))
  +bound = Equal.cong(Nat,R.World,n=>S.park_list(1n+n,w,1n+offset,0n,count),Nat.add(budget,count),Nat.add(amount,budget),fuel)
  +exact = Equal.trans(R.World,S.park_list(1n+Nat.add(budget,count),w,1n+offset,0n,count),S.park_list(1n+Nat.add(amount,budget),w,1n+offset,0n,count),A.walk(amount,w,offset,0n),bound,loop(amount,w,offset,0n,count,admitted,budget,healthy))
  +next = A.walk(amount,w,offset,0n)
  +ready = Equal.trans(Bool,B.ok(next),B.ok(w),True{},A.walkHealth(amount,w,offset,0n,count,admitted),healthy)
  Equal.trans(R.World,S.parkPendingNodes(w,1n+offset),B.choose(~R.World,B.ok(next),_=>R.World.with_pendingNodes(next,[]),_=>next),R.World.with_pendingNodes(next,[]),Equal.cong(R.World,R.World,state=>B.choose(~R.World,B.ok(state),_=>R.World.with_pendingNodes(state,[]),_=>state),S.park_list(1n+Nat.add(budget,count),w,1n+offset,0n,count),next,exact),Equal.cong(Bool,R.World,flag=>B.choose(~R.World,flag,_=>R.World.with_pendingNodes(next,[]),_=>next),B.ok(next),True{},ready))
