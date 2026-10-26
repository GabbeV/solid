# Transfer the source profile across proved storage/control equalities. Actor,
# transaction and Promise metadata may change; no source profile fact is assumed
# at the destination. Actual constructor equations supply these field frames.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/equality.bend as Equality
import ../runtime/constants.bend as K
import ./ordinary-write-profile.bend as P
import ./subscriber-walk-step.bend as Path
import ./subscriber-path-transport.bend as Move

def budget(+w: R.World,+next: R.World,nodes: {R.World.nodes(next) == R.World.nodes(w) : List<&2,R.Node>},links: {R.World.links(next) == R.World.links(w) : List<&2,R.Link>}) -> {B.budget(next) == B.budget(w) : Nat}:
  Equal.trans(Nat,B.budget(next),Nat.mul(4n,Nat.add(B.length(R.Node,R.World.nodes(w)),B.length(R.Link,R.World.links(next)))),B.budget(w),Equal.cong(List<&2,R.Node>,Nat,rows=>Nat.mul(4n,Nat.add(B.length(R.Node,rows),B.length(R.Link,R.World.links(next)))),R.World.nodes(next),R.World.nodes(w),nodes),Equal.cong(List<&2,R.Link>,Nat,rows=>Nat.mul(4n,Nat.add(B.length(R.Node,R.World.nodes(w)),B.length(R.Link,rows))),R.World.links(next),R.World.links(w),links))

def transferWith(+w: R.World,+next: R.World,+id: Nat,profile: P.Profile<w,id>,+nodes: {R.World.nodes(next) == R.World.nodes(w) : List<&2,R.Node>},links: {R.World.links(next) == R.World.links(w) : List<&2,R.Link>},comparators: {R.World.comparators(next) == R.World.comparators(w) : List<&2,R.ComparatorBinding>},fault: {R.World.fault(next) == R.World.fault(w) : R.Fault},marked: {R.World.marked(next) == R.World.marked(w) : Bool},owner: {R.World.context(next) == R.World.context(w) : Nat},moved: Move.Rebased<w,next,P.path(w,id,profile)>) -> P.Profile<next,id>:
  match profile:
    case P.ProfileAt{oldPath,+extra,health,unmarked,valid,head,room,context,signal,ordinary,override,custom}:
      match moved:
        case Move.RebasedAt{+newPath,origin,depth}:
          +node = Equal.cong(List<&2,R.Node>,R.Node,rows=>B.get(R.Node,rows,id,B.blank_node()),R.World.nodes(next),R.World.nodes(w),nodes)
          P.ProfileAt{newPath,extra,
            Equal.trans(R.Fault,R.World.fault(next),R.World.fault(w),R.Healthy{},fault,health),
            Equal.trans(Bool,R.World.marked(next),R.World.marked(w),False{},marked,unmarked),
            Equal.trans(Bool,Nat.is_lt(id,B.length(R.Node,R.World.nodes(next))),Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))),True{},Equal.cong(List<&2,R.Node>,Bool,rows=>Nat.is_lt(id,B.length(R.Node,rows)),R.World.nodes(next),R.World.nodes(w),nodes),valid),
            Equal.trans(Nat,R.Node.subs(B.node(next,id)),R.Node.subs(B.node(w,id)),Path.origin(next,newPath),Equal.cong(R.Node,Nat,n=>R.Node.subs(n),B.node(next,id),B.node(w,id),node),Equal.trans(Nat,R.Node.subs(B.node(w,id)),Path.origin(w,oldPath),Path.origin(next,newPath),head,Equal.sym(Nat,Path.origin(next,newPath),Path.origin(w,oldPath),origin))),
            Equal.trans(Nat,B.budget(next),B.budget(w),Nat.add(Path.depth(next,newPath),extra),budget(w,next,nodes,links),Equal.trans(Nat,B.budget(w),Nat.add(Path.depth(w,oldPath),extra),Nat.add(Path.depth(next,newPath),extra),room,Equal.cong(Nat,Nat,n=>Nat.add(n,extra),Path.depth(w,oldPath),Path.depth(next,newPath),Equal.sym(Nat,Path.depth(next,newPath),Path.depth(w,oldPath),depth)))),
            Equal.trans(Nat,R.World.context(next),R.World.context(w),0n,owner,context),
            Equal.trans(R.NodeKind,R.Node.kind(B.node(next,id)),R.Node.kind(B.node(w,id)),R.Signal{},Equal.cong(R.Node,R.NodeKind,n=>R.Node.kind(n),B.node(next,id),B.node(w,id),node),signal),
            Equal.trans(Bool,B.has(R.Node.config(B.node(next,id)),K.CONFIG_HELD()),B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),False{},Equal.cong(R.Node,Bool,n=>B.has(R.Node.config(n),K.CONFIG_HELD()),B.node(next,id),B.node(w,id),node),ordinary),
            Equal.trans(Bool,B.has(R.Node.config(B.node(next,id)),K.CONFIG_OVERRIDE()),B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()),False{},Equal.cong(R.Node,Bool,n=>B.has(R.Node.config(n),K.CONFIG_OVERRIDE()),B.node(next,id),B.node(w,id),node),override),
            Equal.trans(Nat,Equality.custom(next,id),Equality.custom(w,id),0n,Equal.cong(List<&2,R.ComparatorBinding>,Nat,rows=>Equality.find(rows,id),R.World.comparators(next),R.World.comparators(w),comparators),custom)}

def transfer(+w: R.World,+next: R.World,+id: Nat,+profile: P.Profile<w,id>,nodes: {R.World.nodes(next) == R.World.nodes(w) : List<&2,R.Node>},+links: {R.World.links(next) == R.World.links(w) : List<&2,R.Link>},comparators: {R.World.comparators(next) == R.World.comparators(w) : List<&2,R.ComparatorBinding>},fault: {R.World.fault(next) == R.World.fault(w) : R.Fault},marked: {R.World.marked(next) == R.World.marked(w) : Bool},owner: {R.World.context(next) == R.World.context(w) : Nat}) -> P.Profile<next,id>:
  transferWith(w,next,id,profile,nodes,links,comparators,fault,marked,owner,Move.move(w,next,P.path(w,id,profile),links))

def move(-w: R.World,-next: R.World,-id: Nat,same: {w == next : R.World},profile: P.Profile<w,id>) -> P.Profile<next,id>:
  %same : P.Profile<_,id>
  profile
