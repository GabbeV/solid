# Actual local pending status stores for every initial status word. Membership
# and stored-error identity remain separate contracts with arena prerequisites.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/status.bend as A
import ../runtime/constants.bend as K
import ./pending-notification-operations.bend as Notify
import ../runtime/pending-state.bend as P
import ./node-status-frame.bend as Status
import ./node-observation-lens.bend as Lens
import ./pending-source-status-frame.bend as Pending
import ./pending-add-frame.bend as Choice
import ./pending-add-preservation.bend as Added
import ./pending-add-storage.bend as StorageAux
import ./graph-allocation-properties.bend as Storage
import ./natural-logic.bend as Logic
import ./node-store-lookup.bend as Store
import ./word-mask-laws.bend as WordMasks


def shown(+w: R.World,+node: Nat,show: Bool) -> R.World:
  B.choose(~R.World,show,_=>B.store_extension(w,node,R.NodeExtension.with_shownError(B.extension(w,node),R.NodeExtension.error(B.extension(w,node)))),_=>w)

def prepared(+w: R.World,+node: Nat,source: Nat,show: Bool) -> R.World:
  B.first(R.World,Bool,P.addPendingSource(shown(w,node,show),node,1n+source))

def shownStatuses(+w: R.World,+node: Nat,+show: Bool) -> {Status.observe(shown(w,node,show)) == Status.observe(w) : List<&2,U32>}:
  Choice.choice(List<&2,U32>,state=>Status.observe(state),show,w,B.store_extension(w,node,R.NodeExtension.with_shownError(B.extension(w,node),R.NodeExtension.error(B.extension(w,node)))),w,Status.extension(w,node,R.NodeExtension.with_shownError(B.extension(w,node),R.NodeExtension.error(B.extension(w,node)))),{==})

def preparedStatuses(+w: R.World,+node: Nat,+source: Nat,+show: Bool) -> {Status.observe(prepared(w,node,source,show)) == Status.observe(w) : List<&2,U32>}:
  Equal.trans(List<&2,U32>,Status.observe(prepared(w,node,source,show)),Status.observe(shown(w,node,show)),Status.observe(w),Status.added(shown(w,node,show),node,1n+source),shownStatuses(w,node,show))

def shownStorage(+w: R.World,+node: Nat,+show: Bool) -> {Storage.storage(shown(w,node,show)) == Storage.storage(w) : Storage.Storage}:
  Choice.choice(Storage.Storage,state=>Storage.storage(state),show,w,B.store_extension(w,node,R.NodeExtension.with_shownError(B.extension(w,node),R.NodeExtension.error(B.extension(w,node)))),w,StorageAux.storeExtension(w,node,R.NodeExtension.with_shownError(B.extension(w,node),R.NodeExtension.error(B.extension(w,node)))),{==})

def preparedStorage(+w: R.World,+node: Nat,+source: Nat,+show: Bool) -> {Storage.storage(prepared(w,node,source,show)) == Storage.storage(w) : Storage.Storage}:
  Storage.compose(w,shown(w,node,show),prepared(w,node,source,show),Added.storage(shown(w,node,show),node,1n+source),shownStorage(w,node,show))


def nodeRoom(+w: R.World,+node: Nat,valid: {B.valid(w,node) == True{} : Bool}) -> {Nat.is_lt(node,B.length(R.Node,R.World.nodes(w))) == True{} : Bool}:
  Logic.andRight(Nat.is_ne(node,0n),Nat.is_lt(node,B.length(R.Node,R.World.nodes(w))),valid)

def validAfter(+w: R.World,+next: R.World,+node: Nat,same: {Storage.storage(next) == Storage.storage(w) : Storage.Storage},known: {B.valid(w,node) == True{} : Bool}) -> {B.valid(next,node) == True{} : Bool}:
  Equal.trans(Bool,B.valid(next,node),B.valid(w,node),True{},Equal.cong(Storage.Storage,Bool,view=>Bool.and(Nat.is_ne(node,0n),Nat.is_lt(node,Storage.count(view))),Storage.storage(next),Storage.storage(w),same),known)


def finishStatus(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,valid: {B.valid(w,node) == True{} : Bool}) -> {R.Node.status(B.node(Notify.finish(w,node,source,serial),node)) == Status.select(R.Node.status(B.node(w,node))) : U32}:
  +next = Notify.statused(w,node)
  Equal.trans(U32,R.Node.status(B.node(Notify.finish(w,node,source,serial),node)),R.Node.status(B.node(next,node)),Status.select(R.Node.status(B.node(w,node))),Lens.readWorld(U32,Status.project,next,Notify.finish(w,node,source,serial),node,Pending.setError(next,node,1n+source,Notify.error(serial,source))),Equal.trans(U32,R.Node.status(B.node(next,node)),R.Node.status(R.Node.with_status(B.node(w,node),Notify.flags(w,node))),Status.select(R.Node.status(B.node(w,node))),Equal.cong(R.Node,U32,n=>R.Node.status(n),B.node(next,node),R.Node.with_status(B.node(w,node),Notify.flags(w,node)),Store.nodeSame(w,node,R.Node.with_status(B.node(w,node),Notify.flags(w,node)),nodeRoom(w,node,valid))),Notify.statusField(B.node(w,node),Notify.flags(w,node))))


def choiceStatus(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+show: Bool,valid: {B.valid(w,node) == True{} : Bool}) -> {R.Node.status(B.node(Notify.choice(w,node,source,serial,show),node)) == Status.select(R.Node.status(B.node(w,node))) : U32}:
  +next = prepared(w,node,source,show)
  Equal.trans(U32,R.Node.status(B.node(Notify.choice(w,node,source,serial,show),node)),Status.select(R.Node.status(B.node(next,node))),Status.select(R.Node.status(B.node(w,node))),finishStatus(next,node,source,serial,validAfter(w,next,node,preparedStorage(w,node,source,show),valid)),Equal.cong(U32,U32,status=>Status.select(status),R.Node.status(B.node(next,node)),R.Node.status(B.node(w,node)),Lens.readWorld(U32,Status.project,w,next,node,preparedStatuses(w,node,source,show))))


def selected(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,valid: {B.valid(w,node) == True{} : Bool}) -> {R.Node.status(B.node(Notify.notified(w,node,source,serial),node)) == Status.select(R.Node.status(B.node(w,node))) : U32}:
  choiceStatus(w,node,source,serial,B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()),valid)

def classified(+flags: U32,missing: Bool) -> U32:
  B.set(K.STATUS_PENDING(),B.choose(~U32,missing,_=>K.STATUS_UNINITIALIZED(),_=>U32.and(flags,K.STATUS_UNINITIALIZED())))

def classifiedPendingMask(+flags: U32,+missing: Bool) -> {U32.and(classified(flags,missing),K.STATUS_PENDING()) == K.STATUS_PENDING() : U32}:
  match missing:
    case False{}: WordMasks.carryPendingMask(flags)
    case True{}: {==}

def classifiedErrorMask(+flags: U32,+missing: Bool) -> {U32.and(classified(flags,missing),K.STATUS_ERROR()) == 0 : U32}:
  match missing:
    case False{}: WordMasks.carryErrorMask(flags)
    case True{}: {==}

def selectedPending(+flags: U32) -> {B.has(Status.select(flags),K.STATUS_PENDING()) == True{} : Bool}:
  Equal.cong(U32,Bool,mask=>U32.is_ne(mask,0),U32.and(Status.select(flags),K.STATUS_PENDING()),K.STATUS_PENDING(),classifiedPendingMask(flags,B.has(flags,K.STATUS_NO_VALUE())))

def selectedError(+flags: U32) -> {B.has(Status.select(flags),K.STATUS_ERROR()) == False{} : Bool}:
  Equal.cong(U32,Bool,mask=>U32.is_ne(mask,0),U32.and(Status.select(flags),K.STATUS_ERROR()),0,classifiedErrorMask(flags,B.has(flags,K.STATUS_NO_VALUE())))

def pending(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,valid: {B.valid(w,node) == True{} : Bool}) -> {B.has(R.Node.status(B.node(Notify.notified(w,node,source,serial),node)),K.STATUS_PENDING()) == True{} : Bool}:
  Equal.trans(Bool,B.has(R.Node.status(B.node(Notify.notified(w,node,source,serial),node)),K.STATUS_PENDING()),B.has(Status.select(R.Node.status(B.node(w,node))),K.STATUS_PENDING()),True{},Equal.cong(U32,Bool,flags=>B.has(flags,K.STATUS_PENDING()),R.Node.status(B.node(Notify.notified(w,node,source,serial),node)),Status.select(R.Node.status(B.node(w,node))),selected(w,node,source,serial,valid)),selectedPending(R.Node.status(B.node(w,node))))

def errorCleared(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,valid: {B.valid(w,node) == True{} : Bool}) -> {B.has(R.Node.status(B.node(Notify.notified(w,node,source,serial),node)),K.STATUS_ERROR()) == False{} : Bool}:
  Equal.trans(Bool,B.has(R.Node.status(B.node(Notify.notified(w,node,source,serial),node)),K.STATUS_ERROR()),B.has(Status.select(R.Node.status(B.node(w,node))),K.STATUS_ERROR()),False{},Equal.cong(U32,Bool,flags=>B.has(flags,K.STATUS_ERROR()),R.Node.status(B.node(Notify.notified(w,node,source,serial),node)),Status.select(R.Node.status(B.node(w,node))),selected(w,node,source,serial,valid)),selectedError(R.Node.status(B.node(w,node))))
