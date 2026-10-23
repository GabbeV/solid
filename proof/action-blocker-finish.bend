# The other action still blocks after either first completion, including after
# arbitrary finite pair observations/rejoins. Zero-debt/publication is separate.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./transaction-pair.bend as Pair
import ./action-pair.bend as Actions
import ./action-opening.bend as Opening
import ./action-blocker.bend as Blocker
import ./transaction-positive.bend as Positive
import ./transaction-positive-update.bend as Update
import ./transaction-joined-history.bend as History

def expectedBlocked(+state: R.World, +before: List<&2, R.Transaction>, +reverse: Bool,
  +known: {Pair.scope(state, before, Opening.record(1n, True{}), [], Opening.record(1n, True{}), []) == state : R.World},
  healthy: {B.ok(state) == True{} : Bool}) ->
  {X.blocked(Update.result(X.merge(state, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), Pair.targetId(before, [], reverse), 1n), Pair.targetId(before, [], reverse)) == B.Bundle{Update.result(X.merge(state, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse)), Pair.targetId(before, [], reverse), 1n), True{}} : B.Bundle<R.World, Bool>}:
  +joined = X.merge(state, Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse))
  +root = Pair.targetId(before, [], reverse)
  Positive.public(Update.result(joined, root, 1n), root, 0n,
    Equal.trans(Bool, B.ok(Update.result(joined, root, 1n)), B.ok(joined), True{}, Update.healthyResult(joined, root, 1n),
      Equal.trans(Bool, B.ok(joined), B.ok(state), True{}, Blocker.joinedOk(state, before, reverse, known), healthy)), Update.countJoinedResult(state, before, reverse, 1n, known))

def transport(+actual: R.World, +expected: R.World, +root: Nat,
  +same: {actual == expected : R.World},
  blocked: {X.blocked(expected, root) == B.Bundle{expected, True{}} : B.Bundle<R.World, Bool>}) ->
  {X.blocked(actual, root) == B.Bundle{actual, True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, X.blocked(actual, root), X.blocked(expected, root), B.Bundle{actual, True{}},
    Equal.cong(R.World, B.Bundle<R.World, Bool>, state => X.blocked(state, root), actual, expected, same),
    Equal.trans(B.Bundle<R.World, Bool>, X.blocked(expected, root), B.Bundle{expected, True{}}, B.Bundle{actual, True{}}, blocked,
      Equal.cong(R.World, B.Bundle<R.World, Bool>, state => B.Bundle{state, True{}}, expected, actual, Equal.sym(R.World, actual, expected, same))))

def afterOne(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool, +finishSecond: Bool,
  healthy: {B.ok(w) == True{} : Bool}) ->
  {X.blocked(A.done(Actions.joined(w, before, cells, first, other, reverse), Actions.idFor(w, before, cells, first, finishSecond)), Pair.targetId(before, [], reverse)) == B.Bundle{A.done(Actions.joined(w, before, cells, first, other, reverse), Actions.idFor(w, before, cells, first, finishSecond)), True{}} : B.Bundle<R.World, Bool>}:
  +joined = Actions.joined(w, before, cells, first, other, reverse)
  +root = Pair.targetId(before, [], reverse)
  +id = Actions.idFor(w, before, cells, first, finishSecond)
  transport(A.done(joined, id), Update.result(joined, root, 1n), root, Actions.completeFirst(w, before, cells, first, other, reverse, finishSecond),
    expectedBlocked(Actions.second(w, before, cells, first, other), before, reverse, Actions.allocatedPair(w, before, cells, first, other),
      Equal.trans(Bool, B.ok(Actions.second(w, before, cells, first, other)), B.ok(w), True{}, Blocker.constructedOk(w, before, cells, first, other), healthy)))

def afterHistory(+w: R.World, +before: List<&2, R.Transaction>, +cells: List<&2, R.ActionState>, +first: R.Expr, +other: R.Expr, +reverse: Bool, +finishSecond: Bool, +events: List<&2, History.JoinEvent>,
  healthy: {B.ok(w) == True{} : Bool}) ->
  {X.blocked(A.done(History.world(History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, Actions.joined(w, before, cells, first, other, reverse))), Actions.idFor(w, before, cells, first, finishSecond)), Pair.targetId(before, [], reverse)) == B.Bundle{A.done(History.world(History.run(Pair.sourceId(before, [], reverse), Pair.targetId(before, [], reverse), events, Actions.joined(w, before, cells, first, other, reverse))), Actions.idFor(w, before, cells, first, finishSecond)), True{}} : B.Bundle<R.World, Bool>}:
  +joined = Actions.joined(w, before, cells, first, other, reverse)
  +root = Pair.targetId(before, [], reverse)
  +id = Actions.idFor(w, before, cells, first, finishSecond)
  transport(A.done(History.world(History.run(Pair.sourceId(before, [], reverse), root, events, joined)), id), Update.result(joined, root, 1n), root,
    Actions.completeAfterHistory(w, before, cells, first, other, reverse, finishSecond, events),
    expectedBlocked(Actions.second(w, before, cells, first, other), before, reverse, Actions.allocatedPair(w, before, cells, first, other),
      Equal.trans(Bool, B.ok(Actions.second(w, before, cells, first, other)), B.ok(w), True{}, Blocker.constructedOk(w, before, cells, first, other), healthy)))
