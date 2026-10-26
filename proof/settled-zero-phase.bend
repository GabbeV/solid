# Exact source phase expression, with no behavioral substitution.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending.bend as Q
import ../runtime/pending-state.bend as P
import ../runtime/transaction.bend as X
import ../runtime/constants.bend as K

def statused(+w: R.World,+node: Nat) -> R.World:
  B.store_node(w,node,R.Node.with_status(B.node(w,node),B.clear(R.Node.status(B.node(w,node)),K.STATUS_PENDING())))

def afterError(+w: R.World,+node: Nat) -> R.World:
  B.choose(~R.World,B.has(R.Node.config(B.node(w,node)),K.CONFIG_HELD()),_=>X.joinNode(w,node),_=>w)

def phase(+w: R.World,+node: Nat) -> R.World:
  afterError(P.setPendingError(statused(w,node),node,0n,R.Undefined{}),node)

def exact(+w: R.World,+node: Nat) -> {Q.settledStatus(w,node,0n,False{}) == phase(w,node) : R.World}:
  {==}
