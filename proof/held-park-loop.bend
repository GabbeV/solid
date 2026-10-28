# Structural completion of the real captured park loop for quiet held entries.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/scheduler.bend as S
import ../runtime/constants.bend as K
import ./held-park-intake.bend as I
import ./natural-addition.bend as NatProof

def advance(+w: R.World,+tx: Nat,+index: Nat,+count: Nat,+fuel: Nat,inside: {Nat.is_ge(index,count) == False{} : Bool},held: {B.has(R.Node.config(B.node(w,B.get(Nat,R.World.pendingNodes(w),index,0n))),B.set(K.CONFIG_HELD(),K.CONFIG_OVERRIDE())) == True{} : Bool},unstaged: {B.has(R.Node.config(B.node(w,B.get(Nat,R.World.pendingNodes(w),index,0n))),K.CONFIG_STAGED()) == False{} : Bool},healthy: {B.ok(w) == True{} : Bool}) -> {S.park_list(1n+fuel,w,tx,index,count) == S.park_list(fuel,w,tx,1n+index,count) : R.World}:
  +id = B.get(Nat,R.World.pendingNodes(w),index,0n)
  +afterNode = S.parkPendingNode(w,id,tx)
  +walk = Equal.cong(Bool,R.World,flag=>B.choose(~R.World,flag,_=>w,_=>
    +next = S.parkPendingNode(w,id,tx)
    B.choose(~R.World,B.ok(next),_=>S.park_list(fuel,next,tx,1n+index,count),_=>next)),Nat.is_ge(index,count),False{},inside)
  +same = Equal.cong(R.World,R.World,next=>B.choose(~R.World,B.ok(next),_=>S.park_list(fuel,next,tx,1n+index,count),_=>next),afterNode,w,I.node(w,id,tx,held,unstaged))
  +ok = Equal.cong(Bool,R.World,flag=>B.choose(~R.World,flag,_=>S.park_list(fuel,w,tx,1n+index,count),_=>w),B.ok(w),True{},healthy)
  Equal.trans(R.World,S.park_list(1n+fuel,w,tx,index,count),B.choose(~R.World,B.ok(afterNode),_=>S.park_list(fuel,afterNode,tx,1n+index,count),_=>afterNode),S.park_list(fuel,w,tx,1n+index,count),walk,Equal.trans(R.World,B.choose(~R.World,B.ok(afterNode),_=>S.park_list(fuel,afterNode,tx,1n+index,count),_=>afterNode),B.choose(~R.World,B.ok(w),_=>S.park_list(fuel,w,tx,1n+index,count),_=>w),S.park_list(fuel,w,tx,1n+index,count),same,ok))

def loop(+w: R.World,+count: Nat,+intake: I.Intake<w,count>,+tx: Nat,+extra: Nat,+healthy: {B.ok(w) == True{} : Bool}) -> {S.park_list(1n+Nat.add(I.height(w,count,intake),extra),w,tx,I.cursor(w,count,intake),count) == w : R.World}:
  match intake:
    case I.End{}:
      Equal.cong(Bool,R.World,flag=>B.choose(~R.World,flag,_=>w,_=>
        +next = S.parkPendingNode(w,B.get(Nat,R.World.pendingNodes(w),count,0n),tx)
        B.choose(~R.World,B.ok(next),_=>S.park_list(extra,next,tx,1n+count,count),_=>next)),Nat.is_ge(count,count),True{},NatProof.geSelf(count))
    case I.Next{+index,inside,held,unstaged,+tail,follows}:
      +fuel = {1n+Nat.add(I.height(w,count,tail),extra) : Nat}
      +nextIndex = Equal.cong(Nat,R.World,at=>S.park_list(fuel,w,tx,at,count),1n+index,I.cursor(w,count,tail),Equal.sym(Nat,I.cursor(w,count,tail),1n+index,follows))
      Equal.trans(R.World,S.park_list(1n+fuel,w,tx,index,count),S.park_list(fuel,w,tx,1n+index,count),w,advance(w,tx,index,count,fuel,inside,held,unstaged,healthy),Equal.trans(R.World,S.park_list(fuel,w,tx,1n+index,count),S.park_list(fuel,w,tx,I.cursor(w,count,tail),count),w,nextIndex,loop(w,count,tail,tx,extra,healthy)))

def distance(+w: R.World,+count: Nat,+intake: I.Intake<w,count>) -> {Nat.add(I.cursor(w,count,intake),I.height(w,count,intake)) == count : Nat}:
  match intake:
    case I.End{}: NatProof.zero(count)
    case I.Next{+index,inside,held,unstaged,+tail,follows}:
      +height = I.height(w,count,tail)
      Equal.trans(Nat,Nat.add(index,1n+height),Nat.add(1n+index,height),count,NatProof.successor(index,height),Equal.trans(Nat,Nat.add(1n+index,height),Nat.add(I.cursor(w,count,tail),height),count,Equal.cong(Nat,Nat,at=>Nat.add(at,height),1n+index,I.cursor(w,count,tail),Equal.sym(Nat,I.cursor(w,count,tail),1n+index,follows)),distance(w,count,tail)))

def fullHeight(+w: R.World,+count: Nat,+intake: I.Intake<w,count>,first: {I.cursor(w,count,intake) == 0n : Nat}) -> {I.height(w,count,intake) == count : Nat}:
  Equal.trans(Nat,I.height(w,count,intake),Nat.add(I.cursor(w,count,intake),I.height(w,count,intake)),count,Equal.cong(Nat,Nat,at=>Nat.add(at,I.height(w,count,intake)),0n,I.cursor(w,count,intake),Equal.sym(Nat,I.cursor(w,count,intake),0n,first)),distance(w,count,intake))

def captured(+w: R.World,+tx: Nat,+intake: I.Intake<w,B.length(Nat,R.World.pendingNodes(w))>,+first: {I.cursor(w,B.length(Nat,R.World.pendingNodes(w)),intake) == 0n : Nat},+healthy: {B.ok(w) == True{} : Bool}) -> {S.parkPendingNodes(w,tx) == R.World.with_pendingNodes(w,[]) : R.World}:
  +count = B.length(Nat,R.World.pendingNodes(w))
  +height = I.height(w,count,intake)
  +budget = B.budget(w)
  +fuel = Equal.trans(Nat,Nat.add(budget,count),Nat.add(count,budget),Nat.add(height,budget),NatProof.commute(budget,count),Equal.cong(Nat,Nat,n=>Nat.add(n,budget),count,height,Equal.sym(Nat,height,count,fullHeight(w,count,intake,first))))
  +bound = Equal.cong(Nat,R.World,n=>S.park_list(1n+n,w,tx,0n,count),Nat.add(budget,count),Nat.add(height,budget),fuel)
  +cursor = Equal.cong(Nat,R.World,at=>S.park_list(1n+Nat.add(height,budget),w,tx,at,count),0n,I.cursor(w,count,intake),Equal.sym(Nat,I.cursor(w,count,intake),0n,first))
  +same = Equal.trans(R.World,S.park_list(1n+Nat.add(budget,count),w,tx,0n,count),S.park_list(1n+Nat.add(height,budget),w,tx,0n,count),w,bound,Equal.trans(R.World,S.park_list(1n+Nat.add(height,budget),w,tx,0n,count),S.park_list(1n+Nat.add(height,budget),w,tx,I.cursor(w,count,intake),count),w,cursor,loop(w,count,intake,tx,budget,healthy)))
  Equal.trans(R.World,S.parkPendingNodes(w,tx),B.choose(~R.World,B.ok(w),_=>R.World.with_pendingNodes(w,[]),_=>w),R.World.with_pendingNodes(w,[]),Equal.cong(R.World,R.World,next=>B.choose(~R.World,B.ok(next),_=>R.World.with_pendingNodes(next,[]),_=>next),S.park_list(1n+Nat.add(budget,count),w,tx,0n,count),w,same),Equal.cong(Bool,R.World,flag=>B.choose(~R.World,flag,_=>R.World.with_pendingNodes(w,[]),_=>w),B.ok(w),True{},healthy))
