# Removing a pending-source entry changes only its Set/extension bookkeeping.
# The actual nodes, intrusive links and fault are preserved, including absence.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ./pending-source-committed-frame.bend as Source

type View is Data:
  View{nodes: List<&2, R.Node>, links: List<&2, R.Link>, fault: R.Fault}

def observe(+w: R.World) -> View:
  View{R.World.nodes(w), R.World.links(w), R.World.fault(w)}

def nodes(view: View) -> List<&2, R.Node>:
  match view:
    case View{nodes, links, fault}: nodes

def links(view: View) -> List<&2, R.Link>:
  match view:
    case View{nodes, links, fault}: links

def fault(view: View) -> R.Fault:
  match view:
    case View{nodes, links, fault}: fault

def compose(+w: R.World, +next: R.World, +last: R.World,
  second: {observe(last) == observe(next) : View}, first: {observe(next) == observe(w) : View}) ->
  {observe(last) == observe(w) : View}:
  Equal.trans(View, observe(last), observe(next), observe(w), second, first)

def choice(+condition: Bool, +w: R.World, +left: R.World, +right: R.World,
  leftFrame: {observe(left) == observe(w) : View}, rightFrame: {observe(right) == observe(w) : View}) ->
  {observe(B.choose(~R.World, condition, _ => left, _ => right)) == observe(w) : View}:
  match condition:
    case True{}: leftFrame
    case False{}: rightFrame

def pairChoice(+condition: Bool, +w: R.World, +left: B.Bundle<R.World, Bool>, +right: B.Bundle<R.World, Bool>,
  leftFrame: {observe(B.first(R.World, Bool, left)) == observe(w) : View}, rightFrame: {observe(B.first(R.World, Bool, right)) == observe(w) : View}) ->
  {observe(B.first(R.World, Bool, B.choose(~B.Bundle<R.World, Bool>, condition, _ => left, _ => right))) == observe(w) : View}:
  match condition:
    case True{}: leftFrame
    case False{}: rightFrame

def storePending(w: R.World, set: Nat, items: List<&2, Nat>) ->
  {observe(B.store_pendingSet(w, set, items)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def storeExtension(w: R.World, id: Nat, extension: R.NodeExtension) ->
  {observe(B.store_extension(w, id, extension)) == observe(w) : View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def removeTail(+w: R.World, +id: Nat, +source: Nat) ->
  {observe(Source.removeTail(w, id, source)) == observe(w) : View}:
  +set = R.NodeExtension.pendingSources(B.extension(w, id))
  +items = P.removeSlot(B.pendingSlots(w, set), source)
  +next = B.store_pendingSet(w, set, items)
  +record = R.NodeExtension.with_pendingSources(B.extension(next, id), 0n)
  compose(w, next, Source.removeTail(w, id, source), choice(List.is_empty(&2, Nat, B.liveIds(items)), next, B.store_extension(next, id, record), next, storeExtension(next, id, record), {==}), storePending(w, set, items))

def removed(+w: R.World, +id: Nat, +source: Nat) ->
  {observe(B.first(R.World, Bool, P.removePendingSource(w, id, source))) == observe(w) : View}:
  pairChoice(P.hasSource(w, id, source), w, B.Bundle{Source.removeTail(w, id, source), True{}}, B.Bundle{w, False{}}, removeTail(w, id, source), {==})

def node(+w: R.World, +id: Nat, +source: Nat, +read: Nat) ->
  {B.node(B.first(R.World, Bool, P.removePendingSource(w, id, source)), read) == B.node(w, read) : R.Node}:
  Equal.cong(View, R.Node, view => B.get(R.Node, nodes(view), read, B.blank_node()), observe(B.first(R.World, Bool, P.removePendingSource(w, id, source))), observe(w), removed(w, id, source))

def health(+w: R.World, +id: Nat, +source: Nat) ->
  {B.ok(B.first(R.World, Bool, P.removePendingSource(w, id, source))) == B.ok(w) : Bool}:
  Equal.cong(View, Bool, view => B.healthy(fault(view)), observe(B.first(R.World, Bool, P.removePendingSource(w, id, source))), observe(w), removed(w, id, source))

def scheduleHealth(+w: R.World) ->
  {B.ok(B.schedule(w)) == B.ok(w) : Bool}:
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

# Composition works at opaque World boundaries, including exhausted/faulted
# Worlds. Preservation does not turn exhaustion into successful progress.
