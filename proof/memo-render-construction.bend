# Compose actual default memo and render-effect allocation with graph.link.
# Stops before eager callback execution and pending-flight registration.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/graph-state.bend as G
import ../runtime/core.bend as Core
import ../runtime/constants.bend as K
import ./default-computed-construction.bend as N
import ./graph-link-construction.bend as Linked
import ./graph-allocation-construction.bend as Shape
import ./transaction-arena.bend as Arithmetic
import ./pending-committed-history.bend as Logic
import ./node-append-construction.bend as Append
import ./bounded-core-return.bend as Return
import ./one-edge-settlement-return.bend as Settlement
import ./committed-storage-frame.bend as Frame
import ./graph-construction-frame.bend as GraphFrame

def memo(w: R.World, expr: R.Expr) -> R.World:
  N.source(w, expr, N.Memo{})

def allocated(w: R.World, sourceExpr: R.Expr, effectExpr: R.Expr, target: Nat, program: Nat, cleanup: Nat) -> R.World:
  N.source(memo(w, sourceExpr), effectExpr, N.Render{target, program, cleanup})

def linked(+w: R.World, +sourceExpr: R.Expr, effectExpr: R.Expr, target: Nat, program: Nat, cleanup: Nat) -> R.World:
  G.link(allocated(w, sourceExpr, effectExpr, target, program, cleanup), N.index(w), N.index(memo(w, sourceExpr)))

def rootNode(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +room: {Nat.is_lt(0n, N.index(w)) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  validRoot: {B.valid(memo(w, sourceExpr), N.index(w)) == True{} : Bool}) ->
  {B.node(allocated(w, sourceExpr, effectExpr, target, program, cleanup), N.index(w)) == N.record(w, sourceExpr, N.Memo{}) : R.Node}:
  +m = memo(w, sourceExpr)
  +roomM = N.zeroRoom(w, sourceExpr, N.Memo{}, room, nullComputed)
  +nullM = N.nullComputed(w, sourceExpr, N.Memo{}, room, nullComputed)
  +fits = Logic.andRight(Nat.is_ne(N.index(w), 0n), Nat.is_lt(N.index(w), N.index(m)), validRoot)
  Equal.trans(R.Node, B.node(allocated(w, sourceExpr, effectExpr, target, program, cleanup), N.index(w)), B.node(m, N.index(w)), N.record(w, sourceExpr, N.Memo{}), N.oldNode(m, effectExpr, N.Render{target, program, cleanup}, roomM, nullM, N.index(w), fits), N.node(w, sourceExpr, N.Memo{}, room, nullComputed))

def build(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  healthy: {B.ok(w) == True{} : Bool},
  +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>},
  linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}) ->
  Shape.OneEdge<linked(w, sourceExpr, effectExpr, target, program, cleanup), N.index(w), N.index(memo(w, sourceExpr)), B.length(R.Link, links)>:
  +room = Append.zeroRoom(w, first, nodes, arena)
  +m = memo(w, sourceExpr)
  +which = {N.Render{target, program, cleanup} : N.Family}
  +e = allocated(w, sourceExpr, effectExpr, target, program, cleanup)
  +roomM = N.zeroRoom(w, sourceExpr, N.Memo{}, room, nullComputed)
  +nullM = N.nullComputed(w, sourceExpr, N.Memo{}, room, nullComputed)
  +rootValid = N.fresh(w, sourceExpr, N.Memo{}, room, nullComputed, first, nodes, arena)
  +validRoot = N.oldValid(m, effectExpr, which, roomM, nullM, N.index(w), rootValid)
  +validLeaf = N.fresh(m, effectExpr, which, roomM, nullM, first, B.append(R.Node, nodes, [N.record(w, sourceExpr, N.Memo{})]), N.arena(w, sourceExpr, N.Memo{}, room, nullComputed, first, nodes, arena))
  +root = rootNode(w, sourceExpr, effectExpr, target, program, cleanup, room, nullComputed, rootValid)
  +leaf = N.node(m, effectExpr, which, roomM, nullM)
  +healthyE = Equal.trans(Bool, B.ok(e), B.ok(m), True{}, N.health(m, effectExpr, which, roomM, nullM), Equal.trans(Bool, B.ok(m), B.ok(w), True{}, N.health(w, sourceExpr, N.Memo{}, room, nullComputed), healthy))
  +different = Equal.trans(Bool, Nat.is_eq(N.index(m), N.index(w)), Nat.is_eq(Nat.add(N.index(w), 1n), N.index(w)), False{}, Equal.cong(Nat, Bool, id => Nat.is_eq(id, N.index(w)), N.index(m), Nat.add(N.index(w), 1n), N.count(w, sourceExpr, N.Memo{}, room, nullComputed)), Arithmetic.differentReverse(N.index(w), 0n))
  +arenaE = Equal.trans(List<&2, R.Link>, R.World.links(e), R.World.links(m), firstLink <> links, N.links(m, effectExpr, which, roomM, nullM), Equal.trans(List<&2, R.Link>, R.World.links(m), R.World.links(w), firstLink <> links, N.links(w, sourceExpr, N.Memo{}, room, nullComputed), linkArena))
  Linked.build(e, N.index(w), N.index(m), firstLink, links, healthyE, validRoot, validLeaf, different,
    Equal.cong(R.Node, Nat, node => R.Node.subs(node), B.node(e, N.index(w)), N.record(w, sourceExpr, N.Memo{}), root),
    Equal.cong(R.Node, Nat, node => R.Node.subsTail(node), B.node(e, N.index(w)), N.record(w, sourceExpr, N.Memo{}), root),
    Equal.cong(R.Node, Nat, node => R.Node.deps(node), B.node(e, N.index(m)), N.record(m, effectExpr, which), leaf),
    Equal.cong(R.Node, Nat, node => R.Node.depsTail(node), B.node(e, N.index(m)), N.record(m, effectExpr, which), leaf),
    Equal.cong(R.Node, Nat, node => R.Node.subs(node), B.node(e, N.index(m)), N.record(m, effectExpr, which), leaf),
    Equal.cong(R.Node, Bool, node => B.has(R.Node.config(node), K.CONFIG_AUTO_DISPOSE()), B.node(e, N.index(m)), N.record(m, effectExpr, which), leaf), arenaE)


def startReturn(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>,
  healthy: {B.ok(w) == True{} : Bool}, nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}) ->
  Return.Returned<Settlement.start(linked(w, sourceExpr, effectExpr, target, program, cleanup), N.index(w), rest, stack), rest, stack, 10n>:
  Shape.startReturn(linked(w, sourceExpr, effectExpr, target, program, cleanup), N.index(w), N.index(memo(w, sourceExpr)), B.length(R.Link, links), rest, stack, build(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena))


def frame(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}) ->
  {Frame.observe(Return.world(Settlement.start(linked(w, sourceExpr, effectExpr, target, program, cleanup), N.index(w), rest, stack), rest, stack, 10n, startReturn(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, rest, stack, healthy, nullComputed, arena, linkArena))) == Frame.observe(allocated(w, sourceExpr, effectExpr, target, program, cleanup)) : Frame.View}:
  +room = Append.zeroRoom(w, first, nodes, arena)
  +m = memo(w, sourceExpr)
  +e = allocated(w, sourceExpr, effectExpr, target, program, cleanup)
  +q = linked(w, sourceExpr, effectExpr, target, program, cleanup)
  +which = {N.Render{target, program, cleanup} : N.Family}
  +roomM = N.zeroRoom(w, sourceExpr, N.Memo{}, room, nullComputed)
  +nullM = N.nullComputed(w, sourceExpr, N.Memo{}, room, nullComputed)
  +rootValid = N.fresh(w, sourceExpr, N.Memo{}, room, nullComputed, first, nodes, arena)
  +root = rootNode(w, sourceExpr, effectExpr, target, program, cleanup, room, nullComputed, rootValid)
  +leaf = N.node(m, effectExpr, which, roomM, nullM)
  +built = build(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena)
  Frame.compose(e, q, Return.world(Settlement.start(linked(w, sourceExpr, effectExpr, target, program, cleanup), N.index(w), rest, stack), rest, stack, 10n, startReturn(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, rest, stack, healthy, nullComputed, arena, linkArena)),
    Shape.returnedFrame(q, N.index(w), N.index(m), B.length(R.Link, links), rest, stack, built),
    GraphFrame.linked(e, N.index(w), N.index(m),
      Equal.cong(R.Node, Nat, node => R.Node.depsTail(node), B.node(e, N.index(m)), N.record(m, effectExpr, which), leaf),
      Equal.cong(R.Node, Nat, node => R.Node.deps(node), B.node(e, N.index(m)), N.record(m, effectExpr, which), leaf),
      Equal.cong(R.Node, Nat, node => R.Node.subsTail(node), B.node(e, N.index(w)), N.record(w, sourceExpr, N.Memo{}), root)))
