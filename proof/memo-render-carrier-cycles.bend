# Actual default memo/render construction supplies the initial carrier-cycle
# invariant. Repeated command membership is proved before any Core settlement.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ./memo-render-construction.bend as Pair
import ./memo-render-pending-context.bend as Context
import ./default-computed-construction.bend as N
import ./pending-command-history.bend as Commands
import ./pending-carrier-state.bend as State
import ./pending-carrier-cycles.bend as Cycles
import ./node-append-construction.bend as Append

def seed(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>},
  +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>},
  +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) -> State.CarrierSnapshot<Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup), N.index(Pair.memo(w, sourceExpr)), B.length(R.Node, nodes)>:
  +q = Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup)
  +leaf = N.index(Pair.memo(w, sourceExpr))
  +context = Context.build(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena)
  +graph = Context.graph(w, q, N.index(w), leaf, B.length(R.Link, links), context)
  State.CarrierFresh{extensions, sets, Commands.leafValid(q, N.index(w), leaf, B.length(R.Link, links), graph), Context.freshX(w, q, N.index(w), leaf, B.length(R.Link, links), context), Context.extensionArena(w, q, N.index(w), leaf, B.length(R.Link, links), extensions, context, extensionArena), Context.setArena(w, q, N.index(w), leaf, B.length(R.Link, links), sets, context, setArena)}


def after(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>},
  +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>},
  +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}, +commands: List<&2, Commands.Command>) -> R.World:
  Cycles.executeWorld(N.index(Pair.memo(w, sourceExpr)), B.length(R.Node, nodes), commands, Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup))


def membership(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>},
  +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>},
  +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}, +commands: List<&2, Commands.Command>) ->
  {P.hasSource(after(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena, commands), N.index(Pair.memo(w, sourceExpr)), 1n+B.length(R.Node, nodes)) == Cycles.expected(commands, False{}) : Bool}:
  Cycles.worldMembership(N.index(Pair.memo(w, sourceExpr)), B.length(R.Node, nodes), commands, Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup), seed(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, extensions, sets, healthy, nullComputed, arena, linkArena, extensionArena, setArena))


def sourceIdentity(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +extensions: List<&2, R.NodeExtension>, +sets: List<&2, List<&2, Nat>>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>},
  +extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>},
  +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) -> {N.index(w) == 1n+B.length(R.Node, nodes) : Nat}:
  Append.positive(w, first, nodes, arena)
