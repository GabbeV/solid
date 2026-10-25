# Construct one-edge metadata from actual fresh graph allocation on allocated
# distinct nodes. No final head/link/health equation is an input premise.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/constants.bend as K
import ../runtime/core.bend as C
import ./graph-empty-allocation.bend as Allocation
import ./graph-allocation-properties.bend as Properties
import ./subscriber-topology-frame.bend as Shape
import ./pending-committed-history.bend as Logic
import ./one-edge-settlement-return.bend as Settlement
import ./bounded-core-return.bend as Return
import ./committed-storage-frame.bend as Frame

def rootHead(+w: R.World, +root: Nat, +leaf: Nat, room: {Nat.is_lt(root, B.length(R.Node, R.World.nodes(w))) == True{} : Bool}) ->
  {R.Node.subs(B.node(Allocation.source(w, root, leaf), root)) == Allocation.index(w) : Nat}:
  +next = Allocation.appended(w, root, leaf)
  +fits = Equal.trans(Bool, Nat.is_lt(root, B.length(R.Node, R.World.nodes(next))), Nat.is_lt(root, B.length(R.Node, R.World.nodes(w))), True{}, Equal.cong(Nat, Bool, size => Nat.is_lt(root, size), B.length(R.Node, R.World.nodes(next)), B.length(R.Node, R.World.nodes(w)), Properties.appendedCount(w, root, leaf)), room)
  Equal.trans(Nat, R.Node.subs(B.node(Allocation.source(w, root, leaf), root)), R.Node.subs(B.node(Allocation.writes(next, root, leaf, Allocation.index(w)), root)), Allocation.index(w),
    Equal.cong(R.World, Nat, state => R.Node.subs(B.node(state, root)), Allocation.source(w, root, leaf), Allocation.writes(next, root, leaf, Allocation.index(w)), Allocation.exact(w, root, leaf)), Properties.writesRoot(next, root, leaf, Allocation.index(w), fits))

def leafShape(+w: R.World, +root: Nat, +leaf: Nat, different: {Nat.is_eq(leaf, root) == False{} : Bool}) ->
  {Shape.shape(B.node(Allocation.source(w, root, leaf), leaf)) == Shape.shape(B.node(w, leaf)) : Shape.Shape}:
  +next = Allocation.appended(w, root, leaf)
  +last = Allocation.writes(next, root, leaf, Allocation.index(w))
  Equal.trans(Shape.Shape, Shape.shape(B.node(Allocation.source(w, root, leaf), leaf)), Shape.shape(B.node(last, leaf)), Shape.shape(B.node(w, leaf)),
    Equal.cong(R.World, Shape.Shape, state => Shape.shape(B.node(state, leaf)), Allocation.source(w, root, leaf), last, Allocation.exact(w, root, leaf)),
    Equal.trans(Shape.Shape, Shape.shape(B.node(last, leaf)), Shape.shape(B.node(next, leaf)), Shape.shape(B.node(w, leaf)), Properties.writesLeaf(next, root, leaf, Allocation.index(w), different), Equal.cong(R.Node, Shape.Shape, node => Shape.shape(node), B.node(next, leaf), B.node(w, leaf), Properties.appendedNode(w, root, leaf, leaf))))

def freshLink(+w: R.World, +root: Nat, +leaf: Nat) ->
  {B.link(Allocation.source(w, root, leaf), Allocation.index(w)) == Allocation.record(w, root, leaf) : R.Link}:
  +next = Allocation.appended(w, root, leaf)
  +last = Allocation.writes(next, root, leaf, Allocation.index(w))
  +unchanged = Equal.cong(Properties.Storage, R.Link, view => B.get(R.Link, Properties.links(view), Allocation.index(w), B.blank_link()), Properties.storage(last), Properties.storage(next), Properties.writesStorage(next, root, leaf, Allocation.index(w)))
  Equal.trans(R.Link, B.link(Allocation.source(w, root, leaf), Allocation.index(w)), B.link(last, Allocation.index(w)), Allocation.record(w, root, leaf),
    Equal.cong(R.World, R.Link, state => B.link(state, Allocation.index(w)), Allocation.source(w, root, leaf), last, Allocation.exact(w, root, leaf)),
    Equal.trans(R.Link, B.link(last, Allocation.index(w)), B.link(next, Allocation.index(w)), Allocation.record(w, root, leaf), unchanged, Properties.appendedLink(w, root, leaf)))

def health(+w: R.World, +root: Nat, +leaf: Nat) -> {B.ok(Allocation.source(w, root, leaf)) == B.ok(w) : Bool}:
  +next = Allocation.appended(w, root, leaf)
  +last = Allocation.writes(next, root, leaf, Allocation.index(w))
  Equal.trans(Bool, B.ok(Allocation.source(w, root, leaf)), B.ok(last), B.ok(w),
    Equal.cong(R.World, Bool, state => B.ok(state), Allocation.source(w, root, leaf), last, Allocation.exact(w, root, leaf)),
    Equal.trans(Bool, B.ok(last), B.ok(next), B.ok(w), Equal.cong(Properties.Storage, Bool, view => B.healthy(Properties.fault(view)), Properties.storage(last), Properties.storage(next), Properties.writesStorage(next, root, leaf, Allocation.index(w))), Properties.appendedHealth(w, root, leaf)))


def nodeCount(+w: R.World, +root: Nat, +leaf: Nat) ->
  {B.length(R.Node, R.World.nodes(Allocation.source(w, root, leaf))) == B.length(R.Node, R.World.nodes(w)) : Nat}:
  +next = Allocation.appended(w, root, leaf)
  +last = Allocation.writes(next, root, leaf, Allocation.index(w))
  Equal.trans(Nat, B.length(R.Node, R.World.nodes(Allocation.source(w, root, leaf))), B.length(R.Node, R.World.nodes(last)), B.length(R.Node, R.World.nodes(w)),
    Equal.cong(R.World, Nat, state => B.length(R.Node, R.World.nodes(state)), Allocation.source(w, root, leaf), last, Allocation.exact(w, root, leaf)),
    Equal.trans(Nat, B.length(R.Node, R.World.nodes(last)), B.length(R.Node, R.World.nodes(next)), B.length(R.Node, R.World.nodes(w)), Equal.cong(Properties.Storage, Nat, view => Properties.count(view), Properties.storage(last), Properties.storage(next), Properties.writesStorage(next, root, leaf, Allocation.index(w))), Properties.appendedCount(w, root, leaf)))

def valid(+w: R.World, +root: Nat, +leaf: Nat, +read: Nat, known: {B.valid(w, read) == True{} : Bool}) ->
  {B.valid(Allocation.source(w, root, leaf), read) == True{} : Bool}:
  Equal.trans(Bool, B.valid(Allocation.source(w, root, leaf), read), B.valid(w, read), True{},
    Equal.cong(Nat, Bool, size => Bool.and(Nat.is_ne(read, 0n), Nat.is_lt(read, size)), B.length(R.Node, R.World.nodes(Allocation.source(w, root, leaf))), B.length(R.Node, R.World.nodes(w)), nodeCount(w, root, leaf)), known)

def config(shape: Shape.Shape) -> U32:
  match shape:
    case Shape.Shape{kind, config, subscribers}: config

def subscribers(shape: Shape.Shape) -> Nat:
  match shape:
    case Shape.Shape{kind, config, subscribers}: subscribers

type OneEdge<-w: R.World, -root: Nat, -leaf: Nat, -edge: Nat> is Data:
  OneEdgeReady{healthy: {B.ok(w) == True{} : Bool}, validRoot: {B.valid(w, root) == True{} : Bool}, validLeaf: {B.valid(w, leaf) == True{} : Bool},
    head: {R.Node.subs(B.node(w, root)) == 1n+edge : Nat},
    selected: {R.Link.sub(B.link(w, 1n+edge)) == leaf : Nat},
    end: {R.Link.nextSub(B.link(w, 1n+edge)) == 0n : Nat},
    noSubscribers: {R.Node.subs(B.node(w, leaf)) == 0n : Nat},
    noAuto: {B.has(R.Node.config(B.node(w, leaf)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}}

def build(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat,
  healthy: {B.ok(w) == True{} : Bool}, +validRoot: {B.valid(w, root) == True{} : Bool}, validLeaf: {B.valid(w, leaf) == True{} : Bool},
  different: {Nat.is_eq(leaf, root) == False{} : Bool}, +positive: {Allocation.index(w) == 1n+edge : Nat},
  noSubscribers: {R.Node.subs(B.node(w, leaf)) == 0n : Nat}, noAuto: {B.has(R.Node.config(B.node(w, leaf)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  OneEdge<Allocation.source(w, root, leaf), root, leaf, edge>:
  +next = Allocation.source(w, root, leaf)
  +room = Logic.andRight(Nat.is_ne(root, 0n), Nat.is_lt(root, B.length(R.Node, R.World.nodes(w))), validRoot)
  +same = leafShape(w, root, leaf, different)
  +head = Equal.trans(Nat, R.Node.subs(B.node(next, root)), Allocation.index(w), 1n+edge, rootHead(w, root, leaf, room), positive)
  +link = Equal.trans(R.Link, B.link(next, 1n+edge), B.link(next, Allocation.index(w)), Allocation.record(w, root, leaf), Equal.cong(Nat, R.Link, index => B.link(next, index), 1n+edge, Allocation.index(w), Equal.sym(Nat, Allocation.index(w), 1n+edge, positive)), freshLink(w, root, leaf))
  +subscribers = Equal.trans(Nat, R.Node.subs(B.node(next, leaf)), R.Node.subs(B.node(w, leaf)), 0n, Equal.cong(Shape.Shape, Nat, shape => subscribers(shape), Shape.shape(B.node(next, leaf)), Shape.shape(B.node(w, leaf)), same), noSubscribers)
  +automatic = Equal.trans(Bool, B.has(R.Node.config(B.node(next, leaf)), K.CONFIG_AUTO_DISPOSE()), B.has(R.Node.config(B.node(w, leaf)), K.CONFIG_AUTO_DISPOSE()), False{}, Equal.cong(Shape.Shape, Bool, shape => B.has(config(shape), K.CONFIG_AUTO_DISPOSE()), Shape.shape(B.node(next, leaf)), Shape.shape(B.node(w, leaf)), same), noAuto)
  OneEdgeReady{Equal.trans(Bool, B.ok(next), B.ok(w), True{}, health(w, root, leaf), healthy), valid(w, root, leaf, root, validRoot), valid(w, root, leaf, leaf, validLeaf), head,
    Equal.cong(R.Link, Nat, record => R.Link.sub(record), B.link(next, 1n+edge), Allocation.record(w, root, leaf), link),
    Equal.cong(R.Link, Nat, record => R.Link.nextSub(record), B.link(next, 1n+edge), Allocation.record(w, root, leaf), link), subscribers, automatic}

def startReturn(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat, rest: List<&2, C.Task>, stack: List<&2, R.Value>, shape: OneEdge<w, root, leaf, edge>) ->
  Return.Returned<Settlement.start(w, root, rest, stack), rest, stack, 10n>:
  match shape:
    case OneEdgeReady{healthy, validRoot, validLeaf, head, selected, end, noSubscribers, noAuto}:
      Settlement.complete(w, edge, root, leaf, rest, stack, healthy, head, selected, end, noSubscribers, noAuto)

def returnedFrame(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +shape: OneEdge<w, root, leaf, edge>) ->
  {Frame.observe(Return.world(Settlement.start(w, root, rest, stack), rest, stack, 10n, startReturn(w, root, leaf, edge, rest, stack, shape))) == Frame.observe(w) : Frame.View}:
  match shape:
    case OneEdgeReady{healthy, validRoot, validLeaf, head, selected, end, noSubscribers, noAuto}:
      Settlement.frame(w, edge, root, leaf, rest, stack, healthy, head, selected, end, noSubscribers, noAuto)
