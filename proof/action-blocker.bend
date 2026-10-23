# Connect the constructed action accounting to the actual scheduler judgment.
# A positive group blocks even if it owns no observed flight. This is not a
# theorem that zero actions implies unblocked, or that a screen has published.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/transaction.bend as X
import ./transaction-pair.bend as Pair
import ./action-pair.bend as Actions
import ./action-opening.bend as Opening
import ./transaction-positive.bend as Positive
import ./transaction-joined-history.bend as History

def afterOk(+w: R.World, +before: List<&2, R.Transaction>, +reverse: Bool) ->
  {B.ok(Pair.after(w, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse)) == B.ok(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}:
      match reverse:
        case False{}: {==}
        case True{}: {==}

def expectedOk(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr) ->
  {B.ok(Actions.expected(w, before, cells, first, other)) == B.ok(w) : Bool}:
  match w:
    case R.World{+nodes, +links, +buckets, +minimum, +maximum, +marked, +pendingNodes, +trims, +renderQueue, +userQueue, +context, +tracking, +running, +scheduled, +clock, +epoch, +tree, +events, +fault, +unflushedStaged, +promotedWrites, +extensions, +cleanupPrograms, +dormantNodes, +errorSerial, +halted, +haltNotified, +reports, +callbackEffect, +txArena, +transactions, +flushTransaction, +passTx, +passLane, +judge, +deferredZombies, +question, +pendingSets, +asyncObjects, +asyncObservers, +hostJobs, +syncDepth, +streamPlans, +iterators, +streams, +iteratorEvents, +awaiters, +truthReadHook, +truthConfirmedHook, +questions, +abortInputs, +contextKeys, +contextRecords, +deferredReleases, +releaseLists, +stale, +settledCallbacks, +reactions, +comparators, +actionDepth, +actions, +actionWaits, +arrays, +repeats, +maps, +activeMarks, +laneState, +verdictState, +cleanupError, +ambientMarks, +deferredArena}: {==}

def constructedOk(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr) ->
  {B.ok(Actions.second(w, before, cells, first, other)) == B.ok(w) : Bool}:
  Equal.trans(Bool, B.ok(Actions.second(w, before, cells, first, other)), B.ok(Actions.expected(w, before, cells, first, other)), B.ok(w),
    Equal.cong(R.World, Bool, state => B.ok(state), Actions.second(w, before, cells, first, other), Actions.expected(w, before, cells, first, other), Actions.constructs(w, before, cells, first, other)), expectedOk(w, before, cells, first, other))

def joinedOk(+state: R.World, +before: List<&2, R.Transaction>, +reverse: Bool,
  known: {Pair.scope(state, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []) == state : R.World}) ->
  {B.ok(X.merge(state, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse))) == B.ok(state) : Bool}:
  +joined = X.merge(state, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse))
  +after = Pair.after(state, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse)
  Equal.trans(Bool, B.ok(joined), B.ok(after), B.ok(state),
    Equal.cong(R.World, Bool, w => B.ok(w), joined, after,
      Equal.trans(R.World, joined, Pair.merged(state, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse), after,
        Actions.joinAllocated(state, before, reverse, known), Pair.merge(state, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), [], reverse))), afterOk(state, before, reverse))

def blockedAllocated(+state: R.World, +before: List<&2, R.Transaction>, +reverse: Bool,
  +known: {Pair.scope(state, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []) == state : R.World},
  healthy: {B.ok(state) == True{} : Bool}) ->
  {X.blocked(X.merge(state, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), Pair.targetId(before, [], reverse)) == B.Bundle{X.merge(state, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), True{}} : B.Bundle<R.World, Bool>}:
  +joined = X.merge(state, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse))
  Positive.public(joined, Pair.targetId(before, [], reverse), 1n,
    Equal.trans(Bool, B.ok(joined), B.ok(state), True{}, joinedOk(state, before, reverse, known), healthy), Actions.countAllocated(state, before, reverse, known))

# Initial health is the only added premise. Allocation, capture, positive open
# count, valid selected IDs and source helper execution are established above.
def blocked(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool,
  healthy: {B.ok(w) == True{} : Bool}) ->
  {X.blocked(Actions.joined(w, before, cells, first, other, reverse), Pair.targetId(before, [], reverse)) == B.Bundle{Actions.joined(w, before, cells, first, other, reverse), True{}} : B.Bundle<R.World, Bool>}:
  blockedAllocated(Actions.second(w, before, cells, first, other), before, reverse, Actions.allocatedPair(w, before, cells, first, other),
    Equal.trans(Bool, B.ok(Actions.second(w, before, cells, first, other)), B.ok(w), True{}, constructedOk(w, before, cells, first, other), healthy))

def afterHistory(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool, +events: List<&2, History.JoinEvent>,
  healthy: {B.ok(w) == True{} : Bool}) ->
  {X.blocked(History.world(History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, Actions.joined(w, before, cells, first, other, reverse))), Pair.targetId(before, [], reverse)) == B.Bundle{Actions.joined(w, before, cells, first, other, reverse), True{}} : B.Bundle<R.World, Bool>}:
  +state = Actions.joined(w, before, cells, first, other, reverse)
  +root = Pair.targetId(before, [], reverse)
  Equal.trans(B.Bundle<R.World, Bool>, X.blocked(History.world(History.run(Pair.sourceId(before, [], reverse), root, events, state)), root), X.blocked(state, root), B.Bundle{state, True{}},
    Equal.cong(History.Audit, B.Bundle<R.World, Bool>, audit => X.blocked(History.world(audit), root), History.run(Pair.sourceId(before, [], reverse), root, events, state), History.Audit{state, History.expected(root, events)}, Actions.history(w, before, cells, first, other, reverse, events)), blocked(w, before, cells, first, other, reverse, healthy))
