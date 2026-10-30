# Controller setup/preparation/retirement changes bookkeeping, not heap intake.
import Base
import ../proof/transaction-pair.bend as PairId
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ../proof/action-body-entry.bend as Entry
import ../proof/action-body-retirement.bend as Exit
import ../proof/ordinary-graph-data.bend as Graph
import ../proof/action-constructor-state.bend as Constructor
import ../proof/held-opened-state.bend as First
import ../proof/held-pair-generic-state.bend as Pair
import ../proof/holding-outer.bend as Hold
import ./heap-entry-view.bend as View
import ./transaction-heap-entry.bend as Tx
import ./masked-projection.bend as Projection

def create(+w: R.World,+methods: R.Expr) -> {View.observe(B.first(R.World,Nat,A.create(w,methods))) == View.observe(w) : View.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def open(+w: R.World,+actor: Nat) -> {View.observe(A.open(w,actor)) == View.observe(w) : View.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def store(+w: R.World,id: Nat,state: R.ActionState) -> {View.observe(A.store(w,id,state)) == View.observe(w) : View.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def enter(+w: R.World) -> {View.observe(A.enter(w)) == View.observe(w) : View.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def exit(+w: R.World) -> {View.observe(A.exit(w)) == View.observe(w) : View.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def asked(+w: R.World,actor: Nat) -> {View.observe(Entry.asked(w,actor)) == View.observe(w) : View.View}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def joined(+w: R.World,+actor: Nat) -> {View.observe(Entry.joined(w,actor)) == View.observe(w) : View.View}:
  View.compose(w,Entry.asked(w,actor),Entry.joined(w,actor),Tx.joinFuture(Entry.asked(w,actor),R.ActionState.transaction(A.get(w,actor))),asked(w,actor))

def prepared(+w: R.World,+actor: Nat,+tail: R.Expr) -> {View.observe(Entry.prepared(w,actor,tail)) == View.observe(w) : View.View}:
  +next = Entry.joined(w,actor)
  +entered = A.enter(next)
  View.compose(w,next,Entry.prepared(w,actor,tail),View.compose(next,entered,Entry.prepared(w,actor,tail),store(entered,actor,R.ActionState.with_methods(A.get(next,actor),tail)),enter(next)),joined(w,actor))

def target(+w: R.World,+root: Nat,+remaining: Nat) -> {View.observe(Exit.target(w,root,remaining)) == View.observe(w) : View.View}:
  +next = A.exit(w)
  +stored = B.store_transaction(next,root,R.Transaction.with_open(B.transaction(next,root),remaining))
  View.compose(w,next,Exit.target(w,root,remaining),View.compose(next,stored,Exit.target(w,root,remaining),View.schedule(stored),View.transaction(next,root,R.Transaction.with_open(B.transaction(next,root),remaining))),exit(w))

def firstController(+value: R.Value,+methods: R.Expr) -> {View.observe(Constructor.opened(value,methods)) == View.observe(Graph.linked(value)) : View.View}:
  +before = Graph.linked(value)
  +pair = A.create(before,methods)
  +next = B.first(R.World,Nat,pair)
  View.compose(before,next,Constructor.opened(value,methods),open(next,B.second(R.World,Nat,pair)),create(before,methods))

def heldController(+value: R.Value,+methods: R.Expr) -> {View.observe(First.opened(value,methods)) == View.observe(Graph.linked(value)) : View.View}:
  +next = Constructor.opened(value,methods)
  View.compose(Graph.linked(value),next,First.opened(value,methods),Projection.transport(View.View,View.observe,Hold.observe,next,First.opened(value,methods),Hold.node(next,Graph.source(value),1n),View.holdMasked(next),View.holdMasked(First.opened(value,methods))),firstController(value,methods))

def secondController(+w: R.World,+methods: R.Expr) -> {View.observe(Pair.opened(w,methods)) == View.observe(w) : View.View}:
  +pair = A.create(w,methods)
  +next = B.first(R.World,Nat,pair)
  View.compose(w,next,Pair.opened(w,methods),open(next,B.second(R.World,Nat,pair)),create(w,methods))

def pair(+w: R.World,+methods: R.Expr,+reverse: Bool) -> {View.observe(Pair.joined(w,methods,reverse)) == View.observe(w) : View.View}:
  +next = Pair.opened(w,methods)
  View.compose(w,next,Pair.joined(w,methods,reverse),Tx.merge(next,PairId.sourceId([],[],reverse),PairId.targetId([],[],reverse)),secondController(w,methods))

def graph(+value: R.Value) -> {View.observe(Graph.linked(value)) == View.HeapEntry{[],[],[0n],0n,0n,[]} : View.View}:
  {==}
