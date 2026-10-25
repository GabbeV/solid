# Actual constructor and callback/retirement controls, with derived actor zero.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/flight.bend as F
import ../runtime/core.bend as C

def initial() -> R.World:
  +action = A.create(B.empty(),R.ActionEnd{})
  +id = B.second(R.World,Nat,action)
  +w = A.open(B.first(R.World,Nat,action),id)
  +result = F.newThenable(w,False{},R.Unresolved{})
  B.first(R.World,Nat,A.wait(B.first(R.World,Nat,result),id,B.second(R.World,Nat,result),0))

def first(rejected: Bool,value: R.Value) -> C.Machine:
  C.asyncActionDelivery(initial(),[],[],1n,rejected,value,A.find(R.World.actionWaits(initial()),1n))

def actual_constructor_actor_is_captured() -> {A.find(R.World.actionWaits(initial()),1n) == Some{R.ActionWait{1n,0n,0,False{}}} : Maybe<&2,R.ActionWait>}:
  {==}

def actual_first_callback_sets_its_cell() -> {A.find(R.World.actionWaits(C.world(first(False{},R.Undefined{}))),1n) == Some{R.ActionWait{1n,0n,0,True{}}} : Maybe<&2,R.ActionWait>}:
  {==}

def actual_terminal_return_retires_the_obligation() -> {R.Transaction.open(B.transaction(C.world(C.step(first(False{},R.Undefined{}))),1n)) == 0n : Nat}:
  {==}

def rejected_thenable_remains_a_rejection_reason() -> {R.AsyncObject.state(B.asyncObject(C.world(C.step(first(True{},R.AsyncValue{2n}))),1n)) == R.Rejected{R.AsyncValue{2n}} : R.AsyncSettlement}:
  {==}
