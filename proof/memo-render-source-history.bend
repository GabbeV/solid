# Actual default memo/render construction followed by arbitrary finite source
# registration/retirement choices along its edge. Callbacks/flush remain outside.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as Core
import ./memo-render-construction.bend as Pair
import ./default-computed-construction.bend as N
import ./pending-command-history.bend as Commands
import ./pending-source-history.bend as History
import ./bounded-core-return.bend as Return
import ./one-edge-settlement-return.bend as Settlement
import ./committed-storage-frame.bend as Frame

def programme(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>},
  +commands: List<&2, Commands.Command>) -> History.History<Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup)>:
  Commands.build(Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup), commands, N.index(w), N.index(Pair.memo(w, sourceExpr)), B.length(R.Link, links), Pair.build(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena))


def after(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>},
  +commands: List<&2, Commands.Command>) -> R.World:
  History.run(Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup), programme(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena, commands))


def startReturn(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>},
  +commands: List<&2, Commands.Command>, +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>) ->
  Return.Returned<Settlement.start(after(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena, commands), N.index(w), rest, stack), rest, stack, 10n>:
  Commands.startReturn(Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup), commands, N.index(w), N.index(Pair.memo(w, sourceExpr)), B.length(R.Link, links), rest, stack, Pair.build(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena))


def frame(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>},
  +commands: List<&2, Commands.Command>, +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>) ->
  {Frame.observe(Return.world(Settlement.start(after(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena, commands), N.index(w), rest, stack), rest, stack, 10n, startReturn(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena, commands, rest, stack))) == Frame.observe(Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup)) : Frame.View}:
  Commands.frame(Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup), commands, N.index(w), N.index(Pair.memo(w, sourceExpr)), B.length(R.Link, links), rest, stack, Pair.build(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena))
