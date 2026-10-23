# Actual completion of an allocated ordinary group with arbitrary owned graph
# work. No callback body or flight delivery is substituted by this contract.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./transaction-arena.bend as Arena
import ./action-resolution.bend as Completion
import ./transaction-resolution.bend as Paths
import ./transaction-positive-update.bend as Update

def expected(+w: R.World, +before: List<&2, R.Transaction>, +record: R.Transaction, +after: List<&2, R.Transaction>, remaining: Nat) -> R.World:
  B.schedule(Arena.scope(w, before, R.Transaction.with_open(record, remaining), after))

def allocated(+w: R.World, +before: List<&2, R.Transaction>, +record: R.Transaction, +after: List<&2, R.Transaction>, +id: Nat, +remaining: Nat,
  captured: {R.ActionState.transaction(A.get(Arena.scope(w, before, record, after), id)) == B.length(R.Transaction, before) : Nat},
  stopped: {R.Transaction.into(record) == 0n : Nat},
  positive: {R.Transaction.open(record) == 1n+remaining : Nat}) ->
  {A.done(Arena.scope(w, before, record, after), id) == expected(w, before, record, after, remaining) : R.World}:
  +start = Arena.scope(w, before, record, after)
  +root = B.length(R.Transaction, before)
  Equal.trans(R.World, A.done(start, id), Update.result(start, root, remaining), expected(w, before, record, after, remaining),
    Completion.decreases(start, id, root, remaining,
      Equal.trans(B.Bundle<R.World, Nat>, X.resolveTx(start, R.ActionState.transaction(A.get(start, id))), X.resolveTx(start, root), B.Bundle{start, root},
        Equal.cong(Nat, B.Bundle<R.World, Nat>, tx => X.resolveTx(start, tx), R.ActionState.transaction(A.get(start, id)), root, captured),
        Paths.stopped(start, root, B.length(R.Transaction, R.World.txArena(start)), Equal.trans(Nat, R.Transaction.into(B.transaction(start, root)), R.Transaction.into(record), 0n, Equal.cong(R.Transaction, Nat, t => R.Transaction.into(t), B.transaction(start, root), record, Arena.peek(w, before, record, after)), stopped))),
      Equal.trans(Nat, R.Transaction.open(B.transaction(start, root)), R.Transaction.open(record), 1n+remaining, Equal.cong(R.Transaction, Nat, t => R.Transaction.open(t), B.transaction(start, root), record, Arena.peek(w, before, record, after)), positive)),
    Equal.trans(R.World, Update.result(start, root, remaining), B.schedule(B.store_transaction(start, root, R.Transaction.with_open(record, remaining))), expected(w, before, record, after, remaining),
      Equal.cong(R.Transaction, R.World, old => B.schedule(B.store_transaction(start, root, R.Transaction.with_open(old, remaining))), B.transaction(start, root), record, Arena.peek(w, before, record, after)),
      Equal.cong(R.World, R.World, state => B.schedule(state), B.store_transaction(start, root, R.Transaction.with_open(record, remaining)), Arena.scope(w, before, R.Transaction.with_open(record, remaining), after), Arena.store(w, before, record, after, R.Transaction.with_open(record, remaining)))))

def currentRecord(+w: R.World, +before: List<&2, R.Transaction>, +record: R.Transaction, +after: List<&2, R.Transaction>, +remaining: Nat) ->
  {B.transaction(expected(w, before, record, after, remaining), B.length(R.Transaction, before)) == R.Transaction.with_open(record, remaining) : R.Transaction}:
  Equal.trans(R.Transaction, B.transaction(expected(w, before, record, after, remaining), B.length(R.Transaction, before)), B.transaction(Arena.scope(w, before, R.Transaction.with_open(record, remaining), after), B.length(R.Transaction, before)), R.Transaction.with_open(record, remaining),
    Update.scheduledRecord(Arena.scope(w, before, R.Transaction.with_open(record, remaining), after), B.length(R.Transaction, before)), Arena.peek(w, before, R.Transaction.with_open(record, remaining), after))
