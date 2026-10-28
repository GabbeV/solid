# Split constructor equations at real create/open and captured-resume boundaries.
# The generic method argument avoids repeatedly reducing its finite body grammar.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./action-constructor-state.bend as Normal
import ./ordinary-graph-data.bend as Graph

def openedNormalized(w: R.World,methods: R.Expr) -> R.World:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      R.World{nodes, links, buckets, minimum, maximum, marked, pendingNodes, trims, renderQueue, userQueue, context, tracking, running, scheduled, clock, epoch, tree, events, fault, unflushedStaged, promotedWrites, extensions, cleanupPrograms, dormantNodes, errorSerial, halted, haltNotified, reports, callbackEffect, B.append(R.Transaction,txArena,[R.Transaction{[],[],[],[],0n,0n,False{},0n,1n,True{},0n,False{},False{},R.NoIds{}}]), B.append(Nat,transactions,[1n]), flushTransaction, passTx, passLane, judge, deferredZombies, question, pendingSets, B.append(R.AsyncObject,asyncObjects,[R.AsyncObject{False{},R.Unresolved{},[],0n}]), asyncObservers, hostJobs, syncDepth, streamPlans, iterators, streams, iteratorEvents, awaiters, truthReadHook, truthConfirmedHook, R.QuestionOdd{R.QuestionZero{}}, abortInputs, contextKeys, contextRecords, deferredReleases, releaseLists, stale, settledCallbacks, reactions, comparators, actionDepth, [R.ActionState{1n,R.QuestionOdd{R.QuestionZero{}},methods,1n}], actionWaits, arrays, repeats, maps, activeMarks, laneState, verdictState, cleanupError, ambientMarks, deferredArena}

def openedExact(+initial: R.Value,+methods: R.Expr) -> {Normal.opened(initial,methods) == openedNormalized(Graph.linked(initial),methods) : R.World}:
  {==}
