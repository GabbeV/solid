# Two actual notifier steps fit its existing size-derived public budget.
# This is arithmetic about that budget, not a replacement execution limit.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./natural-logic.bend as Logic
import ./list-update-lookup.bend as Contradiction


def addSuccessor(+a: Nat,+b: Nat) -> {Nat.add(a,1n+b) == 1n+Nat.add(a,b) : Nat}:
  match a:
    case 0n: {==}
    case 1n+p: Equal.cong(Nat,Nat,n=>1n+n,Nat.add(p,1n+b),1n+Nat.add(p,b),addSuccessor(p,b))

def fourExtra(+k: Nat) -> Nat:
  Nat.add(k,Nat.add(k,Nat.mul(2n,1n+k)))

def fourRoom(+k: Nat) -> {Nat.mul(4n,1n+k) == 2n+fourExtra(k) : Nat}:
  Equal.cong(Nat,Nat,n=>1n+n,Nat.add(k,1n+Nat.add(k,Nat.mul(2n,1n+k))),1n+fourExtra(k),addSuccessor(k,Nat.add(k,Nat.mul(2n,1n+k))))

def remaining(+nodes: List<&2,R.Node>,+links: List<&2,R.Link>) -> Nat:
  match nodes:
    case Nil{}: 0n
    case first <> tail:
      +sum = Nat.add(B.length(R.Node,tail),B.length(R.Link,links))
      fourExtra(Nat.add(sum,Nat.mul(3n,1n+sum)))

def fits(+nodes: List<&2,R.Node>,+links: List<&2,R.Link>,+node: Nat,valid: {Nat.is_lt(node,B.length(R.Node,nodes)) == True{} : Bool}) -> {Nat.mul(4n,Nat.mul(4n,Nat.add(B.length(R.Node,nodes),B.length(R.Link,links)))) == 2n+remaining(nodes,links) : Nat}:
  match nodes:
    case Nil{}:
      match node:
        case 0n: Empty.absurd({Nat.mul(4n,Nat.mul(4n,B.length(R.Link,links))) == 2n : Nat},Contradiction.impossible(Equal.sym(Bool,False{},True{},valid)))
        case 1n+p: Empty.absurd({Nat.mul(4n,Nat.mul(4n,B.length(R.Link,links))) == 2n : Nat},Contradiction.impossible(Equal.sym(Bool,False{},True{},valid)))
    case first <> tail:
      +sum = Nat.add(B.length(R.Node,tail),B.length(R.Link,links))
      fourRoom(Nat.add(sum,Nat.mul(3n,1n+sum)))

def room(+w: R.World,+node: Nat,valid: {B.valid(w,node) == True{} : Bool}) -> {Nat.mul(4n,B.budget(w)) == 2n+remaining(R.World.nodes(w),R.World.links(w)) : Nat}:
  fits(R.World.nodes(w),R.World.links(w),node,Logic.andRight(Nat.is_ne(node,0n),Nat.is_lt(node,B.length(R.Node,R.World.nodes(w))),valid))
