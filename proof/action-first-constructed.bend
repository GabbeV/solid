# Actual first yielded-value delivery after real action/Promise/wait construction.
# The generator's continuation is its terminal method; user evaluation is queued,
# not executed. Payloads, cached prefix and caller machine data are arbitrary.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./action-wait-fixture.bend as Input
import ./action-wait-history.bend as History
import ./action-wait-range.bend as Range
import ./action-wait-allocation.bend as Allocation
import ./committed-storage-frame.bend as Content
import ./action-laws.bend as Guard


def initial(values: List<&2,R.Value>) -> R.World:
  Input.registered(values,[])

def first(+values: List<&2,R.Value>,rest: List<&2,C.Task>,stack: List<&2,R.Value>,rejected: Bool,value: R.Value) -> C.Machine:
  C.asyncActionDelivery(initial(values),rest,stack,1n,rejected,value,A.find(R.World.actionWaits(initial(values)),1n))

def lookup(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value) -> {A.find(R.World.actionWaits(C.world(first(values,rest,stack,rejected,value))),1n) == Some{R.ActionWait{1n,Input.action(values),0,True{}}} : Maybe<&2,R.ActionWait>}:
  match rejected:
    case False{}: {==}
    case True{}: {==}

def range(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value) -> {Range.below(R.World.actionWaits(C.world(first(values,rest,stack,rejected,value))),Allocation.index(C.world(first(values,rest,stack,rejected,value)))) == True{} : Bool}:
  match rejected:
    case False{}: {==}
    case True{}: {==}

def content(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value) -> {Content.observe(C.world(first(values,rest,stack,rejected,value))) == Content.observe(initial(values)) : Content.View}:
  match rejected:
    case False{}: {==}
    case True{}: {==}


def tasks(machine: C.Machine) -> List<&2,C.Task>:
  match machine:
    case C.Machine{world,tasks,values}: tasks

def after(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,events: List<&2,History.WaitEvent>) -> C.Machine:
  +arrived = first(values,rest,stack,rejected,value)
  C.Machine{History.run(events,C.world(arrived)),tasks(arrived),C.values(arrived)}

def afterLookup(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,+events: List<&2,History.WaitEvent>) -> {A.find(R.World.actionWaits(C.world(after(values,rest,stack,rejected,value,events))),1n) == Some{R.ActionWait{1n,Input.action(values),0,True{}}} : Maybe<&2,R.ActionWait>}:
  History.historyFound(events,C.world(first(values,rest,stack,rejected,value)),1n,1n,Input.action(values),0,lookup(values,rest,stack,rejected,value))

def duplicate(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,+events: List<&2,History.WaitEvent>,+lateRejected: Bool,+lateValue: R.Value) -> {C.asyncActionDelivery(C.world(after(values,rest,stack,rejected,value,events)),tasks(after(values,rest,stack,rejected,value,events)),C.values(after(values,rest,stack,rejected,value,events)),1n,lateRejected,lateValue,A.find(R.World.actionWaits(C.world(after(values,rest,stack,rejected,value,events))),1n)) == after(values,rest,stack,rejected,value,events) : C.Machine}:
  +machine = after(values,rest,stack,rejected,value,events)
  +w = C.world(machine)
  +work = tasks(machine)
  +valuesStack = C.values(machine)
  Equal.trans(C.Machine,C.asyncActionDelivery(w,work,valuesStack,1n,lateRejected,lateValue,A.find(R.World.actionWaits(w),1n)),C.asyncActionDelivery(w,work,valuesStack,1n,lateRejected,lateValue,Some{R.ActionWait{1n,Input.action(values),0,True{}}}),machine,Equal.cong(Maybe<&2,R.ActionWait>,C.Machine,found=>C.asyncActionDelivery(w,work,valuesStack,1n,lateRejected,lateValue,found),A.find(R.World.actionWaits(w),1n),Some{R.ActionWait{1n,Input.action(values),0,True{}}},afterLookup(values,rest,stack,rejected,value,events)),Guard.duplicate_yield(w,work,valuesStack,1n,Input.action(values),lateRejected,lateValue))
