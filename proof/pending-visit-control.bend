# A visitor's control observation ignores its computed World. Both source early
# returns and successful leaf retirement are admitted; no error is suppressed.
import Base
import ../runtime/heap.bend as H
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending.bend as Q
import ../runtime/pending-state.bend as P
import ../runtime/constants.bend as K
import ./staged-subscriber-frame.bend as Topology
import ./pending-topology-frame.bend as Graph
import ./pending-machine-shape.bend as Machine
import ./pending-removal-footprint.bend as Removal
import ./topology-source-frame.bend as Source

type View is Data:
  View{tasks: List<&2, Q.Task>, released: List<&2, Nat>}

def observe(+machine: Q.Machine) -> View:
  View{Machine.tasks(machine), Machine.releases(machine)}

# The source now descends only after a successful visitor body (and any
# nested stage-error settlement). Capture both source continuations explicitly.
def continuation(+after: Bool,node: Nat,root: Nat,source: Nat,+tail: List<&2,Q.Task>) -> List<&2,Q.Task>:
  B.choose(~List<&2,Q.Task>,after,_=>Q.Descend{node,root,source} <> tail,_=>tail)

type Next<-machine: Q.Machine, -tail: List<&2, Q.Task>, -released: List<&2, Nat>, -root: Nat, -source: Nat> is Data:
  Direct{shape: {observe(machine) == View{tail, released} : View}}
  Leaf{node: Nat,
    shape: {observe(machine) == View{Q.Descend{node,root,source} <> tail,released} : View},
    noSubscribers: {R.Node.subs(B.node(Machine.world(machine),node)) == 0n : Nat}}
  Nested{node: Nat, visited: List<&2,Nat>, queued: Bool, after: Bool,
    shape: {observe(machine) == View{B.append(Q.Task,[Q.Walk{0n,node,node},Q.Release{0n},Q.End{}],Q.RestoreSettlement{visited,released,queued} <> continuation(after,node,root,source,tail)),[]} : View},
    freshVisits: {Machine.visits(machine) == [] : List<&2,Nat>},
    freshScheduled: {Machine.scheduled(machine) == False{} : Bool},
    noSubscribers: {R.Node.subs(B.node(Machine.world(machine),node)) == 0n : Nat}}

def choice(+condition: Bool, -left: Q.Machine, -right: Q.Machine, -tail: List<&2, Q.Task>, -released: List<&2, Nat>, -root: Nat, -source: Nat,
  yes: Next<left, tail, released, root, source>, no: Next<right, tail, released, root, source>) ->
  Next<B.choose(~Q.Machine, condition, _ => left, _ => right), tail, released, root, source>:
  match condition:
    case True{}: yes
    case False{}: no

def emptyAt(+w: R.World,+next: R.World,+id: Nat,frame: {Topology.observe(next) == Topology.observe(w) : Topology.View},zero: {R.Node.subs(B.node(w,id)) == 0n : Nat}) ->
  {R.Node.subs(B.node(next,id)) == 0n : Nat}:
  Equal.trans(Nat,R.Node.subs(B.node(next,id)),R.Node.subs(B.node(w,id)),0n,Equal.cong(Topology.Shape,Nat,shape=>Machine.subs(shape),Topology.shape(B.node(next,id)),Topology.shape(B.node(w,id)),Topology.read(w,next,id,frame)),zero)

def base(+after: Bool,+w: R.World,+tail: List<&2,Q.Task>,visited: List<&2,Nat>,+released: List<&2,Nat>,queued: Bool,+id: Nat,+root: Nat,+source: Nat,zero: {R.Node.subs(B.node(w,id)) == 0n : Nat}) ->
  Next<Q.Machine{w,continuation(after,id,root,source,tail),visited,released,queued},tail,released,root,source>:
  match after:
    case True{}: Leaf{id,{==},zero}
    case False{}: Direct{{==}}

def stageMark(+w: R.World,+tail: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+queued: Bool,+id: Nat,+root: Nat,+source: Nat,+after: Bool,
  +noSubscribers: {R.Node.subs(B.node(w,id)) == 0n : Nat}) -> Next<Q.stageMark(w,continuation(after,id,root,source,tail),visited,released,queued,id,root),tail,released,root,source>:
  +ending = continuation(after,id,root,source,tail)
  +dep = Q.stagedDependency(w,id)
  +scanned = B.first(R.World,Bool,dep)
  +scanFrame = Graph.stagedDependency(B.budget(w),w,R.Node.deps(B.node(w,id)))
  +scannedZero = emptyAt(w,scanned,id,scanFrame,noSubscribers)
  +prefix = Q.stageMarkPrefix(scanned,id,root)
  +next = B.first(R.World,Bool,P.removePendingSource(prefix,id,id))
  +frame = Topology.compose(scanned,prefix,next,Topology.exact(prefix,next,Source.remove(prefix,id,id)),Graph.stagePrefix(scanned,id,root))
  +zero = emptyAt(scanned,next,id,frame,scannedZero)
  +nested = {Q.Machine{next,B.append(Q.Task,Q.settlementTasks(next,id,id),Q.RestoreSettlement{visited,released,queued} <> ending),[],[],False{}} : Q.Machine}
  +body = B.choose(~Q.Machine,Bool.and(B.ok(scanned),B.second(R.World,Bool,dep)),_=>nested,_=>Q.Machine{scanned,ending,visited,released,queued})
  +nestedShape = Equal.cong(Nat,View,edge=>View{B.append(Q.Task,[Q.Walk{edge,id,id},Q.Release{0n},Q.End{}],Q.RestoreSettlement{visited,released,queued} <> ending),[]},R.Node.subs(B.node(next,id)),0n,zero)
  choice(Bool.and(B.has(R.Node.config(B.node(w,root)),K.CONFIG_STAGED_ERROR()),Bool.not(B.has(R.Node.config(B.node(w,id)),Q.stageMarkMask()))),body,Q.Machine{w,ending,visited,released,queued},tail,released,root,source,
    choice(Bool.and(B.ok(scanned),B.second(R.World,Bool,dep)),nested,Q.Machine{scanned,ending,visited,released,queued},tail,released,root,source,Nested{id,visited,queued,after,nestedShape,{==},{==},zero},base(after,scanned,tail,visited,released,queued,id,root,source,scannedZero)),
    base(after,w,tail,visited,released,queued,id,root,source,noSubscribers))

def skip(+w: R.World,+tail: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+queued: Bool,+id: Nat,+root: Nat,+source: Nat,
  noSubscribers: {R.Node.subs(B.node(w,id)) == 0n : Nat}) -> Next<Q.skip(w,tail,visited,released,queued,id,root),tail,released,root,source>:
  choice(B.has(R.Node.config(B.node(w,id)),K.CONFIG_VERDICT()),Q.Machine{H.enqueueSub(w,id),tail,visited,released,queued},Q.stageMark(w,tail,visited,released,queued,id,root),tail,released,root,source,Direct{{==}},stageMark(w,tail,visited,released,queued,id,root,source,False{},noSubscribers))

def settled(+w: R.World,+tail: List<&2,Q.Task>,+visited: List<&2,Nat>,+released: List<&2,Nat>,+queued: Bool,+id: Nat,+root: Nat,+source: Nat,
  noSubscribers: {R.Node.subs(B.node(w,id)) == 0n : Nat},noAuto: {B.has(R.Node.config(B.node(w,id)),K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  Next<Q.settled(w,tail,visited,released,queued,id,root,source),tail,released,root,source>:
  +prefix = Machine.prepared(w,tail,visited,released,queued,id,root,source)
  +next = Machine.world(prefix)
  +last = Machine.lastOf(w,id)
  +nextQueued = Machine.scheduled(prefix)
  +zero = emptyAt(w,next,id,Machine.preparedFrame(w,tail,visited,released,queued,id,root,source),noSubscribers)
  +plain = {Q.Machine{next,Q.Descend{id,root,source} <> tail,visited,released,nextQueued} : Q.Machine}
  +rebuilt = Equal.cong(Q.Machine,Q.Machine,m=>Q.stageSettled(last,m,id,root),prefix,plain,Machine.preparedLeaf(w,tail,visited,released,queued,id,root,source,noAuto))
  +same = Equal.trans(Q.Machine,Q.settled(w,tail,visited,released,queued,id,root,source),Q.stageSettled(last,prefix,id,root),Q.stageSettled(last,plain,id,root),Machine.settledCut(w,tail,visited,released,queued,id,root,source),rebuilt)
  +back = Equal.sym(Q.Machine,Q.settled(w,tail,visited,released,queued,id,root,source),Q.stageSettled(last,plain,id,root),same)
  %back : Next<_,tail,released,root,source>
  choice(Bool.and(B.ok(next),last),Q.stageMark(next,Q.Descend{id,root,source} <> tail,visited,released,nextQueued,id,root),plain,tail,released,root,source,
    stageMark(next,tail,visited,released,nextQueued,id,root,source,True{},zero),base(True{},next,tail,visited,released,nextQueued,id,root,source,zero))

def removed(+w: R.World, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +queued: Bool, +id: Nat, +root: Nat, +source: Nat,
  noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  Next<Q.visitRemoved(w, tail, visited, released, queued, id, root, source), tail, released, root, source>:
  +pair = P.removePendingSource(w, id, source)
  +next = B.first(R.World, Bool, pair)
  +nodeSame = Removal.node(w, id, source, id)
  +subscribers = Equal.trans(Nat, R.Node.subs(B.node(next, id)), R.Node.subs(B.node(w, id)), 0n, Equal.cong(R.Node, Nat, node => R.Node.subs(node), B.node(next, id), B.node(w, id), nodeSame), noSubscribers)
  +automatic = Equal.trans(Bool, B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE()), B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()), False{}, Equal.cong(R.Node, Bool, node => B.has(R.Node.config(node), K.CONFIG_AUTO_DISPOSE()), B.node(next, id), B.node(w, id), nodeSame), noAuto)
  choice(B.second(R.World, Bool, pair), Q.settled(next, tail, visited, released, queued, id, root, source), Q.skip(next, tail, visited, released, queued, id, root), tail, released, root, source,
    settled(next, tail, visited, released, queued, id, root, source, subscribers, automatic), skip(next, tail, visited, released, queued, id, root, source, subscribers))

def visit(+w: R.World, +tail: List<&2, Q.Task>, +visited: List<&2, Nat>, +released: List<&2, Nat>, +queued: Bool, +id: Nat, +root: Nat, +source: Nat,
  +noSubscribers: {R.Node.subs(B.node(w, id)) == 0n : Nat}, noAuto: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}) ->
  Next<Q.advance(w, Q.Visit{id, root, source} <> tail, visited, released, queued), tail, released, root, source>:
  +pair = B.choose(~B.Bundle<R.World, Bool>, Nat.is_ne(source, root), _ => P.retryReaches(w, id, source), _ => B.Bundle{w, False{}})
  +next = B.first(R.World, Bool, pair)
  +frame = Topology.firstBoolChoice(Nat.is_ne(source, root), w, P.retryReaches(w, id, source), B.Bundle{w, False{}}, Graph.retry(B.budget(w), w, R.Node.deps(B.node(w, id)), source), {==})
  +nodeSame = Topology.read(w, next, id, frame)
  +subscribers = Equal.trans(Nat, R.Node.subs(B.node(next, id)), R.Node.subs(B.node(w, id)), 0n, Equal.cong(Topology.Shape, Nat, shape => Machine.subs(shape), Topology.shape(B.node(next, id)), Topology.shape(B.node(w, id)), nodeSame), noSubscribers)
  +automatic = Equal.trans(Bool, B.has(R.Node.config(B.node(next, id)), K.CONFIG_AUTO_DISPOSE()), B.has(R.Node.config(B.node(w, id)), K.CONFIG_AUTO_DISPOSE()), False{}, Topology.autoRead(w, next, id, frame), noAuto)
  +after = B.choose(~Q.Machine, B.second(R.World, Bool, pair), _ => Q.skip(next, tail, visited, released, queued, id, root), _ => Q.visitRemoved(next, tail, visited, released, queued, id, root, source))
  choice(B.contains(visited, id), Q.skip(w, tail, visited, released, queued, id, root), after, tail, released, root, source,
    skip(w, tail, visited, released, queued, id, root, source, noSubscribers),
    choice(B.second(R.World, Bool, pair), Q.skip(next, tail, visited, released, queued, id, root), Q.visitRemoved(next, tail, visited, released, queued, id, root, source), tail, released, root, source,
      skip(next, tail, visited, released, queued, id, root, source, subscribers), removed(next, tail, visited, released, queued, id, root, source, subscribers, automatic)))
