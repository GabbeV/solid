# Control fields of the actual settled-node continuation. World, pending and
# transaction metadata are retained as actual computed values, never replaced.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending.bend as Q
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K
import ./subscriber-topology-frame.bend as Shape
import ./pending-topology-frame.bend as Topology

def world(machine: Q.Machine) -> R.World:
  match machine:
    case Q.Machine{w, tasks, visited, released, scheduled}: w

def tasks(machine: Q.Machine) -> List<&2, Q.Task>:
  match machine:
    case Q.Machine{w, tasks, visited, released, scheduled}: tasks

def visits(machine: Q.Machine) -> List<&2, Nat>:
  match machine:
    case Q.Machine{w, tasks, visited, released, scheduled}: visited

def releases(machine: Q.Machine) -> List<&2, Nat>:
  match machine:
    case Q.Machine{w, tasks, visited, released, scheduled}: released

def scheduled(machine: Q.Machine) -> Bool:
  match machine:
    case Q.Machine{w, tasks, visited, released, scheduled}: scheduled

def subs(shape: Shape.Shape) -> Nat:
  match shape:
    case Shape.Shape{kind, config, subscribers}: subscribers

def config(shape: Shape.Shape) -> U32:
  match shape:
    case Shape.Shape{kind, config, subscribers}: config

def noAuto(+node: R.Node) -> Bool:
  Bool.not(B.has(R.Node.config(node), K.CONFIG_AUTO_DISPOSE()))

def lastOf(+w: R.World, +id: Nat) -> Bool:
  +timed = B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w)))
  Nat.is_eq(B.get(Nat, P.items(B.pendingSources(timed, id)), 0n, 0n), 0n)

def settledTasks(+w: R.World, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +queued: Bool, +id: Nat, +root: Nat, +source: Nat) ->
  {tasks(Q.settled(w, tail, visited, released, queued, id, root, source)) == Q.Walk{R.Node.subs(B.node(world(Q.settled(w, tail, visited, released, queued, id, root, source)), id)), root, source} <> tail : List<&2, Q.Task>}:
  {==}

def settledVisits(w: R.World, tail: List<&2, Q.Task>, +visited: List<&2, Nat>, released: List<&2, Nat>, queued: Bool, +id: Nat, root: Nat, source: Nat) ->
  {visits(Q.settled(w, tail, visited, released, queued, id, root, source)) == id <> visited : List<&2, Nat>}:
  {==}

def settledReleases(+w: R.World, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +queued: Bool, +id: Nat, +root: Nat, +source: Nat) ->
  {releases(Q.settled(w, tail, visited, released, queued, id, root, source)) ==
    B.choose(~List<&2, Nat>, Bool.and(B.ok(world(Q.settled(w, tail, visited, released, queued, id, root, source))), Bool.and(lastOf(w, id), Bool.and(Nat.is_eq(R.Node.subs(B.node(world(Q.settled(w, tail, visited, released, queued, id, root, source)), id)), 0n), B.has(R.Node.config(B.node(world(Q.settled(w, tail, visited, released, queued, id, root, source)), id)), K.CONFIG_AUTO_DISPOSE())))),
      _ => B.append(Nat, released, [id]), _ => released) : List<&2, Nat>}:
  {==}

def andFalse(left: Bool) -> {Bool.and(left, False{}) == False{} : Bool}:
  match left:
    case True{}: {==}
    case False{}: {==}

def falseRight(+left: Bool, +right: Bool, no: {right == False{} : Bool}) ->
  {Bool.and(left, right) == False{} : Bool}:
  Equal.trans(Bool, Bool.and(left, right), Bool.and(left, False{}), False{}, Equal.cong(Bool, Bool, value => Bool.and(left, value), right, False{}, no), andFalse(left))

def settledNoReleases(+w: R.World, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +queued: Bool, +id: Nat, +root: Nat, +source: Nat,
  noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  {releases(Q.settled(w, tail, visited, released, queued, id, root, source)) == released : List<&2, Nat>}:
  +result = Q.settled(w, tail, visited, released, queued, id, root, source)
  +next = world(result)
  +topology = Topology.settled(w, tail, visited, released, queued, id, root, source)
  +same = Shape.read(w, next, id, topology)
  +no = Equal.trans(Bool, B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE()), B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()), False{}, Equal.cong(Shape.Shape, Bool, shape => B.has(config(shape), K.CONFIG_AUTO_DISPOSE()), Shape.shape(B.node(next, id)), Shape.shape(B.node(w, id)), same), noAuto)
  +guard = falseRight(B.ok(next), Bool.and(lastOf(w, id), Bool.and(Nat.is_eq(R.Node.subs(B.node(next, id)), 0n), B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE()))), falseRight(lastOf(w, id), Bool.and(Nat.is_eq(R.Node.subs(B.node(next, id)), 0n), B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE())), falseRight(Nat.is_eq(R.Node.subs(B.node(next, id)), 0n), B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE()), no)))
  Equal.trans(List<&2, Nat>, releases(result), B.choose(~List<&2, Nat>, Bool.and(B.ok(next), Bool.and(lastOf(w, id), Bool.and(Nat.is_eq(R.Node.subs(B.node(next, id)), 0n), B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE())))), _ => B.append(Nat, released, [id]), _ => released), released,
    settledReleases(w, tail, visited, released, queued, id, root, source), Equal.cong(Bool, List<&2, Nat>, condition => B.choose(~List<&2, Nat>, condition, _ => B.append(Nat, released, [id]), _ => released), Bool.and(B.ok(next), Bool.and(lastOf(w, id), Bool.and(Nat.is_eq(R.Node.subs(B.node(next, id)), 0n), B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE())))), False{}, guard))

# Rebuild an opaque result from its actual fields, then use only checked field
# equations. This avoids expanding the computed World at each control cut.
def fromFields(+machine: Q.Machine, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>,
  taskShape: {tasks(machine) == tail : List<&2, Q.Task>}, visitShape: {visits(machine) == visited : List<&2, Nat>}, releaseShape: {releases(machine) == released : List<&2, Nat>}) ->
  {machine == Q.Machine{world(machine), tail, visited, released, scheduled(machine)} : Q.Machine}:
  match machine:
    case Q.Machine{+w, +oldTasks, +oldVisits, +oldReleases, +queued}:
      Equal.trans(Q.Machine, Q.Machine{w, oldTasks, oldVisits, oldReleases, queued}, Q.Machine{w, tail, oldVisits, oldReleases, queued}, Q.Machine{w, tail, visited, released, queued},
        Equal.cong(List<&2, Q.Task>, Q.Machine, value => Q.Machine{w, value, oldVisits, oldReleases, queued}, oldTasks, tail, taskShape),
        Equal.trans(Q.Machine, Q.Machine{w, tail, oldVisits, oldReleases, queued}, Q.Machine{w, tail, visited, oldReleases, queued}, Q.Machine{w, tail, visited, released, queued},
          Equal.cong(List<&2, Nat>, Q.Machine, value => Q.Machine{w, tail, value, oldReleases, queued}, oldVisits, visited, visitShape),
          Equal.cong(List<&2, Nat>, Q.Machine, value => Q.Machine{w, tail, visited, value, queued}, oldReleases, released, releaseShape)))

def settledLeaf(+w: R.World, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +queued: Bool, +id: Nat, +root: Nat, +source: Nat,
  noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  {Q.settled(w, tail, visited, released, queued, id, root, source) == Q.Machine{world(Q.settled(w, tail, visited, released, queued, id, root, source)), Q.Walk{0n, root, source} <> tail, id <> visited, released, scheduled(Q.settled(w, tail, visited, released, queued, id, root, source))} : Q.Machine}:
  +result = Q.settled(w, tail, visited, released, queued, id, root, source)
  +next = world(result)
  +read = Shape.read(w, next, id, Topology.settled(w, tail, visited, released, queued, id, root, source))
  +zero = Equal.trans(Nat, R.Node.subs(B.node(next, id)), R.Node.subs(B.node(w, id)), 0n, Equal.cong(Shape.Shape, Nat, shape => subs(shape), Shape.shape(B.node(next, id)), Shape.shape(B.node(w, id)), read), noSubscribers)
  +taskShape = Equal.trans(List<&2, Q.Task>, tasks(result), Q.Walk{R.Node.subs(B.node(next, id)), root, source} <> tail, Q.Walk{0n, root, source} <> tail,
    settledTasks(w, tail, visited, released, queued, id, root, source), Equal.cong(Nat, List<&2, Q.Task>, edge => Q.Walk{edge, root, source} <> tail, R.Node.subs(B.node(next, id)), 0n, zero))
  fromFields(result, Q.Walk{0n, root, source} <> tail, id <> visited, released, taskShape, settledVisits(w, tail, visited, released, queued, id, root, source), settledNoReleases(w, tail, visited, released, queued, id, root, source, noAuto))
