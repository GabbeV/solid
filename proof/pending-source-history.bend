# Finite permitted branching histories of actual source add/remove helpers.
# Each event certificate checks both represented node IDs in its actual input
# World. It does not supply a transition or desired observation equation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/core.bend as Core
import ./pending-add-preservation.bend as Add
import ./pending-source-committed-frame.bend as ContentSource
import ./topology-source-frame.bend as TopologySource
import ./committed-storage-frame.bend as Content
import ./subscriber-topology-frame.bend as Topology
import ./graph-allocation-properties.bend as Storage
import ./pending-add-storage.bend as Aux
import ./pending-remove-frame.bend as Remove
import ./pending-one-edge-transport.bend as Transport
import ./graph-allocation-construction.bend as Shape
import ./bounded-core-return.bend as Return
import ./one-edge-settlement-return.bend as Settlement

type SourceChange is Data:
  Add{node: Nat, source: Nat}
  Remove{node: Nat, source: Nat}

def apply(w: R.World, event: SourceChange) -> R.World:
  match event:
    case Add{node, source}: B.first(R.World, Bool, P.addPendingSource(w, node, source))
    case Remove{node, source}: B.first(R.World, Bool, P.removePendingSource(w, node, source))

def admitted(+w: R.World, event: SourceChange) -> Bool:
  match event:
    case Add{node, source}: Bool.and(B.valid(w, node), B.valid(w, source))
    case Remove{node, source}: Bool.and(B.valid(w, node), B.valid(w, source))

type History<-w: R.World> is Data:
  End{}
  Step{event: SourceChange, allowed: {admitted(w, event) == True{} : Bool}, tail: History<apply(w, event)>}

def execute(-scope: R.World, history: History<scope>, actual: R.World) -> R.World:
  match history:
    case End{}: actual
    case Step{event, allowed, tail}: execute(apply(scope, event), tail, apply(actual, event))

def run(+w: R.World, history: History<w>) -> R.World:
  execute(w, history, w)


def onceContent(+w: R.World, +event: SourceChange) -> {Content.observe(apply(w, event)) == Content.observe(w) : Content.View}:
  match event:
    case Add{node, source}: Add.content(w, node, source)
    case Remove{node, source}: ContentSource.remove(w, node, source)

def onceTopology(+w: R.World, +event: SourceChange) -> {Topology.observe(apply(w, event)) == Topology.observe(w) : Topology.View}:
  match event:
    case Add{node, source}: Add.topology(w, node, source)
    case Remove{node, source}: TopologySource.remove(w, node, source)

def onceStorage(+w: R.World, +event: SourceChange) -> {Storage.storage(apply(w, event)) == Storage.storage(w) : Storage.Storage}:
  match event:
    case Add{node, source}: Add.storage(w, node, source)
    case Remove{node, source}: Remove.remove(Storage.Storage, state => Storage.storage(state), Aux.storeExtension, Aux.storePendingSet, w, node, source)

def frame(~A: Data, ~observe: R.World -> A,
  ~once: @+w: R.World -> @+event: SourceChange -> {observe(apply(w, event)) == observe(w) : A},
  -scope: R.World, +history: History<scope>, +actual: R.World) -> {observe(execute(scope, history, actual)) == observe(actual) : A}:
  match history:
    case End{}: {==}
    case Step{+event, allowed, tail}:
      Equal.trans(A, observe(execute(apply(scope, event), tail, apply(actual, event))), observe(apply(actual, event)), observe(actual), frame(A, observe, once, apply(scope, event), tail, apply(actual, event)), once(actual, event))


def content(+w: R.World, +history: History<w>) -> {Content.observe(run(w, history)) == Content.observe(w) : Content.View}:
  frame(Content.View, state => Content.observe(state), onceContent, w, history, w)

def topology(+w: R.World, +history: History<w>) -> {Topology.observe(run(w, history)) == Topology.observe(w) : Topology.View}:
  frame(Topology.View, state => Topology.observe(state), onceTopology, w, history, w)

def storage(+w: R.World, +history: History<w>) -> {Storage.storage(run(w, history)) == Storage.storage(w) : Storage.Storage}:
  frame(Storage.Storage, state => Storage.storage(state), onceStorage, w, history, w)

def graph(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat, +history: History<w>, shape: Shape.OneEdge<w, root, leaf, edge>) ->
  Shape.OneEdge<run(w, history), root, leaf, edge>:
  Transport.build(w, run(w, history), root, leaf, edge, topology(w, history), storage(w, history), shape)

def startReturn(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat, +history: History<w>, +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>, shape: Shape.OneEdge<w, root, leaf, edge>) ->
  Return.Returned<Settlement.start(run(w, history), root, rest, stack), rest, stack, 10n>:
  Shape.startReturn(run(w, history), root, leaf, edge, rest, stack, graph(w, root, leaf, edge, history, shape))

def returnedFrame(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat, +history: History<w>, +rest: List<&2, Core.Task>, +stack: List<&2, R.Value>, +shape: Shape.OneEdge<w, root, leaf, edge>) ->
  {Content.observe(Return.world(Settlement.start(run(w, history), root, rest, stack), rest, stack, 10n, startReturn(w, root, leaf, edge, history, rest, stack, shape))) == Content.observe(w) : Content.View}:
  +next = run(w, history)
  Content.compose(w, next, Return.world(Settlement.start(next, root, rest, stack), rest, stack, 10n, startReturn(w, root, leaf, edge, history, rest, stack, shape)), Shape.returnedFrame(next, root, leaf, edge, rest, stack, graph(w, root, leaf, edge, history, shape)), content(w, history))
