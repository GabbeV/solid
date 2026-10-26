# Node-count, intrusive-link and fault footprint; local initial no-error case.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/extension.bend as E
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K
import ./pending-notification-operations.bend as N
import ./pending-notification-footprint.bend as Local
import ./pending-add-preservation.bend as Added
import ./pending-add-storage.bend as Aux
import ./graph-allocation-properties.bend as Storage


def finish(+w: R.World,+node: Nat,+source: Nat,+serial: Nat) -> {Storage.storage(N.finish(w,node,source,serial)) == Storage.storage(w) : Storage.Storage}:
  +written = N.statused(w,node)
  +grown = E.ext(written,node)
  +stored = B.store_extension(grown,node,R.NodeExtension.with_error(B.extension(grown,node),N.error(serial,source)))
  Equal.trans(Storage.Storage,Storage.storage(N.finish(w,node,source,serial)),Storage.storage(stored),Storage.storage(w),Equal.cong(R.World,Storage.Storage,state=>Storage.storage(state),N.finish(w,node,source,serial),stored,Local.provided(written,node,source,serial)),Storage.compose(w,written,stored,Storage.compose(written,grown,stored,Aux.storeExtension(grown,node,R.NodeExtension.with_error(B.extension(grown,node),N.error(serial,source))),Aux.ext(written,node)),Storage.nodeStorage(w,node,R.Node.with_status(B.node(w,node),N.flags(w,node)))))

def afterAdd(+w: R.World,+node: Nat,+source: Nat,+serial: Nat) -> {Storage.storage(N.finish(B.first(R.World,Bool,P.addPendingSource(w,node,1n+source)),node,source,serial)) == Storage.storage(w) : Storage.Storage}:
  +added = B.first(R.World,Bool,P.addPendingSource(w,node,1n+source))
  Storage.compose(w,added,N.finish(added,node,source,serial),finish(added,node,source,serial),Added.storage(w,node,1n+source))

def stored(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}) -> {Storage.storage(N.notified(w,node,source,serial)) == Storage.storage(w) : Storage.Storage}:
  Equal.trans(Storage.Storage,Storage.storage(N.notified(w,node,source,serial)),Storage.storage(N.finish(B.first(R.World,Bool,P.addPendingSource(w,node,1n+source)),node,source,serial)),Storage.storage(w),Equal.cong(R.World,Storage.Storage,state=>Storage.storage(state),N.notified(w,node,source,serial),N.finish(B.first(R.World,Bool,P.addPendingSource(w,node,1n+source)),node,source,serial),Local.localExact(w,node,source,serial,noError)),afterAdd(w,node,source,serial))

def healthy(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool},known: {B.ok(w) == True{} : Bool}) -> {B.ok(N.notified(w,node,source,serial)) == True{} : Bool}:
  Equal.trans(Bool,B.ok(N.notified(w,node,source,serial)),B.ok(w),True{},Equal.cong(Storage.Storage,Bool,view=>B.healthy(Storage.fault(view)),Storage.storage(N.notified(w,node,source,serial)),Storage.storage(w),stored(w,node,source,serial,noError)),known)


def shownStorage(+w: R.World,+node: Nat,+show: Bool) -> {Storage.storage(Local.shown(w,node,show)) == Storage.storage(w) : Storage.Storage}:
  match show:
    case False{}: {==}
    case True{}: Aux.storeExtension(w,node,R.NodeExtension.with_shownError(B.extension(w,node),R.NodeExtension.error(B.extension(w,node))))


def choiceStorage(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+show: Bool) -> {Storage.storage(N.choice(w,node,source,serial,show)) == Storage.storage(w) : Storage.Storage}:
  +first = Local.shown(w,node,show)
  Storage.compose(w,first,N.choice(w,node,source,serial,show),afterAdd(first,node,source,serial),shownStorage(w,node,show))

def allStored(+w: R.World,+node: Nat,+source: Nat,+serial: Nat) -> {Storage.storage(N.notified(w,node,source,serial)) == Storage.storage(w) : Storage.Storage}:
  choiceStorage(w,node,source,serial,B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()))

def allHealthy(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,known: {B.ok(w) == True{} : Bool}) -> {B.ok(N.notified(w,node,source,serial)) == True{} : Bool}:
  Equal.trans(Bool,B.ok(N.notified(w,node,source,serial)),B.ok(w),True{},Equal.cong(Storage.Storage,Bool,view=>B.healthy(Storage.fault(view)),Storage.storage(N.notified(w,node,source,serial)),Storage.storage(w),allStored(w,node,source,serial)),known)
