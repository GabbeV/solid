# Real raw action allocation/opening at an arbitrary method header, and its
# proof-only constructor normal form. Normalized is checked by separate proofs.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ./ordinary-graph-data.bend as Graph

def created(+initial: R.Value,methods: R.Expr) -> B.Bundle<R.World,Nat>:
  A.create(Graph.linked(initial),methods)

def actor(+initial: R.Value,+methods: R.Expr) -> Nat:
  B.second(R.World,Nat,created(initial,methods))

def opened(+initial: R.Value,+methods: R.Expr) -> R.World:
  +pair = created(initial,methods)
  A.open(B.first(R.World,Nat,pair),B.second(R.World,Nat,pair))

def normalized(w: R.World) -> R.World:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      R.World{nodes, links, buckets, minimum, maximum, marked, pendingNodes, trims, renderQueue, userQueue, context, tracking, running, True{}, clock, epoch, tree, events, fault, unflushedStaged, promotedWrites, extensions, cleanupPrograms, dormantNodes, errorSerial, halted, haltNotified, reports, callbackEffect, B.append(R.Transaction,txArena,[R.Transaction{[],[],[],[],0n,0n,False{},0n,1n,True{},0n,False{},False{},R.NoIds{}}]), B.append(Nat,transactions,[1n]), 1n, passTx, passLane, judge, deferredZombies, R.QuestionOdd{R.QuestionZero{}}, pendingSets, B.append(R.AsyncObject,asyncObjects,[R.AsyncObject{False{},R.Unresolved{},[],0n}]), asyncObservers, B.append(R.HostJob,hostJobs,[R.FlushJob{}]), syncDepth, streamPlans, iterators, streams, iteratorEvents, awaiters, truthReadHook, truthConfirmedHook, R.QuestionOdd{R.QuestionZero{}}, abortInputs, contextKeys, contextRecords, deferredReleases, releaseLists, stale, settledCallbacks, reactions, comparators, 1n, [R.ActionState{1n,R.QuestionOdd{R.QuestionZero{}},R.ActionEnd{},1n}], actionWaits, arrays, repeats, maps, activeMarks, laneState, verdictState, cleanupError, ambientMarks, deferredArena}
