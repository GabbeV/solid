# Paired private whole-round input. Callbacks are represented by render node
# and settled-fire identities and must remain parked, with their prefix order.
import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/core.bend as C
import ../../runtime/question.bend as Q
import ./mixed-parking.bend as Seed

def queues(+w: R.World,queued: Bool) -> R.World:
  B.choose(~R.World,queued,_=>
    +w = B.store_transaction(w,1n,R.Transaction.with_renderQueue(B.transaction(w,1n),[2n]))
    +w = B.store_transaction(w,1n,R.Transaction.with_userQueue(B.transaction(w,1n),[R.SettledFire{0n}]))
    R.World.with_userQueue(R.World.with_renderQueue(w,[2n,2n]),[R.SettledFire{1n},R.SettledFire{0n}]),_=>w)

def fixture(render: Bool,allocated: Bool,pending: R.Slot,status: U32,staged: Bool,debt: Nat,queued: Bool) -> C.Machine:
  +w = queues(Seed.seed(render,allocated,pending,status,staged,debt),queued)
  +w = R.World.with_running(w,False{})
  +w = R.World.with_question(w,Q.fromNat(3n))
  +w = R.World.with_cleanupPrograms(w,[R.CleanupProgram{[],False{},0n},R.CleanupProgram{[R.CleanupEmit{101n}],False{},0n},R.CleanupProgram{[R.CleanupEmit{102n}],False{},0n}])
  +w = R.World.with_settledCallbacks(w,[R.CallProgram{1n},R.CallProgram{2n}])
  C.run(4096n,C.Machine{w,[C.Round{},C.ActionRestoreQuestion{Q.fromNat(2n)}],[R.Number{71n}]})
