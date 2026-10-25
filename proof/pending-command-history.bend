# A constructor supplies every input-validity certificate for arbitrary finite
# add/remove choices along the selected root->leaf relation. No caller-supplied
# transition or final invariant equation is accepted.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as Core
import ./pending-source-history.bend as History
import ./pending-one-edge-transport.bend as Transport
import ./graph-allocation-construction.bend as Shape
import ./bounded-core-return.bend as Return
import ./one-edge-settlement-return.bend as Settlement
import ./committed-storage-frame.bend as Frame

type Command is Data:
  AddLeaf{}
  RemoveLeaf{}

def event(root: Nat, leaf: Nat, command: Command) -> History.SourceChange:
  match command:
    case AddLeaf{}: History.Add{leaf, root}
    case RemoveLeaf{}: History.Remove{leaf, root}

def rootValid(-w: R.World, -root: Nat, -leaf: Nat, -edge: Nat, shape: Shape.OneEdge<w, root, leaf, edge>) -> {B.valid(w, root) == True{} : Bool}:
  match shape:
    case Shape.OneEdgeReady{healthy, validRoot, validLeaf, head, selected, end, noSubscribers, noAuto}: validRoot

def leafValid(-w: R.World, -root: Nat, -leaf: Nat, -edge: Nat, shape: Shape.OneEdge<w, root, leaf, edge>) -> {B.valid(w, leaf) == True{} : Bool}:
  match shape:
    case Shape.OneEdgeReady{healthy, validRoot, validLeaf, head, selected, end, noSubscribers, noAuto}: validLeaf

def both(+a: Bool, +b: Bool, left: {a == True{} : Bool}, right: {b == True{} : Bool}) -> {Bool.and(a, b) == True{} : Bool}:
  Equal.trans(Bool, Bool.and(a, b), b, True{}, Equal.cong(Bool, Bool, flag => Bool.and(flag, b), a, True{}, left), right)

def allowed(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat, +shape: Shape.OneEdge<w, root, leaf, edge>, command: Command) ->
  {History.admitted(w, event(root, leaf, command)) == True{} : Bool}:
  match command:
    case AddLeaf{}: both(B.valid(w, leaf), B.valid(w, root), leafValid(w, root, leaf, edge, shape), rootValid(w, root, leaf, edge, shape))
    case RemoveLeaf{}: both(B.valid(w, leaf), B.valid(w, root), leafValid(w, root, leaf, edge, shape), rootValid(w, root, leaf, edge, shape))

def construct(-scope: R.World, commands: List<&2, Command>, +actual: R.World, +root: Nat, +leaf: Nat, +edge: Nat,
  +layout: {scope == actual : R.World}, +shape: Shape.OneEdge<actual, root, leaf, edge>) -> History.History<scope>:
  match commands:
    case Nil{}: History.End{}
    case +command <> tail:
      +operation = event(root, leaf, command)
      +next = History.apply(actual, operation)
      +cert = Transport.build(actual, next, root, leaf, edge, History.onceTopology(actual, operation), History.onceStorage(actual, operation), shape)
      History.Step{operation,
        Equal.trans(Bool, History.admitted(scope, operation), History.admitted(actual, operation), True{}, Equal.cong(R.World, Bool, world => History.admitted(world, operation), scope, actual, layout), allowed(actual, root, leaf, edge, shape, command)),
        construct(History.apply(scope, operation), tail, next, root, leaf, edge, Equal.cong(R.World, R.World, world => History.apply(world, operation), scope, actual, layout), cert)}

def build(+w: R.World, commands: List<&2, Command>, +root: Nat, +leaf: Nat, +edge: Nat, shape: Shape.OneEdge<w, root, leaf, edge>) -> History.History<w>:
  construct(w, commands, w, root, leaf, edge, {==}, shape)

def startReturn(+w: R.World, +commands: List<&2, Command>, +root: Nat, +leaf: Nat, +edge: Nat, +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>, +shape: Shape.OneEdge<w, root, leaf, edge>) ->
  Return.Returned<Settlement.start(History.run(w, build(w, commands, root, leaf, edge, shape)), root, rest, stack), rest, stack, 10n>:
  History.startReturn(w, root, leaf, edge, build(w, commands, root, leaf, edge, shape), rest, stack, shape)

def frame(+w: R.World, +commands: List<&2, Command>, +root: Nat, +leaf: Nat, +edge: Nat, +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>, +shape: Shape.OneEdge<w, root, leaf, edge>) ->
  {Frame.observe(Return.world(Settlement.start(History.run(w, build(w, commands, root, leaf, edge, shape)), root, rest, stack), rest, stack, 10n, startReturn(w, commands, root, leaf, edge, rest, stack, shape))) == Frame.observe(w) : Frame.View}:
  History.returnedFrame(w, root, leaf, edge, build(w, commands, root, leaf, edge, shape), rest, stack, shape)
