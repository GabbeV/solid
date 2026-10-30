# Rebase leaf and actual rerun/adoption entry probes; no alternate algorithm.
import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/core.bend as Core
import ../../runtime/creator-reads.bend as Creator
import ../../runtime/verdict-work.bend as Work
import ../../runtime/rerun-state.bend as Rerun
import ../../runtime/flight.bend as F
import ../../runtime/transaction.bend as Tx

def hold(w: R.World,n: Nat,s: Nat) -> Bool: Work.holdWork(w,n,s)
def creator(w: R.World,n: Nat,bits: U32) -> B.Bundle<R.World,U32>: Creator.creatorReads(w,n,bits)
def prepare(w: R.World,t: Nat,n: Nat,frame: Nat) -> B.Bundle<R.World,Nat>: Rerun.prepare(w,t,n,frame)
def skipped(w: R.World,n: Nat) -> Bool: Rerun.skipped(w,n)
def reruns(w: R.World,t: Nat) -> Core.Machine: Core.run(10000n,Core.Machine{w,[Core.RerunsLoop{t,0n,0n}],[]})
def adopt(+w: R.World,+n: Nat) -> Core.Machine: Core.run(10000n,Core.adoptParked(w,[],[],n,R.NodeExtension.parkedFlight(B.extension(w,n))))
def storeNode(w: R.World,n: Nat,row: R.Node) -> R.World: B.store_node(w,n,row)
def node(w: R.World,n: Nat) -> R.Node: B.node(w,n)
def storeExt(w: R.World,n: Nat,row: R.NodeExtension) -> R.World: B.store_extension(w,n,row)
def ext(w: R.World,n: Nat) -> R.NodeExtension: B.extension(w,n)

def transaction(w: R.World,lane: Bool) -> B.Bundle<R.World,Nat>: Tx.newTransaction(w,lane,0n)
def admissible(w: R.World,n: Nat) -> Bool: Rerun.adopts(w,n)

def register(+w: R.World,n: Nat,source: Nat) -> R.World:
  +pair = F.register(w,n,source)
  B.first(R.World,R.Value,F.thenValue(B.first(R.World,Nat,pair),B.second(R.World,Nat,pair)))

def storeTransaction(w: R.World,t: Nat,row: R.Transaction) -> R.World: B.store_transaction(w,t,row)
def transactionRow(w: R.World,t: Nat) -> R.Transaction: B.transaction(w,t)

def finish(w: R.World) -> Core.Machine: Core.finishSettleIntake(w,[],[],0n)
