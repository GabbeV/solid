# Actual output handling retains the caller's work as an exact task suffix.
# It either leaves that suffix directly or prefixes non-immediate DeliverObservers.
# The latter has a finite checked drain before reaching the queued slice end.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./action-output-delivery-loop.bend as Loop
import ./pending-stack-history.bend as Steps

type Queue<-machine: C.Machine,-rest: List<&2,C.Task>,-stack: List<&2,R.Value>> is Data:
  DirectAt{exact: {machine == C.Machine{C.world(machine),rest,stack} : C.Machine}}
  DeliveryAt{observers: List<&2,Nat>,rejected: Bool,value: R.Value,exact: {machine == Loop.start(C.world(machine),observers,rest,stack,rejected,value) : C.Machine}}

def choice(+flag: Bool,+yes: C.Machine,+no: C.Machine,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,left: Queue<yes,rest,stack>,right: Queue<no,rest,stack>) -> Queue<B.choose(~C.Machine,flag,_=>yes,_=>no),rest,stack>:
  match flag:
    case True{}: left
    case False{}: right

def settled(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+result: Nat,+rejected: Bool,+value: R.Value) -> Queue<C.actionSettled(w,rest,stack,result,rejected,value),rest,stack>:
  DeliveryAt{R.AsyncObject.observers(B.asyncObject(w,result)),rejected,value,{==}}

def asyncValue(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+result: Nat,+rejected: Bool,+source: Nat) -> Queue<C.actionOutputValue(w,rest,stack,id,result,rejected,R.AsyncValue{source}),rest,stack>:
  +flag = Bool.and(Bool.not(rejected),Nat.is_eq(R.AsyncObject.stream(B.asyncObject(w,source)),0n))
  +adopted = {C.Machine{R.World.with_hostJobs(w,B.append(R.HostJob,R.World.hostJobs(w),[R.ActionAdopt{id,R.AsyncValue{source}}])),rest,stack} : C.Machine}
  choice(flag,adopted,C.actionSettled(w,rest,stack,result,rejected,R.AsyncValue{source}),rest,stack,DirectAt{{==}},settled(w,rest,stack,result,rejected,R.AsyncValue{source}))

def value(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+result: Nat,+rejected: Bool,+answer: R.Value) -> Queue<C.actionOutputValue(w,rest,stack,id,result,rejected,answer),rest,stack>:
  match answer:
    case R.Undefined{}: settled(w,rest,stack,result,rejected,R.Undefined{})
    case R.Null{}: settled(w,rest,stack,result,rejected,R.Null{})
    case R.Boolean{b}: settled(w,rest,stack,result,rejected,R.Boolean{b})
    case R.Number{n}: settled(w,rest,stack,result,rejected,R.Number{n})
    case R.NegativeZero{}: settled(w,rest,stack,result,rejected,R.NegativeZero{})
    case R.Reference{id}: settled(w,rest,stack,result,rejected,R.Reference{id})
    case R.ArrayReference{id}: settled(w,rest,stack,result,rejected,R.ArrayReference{id})
    case R.OwnerReference{id}: settled(w,rest,stack,result,rejected,R.OwnerReference{id})
    case R.RootDisposerReference{owner}: settled(w,rest,stack,result,rejected,R.RootDisposerReference{owner})
    case R.AccessorReference{signal}: settled(w,rest,stack,result,rejected,R.AccessorReference{signal})
    case R.SetterReference{signal}: settled(w,rest,stack,result,rejected,R.SetterReference{signal})
    case R.ProgramReference{callback}: settled(w,rest,stack,result,rejected,R.ProgramReference{callback})
    case R.ContextFailure{identity,kind}: settled(w,rest,stack,result,rejected,R.ContextFailure{identity,kind})
    case R.NotANumber{}: settled(w,rest,stack,result,rejected,R.NotANumber{})
    case R.StringValue{s}: settled(w,rest,stack,result,rejected,R.StringValue{s})
    case R.StatusFailure{identity,source,cause,message}: settled(w,rest,stack,result,rejected,R.StatusFailure{identity,source,cause,message})
    case R.NotReadyFailure{identity,source}: settled(w,rest,stack,result,rejected,R.NotReadyFailure{identity,source})
    case R.NotPendingToken{}: settled(w,rest,stack,result,rejected,R.NotPendingToken{})
    case R.AsyncValue{identity}: asyncValue(w,rest,stack,id,result,rejected,identity)
    case R.IteratorReference{iterator}: settled(w,rest,stack,result,rejected,R.IteratorReference{iterator})
    case R.StepResult{done,value}: settled(w,rest,stack,result,rejected,R.StepResult{done,value})
    case R.StreamVerdict{stream,landed,value}: settled(w,rest,stack,result,rejected,R.StreamVerdict{stream,landed,value})
    case R.TimeoutFailure{identity}: settled(w,rest,stack,result,rejected,R.TimeoutFailure{identity})
    case R.ExternalError{id,explicit,kind,name,message,native,code}: settled(w,rest,stack,result,rejected,R.ExternalError{id,explicit,kind,name,message,native,code})

def state(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+result: Nat,+rejected: Bool,+answer: R.Value,condition: R.AsyncSettlement) -> Queue<C.actionOutputState(w,rest,stack,id,result,rejected,answer,condition),rest,stack>:
  match condition:
    case R.Unresolved{}: value(w,rest,stack,id,result,rejected,answer)
    case R.Fulfilled{old}: DirectAt{{==}}
    case R.Rejected{old}: DirectAt{{==}}

def output(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+rejected: Bool,+answer: R.Value) -> Queue<C.actionOutput(w,rest,stack,id,rejected,answer),rest,stack>:
  +result = R.ActionState.result(A.get(w,id))
  state(w,rest,stack,id,result,rejected,answer,R.AsyncObject.state(B.asyncObject(w,result)))

def done(+w: R.World,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+id: Nat,+rejected: Bool,+answer: R.Value) -> Queue<C.actionDone(w,rest,stack,id,rejected,answer),rest,stack>:
  output(A.done(w,id),rest,stack,id,rejected,answer)

def cost(-machine: C.Machine,-rest: List<&2,C.Task>,-stack: List<&2,R.Value>,form: Queue<machine,rest,stack>) -> Nat:
  match form:
    case DirectAt{exact}: 0n
    case DeliveryAt{observers,rejected,value,exact}: Loop.cost(observers)

def world(+machine: C.Machine,-rest: List<&2,C.Task>,-stack: List<&2,R.Value>,form: Queue<machine,rest,stack>) -> R.World:
  match form:
    case DirectAt{exact}: C.world(machine)
    case DeliveryAt{observers,rejected,value,exact}: Loop.run(observers,C.world(machine),rejected,value)

def drain(+machine: C.Machine,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+form: Queue<machine,rest,stack>,healthy: {R.World.fault(C.world(machine)) == R.Healthy{} : R.Fault}) -> {Steps.iterate(cost(machine,rest,stack,form),machine) == C.Machine{world(machine,rest,stack,form),rest,stack} : C.Machine}:
  match form:
    case DirectAt{exact}: exact
    case DeliveryAt{+observers,+rejected,+value,exact}:
      Equal.trans(C.Machine,Steps.iterate(Loop.cost(observers),machine),Steps.iterate(Loop.cost(observers),Loop.start(C.world(machine),observers,rest,stack,rejected,value)),C.Machine{Loop.run(observers,C.world(machine),rejected,value),rest,stack},Equal.cong(C.Machine,C.Machine,m=>Steps.iterate(Loop.cost(observers),m),machine,Loop.start(C.world(machine),observers,rest,stack,rejected,value),exact),Loop.complete(observers,C.world(machine),rest,stack,rejected,value,healthy))

def frame(+machine: C.Machine,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,form: Queue<machine,rest,stack>) -> {Loop.outer(world(machine,rest,stack,form)) == Loop.outer(C.world(machine)) : R.World}:
  match form:
    case DirectAt{exact}: {==}
    case DeliveryAt{observers,rejected,value,exact}: Loop.runOuter(observers,C.world(machine),rejected,value)

def substitute(-a: C.Machine,-b: C.Machine,-rest: List<&2,C.Task>,-stack: List<&2,R.Value>,same: {a == b : C.Machine},form: Queue<a,rest,stack>) -> Queue<b,rest,stack>:
  %same : Queue<_,rest,stack>
  form
