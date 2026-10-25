# Compact concrete-shape kernel controls for the actual registration operations.
import Base
import ../runtime/core.bend as Core
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/flight.bend as F


def initial(value: R.Value) -> R.World:
  B.first(R.World,Nat,F.newThenable(R.World.with_nodes(B.empty(),[B.blank_node(),R.Node.with_value(B.blank_node(),value)]),False{},R.Unresolved{}))

def first(value: R.Value) -> R.World:
  B.first(R.World,Nat,A.wait(initial(value),1n,1n,0))

def second(value: R.Value) -> R.World:
  B.first(R.World,Nat,A.wait(first(value),1n,1n,0))

def fresh_second_identity(+value: R.Value) -> {B.second(R.World,Nat,A.wait(first(value),1n,1n,0)) == 2n : Nat}:
  {==}

def new_yield_wait_starts_unsettled(+value: R.Value) -> {A.find(R.World.actionWaits(first(value)),1n) == Some{R.ActionWait{1n,1n,0,False{}}} : Maybe<&2,R.ActionWait>}:
  {==}

def registration_keeps_source_append_order(+value: R.Value) -> {R.World.actionWaits(second(value)) == [R.ActionWait{1n,1n,0,False{}},R.ActionWait{2n,1n,0,False{}}] : List<&2,R.ActionWait>}:
  {==}

def result_receives_both_observers(+value: R.Value) -> {R.AsyncObject.observers(B.asyncObject(second(value),1n)) == [1n,2n] : List<&2,Nat>}:
  {==}


def marked(+value: R.Value) -> R.World:
  R.World.with_actionWaits(first(value),A.settleWait(R.World.actionWaits(first(value)),1n))

def settled_then_throw_is_caught(+value: R.Value) -> {Core.actionYieldThrow(R.World.with_fault(marked(value),R.CallbackThrown{value}),[],[],1n,R.CallbackThrown{value}) == Core.Machine{R.World.with_fault(marked(value),R.Healthy{}),[],[]} : Core.Machine}:
  {==}
