# Actual memo/render construction supplies the fresh-carrier node and auxiliary
# premises. No post-construction x/validity/arena equation is an input.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./memo-render-construction.bend as Pair
import ./default-computed-construction.bend as N
import ./node-append-construction.bend as Append
import ./graph-allocation-construction.bend as Shape
import ./pending-command-history.bend as Commands
import ./node-pointer-observation.bend as Pointer
import ./graph-extension-pointers.bend as GraphPointers
import ./constructor-auxiliary-frame.bend as Aux


type Context<-base: R.World, -world: R.World, -root: Nat, -leaf: Nat, -edge: Nat> is Data:
  FreshInput{graph: Shape.OneEdge<world, root, leaf, edge>, empty: {R.Node.x(B.node(world, leaf)) == 0n : Nat}, auxiliary: {Aux.observe(world) == Aux.observe(base) : Aux.View}}

def build(+w: R.World, +sourceExpr: R.Expr, +effectExpr: R.Expr, +target: Nat, +program: Nat, +cleanup: Nat,
  +first: R.Node, +nodes: List<&2, R.Node>, +firstLink: R.Link, +links: List<&2, R.Link>,
  +healthy: {B.ok(w) == True{} : Bool}, +nullComputed: {B.parentComputed(w, 0n) == 0n : Nat},
  +arena: {R.World.nodes(w) == first <> nodes : List<&2, R.Node>}, +linkArena: {R.World.links(w) == firstLink <> links : List<&2, R.Link>}) ->
  Context<w, Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup), N.index(w), N.index(Pair.memo(w, sourceExpr)), B.length(R.Link, links)>:
  +room = Append.zeroRoom(w, first, nodes, arena)
  +m = Pair.memo(w, sourceExpr)
  +e = Pair.allocated(w, sourceExpr, effectExpr, target, program, cleanup)
  +q = Pair.linked(w, sourceExpr, effectExpr, target, program, cleanup)
  +which = {N.Render{target, program, cleanup} : N.Family}
  +roomM = N.zeroRoom(w, sourceExpr, N.Memo{}, room, nullComputed)
  +nullM = N.nullComputed(w, sourceExpr, N.Memo{}, room, nullComputed)
  +rootValid = N.fresh(w, sourceExpr, N.Memo{}, room, nullComputed, first, nodes, arena)
  +root = Pair.rootNode(w, sourceExpr, effectExpr, target, program, cleanup, room, nullComputed, rootValid)
  +leaf = N.node(m, effectExpr, which, roomM, nullM)
  +depsTail = Equal.cong(R.Node, Nat, node => R.Node.depsTail(node), B.node(e, N.index(m)), N.record(m, effectExpr, which), leaf)
  +deps = Equal.cong(R.Node, Nat, node => R.Node.deps(node), B.node(e, N.index(m)), N.record(m, effectExpr, which), leaf)
  +sourceTail = Equal.cong(R.Node, Nat, node => R.Node.subsTail(node), B.node(e, N.index(w)), N.record(w, sourceExpr, N.Memo{}), root)
  +graph = Pair.build(w, sourceExpr, effectExpr, target, program, cleanup, first, nodes, firstLink, links, healthy, nullComputed, arena, linkArena)
  +empty = Equal.trans(Nat, R.Node.x(B.node(q, N.index(m))), R.Node.x(B.node(e, N.index(m))), 0n, Pointer.read(e, q, N.index(m), GraphPointers.linked(e, N.index(w), N.index(m), depsTail, deps, sourceTail)), Equal.cong(R.Node, Nat, node => R.Node.x(node), B.node(e, N.index(m)), N.record(m, effectExpr, which), leaf))
  +aux = Aux.compose(w, e, q, Aux.linked(e, N.index(w), N.index(m), depsTail, deps, sourceTail), Aux.compose(w, m, e, Aux.constructor(m, effectExpr, which, roomM, nullM), Aux.constructor(w, sourceExpr, N.Memo{}, room, nullComputed)))
  FreshInput{graph, empty, aux}


def extensionArena(-base: R.World, -world: R.World, -root: Nat, -leaf: Nat, -edge: Nat, +extensions: List<&2, R.NodeExtension>,
  context: Context<base, world, root, leaf, edge>, known: {R.World.extensions(base) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}) ->
  {R.World.extensions(world) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}:
  match context:
    case FreshInput{graph, empty, auxiliary}:
      Equal.trans(List<&2, R.NodeExtension>, R.World.extensions(world), R.World.extensions(base), B.blank_extension() <> extensions, Equal.cong(Aux.View, List<&2, R.NodeExtension>, view => Aux.extensions(view), Aux.observe(world), Aux.observe(base), auxiliary), known)


def setArena(-base: R.World, -world: R.World, -root: Nat, -leaf: Nat, -edge: Nat, +sets: List<&2, List<&2, Nat>>,
  context: Context<base, world, root, leaf, edge>, known: {R.World.pendingSets(base) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {R.World.pendingSets(world) == [] <> sets : List<&2, List<&2, Nat>>}:
  match context:
    case FreshInput{graph, empty, auxiliary}:
      Equal.trans(List<&2, List<&2, Nat>>, R.World.pendingSets(world), R.World.pendingSets(base), [] <> sets, Equal.cong(Aux.View, List<&2, List<&2, Nat>>, view => Aux.sets(view), Aux.observe(world), Aux.observe(base), auxiliary), known)


def graph(-base: R.World, -world: R.World, -root: Nat, -leaf: Nat, -edge: Nat, context: Context<base, world, root, leaf, edge>) -> Shape.OneEdge<world, root, leaf, edge>:
  match context:
    case FreshInput{graph, empty, auxiliary}: graph


def freshX(-base: R.World, -world: R.World, -root: Nat, -leaf: Nat, -edge: Nat, context: Context<base, world, root, leaf, edge>) -> {R.Node.x(B.node(world, leaf)) == 0n : Nat}:
  match context:
    case FreshInput{graph, empty, auxiliary}: empty
