# Typed action wait control from actual action/Promise creation and opening.
# Prefix/suffix events call real wait/observer-allocation/mark operations.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/flight.bend as F
import ../runtime/core.bend as Core
import ./memo-render-fixture.bend as Values
import ./action-wait-allocation.bend as Allocation
import ./action-wait-range.bend as Range
import ./action-wait-history.bend as History
import ./action-wait-construction.bend as Register


def created(values: List<&2,R.Value>) -> B.Bundle<R.World,Nat>:
  A.create(Values.input(values),R.ActionEnd{})

def action(values: List<&2,R.Value>) -> Nat:
  B.second(R.World,Nat,created(values))

def opened(+values: List<&2,R.Value>) -> R.World:
  +pair = created(values)
  A.open(B.first(R.World,Nat,pair),B.second(R.World,Nat,pair))

def inputResult(values: List<&2,R.Value>) -> B.Bundle<R.World,Nat>:
  F.newThenable(opened(values),False{},R.Unresolved{})

def result(values: List<&2,R.Value>) -> Nat:
  B.second(R.World,Nat,inputResult(values))

def initial(values: List<&2,R.Value>) -> R.World:
  B.first(R.World,Nat,inputResult(values))

def allocated(+values: List<&2,R.Value>) -> {Nat.is_lt(action(values),B.length(R.ActionState,R.World.actions(initial(values)))) == True{} : Bool}:
  {==}


def initialRange(+values: List<&2,R.Value>) -> {Range.below(R.World.actionWaits(initial(values)),Allocation.index(initial(values))) == True{} : Bool}:
  {==}

def before(values: List<&2,R.Value>,prefix: List<&2,History.WaitEvent>) -> R.World:
  History.run(prefix,initial(values))

def beforeRange(+values: List<&2,R.Value>,+prefix: List<&2,History.WaitEvent>) -> {Range.below(R.World.actionWaits(before(values,prefix)),Allocation.index(before(values,prefix))) == True{} : Bool}:
  History.historyRange(prefix,initial(values),initialRange(values))

def registered(+values: List<&2,R.Value>,+prefix: List<&2,History.WaitEvent>) -> R.World:
  Allocation.after(before(values,prefix),action(values),result(values),0)

def fresh(+values: List<&2,R.Value>,+prefix: List<&2,History.WaitEvent>) -> Nat:
  Allocation.index(before(values,prefix))

def lookup(+values: List<&2,R.Value>,+prefix: List<&2,History.WaitEvent>) -> {A.find(R.World.actionWaits(registered(values,prefix)),fresh(values,prefix)) == Some{R.ActionWait{fresh(values,prefix),action(values),0,False{}}} : Maybe<&2,R.ActionWait>}:
  Register.found(before(values,prefix),action(values),result(values),0,beforeRange(values,prefix))

def final(+values: List<&2,R.Value>,+prefix: List<&2,History.WaitEvent>,suffix: List<&2,History.WaitEvent>) -> R.World:
  History.afterRegistered(before(values,prefix),action(values),result(values),suffix)

def settled(+values: List<&2,R.Value>,+prefix: List<&2,History.WaitEvent>,+suffix: List<&2,History.WaitEvent>) -> {A.find(R.World.actionWaits(final(values,prefix,suffix)),fresh(values,prefix)) == Some{R.ActionWait{fresh(values,prefix),action(values),0,True{}}} : Maybe<&2,R.ActionWait>}:
  History.constructedSettledLookup(before(values,prefix),action(values),result(values),suffix,beforeRange(values,prefix))

def duplicate(+values: List<&2,R.Value>,+prefix: List<&2,History.WaitEvent>,+suffix: List<&2,History.WaitEvent>,+rest: List<&2,Core.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value) -> {Core.asyncActionDelivery(final(values,prefix,suffix),rest,stack,fresh(values,prefix),rejected,value,A.find(R.World.actionWaits(final(values,prefix,suffix)),fresh(values,prefix))) == Core.Machine{final(values,prefix,suffix),rest,stack} : Core.Machine}:
  History.constructedDuplicate(before(values,prefix),action(values),result(values),suffix,rest,stack,rejected,value,beforeRange(values,prefix))


def initialPositive(+values: List<&2,R.Value>) -> {Nat.is_ne(Allocation.index(initial(values)),0n) == True{} : Bool}:
  {==}

def freshPositive(+values: List<&2,R.Value>,+prefix: List<&2,History.WaitEvent>) -> {Nat.is_ne(fresh(values,prefix),0n) == True{} : Bool}:
  History.historyPositive(prefix,initial(values),initialPositive(values))

def finalRange(+values: List<&2,R.Value>,+prefix: List<&2,History.WaitEvent>,+suffix: List<&2,History.WaitEvent>) -> {Range.below(R.World.actionWaits(final(values,prefix,suffix)),Allocation.index(final(values,prefix,suffix))) == True{} : Bool}:
  History.afterRange(before(values,prefix),action(values),result(values),suffix,beforeRange(values,prefix))
