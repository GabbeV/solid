# Actual merge sequence: append copies marks into a separate recipient array;
# later merges leave the retired sender scope unchanged.
import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/transaction.bend as T
import ../../runtime/affects-marks.bend as Marks
import ../../runtime/affects-scope.bend as Scope

def fixture() -> R.World:
  +w = N.createOwner(B.empty(), 0n, False{})
  +w = N.signal(N.signal(w, R.Number{1n}, N.defaults()), R.Number{2n}, N.defaults())
  +w = Marks.mark(Marks.mark(w, 2n), 3n)
  +w = B.first(R.World, Nat, T.newTransaction(w, False{}, 0n))
  +w = B.first(R.World, Nat, T.newTransaction(w, False{}, 0n))
  +w = B.first(R.World, Nat, T.newTransaction(w, False{}, 0n))
  +w = B.store_transaction(w, 1n, R.Transaction.with_marks(B.transaction(w, 1n), R.SomeIds{[2n]}))
  +w = B.store_transaction(w, 3n, R.Transaction.with_marks(B.transaction(w, 3n), R.SomeIds{[3n]}))
  T.merge(T.merge(w, 1n, 2n), 3n, 2n)


def registerCopies(copies: Nat, w: R.World) -> R.World:
  match copies:
    case 0n: w
    case 1n+p: registerCopies(p, Scope.affects(w, R.AccessorReference{1n}))

def registerFixture(tx: Nat, redirected: Bool, copies: Nat) -> R.World:
  +w = N.signal(N.signal(B.empty(), R.Number{1n}, N.defaults()), R.Number{2n}, N.defaults())
  +w = B.first(R.World, Nat, T.newTransaction(w, False{}, 0n))
  +w = B.first(R.World, Nat, T.newTransaction(w, False{}, 0n))
  +w = B.choose(~R.World, redirected, _ => T.merge(w, 1n, 2n), _ => w)
  registerCopies(copies, R.World.with_flushTransaction(w, tx))
