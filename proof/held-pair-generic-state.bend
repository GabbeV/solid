# Real second create/open and distinct join, with the first controller World
# kept abstract at this operation boundary. No alternative runtime transition.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./transaction-pair.bend as Pair

def created(+w: R.World,second: R.Expr) -> B.Bundle<R.World,Nat>:
  A.create(w,second)

def actor(+w: R.World,second: R.Expr) -> Nat:
  B.second(R.World,Nat,created(w,second))

def opened(+w: R.World,second: R.Expr) -> R.World:
  +pair = created(w,second)
  A.open(B.first(R.World,Nat,pair),B.second(R.World,Nat,pair))

def joined(+w: R.World,second: R.Expr,+reverse: Bool) -> R.World:
  X.merge(opened(w,second),Pair.sourceId([],[],reverse),Pair.targetId([],[],reverse))
