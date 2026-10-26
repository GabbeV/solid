# Sole-source retirement and the actual settledStatus phase. The source's
# blocked enqueue/release tail is deliberately a later obligation.
import Base
import ../runtime/transaction.bend as X
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/pending.bend as Q
import ../runtime/constants.bend as K
import ./single-carrier-frame.bend as Single
import ./pending-carrier-state.bend as State
import ./pending-carrier-retirement.bend as Retire
import ./pending-carrier-arena.bend as Arena
import ./pending-fresh-set.bend as Fresh
import ./carrier-field-frame.bend as Field
import ./carrier-status-writes.bend as Writes
import ./node-store-lookup.bend as Store
import ./pending-fresh-carrier.bend as NodeRoom


type EmptyCarrier<-w: R.World,-node: Nat> is Data:
  EmptyCarrier{extension: Nat,sets: List<&2,List<&2,Nat>>,allocated: {R.Node.x(B.node(w,node)) == 1n+extension : Nat},room: {Nat.is_lt(R.Node.x(B.node(w,node)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool},pointer: {R.NodeExtension.pendingSources(B.extension(w,node)) == 0n : Nat},setArena: {R.World.pendingSets(w) == [] <> sets : List<&2,List<&2,Nat>>}}

def shift(-a: R.World,-b: R.World,-node: Nat,+same: {a == b : R.World},empty: EmptyCarrier<a,node>) -> EmptyCarrier<b,node>:
  match empty:
    case EmptyCarrier{extension,sets,allocated,room,pointer,setArena}:
      EmptyCarrier{extension,sets,State.shift_allocated(a,b,node,extension,same,allocated),State.shift_room(a,b,node,same,room),State.shift_emptyPointer(a,b,node,same,pointer),State.shift_setArena(a,b,sets,same,setArena)}

def move(+a: R.World,+b: R.World,+node: Nat,frame: Field.Frame<a,b,node>,empty: EmptyCarrier<a,node>) -> EmptyCarrier<b,node>:
  match frame empty:
    case Field.Frame{x,count,range,pending,storage} EmptyCarrier{extension,sets,allocated,room,pointer,setArena}:
      EmptyCarrier{extension,sets,Equal.trans(Nat,R.Node.x(B.node(b,node)),R.Node.x(B.node(a,node)),1n+extension,x,allocated),Equal.trans(Bool,Nat.is_lt(R.Node.x(B.node(b,node)),B.length(R.NodeExtension,R.World.extensions(b))),Nat.is_lt(R.Node.x(B.node(a,node)),B.length(R.NodeExtension,R.World.extensions(a))),True{},range,room),Equal.trans(Nat,R.NodeExtension.pendingSources(B.extension(b,node)),R.NodeExtension.pendingSources(B.extension(a,node)),0n,pending,pointer),Equal.trans(List<&2,List<&2,Nat>>,R.World.pendingSets(b),R.World.pendingSets(a),[] <> sets,storage,setArena)}

def retired(+w: R.World,+node: Nat,+source: Nat,single: Single.Single<w,node,source>) -> EmptyCarrier<State.removeWorld(w,node,source),node>:
  match single:
    case Single.Single{+extension,+set,+sets,+allocated,+room,+pointer,+slots,+setRoom,+setArena}:
      +next = Retire.retired(w,node,1n+set)
      +normal = {EmptyCarrier{extension,List.set(&2,List<&2,Nat>,sets,set,[0n]),Equal.trans(Nat,R.Node.x(B.node(next,node)),R.Node.x(B.node(w,node)),1n+extension,Arena.retiredX(w,node,set),allocated),Arena.retiredExtRoom(w,node,set,room),Retire.pointer(w,node,set,room),Arena.retiredArena(w,node,set,sets,setArena)} : EmptyCarrier<next,node>}
      shift(next,State.removeWorld(w,node,source),node,Equal.sym(R.World,State.removeWorld(w,node,source),next,Equal.cong(B.Bundle<R.World,Bool>,R.World,pair=>B.first(R.World,Bool,pair),P.removePendingSource(w,node,1n+source),B.Bundle{next,True{}},Retire.remove(w,node,source,set,pointer,slots))),normal)

def pointer(-w: R.World,-node: Nat,empty: EmptyCarrier<w,node>) -> {R.NodeExtension.pendingSources(B.extension(w,node)) == 0n : Nat}:
  match empty:
    case EmptyCarrier{extension,sets,allocated,room,pointer,setArena}: pointer

def allocated(-w: R.World,-node: Nat,empty: EmptyCarrier<w,node>) -> Nat:
  match empty:
    case EmptyCarrier{extension,sets,allocated,room,pointer,setArena}: extension

def allocatedKnown(-w: R.World,-node: Nat,+empty: EmptyCarrier<w,node>) -> {R.Node.x(B.node(w,node)) == 1n+allocated(w,node,empty) : Nat}:
  match empty:
    case EmptyCarrier{extension,sets,allocated,room,pointer,setArena}: allocated

def room(-w: R.World,-node: Nat,empty: EmptyCarrier<w,node>) -> {Nat.is_lt(R.Node.x(B.node(w,node)),B.length(R.NodeExtension,R.World.extensions(w))) == True{} : Bool}:
  match empty:
    case EmptyCarrier{extension,sets,allocated,room,pointer,setArena}: room

def absent(+w: R.World,+node: Nat,+source: Nat,empty: EmptyCarrier<w,node>) -> {P.hasSource(w,node,source) == False{} : Bool}:
  match empty:
    case EmptyCarrier{extension,sets,allocated,room,pointer,setArena}: Fresh.absent(w,node,source,pointer,Fresh.zero(w,sets,setArena))

def remaining(+w: R.World,+node: Nat,empty: EmptyCarrier<w,node>) -> {B.get(Nat,P.items(B.pendingSources(w,node)),0n,0n) == 0n : Nat}:
  Equal.cong(Nat,Nat,slot=>B.get(Nat,P.items(B.choose(~R.SourceSet,Nat.is_eq(slot,0n),_=>R.NoSources{},_=>R.Sources{B.pendingItems(w,slot)})),0n,0n),R.NodeExtension.pendingSources(B.extension(w,node)),0n,pointer(w,node,empty))

def statused(+w: R.World,+node: Nat) -> R.World:
  B.store_node(w,node,R.Node.with_status(B.node(w,node),B.clear(R.Node.status(B.node(w,node)),K.STATUS_PENDING())))

def cleared(+w: R.World,+node: Nat) -> R.World:
  +w = statused(w,node)
  B.store_extension(w,node,R.NodeExtension.with_error(B.extension(w,node),R.Null{}))

def zeroError(+w: R.World,+node: Nat,+empty: EmptyCarrier<w,node>) -> {P.setPendingError(w,node,0n,R.Undefined{}) == B.store_extension(w,node,R.NodeExtension.with_error(B.extension(w,node),R.Null{})) : R.World}:
  Equal.cong(Nat,R.World,x=>B.choose(~R.World,Nat.is_ne(x,0n),_=>B.store_extension(w,node,R.NodeExtension.with_error(B.extension(w,node),R.Null{})),_=>w),R.Node.x(B.node(w,node)),1n+allocated(w,node,empty),allocatedKnown(w,node,empty))

def statusEmpty(+w: R.World,+node: Nat,empty: EmptyCarrier<w,node>) -> EmptyCarrier<statused(w,node),node>:
  move(w,statused(w,node),node,Writes.status(w,node,B.clear(R.Node.status(B.node(w,node)),K.STATUS_PENDING())),empty)

def clearedEmpty(+w: R.World,+node: Nat,+empty: EmptyCarrier<w,node>) -> EmptyCarrier<cleared(w,node),node>:
  move(statused(w,node),cleared(w,node),node,Writes.error(statused(w,node),node,R.Null{},room(statused(w,node),node,statusEmpty(w,node,empty))),statusEmpty(w,node,empty))

def statusConfig(+record: R.Node,+flags: U32) -> {R.Node.config(R.Node.with_status(record,flags)) == R.Node.config(record) : U32}:
  match record:
    case R.Node{kind,value,pending,equals,config,flags,status,time,notified,deps,depsTail,depGen,subs,subsTail,height,nextHeap,prevHeap,parent,firstChild,nextSibling,prevSibling,expr,modified,prevValue,target,loading,x,parentComputed,scope,childCount,disposal,cleanup,effectProgram,returnedCleanup,errorProgram}: {==}

def clearedConfig(+w: R.World,+node: Nat,valid: {B.valid(w,node) == True{} : Bool}) -> {R.Node.config(B.node(cleared(w,node),node)) == R.Node.config(B.node(w,node)) : U32}:
  +next = statused(w,node)
  +record = R.Node.with_status(B.node(w,node),B.clear(R.Node.status(B.node(w,node)),K.STATUS_PENDING()))
  +errorRecord = R.NodeExtension.with_error(B.extension(next,node),R.Null{})
  Equal.trans(U32,R.Node.config(B.node(cleared(w,node),node)),R.Node.config(B.node(next,node)),R.Node.config(B.node(w,node)),Equal.cong(R.Node,U32,n=>R.Node.config(n),B.node(cleared(w,node),node),B.node(next,node),Writes.extensionNode(next,node,errorRecord,node)),Equal.trans(U32,R.Node.config(B.node(next,node)),R.Node.config(record),R.Node.config(B.node(w,node)),Equal.cong(R.Node,U32,n=>R.Node.config(n),B.node(next,node),record,Store.nodeSame(w,node,record,NodeRoom.nodeRoom(w,node,valid))),statusConfig(B.node(w,node),B.clear(R.Node.status(B.node(w,node)),K.STATUS_PENDING()))))

def statusBody(+w: R.World,+node: Nat,+held: Bool) -> R.World:
  B.choose(~R.World,held,_=>X.joinNode(w,node),_=>w)

def afterError(+w: R.World,+node: Nat) -> R.World:
  statusBody(w,node,B.has(R.Node.config(B.node(w,node)),K.CONFIG_HELD()))

def withoutHeld(+w: R.World,+node: Nat,noHeld: {B.has(R.Node.config(B.node(w,node)),K.CONFIG_HELD()) == False{} : Bool}) -> {afterError(w,node) == w : R.World}:
  Equal.cong(Bool,R.World,held=>statusBody(w,node,held),B.has(R.Node.config(B.node(w,node)),K.CONFIG_HELD()),False{},noHeld)

def clearedUnheld(+w: R.World,+node: Nat,+valid: {B.valid(w,node) == True{} : Bool},noHeld: {B.has(R.Node.config(B.node(w,node)),K.CONFIG_HELD()) == False{} : Bool}) -> {B.has(R.Node.config(B.node(cleared(w,node),node)),K.CONFIG_HELD()) == False{} : Bool}:
  Equal.trans(Bool,B.has(R.Node.config(B.node(cleared(w,node),node)),K.CONFIG_HELD()),B.has(R.Node.config(B.node(w,node)),K.CONFIG_HELD()),False{},Equal.cong(U32,Bool,flags=>B.has(flags,K.CONFIG_HELD()),R.Node.config(B.node(cleared(w,node),node)),R.Node.config(B.node(w,node)),clearedConfig(w,node,valid)),noHeld)

def exact(+w: R.World,+node: Nat,+empty: EmptyCarrier<w,node>,+valid: {B.valid(w,node) == True{} : Bool},noHeld: {B.has(R.Node.config(B.node(w,node)),K.CONFIG_HELD()) == False{} : Bool}) -> {Q.settledStatus(w,node,0n,False{}) == cleared(w,node) : R.World}:
  +after = P.setPendingError(statused(w,node),node,0n,R.Undefined{})
  Equal.trans(R.World,Q.settledStatus(w,node,0n,False{}),afterError(cleared(w,node),node),cleared(w,node),Equal.cong(R.World,R.World,state=>afterError(state,node),after,cleared(w,node),zeroError(statused(w,node),node,statusEmpty(w,node,empty))),withoutHeld(cleared(w,node),node,clearedUnheld(w,node,valid,noHeld)))

def settledEmpty(+w: R.World,+node: Nat,+empty: EmptyCarrier<w,node>,valid: {B.valid(w,node) == True{} : Bool},noHeld: {B.has(R.Node.config(B.node(w,node)),K.CONFIG_HELD()) == False{} : Bool}) -> EmptyCarrier<Q.settledStatus(w,node,0n,False{}),node>:
  shift(cleared(w,node),Q.settledStatus(w,node,0n,False{}),node,Equal.sym(R.World,Q.settledStatus(w,node,0n,False{}),cleared(w,node),exact(w,node,empty,valid,noHeld)),clearedEmpty(w,node,empty))
