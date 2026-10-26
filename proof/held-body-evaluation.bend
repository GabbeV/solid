# Evaluate the same finite real setter-body grammar on an already-held source.
# Every intermediate extension/group/path/health profile is constructed from
# actual source operations. Caller tasks, stack and syntax-derived cost remain.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/write.bend as W
import ./ordinary-body-evaluation.bend as Grammar
import ./held-write-profile.bend as P
import ./held-setter-frames.bend as Setter
import ./held-profile-control.bend as Control
import ./held-write-history.bend as History
import ./ordinary-updater-evaluation.bend as Write
import ./action-body-return.bend as Body
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver
import ./core-prefix-compose.bend as Prefix

def expression(values: List<&2,R.Value>,+id: Nat,answer: R.Value) -> R.Expr:
  Grammar.expression(values,id,answer)

def cost(values: List<&2,R.Value>) -> Nat:
  Grammar.cost(values)

def start(w: R.World,values: List<&2,R.Value>,id: Nat,answer: R.Value,rest: List<&2,C.Task>,stack: List<&2,R.Value>) -> C.Machine:
  Grammar.start(w,values,id,answer,rest,stack)

def finished(+w: R.World,+values: List<&2,R.Value>,+id: Nat,answer: R.Value,rest: List<&2,C.Task>,stack: List<&2,R.Value>) -> C.Machine:
  Grammar.finished(w,values,id,answer,rest,stack)

def entered(+w: R.World,+head: R.Value,+tail: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>) -> C.Machine:
  Grammar.entered(w,head,tail,id,answer,rest,stack)

def discard(+w: R.World,+head: R.Value,+tail: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>) -> C.Machine:
  Grammar.discard(w,head,tail,id,answer,rest,stack)

def entry(+w: R.World,+head: R.Value,+tail: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,profile: P.Profile<w,id,offset>) -> {C.step(start(w,head <> tail,id,answer,rest,stack)) == entered(w,head,tail,id,answer,rest,stack) : C.Machine}:
  Body.healthyStep(w,C.Evaluate{expression(head <> tail,id,answer),R.Undefined{}},rest,stack,Body.health(w,Control.healthy(w,id,offset,profile)))

def discards(+w: R.World,+head: R.Value,+tail: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,profile: P.Profile<W.setSignal(w,id,head),id,offset>) -> {C.step(discard(w,head,tail,id,answer,rest,stack)) == start(W.setSignal(w,id,head),tail,id,answer,rest,stack) : C.Machine}:
  Body.healthyStep(W.setSignal(w,id,head),C.Discard{},C.Evaluate{expression(tail,id,answer),R.Undefined{}} <> rest,head <> stack,Body.health(W.setSignal(w,id,head),Control.healthy(W.setSignal(w,id,head),id,offset,profile)))

def firstWrite(+w: R.World,+head: R.Value,+tail: List<&2,R.Value>,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+profile: P.Profile<w,id,offset>) -> {Steps.iterate(5n,start(w,head <> tail,id,answer,rest,stack)) == start(W.setSignal(w,id,head),tail,id,answer,rest,stack) : C.Machine}:
  +before = start(w,head <> tail,id,answer,rest,stack)
  +after = discard(w,head,tail,id,answer,rest,stack)
  +work = {C.Discard{} <> C.Evaluate{expression(tail,id,answer),R.Undefined{}} <> rest : List<&2,C.Task>}
  Driver.appendStep(4n,before,after,start(W.setSignal(w,id,head),tail,id,answer,rest,stack),Prefix.compose(1n,3n,before,entered(w,head,tail,id,answer,rest,stack),after,entry(w,head,tail,id,answer,rest,stack,offset,profile),Control.exact(w,id,head,R.Undefined{},work,stack,offset,profile)),discards(w,head,tail,id,answer,rest,stack,offset,Setter.next(w,id,head,offset,profile)))

def complete(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+profile: P.Profile<w,id,offset>) -> {Steps.iterate(cost(values),start(w,values,id,answer,rest,stack)) == finished(w,values,id,answer,rest,stack) : C.Machine}:
  match values:
    case Nil{}:
      Body.healthyStep(w,C.Evaluate{R.Literal{R.StepResult{True{},answer}},R.Undefined{}},rest,stack,Body.health(w,Control.healthy(w,id,offset,profile)))
    case +head <> +tail:
      Prefix.compose(5n,cost(tail),start(w,head <> tail,id,answer,rest,stack),start(W.setSignal(w,id,head),tail,id,answer,rest,stack),finished(w,head <> tail,id,answer,rest,stack),firstWrite(w,head,tail,id,answer,rest,stack,offset,profile),complete(tail,W.setSignal(w,id,head),id,answer,rest,stack,offset,Setter.next(w,id,head,offset,profile)))
