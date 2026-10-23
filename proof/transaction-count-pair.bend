# A joined allocated pair after a representative count write. This proof-side
# shape does not re-merge or re-retire the old source. It retains both original
# identities, the stale source count, and all surrounding World fields.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./transaction-pair.bend as Pair
import ./transaction-resolution.bend as Paths
import ./action-opening.bend as Opening
import ./transaction-positive-update.bend as Update

def source(+before: List<&2, R.Transaction>, reverse: Bool) -> R.Transaction:
  R.Transaction.with_into(Opening.record(1n, True{}), Pair.targetId(before, [], reverse))

def left(+before: List<&2, R.Transaction>, +reverse: Bool, count: Nat) -> R.Transaction:
  B.choose(~R.Transaction, reverse, _ => Opening.record(count, True{}), _ => source(before, reverse))

def right(+before: List<&2, R.Transaction>, +reverse: Bool, count: Nat) -> R.Transaction:
  B.choose(~R.Transaction, reverse, _ => source(before, reverse), _ => Opening.record(count, True{}))

def state(w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +count: Nat) -> R.World:
  Pair.scope(w, before, left(before, reverse, count), [], right(before, reverse, count), [])

def sourceRead(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +count: Nat) ->
  {B.transaction(state(w, before, reverse, count), Pair.sourceId(before, [], reverse)) == source(before, reverse) : R.Transaction}:
  match reverse:
    case False{}: Pair.peekLeft(w, before, left(before, False{}, count), [], right(before, False{}, count), [])
    case True{}: Pair.peekRight(w, before, left(before, True{}, count), [], right(before, True{}, count), [])

def targetRead(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +count: Nat) ->
  {B.transaction(state(w, before, reverse, count), Pair.targetId(before, [], reverse)) == Opening.record(count, True{}) : R.Transaction}:
  match reverse:
    case False{}: Pair.peekRight(w, before, left(before, False{}, count), [], right(before, False{}, count), [])
    case True{}: Pair.peekLeft(w, before, left(before, True{}, count), [], right(before, True{}, count), [])

def count(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +value: Nat) ->
  {R.Transaction.open(B.transaction(state(w, before, reverse, value), Pair.targetId(before, [], reverse))) == value : Nat}:
  Equal.cong(R.Transaction, Nat, record => R.Transaction.open(record), B.transaction(state(w, before, reverse, value), Pair.targetId(before, [], reverse)), Opening.record(value, True{}), targetRead(w, before, reverse, value))

def redirected(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +count: Nat) ->
  {R.Transaction.into(B.transaction(state(w, before, reverse, count), Pair.sourceId(before, [], reverse))) == Pair.targetId(before, [], reverse) : Nat}:
  Equal.cong(R.Transaction, Nat, record => R.Transaction.into(record), B.transaction(state(w, before, reverse, count), Pair.sourceId(before, [], reverse)), source(before, reverse), sourceRead(w, before, reverse, count))

def stopped(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +count: Nat) ->
  {R.Transaction.into(B.transaction(state(w, before, reverse, count), Pair.targetId(before, [], reverse))) == 0n : Nat}:
  Equal.cong(R.Transaction, Nat, record => R.Transaction.into(record), B.transaction(state(w, before, reverse, count), Pair.targetId(before, [], reverse)), Opening.record(count, True{}), targetRead(w, before, reverse, count))

def room(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +count: Nat) ->
  {1n+B.length(R.Transaction, R.World.txArena(state(w, before, reverse, count))) == 2n+B.length(R.Transaction, Pair.tail(R.World.txArena(state(w, before, reverse, count)))) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def sourceResolves(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +count: Nat) ->
  {X.resolveTx(state(w, before, reverse, count), Pair.sourceId(before, [], reverse)) == B.Bundle{state(w, before, reverse, count), Pair.targetId(before, [], reverse)} : B.Bundle<R.World, Nat>}:
  +s = state(w, before, reverse, count)
  +from = Pair.sourceId(before, [], reverse)
  +to = Pair.targetId(before, [], reverse)
  +pred = Pair.targetPred(before, [], reverse)
  +extra = B.length(R.Transaction, Pair.tail(R.World.txArena(s)))
  Equal.trans(B.Bundle<R.World, Nat>, X.resolveTx(s, from), X.resolveLoop(2n+extra, s, from), B.Bundle{s, to},
    Equal.cong(Nat, B.Bundle<R.World, Nat>, fuel => X.resolveLoop(fuel, s, from), 1n+B.length(R.Transaction, R.World.txArena(s)), 2n+extra, room(w, before, reverse, count)),
    Equal.trans(B.Bundle<R.World, Nat>, X.resolveLoop(2n+extra, s, from), X.resolveLoop(1n+extra, s, 1n+pred), B.Bundle{s, to},
      Paths.redirect(s, from, pred, 1n+extra, Equal.trans(Nat, R.Transaction.into(B.transaction(s, from)), to, 1n+pred, redirected(w, before, reverse, count), Pair.targetPositive(before, [], reverse))),
      Equal.trans(B.Bundle<R.World, Nat>, X.resolveLoop(1n+extra, s, 1n+pred), X.resolveLoop(1n+extra, s, to), B.Bundle{s, to},
        Equal.cong(Nat, B.Bundle<R.World, Nat>, id => X.resolveLoop(1n+extra, s, id), 1n+pred, to, Equal.sym(Nat, to, 1n+pred, Pair.targetPositive(before, [], reverse))), Paths.stopped(s, to, extra, stopped(w, before, reverse, count)))))

def targetResolves(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +count: Nat) ->
  {X.resolveTx(state(w, before, reverse, count), Pair.targetId(before, [], reverse)) == B.Bundle{state(w, before, reverse, count), Pair.targetId(before, [], reverse)} : B.Bundle<R.World, Nat>}:
  Paths.stopped(state(w, before, reverse, count), Pair.targetId(before, [], reverse), B.length(R.Transaction, R.World.txArena(state(w, before, reverse, count))), stopped(w, before, reverse, count))

# Scheduling commutes with this arena lens. It retains its own host/report
# behavior and cannot change captures or transaction live membership.
def scheduleScope(+w: R.World, +before: List<&2, R.Transaction>, +left: R.Transaction, +right: R.Transaction) ->
  {B.schedule(Pair.scope(w, before, left, [], right, [])) == Pair.scope(B.schedule(w), before, left, [], right, []) : R.World}:
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

def storeTarget(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +old: Nat, +next: Nat) ->
  {B.store_transaction(state(w, before, reverse, old), Pair.targetId(before, [], reverse), Opening.record(next, True{})) == state(w, before, reverse, next) : R.World}:
  match reverse:
    case False{}: Pair.putRight(w, before, left(before, False{}, old), [], right(before, False{}, old), [], Opening.record(next, True{}))
    case True{}: Pair.putLeft(w, before, left(before, True{}, old), [], right(before, True{}, old), [], Opening.record(next, True{}))

def update(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +old: Nat, +next: Nat) ->
  {Update.result(state(w, before, reverse, old), Pair.targetId(before, [], reverse), next) == state(B.schedule(w), before, reverse, next) : R.World}:
  +s = state(w, before, reverse, old)
  +id = Pair.targetId(before, [], reverse)
  Equal.trans(R.World, Update.result(s, id, next), B.schedule(B.store_transaction(s, id, Opening.record(next, True{}))), state(B.schedule(w), before, reverse, next),
    Equal.cong(R.Transaction, R.World, record => B.schedule(B.store_transaction(s, id, R.Transaction.with_open(record, next))), B.transaction(s, id), Opening.record(old, True{}), targetRead(w, before, reverse, old)),
    Equal.trans(R.World, B.schedule(B.store_transaction(s, id, Opening.record(next, True{}))), B.schedule(state(w, before, reverse, next)), state(B.schedule(w), before, reverse, next),
      Equal.cong(R.World, R.World, world => B.schedule(world), B.store_transaction(s, id, Opening.record(next, True{})), state(w, before, reverse, next), storeTarget(w, before, reverse, old, next)), scheduleScope(w, before, left(before, reverse, next), right(before, reverse, next))))

# Initial distinct join establishes this shape once. Later updates never call
# removeIdentity again; the retired ambient World's live list is retained.
def afterState(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool) ->
  {Pair.after(w, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse) == state(Pair.retire(w, Pair.sourceId(before, [], reverse)), before, reverse, 2n) : R.World}:
  match reverse:
    case False{}: Update.retireScope(w, before, left(before, False{}, 2n), right(before, False{}, 2n), Pair.sourceId(before, [], False{}))
    case True{}: Update.retireScope(w, before, left(before, True{}, 2n), right(before, True{}, 2n), Pair.sourceId(before, [], True{}))
