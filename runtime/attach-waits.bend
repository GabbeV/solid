# core/verdict.ts:bornHeldOpen/valueInserts/attachWaits. Hidden boundary hooks
# remain outside this production non-store profile. R.Reference decodes to an
# opaque {ref:id} atom, with no nodeType; actual DOM-node payloads are unported.
# Arrays retain the source recursive .some traversal, including sparse slots.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./arrays.bend as Arrays
import ./constants.bend as K
import ./transaction.bend as Tx
import ./write.bend as W

# This worklist is the recursive Array.some call stack. One slot is examined
# per step; a sparse hole is skipped. Exhaustion refuses the execution, never
# certifies false. The admitted shared/cyclic-array profile remains resource
# bounded, like the other pointer/array helpers.
def valueWork(fuel: Nat,+w: R.World,work: List<&2,R.Slot>) -> B.Bundle<R.World,Bool>:
  match fuel work:
    case _ Nil{}: B.Bundle{w,False{}}
    case 0n _: B.Bundle{R.World.with_fault(w,R.Exhausted{}),False{}}
    case 1n+ +p R.Empty{} <> tail: valueWork(p,w,tail)
    case 1n+ +p R.Present{R.ArrayReference{id}} <> tail:
      valueWork(p,w,B.append(R.Slot,Arrays.get(w,id),tail))
    case 1n+ +p R.Present{value} <> tail:
      # All admitted object atoms lack nodeType; primitives/null are false too.
      valueWork(p,w,tail)

def arraySlots(arrays: List<&2,R.ArrayData>) -> Nat:
  match arrays:
    case Nil{}: 0n
    case array <> tail: Nat.add(B.length(R.Slot,R.ArrayData.slots(array)),arraySlots(tail))

def valueInserts(+w: R.World,value: R.Value) -> B.Bundle<R.World,Bool>:
  valueWork(1n+Nat.mul(4n,1n+arraySlots(R.World.arrays(w))),w,[R.Present{value}])

def bornChildren(fuel: Nat,+w: R.World,+child: Nat) -> B.Bundle<R.World,Nat>:
  match fuel:
    case 0n:
      B.Bundle{B.choose(~R.World,Nat.is_eq(child,0n),_=>w,_=>R.World.with_fault(w,R.Exhausted{})),0n}
    case 1n+ +p:
      B.choose(~B.Bundle<R.World,Nat>,Nat.is_eq(child,0n),_=>B.Bundle{w,0n},
        _=>B.choose(~B.Bundle<R.World,Nat>,B.has(R.Node.flags(B.node(w,child)),K.REACTIVE_DISPOSED()),_=>bornChildren(p,w,R.Node.nextSibling(B.node(w,child))),
          _=>
            +n = B.node(w,child)
            +candidate = Bool.and(Tx.isRender(R.Node.kind(n)),Bool.and(B.has(R.Node.status(n),K.STATUS_UNINITIALIZED()),Bool.and(B.has(R.Node.config(n),K.CONFIG_HELD()),B.present(R.Node.pending(n)))))
            +pair = B.choose(~B.Bundle<R.World,Nat>,candidate,
              _=>
                +tx = Tx.txOf(w,child)
                +w = B.first(R.World,Nat,tx)
                +t = B.second(R.World,Nat,tx)
                +blocked = B.choose(~B.Bundle<R.World,Bool>,R.Transaction.lane(B.transaction(w,t)),_=>B.Bundle{w,False{}},_=>Tx.blocked(w,t))
                B.Bundle{B.first(R.World,Bool,blocked),B.choose(~Nat,B.second(R.World,Bool,blocked),_=>t,_=>0n)},_=>B.Bundle{w,0n})
            +w = B.first(R.World,Nat,pair)
            B.choose(~B.Bundle<R.World,Nat>,Nat.is_ne(B.second(R.World,Nat,pair),0n),_=>pair,
              _=>
                +inner = bornChildren(p,w,R.Node.firstChild(B.node(w,child)))
                +w = B.first(R.World,Nat,inner)
                B.choose(~B.Bundle<R.World,Nat>,Nat.is_ne(B.second(R.World,Nat,inner),0n),_=>inner,_=>bornChildren(p,w,R.Node.nextSibling(B.node(w,child)))))))

def bornHeldOpen(+w: R.World,owner: Nat) -> B.Bundle<R.World,Nat>:
  bornChildren(B.budget(w),w,R.Node.firstChild(B.node(w,owner)))

def attachDeps(fuel: Nat,+w: R.World,+edge: Nat,+node: Nat) -> B.Bundle<R.World,Nat>:
  match fuel:
    case 0n: B.Bundle{B.choose(~R.World,Nat.is_eq(edge,0n),_=>w,_=>R.World.with_fault(w,R.Exhausted{})),0n}
    case 1n+p:
      B.choose(~B.Bundle<R.World,Nat>,Nat.is_eq(edge,0n),_=>B.Bundle{w,0n},
        _=>
          +pair = bornHeldOpen(w,R.Link.dep(B.link(w,edge)))
          +w = B.first(R.World,Nat,pair)
          B.choose(~B.Bundle<R.World,Nat>,Bool.or(Nat.is_ne(B.second(R.World,Nat,pair),0n),Nat.is_eq(edge,R.Node.depsTail(B.node(w,node)))),_=>pair,_=>attachDeps(p,w,R.Link.nextDep(B.link(w,edge)),node)))

def attachWaits(+w: R.World,+node: Nat) -> B.Bundle<R.World,Bool>:
  +n = B.node(w,node)
  +candidate = Bool.and(Tx.isRender(R.Node.kind(n)),Bool.or(B.has(R.Node.config(n),K.CONFIG_VERDICT()),R.Transaction.lane(B.transaction(w,R.NodeExtension.transaction(B.extension(w,node))))))
  +inserts = B.choose(~B.Bundle<R.World,Bool>,candidate,_=>valueInserts(w,B.current(n)),_=>B.Bundle{w,False{}})
  +w = B.first(R.World,Bool,inserts)
  B.choose(~B.Bundle<R.World,Bool>,B.second(R.World,Bool,inserts),
    _=>
      +pair = bornHeldOpen(w,node)
      +w = B.first(R.World,Nat,pair)
      +pair = B.choose(~B.Bundle<R.World,Nat>,Nat.is_ne(B.second(R.World,Nat,pair),0n),_=>pair,_=>attachDeps(B.budget(w),w,R.Node.deps(B.node(w,node)),node))
      +w = B.first(R.World,Nat,pair)
      +t = B.second(R.World,Nat,pair)
      B.choose(~B.Bundle<R.World,Bool>,Nat.is_eq(t,0n),_=>B.Bundle{w,False{}},
        _=>B.Bundle{B.store_transaction(w,t,R.Transaction.with_renderQueue(B.transaction(w,t),B.append(Nat,R.Transaction.renderQueue(B.transaction(w,t)),[node]))),True{}}),
    _=>B.Bundle{w,False{}})
