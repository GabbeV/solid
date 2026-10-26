# Actual stageResolved retains health and action/group metadata in the ordinary
# imperative profile. Finite source-link certificates establish traversal room.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ../runtime/constants.bend as K
import ./staging-committed-frame.bend as Stage
import ./ordinary-write-outer.bend as Frame
import ./ordinary-stage-intake.bend as Intake
import ./ordinary-stage-tail.bend as Tail
import ./subscriber-walk-step.bend as Path

def entered(+w: R.World,+id: Nat) -> R.World:
  Intake.simple(w,id,B.present(R.Node.pending(B.node(w,id))))

def entryNode(+w: R.World,+id: Nat) -> {B.node(entered(w,id),id) == B.node(w,id) : R.Node}:
  Equal.cong(List<&2,R.Node>,R.Node,nodes=>B.get(R.Node,nodes,id,B.blank_node()),R.World.nodes(entered(w,id)),R.World.nodes(w),Intake.nodes(w,id,B.present(R.Node.pending(B.node(w,id)))))

def entryBudget(+w: R.World,+id: Nat) -> {B.budget(entered(w,id)) == B.budget(w) : Nat}:
  Equal.trans(Nat,B.budget(entered(w,id)),Nat.mul(4n,Nat.add(B.length(R.Node,R.World.nodes(w)),B.length(R.Link,R.World.links(entered(w,id))))),B.budget(w),Equal.cong(List<&2,R.Node>,Nat,nodes=>Nat.mul(4n,Nat.add(B.length(R.Node,nodes),B.length(R.Link,R.World.links(entered(w,id))))),R.World.nodes(entered(w,id)),R.World.nodes(w),Intake.nodes(w,id,B.present(R.Node.pending(B.node(w,id))))),Equal.cong(List<&2,R.Link>,Nat,links=>Nat.mul(4n,Nat.add(B.length(R.Node,R.World.nodes(w)),B.length(R.Link,links))),R.World.links(entered(w,id)),R.World.links(w),Frame.sameLinks(w,entered(w,id),Intake.frame(w,id,B.present(R.Node.pending(B.node(w,id)))))))

def actual(+w: R.World,+path: Path.Path<w>,+id: Nat,+value: R.Value,+extra: Nat,unmarked: {R.World.marked(w) == False{} : Bool},valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},head: {R.Node.subs(B.node(w,id)) == Path.origin(w,path) : Nat},room: {B.budget(w) == Nat.add(Path.depth(w,path),extra) : Nat},context: {R.World.context(w) == 0n : Nat},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},ordinary: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()) == False{} : Bool}) -> {Frame.observe(W.stageResolved(w,id,value)) == Frame.observe(w) : R.World}:
  +node = B.node(w,id)
  +staged = B.present(R.Node.pending(node))
  +next = entered(w,id)
  +same = Intake.frame(w,id,staged)
  +nextValid = Equal.trans(Bool,Nat.is_lt(id,B.length(R.Node,R.World.nodes(next))),Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))),True{},Equal.cong(List<&2,R.Node>,Bool,nodes=>Nat.is_lt(id,B.length(R.Node,nodes)),R.World.nodes(next),R.World.nodes(w),Intake.nodes(w,id,staged)),valid)
  +nextHead = Equal.trans(Nat,R.Node.subs(B.node(next,id)),R.Node.subs(B.node(w,id)),Path.origin(w,path),Equal.cong(R.Node,Nat,n=>R.Node.subs(n),B.node(next,id),B.node(w,id),entryNode(w,id)),head)
  +nextRoom = Equal.trans(Nat,B.budget(next),B.budget(w),Nat.add(Path.depth(w,path),extra),entryBudget(w,id),room)
  Equal.trans(R.World,Frame.observe(W.stageResolved(w,id,value)),Frame.observe(Stage.tail(next,id,value,node,staged)),Frame.observe(w),Equal.cong(R.World,R.World,state=>Frame.observe(Stage.tail(state,id,value,node,staged)),Stage.intake(w,id,node,staged),next,Intake.exact(w,id,staged,ordinary)),Tail.frame(w,path,next,id,value,node,staged,extra,same,unmarked,nextValid,nextHead,nextRoom,Frame.context(w,next,same,context),signal))

def healthy(+w: R.World,+path: Path.Path<w>,+id: Nat,+value: R.Value,+extra: Nat,health: {R.World.fault(w) == R.Healthy{} : R.Fault},unmarked: {R.World.marked(w) == False{} : Bool},valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},head: {R.Node.subs(B.node(w,id)) == Path.origin(w,path) : Nat},room: {B.budget(w) == Nat.add(Path.depth(w,path),extra) : Nat},context: {R.World.context(w) == 0n : Nat},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},ordinary: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()) == False{} : Bool}) -> {R.World.fault(W.stageResolved(w,id,value)) == R.Healthy{} : R.Fault}:
  Frame.health(w,W.stageResolved(w,id,value),actual(w,path,id,value,extra,unmarked,valid,head,room,context,signal,ordinary),health)
