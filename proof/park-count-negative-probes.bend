# Reduced projections for count-loss source mutations. These support, rather
# than replace, the quantified membership/parking contracts.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct-state.bend as N
import ../runtime/transaction.bend as X

def world() -> R.World:
  +w = N.signal(B.empty(),R.Number{0n},N.defaults())
  +w = B.first(R.World,Nat,X.newTransaction(w,False{},0n))
  B.store_transaction(w,1n,R.Transaction.with_open(B.transaction(w,1n),7n))

def holdingANodeRetainsActionDebt() -> {R.Transaction.open(B.transaction(X.holdNode(world(),1n,1n),1n)) == 7n : Nat}:
  {==}

def anExhaustedChildWalkRetainsActionDebt() -> {R.Transaction.open(B.transaction(X.holdRun(0n,world(),[X.HoldChild{0n,1n}]),1n)) == 7n : Nat}:
  {==}
