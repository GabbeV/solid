# Small real-constructor/write state for discrimination controls, not a general
# public reachability claim and not an alternate implementation.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct-state.bend as N
import ../runtime/transaction.bend as X
import ../runtime/write.bend as W

def world() -> R.World:
  +w = N.signal(B.empty(),R.Number{4n},N.defaults())
  +w = N.createEffectNode(w,R.Read{1n},R.Render{},0n,N.defaults(),0n,0n,0n)
  +w = B.first(R.World,Nat,X.newTransaction(w,False{},0n))
  +w = X.holdNode(w,1n,1n)
  +w = R.World.with_running(R.World.with_flushTransaction(w,1n),True{})
  +w = W.setSignal(w,1n,R.Number{8n})
  R.World.with_tracking(R.World.with_context(w,2n),True{})
