# Checked handoff from one completed finite body to another controller's resume.
# This is an internal prefix contract: queued output/slice/Round work between
# host events is not executed or discarded by this theorem.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./pending-stack-history.bend as Steps
import ./held-resume-retirement.bend as Resume
import ./held-body-evaluation.bend as Eval
import ./held-write-history.bend as History
import ./held-cache-body-input.bend as Input
import ./held-source-input-successor.bend as Source
import ./held-body-controller-frame.bend as Frame
import ./held-controller-ready.bend as Controller
import ./held-source-cache-debt.bend as Body
import ./held-count-certificate.bend as Debt
import ./held-source-cache-resume.bend as Stack
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output

type Ready<-before: C.Machine,-steps: Nat,-id: Nat,-offset: Nat,-other: Nat,-captureOffset: Nat,-methods: R.Expr> is Data:
  Next{count: Debt.Outcome<before,steps,id,offset,1n>,source: Input.Input<C.world(Steps.iterate(steps,before)),id,offset>,controller: Controller.Ready<C.world(Steps.iterate(steps,before)),other,1n+offset,captureOffset,methods>}

def fromBody(+before: C.Machine,+steps: Nat,+body: R.World,+values: List<&2,R.Value>,+id: Nat,+offset: Nat,+other: Nat,+captureOffset: Nat,+methods: R.Expr,+input: Input.Input<body,id,offset>,controller: Controller.Ready<body,other,1n+offset,captureOffset,methods>,+same: {Output.outer(C.world(Steps.iterate(steps,before))) == Output.outer(Exit.target(History.run(values,body,id),1n+offset,1n)) : R.World}) -> Ready<before,steps,id,offset,other,captureOffset,methods>:
  +next = C.world(Steps.iterate(steps,before))
  Next{Body.fromBody(before,steps,body,values,id,offset,1n,input,same),Source.retired(History.run(values,body,id),next,id,offset,1n,Source.written(values,body,id,offset,input),same),Controller.body(body,next,other,1n+offset,captureOffset,methods,controller,Frame.frame(values,body,next,id,offset,1n,input,same))}

def complete(+before: C.Machine,+steps: Nat,+id: Nat,+offset: Nat,+other: Nat,+captureOffset: Nat,+values: List<&2,R.Value>,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,ready: Ready<before,steps,id,offset,other,captureOffset,Resume.methods(values,id,answer)>) -> Debt.Outcome<Resume.start(C.world(Steps.iterate(steps,before)),other,rest,stack,incoming,rejected),1n+Eval.cost(values),id,offset,0n>:
  match ready:
    case Next{count,source,controller}:
      match source:
        case Input.Prepared{sourceAlias,cached,profile}:
          match controller:
            case Controller.Captured{alias,capture,positive,known}:
              Body.current(C.world(Steps.iterate(steps,before)),other,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,0n,profile,sourceAlias,cached,alias,capture,positive,Debt.count(before,steps,id,offset,1n,count),known)

def savedStack(+before: C.Machine,+steps: Nat,+id: Nat,+offset: Nat,+other: Nat,+captureOffset: Nat,+values: List<&2,R.Value>,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,ready: Ready<before,steps,id,offset,other,captureOffset,Resume.methods(values,id,answer)>) -> {C.values(Steps.iterate(1n+Eval.cost(values),Resume.start(C.world(Steps.iterate(steps,before)),other,rest,stack,incoming,rejected))) == stack : List<&2,R.Value>}:
  match ready:
    case Next{count,source,controller}:
      match source:
        case Input.Prepared{sourceAlias,cached,profile}:
          match controller:
            case Controller.Captured{alias,capture,positive,known}:
              Stack.currentStack(C.world(Steps.iterate(steps,before)),other,values,id,answer,rest,stack,incoming,rejected,offset,captureOffset,0n,profile,sourceAlias,cached,alias,capture,positive,Debt.count(before,steps,id,offset,1n,count),known)
