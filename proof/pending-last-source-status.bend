# Actual sole-source removal supplies the zero remaining count. The subsequent
# status phase clears PENDING even through held joins; release/flush stay later.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending.bend as Q
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K
import ./pending-settlement-status.bend as Phase
import ./node-status-operations.bend as Status
import ./node-status-frame.bend as NodeStatus
import ./node-observation-lens.bend as Lens
import ./node-store-lookup.bend as Store
import ./pending-fresh-carrier.bend as Room
import ./word-mask-laws.bend as Word
import ./pending-last-source.bend as Last
import ./single-carrier-frame.bend as Single
import ./pending-carrier-state.bend as State
import ./pending-carrier-retirement.bend as Retire
import ./pending-removal-footprint.bend as Removal


def statusWritten(+record: R.Node,+status: U32) -> {R.Node.status(R.Node.with_status(record,status)) == status : U32}:
  match record:
    case R.Node{kind, value, pending, equals, config, flags, oldStatus, time, notified, deps, depsTail, depGen, subs, subsTail, height, nextHeap, prevHeap, parent, firstChild, nextSibling, prevSibling, expr, modified, prevValue, target, loading, x, parentComputed, scope, childCount, disposal, cleanup, effectProgram, returnedCleanup, errorProgram}:
      {==}

def selected(+w: R.World,+node: Nat,+errored: Bool,valid: {B.valid(w,node) == True{} : Bool}) -> {R.Node.status(B.node(Q.settledStatus(w,node,0n,errored),node)) == B.clear(R.Node.status(B.node(w,node)),K.STATUS_PENDING()) : U32}:
  +written = Phase.statused(w,node)
  +record = R.Node.with_status(B.node(w,node),B.clear(R.Node.status(B.node(w,node)),K.STATUS_PENDING()))
  Equal.trans(U32,R.Node.status(B.node(Q.settledStatus(w,node,0n,errored),node)),R.Node.status(B.node(written,node)),B.clear(R.Node.status(B.node(w,node)),K.STATUS_PENDING()),Lens.readWorld(U32,NodeStatus.project,written,Q.settledStatus(w,node,0n,errored),node,Phase.observed(w,node,0n,errored)),Equal.trans(U32,R.Node.status(B.node(written,node)),R.Node.status(record),B.clear(R.Node.status(B.node(w,node)),K.STATUS_PENDING()),Equal.cong(R.Node,U32,n=>R.Node.status(n),B.node(written,node),record,Store.nodeSame(w,node,record,Room.nodeRoom(w,node,valid))),statusWritten(B.node(w,node),B.clear(R.Node.status(B.node(w,node)),K.STATUS_PENDING()))))

def cleared(+w: R.World,+node: Nat,+errored: Bool,valid: {B.valid(w,node) == True{} : Bool}) -> {B.has(R.Node.status(B.node(Q.settledStatus(w,node,0n,errored),node)),K.STATUS_PENDING()) == False{} : Bool}:
  Equal.trans(Bool,B.has(R.Node.status(B.node(Q.settledStatus(w,node,0n,errored),node)),K.STATUS_PENDING()),B.has(B.clear(R.Node.status(B.node(w,node)),K.STATUS_PENDING()),K.STATUS_PENDING()),False{},Equal.cong(U32,Bool,flags=>B.has(flags,K.STATUS_PENDING()),R.Node.status(B.node(Q.settledStatus(w,node,0n,errored),node)),B.clear(R.Node.status(B.node(w,node)),K.STATUS_PENDING()),selected(w,node,errored,valid)),Word.clearPendingFalse(R.Node.status(B.node(w,node))))

def validRemoved(+w: R.World,+node: Nat,+source: Nat,valid: {B.valid(w,node) == True{} : Bool}) -> {B.valid(State.removeWorld(w,node,source),node) == True{} : Bool}:
  +removed = State.removeWorld(w,node,source)
  Equal.trans(Bool,B.valid(removed,node),B.valid(w,node),True{},Equal.cong(Removal.View,Bool,view=>Bool.and(Nat.is_ne(node,0n),Nat.is_lt(node,B.length(R.Node,Removal.nodes(view)))),Removal.observe(removed),Removal.observe(w),Removal.removed(w,node,1n+source)),valid)

def remaining(w: R.World,node: Nat) -> Nat:
  B.get(Nat,P.items(B.pendingSources(w,node)),0n,0n)

def afterEmpty(+w: R.World,+node: Nat) -> R.World:
  Q.settledStatus(w,node,remaining(w,node),B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()))

def emptyCleared(+w: R.World,+node: Nat,+empty: Last.EmptyCarrier<w,node>,+valid: {B.valid(w,node) == True{} : Bool}) -> {B.has(R.Node.status(B.node(afterEmpty(w,node),node)),K.STATUS_PENDING()) == False{} : Bool}:
  +errored = B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR())
  Equal.trans(Bool,B.has(R.Node.status(B.node(afterEmpty(w,node),node)),K.STATUS_PENDING()),B.has(R.Node.status(B.node(Q.settledStatus(w,node,0n,errored),node)),K.STATUS_PENDING()),False{},Equal.cong(Nat,Bool,count=>B.has(R.Node.status(B.node(Q.settledStatus(w,node,count,errored),node)),K.STATUS_PENDING()),remaining(w,node),0n,Last.remaining(w,node,empty)),cleared(w,node,errored,valid))

def afterRemoval(+w: R.World,+node: Nat,+source: Nat) -> R.World:
  afterEmpty(State.removeWorld(w,node,source),node)

def retiredCleared(+w: R.World,+node: Nat,+source: Nat,+single: Single.Single<w,node,source>,valid: {B.valid(w,node) == True{} : Bool}) -> {B.has(R.Node.status(B.node(afterRemoval(w,node,source),node)),K.STATUS_PENDING()) == False{} : Bool}:
  emptyCleared(State.removeWorld(w,node,source),node,Last.retired(w,node,source,single),validRemoved(w,node,source,valid))

def removalReported(+w: R.World,+node: Nat,+source: Nat,single: Single.Single<w,node,source>) -> {B.second(R.World,Bool,P.removePendingSource(w,node,1n+source)) == True{} : Bool}:
  match single:
    case Single.Single{extension,+set,sets,allocated,room,+pointer,+slots,setRoom,setArena}:
      Equal.cong(B.Bundle<R.World,Bool>,Bool,pair=>B.second(R.World,Bool,pair),P.removePendingSource(w,node,1n+source),B.Bundle{Retire.retired(w,node,1n+set),True{}},Retire.remove(w,node,source,set,pointer,slots))
