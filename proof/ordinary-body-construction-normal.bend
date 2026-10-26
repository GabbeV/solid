# Actual signal/render/link/action construction supplies the body profile and
# original captured-group debt. This is a constructed controller entry, not a
# proof of every public generator invocation or external callback delivery.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ../runtime/constants.bend as K
import ../runtime/equality.bend as Equality
import ./ordinary-write-constructed.bend as Graph
import ./ordinary-write-profile.bend as P
import ./ordinary-write-history.bend as History
import ./ordinary-body-evaluation.bend as Eval
import ./ordinary-body-return.bend as Body
import ./ordinary-body-entry.bend as Entry
import ./ordinary-body-retirement.bend as Retire
import ./action-body-entry.bend as Prepared
import ./action-body-retirement.bend as Exit
import ./action-first-frame.bend as First
import ./action-output-frame.bend as Output
import ./subscriber-walk-step.bend as Path
import ./transaction-resolution.bend as Routes
import ./pending-stack-history.bend as Steps

def created(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> B.Bundle<R.World,Nat>:
  A.create(Graph.linked(initial),First.expression(Entry.method(values,Graph.source(initial),answer,R.ActionEnd{})))

def actor(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> Nat:
  B.second(R.World,Nat,created(initial,values,answer))

def opened(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> R.World:
  +pair = created(initial,values,answer)
  A.open(B.first(R.World,Nat,pair),B.second(R.World,Nat,pair))

def ready(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> R.World:
  Prepared.prepared(opened(initial,values,answer),actor(initial,values,answer),R.ActionEnd{})

# Proof normal form of this closed constructor family; the equation below
# checks it against actual create/open/captured resume, with no runtime change.
def normalized(w: R.World) -> R.World:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      R.World{nodes, links, buckets, minimum, maximum, marked, pendingNodes, trims, renderQueue, userQueue, context, tracking, running, True{}, clock, epoch, tree, events, fault, unflushedStaged, promotedWrites, extensions, cleanupPrograms, dormantNodes, errorSerial, halted, haltNotified, reports, callbackEffect, B.append(R.Transaction,txArena,[R.Transaction{[],[],[],[],0n,0n,False{},0n,1n,True{},0n,False{},False{},R.NoIds{}}]), B.append(Nat,transactions,[1n]), 1n, passTx, passLane, judge, deferredZombies, R.QuestionOdd{R.QuestionZero{}}, pendingSets, B.append(R.AsyncObject,asyncObjects,[R.AsyncObject{False{},R.Unresolved{},[],0n}]), asyncObservers, B.append(R.HostJob,hostJobs,[R.FlushJob{}]), syncDepth, streamPlans, iterators, streams, iteratorEvents, awaiters, truthReadHook, truthConfirmedHook, R.QuestionOdd{R.QuestionZero{}}, abortInputs, contextKeys, contextRecords, deferredReleases, releaseLists, stale, settledCallbacks, reactions, comparators, 1n, [R.ActionState{1n,R.QuestionOdd{R.QuestionZero{}},R.ActionEnd{},1n}], actionWaits, arrays, repeats, maps, activeMarks, laneState, verdictState, cleanupError, ambientMarks, deferredArena}

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
