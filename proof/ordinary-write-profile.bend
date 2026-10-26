# Reachable-state certificate for the finite ordinary updater body language.
# Transitions construct the next certificate from actual source operation laws;
# later health, path, room or source configuration are never assumed.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/write.bend as W
import ../runtime/equality.bend as Equality
import ../runtime/constants.bend as K
import ./ordinary-write-outer.bend as Outer
import ./ordinary-setter-health.bend as Setter
import ./ordinary-setter-topology.bend as Topology
import ./subscriber-topology-frame.bend as Shape
import ./ordinary-shape-facts.bend as Facts
import ./subscriber-walk-step.bend as Path
import ./subscriber-path-transport.bend as Move

type Profile<-w: R.World,-id: Nat> is Data:
  ProfileAt{path: Path.Path<w>,extra: Nat,
    health: {R.World.fault(w) == R.Healthy{} : R.Fault},
    unmarked: {R.World.marked(w) == False{} : Bool},
    valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},
    head: {R.Node.subs(B.node(w,id)) == Path.origin(w,path) : Nat},
    room: {B.budget(w) == Nat.add(Path.depth(w,path),extra) : Nat},
    context: {R.World.context(w) == 0n : Nat},
    signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},
    ordinary: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()) == False{} : Bool},
    override: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool},
    custom: {Equality.custom(w,id) == 0n : Nat}}

def path(-w: R.World,-id: Nat,profile: Profile<w,id>) -> Path.Path<w>:
  match profile:
    case ProfileAt{path,extra,health,unmarked,valid,head,room,context,signal,ordinary,override,custom}: path

def outer(+w: R.World,+id: Nat,+value: R.Value,profile: Profile<w,id>) -> {Outer.observe(W.setSignal(w,id,value)) == Outer.observe(w) : R.World}:
  match profile:
    case ProfileAt{path,extra,health,unmarked,valid,head,room,context,signal,ordinary,override,custom}:
      Setter.actual(w,path,id,B.current(B.node(w,id)),value,extra,unmarked,valid,head,room,context,signal,ordinary,custom)

def shape(+w: R.World,+id: Nat,+value: R.Value,profile: Profile<w,id>) -> {Shape.observe(W.setSignal(w,id,value)) == Shape.observe(w) : Shape.View}:
  match profile:
    case ProfileAt{path,extra,health,unmarked,valid,head,room,context,signal,ordinary,override,custom}:
      Topology.actual(w,id,B.current(B.node(w,id)),value,context,signal,ordinary,custom)

def renew(+w: R.World,+id: Nat,+value: R.Value,profile: Profile<w,id>,+outer: {Outer.observe(W.setSignal(w,id,value)) == Outer.observe(w) : R.World},+shape: {Shape.observe(W.setSignal(w,id,value)) == Shape.observe(w) : Shape.View},moved: Move.Rebased<w,W.setSignal(w,id,value),path(w,id,profile)>) -> Profile<W.setSignal(w,id,value),id>:
  match profile:
    case ProfileAt{oldPath,+extra,health,unmarked,valid,head,room,context,signal,ordinary,override,custom}:
      match moved:
        case Move.RebasedAt{+nextPath,origin,depth}:
          +next = W.setSignal(w,id,value)
          +nodeShape = Shape.read(w,next,id,shape)
          ProfileAt{nextPath,extra,
            Outer.health(w,next,outer,health),
            Outer.unmarked(w,next,outer,unmarked),
            Facts.valid(w,next,id,shape,valid),
            Equal.trans(Nat,R.Node.subs(B.node(next,id)),R.Node.subs(B.node(w,id)),Path.origin(next,nextPath),Equal.cong(Shape.Shape,Nat,s=>Facts.subscribers(s),Shape.shape(B.node(next,id)),Shape.shape(B.node(w,id)),nodeShape),Equal.trans(Nat,R.Node.subs(B.node(w,id)),Path.origin(w,oldPath),Path.origin(next,nextPath),head,Equal.sym(Nat,Path.origin(next,nextPath),Path.origin(w,oldPath),origin))),
            Equal.trans(Nat,B.budget(next),B.budget(w),Nat.add(Path.depth(next,nextPath),extra),Facts.budget(w,next,shape),Equal.trans(Nat,B.budget(w),Nat.add(Path.depth(w,oldPath),extra),Nat.add(Path.depth(next,nextPath),extra),room,Equal.cong(Nat,Nat,n=>Nat.add(n,extra),Path.depth(w,oldPath),Path.depth(next,nextPath),Equal.sym(Nat,Path.depth(next,nextPath),Path.depth(w,oldPath),depth)))),
            Outer.context(w,next,outer,context),
            Equal.trans(R.NodeKind,R.Node.kind(B.node(next,id)),R.Node.kind(B.node(w,id)),R.Signal{},Equal.cong(Shape.Shape,R.NodeKind,s=>Facts.kind(s),Shape.shape(B.node(next,id)),Shape.shape(B.node(w,id)),nodeShape),signal),
            Equal.trans(Bool,B.has(R.Node.config(B.node(next,id)),K.CONFIG_HELD()),B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),False{},Equal.cong(Shape.Shape,Bool,s=>B.has(Facts.config(s),K.CONFIG_HELD()),Shape.shape(B.node(next,id)),Shape.shape(B.node(w,id)),nodeShape),ordinary),
            Equal.trans(Bool,B.has(R.Node.config(B.node(next,id)),K.CONFIG_OVERRIDE()),B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()),False{},Equal.cong(Shape.Shape,Bool,s=>B.has(Facts.config(s),K.CONFIG_OVERRIDE()),Shape.shape(B.node(next,id)),Shape.shape(B.node(w,id)),nodeShape),override),
            Equal.trans(Nat,Equality.custom(next,id),Equality.custom(w,id),0n,Equal.cong(List<&2,R.ComparatorBinding>,Nat,rows=>Equality.find(rows,id),R.World.comparators(next),R.World.comparators(w),Outer.sameComparators(w,next,outer)),custom)}

def next(+w: R.World,+id: Nat,+value: R.Value,+profile: Profile<w,id>) -> Profile<W.setSignal(w,id,value),id>:
  +same = outer(w,id,value,profile)
  renew(w,id,value,profile,same,shape(w,id,value,profile),Move.move(w,W.setSignal(w,id,value),path(w,id,profile),Outer.sameLinks(w,W.setSignal(w,id,value),same)))
