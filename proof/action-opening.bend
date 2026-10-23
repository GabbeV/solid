# Action opening establishes its own transaction obligation; no initial open
# count or captured transaction equation is supplied as a proof premise.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ../runtime/question.bend as Q
import ./arena.bend as Arena

def record(open: Nat, acted: Bool) -> R.Transaction:
  R.Transaction{[], [], [], [], 0n, 0n, False{}, 0n, open, acted, 0n, False{}, False{}, R.NoIds{}}

def fresh(+w: R.World, value: R.Transaction) -> R.World:
  R.World.with_transactions(R.World.with_txArena(w, B.append(R.Transaction, R.World.txArena(w), [value])), B.append(Nat, R.World.transactions(w), [B.length(R.Transaction, R.World.txArena(w))]))

def freshPeek(+w: R.World, +value: R.Transaction) ->
  {B.transaction(fresh(w, value), B.length(R.Transaction, R.World.txArena(w))) == value : R.Transaction}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Arena.getPrefix(R.Transaction, txArena, value, [], B.blank_transaction())

def freshStore(+w: R.World, +old: R.Transaction, +value: R.Transaction) ->
  {B.store_transaction(fresh(w, old), B.length(R.Transaction, R.World.txArena(w)), value) == fresh(w, value) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2, R.Transaction>, R.World, xs => R.World.with_txArena(fresh(w, old), xs),
        List.set(&2, R.Transaction, B.append(R.Transaction, txArena, [old]), B.length(R.Transaction, txArena), value),
        B.append(R.Transaction, txArena, [value]), Arena.setPrefix(R.Transaction, txArena, old, [], value))

def allocation(+w: R.World) ->
  {X.newTransaction(w, False{}, 0n) == B.Bundle{fresh(w, record(0n, False{})), B.length(R.Transaction, R.World.txArena(w))} : B.Bundle<R.World, Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: {==}

def setOpen(+w: R.World, +t: Nat) -> R.World:
  B.store_transaction(w, t, R.Transaction.with_open(B.transaction(w, t), 1n))

def setActed(+w: R.World, +t: Nat) -> R.World:
  B.store_transaction(w, t, R.Transaction.with_acted(B.transaction(w, t), True{}))

def oneOpen(+w: R.World) ->
  {setOpen(fresh(w, record(0n, False{})), B.length(R.Transaction, R.World.txArena(w))) == fresh(w, record(1n, False{})) : R.World}:
  +start = fresh(w, record(0n, False{}))
  +t = B.length(R.Transaction, R.World.txArena(w))
  Equal.trans(R.World, setOpen(start, t), B.store_transaction(start, t, record(1n, False{})), fresh(w, record(1n, False{})),
    Equal.cong(R.Transaction, R.World, value => B.store_transaction(start, t, R.Transaction.with_open(value, 1n)), B.transaction(start, t), record(0n, False{}), freshPeek(w, record(0n, False{}))), freshStore(w, record(0n, False{}), record(1n, False{})))

def marked(+w: R.World) ->
  {setActed(fresh(w, record(1n, False{})), B.length(R.Transaction, R.World.txArena(w))) == fresh(w, record(1n, True{})) : R.World}:
  +start = fresh(w, record(1n, False{}))
  +t = B.length(R.Transaction, R.World.txArena(w))
  Equal.trans(R.World, setActed(start, t), B.store_transaction(start, t, record(1n, True{})), fresh(w, record(1n, True{})),
    Equal.cong(R.Transaction, R.World, value => B.store_transaction(start, t, R.Transaction.with_acted(value, True{})), B.transaction(start, t), record(1n, False{}), freshPeek(w, record(1n, False{}))), freshStore(w, record(1n, False{}), record(1n, True{})))

def ready(+w: R.World) ->
  {setActed(setOpen(fresh(w, record(0n, False{})), B.length(R.Transaction, R.World.txArena(w))), B.length(R.Transaction, R.World.txArena(w))) == fresh(w, record(1n, True{})) : R.World}:
  +t = B.length(R.Transaction, R.World.txArena(w))
  Equal.trans(R.World, setActed(setOpen(fresh(w, record(0n, False{})), t), t), setActed(fresh(w, record(1n, False{})), t), fresh(w, record(1n, True{})),
    Equal.cong(R.World, R.World, world => setActed(world, t), setOpen(fresh(w, record(0n, False{})), t), fresh(w, record(1n, False{})), oneOpen(w)), marked(w))

# The actual tail after transaction creation: fresh question allocation followed
# by capture in the action's existing closure cell. Ambient question is separate.
def capture(+w: R.World, +id: Nat, +t: Nat) -> R.World:
  +pair = Q.nextQuestion(w)
  +w = B.first(R.World, R.Question, pair)
  A.store(w, id, R.ActionState.with_question(R.ActionState.with_transaction(A.get(w, id), t), B.second(R.World, R.Question, pair)))

def fromAllocation(+pair: B.Bundle<R.World, Nat>, +id: Nat) -> R.World:
  +w = B.first(R.World, Nat, pair)
  +t = B.second(R.World, Nat, pair)
  capture(setActed(setOpen(w, t), t), id, t)

def opened(+w: R.World, +id: Nat) -> R.World:
  capture(fresh(w, record(1n, True{})), id, B.length(R.Transaction, R.World.txArena(w)))

def open(+w: R.World, +id: Nat) ->
  {A.open(w, id) == opened(w, id) : R.World}:
  +t = B.length(R.Transaction, R.World.txArena(w))
  Equal.trans(R.World, A.open(w, id), fromAllocation(B.Bundle{fresh(w, record(0n, False{})), t}, id), opened(w, id),
    Equal.cong(B.Bundle<R.World, Nat>, R.World, pair => fromAllocation(pair, id), X.newTransaction(w, False{}, 0n), B.Bundle{fresh(w, record(0n, False{})), t}, allocation(w)),
    Equal.cong(R.World, R.World, world => capture(world, id, t), setActed(setOpen(fresh(w, record(0n, False{})), t), t), fresh(w, record(1n, True{})), ready(w)))

# Existing action cells are represented by an actual list split; a sentinel
# makes the newly appended transaction identity nonzero.
def scope(w: R.World, arena: List<&2, R.Transaction>, before: List<&2, R.ActionState>, entry: R.ActionState, after: List<&2, R.ActionState>) -> R.World:
  R.World.with_txArena(R.World.with_actions(w, B.append(R.ActionState, before, entry <> after)), B.blank_transaction() <> arena)

def updated(entry: R.ActionState, t: Nat, q: R.Question) -> R.ActionState:
  R.ActionState.with_question(R.ActionState.with_transaction(entry, t), q)

def prepared(+w: R.World) -> R.World:
  R.World.with_questions(fresh(w, record(1n, True{})), Q.increment(R.World.questions(w)))

def expected(+w: R.World, +arena: List<&2, R.Transaction>, +before: List<&2, R.ActionState>, +entry: R.ActionState, +after: List<&2, R.ActionState>) -> R.World:
  +start = scope(w, arena, before, entry, after)
  R.World.with_actions(prepared(start), B.append(R.ActionState, before, updated(entry, 1n+B.length(R.Transaction, arena), Q.increment(R.World.questions(w))) <> after))

def preparedPeek(+w: R.World, +arena: List<&2, R.Transaction>, +before: List<&2, R.ActionState>, +entry: R.ActionState, +after: List<&2, R.ActionState>) ->
  {A.get(prepared(scope(w, arena, before, entry, after)), B.length(R.ActionState, before)) == entry : R.ActionState}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Arena.getPrefix(R.ActionState, before, entry, after, A.blank())

def preparedStore(+w: R.World, +arena: List<&2, R.Transaction>, +before: List<&2, R.ActionState>, +entry: R.ActionState, +after: List<&2, R.ActionState>, +value: R.ActionState) ->
  {A.store(prepared(scope(w, arena, before, entry, after)), B.length(R.ActionState, before), value)
    == R.World.with_actions(prepared(scope(w, arena, before, entry, after)), B.append(R.ActionState, before, value <> after)) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2, R.ActionState>, R.World, xs => R.World.with_actions(prepared(scope(w, arena, before, entry, after)), xs),
        List.set(&2, R.ActionState, B.append(R.ActionState, before, entry <> after), B.length(R.ActionState, before), value),
        B.append(R.ActionState, before, value <> after), Arena.setPrefix(R.ActionState, before, entry, after, value))

def captureScope(+w: R.World, +arena: List<&2, R.Transaction>, +before: List<&2, R.ActionState>, +entry: R.ActionState, +after: List<&2, R.ActionState>) ->
  {opened(scope(w, arena, before, entry, after), B.length(R.ActionState, before)) == expected(w, arena, before, entry, after) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      +start = scope(w, arena, before, entry, after)
      +p = prepared(start)
      +id = B.length(R.ActionState, before)
      +t = {1n+B.length(R.Transaction, arena) : Nat}
      +q = Q.increment(questions)
      Equal.trans(R.World, opened(start, id), A.store(p, id, updated(entry, t, q)), expected(w, arena, before, entry, after),
        Equal.cong(R.ActionState, R.World, value => A.store(p, id, updated(value, t, q)), A.get(p, id), entry, preparedPeek(w, arena, before, entry, after)), preparedStore(w, arena, before, entry, after, updated(entry, t, q)))

# Exact full-World constructor contract, including the real transaction allocation,
# live-list append, one obligation, acted marker and question/closure capture.
def allocated(+w: R.World, +arena: List<&2, R.Transaction>, +before: List<&2, R.ActionState>, +entry: R.ActionState, +after: List<&2, R.ActionState>) ->
  {A.open(scope(w, arena, before, entry, after), B.length(R.ActionState, before)) == expected(w, arena, before, entry, after) : R.World}:
  Equal.trans(R.World, A.open(scope(w, arena, before, entry, after), B.length(R.ActionState, before)), opened(scope(w, arena, before, entry, after), B.length(R.ActionState, before)), expected(w, arena, before, entry, after), open(scope(w, arena, before, entry, after), B.length(R.ActionState, before)), captureScope(w, arena, before, entry, after))

def expectedCell(+w: R.World, +arena: List<&2, R.Transaction>, +before: List<&2, R.ActionState>, +entry: R.ActionState, +after: List<&2, R.ActionState>) ->
  {A.get(expected(w, arena, before, entry, after), B.length(R.ActionState, before)) == updated(entry, 1n+B.length(R.Transaction, arena), Q.increment(R.World.questions(w))) : R.ActionState}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Arena.getPrefix(R.ActionState, before, updated(entry, 1n+B.length(R.Transaction, arena), Q.increment(questions)), after, A.blank())

def captured(+w: R.World, +arena: List<&2, R.Transaction>, +before: List<&2, R.ActionState>, +entry: R.ActionState, +after: List<&2, R.ActionState>) ->
  {A.get(A.open(scope(w, arena, before, entry, after), B.length(R.ActionState, before)), B.length(R.ActionState, before)) == updated(entry, 1n+B.length(R.Transaction, arena), Q.increment(R.World.questions(w))) : R.ActionState}:
  +start = scope(w, arena, before, entry, after)
  +id = B.length(R.ActionState, before)
  Equal.trans(R.ActionState, A.get(A.open(start, id), id), A.get(expected(w, arena, before, entry, after), id), updated(entry, 1n+B.length(R.Transaction, arena), Q.increment(R.World.questions(w))),
    Equal.cong(R.World, R.ActionState, world => A.get(world, id), A.open(start, id), expected(w, arena, before, entry, after), allocated(w, arena, before, entry, after)), expectedCell(w, arena, before, entry, after))

def expectedRecord(+w: R.World, +arena: List<&2, R.Transaction>, +before: List<&2, R.ActionState>, +entry: R.ActionState, +after: List<&2, R.ActionState>) ->
  {B.transaction(expected(w, arena, before, entry, after), 1n+B.length(R.Transaction, arena)) == record(1n, True{}) : R.Transaction}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Arena.getPrefix(R.Transaction, B.blank_transaction() <> arena, record(1n, True{}), [], B.blank_transaction())

def obligation(+w: R.World, +arena: List<&2, R.Transaction>, +before: List<&2, R.ActionState>, +entry: R.ActionState, +after: List<&2, R.ActionState>) ->
  {B.transaction(A.open(scope(w, arena, before, entry, after), B.length(R.ActionState, before)), 1n+B.length(R.Transaction, arena)) == record(1n, True{}) : R.Transaction}:
  +start = scope(w, arena, before, entry, after)
  +id = B.length(R.ActionState, before)
  +t = {1n+B.length(R.Transaction, arena) : Nat}
  Equal.trans(R.Transaction, B.transaction(A.open(start, id), t), B.transaction(expected(w, arena, before, entry, after), t), record(1n, True{}),
    Equal.cong(R.World, R.Transaction, world => B.transaction(world, t), A.open(start, id), expected(w, arena, before, entry, after), allocated(w, arena, before, entry, after)), expectedRecord(w, arena, before, entry, after))
