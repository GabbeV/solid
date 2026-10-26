# A finite already-held updater body reaches the actual ActionStepReturn/done
# operation. Output Promise adoption and queued flush remain separate boundaries.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./held-body-evaluation.bend as Eval
import ./held-write-history.bend as History
import ./held-write-profile.bend as P
import ./held-profile-control.bend as Control
import ./action-body-return.bend as Body
import ./action-output-frame.bend as Output
import ./pending-stack-history.bend as Steps
import ./core-run-prefix.bend as Driver

def start(+w: R.World,values: List<&2,R.Value>,id: Nat,answer: R.Value,actor: Nat,rest: List<&2,C.Task>,+stack: List<&2,R.Value>) -> C.Machine:
  Eval.start(w,values,id,answer,C.ActionStepReturn{actor,stack} <> rest,stack)

def done(+w: R.World,+values: List<&2,R.Value>,+id: Nat,answer: R.Value,actor: Nat,rest: List<&2,C.Task>,stack: List<&2,R.Value>) -> C.Machine:
  C.actionDone(A.exit(History.run(values,w,id)),rest,stack,actor,False{},answer)

def complete(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+answer: R.Value,+actor: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,+profile: P.Profile<w,id,offset>) -> {Steps.iterate(1n+Eval.cost(values),start(w,values,id,answer,actor,rest,stack)) == done(w,values,id,answer,actor,rest,stack) : C.Machine}:
  +next = History.run(values,w,id)
  Driver.appendStep(Eval.cost(values),start(w,values,id,answer,actor,rest,stack),Body.returned(next,rest,stack,actor,answer),done(w,values,id,answer,actor,rest,stack),Eval.complete(values,w,id,answer,C.ActionStepReturn{actor,stack} <> rest,stack,offset,profile),Body.finishes(next,rest,stack,actor,answer,Control.healthy(next,id,offset,History.invariant(values,w,id,offset,profile))))

def outer(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+answer: R.Value,+actor: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,profile: P.Profile<w,id,offset>) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),start(w,values,id,answer,actor,rest,stack)))) == Output.outer(A.done(A.exit(History.run(values,w,id)),actor)) : R.World}:
  +next = A.done(A.exit(History.run(values,w,id)),actor)
  Equal.trans(R.World,Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),start(w,values,id,answer,actor,rest,stack)))),Output.outer(C.world(done(w,values,id,answer,actor,rest,stack))),Output.outer(next),Equal.cong(C.Machine,R.World,m=>Output.outer(C.world(m)),Steps.iterate(1n+Eval.cost(values),start(w,values,id,answer,actor,rest,stack)),done(w,values,id,answer,actor,rest,stack),complete(values,w,id,answer,actor,rest,stack,offset,profile)),Output.output(next,rest,stack,actor,False{},answer))

def savedStack(+values: List<&2,R.Value>,+w: R.World,+id: Nat,+answer: R.Value,+actor: Nat,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+offset: Nat,profile: P.Profile<w,id,offset>) -> {C.values(Steps.iterate(1n+Eval.cost(values),start(w,values,id,answer,actor,rest,stack))) == stack : List<&2,R.Value>}:
  +next = A.done(A.exit(History.run(values,w,id)),actor)
  Equal.trans(List<&2,R.Value>,C.values(Steps.iterate(1n+Eval.cost(values),start(w,values,id,answer,actor,rest,stack))),C.values(done(w,values,id,answer,actor,rest,stack)),stack,Equal.cong(C.Machine,List<&2,R.Value>,m=>C.values(m),Steps.iterate(1n+Eval.cost(values),start(w,values,id,answer,actor,rest,stack)),done(w,values,id,answer,actor,rest,stack),complete(values,w,id,answer,actor,rest,stack,offset,profile)),Output.outputStack(next,rest,stack,actor,False{},answer))
