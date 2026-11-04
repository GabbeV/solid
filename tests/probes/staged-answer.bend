# Private first-answer/reask helper controls; no public reachability claim.
import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/extension.bend as E
import ../../runtime/constants.bend as K
import ../../runtime/staged-answer.bend as Answer

def sources(+mode: U32) -> List<&2,Nat>:
  B.choose(~List<&2,Nat>,U32.is_eq(mode,2),_=>[2n],_=>B.choose(~List<&2,Nat>,U32.is_eq(mode,3),_=>[3n],_=>B.choose(~List<&2,Nat>,U32.is_eq(mode,4),_=>[2n,3n],_=>[])))

def fixture(+readerStatus: U32,+sourceStatus: U32,+flags: U32,+config: U32,+effect: Bool,+readerSlot: Bool,+sourceSlot: Bool,+lane: Bool,+clock: Nat,+stamp: U32,+mode: U32) -> R.World:
  +w = N.createOwner(B.empty(),0n,False{})
  +options = R.NodeOptions.with_lazy(N.defaults(),True{})
  +w = N.computed(0n,w,R.Literal{R.Number{7n}},options,1n)
  +w = N.computed(0n,w,R.Literal{R.Number{11n}},options,1n)
  +w = R.World.with_clock(w,clock)
  +w = R.World.with_passLane(w,B.choose(~Nat,lane,_=>1n,_=>0n))
  +node = R.Node.with_status(R.Node.with_config(B.node(w,2n),config),sourceStatus)
  +w = B.store_node(w,2n,R.Node.with_pending(node,B.choose(~R.Slot,sourceSlot,_=>R.Present{R.Number{77n}},_=>R.Empty{})))
  +node = R.Node.with_flags(R.Node.with_status(B.node(w,3n),readerStatus),flags)
  +node = R.Node.with_kind(node,B.choose(~R.NodeKind,effect,_=>R.Render{},_=>R.Memo{}))
  +w = B.store_node(w,3n,R.Node.with_pending(node,B.choose(~R.Slot,readerSlot,_=>R.Present{R.Number{1n}},_=>R.Empty{})))
  +w = E.ext(w,2n)
  +w = B.store_extension(w,2n,R.NodeExtension.with_error(B.extension(w,2n),R.NotReadyFailure{1n,2n}))
  +w = B.choose(~R.World,Bool.or(U32.is_ne(stamp,0),U32.is_ne(mode,0)),_=>E.ext(w,3n),_=>w)
  +w = B.choose(~R.World,U32.is_ne(stamp,0),_=>B.store_extension(w,3n,R.NodeExtension.with_served(B.extension(w,3n),R.Stamped{B.choose(~Nat,U32.is_eq(stamp,1),_=>clock,_=>1n+clock)})),_=>w)
  B.choose(~R.World,U32.is_ne(mode,0),_=>B.setPendingSources(w,3n,R.Sources{sources(mode)}),_=>w)

def serve(w: R.World) -> B.Bundle<R.World,Bool>:
  Answer.servesStaged(w,3n,2n,2n)

def clearLatch(+w: R.World) -> R.World:
  B.store_node(w,3n,R.Node.with_flags(B.node(w,3n),B.clear(R.Node.flags(B.node(w,3n)),K.REACTIVE_MISSED_WAKE())))

def node(w: R.World) -> R.Node:
  B.node(w,3n)

def extension(w: R.World) -> R.NodeExtension:
  B.extension(w,3n)

def pending(w: R.World) -> R.SourceSet:
  B.pendingSources(w,3n)
