# Two successful action-factory prefixes, allocated/opened by the actual
# runtime and then joined. No initial/captured/open-count equation is assumed.
# Generator slices, delivery and the publication seam are not run here.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ../runtime/question.bend as Q
import ./arena.bend as Arena
import ./action-created.bend as Created
import ./action-opening.bend as Opening
import ./transaction-pair.bend as Pair
import ./transaction-merge-laws.bend as M
import ./action-join.bend as JoinedAction
import ./action-resolution.bend as Done
import ./transaction-joined-history.bend as JoinedHistory

def firstEntry(+w: R.World, +arena: List<&2, R.Transaction>, first: R.Expr) -> R.ActionState:
  Opening.updated(Created.cell(w, first), 1n+B.length(R.Transaction, arena), Q.increment(R.World.questions(w)))

def nextArena(arena: List<&2, R.Transaction>) -> List<&2, R.Transaction>:
  B.append(R.Transaction, arena, [Opening.record(1n, True{})])

def nextCells(+w: R.World, +arena: List<&2, R.Transaction>, cells: List<&2, R.ActionState>, first: R.Expr) -> List<&2, R.ActionState>:
  B.append(R.ActionState, cells, [firstEntry(w, arena, first)])

def second(+w: R.World, +arena: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, first: R.Expr, second: R.Expr) -> R.World:
  Created.start(A.create(Created.run(w, arena, cells, first), second))

def expected(+w: R.World, +arena: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, second: R.Expr) -> R.World:
  Created.expected(Created.expected(w, arena, cells, first), nextArena(arena), nextCells(w, arena, cells, first), second)

def firstShape(+w: R.World, +arena: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr) ->
  {Created.expected(w, arena, cells, first) == Created.initial(Created.expected(w, arena, cells, first), nextArena(arena), nextCells(w, arena, cells, first)) : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: {==}

def constructs(+w: R.World, +arena: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr) ->
  {second(w, arena, cells, first, other) == expected(w, arena, cells, first, other) : R.World}:
  +once = Created.expected(w, arena, cells, first)
  Equal.trans(R.World, second(w, arena, cells, first, other), Created.start(A.create(once, other)), expected(w, arena, cells, first, other),
    Equal.cong(R.World, R.World, world => Created.start(A.create(world, other)), Created.run(w, arena, cells, first), once, Created.opens(w, arena, cells, first)),
    Equal.trans(R.World, Created.start(A.create(once, other)), Created.run(once, nextArena(arena), nextCells(w, arena, cells, first), other), expected(w, arena, cells, first, other),
      Equal.cong(R.World, R.World, world => Created.start(A.create(world, other)), once, Created.initial(once, nextArena(arena), nextCells(w, arena, cells, first)), firstShape(w, arena, cells, first)),
      Created.opens(once, nextArena(arena), nextCells(w, arena, cells, first), other)))

def expectedArena(+w: R.World, +arena: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr) ->
  {R.World.txArena(expected(w, arena, cells, first, other)) == B.blank_transaction() <> B.append(R.Transaction, arena, [Opening.record(1n, True{}), Opening.record(1n, True{})]) : List<&2, R.Transaction>}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2, R.Transaction>, List<&2, R.Transaction>, xs => B.blank_transaction() <> xs,
        B.append(R.Transaction, B.append(R.Transaction, arena, [Opening.record(1n, True{})]), [Opening.record(1n, True{})]), B.append(R.Transaction, arena, [Opening.record(1n, True{}), Opening.record(1n, True{})]),
        Arena.appendSingletons(R.Transaction, arena, Opening.record(1n, True{}), Opening.record(1n, True{})))

def arena(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr) ->
  {R.World.txArena(second(w, before, cells, first, other)) == B.blank_transaction() <> B.append(R.Transaction, before, [Opening.record(1n, True{}), Opening.record(1n, True{})]) : List<&2, R.Transaction>}:
  Equal.trans(List<&2, R.Transaction>, R.World.txArena(second(w, before, cells, first, other)), R.World.txArena(expected(w, before, cells, first, other)), B.blank_transaction() <> B.append(R.Transaction, before, [Opening.record(1n, True{}), Opening.record(1n, True{})]),
    Equal.cong(R.World, List<&2, R.Transaction>, world => R.World.txArena(world), second(w, before, cells, first, other), expected(w, before, cells, first, other), constructs(w, before, cells, first, other)), expectedArena(w, before, cells, first, other))

def sameArena(+w: R.World, +xs: List<&2, R.Transaction>, known: {xs == R.World.txArena(w) : List<&2, R.Transaction>}) ->
  {R.World.with_txArena(w, xs) == w : R.World}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.cong(List<&2, R.Transaction>, R.World, values => R.World.with_txArena(w, values), xs, txArena, known)

def allocatedPair(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr) ->
  {Pair.scope(second(w, before, cells, first, other), before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []) == second(w, before, cells, first, other) : R.World}:
  sameArena(second(w, before, cells, first, other), B.blank_transaction() <> B.append(R.Transaction, before, [Opening.record(1n, True{}), Opening.record(1n, True{})]),
    Equal.sym(List<&2, R.Transaction>, R.World.txArena(second(w, before, cells, first, other)), B.blank_transaction() <> B.append(R.Transaction, before, [Opening.record(1n, True{}), Opening.record(1n, True{})]), arena(w, before, cells, first, other)))

def joined(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool) -> R.World:
  X.merge(second(w, before, cells, first, other), Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse))

def rootRecord() -> {M.root(Opening.record(1n, True{})) == Opening.record(1n, True{}) : R.Transaction}:
  {==}

# The operation contract is proved once for an opaque actual World. Keeping
# the allocation certificate at this boundary avoids expanding the two action
# constructors separately inside every merge operand during conversion.
def joinAllocated(+world: R.World, +before: List<&2, R.Transaction>, +reverse: Bool,
  known: {Pair.scope(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []) == world : R.World}) ->
  {X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)) == Pair.merged(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse) : R.World}:
  Equal.cong(R.World, R.World, state => X.merge(state, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), world, Pair.scope(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []),
    Equal.sym(R.World, Pair.scope(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []), world, known))

def joinShape(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool) ->
  {joined(w, before, cells, first, other, reverse) == Pair.merged(second(w, before, cells, first, other), before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse) : R.World}:
  joinAllocated(second(w, before, cells, first, other), before, reverse, allocatedPair(w, before, cells, first, other))

def obligationsTwo(+reverse: Bool) -> {Pair.obligations(Opening.record(1n, True{}), Opening.record(1n, True{}), reverse) == 2n : Nat}:
  match reverse:
    case False{}: {==}
    case True{}: {==}

def countAllocated(+world: R.World, +before: List<&2, R.Transaction>, +reverse: Bool,
  known: {Pair.scope(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []) == world : R.World}) ->
  {R.Transaction.open(B.transaction(X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), Pair.targetId(before, [], reverse))) == 2n : Nat}:
  Equal.trans(Nat, R.Transaction.open(B.transaction(X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), Pair.targetId(before, [], reverse))), R.Transaction.open(B.transaction(Pair.merged(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse), Pair.targetId(before, [], reverse))), 2n,
    Equal.cong(R.World, Nat, state => R.Transaction.open(B.transaction(state, Pair.targetId(before, [], reverse))), X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), Pair.merged(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse), joinAllocated(world, before, reverse, known)),
    Equal.trans(Nat, R.Transaction.open(B.transaction(Pair.merged(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse), Pair.targetId(before, [], reverse))), Pair.obligations(Opening.record(1n, True{}), Opening.record(1n, True{}), reverse), 2n,
      Pair.count(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse), obligationsTwo(reverse)))

def two(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool) ->
  {R.Transaction.open(B.transaction(joined(w, before, cells, first, other, reverse), Pair.targetId(before, [], reverse))) == 2n : Nat}:
  countAllocated(second(w, before, cells, first, other), before, reverse, allocatedPair(w, before, cells, first, other))

def secondEntry(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, other: R.Expr) -> R.ActionState:
  +once = Created.expected(w, before, cells, first)
  Opening.updated(Created.cell(once, other), 1n+B.length(R.Transaction, nextArena(before)), Q.increment(R.World.questions(once)))

def updatedTransaction(+entry: R.ActionState, +t: Nat, +q: R.Question) ->
  {R.ActionState.transaction(Opening.updated(entry, t, q)) == t : Nat}:
  match entry:
    case R.ActionState{transaction, question, methods, result}: {==}

def firstExpectedTransaction(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr) ->
  {R.ActionState.transaction(A.get(expected(w, before, cells, first, other), 1n+B.length(R.ActionState, cells))) == Pair.leftId(before) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.trans(Nat, R.ActionState.transaction(A.get(expected(w, before, cells, first, other), 1n+B.length(R.ActionState, cells))), R.ActionState.transaction(firstEntry(w, before, first)), Pair.leftId(before),
        Equal.cong(R.ActionState, Nat, entry => R.ActionState.transaction(entry), A.get(expected(w, before, cells, first, other), 1n+B.length(R.ActionState, cells)), firstEntry(w, before, first),
          Arena.firstOfAppendedPair(R.ActionState, cells, firstEntry(w, before, first), secondEntry(w, before, cells, first, other), A.blank())), updatedTransaction(Created.cell(w, first), 1n+B.length(R.Transaction, before), Q.increment(questions)))

def secondExpectedTransaction(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr) ->
  {R.ActionState.transaction(A.get(expected(w, before, cells, first, other), 1n+B.length(R.ActionState, nextCells(w, before, cells, first)))) == Pair.rightId(before, []) : Nat}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      Equal.trans(Nat, R.ActionState.transaction(A.get(expected(w, before, cells, first, other), 1n+B.length(R.ActionState, nextCells(w, before, cells, first)))), 1n+B.length(R.Transaction, nextArena(before)), Pair.rightId(before, []),
        Equal.trans(Nat, R.ActionState.transaction(A.get(expected(w, before, cells, first, other), 1n+B.length(R.ActionState, nextCells(w, before, cells, first)))), R.ActionState.transaction(secondEntry(w, before, cells, first, other)), 1n+B.length(R.Transaction, nextArena(before)),
          Equal.cong(R.ActionState, Nat, entry => R.ActionState.transaction(entry), A.get(expected(w, before, cells, first, other), 1n+B.length(R.ActionState, nextCells(w, before, cells, first))), secondEntry(w, before, cells, first, other),
            Arena.getPrefix(R.ActionState, A.blank() <> nextCells(w, before, cells, first), secondEntry(w, before, cells, first, other), [], A.blank())), updatedTransaction(Created.cell(Created.expected(w, before, cells, first), other), 1n+B.length(R.Transaction, nextArena(before)), Q.increment(R.World.questions(Created.expected(w, before, cells, first))))),
        Equal.cong(Nat, Nat, size => 1n+size, B.length(R.Transaction, nextArena(before)), Nat.add(B.length(R.Transaction, before), 1n), Arena.appendLength(R.Transaction, before, [Opening.record(1n, True{})])))

def firstCaptured(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr) ->
  {R.ActionState.transaction(A.get(second(w, before, cells, first, other), 1n+B.length(R.ActionState, cells))) == Pair.leftId(before) : Nat}:
  Equal.trans(Nat, R.ActionState.transaction(A.get(second(w, before, cells, first, other), 1n+B.length(R.ActionState, cells))), R.ActionState.transaction(A.get(expected(w, before, cells, first, other), 1n+B.length(R.ActionState, cells))), Pair.leftId(before),
    Equal.cong(R.World, Nat, world => R.ActionState.transaction(A.get(world, 1n+B.length(R.ActionState, cells))), second(w, before, cells, first, other), expected(w, before, cells, first, other), constructs(w, before, cells, first, other)), firstExpectedTransaction(w, before, cells, first, other))

def secondCaptured(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr) ->
  {R.ActionState.transaction(A.get(second(w, before, cells, first, other), 1n+B.length(R.ActionState, nextCells(w, before, cells, first)))) == Pair.rightId(before, []) : Nat}:
  Equal.trans(Nat, R.ActionState.transaction(A.get(second(w, before, cells, first, other), 1n+B.length(R.ActionState, nextCells(w, before, cells, first)))), R.ActionState.transaction(A.get(expected(w, before, cells, first, other), 1n+B.length(R.ActionState, nextCells(w, before, cells, first)))), Pair.rightId(before, []),
    Equal.cong(R.World, Nat, world => R.ActionState.transaction(A.get(world, 1n+B.length(R.ActionState, nextCells(w, before, cells, first)))), second(w, before, cells, first, other), expected(w, before, cells, first, other), constructs(w, before, cells, first, other)), secondExpectedTransaction(w, before, cells, first, other))

# Preserve closure capture across the actual join, including the retired
# action's original transaction ID. Only scheduling groups are merged.
def frameAllocated(+world: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +id: Nat,
  known: {Pair.scope(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []) == world : R.World}) ->
  {A.get(X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), id) == A.get(world, id) : R.ActionState}:
  Equal.cong(List<&2, R.ActionState>, R.ActionState, states => B.get(R.ActionState, states, id, A.blank()), R.World.actions(X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse))), R.World.actions(world),
    Equal.trans(List<&2, R.ActionState>, R.World.actions(X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse))), R.World.actions(Pair.merged(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse)), R.World.actions(world),
      Equal.cong(R.World, List<&2, R.ActionState>, state => R.World.actions(state), X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), Pair.merged(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse), joinAllocated(world, before, reverse, known)), Pair.actionFrame(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse)))

def resolveAllocated(+world: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +retired: Bool,
  +known: {Pair.scope(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []) == world : R.World}) ->
  {X.resolveTx(X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), JoinedAction.capturedId(before, [], reverse, retired)) == B.Bundle{X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), Pair.targetId(before, [], reverse)} : B.Bundle<R.World, Nat>}:
  +next = X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse))
  +model = Pair.merged(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse)
  +root = Pair.targetId(before, [], reverse)
  +captured = JoinedAction.capturedId(before, [], reverse, retired)
  Equal.trans(B.Bundle<R.World, Nat>, X.resolveTx(next, captured), X.resolveTx(model, captured), B.Bundle{next, root},
    Equal.cong(R.World, B.Bundle<R.World, Nat>, state => X.resolveTx(state, captured), next, model, joinAllocated(world, before, reverse, known)),
    Equal.trans(B.Bundle<R.World, Nat>, X.resolveTx(model, captured), B.Bundle{model, root}, B.Bundle{next, root}, JoinedAction.resolution(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse, retired),
      Equal.cong(R.World, B.Bundle<R.World, Nat>, state => B.Bundle{state, root}, model, next, Equal.sym(R.World, next, model, joinAllocated(world, before, reverse, known)))))

def role(reverse: Bool, finishSecond: Bool) -> Bool:
  Bool.not(Bool.xor(reverse, finishSecond))

def transactionChoice(+before: List<&2, R.Transaction>, finishSecond: Bool) -> Nat:
  B.choose(~Nat, finishSecond, _ => Pair.rightId(before, []), _ => Pair.leftId(before))

def roleIdentity(+before: List<&2, R.Transaction>, +reverse: Bool, +finishSecond: Bool) ->
  {transactionChoice(before, finishSecond) == JoinedAction.capturedId(before, [], reverse, role(reverse, finishSecond)) : Nat}:
  match reverse:
    case False{}:
      match finishSecond:
        case False{}: {==}
        case True{}: {==}
    case True{}:
      match finishSecond:
        case False{}: {==}
        case True{}: {==}

def idFor(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, first: R.Expr, finishSecond: Bool) -> Nat:
  B.choose(~Nat, finishSecond, _ => 1n+B.length(R.ActionState, nextCells(w, before, cells, first)), _ => 1n+B.length(R.ActionState, cells))

def captureChoice(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +finishSecond: Bool) ->
  {R.ActionState.transaction(A.get(second(w, before, cells, first, other), idFor(w, before, cells, first, finishSecond))) == transactionChoice(before, finishSecond) : Nat}:
  match finishSecond:
    case False{}: firstCaptured(w, before, cells, first, other)
    case True{}: secondCaptured(w, before, cells, first, other)

def completeAllocated(+world: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +finishSecond: Bool, +id: Nat,
  +known: {Pair.scope(world, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []) == world : R.World},
  captured: {R.ActionState.transaction(A.get(world, id)) == transactionChoice(before, finishSecond) : Nat}) ->
  {A.done(X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), id) == B.schedule(B.store_transaction(X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), Pair.targetId(before, [], reverse), R.Transaction.with_open(B.transaction(X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), Pair.targetId(before, [], reverse)), 1n))) : R.World}:
  +next = X.merge(world, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse))
  +root = Pair.targetId(before, [], reverse)
  +which = JoinedAction.capturedId(before, [], reverse, role(reverse, finishSecond))
  Done.decreases(next, id, root, 1n,
    Equal.trans(B.Bundle<R.World, Nat>, X.resolveTx(next, R.ActionState.transaction(A.get(next, id))), X.resolveTx(next, which), B.Bundle{next, root},
      Equal.cong(Nat, B.Bundle<R.World, Nat>, t => X.resolveTx(next, t), R.ActionState.transaction(A.get(next, id)), which,
        Equal.trans(Nat, R.ActionState.transaction(A.get(next, id)), R.ActionState.transaction(A.get(world, id)), which,
          Equal.cong(R.ActionState, Nat, state => R.ActionState.transaction(state), A.get(next, id), A.get(world, id), frameAllocated(world, before, reverse, id, known)),
          Equal.trans(Nat, R.ActionState.transaction(A.get(world, id)), transactionChoice(before, finishSecond), which, captured, roleIdentity(before, reverse, finishSecond)))), resolveAllocated(world, before, reverse, role(reverse, finishSecond), known)), countAllocated(world, before, reverse, known))

# Either newly allocated action may complete first, through its actual captured
# identity, after either join direction. The real remaining debt is one; there
# is no supplied capture, resolver, positive-count or traversal-room premise.
def completeFirst(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool, +finishSecond: Bool) ->
  {A.done(joined(w, before, cells, first, other, reverse), idFor(w, before, cells, first, finishSecond)) == B.schedule(B.store_transaction(joined(w, before, cells, first, other, reverse), Pair.targetId(before, [], reverse), R.Transaction.with_open(B.transaction(joined(w, before, cells, first, other, reverse), Pair.targetId(before, [], reverse)), 1n))) : R.World}:
  completeAllocated(second(w, before, cells, first, other), before, reverse, finishSecond, idFor(w, before, cells, first, finishSecond), allocatedPair(w, before, cells, first, other), captureChoice(w, before, cells, first, other, finishSecond))

def historyAllocated(+state: R.World, +before: List<&2, R.Transaction>, +reverse: Bool, +events: List<&2, JoinedHistory.JoinEvent>,
  +known: {Pair.scope(state, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []) == state : R.World}) ->
  {JoinedHistory.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, X.merge(state, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse))) == JoinedHistory.Audit{X.merge(state, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), JoinedHistory.expected(Pair.targetId(before, [], reverse), events)} : JoinedHistory.Audit}:
  +next = X.merge(state, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse))
  +root = Pair.targetId(before, [], reverse)
  JoinedHistory.preserves(next, Pair.sourceId(before, [], reverse), root, root, events, resolveAllocated(state, before, reverse, True{}, known), resolveAllocated(state, before, reverse, False{}, known))

# Arbitrary finite branching observations/rejoins begin with two real action
# allocations/openings and the actual distinct-root merge, not a supplied ledger.
def history(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool, +events: List<&2, JoinedHistory.JoinEvent>) ->
  {JoinedHistory.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, joined(w, before, cells, first, other, reverse)) == JoinedHistory.Audit{joined(w, before, cells, first, other, reverse), JoinedHistory.expected(Pair.targetId(before, [], reverse), events)} : JoinedHistory.Audit}:
  historyAllocated(second(w, before, cells, first, other), before, reverse, events, allocatedPair(w, before, cells, first, other))

def finishOnHistory(+state: R.World, +source: Nat, +target: Nat, +id: Nat, +events: List<&2, JoinedHistory.JoinEvent>,
  audit: {JoinedHistory.run(source, target, events, state) == JoinedHistory.Audit{state, JoinedHistory.expected(target, events)} : JoinedHistory.Audit},
  finish: {A.done(state, id) == B.schedule(B.store_transaction(state, target, R.Transaction.with_open(B.transaction(state, target), 1n))) : R.World}) ->
  {A.done(JoinedHistory.world(JoinedHistory.run(source, target, events, state)), id) == B.schedule(B.store_transaction(state, target, R.Transaction.with_open(B.transaction(state, target), 1n))) : R.World}:
  Equal.trans(R.World, A.done(JoinedHistory.world(JoinedHistory.run(source, target, events, state)), id), A.done(state, id), B.schedule(B.store_transaction(state, target, R.Transaction.with_open(B.transaction(state, target), 1n))),
    Equal.cong(JoinedHistory.Audit, R.World, result => A.done(JoinedHistory.world(result), id), JoinedHistory.run(source, target, events, state), JoinedHistory.Audit{state, JoinedHistory.expected(target, events)}, audit), finish)

# Either action may be the first completion after any such finite history. The
# exact World equation includes source scheduling, with one obligation remaining.
def completeAfterHistory(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool, +finishSecond: Bool, +events: List<&2, JoinedHistory.JoinEvent>) ->
  {A.done(JoinedHistory.world(JoinedHistory.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, joined(w, before, cells, first, other, reverse))), idFor(w, before, cells, first, finishSecond)) == B.schedule(B.store_transaction(joined(w, before, cells, first, other, reverse), Pair.targetId(before, [], reverse), R.Transaction.with_open(B.transaction(joined(w, before, cells, first, other, reverse), Pair.targetId(before, [], reverse)), 1n))) : R.World}:
  finishOnHistory(joined(w, before, cells, first, other, reverse), Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), idFor(w, before, cells, first, finishSecond), events, history(w, before, cells, first, other, reverse, events), completeFirst(w, before, cells, first, other, reverse, finishSecond))
