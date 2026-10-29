# Fresh extension allocation during holdNode is part of actual parking. No
# allocated-cache or post-holding node premise is assumed.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../runtime/extension.bend as E
import ../runtime/scheduler.bend as S
import ../runtime/constants.bend as K
import ../proof/held-node-listing.bend as Listing
import ../proof/transaction-list-construction.bend as Listed
import ../proof/pending-fresh-extension.bend as Ext
import ../proof/extension-laws.bend as Extension
import ../proof/node-store-lookup.bend as Lens
import ../proof/held-park-leaf.bend as Parking
import ../proof/held-frame-leaf.bend as Leaf

def extended(w: R.World,+id: Nat) -> R.World:
  E.ext(Listing.configured(w,id),id)

def configuredRoom(+w: R.World,+id: Nat,valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool}) -> {Nat.is_lt(id,B.length(R.Node,R.World.nodes(Listing.configured(w,id)))) == True{} : Bool}:
  Equal.trans(Bool,Nat.is_lt(id,B.length(R.Node,R.World.nodes(Listing.configured(w,id)))),Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))),True{},Equal.cong(Nat,Bool,n=>Nat.is_lt(id,n),B.length(R.Node,R.World.nodes(Listing.configured(w,id))),B.length(R.Node,R.World.nodes(w)),Lens.nodeLength(w,id,Listing.record(w,id))),valid)

def configuredFresh(+w: R.World,+id: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},fresh: {R.Node.x(B.node(w,id)) == 0n : Nat}) -> {R.Node.x(B.node(Listing.configured(w,id),id)) == 0n : Nat}:
  Equal.trans(Nat,R.Node.x(B.node(Listing.configured(w,id),id)),R.Node.x(Listing.record(w,id)),0n,Equal.cong(R.Node,Nat,n=>R.Node.x(n),B.node(Listing.configured(w,id),id),Listing.record(w,id),Listing.node(w,id,valid)),Equal.trans(Nat,R.Node.x(Listing.record(w,id)),R.Node.x(B.node(w,id)),0n,Listing.configX(B.node(w,id),B.set(R.Node.config(B.node(w,id)),K.CONFIG_HELD())),fresh))

def defaults(+w: R.World,+id: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},fresh: {R.Node.x(B.node(w,id)) == 0n : Nat}) -> {B.extension(extended(w,id),id) == B.blank_extension() : R.NodeExtension}:
  +c = Listing.configured(w,id)
  Equal.trans(R.NodeExtension,B.extension(extended(w,id),id),B.extension(Extension.grow(c,id),id),B.blank_extension(),Equal.cong(R.World,R.NodeExtension,state=>B.extension(state,id),extended(w,id),Extension.grow(c,id),Ext.exact(c,id,configuredFresh(w,id,valid,fresh))),Ext.record(c,id,configuredRoom(w,id,valid)))

def unowned(+w: R.World,+id: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},fresh: {R.Node.x(B.node(w,id)) == 0n : Nat}) -> {R.NodeExtension.transaction(B.extension(extended(w,id),id)) == 0n : Nat}:
  Equal.cong(R.NodeExtension,Nat,x=>R.NodeExtension.transaction(x),B.extension(extended(w,id),id),B.blank_extension(),defaults(w,id,valid,fresh))

def start(+w: R.World,+id: Nat,+tx: Nat) -> {X.holdNode(w,id,tx) == Listed.afterExt(extended(w,id),id,tx,R.NodeExtension.transaction(B.extension(extended(w,id),id))) : R.World}:
  {==}

def actual(+w: R.World,+id: Nat,+offset: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},fresh: {R.Node.x(B.node(w,id)) == 0n : Nat}) -> {X.holdNode(w,id,1n+offset) == Listed.raw(extended(w,id),id,1n+offset) : R.World}:
  +e = extended(w,id)
  Equal.trans(R.World,X.holdNode(w,id,1n+offset),Listed.afterExt(e,id,1n+offset,R.NodeExtension.transaction(B.extension(e,id))),Listed.raw(e,id,1n+offset),start(w,id,1n+offset),Equal.cong(Nat,R.World,current=>Listed.afterExt(e,id,1n+offset,current),R.NodeExtension.transaction(B.extension(e,id)),0n,unowned(w,id,valid,fresh)))

def record(+w: R.World,+id: Nat) -> R.Node:
  R.Node.with_x(Listing.record(w,id),Ext.index(Listing.configured(w,id)))

def node(+w: R.World,+id: Nat,+offset: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},+fresh: {R.Node.x(B.node(w,id)) == 0n : Nat}) -> {B.node(X.holdNode(w,id,1n+offset),id) == record(w,id) : R.Node}:
  +c = Listing.configured(w,id)
  +e = extended(w,id)
  +grow = Extension.grow(c,id)
  +loaded = Equal.trans(R.Node,B.node(e,id),B.node(grow,id),record(w,id),Equal.cong(R.World,R.Node,state=>B.node(state,id),e,grow,Ext.exact(c,id,configuredFresh(w,id,valid,fresh))),Equal.trans(R.Node,B.node(grow,id),R.Node.with_x(B.node(c,id),Ext.index(c)),record(w,id),Ext.node(c,id,configuredRoom(w,id,valid)),Equal.cong(R.Node,R.Node,n=>R.Node.with_x(n,Ext.index(c)),B.node(c,id),Listing.record(w,id),Listing.node(w,id,valid))))
  Equal.trans(R.Node,B.node(X.holdNode(w,id,1n+offset),id),B.node(Listed.raw(e,id,1n+offset),id),record(w,id),Equal.cong(R.World,R.Node,state=>B.node(state,id),X.holdNode(w,id,1n+offset),Listed.raw(e,id,1n+offset),actual(w,id,offset,valid,fresh)),Equal.trans(R.Node,B.node(Listed.raw(e,id,1n+offset),id),B.node(e,id),record(w,id),Listed.nodeRaw(e,id,1n+offset,id),loaded))

def childX(+entry: R.Node,index: Nat) -> {R.Node.firstChild(R.Node.with_x(entry,index)) == R.Node.firstChild(entry) : Nat}:
  match entry:
    case R.Node{kind,value,pending,equals,old,flags,status,time,notified,deps,depsTail,depGen,subs,subsTail,height,nextHeap,prevHeap,parent,firstChild,nextSibling,prevSibling,expr,modified,prevValue,target,loading,x,parentComputed,scope,childCount,disposal,cleanup,effectProgram,returnedCleanup,errorProgram}: {==}

def child(+w: R.World,+id: Nat,+offset: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},+fresh: {R.Node.x(B.node(w,id)) == 0n : Nat},empty: {R.Node.firstChild(B.node(w,id)) == 0n : Nat}) -> {R.Node.firstChild(B.node(X.holdNode(w,id,1n+offset),id)) == 0n : Nat}:
  Equal.trans(Nat,R.Node.firstChild(B.node(X.holdNode(w,id,1n+offset),id)),R.Node.firstChild(record(w,id)),0n,Equal.cong(R.Node,Nat,n=>R.Node.firstChild(n),B.node(X.holdNode(w,id,1n+offset),id),record(w,id),node(w,id,offset,valid,fresh)),Equal.trans(Nat,R.Node.firstChild(record(w,id)),R.Node.firstChild(Listing.record(w,id)),0n,childX(Listing.record(w,id),Ext.index(Listing.configured(w,id))),Equal.trans(Nat,R.Node.firstChild(Listing.record(w,id)),R.Node.firstChild(B.node(w,id)),0n,Listing.configChild(B.node(w,id),B.set(R.Node.config(B.node(w,id)),K.CONFIG_HELD())),empty)))

def growEmpty(+w: R.World,+id: Nat) -> {List.is_empty(&2,R.Node,R.World.nodes(Extension.grow(w,id))) == List.is_empty(&2,R.Node,R.World.nodes(w)) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Listing.setEmpty(nodes,id,R.Node.with_x(B.get(R.Node,nodes,id,B.blank_node()),B.length(R.NodeExtension,extensions)))

def nonempty(+w: R.World,+id: Nat,+offset: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},+fresh: {R.Node.x(B.node(w,id)) == 0n : Nat}) -> {List.is_empty(&2,R.Node,R.World.nodes(X.holdNode(w,id,1n+offset))) == False{} : Bool}:
  +c = Listing.configured(w,id)
  +e = extended(w,id)
  +raw = Listed.raw(e,id,1n+offset)
  +grow = Extension.grow(c,id)
  +eEmpty = Equal.trans(Bool,List.is_empty(&2,R.Node,R.World.nodes(e)),List.is_empty(&2,R.Node,R.World.nodes(grow)),List.is_empty(&2,R.Node,R.World.nodes(c)),Equal.cong(R.World,Bool,state=>List.is_empty(&2,R.Node,R.World.nodes(state)),e,grow,Ext.exact(c,id,configuredFresh(w,id,valid,fresh))),growEmpty(c,id))
  +last = Equal.trans(Bool,List.is_empty(&2,R.Node,R.World.nodes(c)),List.is_empty(&2,R.Node,R.World.nodes(w)),False{},Listing.configuredEmpty(w,id),Parking.nonempty(R.World.nodes(w),id,valid))
  Equal.trans(Bool,List.is_empty(&2,R.Node,R.World.nodes(X.holdNode(w,id,1n+offset))),List.is_empty(&2,R.Node,R.World.nodes(raw)),False{},Equal.cong(R.World,Bool,state=>List.is_empty(&2,R.Node,R.World.nodes(state)),X.holdNode(w,id,1n+offset),raw,actual(w,id,offset,valid,fresh)),Equal.trans(Bool,List.is_empty(&2,R.Node,R.World.nodes(raw)),List.is_empty(&2,R.Node,R.World.nodes(e)),False{},Equal.cong(List<&2,R.Node>,Bool,rows=>List.is_empty(&2,R.Node,rows),R.World.nodes(raw),R.World.nodes(e),Listed.nodesRaw(e,id,1n+offset)),Equal.trans(Bool,List.is_empty(&2,R.Node,R.World.nodes(e)),List.is_empty(&2,R.Node,R.World.nodes(c)),False{},eEmpty,last)))

def frame(+w: R.World,+id: Nat,+offset: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},+fresh: {R.Node.x(B.node(w,id)) == 0n : Nat},empty: {R.Node.firstChild(B.node(w,id)) == 0n : Nat}) -> {X.holdFrame(X.holdNode(w,id,1n+offset),id,1n+offset) == X.holdNode(w,id,1n+offset) : R.World}:
  Leaf.leaf(X.holdNode(w,id,1n+offset),id,1n+offset,child(w,id,offset,valid,fresh,empty),nonempty(w,id,offset,valid,fresh))

# The original child/frame order is unchanged: first hold the node, then the
# conditional staged-child walk. A childless walk leaves the fresh cache intact.
def changed(+w: R.World,+id: Nat,+offset: Nat,+valid: {Nat.is_lt(id,B.length(R.Node,R.World.nodes(w))) == True{} : Bool},+fresh: {R.Node.x(B.node(w,id)) == 0n : Nat},empty: {R.Node.firstChild(B.node(w,id)) == 0n : Nat}) -> {S.parkChanged(w,id,1n+offset,True{}) == X.holdNode(w,id,1n+offset) : R.World}:
  +next = X.holdNode(w,id,1n+offset)
  Parking.conditionalFrame(B.has(R.Node.config(B.node(next,id)),K.CONFIG_STAGED()),next,id,1n+offset,frame(w,id,offset,valid,fresh,empty))
