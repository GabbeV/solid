# Source-comparison seed only; this constructs private initial states rather
# than claiming a public path to every status/pending combination.
import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct-state.bend as N
import ../../runtime/extension.bend as E
import ../../runtime/transaction.bend as X
import ../../runtime/core.bend as C
import ../../runtime/constants.bend as K

def seed(+render: Bool,allocated: Bool,pending: R.Slot,status: U32,+staged: Bool,+debt: Nat) -> R.World:
  +w = N.signal(B.empty(),R.Number{7n},N.defaults())
  +options = R.NodeOptions.with_equals(R.NodeOptions.with_lazy(N.defaults(),True{}),False{})
  +w = B.choose(~R.World,render,
    _=>N.createEffectNode(w,R.Literal{R.Number{9n}},R.Render{},0n,N.defaults(),0n,0n,0n),
    _=>N.computed(w,R.Literal{R.Number{9n}},options,0n))
  +w = B.first(R.World,Nat,X.newTransaction(w,False{},0n))
  +w = X.holdNode(w,1n,1n)
  +w = B.store_transaction(w,1n,R.Transaction.with_open(B.transaction(w,1n),1n+debt))
  +w = B.choose(~R.World,allocated,_=>E.ext(w,2n),_=>w)
  +config = B.choose(~U32,render,_=>K.CONFIG_FRAME(),_=>0)
  +config = B.choose(~U32,staged,_=>B.set(config,K.CONFIG_STAGED()),_=>config)
  +w = B.store_node(w,2n,R.Node.with_pending(R.Node.with_status(R.Node.with_flags(R.Node.with_config(R.Node.with_value(B.node(w,2n),R.Undefined{}),config),0),status),pending))
  R.World.with_pendingNodes(R.World.with_running(R.World.with_flushTransaction(w,1n),True{}),[1n,2n])

def fixture(render: Bool,allocated: Bool,pending: R.Slot,status: U32,staged: Bool,debt: Nat) -> C.Machine:
  C.run(4096n,C.Machine{seed(render,allocated,pending,status,staged,debt),[C.Settle{}],[R.Number{71n}]})
