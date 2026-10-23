# Source action done prefix, composed with redirect resolution. This is not a
# proof of callback delivery, once-only completion or transaction publication.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./transaction-resolution.bend as Paths
import ./action-laws.bend as Depth

def finish(+pair: B.Bundle<R.World, Nat>) -> R.World:
  +w = B.first(R.World, Nat, pair)
  +root = B.second(R.World, Nat, pair)
  B.schedule(B.store_transaction(w, root, R.Transaction.with_open(B.transaction(w, root), Nat.sub(R.Transaction.open(B.transaction(w, root)), 1n))))

def completion(+w: R.World, +id: Nat, +root: Nat,
  resolution: {X.resolveTx(w, R.ActionState.transaction(A.get(w, id))) == B.Bundle{w, root} : B.Bundle<R.World, Nat>}) ->
  {A.done(w, id) == finish(B.Bundle{w, root}) : R.World}:
  Equal.cong(B.Bundle<R.World, Nat>, R.World, pair => finish(pair), X.resolveTx(w, R.ActionState.transaction(A.get(w, id))), B.Bundle{w, root}, resolution)

def decreases(+w: R.World, +id: Nat, +root: Nat, +remaining: Nat,
  resolution: {X.resolveTx(w, R.ActionState.transaction(A.get(w, id))) == B.Bundle{w, root} : B.Bundle<R.World, Nat>},
  open: {R.Transaction.open(B.transaction(w, root)) == 1n+remaining : Nat}) ->
  {A.done(w, id) == B.schedule(B.store_transaction(w, root, R.Transaction.with_open(B.transaction(w, root), remaining))) : R.World}:
  Equal.trans(R.World, A.done(w, id), finish(B.Bundle{w, root}), B.schedule(B.store_transaction(w, root, R.Transaction.with_open(B.transaction(w, root), remaining))), completion(w, id, root, resolution),
    Equal.cong(Nat, R.World, count => B.schedule(B.store_transaction(w, root, R.Transaction.with_open(B.transaction(w, root), count))), Nat.sub(R.Transaction.open(B.transaction(w, root)), 1n), remaining,
      Equal.trans(Nat, Nat.sub(R.Transaction.open(B.transaction(w, root)), 1n), Nat.sub(1n+remaining, 1n), remaining,
        Equal.cong(Nat, Nat, n => Nat.sub(n, 1n), R.Transaction.open(B.transaction(w, root)), 1n+remaining, open), Depth.subZero(remaining))))

def fromRoute(+w: R.World, +id: Nat, +path: Paths.Route<w>, +extra: Nat, +remaining: Nat,
  captured: {R.ActionState.transaction(A.get(w, id)) == Paths.origin(w, path) : Nat},
  room: {1n+B.length(R.Transaction, R.World.txArena(w)) == Nat.add(Paths.depth(w, path), 1n+extra) : Nat},
  open: {R.Transaction.open(B.transaction(w, Paths.terminal(w, path))) == 1n+remaining : Nat}) ->
  {A.done(w, id) == B.schedule(B.store_transaction(w, Paths.terminal(w, path), R.Transaction.with_open(B.transaction(w, Paths.terminal(w, path)), remaining))) : R.World}:
  decreases(w, id, Paths.terminal(w, path), remaining,
    Equal.trans(B.Bundle<R.World, Nat>, X.resolveTx(w, R.ActionState.transaction(A.get(w, id))), X.resolveTx(w, Paths.origin(w, path)), B.Bundle{w, Paths.terminal(w, path)},
      Equal.cong(Nat, B.Bundle<R.World, Nat>, n => X.resolveTx(w, n), R.ActionState.transaction(A.get(w, id)), Paths.origin(w, path), captured), Paths.public(w, path, extra, room)), open)
