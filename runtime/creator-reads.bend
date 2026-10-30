# core/core.ts:creatorReads. Only currently computing creator ancestors count.
# A structural walk faults on exhaustion; successful finite chains retain the
# source accumulation and apply the joined/staged mask only at the return.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K

def selected(bits: U32) -> U32:
  U32.and(bits,U32.or(K.REACTIVE_JOINED(),K.REACTIVE_STAGED_READ()))

def next(fuel: Nat,+w: R.World,+parent: Nat,+born: U32) -> B.Bundle<R.World,U32>:
  match fuel:
    case 0n:
      +active = Bool.and(Nat.is_ne(parent,0n),B.has(R.Node.flags(B.node(w,parent)),K.REACTIVE_RECOMPUTING_DEPS()))
      B.Bundle{B.choose(~R.World,active,_=>R.World.with_fault(w,R.Exhausted{}),_=>w),selected(born)}
    case 1n+left:
      +active = Bool.and(Nat.is_ne(parent,0n),B.has(R.Node.flags(B.node(w,parent)),K.REACTIVE_RECOMPUTING_DEPS()))
      B.choose(~B.Bundle<R.World,U32>,active,
        _=>next(left,w,B.parentComputed(w,R.Node.parent(B.node(w,parent))),U32.or(born,R.Node.flags(B.node(w,parent)))),
        _=>B.Bundle{w,selected(born)})

def creatorReads(+w: R.World,+reader: Nat,born: U32) -> B.Bundle<R.World,U32>:
  next(1n+B.length(R.Node,R.World.nodes(w)),w,B.parentComputed(w,R.Node.parent(B.node(w,reader))),born)
