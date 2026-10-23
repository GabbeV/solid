# The two actual action opening prefixes install both live IDs. Their merge
# removes a present distinct source, so the representative remains selectable.
# No global live-list uniqueness/forest invariant is assumed or concluded.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./arena.bend as Arena
import ./transaction-arena.bend as TxArena
import ./action-opening.bend as Opening
import ./action-created.bend as Created
import ./action-pair.bend as Actions
import ./transaction-pair.bend as Pair
import ./transaction-count-pair.bend as Count
import ./action-pair-completion.bend as Completion
import ./transaction-joined-history.bend as History
import ./scheduler-frame.bend as Schedule
import ./live-membership.bend as Live

def secondId(+before: List<&2, R.Transaction>) ->
  {1n+B.length(R.Transaction, Actions.nextArena(before)) == Pair.rightId(before, []) : Nat}:
  Equal.cong(Nat, Nat, size => 1n+size, B.length(R.Transaction, Actions.nextArena(before)), Nat.add(B.length(R.Transaction, before), 1n), Arena.appendLength(R.Transaction, before, [Opening.record(1n, True{})]))

def expectedLive(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr) ->
  {R.World.transactions(Actions.expected(w, before, cells, first, other)) == B.append(Nat, R.World.transactions(w), [Pair.leftId(before), Pair.rightId(before, [])]) : List<&2, Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.trans(List<&2, Nat>, R.World.transactions(Actions.expected(w, before, cells, first, other)), B.append(Nat, B.append(Nat, transactions, [Pair.leftId(before)]), [Pair.rightId(before, [])]), B.append(Nat, transactions, [Pair.leftId(before), Pair.rightId(before, [])]),
        Equal.cong(Nat, List<&2, Nat>, id => B.append(Nat, B.append(Nat, transactions, [Pair.leftId(before)]), [id]), 1n+B.length(R.Transaction, Actions.nextArena(before)), Pair.rightId(before, []), secondId(before)), Arena.appendSingletons(Nat, transactions, Pair.leftId(before), Pair.rightId(before, [])))

def openingLive(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr) ->
  {R.World.transactions(Actions.second(w, before, cells, first, other)) == B.append(Nat, R.World.transactions(w), [Pair.leftId(before), Pair.rightId(before, [])]) : List<&2, Nat>}:
  Equal.trans(List<&2, Nat>, R.World.transactions(Actions.second(w, before, cells, first, other)), R.World.transactions(Actions.expected(w, before, cells, first, other)), B.append(Nat, R.World.transactions(w), [Pair.leftId(before), Pair.rightId(before, [])]),
    Equal.cong(R.World, List<&2, Nat>, state => R.World.transactions(state), Actions.second(w, before, cells, first, other), Actions.expected(w, before, cells, first, other), Actions.constructs(w, before, cells, first, other)), expectedLive(w, before, cells, first, other))

def countedLive(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +count: Nat) ->
  {R.World.transactions(Count.state(w, before, reverse, count)) == R.World.transactions(w) : List<&2, Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def retiredLive(+w: R.World, +source: Nat) ->
  {R.World.transactions(Pair.retire(w, source)) == X.removeIdentity(R.World.transactions(w), source) : List<&2, Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def joinedLive(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool) ->
  {R.World.transactions(Actions.joined(w, before, cells, first, other, reverse)) == X.removeIdentity(B.append(Nat, R.World.transactions(w), [Pair.leftId(before), Pair.rightId(before, [])]), Pair.sourceId(before, [], reverse)) : List<&2, Nat>}:
  +opened = Actions.second(w, before, cells, first, other)
  +source = Pair.sourceId(before, [], reverse)
  Equal.trans(List<&2, Nat>, R.World.transactions(Actions.joined(w, before, cells, first, other, reverse)), R.World.transactions(Count.state(Pair.retire(opened, source), before, reverse, 2n)), X.removeIdentity(B.append(Nat, R.World.transactions(w), [Pair.leftId(before), Pair.rightId(before, [])]), source),
    Equal.cong(R.World, List<&2, Nat>, state => R.World.transactions(state), Actions.joined(w, before, cells, first, other, reverse), Count.state(Pair.retire(opened, source), before, reverse, 2n), Completion.joinedState(opened, before, reverse, Actions.allocatedPair(w, before, cells, first, other))),
    Equal.trans(List<&2, Nat>, R.World.transactions(Count.state(Pair.retire(opened, source), before, reverse, 2n)), X.removeIdentity(R.World.transactions(opened), source), X.removeIdentity(B.append(Nat, R.World.transactions(w), [Pair.leftId(before), Pair.rightId(before, [])]), source),
      Equal.trans(List<&2, Nat>, R.World.transactions(Count.state(Pair.retire(opened, source), before, reverse, 2n)), R.World.transactions(Pair.retire(opened, source)), X.removeIdentity(R.World.transactions(opened), source), countedLive(Pair.retire(opened, source), before, reverse, 2n), retiredLive(opened, source)),
      Equal.cong(List<&2, Nat>, List<&2, Nat>, live => X.removeIdentity(live, source), R.World.transactions(opened), B.append(Nat, R.World.transactions(w), [Pair.leftId(before), Pair.rightId(before, [])]), openingLive(w, before, cells, first, other))))

def different(+before: List<&2, R.Transaction>, reverse: Bool) ->
  {Nat.is_eq(Pair.targetId(before, [], reverse), Pair.sourceId(before, [], reverse)) == False{} : Bool}:
  match reverse:
    case False{}: TxArena.differentReverse(B.length(R.Transaction, before), 0n)
    case True{}: TxArena.different(B.length(R.Transaction, before), 0n)

def sourceLocation(+xs: List<&2, Nat>, +before: List<&2, R.Transaction>, reverse: Bool) ->
  Live.Located<B.append(Nat, xs, [Pair.leftId(before), Pair.rightId(before, [])]), Pair.sourceId(before, [], reverse)>:
  match reverse:
    case False{}: Live.pair(xs, Pair.leftId(before), Pair.rightId(before, []), True{})
    case True{}: Live.pair(xs, Pair.leftId(before), Pair.rightId(before, []), False{})

def joined(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool) ->
  Live.Located<R.World.transactions(Actions.joined(w, before, cells, first, other, reverse)), Pair.targetId(before, [], reverse)>:
  +opened = B.append(Nat, R.World.transactions(w), [Pair.leftId(before), Pair.rightId(before, [])])
  +source = Pair.sourceId(before, [], reverse)
  +target = Pair.targetId(before, [], reverse)
  Live.cast(X.removeIdentity(opened, source), R.World.transactions(Actions.joined(w, before, cells, first, other, reverse)), target,
    Equal.sym(List<&2, Nat>, R.World.transactions(Actions.joined(w, before, cells, first, other, reverse)), X.removeIdentity(opened, source), joinedLive(w, before, cells, first, other, reverse)),
    Live.retained(opened, source, target, sourceLocation(R.World.transactions(w), before, reverse), Live.pair(R.World.transactions(w), Pair.leftId(before), Pair.rightId(before, []), reverse), different(before, reverse)))


def faultLive(+w: R.World, +fault: R.Fault) ->
  {R.World.transactions(R.World.with_fault(w, fault)) == R.World.transactions(w) : List<&2, Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}


def storedLive(+w: R.World, +id: Nat, +record: R.Transaction) ->
  {R.World.transactions(B.store_transaction(w, id, record)) == R.World.transactions(w) : List<&2, Nat>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def ledgerLive(value: Schedule.LedgerFrame) -> List<&2, Nat>:
  match value:
    case Schedule.LedgerFrame{arena, live, actions}: live

def scheduledLive(+w: R.World) -> {R.World.transactions(B.schedule(w)) == R.World.transactions(w) : List<&2, Nat>}:
  Equal.cong(Schedule.LedgerFrame, List<&2, Nat>, value => ledgerLive(value), Schedule.ledger(B.schedule(w)), Schedule.ledger(w), Schedule.preserves(w))

def resolveChoice(+condition: Bool, +w: R.World, +id: Nat, +other: B.Bundle<R.World, Nat>,
  otherLive: {R.World.transactions(B.first(R.World, Nat, other)) == R.World.transactions(w) : List<&2, Nat>}) ->
  {R.World.transactions(B.first(R.World, Nat, B.choose(~B.Bundle<R.World, Nat>, condition, _ => B.Bundle{w, id}, _ => other))) == R.World.transactions(w) : List<&2, Nat>}:
  match condition:
    case True{}: {==}
    case False{}: otherLive

def resolveLoopLive(+fuel: Nat, +w: R.World, +id: Nat) ->
  {R.World.transactions(B.first(R.World, Nat, X.resolveLoop(fuel, w, id))) == R.World.transactions(w) : List<&2, Nat>}:
  match fuel:
    case 0n: faultLive(w, R.Exhausted{})
    case 1n+p:
      +into = R.Transaction.into(B.transaction(w, id))
      resolveChoice(Nat.is_eq(into, 0n), w, id, X.resolveLoop(p, w, into), resolveLoopLive(p, w, into))

def doneLive(+w: R.World, +id: Nat) -> {R.World.transactions(A.done(w, id)) == R.World.transactions(w) : List<&2, Nat>}:
  +pair = X.resolveTx(w, R.ActionState.transaction(A.get(w, id)))
  +next = B.first(R.World, Nat, pair)
  +root = B.second(R.World, Nat, pair)
  +record = R.Transaction.with_open(B.transaction(next, root), Nat.sub(R.Transaction.open(B.transaction(next, root)), 1n))
  +stored = B.store_transaction(next, root, record)
  Equal.trans(List<&2, Nat>, R.World.transactions(A.done(w, id)), R.World.transactions(stored), R.World.transactions(w), scheduledLive(stored),
    Equal.trans(List<&2, Nat>, R.World.transactions(stored), R.World.transactions(next), R.World.transactions(w), storedLive(next, root, record), resolveLoopLive(1n+B.length(R.Transaction, R.World.txArena(w)), w, R.ActionState.transaction(A.get(w, id)))))

def historyLive(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool, +events: List<&2, History.JoinEvent>) ->
  {R.World.transactions(History.world(History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, Actions.joined(w, before, cells, first, other, reverse)))) == R.World.transactions(Actions.joined(w, before, cells, first, other, reverse)) : List<&2, Nat>}:
  Equal.cong(History.Audit, List<&2, Nat>, audit => R.World.transactions(History.world(audit)), History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, Actions.joined(w, before, cells, first, other, reverse)), History.Audit{Actions.joined(w, before, cells, first, other, reverse), History.expected(Pair.targetId(before, [], reverse), events)}, Actions.history(w, before, cells, first, other, reverse, events))

def afterOne(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool, +finishSecond: Bool, +events: List<&2, History.JoinEvent>) ->
  Live.Located<R.World.transactions(A.done(History.world(History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, Actions.joined(w, before, cells, first, other, reverse))), Actions.idFor(w, before, cells, first, finishSecond))), Pair.targetId(before, [], reverse)>:
  +opened = Actions.joined(w, before, cells, first, other, reverse)
  +observed = History.world(History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, opened))
  +id = Actions.idFor(w, before, cells, first, finishSecond)
  +target = Pair.targetId(before, [], reverse)
  Live.cast(R.World.transactions(opened), R.World.transactions(A.done(observed, id)), target,
    Equal.sym(List<&2, Nat>, R.World.transactions(A.done(observed, id)), R.World.transactions(opened),
      Equal.trans(List<&2, Nat>, R.World.transactions(A.done(observed, id)), R.World.transactions(observed), R.World.transactions(opened), doneLive(observed, id), historyLive(w, before, cells, first, other, reverse, events))), joined(w, before, cells, first, other, reverse))
