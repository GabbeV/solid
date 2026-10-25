# A visitor's control observation ignores its computed World. Both source early
# returns and successful leaf retirement are admitted; no error is suppressed.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending.bend as Q
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K
import ./subscriber-topology-frame.bend as Topology
import ./pending-topology-frame.bend as Graph
import ./pending-machine-shape.bend as Machine
import ./pending-removal-footprint.bend as Removal

type View is Data:
  View{tasks: List<&2, Q.Task>, released: List<&2, Nat>}

def observe(+machine: Q.Machine) -> View:
  View{Machine.tasks(machine), Machine.releases(machine)}

type Next<-view: View, -tail: List<&2, Q.Task>, -released: List<&2, Nat>, -root: Nat, -source: Nat> is Data:
  Direct{shape: {view == View{tail, released} : View}}
  Leaf{shape: {view == View{Q.Walk{0n, root, source} <> tail, released} : View}}

def choice(+condition: Bool, -left: Q.Machine, -right: Q.Machine, -tail: List<&2, Q.Task>, -released: List<&2, Nat>, -root: Nat, -source: Nat,
  yes: Next<observe(left), tail, released, root, source>, no: Next<observe(right), tail, released, root, source>) ->
  Next<observe(B.choose(~Q.Machine, condition, _ => left, _ => right)), tail, released, root, source>:
  match condition:
    case True{}: yes
    case False{}: no

def skip(w: R.World, +tail: List<&2, Q.Task>, visited: List<&2, Nat>, +released: List<&2, Nat>, queued: Bool, id: Nat) ->
  {observe(Q.skip(w, tail, visited, released, queued, id)) == View{tail, released} : View}:
  {==}

def settled(+w: R.World, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +queued: Bool, +id: Nat, +root: Nat, +source: Nat,
  noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  {observe(Q.settled(w, tail, visited, released, queued, id, root, source)) == View{Q.Walk{0n, root, source} <> tail, released} : View}:
  Equal.cong(Q.Machine, View, result => observe(result), Q.settled(w, tail, visited, released, queued, id, root, source), Q.Machine{Machine.world(Q.settled(w, tail, visited, released, queued, id, root, source)), Q.Walk{0n, root, source} <> tail, id <> visited, released, Machine.scheduled(Q.settled(w, tail, visited, released, queued, id, root, source))}, Machine.settledLeaf(w, tail, visited, released, queued, id, root, source, noSubscribers, noAuto))

def removed(+w: R.World, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +queued: Bool, +id: Nat, +root: Nat, +source: Nat,
  noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  Next<observe(Q.visitRemoved(w, tail, visited, released, queued, id, root, source)), tail, released, root, source>:
  +pair = P.removePendingSource(w, id, source)
  +next = B.first(R.World, Bool, pair)
  +nodeSame = Removal.node(w, id, source, id)
  +subscribers = Equal.trans(Nat, R.Node.subs(B.node(next, id)), R.Node.subs(B.node(w, id)), 0n, Equal.cong(R.Node, Nat, node => R.Node.subs(node), B.node(next, id), B.node(w, id), nodeSame), noSubscribers)
  +automatic = Equal.trans(Bool, B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE()), B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()), False{}, Equal.cong(R.Node, Bool, node => B.has(R.Node.config(node), K.CONFIG_AUTO_DISPOSE()), B.node(next, id), B.node(w, id), nodeSame), noAuto)
  choice(B.second(R.World, Bool, pair), Q.settled(next, tail, visited, released, queued, id, root, source), Q.skip(next, tail, visited, released, queued, id), tail, released, root, source,
    Leaf{settled(next, tail, visited, released, queued, id, root, source, subscribers, automatic)}, Direct{skip(next, tail, visited, released, queued, id)})

def visit(+w: R.World, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +queued: Bool, +id: Nat, +root: Nat, +source: Nat,
  noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  Next<observe(Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, queued)), tail, released, root, source>:
  +pair = B.choose(~B.Bundle<R.World, Bool>, Nat.is_ne(source, root), _ => P.retryReaches(w, id, source), _ => B.Bundle{w, False{}})
  +next = B.first(R.World, Bool, pair)
  +frame = Topology.firstBoolChoice(Nat.is_ne(source, root), w, P.retryReaches(w, id, source), B.Bundle{w, False{}}, Graph.retry(B.budget(w), w, R.Node.deps(B.node(w, id)), source), {==})
  +nodeSame = Topology.read(w, next, id, frame)
  +subscribers = Equal.trans(Nat, R.Node.subs(B.node(next, id)), R.Node.subs(B.node(w, id)), 0n, Equal.cong(Topology.Shape, Nat, shape => Machine.subs(shape), Topology.shape(B.node(next, id)), Topology.shape(B.node(w, id)), nodeSame), noSubscribers)
  +automatic = Equal.trans(Bool, B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE()), B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()), False{}, Equal.cong(Topology.Shape, Bool, shape => B.has(Machine.config(shape), K.CONFIG_AUTO_DISPOSE()), Topology.shape(B.node(next, id)), Topology.shape(B.node(w, id)), nodeSame), noAuto)
  +after = B.choose(~Q.Machine, B.second(R.World, Bool, pair), _ => Q.skip(next, tail, visited, released, queued, id), _ => Q.visitRemoved(next, tail, visited, released, queued, id, root, source))
  choice(B.contains(visited, id), Q.skip(w, tail, visited, released, queued, id), after, tail, released, root, source,
    Direct{skip(w, tail, visited, released, queued, id)},
    choice(B.second(R.World, Bool, pair), Q.skip(next, tail, visited, released, queued, id), Q.visitRemoved(next, tail, visited, released, queued, id, root, source), tail, released, root, source,
      Direct{skip(next, tail, visited, released, queued, id)}, removed(next, tail, visited, released, queued, id, root, source, subscribers, automatic)))
