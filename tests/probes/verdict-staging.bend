# rc.21 holdStaging source segment. Raw fixtures, not public reachability.
import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/construct.bend as N
import ../../runtime/extension.bend as E
import ../../runtime/transaction.bend as T
import ../../runtime/lanes-state.bend as L
import ../../runtime/verdict-staging.bend as V
import ../../runtime/read-transaction.bend as ReadTx

# mark=0 absent, 1/2 clocks0/9, 3/4 transaction1/2.
def mark(kind: U32) -> R.AskedIn:
  match kind:
    case 0: R.Unasked{}
    case 1: R.AskedClock{0n}
    case 2: R.AskedClock{9n}
    case 3: R.AskedTransaction{1n}
    case _: R.AskedTransaction{2n}

def fixture(readerConfig: U32, readerFlags: U32, sourceConfig: U32, staged: Bool, kind: U32, owner: Nat, flush: Nat, lane: Nat, clock: Nat, redirect: Bool) -> B.Bundle<R.World, Bool>:
  +w = N.signal(B.empty(), R.Number{7n}, N.defaults())
  +w = N.computed(0n,w,R.Literal{R.Number{2n}},R.NodeOptions.with_lazy(N.defaults(),True{}),0n)
  +w = B.first(R.World,Nat,T.newTransaction(w,False{},0n))
  +w = B.first(R.World,Nat,T.newTransaction(w,False{},0n))
  +w = B.first(R.World,Nat,L.verdictLane(w,1n))
  +w = B.first(R.World,Nat,L.newLane(w,2n))
  +w = B.store_node(w,1n,R.Node.with_config(R.Node.with_pending(B.node(w,1n),B.choose(~R.Slot,staged,_=>R.Present{R.Number{23n}},_=>R.Empty{})),sourceConfig))
  +w = B.store_node(w,2n,R.Node.with_config(R.Node.with_flags(B.node(w,2n),readerFlags),readerConfig))
  +w = E.ext(w,1n)
  +w = B.store_extension(w,1n,R.NodeExtension.with_askedIn(R.NodeExtension.with_transaction(B.extension(w,1n),owner),mark(kind)))
  +w = B.choose(~R.World,redirect,_=>T.merge(w,1n,2n),_=>w)
  +w = R.World.with_flushTransaction(w,flush)
  +w = R.World.with_passLane(w,lane)
  V.holdStaging(R.World.with_clock(w,clock),2n,1n)

# Same admitted raw transaction identities, at the actual frameRead entry.
def withOver(+w: R.World,+tx: Nat,over: Nat) -> R.World:
  B.store_transaction(w,tx,R.Transaction.with_over(B.transaction(w,tx),over))

def frame(w: R.World) -> B.Bundle<R.World,Bool>:
  ReadTx.frameRead(w,2n,1n)
