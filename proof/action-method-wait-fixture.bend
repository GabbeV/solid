# Actual action/Promise creation with an arbitrary admitted generator method.
# Prefix/suffix events call real wait/observer-allocation/mark operations.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/action-state.bend as A
import ../runtime/flight.bend as F
import ../runtime/core.bend as Core
import ./memo-render-fixture.bend as Values
import ./action-first-frame.bend as Frame
import ./action-wait-allocation.bend as Allocation
import ./action-wait-range.bend as Range
import ./action-wait-history.bend as History
import ./action-wait-construction.bend as Register


def created(values: List<&2,R.Value>,+method: Frame.Method) -> B.Bundle<R.World,Nat>:
  A.create(Values.input(values),Frame.expression(method))

def action(values: List<&2,R.Value>,+method: Frame.Method) -> Nat:
  B.second(R.World,Nat,created(values,method))

def opened(+values: List<&2,R.Value>,+method: Frame.Method) -> R.World:
  +pair = created(values,method)
  A.open(B.first(R.World,Nat,pair),B.second(R.World,Nat,pair))

def inputResult(values: List<&2,R.Value>,+method: Frame.Method) -> B.Bundle<R.World,Nat>:
  F.newThenable(opened(values,method),False{},R.Unresolved{})

def result(values: List<&2,R.Value>,+method: Frame.Method) -> Nat:
  B.second(R.World,Nat,inputResult(values,method))

def initial(values: List<&2,R.Value>,+method: Frame.Method) -> R.World:
  B.first(R.World,Nat,inputResult(values,method))

def allocated(+values: List<&2,R.Value>,+method: Frame.Method) -> {Nat.is_lt(action(values,method),B.length(R.ActionState,R.World.actions(initial(values,method)))) == True{} : Bool}:
  {==}


def initialRange(+values: List<&2,R.Value>,+method: Frame.Method) -> {Range.below(R.World.actionWaits(initial(values,method)),Allocation.index(initial(values,method))) == True{} : Bool}:
  {==}

def before(values: List<&2,R.Value>,+method: Frame.Method,prefix: List<&2,History.WaitEvent>) -> R.World:
  History.run(prefix,initial(values,method))

def beforeRange(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>) -> {Range.below(R.World.actionWaits(before(values,method,prefix)),Allocation.index(before(values,method,prefix))) == True{} : Bool}:
  History.historyRange(prefix,initial(values,method),initialRange(values,method))

def registered(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>) -> R.World:
  Allocation.after(before(values,method,prefix),action(values,method),result(values,method),0)

def fresh(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>) -> Nat:
  Allocation.index(before(values,method,prefix))

def lookup(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>) -> {A.find(R.World.actionWaits(registered(values,method,prefix)),fresh(values,method,prefix)) == Some{R.ActionWait{fresh(values,method,prefix),action(values,method),0,False{}}} : Maybe<&2,R.ActionWait>}:
  Register.found(before(values,method,prefix),action(values,method),result(values,method),0,beforeRange(values,method,prefix))

def final(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>,suffix: List<&2,History.WaitEvent>) -> R.World:
  History.afterRegistered(before(values,method,prefix),action(values,method),result(values,method),suffix)

def settled(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>,+suffix: List<&2,History.WaitEvent>) -> {A.find(R.World.actionWaits(final(values,method,prefix,suffix)),fresh(values,method,prefix)) == Some{R.ActionWait{fresh(values,method,prefix),action(values,method),0,True{}}} : Maybe<&2,R.ActionWait>}:
  History.constructedSettledLookup(before(values,method,prefix),action(values,method),result(values,method),suffix,beforeRange(values,method,prefix))

def duplicate(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>,+suffix: List<&2,History.WaitEvent>,+rest: List<&2,Core.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value) -> {Core.asyncActionDelivery(final(values,method,prefix,suffix),rest,stack,fresh(values,method,prefix),rejected,value,A.find(R.World.actionWaits(final(values,method,prefix,suffix)),fresh(values,method,prefix))) == Core.Machine{final(values,method,prefix,suffix),rest,stack} : Core.Machine}:
  History.constructedDuplicate(before(values,method,prefix),action(values,method),result(values,method),suffix,rest,stack,rejected,value,beforeRange(values,method,prefix))


def initialPositive(+values: List<&2,R.Value>,+method: Frame.Method) -> {Nat.is_ne(Allocation.index(initial(values,method)),0n) == True{} : Bool}:
  {==}

def freshPositive(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>) -> {Nat.is_ne(fresh(values,method,prefix),0n) == True{} : Bool}:
  History.historyPositive(prefix,initial(values,method),initialPositive(values,method))

def finalRange(+values: List<&2,R.Value>,+method: Frame.Method,+prefix: List<&2,History.WaitEvent>,+suffix: List<&2,History.WaitEvent>) -> {Range.below(R.World.actionWaits(final(values,method,prefix,suffix)),Allocation.index(final(values,method,prefix,suffix))) == True{} : Bool}:
  History.afterRange(before(values,method,prefix),action(values,method),result(values,method),suffix,beforeRange(values,method,prefix))
