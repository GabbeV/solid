# Initial held-source facts used by actual setters. The next certificate is
# constructed from the three precise transition frames, retaining the actual
# extension membership and canonical positive group; it is never an assumption.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/equality.bend as Equality
import ../runtime/constants.bend as K
import ./held-write-outer.bend as Outer
import ./held-extension-frame.bend as Extension
import ./held-transition-frame.bend as Transition
import ./subscriber-topology-frame.bend as Shape
import ./ordinary-shape-facts.bend as Facts
import ./subscriber-walk-step.bend as Path
import ./subscriber-path-transport.bend as Move
import ./node-pointer-observation.bend as Pointer

type Profile<-w: R.World,-id: Nat,-offset: Nat> is Data:
  HeldAt{path: Path.Path<w>,extra: Nat,
    health: {R.World.fault(w) == R.Healthy{} : R.Fault},
    unmarked: {R.World.marked(w) == False{} : Bool},
    valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},
    head: {R.Node.subs(B.node(w,id)) == Path.origin(w,path) : Nat},
    room: {B.budget(w) == Nat.add(Path.depth(w,path),extra) : Nat},
    context: {R.World.context(w) == 0n : Nat},
    signal: {R.Node.kind(B.node(w,id)) == R.Signal{} : R.NodeKind},
    held: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()) == True{} : Bool},
    override: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()) == False{} : Bool},
    custom: {Equality.custom(w,id) == 0n : Nat},
    existing: {Nat.is_eq(R.Node.x(B.node(w,id)),0n) == False{} : Bool},
    extensionRoom: {Nat.is_lt(R.Node.x(B.node(w,id)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool},
    canonical: {R.NodeExtension.transaction(B.extension(w,id)) == 1n+offset : Nat},
    future: {R.World.flushTransaction(w) == 1n+offset : Nat},
    terminal: {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat},
    groupRoom: {Nat.is_lt(1n+offset,B.length(R.Transaction,R.World.txArena(w))) == True{} : Bool}}

def path(-w: R.World,-id: Nat,-offset: Nat,profile: Profile<w,id,offset>) -> Path.Path<w>:
  match profile:
    case HeldAt{path,extra,health,unmarked,valid,head,room,context,signal,held,override,custom,existing,extensionRoom,canonical,future,terminal,groupRoom}: path

def healthy(-w: R.World,-id: Nat,-offset: Nat,profile: Profile<w,id,offset>) -> {R.World.fault(w) == R.Healthy{} : R.Fault}:
  match profile:
    case HeldAt{path,extra,health,unmarked,valid,head,room,context,signal,held,override,custom,existing,extensionRoom,canonical,future,terminal,groupRoom}: health

def renew(+w: R.World,+next: R.World,+id: Nat,+offset: Nat,profile: Profile<w,id,offset>,frame: Transition.Transition<w,next,id>,moved: Move.Rebased<w,next,path(w,id,offset,profile)>) -> Profile<next,id,offset>:
  match profile:
    case HeldAt{oldPath,+extra,health,unmarked,valid,head,room,context,signal,held,override,custom,existing,extensionRoom,canonical,future,terminal,groupRoom}:
      match frame:
        case Transition.Retained{+outer,+shape,+pointers}:
          match moved:
            case Move.RebasedAt{+nextPath,origin,depth}:
              +slot = R.Node.x(B.node(w,id))
              +nodeShape = Shape.read(w,next,id,shape)
              +pointer = Pointer.read(w,next,id,pointers)
              +arena = Outer.sameTxArena(w,next,slot,outer)
              HeldAt{nextPath,extra,
                Equal.trans(R.Fault,R.World.fault(next),R.World.fault(w),R.Healthy{},Outer.sameFault(w,next,slot,outer),health),
                Equal.trans(Bool,R.World.marked(next),R.World.marked(w),False{},Outer.sameMarked(w,next,slot,outer),unmarked),
                Facts.valid(w,next,id,shape,valid),
                Equal.trans(Nat,R.Node.subs(B.node(next,id)),R.Node.subs(B.node(w,id)),Path.origin(next,nextPath),Equal.cong(Shape.Shape,Nat,s=>Facts.subscribers(s),Shape.shape(B.node(next,id)),Shape.shape(B.node(w,id)),nodeShape),Equal.trans(Nat,R.Node.subs(B.node(w,id)),Path.origin(w,oldPath),Path.origin(next,nextPath),head,Equal.sym(Nat,Path.origin(next,nextPath),Path.origin(w,oldPath),origin))),
                Equal.trans(Nat,B.budget(next),B.budget(w),Nat.add(Path.depth(next,nextPath),extra),Facts.budget(w,next,shape),Equal.trans(Nat,B.budget(w),Nat.add(Path.depth(w,oldPath),extra),Nat.add(Path.depth(next,nextPath),extra),room,Equal.cong(Nat,Nat,n=>Nat.add(n,extra),Path.depth(w,oldPath),Path.depth(next,nextPath),Equal.sym(Nat,Path.depth(next,nextPath),Path.depth(w,oldPath),depth)))),
                Equal.trans(Nat,R.World.context(next),R.World.context(w),0n,Outer.sameContext(w,next,slot,outer),context),
                Equal.trans(R.NodeKind,R.Node.kind(B.node(next,id)),R.Node.kind(B.node(w,id)),R.Signal{},Equal.cong(Shape.Shape,R.NodeKind,s=>Facts.kind(s),Shape.shape(B.node(next,id)),Shape.shape(B.node(w,id)),nodeShape),signal),
                Equal.trans(Bool,B.has(R.Node.config(B.node(next,id)),K.CONFIG_HELD()),B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),True{},Equal.cong(Shape.Shape,Bool,s=>B.has(Facts.config(s),K.CONFIG_HELD()),Shape.shape(B.node(next,id)),Shape.shape(B.node(w,id)),nodeShape),held),
                Equal.trans(Bool,B.has(R.Node.config(B.node(next,id)),K.CONFIG_OVERRIDE()),B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()),False{},Equal.cong(Shape.Shape,Bool,s=>B.has(Facts.config(s),K.CONFIG_OVERRIDE()),Shape.shape(B.node(next,id)),Shape.shape(B.node(w,id)),nodeShape),override),
                Equal.trans(Nat,Equality.custom(next,id),Equality.custom(w,id),0n,Equal.cong(List<&2,R.ComparatorBinding>,Nat,rows=>Equality.find(rows,id),R.World.comparators(next),R.World.comparators(w),Outer.sameComparators(w,next,slot,outer)),custom),
                Equal.trans(Bool,Nat.is_eq(R.Node.x(B.node(next,id)),0n),Nat.is_eq(slot,0n),False{},Equal.cong(Nat,Bool,at=>Nat.is_eq(at,0n),R.Node.x(B.node(next,id)),slot,pointer),existing),
                Extension.room(w,next,id,pointer,outer,extensionRoom),
                Equal.trans(Nat,R.NodeExtension.transaction(B.extension(next,id)),R.NodeExtension.transaction(B.extension(w,id)),1n+offset,Extension.sameTransaction(w,next,id,pointer,outer),canonical),
                Equal.trans(Nat,R.World.flushTransaction(next),R.World.flushTransaction(w),1n+offset,Outer.sameFlushTransaction(w,next,slot,outer),future),
                Equal.trans(Nat,R.Transaction.into(B.transaction(next,1n+offset)),R.Transaction.into(B.transaction(w,1n+offset)),0n,Equal.cong(List<&2,R.Transaction>,Nat,rows=>R.Transaction.into(B.get(R.Transaction,rows,1n+offset,B.blank_transaction())),R.World.txArena(next),R.World.txArena(w),arena),terminal),
                Equal.trans(Bool,Nat.is_lt(1n+offset,B.length(R.Transaction,R.World.txArena(next))),Nat.is_lt(1n+offset,B.length(R.Transaction,R.World.txArena(w))),True{},Equal.cong(List<&2,R.Transaction>,Bool,rows=>Nat.is_lt(1n+offset,B.length(R.Transaction,rows)),R.World.txArena(next),R.World.txArena(w),arena),groupRoom)}

def transport(+w: R.World,+next: R.World,+id: Nat,+offset: Nat,+profile: Profile<w,id,offset>,+frame: Transition.Transition<w,next,id>) -> Profile<next,id,offset>:
  match frame:
    case Transition.Retained{+outer,shape,pointers}:
      renew(w,next,id,offset,profile,Transition.Retained{outer,shape,pointers},Move.move(w,next,path(w,id,offset,profile),Outer.sameLinks(w,next,R.Node.x(B.node(w,id)),outer)))

def terminal(-w: R.World,-id: Nat,-offset: Nat,profile: Profile<w,id,offset>) -> {R.Transaction.into(B.transaction(w,1n+offset)) == 0n : Nat}:
  match profile:
    case HeldAt{path,extra,health,unmarked,valid,head,room,context,signal,held,override,custom,existing,extensionRoom,canonical,future,terminal,groupRoom}: terminal

def groupValid(-w: R.World,-id: Nat,-offset: Nat,profile: Profile<w,id,offset>) -> {Nat.is_lt(1n+offset,B.length(R.Transaction,R.World.txArena(w))) == True{} : Bool}:
  match profile:
    case HeldAt{path,extra,health,unmarked,valid,head,room,context,signal,held,override,custom,existing,extensionRoom,canonical,future,terminal,groupRoom}: groupRoom
