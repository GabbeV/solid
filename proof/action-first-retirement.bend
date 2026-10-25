# One actual ActionStepReturn closes the single constructed obligation and
# settles its output; the queued observer delivery and public flush stay queued.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./action-first-constructed.bend as First
import ./action-wait-fixture.bend as Input
import ./action-output-rejection.bend as Output
import ./action-wait-history.bend as History
import ./action-laws.bend as Guard

def retired(values: List<&2,R.Value>,rest: List<&2,C.Task>,stack: List<&2,R.Value>,rejected: Bool,value: R.Value) -> C.Machine:
  C.step(First.first(values,rest,stack,rejected,value))

def outcome(+rejected: Bool,value: R.Value) -> R.AsyncSettlement:
  B.choose(~R.AsyncSettlement,rejected,_=>R.Rejected{value},_=>R.Fulfilled{R.Undefined{}})

type Retired<-values: List<&2,R.Value>,-rest: List<&2,C.Task>,-stack: List<&2,R.Value>,-rejected: Bool,-value: R.Value> is Data:
  RetiredAt{
    open: {R.Transaction.open(B.transaction(C.world(retired(values,rest,stack,rejected,value)),1n)) == 0n : Nat},
    result: {R.AsyncObject.state(B.asyncObject(C.world(retired(values,rest,stack,rejected,value)),1n)) == outcome(rejected,value) : R.AsyncSettlement},
    lookup: {A.find(R.World.actionWaits(C.world(retired(values,rest,stack,rejected,value))),1n) == Some{R.ActionWait{1n,Input.action(values),0,True{}}} : Maybe<&2,R.ActionWait>}
  }

def rejectedDone(+values: List<&2,R.Value>,rest: List<&2,C.Task>,stack: List<&2,R.Value>,value: R.Value) -> R.World:
  A.done(R.World.with_fault(A.exit(C.world(First.first(values,rest,stack,True{},value))),R.Healthy{}),Input.action(values))

def rejectedExpected(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+value: R.Value) -> C.Machine:
  C.actionSettled(rejectedDone(values,rest,stack,value),C.ActionSliceEnd{R.QuestionZero{}} <> rest,stack,1n,True{},value)

def rejectedExact(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+value: R.Value) -> {retired(values,rest,stack,True{},value) == rejectedExpected(values,rest,stack,value) : C.Machine}:
  Output.raw(rejectedDone(values,rest,stack,value),C.ActionSliceEnd{R.QuestionZero{}} <> rest,stack,Input.action(values),1n,value)

def expectedOpen(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+value: R.Value) -> {R.Transaction.open(B.transaction(C.world(rejectedExpected(values,rest,stack,value)),1n)) == 0n : Nat}:
  {==}

def expectedResult(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+value: R.Value) -> {R.AsyncObject.state(B.asyncObject(C.world(rejectedExpected(values,rest,stack,value)),1n)) == R.Rejected{value} : R.AsyncSettlement}:
  {==}

def expectedLookup(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+value: R.Value) -> {A.find(R.World.actionWaits(C.world(rejectedExpected(values,rest,stack,value))),1n) == Some{R.ActionWait{1n,Input.action(values),0,True{}}} : Maybe<&2,R.ActionWait>}:
  {==}

def completed(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value) -> Retired<values,rest,stack,rejected,value>:
  match rejected:
    case False{}: RetiredAt{{==},{==},{==}}
    case True{}:
      +before = retired(values,rest,stack,True{},value)
      +after = rejectedExpected(values,rest,stack,value)
      +same = rejectedExact(values,rest,stack,value)
      RetiredAt{
        Equal.trans(Nat,R.Transaction.open(B.transaction(C.world(before),1n)),R.Transaction.open(B.transaction(C.world(after),1n)),0n,Equal.cong(C.Machine,Nat,m=>R.Transaction.open(B.transaction(C.world(m),1n)),before,after,same),expectedOpen(values,rest,stack,value)),
        Equal.trans(R.AsyncSettlement,R.AsyncObject.state(B.asyncObject(C.world(before),1n)),R.AsyncObject.state(B.asyncObject(C.world(after),1n)),R.Rejected{value},Equal.cong(C.Machine,R.AsyncSettlement,m=>R.AsyncObject.state(B.asyncObject(C.world(m),1n)),before,after,same),expectedResult(values,rest,stack,value)),
        Equal.trans(Maybe<&2,R.ActionWait>,A.find(R.World.actionWaits(C.world(before)),1n),A.find(R.World.actionWaits(C.world(after)),1n),Some{R.ActionWait{1n,Input.action(values),0,True{}}},Equal.cong(C.Machine,Maybe<&2,R.ActionWait>,m=>A.find(R.World.actionWaits(C.world(m)),1n),before,after,same),expectedLookup(values,rest,stack,value))
      }


def settled(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,proof: Retired<values,rest,stack,rejected,value>) -> {A.find(R.World.actionWaits(C.world(retired(values,rest,stack,rejected,value))),1n) == Some{R.ActionWait{1n,Input.action(values),0,True{}}} : Maybe<&2,R.ActionWait>}:
  match proof:
    case RetiredAt{open,result,lookup}: lookup

def after(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,events: List<&2,History.WaitEvent>) -> C.Machine:
  +done = retired(values,rest,stack,rejected,value)
  C.Machine{History.run(events,C.world(done)),First.tasks(done),C.values(done)}

def afterLookup(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,+events: List<&2,History.WaitEvent>) -> {A.find(R.World.actionWaits(C.world(after(values,rest,stack,rejected,value,events))),1n) == Some{R.ActionWait{1n,Input.action(values),0,True{}}} : Maybe<&2,R.ActionWait>}:
  History.historyFound(events,C.world(retired(values,rest,stack,rejected,value)),1n,1n,Input.action(values),0,settled(values,rest,stack,rejected,value,completed(values,rest,stack,rejected,value)))

def duplicate(+values: List<&2,R.Value>,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+rejected: Bool,+value: R.Value,+events: List<&2,History.WaitEvent>,+lateRejected: Bool,+lateValue: R.Value) -> {C.asyncActionDelivery(C.world(after(values,rest,stack,rejected,value,events)),First.tasks(after(values,rest,stack,rejected,value,events)),C.values(after(values,rest,stack,rejected,value,events)),1n,lateRejected,lateValue,A.find(R.World.actionWaits(C.world(after(values,rest,stack,rejected,value,events))),1n)) == after(values,rest,stack,rejected,value,events) : C.Machine}:
  +machine = after(values,rest,stack,rejected,value,events)
  +w = C.world(machine)
  +work = First.tasks(machine)
  +saved = C.values(machine)
  Equal.trans(C.Machine,C.asyncActionDelivery(w,work,saved,1n,lateRejected,lateValue,A.find(R.World.actionWaits(w),1n)),C.asyncActionDelivery(w,work,saved,1n,lateRejected,lateValue,Some{R.ActionWait{1n,Input.action(values),0,True{}}}),machine,Equal.cong(Maybe<&2,R.ActionWait>,C.Machine,found=>C.asyncActionDelivery(w,work,saved,1n,lateRejected,lateValue,found),A.find(R.World.actionWaits(w),1n),Some{R.ActionWait{1n,Input.action(values),0,True{}}},afterLookup(values,rest,stack,rejected,value,events)),Guard.duplicate_yield(w,work,saved,1n,Input.action(values),lateRejected,lateValue))
