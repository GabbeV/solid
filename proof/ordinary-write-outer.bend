# Full outer World frame for ordinary staging/heap stores. Fault and action/
# group metadata are retained; no health assertion is hidden in the observation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./onflush-registration.bend as Flush

def rest(w: R.World) -> R.World:
  R.World.with_nodes(R.World.with_buckets(R.World.with_minimum(R.World.with_maximum(R.World.with_pendingNodes(R.World.with_unflushedStaged(w,False{}),[]),0n),0n),[]),[])

def observe(w: R.World) -> R.World:
  rest(Flush.outer(w))

def worldNodes(+w: R.World,value: List<&2,R.Node>) -> {observe(R.World.with_nodes(w,value)) == observe(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldBuckets(+w: R.World,value: List<&2,Nat>) -> {observe(R.World.with_buckets(w,value)) == observe(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldMinimum(+w: R.World,value: Nat) -> {observe(R.World.with_minimum(w,value)) == observe(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldMaximum(+w: R.World,value: Nat) -> {observe(R.World.with_maximum(w,value)) == observe(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldPendingNodes(+w: R.World,value: List<&2,Nat>) -> {observe(R.World.with_pendingNodes(w,value)) == observe(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def worldUnflushedStaged(+w: R.World,value: Bool) -> {observe(R.World.with_unflushedStaged(w,value)) == observe(w) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def storeNode(+w: R.World,+id: Nat,+node: R.Node) -> {observe(B.store_node(w,id,node)) == observe(w) : R.World}:
  worldNodes(w,List.set(&2,R.Node,R.World.nodes(w),id,node))

def storeBucket(+w: R.World,+height: Nat,+id: Nat) -> {observe(B.store_bucket(w,height,id)) == observe(w) : R.World}:
  worldBuckets(w,B.put(Nat,R.World.buckets(w),height,0n,id))

def schedule(+w: R.World) -> {observe(B.schedule(w)) == observe(w) : R.World}:
  Equal.cong(R.World,R.World,state=>rest(state),Flush.outer(B.schedule(w)),Flush.outer(w),Flush.outerScheduled(w))

def compose(+a: R.World,+b: R.World,+c: R.World,last: {observe(c) == observe(b) : R.World},first: {observe(b) == observe(a) : R.World}) -> {observe(c) == observe(a) : R.World}:
  Equal.trans(R.World,observe(c),observe(b),observe(a),last,first)

def choice(+flag: Bool,+w: R.World,+yes: R.World,+no: R.World,left: {observe(yes) == observe(w) : R.World},right: {observe(no) == observe(w) : R.World}) -> {observe(B.choose(~R.World,flag,_=>yes,_=>no)) == observe(w) : R.World}:
  match flag:
    case True{}: left
    case False{}: right

def marked(+w: R.World) -> {R.World.marked(observe(w)) == R.World.marked(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def unmarked(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : R.World},known: {R.World.marked(w) == False{} : Bool}) -> {R.World.marked(next) == False{} : Bool}:
  Equal.trans(Bool,R.World.marked(next),R.World.marked(observe(next)),False{},Equal.sym(Bool,R.World.marked(observe(next)),R.World.marked(next),marked(next)),Equal.trans(Bool,R.World.marked(observe(next)),R.World.marked(observe(w)),False{},Equal.cong(R.World,Bool,state=>R.World.marked(state),observe(next),observe(w),same),Equal.trans(Bool,R.World.marked(observe(w)),R.World.marked(w),False{},marked(w),known)))

def flags(+w: R.World,+id: Nat,+value: U32) -> {observe(B.store_node(w,id,R.Node.with_flags(B.node(w,id),value))) == observe(w) : R.World}:
  storeNode(w,id,R.Node.with_flags(B.node(w,id),value))

def height(+w: R.World,+id: Nat,+value: Nat) -> {observe(B.store_node(w,id,R.Node.with_height(B.node(w,id),value))) == observe(w) : R.World}:
  storeNode(w,id,R.Node.with_height(B.node(w,id),value))

def nextHeap(+w: R.World,+id: Nat,+value: Nat) -> {observe(B.store_node(w,id,R.Node.with_nextHeap(B.node(w,id),value))) == observe(w) : R.World}:
  storeNode(w,id,R.Node.with_nextHeap(B.node(w,id),value))

def prevHeap(+w: R.World,+id: Nat,+value: Nat) -> {observe(B.store_node(w,id,R.Node.with_prevHeap(B.node(w,id),value))) == observe(w) : R.World}:
  storeNode(w,id,R.Node.with_prevHeap(B.node(w,id),value))

def links(+w: R.World) -> {R.World.links(observe(w)) == R.World.links(w) : List<&2,R.Link>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameLinks(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : R.World}) -> {R.World.links(next) == R.World.links(w) : List<&2,R.Link>}:
  Equal.trans(List<&2,R.Link>,R.World.links(next),R.World.links(observe(next)),R.World.links(w),Equal.sym(List<&2,R.Link>,R.World.links(observe(next)),R.World.links(next),links(next)),Equal.trans(List<&2,R.Link>,R.World.links(observe(next)),R.World.links(observe(w)),R.World.links(w),Equal.cong(R.World,List<&2,R.Link>,state=>R.World.links(state),observe(next),observe(w),same),links(w)))

def readContext(+w: R.World) -> {R.World.context(observe(w)) == R.World.context(w) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def context(+base: R.World,+w: R.World,same: {observe(w) == observe(base) : R.World},known: {R.World.context(base) == 0n : Nat}) -> {R.World.context(w) == 0n : Nat}:
  Equal.trans(Nat,R.World.context(w),R.World.context(observe(w)),0n,Equal.sym(Nat,R.World.context(observe(w)),R.World.context(w),readContext(w)),Equal.trans(Nat,R.World.context(observe(w)),R.World.context(observe(base)),0n,Equal.cong(R.World,Nat,state=>R.World.context(state),observe(w),observe(base),same),Equal.trans(Nat,R.World.context(observe(base)),R.World.context(base),0n,readContext(base),known)))

def readFault(+w: R.World) -> {R.World.fault(observe(w)) == R.World.fault(w) : R.Fault}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def health(+base: R.World,+w: R.World,same: {observe(w) == observe(base) : R.World},known: {R.World.fault(base) == R.Healthy{} : R.Fault}) -> {R.World.fault(w) == R.Healthy{} : R.Fault}:
  Equal.trans(R.Fault,R.World.fault(w),R.World.fault(observe(w)),R.Healthy{},Equal.sym(R.Fault,R.World.fault(observe(w)),R.World.fault(w),readFault(w)),Equal.trans(R.Fault,R.World.fault(observe(w)),R.World.fault(observe(base)),R.Healthy{},Equal.cong(R.World,R.Fault,state=>R.World.fault(state),observe(w),observe(base),same),Equal.trans(R.Fault,R.World.fault(observe(base)),R.World.fault(base),R.Healthy{},readFault(base),known)))

def readComparators(+w: R.World) -> {R.World.comparators(observe(w)) == R.World.comparators(w) : List<&2,R.ComparatorBinding>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameComparators(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : R.World}) -> {R.World.comparators(next) == R.World.comparators(w) : List<&2,R.ComparatorBinding>}:
  Equal.trans(List<&2,R.ComparatorBinding>,R.World.comparators(next),R.World.comparators(observe(next)),R.World.comparators(w),Equal.sym(List<&2,R.ComparatorBinding>,R.World.comparators(observe(next)),R.World.comparators(next),readComparators(next)),Equal.trans(List<&2,R.ComparatorBinding>,R.World.comparators(observe(next)),R.World.comparators(observe(w)),R.World.comparators(w),Equal.cong(R.World,List<&2,R.ComparatorBinding>,state=>R.World.comparators(state),observe(next),observe(w),same),readComparators(w)))

def readTxArena(+w: R.World) -> {R.World.txArena(observe(w)) == R.World.txArena(w) : List<&2,R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameTxArena(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : R.World}) -> {R.World.txArena(next) == R.World.txArena(w) : List<&2,R.Transaction>}:
  Equal.trans(List<&2,R.Transaction>,R.World.txArena(next),R.World.txArena(observe(next)),R.World.txArena(w),Equal.sym(List<&2,R.Transaction>,R.World.txArena(observe(next)),R.World.txArena(next),readTxArena(next)),Equal.trans(List<&2,R.Transaction>,R.World.txArena(observe(next)),R.World.txArena(observe(w)),R.World.txArena(w),Equal.cong(R.World,List<&2,R.Transaction>,state=>R.World.txArena(state),observe(next),observe(w),same),readTxArena(w)))

def readActions(+w: R.World) -> {R.World.actions(observe(w)) == R.World.actions(w) : List<&2,R.ActionState>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameActions(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : R.World}) -> {R.World.actions(next) == R.World.actions(w) : List<&2,R.ActionState>}:
  Equal.trans(List<&2,R.ActionState>,R.World.actions(next),R.World.actions(observe(next)),R.World.actions(w),Equal.sym(List<&2,R.ActionState>,R.World.actions(observe(next)),R.World.actions(next),readActions(next)),Equal.trans(List<&2,R.ActionState>,R.World.actions(observe(next)),R.World.actions(observe(w)),R.World.actions(w),Equal.cong(R.World,List<&2,R.ActionState>,state=>R.World.actions(state),observe(next),observe(w),same),readActions(w)))

def readActionWaits(+w: R.World) -> {R.World.actionWaits(observe(w)) == R.World.actionWaits(w) : List<&2,R.ActionWait>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sameActionWaits(+w: R.World,+next: R.World,same: {observe(next) == observe(w) : R.World}) -> {R.World.actionWaits(next) == R.World.actionWaits(w) : List<&2,R.ActionWait>}:
  Equal.trans(List<&2,R.ActionWait>,R.World.actionWaits(next),R.World.actionWaits(observe(next)),R.World.actionWaits(w),Equal.sym(List<&2,R.ActionWait>,R.World.actionWaits(observe(next)),R.World.actionWaits(next),readActionWaits(next)),Equal.trans(List<&2,R.ActionWait>,R.World.actionWaits(observe(next)),R.World.actionWaits(observe(w)),R.World.actionWaits(w),Equal.cong(R.World,List<&2,R.ActionWait>,state=>R.World.actionWaits(state),observe(next),observe(w),same),readActionWaits(w)))
