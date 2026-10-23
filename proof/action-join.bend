# A completion after a genuine distinct-root merge. Structural source/target
# resolution and count transfer replace the earlier assumed resolver equation.
# Valid action capture and a positive obligation are still explicit premises.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./transaction-pair.bend as Pair
import ./action-resolution.bend as Done

def capturedId(+prefix: List<&2, R.Transaction>, +gap: List<&2, R.Transaction>, +reverse: Bool, retired: Bool) -> Nat:
  B.choose(~Nat, retired, _ => Pair.sourceId(prefix, gap, reverse), _ => Pair.targetId(prefix, gap, reverse))

def resolution(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool, +retired: Bool) ->
  {X.resolveTx(Pair.merged(w, prefix, left, gap, right, suffix, reverse), capturedId(prefix, gap, reverse, retired)) == B.Bundle{Pair.merged(w, prefix, left, gap, right, suffix, reverse), Pair.targetId(prefix, gap, reverse)} : B.Bundle<R.World, Nat>}:
  match retired:
    case False{}: Pair.targetResolves(w, prefix, left, gap, right, suffix, reverse)
    case True{}: Pair.sourceResolves(w, prefix, left, gap, right, suffix, reverse)

def completion(+w: R.World, +prefix: List<&2, R.Transaction>, +left: R.Transaction, +gap: List<&2, R.Transaction>, +right: R.Transaction, +suffix: List<&2, R.Transaction>, +reverse: Bool, +retired: Bool, +id: Nat, +remaining: Nat,
  captured: {R.ActionState.transaction(A.get(Pair.merged(w, prefix, left, gap, right, suffix, reverse), id)) == capturedId(prefix, gap, reverse, retired) : Nat},
  positive: {Pair.obligations(left, right, reverse) == 1n+remaining : Nat}) ->
  {A.done(Pair.merged(w, prefix, left, gap, right, suffix, reverse), id) == B.schedule(B.store_transaction(Pair.merged(w, prefix, left, gap, right, suffix, reverse), Pair.targetId(prefix, gap, reverse), R.Transaction.with_open(B.transaction(Pair.merged(w, prefix, left, gap, right, suffix, reverse), Pair.targetId(prefix, gap, reverse)), remaining))) : R.World}:
  +next = Pair.merged(w, prefix, left, gap, right, suffix, reverse)
  +root = Pair.targetId(prefix, gap, reverse)
  Done.decreases(next, id, root, remaining,
    Equal.trans(B.Bundle<R.World, Nat>, X.resolveTx(next, R.ActionState.transaction(A.get(next, id))), X.resolveTx(next, capturedId(prefix, gap, reverse, retired)), B.Bundle{next, root},
      Equal.cong(Nat, B.Bundle<R.World, Nat>, t => X.resolveTx(next, t), R.ActionState.transaction(A.get(next, id)), capturedId(prefix, gap, reverse, retired), captured), resolution(w, prefix, left, gap, right, suffix, reverse, retired)),
    Equal.trans(Nat, R.Transaction.open(B.transaction(next, root)), Pair.obligations(left, right, reverse), 1n+remaining, Pair.count(w, prefix, left, gap, right, suffix, reverse), positive))
