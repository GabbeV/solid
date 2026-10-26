# Observer-polymorphic footprint of the actual local pending store, including
# old-error capture. Runtime source is unchanged.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/extension.bend as E
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K
import ./pending-notification-operations.bend as N
import ./natural-logic.bend as Existing
import ./pending-add-frame.bend as Generic
import ./pending-add-preservation.bend as Added
import ./subscriber-topology-frame.bend as Topology
import ./topology-source-frame.bend as TopologySource

def shown(+w: R.World,+node: Nat,show: Bool) -> R.World:
  B.choose(~R.World,show,_=>B.store_extension(w,node,R.NodeExtension.with_shownError(B.extension(w,node),R.NodeExtension.error(B.extension(w,node)))),_=>w)

def prepared(+w: R.World,+node: Nat,source: Nat,show: Bool) -> R.World:
  B.first(R.World,Bool,P.addPendingSource(shown(w,node,show),node,1n+source))


def providedBranch(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+same: Bool) -> R.World:
  B.choose(~R.World,same,
    _=>B.store_extension(E.ext(w,node),node,R.NodeExtension.with_error(B.extension(E.ext(w,node),node),N.error(serial,source))),
    _=>P.preserveOrCreate(w,node,1n+source,R.NodeExtension.error(B.extension(w,node))))


def provided(+w: R.World,+node: Nat,+source: Nat,+serial: Nat) -> {P.setPendingError(w,node,1n+source,N.error(serial,source)) == B.store_extension(E.ext(w,node),node,R.NodeExtension.with_error(B.extension(E.ext(w,node),node),N.error(serial,source))) : R.World}:
  Equal.cong(Bool,R.World,same=>providedBranch(w,node,source,serial,same),Nat.is_eq(1n+source,1n+source),True{},Existing.self(1n+source))

def topologyFinish(+w: R.World,+node: Nat,+source: Nat,+serial: Nat) -> {Topology.observe(N.finish(w,node,source,serial)) == Topology.observe(w) : Topology.View}:
  +written = N.statused(w,node)
  +grown = E.ext(written,node)
  +stored = B.store_extension(grown,node,R.NodeExtension.with_error(B.extension(grown,node),N.error(serial,source)))
  Equal.trans(Topology.View,Topology.observe(N.finish(w,node,source,serial)),Topology.observe(stored),Topology.observe(w),Equal.cong(R.World,Topology.View,state=>Topology.observe(state),N.finish(w,node,source,serial),stored,provided(written,node,source,serial)),Equal.trans(Topology.View,Topology.observe(stored),Topology.observe(grown),Topology.observe(w),Topology.storeExtension(grown,node,R.NodeExtension.with_error(B.extension(grown,node),N.error(serial,source))),Equal.trans(Topology.View,Topology.observe(grown),Topology.observe(written),Topology.observe(w),TopologySource.ext(written,node),Topology.status(w,node,N.flags(w,node)))))

def afterAdd(+w: R.World,+node: Nat,+source: Nat,+serial: Nat) -> {Topology.observe(N.finish(B.first(R.World,Bool,P.addPendingSource(w,node,1n+source)),node,source,serial)) == Topology.observe(w) : Topology.View}:
  +added = B.first(R.World,Bool,P.addPendingSource(w,node,1n+source))
  Topology.compose(w,added,N.finish(added,node,source,serial),topologyFinish(added,node,source,serial),Added.topology(w,node,1n+source))

def localExact(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}) -> {N.notified(w,node,source,serial) == N.finish(B.first(R.World,Bool,P.addPendingSource(w,node,1n+source)),node,source,serial) : R.World}:
  Equal.cong(Bool,R.World,show=>N.choice(w,node,source,serial,show),B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()),False{},noError)

def topology(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,noError: {B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()) == False{} : Bool}) -> {Topology.observe(N.notified(w,node,source,serial)) == Topology.observe(w) : Topology.View}:
  Equal.trans(Topology.View,Topology.observe(N.notified(w,node,source,serial)),Topology.observe(N.finish(B.first(R.World,Bool,P.addPendingSource(w,node,1n+source)),node,source,serial)),Topology.observe(w),Equal.cong(R.World,Topology.View,state=>Topology.observe(state),N.notified(w,node,source,serial),N.finish(B.first(R.World,Bool,P.addPendingSource(w,node,1n+source)),node,source,serial),localExact(w,node,source,serial,noError)),afterAdd(w,node,source,serial))


def shownTopology(+w: R.World,+node: Nat,+show: Bool) -> {Topology.observe(shown(w,node,show)) == Topology.observe(w) : Topology.View}:
  match show:
    case False{}: {==}
    case True{}: Topology.storeExtension(w,node,R.NodeExtension.with_shownError(B.extension(w,node),R.NodeExtension.error(B.extension(w,node))))


def choiceTopology(+w: R.World,+node: Nat,+source: Nat,+serial: Nat,+show: Bool) -> {Topology.observe(N.choice(w,node,source,serial,show)) == Topology.observe(w) : Topology.View}:
  +first = shown(w,node,show)
  Topology.compose(w,first,N.choice(w,node,source,serial,show),afterAdd(first,node,source,serial),shownTopology(w,node,show))

def allTopology(+w: R.World,+node: Nat,+source: Nat,+serial: Nat) -> {Topology.observe(N.notified(w,node,source,serial)) == Topology.observe(w) : Topology.View}:
  choiceTopology(w,node,source,serial,B.has(R.Node.status(B.node(w,node)),K.STATUS_ERROR()))
