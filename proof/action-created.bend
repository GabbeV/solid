# Connect allocation of the action closure/result Promise to successful
# factory-return opening. These are real runtime prefixes, with no manually
# supplied action cell, captured identity or initial obligation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/flight.bend as F
import ../runtime/question.bend as Q
import ./action-opening.bend as Opening

# Both arenas have their reserved identity-zero slot before construction.
def initial(w: R.World, arena: List<&2, R.Transaction>, cells: List<&2, R.ActionState>) -> R.World:
  R.World.with_actions(R.World.with_txArena(w, B.blank_transaction() <> arena), A.blank() <> cells)

def promise(+w: R.World, arena: List<&2, R.Transaction>, cells: List<&2, R.ActionState>) -> R.World:
  B.first(R.World, Nat, F.newThenable(initial(w, arena, cells), False{}, R.Unresolved{}))

def cell(+w: R.World, methods: R.Expr) -> R.ActionState:
  R.ActionState{0n, R.QuestionZero{}, methods, B.length(R.AsyncObject, R.World.asyncObjects(w))}

def construction(+w: R.World, +arena: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +methods: R.Expr) ->
  {A.create(initial(w, arena, cells), methods) == B.Bundle{Opening.scope(promise(w, arena, cells), arena, A.blank() <> cells, cell(w, methods), []), 1n+B.length(R.ActionState, cells)} : B.Bundle<R.World, Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: {==}

def start(+pair: B.Bundle<R.World, Nat>) -> R.World:
  A.open(B.first(R.World, Nat, pair), B.second(R.World, Nat, pair))

def run(+w: R.World, +arena: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, methods: R.Expr) -> R.World:
  start(A.create(initial(w, arena, cells), methods))

def openingExpected(+w: R.World, +arena: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, methods: R.Expr) -> R.World:
  Opening.expected(promise(w, arena, cells), arena, A.blank() <> cells, cell(w, methods), [])

# A direct normal form of the expected World prevents nested constructor
# specifications from repeatedly expanding chains of record projections.
# The equation below checks it against the source-indexed opening contract.
def expected(+w: R.World, +arena: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +methods: R.Expr) -> R.World:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      R.World{nodes, links, buckets, minimum, maximum, marked, pendingNodes, trims, renderQueue, userQueue, context, tracking, running, scheduled, clock, epoch, tree, events, fault, unflushedStaged, promotedWrites, extensions, cleanupPrograms, dormantNodes, errorSerial, halted, haltNotified, reports, callbackEffect, B.blank_transaction() <> B.append(R.Transaction, arena, [Opening.record(1n, True{})]), B.append(Nat, transactions, [1n+B.length(R.Transaction, arena)]), flushTransaction, passTx, passLane, judge, deferredZombies, question, pendingSets, B.append(R.AsyncObject, asyncObjects, [R.AsyncObject{False{}, R.Unresolved{}, [], 0n}]), asyncObservers, hostJobs, syncDepth, streamPlans, iterators, streams, iteratorEvents, awaiters, truthReadHook, truthConfirmedHook, Q.increment(questions), abortInputs, contextKeys, contextRecords, deferredReleases, releaseLists, stale, settledCallbacks, reactions, comparators, actionDepth, A.blank() <> B.append(R.ActionState, cells, [Opening.updated(cell(w, methods), 1n+B.length(R.Transaction, arena), Q.increment(questions))]), actionWaits, arrays, repeats, maps, activeMarks, laneState, verdictState, cleanupError, ambientMarks, deferredArena}

def sameExpected(+w: R.World, +arena: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +methods: R.Expr) ->
  {openingExpected(w, arena, cells, methods) == expected(w, arena, cells, methods) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: {==}

def opening(+w: R.World, +arena: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +methods: R.Expr) ->
  {run(w, arena, cells, methods) == openingExpected(w, arena, cells, methods) : R.World}:
  +before = Opening.scope(promise(w, arena, cells), arena, A.blank() <> cells, cell(w, methods), [])
  +id = {1n+B.length(R.ActionState, cells) : Nat}
  Equal.trans(R.World, run(w, arena, cells, methods), A.open(before, id), openingExpected(w, arena, cells, methods),
    Equal.cong(B.Bundle<R.World, Nat>, R.World, pair => start(pair), A.create(initial(w, arena, cells), methods), B.Bundle{before, id}, construction(w, arena, cells, methods)),
    Opening.allocated(promise(w, arena, cells), arena, A.blank() <> cells, cell(w, methods), []))

def opens(+w: R.World, +arena: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +methods: R.Expr) ->
  {run(w, arena, cells, methods) == expected(w, arena, cells, methods) : R.World}:
  Equal.trans(R.World, run(w, arena, cells, methods), openingExpected(w, arena, cells, methods), expected(w, arena, cells, methods), opening(w, arena, cells, methods), sameExpected(w, arena, cells, methods))

def captures(+w: R.World, +arena: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +methods: R.Expr) ->
  {A.get(run(w, arena, cells, methods), 1n+B.length(R.ActionState, cells)) == Opening.updated(cell(w, methods), 1n+B.length(R.Transaction, arena), Q.increment(R.World.questions(w))) : R.ActionState}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      +before = Opening.scope(promise(w, arena, cells), arena, A.blank() <> cells, cell(w, methods), [])
      +id = {1n+B.length(R.ActionState, cells) : Nat}
      Equal.trans(R.ActionState, A.get(run(w, arena, cells, methods), id), A.get(A.open(before, id), id), Opening.updated(cell(w, methods), 1n+B.length(R.Transaction, arena), Q.increment(questions)),
        Equal.cong(B.Bundle<R.World, Nat>, R.ActionState, pair => A.get(start(pair), id), A.create(initial(w, arena, cells), methods), B.Bundle{before, id}, construction(w, arena, cells, methods)), Opening.captured(promise(w, arena, cells), arena, A.blank() <> cells, cell(w, methods), []))

def obligation(+w: R.World, +arena: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +methods: R.Expr) ->
  {B.transaction(run(w, arena, cells, methods), 1n+B.length(R.Transaction, arena)) == Opening.record(1n, True{}) : R.Transaction}:
  +before = Opening.scope(promise(w, arena, cells), arena, A.blank() <> cells, cell(w, methods), [])
  +id = {1n+B.length(R.ActionState, cells) : Nat}
  +t = {1n+B.length(R.Transaction, arena) : Nat}
  Equal.trans(R.Transaction, B.transaction(run(w, arena, cells, methods), t), B.transaction(A.open(before, id), t), Opening.record(1n, True{}),
    Equal.cong(B.Bundle<R.World, Nat>, R.Transaction, pair => B.transaction(start(pair), t), A.create(initial(w, arena, cells), methods), B.Bundle{before, id}, construction(w, arena, cells, methods)), Opening.obligation(promise(w, arena, cells), arena, A.blank() <> cells, cell(w, methods), []))
