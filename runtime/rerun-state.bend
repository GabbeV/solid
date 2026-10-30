# scheduler.ts:reruns shared admission and pre-adoption stores. The active
# Core walker pauses at adoptParked's release callback; this module is pure.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K
import ./heap.bend as H

def clearChildRuns(fuel: Nat, +w: R.World, +child: Nat) -> R.World:
  match fuel:
    case 0n:
      B.choose(~R.World, Nat.is_eq(child, 0n), _ => w, _ => R.World.with_fault(w, R.Exhausted{}))
    case 1n+p:
      B.choose(~R.World, Nat.is_eq(child, 0n), _ => w,
        _ =>
          +w = B.choose(~R.World, B.effect(R.Node.kind(B.node(w, child))), _ => B.store_node(w, child, R.Node.with_modified(B.node(w, child), False{})), _ => w)
          clearChildRuns(p, w, R.Node.nextSibling(B.node(w, child))))

def errorSource(error: R.Value) -> Nat:
  match error:
    case R.StatusFailure{identity,source,cause,message}: source
    case R.NotReadyFailure{identity,source}: source
    case _: 0n

def ownError(+w: R.World,+id: Nat) -> Bool:
  +source = errorSource(R.NodeExtension.error(B.extension(w,id)))
  Bool.and(Nat.is_ne(source,0n),Nat.is_eq(source,id))

def skipped(+w: R.World,+id: Nat) -> Bool:
  +n = B.node(w,id)
  +source = errorSource(R.NodeExtension.error(B.extension(w,id)))
  Bool.or(B.has(R.Node.flags(n),K.REACTIVE_DISPOSED()),
    Bool.and(B.has(R.Node.status(n),K.STATUS_ERROR()),Bool.and(Bool.or(B.effect(R.Node.kind(n)),Bool.not(B.has(R.Node.config(n),K.CONFIG_FRAME()))),Bool.and(Bool.not(ownError(w,id)),Bool.or(Nat.is_eq(source,0n),B.has(R.Node.status(B.node(w,source)),K.STATUS_ERROR()))))))

def eligible(+w: R.World,+id: Nat) -> Bool:
  Bool.or(B.has(R.Node.flags(B.node(w,id)),K.REACTIVE_FRAME_READ()),B.has(R.Node.config(B.node(w,id)),K.CONFIG_VERDICT()))

def effectType(kind: R.NodeKind) -> Nat:
  match kind:
    case R.Render{}: 1n
    case R.User{}: 2n
    case R.Tracked{}: 3n
    case _: 0n

def prepare(+w: R.World,+tx: Nat,+id: Nat,+frame: Nat) -> B.Bundle<R.World,Nat>:
  +n = B.node(w,id)
  +kind = effectType(R.Node.kind(n))
  +frame = B.choose(~Nat,Nat.is_eq(frame,0n),_=>B.choose(~Nat,Nat.is_ne(kind,0n),_=>kind,_=>B.choose(~Nat,ownError(w,id),_=>1n,_=>0n)),_=>frame)
  +w = B.choose(~R.World,R.Transaction.lane(B.transaction(w,tx)),_=>w,_=>B.store_node(w,id,R.Node.with_flags(n,B.clear(R.Node.flags(n),K.REACTIVE_FRAME_READ()))))
  +w = B.store_node(w,id,R.Node.with_modified(B.node(w,id),False{}))
  B.Bundle{clearChildRuns(B.budget(w),w,R.Node.firstChild(B.node(w,id))),frame}

def present(flight: R.Flight) -> Bool:
  match flight:
    case R.FlightActive{result}: True{}
    case _: False{}

def adopts(+w: R.World,+id: Nat) -> Bool:
  Bool.and(present(R.NodeExtension.parkedFlight(B.extension(w,id))),Bool.not(B.has(R.Node.flags(B.node(w,id)),U32.or(K.REACTIVE_DIRTY(),U32.or(K.REACTIVE_CHECK(),K.REACTIVE_IN_HEAP())))))
