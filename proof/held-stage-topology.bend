# Held intake retains actual nodes and links; the existing source tail contracts
# then retain kind/config/subscriber shape and extension identities separately.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ./held-stage-intake.bend as Intake
import ./held-write-outer.bend as Outer
import ./ordinary-stage-topology.bend as ShapeTail
import ./ordinary-stage-tail.bend as Tail
import ./staging-committed-frame.bend as Stage
import ./subscriber-topology-frame.bend as Shape
import ./node-pointer-observation.bend as Pointer
import ./pointer-store-frame.bend as Ptr
import ./pointer-notification-frame.bend as Notify

def shape(+w: R.World,+id: Nat,+value: R.Value,context: {R.World.context(w) == 0n : Nat},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},+existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}) -> {Shape.observe(W.stageResolved(w,id,value)) == Shape.observe(w) : Shape.View}:
  +node = B.node(w,id)
  +staged = B.present(R.Node.pending(node))
  +next = Intake.entered(w,id)
  +same = Intake.frame(w,id,existing)
  +slot = R.Node.x(node)
  +nextContext = Equal.trans(Nat,R.World.context(next),R.World.context(w),0n,Outer.sameContext(w,next,slot,same),context)
  Shape.compose(w,next,W.stageResolved(w,id,value),ShapeTail.tail(next,id,value,node,staged,nextContext,signal),ShapeTail.storage(w,next,Intake.nodes(w,id,existing),Outer.sameLinks(w,next,slot,same)))

def last(+w: R.World,+id: Nat,+node: R.Node,+staged: Bool) -> {Pointer.observe(Tail.last(w,id,node,staged)) == Pointer.observe(w) : List<&2,Nat>}:
  Ptr.choice(Bool.and(staged,B.stampMatches(R.Node.notified(node),R.World.epoch(w))),w,w,B.schedule(W.insertSubs(w,id)),{==},Ptr.compose(w,W.insertSubs(w,id),B.schedule(W.insertSubs(w,id)),Ptr.schedule(W.insertSubs(w,id)),Notify.insertSubs(w,id)))

def tail(+w: R.World,+id: Nat,+value: R.Value,+node: R.Node,+staged: Bool,context: {R.World.context(w) == 0n : Nat},signal: {R.Node.kind(node) == R.Signal{} : R.NodeKind}) -> {Pointer.observe(Stage.tail(w,id,value,node,staged)) == Pointer.observe(w) : List<&2,Nat>}:
  +next = Tail.put(w,id,value)
  Equal.trans(List<&2,Nat>,Pointer.observe(Stage.tail(w,id,value,node,staged)),Pointer.observe(Tail.last(next,id,node,staged)),Pointer.observe(w),Equal.cong(R.World,List<&2,Nat>,state=>Pointer.observe(state),Stage.tail(w,id,value,node,staged),Tail.last(next,id,node,staged),Tail.plain(w,id,value,node,staged,context,signal)),Ptr.compose(w,next,Tail.last(next,id,node,staged),last(next,id,node,staged),Ptr.pending(w,id,R.Present{value})))

def pointers(+w: R.World,+id: Nat,+value: R.Value,context: {R.World.context(w) == 0n : Nat},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},+existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}) -> {Pointer.observe(W.stageResolved(w,id,value)) == Pointer.observe(w) : List<&2,Nat>}:
  +node = B.node(w,id)
  +staged = B.present(R.Node.pending(node))
  +next = Intake.entered(w,id)
  +same = Intake.frame(w,id,existing)
  +slot = R.Node.x(node)
  +nextContext = Equal.trans(Nat,R.World.context(next),R.World.context(w),0n,Outer.sameContext(w,next,slot,same),context)
  Pointer.compose(w,next,W.stageResolved(w,id,value),tail(next,id,value,node,staged,nextContext,signal),Equal.cong(List<&2,R.Node>,List<&2,Nat>,rows=>Pointer.pointers(rows),R.World.nodes(next),R.World.nodes(w),Intake.nodes(w,id,existing)))
