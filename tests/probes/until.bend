import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/core.bend as C
import ../../runtime/signals.bend as S
import ../../runtime/transaction.bend as X

def body(code: U32) -> R.Expr:
  match code:
    case 0:
      R.Literal{R.Number{0n}}
    case 1:
      R.Literal{R.Number{23n}}
    case 2:
      R.Raise{R.Number{99n}}
    case _:
      R.Raise{R.NotReadyFailure{1n, 2n}}

def fixture(own: Nat, flush: Nat, pass: Nat, redirect: Bool, flags: U32, running: Bool, +open: Bool, cause: U32) -> C.Machine:
  +w = R.World.with_syncDepth(B.empty(), 1n)
  +w = B.first(R.World, Nat, X.newTransaction(w, False{}, 0n))
  +w = B.first(R.World, Nat, X.newTransaction(w, False{}, 0n))
  +w = B.first(R.World, Nat, X.newTransaction(w, False{}, 0n))
  +w = B.choose(~R.World, redirect,
    _ => B.store_transaction(B.store_transaction(w, 1n, R.Transaction.with_into(B.transaction(w, 1n), 2n)), 2n, R.Transaction.with_into(B.transaction(w, 2n), 3n)), _ => w)
  +w = B.store_transaction(w, 1n, R.Transaction.with_open(B.transaction(w, 1n), B.choose(~Nat, open, _ => 1n, _ => 0n)))
  +w = B.store_transaction(w, 2n, R.Transaction.with_open(B.transaction(w, 2n), B.choose(~Nat, open, _ => 1n, _ => 0n)))
  +w = B.store_transaction(w, 3n, R.Transaction.with_open(B.transaction(w, 3n), B.choose(~Nat, open, _ => 1n, _ => 0n)))
  +w = S.until(256n, R.World.with_flushTransaction(w, own), R.Literal{R.Number{0n}})
  +w = R.World.with_hostJobs(w, [])
  +w = B.store_node(w, 2n, R.Node.with_flags(B.node(w, 2n), flags))
  +w = R.World.with_running(R.World.with_context(R.World.with_passTx(R.World.with_flushTransaction(w, flush), pass), 2n), running)
  C.run(128n, C.Machine{w, [C.Evaluate{R.WatchExpr{1n, body(cause)}, R.Undefined{}}], []})
