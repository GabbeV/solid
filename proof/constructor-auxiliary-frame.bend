# Actual default construction and fresh graph linking retain auxiliary arenas.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct-state.bend as N
import ../runtime/graph-state.bend as G
import ./default-computed-construction.bend as Constructed
import ./graph-empty-allocation.bend as Allocation
import ./graph-fresh-link.bend as Fresh

type View is Data:
  View{extensions: List<&2, R.NodeExtension>, sets: List<&2, List<&2, Nat>>}

def observe(+w: R.World) -> View:
  View{R.World.extensions(w), R.World.pendingSets(w)}

def extensions(view: View) -> List<&2, R.NodeExtension>:
  match view:
    case View{extensions, sets}: extensions

def sets(view: View) -> List<&2, List<&2, Nat>>:
  match view:
    case View{extensions, sets}: sets

def append(+w: R.World, node: R.Node) -> {observe(N.append(w, node)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def allocated(+w: R.World, +root: Nat, +leaf: Nat) -> {observe(Allocation.source(w, root, leaf)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def constructor(+w: R.World, +expr: R.Expr, +which: Constructed.Family,
  room: {Nat.is_lt(0n, Constructed.index(w)) == True{} : Bool}, nullComputed: {B.parentComputed(w, 0n) == 0n : Nat}) ->
  {observe(Constructed.source(w, expr, which)) == observe(w) : View}:
  Equal.trans(View, observe(Constructed.source(w, expr, which)), observe(N.append(w, Constructed.record(w, expr, which))), observe(w), Equal.cong(R.World, View, state => observe(state), Constructed.source(w, expr, which), N.append(w, Constructed.record(w, expr, which)), Constructed.exact(w, expr, which, room, nullComputed)), append(w, Constructed.record(w, expr, which)))

def linked(+w: R.World, +root: Nat, +leaf: Nat,
  depsTail: {R.Node.depsTail(B.node(w, leaf)) == 0n : Nat}, deps: {R.Node.deps(B.node(w, leaf)) == 0n : Nat}, sourceTail: {R.Node.subsTail(B.node(w, root)) == 0n : Nat}) -> {observe(G.link(w, root, leaf)) == observe(w) : View}:
  Equal.trans(View, observe(G.link(w, root, leaf)), observe(Allocation.source(w, root, leaf)), observe(w), Equal.cong(R.World, View, state => observe(state), G.link(w, root, leaf), Allocation.source(w, root, leaf), Fresh.freshEmptyDependencies(w, root, leaf, depsTail, deps, sourceTail)), allocated(w, root, leaf))

def compose(+w: R.World, +next: R.World, +last: R.World, second: {observe(last) == observe(next) : View}, first: {observe(next) == observe(w) : View}) -> {observe(last) == observe(w) : View}:
  Equal.trans(View, observe(last), observe(next), observe(w), second, first)
