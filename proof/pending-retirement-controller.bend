# The actual settled/visitRemoved controllers retain the last-source PENDING
# clear through time stamping, enqueue, unblock and deferred-release collection.
# Faults, termination of later callbacks and final publication are separate.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending.bend as Q
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K
import ./pending-last-source.bend as Last
import ./pending-last-source-status.bend as Phase
import ./pending-tail-status.bend as Tail
import ./node-status-frame.bend as Status
import ./node-observation-lens.bend as Lens
import ./node-store-lookup.bend as Store
import ./carrier-status-writes.bend as Writes
import ./single-carrier-frame.bend as Single
import ./pending-carrier-state.bend as State


def timed(+w: R.World,+node: Nat) -> R.World:
  B.store_node(w,node,R.Node.with_time(B.node(w,node),R.World.clock(w)))

def validTimed(+w: R.World,+node: Nat,valid: {B.valid(w,node) == True{} : Bool}) -> {B.valid(timed(w,node),node) == True{} : Bool}:
  Equal.trans(Bool,B.valid(timed(w,node),node),B.valid(w,node),True{},Equal.cong(Nat,Bool,size=>Bool.and(Nat.is_ne(node,0n),Nat.is_lt(node,size)),B.length(R.Node,R.World.nodes(timed(w,node))),B.length(R.Node,R.World.nodes(w)),Store.nodeLength(w,node,R.Node.with_time(B.node(w,node),R.World.clock(w)))),valid)

def timedEmpty(+w: R.World,+node: Nat,empty: Last.EmptyCarrier<w,node>) -> Last.EmptyCarrier<timed(w,node),node>:
  Last.move(w,timed(w,node),node,Writes.time(w,node,R.World.clock(w)),empty)

def selectedTail(+w: R.World,+tasks: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+scheduled: Bool,+node: Nat,+root: Nat,+source: Nat,+last: Bool) -> {B.has(R.Node.status(B.node(Tail.world(Q.settledTail(w,tasks,visited,released,scheduled,node,root,source,last)),node)),K.STATUS_PENDING()) == B.has(R.Node.status(B.node(w,node)),K.STATUS_PENDING()) : Bool}:
  Equal.cong(U32,Bool,flags=>B.has(flags,K.STATUS_PENDING()),R.Node.status(B.node(Tail.world(Q.settledTail(w,tasks,visited,released,scheduled,node,root,source,last)),node)),R.Node.status(B.node(w,node)),Lens.readWorld(U32,Status.project,w,Tail.world(Q.settledTail(w,tasks,visited,released,scheduled,node,root,source,last)),node,Tail.tail(w,tasks,visited,released,scheduled,node,root,source,last)))

def settledCleared(+w: R.World,+tasks: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+scheduled: Bool,+node: Nat,+root: Nat,+source: Nat,empty: Last.EmptyCarrier<w,node>,valid: {B.valid(w,node) == True{} : Bool}) -> {B.has(R.Node.status(B.node(Tail.world(Q.settled(w,tasks,visited,released,scheduled,node,root,source)),node)),K.STATUS_PENDING()) == False{} : Bool}:
  +next = timed(w,node)
  +statused = Phase.afterEmpty(next,node)
  Equal.trans(Bool,B.has(R.Node.status(B.node(Tail.world(Q.settled(w,tasks,visited,released,scheduled,node,root,source)),node)),K.STATUS_PENDING()),B.has(R.Node.status(B.node(statused,node)),K.STATUS_PENDING()),False{},selectedTail(statused,tasks,node <> visited,released,scheduled,node,root,source,Nat.is_eq(Phase.remaining(next,node),0n)),Phase.emptyCleared(next,node,timedEmpty(w,node,empty),validTimed(w,node,valid)))

def removedCleared(+w: R.World,+tasks: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+scheduled: Bool,+node: Nat,+root: Nat,+source: Nat,+single: Single.Single<w,node,source>,valid: {B.valid(w,node) == True{} : Bool}) -> {B.has(R.Node.status(B.node(Tail.world(Q.visitRemoved(w,tasks,visited,released,scheduled,node,root,1n+source)),node)),K.STATUS_PENDING()) == False{} : Bool}:
  +next = State.removeWorld(w,node,source)
  +yes = Q.settled(next,tasks,visited,released,scheduled,node,root,1n+source)
  +no = Q.skip(next,tasks,visited,released,scheduled,node)
  Equal.trans(Bool,B.has(R.Node.status(B.node(Tail.world(Q.visitRemoved(w,tasks,visited,released,scheduled,node,root,1n+source)),node)),K.STATUS_PENDING()),B.has(R.Node.status(B.node(Tail.world(yes),node)),K.STATUS_PENDING()),False{},Equal.cong(Bool,Bool,removed=>B.has(R.Node.status(B.node(Tail.world(B.choose(~Q.Machine,removed,_=>yes,_=>no)),node)),K.STATUS_PENDING()),B.second(R.World,Bool,P.removePendingSource(w,node,1n+source)),True{},Phase.removalReported(w,node,source,single)),settledCleared(next,tasks,visited,released,scheduled,node,root,1n+source,Last.retired(w,node,source,single),Phase.validRemoved(w,node,source,valid)))
