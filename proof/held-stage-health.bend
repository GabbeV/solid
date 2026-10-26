# Actual stageResolved through held snapshot saving and the real subscriber
# walk. An initial finite path supplies fuel; the destination path is constructed
# from preserved links. No post-staging health, count or traversal is assumed.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ./held-stage-intake.bend as Intake
import ./held-write-outer.bend as Frame
import ./ordinary-stage-tail.bend as Tail
import ./staging-committed-frame.bend as Stage
import ./subscriber-walk-step.bend as Path
import ./subscriber-path-transport.bend as Move

def afterPath(+w: R.World,+path: Path.Path<w>,+id: Nat,+value: R.Value,+extra: Nat,+same: {Frame.observe(Intake.entered(w,id),R.Node.x(B.node(w,id))) == Frame.observe(w,R.Node.x(B.node(w,id))) : R.World},unmarked: {R.World.marked(Intake.entered(w,id)) == False{} : Bool},valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(Intake.entered(w,id)))) == True{} : Bool},head: {R.Node.subs(B.node(Intake.entered(w,id),id)) == Path.origin(w,path) : Nat},room: {B.budget(Intake.entered(w,id)) == Nat.add(Path.depth(w,path),extra) : Nat},context: {R.World.context(Intake.entered(w,id)) == 0n : Nat},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},moved: Move.Rebased<w,Intake.entered(w,id),path>) -> {Frame.observe(W.stageResolved(w,id,value),R.Node.x(B.node(w,id))) == Frame.observe(w,R.Node.x(B.node(w,id))) : R.World}:
  match moved:
    case Move.RebasedAt{+nextPath,origin,depth}:
      +next = Intake.entered(w,id)
      +slot = R.Node.x(B.node(w,id))
      +node = B.node(w,id)
      +staged = B.present(R.Node.pending(node))
      +nextHead = Equal.trans(Nat,R.Node.subs(B.node(next,id)),Path.origin(w,path),Path.origin(next,nextPath),head,Equal.sym(Nat,Path.origin(next,nextPath),Path.origin(w,path),origin))
      +nextRoom = Equal.trans(Nat,B.budget(next),Nat.add(Path.depth(w,path),extra),Nat.add(Path.depth(next,nextPath),extra),room,Equal.cong(Nat,Nat,n=>Nat.add(n,extra),Path.depth(w,path),Path.depth(next,nextPath),Equal.sym(Nat,Path.depth(next,nextPath),Path.depth(w,path),depth)))
      Frame.compose(w,next,W.stageResolved(w,id,value),slot,Frame.fromOuter(next,Stage.tail(next,id,value,node,staged),slot,Tail.frame(next,nextPath,next,id,value,node,staged,extra,{==},unmarked,valid,nextHead,nextRoom,context,signal)),same)

def actual(+w: R.World,+path: Path.Path<w>,+id: Nat,+value: R.Value,+extra: Nat,unmarked: {R.World.marked(w) == False{} : Bool},valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},head: {R.Node.subs(B.node(w,id)) == Path.origin(w,path) : Nat},room: {B.budget(w) == Nat.add(Path.depth(w,path),extra) : Nat},context: {R.World.context(w) == 0n : Nat},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},+existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}) -> {Frame.observe(W.stageResolved(w,id,value),R.Node.x(B.node(w,id))) == Frame.observe(w,R.Node.x(B.node(w,id))) : R.World}:
  +next = Intake.entered(w,id)
  +slot = R.Node.x(B.node(w,id))
  +same = Intake.frame(w,id,existing)
  +nodes = Intake.nodes(w,id,existing)
  +node = Equal.cong(List<&2,R.Node>,R.Node,rows=>B.get(R.Node,rows,id,B.blank_node()),R.World.nodes(next),R.World.nodes(w),nodes)
  +nextValid = Equal.trans(Bool,Nat.is_lt(id,B.length(R.Node,R.World.nodes(next))),Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))),True{},Equal.cong(List<&2,R.Node>,Bool,rows=>Nat.is_lt(id,B.length(R.Node,rows)),R.World.nodes(next),R.World.nodes(w),nodes),valid)
  +nextHead = Equal.trans(Nat,R.Node.subs(B.node(next,id)),R.Node.subs(B.node(w,id)),Path.origin(w,path),Equal.cong(R.Node,Nat,n=>R.Node.subs(n),B.node(next,id),B.node(w,id),node),head)
  +nextRoom = Equal.trans(Nat,B.budget(next),B.budget(w),Nat.add(Path.depth(w,path),extra),Intake.budget(w,id,existing),room)
  +nextUnmarked = Equal.trans(Bool,R.World.marked(next),R.World.marked(w),False{},Frame.sameMarked(w,next,slot,same),unmarked)
  +nextContext = Equal.trans(Nat,R.World.context(next),R.World.context(w),0n,Frame.sameContext(w,next,slot,same),context)
  afterPath(w,path,id,value,extra,same,nextUnmarked,nextValid,nextHead,nextRoom,nextContext,signal,Move.move(w,next,path,Frame.sameLinks(w,next,slot,same)))

def healthy(+w: R.World,+path: Path.Path<w>,+id: Nat,+value: R.Value,+extra: Nat,health: {R.World.fault(w) == R.Healthy{} : R.Fault},unmarked: {R.World.marked(w) == False{} : Bool},valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},head: {R.Node.subs(B.node(w,id)) == Path.origin(w,path) : Nat},room: {B.budget(w) == Nat.add(Path.depth(w,path),extra) : Nat},context: {R.World.context(w) == 0n : Nat},signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool}) -> {R.World.fault(W.stageResolved(w,id,value)) == R.Healthy{} : R.Fault}:
  Equal.trans(R.Fault,R.World.fault(W.stageResolved(w,id,value)),R.World.fault(w),R.Healthy{},Frame.sameFault(w,W.stageResolved(w,id,value),R.Node.x(B.node(w,id)),actual(w,path,id,value,extra,unmarked,valid,head,room,context,signal,existing)),health)
