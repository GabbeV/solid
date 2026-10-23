# The count write and source schedule used by action.done. Existing selected
# slots stay allocated; source/target records are supplied by the checked join.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./transaction-pair.bend as Pair
import ./action-pair.bend as Actions
import ./action-opening.bend as Opening
import ./scheduler-frame.bend as Frame

def bare(+w: R.World, +id: Nat, count: Nat) -> R.World:
  B.store_transaction(w, id, R.Transaction.with_open(B.transaction(w, id), count))

def result(w: R.World, id: Nat, count: Nat) -> R.World:
  B.schedule(bare(w, id, count))

def arena(frame: Frame.LedgerFrame) -> List<&2, R.Transaction>:
  match frame:
    case Frame.LedgerFrame{values, live, actions}: values

def scheduledRecord(+w: R.World, +id: Nat) ->
  {B.transaction(B.schedule(w), id) == B.transaction(w, id) : R.Transaction}:
  Equal.cong(List<&2, R.Transaction>, R.Transaction, values => B.get(R.Transaction, values, id, B.blank_transaction()), R.World.txArena(B.schedule(w)), R.World.txArena(w),
    Equal.cong(Frame.LedgerFrame, List<&2, R.Transaction>, frame => arena(frame), Frame.ledger(B.schedule(w)), Frame.ledger(w), Frame.preserves(w)))

def openSetter(+record: R.Transaction, +count: Nat) ->
  {R.Transaction.open(R.Transaction.with_open(record, count)) == count : Nat}:
  match record:
    case R.Transaction{nodes, renderQueue, userQueue, reruns, into, parent, lane, verdict, open, acted, links, shown, held, marks}: {==}

def leftStoreRead(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +right: R.Transaction, +value: R.Transaction) ->
  {B.transaction(B.store_transaction(Pair.scope(w, prefix, left, [], right, []), Pair.leftId(prefix), value), Pair.leftId(prefix)) == value : R.Transaction}:
  Equal.trans(R.Transaction, B.transaction(B.store_transaction(Pair.scope(w, prefix, left, [], right, []), Pair.leftId(prefix), value), Pair.leftId(prefix)), B.transaction(Pair.scope(w, prefix, value, [], right, []), Pair.leftId(prefix)), value,
    Equal.cong(R.World, R.Transaction, state => B.transaction(state, Pair.leftId(prefix)), B.store_transaction(Pair.scope(w, prefix, left, [], right, []), Pair.leftId(prefix), value), Pair.scope(w, prefix, value, [], right, []), Pair.putLeft(w, prefix, left, [], right, [], value)), Pair.peekLeft(w, prefix, value, [], right, []))

def rightStoreRead(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +right: R.Transaction, +value: R.Transaction) ->
  {B.transaction(B.store_transaction(Pair.scope(w, prefix, left, [], right, []), Pair.rightId(prefix, []), value), Pair.rightId(prefix, [])) == value : R.Transaction}:
  Equal.trans(R.Transaction, B.transaction(B.store_transaction(Pair.scope(w, prefix, left, [], right, []), Pair.rightId(prefix, []), value), Pair.rightId(prefix, [])), B.transaction(Pair.scope(w, prefix, left, [], value, []), Pair.rightId(prefix, [])), value,
    Equal.cong(R.World, R.Transaction, state => B.transaction(state, Pair.rightId(prefix, [])), B.store_transaction(Pair.scope(w, prefix, left, [], right, []), Pair.rightId(prefix, []), value), Pair.scope(w, prefix, left, [], value, []), Pair.putRight(w, prefix, left, [], right, [], value)), Pair.peekRight(w, prefix, left, [], value, []))

def leftCount(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +right: R.Transaction, +count: Nat) ->
  {R.Transaction.open(B.transaction(bare(Pair.scope(w, prefix, left, [], right, []), Pair.leftId(prefix), count), Pair.leftId(prefix))) == count : Nat}:
  +start = Pair.scope(w, prefix, left, [], right, [])
  +id = Pair.leftId(prefix)
  Equal.trans(Nat, R.Transaction.open(B.transaction(bare(start, id, count), id)), R.Transaction.open(R.Transaction.with_open(left, count)), count,
    Equal.trans(Nat, R.Transaction.open(B.transaction(bare(start, id, count), id)), R.Transaction.open(B.transaction(B.store_transaction(start, id, R.Transaction.with_open(left, count)), id)), R.Transaction.open(R.Transaction.with_open(left, count)),
      Equal.cong(R.Transaction, Nat, old => R.Transaction.open(B.transaction(B.store_transaction(start, id, R.Transaction.with_open(old, count)), id)), B.transaction(start, id), left, Pair.peekLeft(w, prefix, left, [], right, [])),
      Equal.cong(R.Transaction, Nat, value => R.Transaction.open(value), B.transaction(B.store_transaction(start, id, R.Transaction.with_open(left, count)), id), R.Transaction.with_open(left, count), leftStoreRead(w, prefix, left, right, R.Transaction.with_open(left, count)))), openSetter(left, count))

def rightCount(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +right: R.Transaction, +count: Nat) ->
  {R.Transaction.open(B.transaction(bare(Pair.scope(w, prefix, left, [], right, []), Pair.rightId(prefix, []), count), Pair.rightId(prefix, []))) == count : Nat}:
  +start = Pair.scope(w, prefix, left, [], right, [])
  +id = Pair.rightId(prefix, [])
  Equal.trans(Nat, R.Transaction.open(B.transaction(bare(start, id, count), id)), R.Transaction.open(R.Transaction.with_open(right, count)), count,
    Equal.trans(Nat, R.Transaction.open(B.transaction(bare(start, id, count), id)), R.Transaction.open(B.transaction(B.store_transaction(start, id, R.Transaction.with_open(right, count)), id)), R.Transaction.open(R.Transaction.with_open(right, count)),
      Equal.cong(R.Transaction, Nat, old => R.Transaction.open(B.transaction(B.store_transaction(start, id, R.Transaction.with_open(old, count)), id)), B.transaction(start, id), right, Pair.peekRight(w, prefix, left, [], right, [])),
      Equal.cong(R.Transaction, Nat, value => R.Transaction.open(value), B.transaction(B.store_transaction(start, id, R.Transaction.with_open(right, count)), id), R.Transaction.with_open(right, count), rightStoreRead(w, prefix, left, right, R.Transaction.with_open(right, count)))), openSetter(right, count))

def retireScope(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +right: R.Transaction, +id: Nat) ->
  {Pair.retire(Pair.scope(w, prefix, left, [], right, []), id) == Pair.scope(Pair.retire(w, id), prefix, left, [], right, []) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: {==}

def afterCount(+w: R.World, +prefix: List<&2, R.Transaction>, +reverse: Bool, +count: Nat) ->
  {R.Transaction.open(B.transaction(bare(Pair.after(w, prefix, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse), Pair.targetId(prefix, [], reverse), count), Pair.targetId(prefix, [], reverse))) == count : Nat}:
  match reverse:
    case False{}:
      +from = Pair.sourceRecord(Opening.record(1n, True{}), Opening.record(1n, True{}), Pair.rightId(prefix, []), False{})
      +to = Pair.targetRecord(Opening.record(1n, True{}), Opening.record(1n, True{}), False{})
      +id = Pair.rightId(prefix, [])
      Equal.trans(Nat, R.Transaction.open(B.transaction(bare(Pair.retire(Pair.scope(w, prefix, from, [], to, []), Pair.leftId(prefix)), id, count), id)), R.Transaction.open(B.transaction(bare(Pair.scope(Pair.retire(w, Pair.leftId(prefix)), prefix, from, [], to, []), id, count), id)), count,
        Equal.cong(R.World, Nat, state => R.Transaction.open(B.transaction(bare(state, id, count), id)), Pair.retire(Pair.scope(w, prefix, from, [], to, []), Pair.leftId(prefix)), Pair.scope(Pair.retire(w, Pair.leftId(prefix)), prefix, from, [], to, []), retireScope(w, prefix, from, to, Pair.leftId(prefix))), rightCount(Pair.retire(w, Pair.leftId(prefix)), prefix, from, to, count))
    case True{}:
      +from = Pair.sourceRecord(Opening.record(1n, True{}), Opening.record(1n, True{}), Pair.leftId(prefix), True{})
      +to = Pair.targetRecord(Opening.record(1n, True{}), Opening.record(1n, True{}), True{})
      +id = Pair.leftId(prefix)
      Equal.trans(Nat, R.Transaction.open(B.transaction(bare(Pair.retire(Pair.scope(w, prefix, to, [], from, []), Pair.rightId(prefix, [])), id, count), id)), R.Transaction.open(B.transaction(bare(Pair.scope(Pair.retire(w, Pair.rightId(prefix, [])), prefix, to, [], from, []), id, count), id)), count,
        Equal.cong(R.World, Nat, state => R.Transaction.open(B.transaction(bare(state, id, count), id)), Pair.retire(Pair.scope(w, prefix, to, [], from, []), Pair.rightId(prefix, [])), Pair.scope(Pair.retire(w, Pair.rightId(prefix, [])), prefix, to, [], from, []), retireScope(w, prefix, to, from, Pair.rightId(prefix, []))), leftCount(Pair.retire(w, Pair.rightId(prefix, [])), prefix, to, from, count))

def countJoinedResult(+state: R.World, +prefix: List<&2, R.Transaction>, +reverse: Bool, +count: Nat,
  known: {Pair.scope(state, prefix, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []) == state : R.World}) ->
  {R.Transaction.open(B.transaction(result(X.merge(state, Pair.sourceId(prefix, [], reverse), Pair.targetId(prefix, [], reverse)), Pair.targetId(prefix, [], reverse), count), Pair.targetId(prefix, [], reverse))) == count : Nat}:
  +joined = X.merge(state, Pair.sourceId(prefix, [], reverse), Pair.targetId(prefix, [], reverse))
  +after = Pair.after(state, prefix, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse)
  +id = Pair.targetId(prefix, [], reverse)
  Equal.trans(Nat, R.Transaction.open(B.transaction(result(joined, id, count), id)), R.Transaction.open(B.transaction(bare(joined, id, count), id)), count,
    Equal.cong(R.Transaction, Nat, value => R.Transaction.open(value), B.transaction(result(joined, id, count), id), B.transaction(bare(joined, id, count), id), scheduledRecord(bare(joined, id, count), id)),
    Equal.trans(Nat, R.Transaction.open(B.transaction(bare(joined, id, count), id)), R.Transaction.open(B.transaction(bare(after, id, count), id)), count,
      Equal.cong(R.World, Nat, w => R.Transaction.open(B.transaction(bare(w, id, count), id)), joined, after,
        Equal.trans(R.World, joined, Pair.merged(state, prefix, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse), after, Actions.joinAllocated(state, prefix, reverse, known), Pair.merge(state, prefix, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse))), afterCount(state, prefix, reverse, count)))

def healthyResult(+w: R.World, +id: Nat, +count: Nat) -> {B.ok(result(w, id, count)) == B.ok(w) : Bool}:
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
