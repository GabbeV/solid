# Small actual-operation controls for capture writes and shared arena identity.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/flight.bend as F
import ../runtime/iterator-state.bend as I

def initial() -> R.World:
  R.World.with_actionWaits(R.World.with_asyncObservers(R.World.with_asyncObjects(B.empty(),[B.blank_asyncObject(),R.AsyncObject{False{},R.Unresolved{},[],0n}]),[B.blank_asyncObserver(),B.blank_asyncObserver()]),[R.ActionWait{1n,1n,0,True{}}])

def synchronous_capture_keeps_settled_waits(+value: R.Value) -> {R.World.actionWaits(F.syncFulfilled(initial(),1n,value)) == [R.ActionWait{1n,1n,0,True{}}] : List<&2,R.ActionWait>}:
  {==}

def stream_step_uses_next_arena_identity() -> {B.second(R.World,Nat,I.newStepObserver(initial(),0n)) == 2n : Nat}:
  {==}

def ignored_return_keeps_settled_waits() -> {R.World.actionWaits(I.ignoreThen(initial(),1n)) == [R.ActionWait{1n,1n,0,True{}}] : List<&2,R.ActionWait>}:
  {==}
