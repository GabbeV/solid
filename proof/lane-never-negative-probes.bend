# Closed actual-branch oracle, separate from the general statement. Malformed
# generic proof elaboration after mutation is not a credited counterexample.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/constants.bend as K

def initial() -> R.World:
  +w = R.World.with_nodes(B.empty(),[B.blank_node(),R.Node.with_kind(B.blank_node(),R.Memo{}),R.Node.with_kind(B.blank_node(),R.Render{})])
  +w = R.World.with_txArena(w,[B.blank_transaction(),R.Transaction.with_verdict(B.blank_transaction(),2n),R.Transaction.with_shown(R.Transaction.with_parent(R.Transaction.with_lane(B.blank_transaction(),True{}),1n),True{})])
  R.World.with_passLane(w,2n)

def result() -> C.Machine:
  C.laneReadRender(initial(),[],[R.Number{71n}],2n,1n,2n,False{},K.STATUS_PENDING())

def clears_verdict_pass() -> {R.World.passLane(C.world(result())) == 0n : Nat}:
  {==}

def returns_token_without_losing_caller_stack() -> {C.values(result()) == [R.NotPendingToken{},R.Number{71n}] : List<&2,R.Value>}:
  {==}
