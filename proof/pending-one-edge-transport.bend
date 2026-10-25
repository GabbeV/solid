# Reusable transport from actual operation footprints to a graph certificate.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/constants.bend as K
import ./graph-allocation-properties.bend as Storage
import ./subscriber-topology-frame.bend as Topology
import ./graph-allocation-construction.bend as Shape

def valid(+w: R.World, +next: R.World, +read: Nat, same: {Storage.storage(next) == Storage.storage(w) : Storage.Storage}, known: {B.valid(w, read) == True{} : Bool}) ->
  {B.valid(next, read) == True{} : Bool}:
  Equal.trans(Bool, B.valid(next, read), B.valid(w, read), True{},
    Equal.cong(Storage.Storage, Bool, view => Bool.and(Nat.is_ne(read, 0n), Nat.is_lt(read, Storage.count(view))), Storage.storage(next), Storage.storage(w), same), known)

def build(+w: R.World, +next: R.World, +root: Nat, +leaf: Nat, +edge: Nat, +topology: {Topology.observe(next) == Topology.observe(w) : Topology.View}, +storage: {Storage.storage(next) == Storage.storage(w) : Storage.Storage}, shape: Shape.OneEdge<w, root, leaf, edge>) ->
  Shape.OneEdge<next, root, leaf, edge>:
  match shape:
    case Shape.OneEdgeReady{healthy, validRoot, validLeaf, head, selected, end, noSubscribers, noAuto}:
          +rootSame = Topology.read(w, next, root, topology)
      +leafSame = Topology.read(w, next, leaf, topology)
      +link = Equal.cong(Topology.View, R.Link, view => B.get(R.Link, Topology.edges(view), 1n+edge, B.blank_link()), Topology.observe(next), Topology.observe(w), topology)
      Shape.OneEdgeReady{
        Equal.trans(Bool, B.ok(next), B.ok(w), True{}, Equal.cong(Storage.Storage, Bool, view => B.healthy(Storage.fault(view)), Storage.storage(next), Storage.storage(w), storage), healthy),
        valid(w, next, root, storage, validRoot), valid(w, next, leaf, storage, validLeaf),
        Equal.trans(Nat, R.Node.subs(B.node(next, root)), R.Node.subs(B.node(w, root)), 1n+edge, Equal.cong(Topology.Shape, Nat, view => Shape.subscribers(view), Topology.shape(B.node(next, root)), Topology.shape(B.node(w, root)), rootSame), head),
        Equal.trans(Nat, R.Link.sub(B.link(next, 1n+edge)), R.Link.sub(B.link(w, 1n+edge)), leaf, Equal.cong(R.Link, Nat, record => R.Link.sub(record), B.link(next, 1n+edge), B.link(w, 1n+edge), link), selected),
        Equal.trans(Nat, R.Link.nextSub(B.link(next, 1n+edge)), R.Link.nextSub(B.link(w, 1n+edge)), 0n, Equal.cong(R.Link, Nat, record => R.Link.nextSub(record), B.link(next, 1n+edge), B.link(w, 1n+edge), link), end),
        Equal.trans(Nat, R.Node.subs(B.node(next, leaf)), R.Node.subs(B.node(w, leaf)), 0n, Equal.cong(Topology.Shape, Nat, view => Shape.subscribers(view), Topology.shape(B.node(next, leaf)), Topology.shape(B.node(w, leaf)), leafSame), noSubscribers),
        Equal.trans(Bool, B.has(R.Node.config(B.node(next, leaf)), K.CONFIG_AUTO_DISPOSE()), B.has(R.Node.config(B.node(w, leaf)), K.CONFIG_AUTO_DISPOSE()), False{}, Equal.cong(Topology.Shape, Bool, view => B.has(Shape.config(view), K.CONFIG_AUTO_DISPOSE()), Topology.shape(B.node(next, leaf)), Topology.shape(B.node(w, leaf)), leafSame), noAuto)}
