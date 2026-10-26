# Ordinary imperative staging retains source kind/config/subscriber heads and
# all links. This is a shape frame; fault/health is proved separately.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ../runtime/constants.bend as K
import ./staging-committed-frame.bend as Stage
import ./ordinary-stage-intake.bend as Intake
import ./ordinary-stage-tail.bend as Tail
import ./ordinary-write-outer.bend as Outer
import ./subscriber-topology-frame.bend as Frame
import ./ordinary-notification-topology.bend as Notify

def storage(+w: R.World,+next: R.World,nodes: {R.World.nodes(next) == R.World.nodes(w) : List<&2,R.Node>},links: {R.World.links(next) == R.World.links(w) : List<&2,R.Link>}) -> {Frame.observe(next) == Frame.observe(w) : Frame.View}:
  Equal.trans(Frame.View,Frame.observe(next),Frame.View{Frame.shapes(R.World.nodes(w)),R.World.links(next)},Frame.observe(w),Equal.cong(List<&2,R.Node>,Frame.View,rows=>Frame.View{Frame.shapes(rows),R.World.links(next)},R.World.nodes(next),R.World.nodes(w),nodes),Equal.cong(List<&2,R.Link>,Frame.View,rows=>Frame.View{Frame.shapes(R.World.nodes(w)),rows},R.World.links(next),R.World.links(w),links))

def intake(+w: R.World,+id: Nat,+staged: Bool) -> {Frame.observe(Intake.simple(w,id,staged)) == Frame.observe(w) : Frame.View}:
  storage(w,Intake.simple(w,id,staged),Intake.nodes(w,id,staged),Outer.sameLinks(w,Intake.simple(w,id,staged),Intake.frame(w,id,staged)))

def last(+w: R.World,+id: Nat,+node: R.Node,+staged: Bool) -> {Frame.observe(Tail.last(w,id,node,staged)) == Frame.observe(w) : Frame.View}:
  Frame.choice(Bool.and(staged,B.stampMatches(R.Node.notified(node),R.World.epoch(w))),w,w,B.schedule(W.insertSubs(w,id)),{==},Frame.compose(w,W.insertSubs(w,id),B.schedule(W.insertSubs(w,id)),Frame.schedule(W.insertSubs(w,id)),Notify.insertSubs(w,id)))

def tail(+w: R.World,+id: Nat,+value: R.Value,+node: R.Node,+staged: Bool,context: {R.World.context(w) == 0n : Nat},signal: {R.Node.kind(node) == R.Signal{} : R.NodeKind}) -> {Frame.observe(Stage.tail(w,id,value,node,staged)) == Frame.observe(w) : Frame.View}:
  +next = Tail.put(w,id,value)
  Equal.trans(Frame.View,Frame.observe(Stage.tail(w,id,value,node,staged)),Frame.observe(Tail.last(next,id,node,staged)),Frame.observe(w),Equal.cong(R.World,Frame.View,state=>Frame.observe(state),Stage.tail(w,id,value,node,staged),Tail.last(next,id,node,staged),Tail.plain(w,id,value,node,staged,context,signal)),Frame.compose(w,next,Tail.last(next,id,node,staged),last(next,id,node,staged),Frame.pending(w,id,R.Present{value})))

def actual(+w: R.World,+id: Nat,+value: R.Value,context: {R.World.context(w) == 0n : Nat},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},ordinary: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()) == False{} : Bool}) -> {Frame.observe(W.stageResolved(w,id,value)) == Frame.observe(w) : Frame.View}:
  +node = B.node(w,id)
  +staged = B.present(R.Node.pending(node))
  +next = Intake.simple(w,id,staged)
  Equal.trans(Frame.View,Frame.observe(W.stageResolved(w,id,value)),Frame.observe(Stage.tail(next,id,value,node,staged)),Frame.observe(w),Equal.cong(R.World,Frame.View,state=>Frame.observe(Stage.tail(state,id,value,node,staged)),Stage.intake(w,id,node,staged),next,Intake.exact(w,id,staged,ordinary)),Frame.compose(w,next,Stage.tail(next,id,value,node,staged),tail(next,id,value,node,staged,Outer.context(w,next,Intake.frame(w,id,staged),context),signal),intake(w,id,staged)))
