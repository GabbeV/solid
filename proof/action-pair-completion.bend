# Two actual action done prefixes, in either order, with arbitrary finite
# lookups/rejoins before and between them. Callback delivery is a separate
# obligation: this family admits each selected action's completion once.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./action-pair.bend as Actions
import ./action-opening.bend as Opening
import ./action-resolution.bend as Done
import ./transaction-pair.bend as Pair
import ./transaction-count-pair.bend as Count
import ./transaction-joined-history.bend as History
import ./scheduler-frame.bend as Frame
import ./arena.bend as Arena

def stateGet(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +count: Nat, +id: Nat) ->
  {A.get(Count.state(w, before, reverse, count), id) == A.get(w, id) : R.ActionState}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def retiredGet(+w: R.World, +source: Nat, +id: Nat) ->
  {A.get(Pair.retire(w, source), id) == A.get(w, id) : R.ActionState}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      {==}

def cells(frame: Frame.LedgerFrame) -> List<&2, R.ActionState>:
  match frame:
    case Frame.LedgerFrame{arena, live, actions}: actions

def scheduledGet(+w: R.World, +id: Nat) ->
  {A.get(B.schedule(w), id) == A.get(w, id) : R.ActionState}:
  Equal.cong(List<&2, R.ActionState>, R.ActionState, entries => B.get(R.ActionState, entries, id, A.blank()), R.World.actions(B.schedule(w)), R.World.actions(w),
    Equal.cong(Frame.LedgerFrame, List<&2, R.ActionState>, frame => cells(frame), Frame.ledger(B.schedule(w)), Frame.ledger(w), Frame.preserves(w)))

def choiceResolution(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +count: Nat, +second: Bool) ->
  {X.resolveTx(Count.state(w, before, reverse, count), Actions.transactionChoice(before, second)) == B.Bundle{Count.state(w, before, reverse, count), Pair.targetId(before, [], reverse)} : B.Bundle<R.World, Nat>}:
  match reverse:
    case False{}:
      match second:
        case False{}: Count.sourceResolves(w, before, False{}, count)
        case True{}: Count.targetResolves(w, before, False{}, count)
    case True{}:
      match second:
        case False{}: Count.targetResolves(w, before, True{}, count)
        case True{}: Count.sourceResolves(w, before, True{}, count)

def finish(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +remaining: Nat, +id: Nat, +second: Bool,
  capture: {R.ActionState.transaction(A.get(w, id)) == Actions.transactionChoice(before, second) : Nat}) ->
  {A.done(Count.state(w, before, reverse, 1n+remaining), id) == Count.state(B.schedule(w), before, reverse, remaining) : R.World}:
  +s = Count.state(w, before, reverse, 1n+remaining)
  +root = Pair.targetId(before, [], reverse)
  Equal.trans(R.World, A.done(s, id), B.schedule(B.store_transaction(s, root, R.Transaction.with_open(B.transaction(s, root), remaining))), Count.state(B.schedule(w), before, reverse, remaining),
    Done.decreases(s, id, root, remaining,
      Equal.trans(B.Bundle<R.World, Nat>, X.resolveTx(s, R.ActionState.transaction(A.get(s, id))), X.resolveTx(s, Actions.transactionChoice(before, second)), B.Bundle{s, root},
        Equal.cong(Nat, B.Bundle<R.World, Nat>, tx => X.resolveTx(s, tx), R.ActionState.transaction(A.get(s, id)), Actions.transactionChoice(before, second),
          Equal.trans(Nat, R.ActionState.transaction(A.get(s, id)), R.ActionState.transaction(A.get(w, id)), Actions.transactionChoice(before, second),
            Equal.cong(R.ActionState, Nat, entry => R.ActionState.transaction(entry), A.get(s, id), A.get(w, id), stateGet(w, before, reverse, 1n+remaining, id)), capture)), choiceResolution(w, before, reverse, 1n+remaining, second)), Count.count(w, before, reverse, 1n+remaining)),
    Count.update(w, before, reverse, 1n+remaining, remaining))

def history(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +count: Nat, +events: List<&2, History.JoinEvent>) ->
  {History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, Count.state(w, before, reverse, count)) == History.Audit{Count.state(w, before, reverse, count), History.expected(Pair.targetId(before, [], reverse), events)} : History.Audit}:
  History.preserves(Count.state(w, before, reverse, count), Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), Pair.targetId(before, [], reverse), events, Count.sourceResolves(w, before, reverse, count), Count.targetResolves(w, before, reverse, count))

def observe(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, events: List<&2, History.JoinEvent>) -> R.World:
  History.world(History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, w))

def observed(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +count: Nat, +events: List<&2, History.JoinEvent>) ->
  {observe(Count.state(w, before, reverse, count), before, reverse, events) == Count.state(w, before, reverse, count) : R.World}:
  Equal.cong(History.Audit, R.World, audit => History.world(audit), History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, Count.state(w, before, reverse, count)), History.Audit{Count.state(w, before, reverse, count), History.expected(Pair.targetId(before, [], reverse), events)}, history(w, before, reverse, count, events))

# This is the admitted event programme, calling real lookups, merges and done.
# The two IDs are supplied by construction below; the choices are complementary.
def run(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, firstId: Nat, otherId: Nat, initial: List<&2, History.JoinEvent>, middle: List<&2, History.JoinEvent>, final: List<&2, History.JoinEvent>) -> R.World:
  observe(A.done(observe(A.done(observe(w, before, reverse, initial), firstId), before, reverse, middle), otherId), before, reverse, final)

def both(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +firstId: Nat, +otherId: Nat, +second: Bool,
  +initial: List<&2, History.JoinEvent>, +middle: List<&2, History.JoinEvent>, +final: List<&2, History.JoinEvent>,
  firstCapture: {R.ActionState.transaction(A.get(w, firstId)) == Actions.transactionChoice(before, second) : Nat},
  otherCapture: {R.ActionState.transaction(A.get(w, otherId)) == Actions.transactionChoice(before, Bool.not(second)) : Nat}) ->
  {run(Count.state(w, before, reverse, 2n), before, reverse, firstId, otherId, initial, middle, final) == Count.state(B.schedule(B.schedule(w)), before, reverse, 0n) : R.World}:
  +s = Count.state(w, before, reverse, 2n)
  +one = Count.state(B.schedule(w), before, reverse, 1n)
  +zero = Count.state(B.schedule(B.schedule(w)), before, reverse, 0n)
  +firstDone = Equal.trans(R.World, A.done(observe(s, before, reverse, initial), firstId), A.done(s, firstId), one,
    Equal.cong(R.World, R.World, world => A.done(world, firstId), observe(s, before, reverse, initial), s, observed(w, before, reverse, 2n, initial)), finish(w, before, reverse, 1n, firstId, second, firstCapture))
  +middleDone = Equal.trans(R.World, observe(A.done(observe(s, before, reverse, initial), firstId), before, reverse, middle), observe(one, before, reverse, middle), one,
    Equal.cong(R.World, R.World, world => observe(world, before, reverse, middle), A.done(observe(s, before, reverse, initial), firstId), one, firstDone), observed(B.schedule(w), before, reverse, 1n, middle))
  +secondDone = Equal.trans(R.World, A.done(observe(A.done(observe(s, before, reverse, initial), firstId), before, reverse, middle), otherId), A.done(one, otherId), zero,
    Equal.cong(R.World, R.World, world => A.done(world, otherId), observe(A.done(observe(s, before, reverse, initial), firstId), before, reverse, middle), one, middleDone),
    finish(B.schedule(w), before, reverse, 0n, otherId, Bool.not(second),
      Equal.trans(Nat, R.ActionState.transaction(A.get(B.schedule(w), otherId)), R.ActionState.transaction(A.get(w, otherId)), Actions.transactionChoice(before, Bool.not(second)),
        Equal.cong(R.ActionState, Nat, entry => R.ActionState.transaction(entry), A.get(B.schedule(w), otherId), A.get(w, otherId), scheduledGet(w, otherId)), otherCapture)))
  Equal.trans(R.World, run(s, before, reverse, firstId, otherId, initial, middle, final), observe(zero, before, reverse, final), zero,
    Equal.cong(R.World, R.World, world => observe(world, before, reverse, final), A.done(observe(A.done(observe(s, before, reverse, initial), firstId), before, reverse, middle), otherId), zero, secondDone), observed(B.schedule(B.schedule(w)), before, reverse, 0n, final))

# Opaque-World operation boundary avoids duplicating expanded constructor states
# during conversion. Its shape/capture premises are supplied by real constructors.
def joinedState(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool,
  known: {Pair.scope(w, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []) == w : R.World}) ->
  {X.merge(w, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)) == Count.state(Pair.retire(w, Pair.sourceId(before, [], reverse)), before, reverse, 2n) : R.World}:
  +joined = X.merge(w, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse))
  +merged = Pair.merged(w, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse)
  +after = Pair.after(w, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse)
  +expected = Count.state(Pair.retire(w, Pair.sourceId(before, [], reverse)), before, reverse, 2n)
  Equal.trans(R.World, joined, merged, expected, Actions.joinAllocated(w, before, reverse, known),
    Equal.trans(R.World, merged, after, expected, Pair.merge(w, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse), Count.afterState(w, before, reverse)))

def retiredCapture(+w: R.World, +source: Nat, +before: List<&2, R.Transaction>, +id: Nat, +second: Bool,
  capture: {R.ActionState.transaction(A.get(w, id)) == Actions.transactionChoice(before, second) : Nat}) ->
  {R.ActionState.transaction(A.get(Pair.retire(w, source), id)) == Actions.transactionChoice(before, second) : Nat}:
  Equal.trans(Nat, R.ActionState.transaction(A.get(Pair.retire(w, source), id)), R.ActionState.transaction(A.get(w, id)), Actions.transactionChoice(before, second),
    Equal.cong(R.ActionState, Nat, entry => R.ActionState.transaction(entry), A.get(Pair.retire(w, source), id), A.get(w, id), retiredGet(w, source, id)), capture)

def allocatedBoth(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +firstId: Nat, +otherId: Nat, +second: Bool,
  +initial: List<&2, History.JoinEvent>, +middle: List<&2, History.JoinEvent>, +final: List<&2, History.JoinEvent>,
  known: {Pair.scope(w, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []) == w : R.World},
  firstCapture: {R.ActionState.transaction(A.get(w, firstId)) == Actions.transactionChoice(before, second) : Nat},
  otherCapture: {R.ActionState.transaction(A.get(w, otherId)) == Actions.transactionChoice(before, Bool.not(second)) : Nat}) ->
  {run(X.merge(w, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), before, reverse, firstId, otherId, initial, middle, final) == Count.state(B.schedule(B.schedule(Pair.retire(w, Pair.sourceId(before, [], reverse)))), before, reverse, 0n) : R.World}:
  +ambient = Pair.retire(w, Pair.sourceId(before, [], reverse))
  +joined = X.merge(w, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse))
  +shape = Count.state(ambient, before, reverse, 2n)
  +expected = Count.state(B.schedule(B.schedule(ambient)), before, reverse, 0n)
  Equal.trans(R.World, run(joined, before, reverse, firstId, otherId, initial, middle, final), run(shape, before, reverse, firstId, otherId, initial, middle, final), expected,
    Equal.cong(R.World, R.World, state => run(state, before, reverse, firstId, otherId, initial, middle, final), joined, shape, joinedState(w, before, reverse, known)),
    both(ambient, before, reverse, firstId, otherId, second, initial, middle, final,
      retiredCapture(w, Pair.sourceId(before, [], reverse), before, firstId, second, firstCapture),
      retiredCapture(w, Pair.sourceId(before, [], reverse), before, otherId, Bool.not(second), otherCapture)))

def selectedId(+cells: List<&2, R.ActionState>, second: Bool) -> Nat:
  B.choose(~Nat, second, _ => 1n+Nat.add(B.length(R.ActionState, cells), 1n), _ => 1n+B.length(R.ActionState, cells))

def selectedSame(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +second: Bool) ->
  {Actions.idFor(w, before, cells, first, second) == selectedId(cells, second) : Nat}:
  match second:
    case False{}: {==}
    case True{}:
      Equal.cong(Nat, Nat, n => 1n+n, B.length(R.ActionState, Actions.nextCells(w, before, cells, first)), Nat.add(B.length(R.ActionState, cells), 1n), Arena.appendLength(R.ActionState, cells, [Actions.firstEntry(w, before, first)]))

def selectedCapture(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +second: Bool) ->
  {R.ActionState.transaction(A.get(Actions.second(w, before, cells, first, other), selectedId(cells, second))) == Actions.transactionChoice(before, second) : Nat}:
  Equal.trans(Nat, R.ActionState.transaction(A.get(Actions.second(w, before, cells, first, other), selectedId(cells, second))), R.ActionState.transaction(A.get(Actions.second(w, before, cells, first, other), Actions.idFor(w, before, cells, first, second))), Actions.transactionChoice(before, second),
    Equal.cong(Nat, Nat, id => R.ActionState.transaction(A.get(Actions.second(w, before, cells, first, other), id)), selectedId(cells, second), Actions.idFor(w, before, cells, first, second), Equal.sym(Nat, Actions.idFor(w, before, cells, first, second), selectedId(cells, second), selectedSame(w, before, cells, first, second))), Actions.captureChoice(w, before, cells, first, other, second))

def programme(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool, +second: Bool,
  initial: List<&2, History.JoinEvent>, middle: List<&2, History.JoinEvent>, final: List<&2, History.JoinEvent>) -> R.World:
  run(Actions.joined(w, before, cells, first, other, reverse), before, reverse, selectedId(cells, second), selectedId(cells, Bool.not(second)), initial, middle, final)

def expected(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool) -> R.World:
  Count.state(B.schedule(B.schedule(Pair.retire(Actions.second(w, before, cells, first, other), Pair.sourceId(before, [], reverse)))), before, reverse, 0n)

# An indexed certificate packages the same complete World equation. Its index
# mentions the actual constructed World once; the kernel need not repeatedly
# normalize its nested source setters while converting the composition type.
type Completion<-w: R.World, -before: List<&2, R.Transaction>, -reverse: Bool, -firstId: Nat, -otherId: Nat,
  -initial: List<&2, History.JoinEvent>, -middle: List<&2, History.JoinEvent>, -final: List<&2, History.JoinEvent>> is Data:
  Complete{equation: {run(X.merge(w, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), before, reverse, firstId, otherId, initial, middle, final) == Count.state(B.schedule(B.schedule(Pair.retire(w, Pair.sourceId(before, [], reverse)))), before, reverse, 0n) : R.World}}

def certify(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +firstId: Nat, +otherId: Nat, +second: Bool,
  +initial: List<&2, History.JoinEvent>, +middle: List<&2, History.JoinEvent>, +final: List<&2, History.JoinEvent>,
  known: {Pair.scope(w, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []) == w : R.World},
  firstCapture: {R.ActionState.transaction(A.get(w, firstId)) == Actions.transactionChoice(before, second) : Nat},
  otherCapture: {R.ActionState.transaction(A.get(w, otherId)) == Actions.transactionChoice(before, Bool.not(second)) : Nat}) -> Completion<w, before, reverse, firstId, otherId, initial, middle, final>:
  Complete{allocatedBoth(w, before, reverse, firstId, otherId, second, initial, middle, final, known, firstCapture, otherCapture)}

# Real constructors supply every shape/capture premise. The certificate contains
# the whole World equality, including exactly one source retirement and both
# source schedule operations; it does not assume the desired transition result.
def constructed(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool, +second: Bool,
  +initial: List<&2, History.JoinEvent>, +middle: List<&2, History.JoinEvent>, +final: List<&2, History.JoinEvent>) ->
  Completion<Actions.second(w, before, cells, first, other), before, reverse, selectedId(cells, second), selectedId(cells, Bool.not(second)), initial, middle, final>:
  certify(Actions.second(w, before, cells, first, other), before, reverse, selectedId(cells, second), selectedId(cells, Bool.not(second)), second, initial, middle, final,
    Actions.allocatedPair(w, before, cells, first, other), selectedCapture(w, before, cells, first, other, second), selectedCapture(w, before, cells, first, other, Bool.not(second)))

def equation(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +firstId: Nat, +otherId: Nat,
  +initial: List<&2, History.JoinEvent>, +middle: List<&2, History.JoinEvent>, +final: List<&2, History.JoinEvent>,
  certificate: Completion<w, before, reverse, firstId, otherId, initial, middle, final>) ->
  {run(X.merge(w, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), before, reverse, firstId, otherId, initial, middle, final) == Count.state(B.schedule(B.schedule(Pair.retire(w, Pair.sourceId(before, [], reverse)))), before, reverse, 0n) : R.World}:
  match certificate:
    case Complete{proof}: proof

def zeroCertified(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +firstId: Nat, +otherId: Nat,
  +initial: List<&2, History.JoinEvent>, +middle: List<&2, History.JoinEvent>, +final: List<&2, History.JoinEvent>,
  certificate: Completion<w, before, reverse, firstId, otherId, initial, middle, final>) ->
  {R.Transaction.open(B.transaction(run(X.merge(w, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), before, reverse, firstId, otherId, initial, middle, final), Pair.targetId(before, [], reverse))) == 0n : Nat}:
  +actual = run(X.merge(w, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), before, reverse, firstId, otherId, initial, middle, final)
  +expected = Count.state(B.schedule(B.schedule(Pair.retire(w, Pair.sourceId(before, [], reverse)))), before, reverse, 0n)
  Equal.trans(Nat, R.Transaction.open(B.transaction(actual, Pair.targetId(before, [], reverse))), R.Transaction.open(B.transaction(expected, Pair.targetId(before, [], reverse))), 0n,
    Equal.cong(R.World, Nat, state => R.Transaction.open(B.transaction(state, Pair.targetId(before, [], reverse))), actual, expected, equation(w, before, reverse, firstId, otherId, initial, middle, final, certificate)),
    Count.count(B.schedule(B.schedule(Pair.retire(w, Pair.sourceId(before, [], reverse)))), before, reverse, 0n))
