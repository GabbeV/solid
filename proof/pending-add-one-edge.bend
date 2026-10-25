# addPendingSource preserves a constructor-supplied graph certificate, including
# validity and health. This holds for duplicate/fresh-extension/fresh-Set paths.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/core.bend as Core
import ../runtime/constants.bend as K
import ./pending-add-preservation.bend as Preserved
import ./graph-allocation-properties.bend as Storage
import ./subscriber-topology-frame.bend as Topology
import ./graph-allocation-construction.bend as Shape
import ./bounded-core-return.bend as Return
import ./one-edge-settlement-return.bend as Settlement
import ./committed-storage-frame.bend as Frame

def result(+w: R.World, id: Nat, source: Nat) -> R.World:
  B.first(R.World, Bool, P.addPendingSource(w, id, source))

def valid(+w: R.World, +id: Nat, +source: Nat, +read: Nat, known: {B.valid(w, read) == True{} : Bool}) ->
  {B.valid(result(w, id, source), read) == True{} : Bool}:
  Equal.trans(Bool, B.valid(result(w, id, source), read), B.valid(w, read), True{},
    Equal.cong(Storage.Storage, Bool, view => Bool.and(Nat.is_ne(read, 0n), Nat.is_lt(read, Storage.count(view))), Storage.storage(result(w, id, source)), Storage.storage(w), Preserved.storage(w, id, source)), known)

def build(+w: R.World, +id: Nat, +source: Nat, +root: Nat, +leaf: Nat, +edge: Nat, shape: Shape.OneEdge<w, root, leaf, edge>) ->
  Shape.OneEdge<result(w, id, source), root, leaf, edge>:
  match shape:
    case Shape.OneEdgeReady{healthy, validRoot, validLeaf, head, selected, end, noSubscribers, noAuto}:
      +next = result(w, id, source)
      +rootSame = Topology.read(w, next, root, Preserved.topology(w, id, source))
      +leafSame = Topology.read(w, next, leaf, Preserved.topology(w, id, source))
      +link = Equal.cong(Topology.View, R.Link, view => B.get(R.Link, Topology.edges(view), 1n+edge, B.blank_link()), Topology.observe(next), Topology.observe(w), Preserved.topology(w, id, source))
      Shape.OneEdgeReady{
        Equal.trans(Bool, B.ok(next), B.ok(w), True{}, Equal.cong(Storage.Storage, Bool, view => B.healthy(Storage.fault(view)), Storage.storage(next), Storage.storage(w), Preserved.storage(w, id, source)), healthy),
        valid(w, id, source, root, validRoot), valid(w, id, source, leaf, validLeaf),
        Equal.trans(Nat, R.Node.subs(B.node(next, root)), R.Node.subs(B.node(w, root)), 1n+edge, Equal.cong(Topology.Shape, Nat, view => Shape.subscribers(view), Topology.shape(B.node(next, root)), Topology.shape(B.node(w, root)), rootSame), head),
        Equal.trans(Nat, R.Link.sub(B.link(next, 1n+edge)), R.Link.sub(B.link(w, 1n+edge)), leaf, Equal.cong(R.Link, Nat, record => R.Link.sub(record), B.link(next, 1n+edge), B.link(w, 1n+edge), link), selected),
        Equal.trans(Nat, R.Link.nextSub(B.link(next, 1n+edge)), R.Link.nextSub(B.link(w, 1n+edge)), 0n, Equal.cong(R.Link, Nat, record => R.Link.nextSub(record), B.link(next, 1n+edge), B.link(w, 1n+edge), link), end),
        Equal.trans(Nat, R.Node.subs(B.node(next, leaf)), R.Node.subs(B.node(w, leaf)), 0n, Equal.cong(Topology.Shape, Nat, view => Shape.subscribers(view), Topology.shape(B.node(next, leaf)), Topology.shape(B.node(w, leaf)), leafSame), noSubscribers),
        Equal.trans(Bool, B.has(R.Node.config(B.node(next, leaf)), K.CONFIG_AUTO_DISPOSE()), B.has(R.Node.config(B.node(w, leaf)), K.CONFIG_AUTO_DISPOSE()), False{}, Equal.cong(Topology.Shape, Bool, view => B.has(Shape.config(view), K.CONFIG_AUTO_DISPOSE()), Topology.shape(B.node(next, leaf)), Topology.shape(B.node(w, leaf)), leafSame), noAuto)}

def startReturn(+w: R.World, +id: Nat, +source: Nat, +root: Nat, +leaf: Nat, +edge: Nat, +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>, shape: Shape.OneEdge<w, root, leaf, edge>) ->
  Return.Returned<Settlement.start(result(w, id, source), root, rest, stack), rest, stack, 10n>:
  Shape.startReturn(result(w, id, source), root, leaf, edge, rest, stack, build(w, id, source, root, leaf, edge, shape))

def frame(+w: R.World, +id: Nat, +source: Nat, +root: Nat, +leaf: Nat, +edge: Nat, +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>, +shape: Shape.OneEdge<w, root, leaf, edge>) ->
  {Frame.observe(Return.world(Settlement.start(result(w, id, source), root, rest, stack), rest, stack, 10n, startReturn(w, id, source, root, leaf, edge, rest, stack, shape))) == Frame.observe(w) : Frame.View}:
  +next = result(w, id, source)
  Frame.compose(w, next, Return.world(Settlement.start(next, root, rest, stack), rest, stack, 10n, startReturn(w, id, source, root, leaf, edge, rest, stack, shape)), Shape.returnedFrame(next, root, leaf, edge, rest, stack, build(w, id, source, root, leaf, edge, shape)), Preserved.content(w, id, source))
