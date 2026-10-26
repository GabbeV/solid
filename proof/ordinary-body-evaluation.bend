# Evaluate any finite sequence of real constant-result setters followed by a
# generator protocol return. Every intermediate healthy state is constructed by
# the preserved profile. Work cost follows syntax; caller tasks/stack are retained.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/write.bend as W
import ./ordinary-write-profile.bend as P
import ./ordinary-profile-control.bend as Control
import ./ordinary-write-history.bend as History
import ./ordinary-updater-evaluation.bend as Write
import ./action-body-return.bend as Body
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver
import ./core-prefix-compose.bend as Prefix

def expression(values: List<&2,R.Value>,+id: Nat,answer: R.Value) -> R.Expr:
  match values:
    case Nil{}: R.Literal{R.StepResult{True{},answer}}
    case value <> tail:
      R.Then{R.WriteExpr{id,R.Literal{value},True{}},expression(tail,id,answer)}

def cost(values: List<&2,R.Value>) -> Nat:
  match values:
    case Nil{}: 1n
    case head <> tail: 5n+cost(tail)

def start(w: R.World,values: List<&2,R.Value>,id: Nat,answer: R.Value,rest: List<&2,C.Task>,stack: List<&2,R.Value>) -> C.Machine:
  C.Machine{w,C.Evaluate{expression(values,id,answer),R.Undefined{}} <> rest,stack}

def finished(+w: R.World,+values: List<&2,R.Value>,+id: Nat,answer: R.Value,rest: List<&2,C.Task>,stack: List<&2,R.Value>) -> C.Machine:
  C.Machine{History.run(values,w,id),rest,R.StepResult{True{},answer} <> stack}

def entered(+w: R.World,+head: R.Value,+tail: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>) -> C.Machine:
  Write.start(w,C.Discard{} <> C.Evaluate{expression(tail,id,answer),R.Undefined{}} <> rest,stack,id,head,R.Undefined{})

def discard(+w: R.World,+head: R.Value,+tail: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>) -> C.Machine:
  Write.updated(w,C.Discard{} <> C.Evaluate{expression(tail,id,answer),R.Undefined{}} <> rest,stack,id,head)

def entry(+w: R.World,+head: R.Value,+tail: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,profile: P.Profile<w,id>) -> {C.step(start(w,head <> tail,id,answer,rest,stack)) == entered(w,head,tail,id,answer,rest,stack) : C.Machine}:
  Body.healthyStep(w,C.Evaluate{expression(head <> tail,id,answer),R.Undefined{}},rest,stack,Body.health(w,Control.healthy(w,id,profile)))

def discards(+w: R.World,+head: R.Value,+tail: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,profile: P.Profile<W.setSignal(w,id,head),id>) -> {C.step(discard(w,head,tail,id,answer,rest,stack)) == start(W.setSignal(w,id,head),tail,id,answer,rest,stack) : C.Machine}:
  Body.healthyStep(W.setSignal(w,id,head),C.Discard{},C.Evaluate{expression(tail,id,answer),R.Undefined{}} <> rest,head <> stack,Body.health(W.setSignal(w,id,head),Control.healthy(W.setSignal(w,id,head),id,profile)))

def firstWrite(+w: R.World,+head: R.Value,+tail: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+profile: P.Profile<w,id>) -> {Steps.iterate(5n,start(w,head <> tail,id,answer,rest,stack)) == start(W.setSignal(w,id,head),tail,id,answer,rest,stack) : C.Machine}:
  +before = start(w,head <> tail,id,answer,rest,stack)
  +after = discard(w,head,tail,id,answer,rest,stack)
  +work = {C.Discard{} <> C.Evaluate{expression(tail,id,answer),R.Undefined{}} <> rest : List<&2,C.Task>}
  Driver.appendStep(4n,before,after,start(W.setSignal(w,id,head),tail,id,answer,rest,stack),Prefix.compose(1n,3n,before,entered(w,head,tail,id,answer,rest,stack),after,entry(w,head,tail,id,answer,rest,stack,profile),Control.exact(w,id,head,R.Undefined{},work,stack,profile)),discards(w,head,tail,id,answer,rest,stack,P.next(w,id,head,profile)))

def complete(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+profile: P.Profile<w,id>) -> {Steps.iterate(cost(values),start(w,values,id,answer,rest,stack)) == finished(w,values,id,answer,rest,stack) : C.Machine}:
  match values:
    case Nil{}:
      Body.healthyStep(w,C.Evaluate{R.Literal{R.StepResult{True{},answer}},R.Undefined{}},rest,stack,Body.health(w,Control.healthy(w,id,profile)))
    case +head <> +tail:
      Prefix.compose(5n,cost(tail),start(w,head <> tail,id,answer,rest,stack),start(W.setSignal(w,id,head),tail,id,answer,rest,stack),finished(w,head <> tail,id,answer,rest,stack),firstWrite(w,head,tail,id,answer,rest,stack,profile),complete(tail,W.setSignal(w,id,head),id,answer,rest,stack,P.next(w,id,head,profile)))
