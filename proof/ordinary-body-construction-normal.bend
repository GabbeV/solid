# Actual signal/render/link/action construction supplies the body profile and
# original captured-group debt. This is a constructed controller entry, not a
# proof of every public generator invocation or external callback delivery.
import Base
import ./action-constructor-state.bend as Data
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./ordinary-write-constructed.bend as Graph
import ./ordinary-body-entry.bend as Entry
import ./action-body-entry.bend as Prepared
import ./action-first-frame.bend as First

def created(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> B.Bundle<R.World,Nat>:
  Data.created(initial,First.expression(Entry.method(values,Graph.source(initial),answer,R.ActionEnd{})))

def actor(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> Nat:
  Data.actor(initial,First.expression(Entry.method(values,Graph.source(initial),answer,R.ActionEnd{})))

def opened(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> R.World:
  Data.opened(initial,First.expression(Entry.method(values,Graph.source(initial),answer,R.ActionEnd{})))

def ready(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> R.World:
  Prepared.prepared(opened(initial,values,answer),actor(initial,values,answer),R.ActionEnd{})

# Proof normal form of this closed constructor family; the equation below
# checks it against actual create/open/captured resume, with no runtime change.
def normalized(w: R.World) -> R.World:
  Data.normalized(w)

def normalizedExact(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> {ready(initial,values,answer) == normalized(Graph.linked(initial)) : R.World}:
  {==}

def nodes(+w: R.World) -> {R.World.nodes(normalized(w)) == R.World.nodes(w) : List<&2,R.Node>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def links(+w: R.World) -> {R.World.links(normalized(w)) == R.World.links(w) : List<&2,R.Link>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def comparators(+w: R.World) -> {R.World.comparators(normalized(w)) == R.World.comparators(w) : List<&2,R.ComparatorBinding>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def fault(+w: R.World) -> {R.World.fault(normalized(w)) == R.World.fault(w) : R.Fault}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def marked(+w: R.World) -> {R.World.marked(normalized(w)) == R.World.marked(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def context(+w: R.World) -> {R.World.context(normalized(w)) == R.World.context(w) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def actorZero(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> {actor(initial,values,answer) == 0n : Nat}:
  {==}

def stopped(+initial: R.Value) -> {R.Transaction.into(B.transaction(normalized(Graph.linked(initial)),1n)) == 0n : Nat}:
  {==}

def groupRoom(+initial: R.Value) -> {1n+B.length(R.Transaction,R.World.txArena(normalized(Graph.linked(initial)))) == 3n : Nat}:
  {==}

def openCount(+initial: R.Value) -> {R.Transaction.open(B.transaction(normalized(Graph.linked(initial)),1n)) == 1n : Nat}:
  {==}

def captured(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> {R.ActionState.transaction(A.get(normalized(Graph.linked(initial)),actor(initial,values,answer))) == 1n : Nat}:
  Equal.cong(Nat,Nat,id=>R.ActionState.transaction(A.get(normalized(Graph.linked(initial)),id)),actor(initial,values,answer),0n,actorZero(initial,values,answer))

def groupValid(+initial: R.Value) -> {Nat.is_lt(1n,B.length(R.Transaction,R.World.txArena(normalized(Graph.linked(initial))))) == True{} : Bool}:
  {==}

# The normalized constructor installs one real actor captured in group one.
def capturedZero(+w: R.World) -> {R.ActionState.transaction(A.get(normalized(w),0n)) == 1n : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}
