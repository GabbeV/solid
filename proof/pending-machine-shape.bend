# Control fields of the actual settled-node continuation. World, pending and
# transaction metadata are retained as actual computed values, never replaced.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending.bend as Q
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K
import ./staged-subscriber-frame.bend as Shape
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

def prepared(+w: R.World,tail: List<&2,Q.Task>,visited: List<&2,Nat>,released: List<&2,Nat>,queued: Bool,+id: Nat,root: Nat,source: Nat) -> Q.Machine:
  +timed = B.store_node(w,id,R.Node.with_time(B.node(w,id),R.World.clock(w)))
  +remaining = B.get(Nat,P.items(B.pendingSources(timed,id)),0n,0n)
  +statused = Q.settledStatus(timed,id,remaining,B.has(R.Node.status(B.node(timed,id)),K.STATUS_ERROR()))
  Q.settledTailPrefix(statused,tail,visited,released,queued,id,root,source,Nat.is_eq(remaining,0n))

def settledCut(+w: R.World,+tail: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+queued: Bool,+id: Nat,+root: Nat,+source: Nat) ->
  {Q.settled(w,tail,visited,released,queued,id,root,source) == Q.stageSettled(lastOf(w,id),prepared(w,tail,visited,released,queued,id,root,source),id,root) : Q.Machine}:
  {==}

def preparedFrame(+w: R.World,+tail: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+queued: Bool,+id: Nat,+root: Nat,+source: Nat) ->
  {Shape.observe(world(prepared(w,tail,visited,released,queued,id,root,source))) == Shape.observe(w) : Shape.View}:
  +timed = B.store_node(w,id,R.Node.with_time(B.node(w,id),R.World.clock(w)))
  +remaining = B.get(Nat,P.items(B.pendingSources(timed,id)),0n,0n)
  +errored = B.has(R.Node.status(B.node(timed,id)),K.STATUS_ERROR())
  +statused = Q.settledStatus(timed,id,remaining,errored)
  Shape.compose(w,timed,world(prepared(w,tail,visited,released,queued,id,root,source)),
    Shape.compose(timed,statused,world(prepared(w,tail,visited,released,queued,id,root,source)),Topology.tailPrefix(statused,tail,visited,released,queued,id,root,source,Nat.is_eq(remaining,0n)),Topology.actualStatus(timed,id,remaining,errored)),Shape.time(w,id,R.World.clock(w)))

def preparedTasks(+w: R.World,+tail: List<&2,Q.Task>,visited: List<&2,Nat>,released: List<&2,Nat>,queued: Bool,+id: Nat,+root: Nat,+source: Nat) ->
  {tasks(prepared(w,tail,visited,released,queued,id,root,source)) == Q.Descend{id,root,source} <> tail : List<&2,Q.Task>}:
  {==}

def preparedVisits(w: R.World,tail: List<&2,Q.Task>,+visited: List<&2,Nat>,released: List<&2,Nat>,queued: Bool,id: Nat,root: Nat,source: Nat) ->
  {visits(prepared(w,tail,visited,released,queued,id,root,source)) == visited : List<&2,Nat>}:
  {==}

def preparedReleases(+w: R.World,+tail: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+queued: Bool,+id: Nat,+root: Nat,+source: Nat) ->
  {releases(prepared(w,tail,visited,released,queued,id,root,source)) ==
    B.choose(~List<&2,Nat>,Bool.and(B.ok(world(prepared(w,tail,visited,released,queued,id,root,source))),Bool.and(lastOf(w,id),Bool.and(Nat.is_eq(R.Node.subs(B.node(world(prepared(w,tail,visited,released,queued,id,root,source)),id)),0n),B.has(R.Node.config(B.node(world(prepared(w,tail,visited,released,queued,id,root,source)),id)),K.CONFIG_AUTO_DISPOSE())))),_=>B.append(Nat,released,[id]),_=>released) : List<&2,Nat>}:
  {==}

def andFalse(left: Bool) -> {Bool.and(left, False{}) == False{} : Bool}:
  match left:
    case True{}: {==}
    case False{}: {==}

def falseRight(+left: Bool, +right: Bool, no: {right == False{} : Bool}) ->
  {Bool.and(left, right) == False{} : Bool}:
  Equal.trans(Bool, Bool.and(left, right), Bool.and(left, False{}), False{}, Equal.cong(Bool, Bool, value => Bool.and(left, value), right, False{}, no), andFalse(left))

def preparedNoReleases(+w: R.World, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +queued: Bool, +id: Nat, +root: Nat, +source: Nat,
  noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  {releases(prepared(w, tail, visited, released, queued, id, root, source)) == released : List<&2, Nat>}:
  +result = prepared(w, tail, visited, released, queued, id, root, source)
  +next = world(result)
  +topology = preparedFrame(w, tail, visited, released, queued, id, root, source)
  +same = Shape.read(w, next, id, topology)
  +no = Equal.trans(Bool, B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE()), B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()), False{}, Shape.autoRead(w, next, id, topology), noAuto)
  +guard = falseRight(B.ok(next), Bool.and(lastOf(w, id), Bool.and(Nat.is_eq(R.Node.subs(B.node(next, id)), 0n), B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE()))), falseRight(lastOf(w, id), Bool.and(Nat.is_eq(R.Node.subs(B.node(next, id)), 0n), B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE())), falseRight(Nat.is_eq(R.Node.subs(B.node(next, id)), 0n), B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE()), no)))
  Equal.trans(List<&2, Nat>, releases(result), B.choose(~List<&2, Nat>, Bool.and(B.ok(next), Bool.and(lastOf(w, id), Bool.and(Nat.is_eq(R.Node.subs(B.node(next, id)), 0n), B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE())))), _ => B.append(Nat, released, [id]), _ => released), released,
    preparedReleases(w, tail, visited, released, queued, id, root, source), Equal.cong(Bool, List<&2, Nat>, condition => B.choose(~List<&2, Nat>, condition, _ => B.append(Nat, released, [id]), _ => released), Bool.and(B.ok(next), Bool.and(lastOf(w, id), Bool.and(Nat.is_eq(R.Node.subs(B.node(next, id)), 0n), B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE())))), False{}, guard))

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

# Exact prefix fields; the new stageMark/Descend alternatives are classified
# by pending-visit-control rather than assuming a single post-visitor shape.
def preparedLeaf(+w: R.World,+tail: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+queued: Bool,+id: Nat,+root: Nat,+source: Nat,
  noAuto: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  {prepared(w,tail,visited,released,queued,id,root,source) == Q.Machine{world(prepared(w,tail,visited,released,queued,id,root,source)),Q.Descend{id,root,source} <> tail,visited,released,scheduled(prepared(w,tail,visited,released,queued,id,root,source))} : Q.Machine}:
  +result = prepared(w,tail,visited,released,queued,id,root,source)
  fromFields(result,Q.Descend{id,root,source} <> tail,visited,released,preparedTasks(w,tail,visited,released,queued,id,root,source),preparedVisits(w,tail,visited,released,queued,id,root,source),preparedNoReleases(w,tail,visited,released,queued,id,root,source,noAuto))

# A nested settlement has fresh release locals, but the enclosing release list
# is retained in its actual return continuation. The old unconditional local
# field equation is false at this rc.21 source boundary.
type ReleaseState<-machine: Q.Machine,-released: List<&2,Nat>> is Data:
  Local{same: {releases(machine) == released : List<&2,Nat>}}
  Nested{node: Nat,outerVisited: List<&2,Nat>,outerQueued: Bool,continuation: List<&2,Q.Task>,
    shape: {tasks(machine) == B.append(Q.Task,[Q.Walk{R.Node.subs(B.node(world(machine),node)),node,node},Q.Release{0n},Q.End{}],Q.RestoreSettlement{outerVisited,released,outerQueued} <> continuation) : List<&2,Q.Task>},
    freshReleased: {releases(machine) == [] : List<&2,Nat>}}

def releaseChoice(+condition: Bool,-yes: Q.Machine,-no: Q.Machine,-released: List<&2,Nat>,left: ReleaseState<yes,released>,right: ReleaseState<no,released>) ->
  ReleaseState<B.choose(~Q.Machine,condition,_=>yes,_=>no),released>:
  match condition:
    case True{}: left
    case False{}: right

def stageRelease(+w: R.World,+tail: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+queued: Bool,+id: Nat,+root: Nat) ->
  ReleaseState<Q.stageMark(w,tail,visited,released,queued,id,root),released>:
  +dep = Q.stagedDependency(w,id)
  +scanned = B.first(R.World,Bool,dep)
  +next = B.first(R.World,Bool,P.removePendingSource(Q.stageMarkPrefix(scanned,id,root),id,id))
  +nested = {Q.Machine{next,B.append(Q.Task,Q.settlementTasks(next,id,id),Q.RestoreSettlement{visited,released,queued} <> tail),[],[],False{}} : Q.Machine}
  +body = B.choose(~Q.Machine,Bool.and(B.ok(scanned),B.second(R.World,Bool,dep)),_=>nested,_=>Q.Machine{scanned,tail,visited,released,queued})
  releaseChoice(Bool.and(B.has(R.Node.config(B.node(w,root)),K.CONFIG_STAGED_ERROR()),Bool.not(B.has(R.Node.config(B.node(w,id)),Q.stageMarkMask()))),body,Q.Machine{w,tail,visited,released,queued},released,
    releaseChoice(Bool.and(B.ok(scanned),B.second(R.World,Bool,dep)),nested,Q.Machine{scanned,tail,visited,released,queued},released,Nested{id,visited,queued,tail,{==},{==}},Local{{==}}),Local{{==}})

def settledReleaseState(+w: R.World,+tail: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+queued: Bool,+id: Nat,+root: Nat,+source: Nat,
  noAuto: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  ReleaseState<Q.settled(w,tail,visited,released,queued,id,root,source),released>:
  +prefix = prepared(w,tail,visited,released,queued,id,root,source)
  +next = world(prefix)
  +last = lastOf(w,id)
  +nextQueued = scheduled(prefix)
  +ending = {Q.Descend{id,root,source} <> tail : List<&2,Q.Task>}
  +plain = {Q.Machine{next,ending,visited,released,nextQueued} : Q.Machine}
  +rebuilt = Equal.cong(Q.Machine,Q.Machine,m=>Q.stageSettled(last,m,id,root),prefix,plain,preparedLeaf(w,tail,visited,released,queued,id,root,source,noAuto))
  +same = Equal.trans(Q.Machine,Q.settled(w,tail,visited,released,queued,id,root,source),Q.stageSettled(last,prefix,id,root),Q.stageSettled(last,plain,id,root),settledCut(w,tail,visited,released,queued,id,root,source),rebuilt)
  +back = Equal.sym(Q.Machine,Q.settled(w,tail,visited,released,queued,id,root,source),Q.stageSettled(last,plain,id,root),same)
  %back : ReleaseState<_,released>
  releaseChoice(Bool.and(B.ok(next),last),Q.stageMark(next,ending,visited,released,nextQueued,id,root),plain,released,stageRelease(next,ending,visited,released,nextQueued,id,root),Local{{==}})
