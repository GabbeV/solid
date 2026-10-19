import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/api.bend as A
import ../../runtime/construct.bend as N
import ../../runtime/core.bend as C
import ../../runtime/transaction.bend as X
import ../../runtime/watch-state.bend as U
import ../../runtime/constants.bend as K

def expression(code: U32) -> R.Expr:
  match code:
    case 0:
      R.Literal{R.Number{23n}}
    case 1:
      R.Raise{R.Number{99n}}
    case 2:
      R.Raise{R.StatusFailure{1n, 2n, R.Number{99n}}}
    case 3:
      R.Raise{R.NotReadyFailure{2n, 2n}}
    case 4:
      R.Raise{R.Undefined{}}
    case _:
      R.Raise{R.Boolean{False{}}}

def fixture(own: Nat, flush: Nat, pass: Nat, +redirect: U32, flags: U32, cause: U32) -> C.Machine:
  +w = N.computed(0n, A.createWorld(), R.Literal{R.Undefined{}}, R.NodeOptions.with_lazy(N.defaults(), True{}), 1n)
  +w = B.first(R.World, Nat, X.newTransaction(w, False{}, 0n))
  +w = B.first(R.World, Nat, X.newTransaction(w, False{}, 0n))
  +w = B.first(R.World, Nat, X.newTransaction(w, False{}, 0n))
  +w = B.choose(~R.World, Bool.or(U32.is_eq(redirect, 1), U32.is_eq(redirect, 3)), _ => B.store_transaction(w, 1n, R.Transaction.with_into(B.transaction(w, 1n), 2n)), _ => w)
  +w = B.choose(~R.World, Bool.or(U32.is_eq(redirect, 2), U32.is_eq(redirect, 3)), _ => B.store_transaction(w, 2n, R.Transaction.with_into(B.transaction(w, 2n), 3n)), _ => w)
  +w = U.newAwaiter(w, R.Literal{R.Undefined{}}, False{}, 0n)
  +w = B.store_awaiter(w, 1n, R.Awaiter.with_own(B.awaiter(w, 1n), own))
  +w = B.store_node(w, 2n, R.Node.with_flags(B.node(w, 2n), flags))
  +w = R.World.with_context(R.World.with_passTx(R.World.with_flushTransaction(w, flush), pass), 2n)
  C.run(128n, C.Machine{w, [C.Evaluate{R.WatchExpr{1n, expression(cause)}, R.Undefined{}}], []})
