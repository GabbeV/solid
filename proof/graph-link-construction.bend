# Construction through actual graph.link. Initial empty-list metadata/allocated
# identities remain explicit; the final edge/head/health facts are derived.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/graph-state.bend as G
import ../runtime/constants.bend as K
import ./graph-empty-allocation.bend as Allocation
import ./graph-fresh-link.bend as Fresh
import ./graph-allocation-construction.bend as Constructed
import ./one-edge-settlement-return.bend as Settlement
import ./bounded-core-return.bend as Return
import ./committed-storage-frame.bend as Frame
import ./graph-construction-frame.bend as GraphFrame

def indexNonempty(+w: R.World, +first: R.Link, +tail: List<&2, R.Link>, known: {R.World.links(w) == first <> tail : List<&2, R.Link>}) ->
  {Allocation.index(w) == 1n+B.length(R.Link, tail) : Nat}:
  Equal.cong(List<&2, R.Link>, Nat, links => B.length(R.Link, links), R.World.links(w), first <> tail, known)

def move(-a: R.World, -b: R.World, -root: Nat, -leaf: Nat, -edge: Nat, same: {a == b : R.World}, shape: Constructed.OneEdge<a, root, leaf, edge>) -> Constructed.OneEdge<b, root, leaf, edge>:
  %same : Constructed.OneEdge<_, root, leaf, edge>
  shape

def build(+w: R.World, +root: Nat, +leaf: Nat, +first: R.Link, +links: List<&2, R.Link>,
  healthy: {B.ok(w) == True{} : Bool}, validRoot: {B.valid(w, root) == True{} : Bool}, validLeaf: {B.valid(w, leaf) == True{} : Bool}, different: {Nat.is_eq(leaf, root) == False{} : Bool},
  rootEmpty: {R.Node.subs(B.node(w, root)) == 0n : Nat}, rootTail: {R.Node.subsTail(B.node(w, root)) == 0n : Nat}, deps: {R.Node.deps(B.node(w, leaf)) == 0n : Nat}, depsTail: {R.Node.depsTail(B.node(w, leaf)) == 0n : Nat},
  noSubscribers: {R.Node.subs(B.node(w, leaf)) == 0n : Nat}, noAuto: {B.has(R.Node.config(B.node(w, leaf)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}, arena: {R.World.links(w) == first <> links : List<&2, R.Link>}) ->
  Constructed.OneEdge<G.link(w, root, leaf), root, leaf, B.length(R.Link, links)>:
  +same = Fresh.freshEmptyDependencies(w, root, leaf, depsTail, deps, rootTail)
  move(Allocation.source(w, root, leaf), G.link(w, root, leaf), root, leaf, B.length(R.Link, links), Equal.sym(R.World, G.link(w, root, leaf), Allocation.source(w, root, leaf), same),
    Constructed.build(w, root, leaf, B.length(R.Link, links), healthy, validRoot, validLeaf, different, indexNonempty(w, first, links, arena), noSubscribers, noAuto))

def startReturn(+w: R.World, +root: Nat, +leaf: Nat, +first: R.Link, +links: List<&2, R.Link>, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>,
  healthy: {B.ok(w) == True{} : Bool}, validRoot: {B.valid(w, root) == True{} : Bool}, validLeaf: {B.valid(w, leaf) == True{} : Bool}, different: {Nat.is_eq(leaf, root) == False{} : Bool},
  rootEmpty: {R.Node.subs(B.node(w, root)) == 0n : Nat}, rootTail: {R.Node.subsTail(B.node(w, root)) == 0n : Nat}, deps: {R.Node.deps(B.node(w, leaf)) == 0n : Nat}, depsTail: {R.Node.depsTail(B.node(w, leaf)) == 0n : Nat},
  noSubscribers: {R.Node.subs(B.node(w, leaf)) == 0n : Nat}, noAuto: {B.has(R.Node.config(B.node(w, leaf)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}, arena: {R.World.links(w) == first <> links : List<&2, R.Link>}) ->
  Return.Returned<Settlement.start(G.link(w, root, leaf), root, rest, stack), rest, stack, 10n>:
  Constructed.startReturn(G.link(w, root, leaf), root, leaf, B.length(R.Link, links), rest, stack, build(w, root, leaf, first, links, healthy, validRoot, validLeaf, different, rootEmpty, rootTail, deps, depsTail, noSubscribers, noAuto, arena))


def frame(+w: R.World, +root: Nat, +leaf: Nat, +first: R.Link, +links: List<&2, R.Link>, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>,
  +healthy: {B.ok(w) == True{} : Bool}, +validRoot: {B.valid(w, root) == True{} : Bool}, +validLeaf: {B.valid(w, leaf) == True{} : Bool}, +different: {Nat.is_eq(leaf, root) == False{} : Bool},
  +rootEmpty: {R.Node.subs(B.node(w, root)) == 0n : Nat}, +rootTail: {R.Node.subsTail(B.node(w, root)) == 0n : Nat}, +deps: {R.Node.deps(B.node(w, leaf)) == 0n : Nat}, +depsTail: {R.Node.depsTail(B.node(w, leaf)) == 0n : Nat},
  +noSubscribers: {R.Node.subs(B.node(w, leaf)) == 0n : Nat}, +noAuto: {B.has(R.Node.config(B.node(w, leaf)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}, +arena: {R.World.links(w) == first <> links : List<&2, R.Link>}) ->
  {Frame.observe(Return.world(Settlement.start(G.link(w, root, leaf), root, rest, stack), rest, stack, 10n, startReturn(w, root, leaf, first, links, rest, stack, healthy, validRoot, validLeaf, different, rootEmpty, rootTail, deps, depsTail, noSubscribers, noAuto, arena))) == Frame.observe(w) : Frame.View}:
  +next = G.link(w, root, leaf)
  +shape = build(w, root, leaf, first, links, healthy, validRoot, validLeaf, different, rootEmpty, rootTail, deps, depsTail, noSubscribers, noAuto, arena)
  Frame.compose(w, next, Return.world(Settlement.start(next, root, rest, stack), rest, stack, 10n, Constructed.startReturn(next, root, leaf, B.length(R.Link, links), rest, stack, shape)), Constructed.returnedFrame(next, root, leaf, B.length(R.Link, links), rest, stack, shape), GraphFrame.linked(w, root, leaf, depsTail, deps, rootTail))
