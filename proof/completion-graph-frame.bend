# Graph storage and committed trace are unchanged by the completion prefix.
# This is not a claim about subsequent queued flushes or application callbacks.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ../runtime/action-state.bend as A
import ./transaction-positive-update.bend as Update
import ./transaction-positive.bend as Positive
import ./action-resolution.bend as Completion

type GraphFrame is Data:
  GraphFrame{nodes: List<&2, R.Node>, links: List<&2, R.Link>, extensions: List<&2, R.NodeExtension>, events: List<&2, R.TraceEvent>}

def graph(+w: R.World) -> GraphFrame:
  GraphFrame{R.World.nodes(w), R.World.links(w), R.World.extensions(w), R.World.events(w)}

def countWrite(+w: R.World, +tx: Nat, +remaining: Nat) ->
  {graph(Update.result(w, tx, remaining)) == graph(w) : GraphFrame}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match running scheduled halted haltNotified syncDepth:
        case _ _ True{} True{} _: {==}
        case _ _ True{} False{} _: {==}
        case _ True{} False{} _ _: {==}
        case True{} False{} False{} _ 0n: {==}
        case True{} False{} False{} _ 1n+p: {==}
        case False{} False{} False{} _ 0n: {==}
        case False{} False{} False{} _ 1n+p: {==}

def entered(+w: R.World, +tx: Nat) ->
  {graph(Positive.enter(w, tx)) == graph(w) : GraphFrame}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match judge:
        case 0n: {==}
        case 1n+p: {==}

def completion(+w: R.World, +id: Nat, +root: Nat, +remaining: Nat,
  resolution: {X.resolveTx(w, R.ActionState.transaction(A.get(w, id))) == B.Bundle{w, root} : B.Bundle<R.World, Nat>},
  positive: {R.Transaction.open(B.transaction(w, root)) == 1n+remaining : Nat}) ->
  {graph(A.done(w, id)) == graph(w) : GraphFrame}:
  Equal.trans(GraphFrame, graph(A.done(w, id)), graph(Update.result(w, root, remaining)), graph(w),
    Equal.cong(R.World, GraphFrame, state => graph(state), A.done(w, id), Update.result(w, root, remaining), Completion.decreases(w, id, root, remaining, resolution, positive)), countWrite(w, root, remaining))

def nodes(frame: GraphFrame) -> List<&2, R.Node>:
  match frame:
    case GraphFrame{values, links, extensions, events}: values

def links(frame: GraphFrame) -> List<&2, R.Link>:
  match frame:
    case GraphFrame{nodes, values, extensions, events}: values

def extensions(frame: GraphFrame) -> List<&2, R.NodeExtension>:
  match frame:
    case GraphFrame{nodes, links, values, events}: values

def events(frame: GraphFrame) -> List<&2, R.TraceEvent>:
  match frame:
    case GraphFrame{nodes, links, extensions, values}: values

def node(+w: R.World, +next: R.World, +id: Nat,
  same: {graph(next) == graph(w) : GraphFrame}) ->
  {B.node(next, id) == B.node(w, id) : R.Node}:
  Equal.cong(GraphFrame, R.Node, frame => B.get(R.Node, nodes(frame), id, B.blank_node()), graph(next), graph(w), same)

def extension(+w: R.World, +next: R.World, +id: Nat,
  same: {graph(next) == graph(w) : GraphFrame}) ->
  {B.extension(next, id) == B.extension(w, id) : R.NodeExtension}:
  Equal.cong(GraphFrame, R.NodeExtension, frame => B.get(R.NodeExtension, extensions(frame), R.Node.x(B.get(R.Node, nodes(frame), id, B.blank_node())), B.blank_extension()), graph(next), graph(w), same)
