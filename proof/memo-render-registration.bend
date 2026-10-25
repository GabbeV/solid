# Complete construction of fresh source membership from real default node
# constructors/linking and initial reserved arenas. Callback evaluation and
# status/flight-controller reachability are deliberately separate obligations.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/core.bend as Core
import ./memo-render-construction.bend as Pair
import ./memo-render-pending-context.bend as Context
import ./default-computed-construction.bend as N
import ./node-append-construction.bend as Append
import ./pending-command-history.bend as Commands
import ./graph-allocation-construction.bend as Shape
import ./pending-fresh-carrier.bend as Fresh
import ./pending-carrier-roundtrip.bend as RoundTrip
import ./pending-add-one-edge.bend as Add
import ./constructor-auxiliary-frame.bend as Aux
import ./bounded-core-return.bend as Return
import ./one-edge-settlement-return.bend as Settlement
import ./committed-storage-frame.bend as Frame

def registered(+w: R.World, +sourceExpr: R.Expr, effectExpr: R.Expr, target: Nat, program: Nat, cleanup: Nat) -> R.World:
  B.first(R.World, Bool, P.addPendingSource(Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup), N.index(Pair.memo(w, sourceExpr)), N.index(w)))

type Registered<-world: R.World, -root: Nat, -leaf: Nat, -edge: Nat> is Data:
  RegisteredReady{graph: Shape.OneEdge<world, root, leaf, edge>, member: {P.hasSource(world, leaf, root) == True{} : Bool}}


def member(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>},
  +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>},
  +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) -> {P.hasSource(registered(w, sourceExpr, effectExpr, target, program, cleanup), N.index(Pair.memo(w, sourceExpr)), N.index(w)) == True{} : Bool}:
  +q = Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup)
  +leaf = N.index(Pair.memo(w, sourceExpr))
  +context = Context.build(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena)
  +exts = Context.extensionArena(w, q, N.index(w), leaf, B.length(R.Link, links), extensions, context, extensionArena)
  +pending = Context.setArena(w, q, N.index(w), leaf, B.length(R.Link, links), sets, context, setArena)
  +graph = Context.graph(w, q, N.index(w), leaf, B.length(R.Link, links), context)
  +empty = Context.freshX(w, q, N.index(w), leaf, B.length(R.Link, links), context)
  +validLeaf = Commands.leafValid(q, N.index(w), leaf, B.length(R.Link, links), graph)
  Equal.trans(Bool, P.hasSource(registered(w, sourceExpr, effectExpr, target, program, cleanup), leaf, N.index(w)), P.hasSource(B.first(R.World, Bool, P.addPendingSource(q, leaf, 1n+B.length(R.Node, nodes))), leaf, 1n+B.length(R.Node, nodes)), True{}, Equal.cong(Nat, Bool, source => P.hasSource(B.first(R.World, Bool, P.addPendingSource(q, leaf, source)), leaf, source), N.index(w), 1n+B.length(R.Node, nodes), Append.positive(w, first, nodes, arena)), Fresh.contains(q, leaf, B.length(R.Node, nodes), extensions, sets, validLeaf, empty, exts, pending))


def prepare(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>},
  +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>},
  +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) -> Registered<registered(w, sourceExpr, effectExpr, target, program, cleanup), N.index(w), N.index(Pair.memo(w, sourceExpr)), B.length(R.Link, links)>:
  +graph = Pair.build(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena)
  RegisteredReady{Add.build(Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup), N.index(Pair.memo(w, sourceExpr)), N.index(w), N.index(w), N.index(Pair.memo(w, sourceExpr)), B.length(R.Link, links), graph), member(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena)}


def startReturn(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>},
  +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>},
  +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}, +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>) -> Return.Returned<Settlement.start(registered(w, sourceExpr, effectExpr, target, program, cleanup), N.index(w), rest, stack), rest, stack, 10n>:
  Add.startReturn(Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup), N.index(Pair.memo(w, sourceExpr)), N.index(w), N.index(w), N.index(Pair.memo(w, sourceExpr)), B.length(R.Link, links), rest, stack, Pair.build(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena))


def frame(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>},
  +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>},
  +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}, +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>) ->
  {Frame.observe(Return.world(Settlement.start(registered(w, sourceExpr, effectExpr, target, program, cleanup), N.index(w), rest, stack), rest, stack, 10n, startReturn(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena, rest, stack))) == Frame.observe(Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup)) : Frame.View}:
  Add.frame(Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup), N.index(Pair.memo(w, sourceExpr)), N.index(w), N.index(w), N.index(Pair.memo(w, sourceExpr)), B.length(R.Link, links), rest, stack, Pair.build(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena))


def retired(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>},
  +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>},
  +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {P.hasSource(RoundTrip.removed(Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup), N.index(Pair.memo(w, sourceExpr)), N.index(w)), N.index(Pair.memo(w, sourceExpr)), N.index(w)) == False{} : Bool}:
  +q = Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup)
  +leaf = N.index(Pair.memo(w, sourceExpr))
  +context = Context.build(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena)
  +exts = Context.extensionArena(w, q, N.index(w), leaf, B.length(R.Link, links), extensions, context, extensionArena)
  +pending = Context.setArena(w, q, N.index(w), leaf, B.length(R.Link, links), sets, context, setArena)
  +graph = Context.graph(w, q, N.index(w), leaf, B.length(R.Link, links), context)
  +empty = Context.freshX(w, q, N.index(w), leaf, B.length(R.Link, links), context)
  +validLeaf = Commands.leafValid(q, N.index(w), leaf, B.length(R.Link, links), graph)
  Equal.trans(Bool, P.hasSource(RoundTrip.removed(q, leaf, N.index(w)), leaf, N.index(w)), P.hasSource(RoundTrip.removed(q, leaf, 1n+B.length(R.Node, nodes)), leaf, 1n+B.length(R.Node, nodes)), False{}, Equal.cong(Nat, Bool, source => P.hasSource(RoundTrip.removed(q, leaf, source), leaf, source), N.index(w), 1n+B.length(R.Node, nodes), Append.positive(w, first, nodes, arena)), Fresh.retired(q, leaf, B.length(R.Node, nodes), extensions, sets, validLeaf, empty, exts, pending))
