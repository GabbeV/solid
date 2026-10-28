# Rebuild a held-source certificate when the representative identity changes.
# Static heap facts and the four new group facts remain explicitly separate.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/constants.bend as K
import ../runtime/equality.bend as Equality
import ./held-write-profile.bend as P
import ./held-source-static.bend as View
import ./ordinary-profile-transport.bend as Budget
import ./subscriber-walk-step.bend as Path
import ./subscriber-path-transport.bend as Move

def allocatedRoom(+w: R.World,+next: R.World,+id: Nat,+same: {View.observe(next) == View.observe(w) : View.View},valid: {Nat.is_lt(R.Node.x(B.node(w,id)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool}) -> {Nat.is_lt(R.Node.x(B.node(next,id)),B.length(R.NodeExtension,R.World.extensions(next))) == True{} : Bool}:
  +pointer = Equal.cong(List<&2,R.Node>,Nat,rows=>R.Node.x(B.get(R.Node,rows,id,B.blank_node())),R.World.nodes(next),R.World.nodes(w),View.sameNodes(w,next,same))
  +slot = R.Node.x(B.node(w,id))
  Equal.trans(Bool,Nat.is_lt(R.Node.x(B.node(next,id)),B.length(R.NodeExtension,R.World.extensions(next))),Nat.is_lt(slot,B.length(R.NodeExtension,R.World.extensions(next))),True{},Equal.cong(Nat,Bool,at=>Nat.is_lt(at,B.length(R.NodeExtension,R.World.extensions(next))),R.Node.x(B.node(next,id)),slot,pointer),Equal.trans(Bool,Nat.is_lt(slot,B.length(R.NodeExtension,R.World.extensions(next))),Nat.is_lt(slot,B.length(R.NodeExtension,R.World.extensions(w))),True{},Equal.cong(Nat,Bool,n=>Nat.is_lt(slot,n),B.length(R.NodeExtension,R.World.extensions(next)),B.length(R.NodeExtension,R.World.extensions(w)),View.sameExtensionLength(w,next,same)),valid))

def renew(+w: R.World,+next: R.World,+id: Nat,+offset: Nat,+nextOffset: Nat,profile: P.Profile<w,id,offset>,+same: {View.observe(next) == View.observe(w) : View.View},moved: Move.Rebased<w,next,P.path(w,id,offset,profile)>,cacheNext: {R.NodeExtension.transaction(B.extension(next,id)) == 1n+nextOffset : Nat},futureNext: {R.World.flushTransaction(next) == 1n+nextOffset : Nat},terminalNext: {R.Transaction.into(B.transaction(next,1n+nextOffset)) == 0n : Nat},groupRoomNext: {Nat.is_lt(1n+nextOffset,B.length(R.Transaction,R.World.txArena(next))) == True{} : Bool}) -> P.Profile<next,id,nextOffset>:
  match profile:
    case P.HeldAt{oldPath,+extra,health,unmarked,valid,head,room,context,signal,held,override,custom,existing,extensionRoom,canonical,future,terminal,groupRoom}:
      match moved:
        case Move.RebasedAt{+nextPath,origin,depth}:
          +nodes = View.sameNodes(w,next,same)
          +node = Equal.cong(List<&2,R.Node>,R.Node,rows=>B.get(R.Node,rows,id,B.blank_node()),R.World.nodes(next),R.World.nodes(w),nodes)
          +pointer = Equal.cong(R.Node,Nat,n=>R.Node.x(n),B.node(next,id),B.node(w,id),node)
          +validNext = Equal.trans(Bool,Nat.is_lt(id,B.length(R.Node,R.World.nodes(next))),Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))),True{},Equal.cong(List<&2,R.Node>,Bool,rows=>Nat.is_lt(id,B.length(R.Node,rows)),R.World.nodes(next),R.World.nodes(w),nodes),valid)
          P.HeldAt{nextPath,extra,
            Equal.trans(R.Fault,R.World.fault(next),R.World.fault(w),R.Healthy{},View.sameFault(w,next,same),health),
            Equal.trans(Bool,R.World.marked(next),R.World.marked(w),False{},View.sameMarked(w,next,same),unmarked),
            validNext,
            Equal.trans(Nat,R.Node.subs(B.node(next,id)),R.Node.subs(B.node(w,id)),Path.origin(next,nextPath),Equal.cong(R.Node,Nat,n=>R.Node.subs(n),B.node(next,id),B.node(w,id),node),Equal.trans(Nat,R.Node.subs(B.node(w,id)),Path.origin(w,oldPath),Path.origin(next,nextPath),head,Equal.sym(Nat,Path.origin(next,nextPath),Path.origin(w,oldPath),origin))),
            Equal.trans(Nat,B.budget(next),B.budget(w),Nat.add(Path.depth(next,nextPath),extra),Budget.budget(w,next,nodes,View.sameLinks(w,next,same)),Equal.trans(Nat,B.budget(w),Nat.add(Path.depth(w,oldPath),extra),Nat.add(Path.depth(next,nextPath),extra),room,Equal.cong(Nat,Nat,n=>Nat.add(n,extra),Path.depth(w,oldPath),Path.depth(next,nextPath),Equal.sym(Nat,Path.depth(next,nextPath),Path.depth(w,oldPath),depth)))),
            Equal.trans(Nat,R.World.context(next),R.World.context(w),0n,View.sameContext(w,next,same),context),
            Equal.trans(R.NodeKind,R.Node.kind(B.node(next,id)),R.Node.kind(B.node(w,id)),R.Signal{},Equal.cong(R.Node,R.NodeKind,n=>R.Node.kind(n),B.node(next,id),B.node(w,id),node),signal),
            Equal.trans(Bool,B.has(R.Node.config(B.node(next,id)),K.CONFIG_HELD()),B.has(R.Node.config(B.node(w,id)),K.CONFIG_HELD()),True{},Equal.cong(R.Node,Bool,n=>B.has(R.Node.config(n),K.CONFIG_HELD()),B.node(next,id),B.node(w,id),node),held),
            Equal.trans(Bool,B.has(R.Node.config(B.node(next,id)),K.CONFIG_OVERRIDE()),B.has(R.Node.config(B.node(w,id)),K.CONFIG_OVERRIDE()),False{},Equal.cong(R.Node,Bool,n=>B.has(R.Node.config(n),K.CONFIG_OVERRIDE()),B.node(next,id),B.node(w,id),node),override),
            Equal.trans(Nat,Equality.custom(next,id),Equality.custom(w,id),0n,Equal.cong(List<&2,R.ComparatorBinding>,Nat,rows=>Equality.find(rows,id),R.World.comparators(next),R.World.comparators(w),View.sameComparators(w,next,same)),custom),
            Equal.trans(Bool,Nat.is_eq(R.Node.x(B.node(next,id)),0n),Nat.is_eq(R.Node.x(B.node(w,id)),0n),False{},Equal.cong(Nat,Bool,slot=>Nat.is_eq(slot,0n),R.Node.x(B.node(next,id)),R.Node.x(B.node(w,id)),pointer),existing),
            allocatedRoom(w,next,id,same,extensionRoom),
            cacheNext,futureNext,terminalNext,groupRoomNext}

def retarget(+w: R.World,+next: R.World,+id: Nat,+offset: Nat,+nextOffset: Nat,+profile: P.Profile<w,id,offset>,+same: {View.observe(next) == View.observe(w) : View.View},cacheNext: {R.NodeExtension.transaction(B.extension(next,id)) == 1n+nextOffset : Nat},futureNext: {R.World.flushTransaction(next) == 1n+nextOffset : Nat},terminalNext: {R.Transaction.into(B.transaction(next,1n+nextOffset)) == 0n : Nat},groupRoomNext: {Nat.is_lt(1n+nextOffset,B.length(R.Transaction,R.World.txArena(next))) == True{} : Bool}) -> P.Profile<next,id,nextOffset>:
  renew(w,next,id,offset,nextOffset,profile,same,Move.move(w,next,P.path(w,id,offset,profile),View.sameLinks(w,next,same)),cacheNext,futureNext,terminalNext,groupRoomNext)
