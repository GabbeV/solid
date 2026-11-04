# core/verdict.ts:keepReaders. No user calls occur in these graph/heap writes;
# the subscriber cursor is reloaded after the body, as in the source loop.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./heap.bend as H
import ./write.bend as W

def otherHeld(fuel: Nat,+w: R.World,+edge: Nat,+source: Nat) -> B.Bundle<R.World,Bool>:
  match fuel:
    case 0n:
      B.Bundle{B.choose(~R.World,Nat.is_eq(edge,0n),_=>w,_=>R.World.with_fault(w,R.Exhausted{})),False{}}
    case 1n+p:
      B.choose(~B.Bundle<R.World,Bool>,Nat.is_eq(edge,0n),_=>B.Bundle{w,False{}},
        _=>
          +dep = R.Link.dep(B.link(w,edge))
          B.choose(~B.Bundle<R.World,Bool>,Bool.and(Nat.is_ne(dep,source),B.has(R.Node.config(B.node(w,dep)),K.CONFIG_HELD())),_=>B.Bundle{w,True{}},_=>otherHeld(p,w,R.Link.nextDep(B.link(w,edge)),source)))

def keepOne(+w: R.World,+source: Nat,+reader: Nat) -> R.World:
  +n = B.node(w,reader)
  B.choose(~R.World,Bool.or(Bool.not(U32.is_eq(U32.and(R.Node.config(n),B.set(K.CONFIG_HELD(),K.CONFIG_STAGED())),B.set(K.CONFIG_HELD(),K.CONFIG_STAGED()))),B.effect(R.Node.kind(n))),_=>w,
    _=>
      +pair = otherHeld(B.budget(w),w,R.Node.deps(n),source)
      +w = B.first(R.World,Bool,pair)
      B.choose(~R.World,B.second(R.World,Bool,pair),_=>w,
        _=>
          +w = H.deleteFromHeap(w,reader)
          +w = B.store_node(w,reader,R.Node.with_flags(B.node(w,reader),B.clear(R.Node.flags(B.node(w,reader)),B.set(K.REACTIVE_DIRTY(),K.REACTIVE_CHECK()))))
          +w = B.store_node(w,reader,R.Node.with_config(B.node(w,reader),B.clear(R.Node.config(B.node(w,reader)),K.CONFIG_HELD())))
          W.insertSubs(W.queuePendingNode(w,reader),reader)))

def keepLoop(fuel: Nat,+w: R.World,+edge: Nat,+source: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World,Nat.is_eq(edge,0n),_=>w,_=>R.World.with_fault(w,R.Exhausted{}))
    case 1n+p:
      B.choose(~R.World,Nat.is_eq(edge,0n),_=>w,
        _=>
          +w = keepOne(w,source,R.Link.sub(B.link(w,edge)))
          keepLoop(p,w,R.Link.nextSub(B.link(w,edge)),source))

def keepReaders(+w: R.World,+source: Nat) -> R.World:
  keepLoop(B.budget(w),w,R.Node.subs(B.node(w,source)),source)
