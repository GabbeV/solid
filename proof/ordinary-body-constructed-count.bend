# A direct zero-debt corollary for the fully constructed controller/body family.
# No post-body validity/count or final Promise settlement is an input premise.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ./ordinary-body-constructed.bend as Body
import ./ordinary-body-evaluation.bend as Eval
import ./ordinary-write-history.bend as History
import ./ordinary-write-constructed.bend as Graph
import ./ordinary-write-outer.bend as Frame
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./action-retirement-count.bend as Count
import ./pending-stack-history.bend as Steps

def afterValid(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value) -> {Nat.is_lt(1n,B.length(R.Transaction,R.World.txArena(History.run(values,Body.ready(initial,values,answer),Graph.source(initial))))) == True{} : Bool}:
  +w = Body.ready(initial,values,answer)
  +next = History.run(values,w,Graph.source(initial))
  Equal.trans(Bool,Nat.is_lt(1n,B.length(R.Transaction,R.World.txArena(next))),Nat.is_lt(1n,B.length(R.Transaction,R.World.txArena(w))),True{},Equal.cong(List<&2,R.Transaction>,Bool,rows=>Nat.is_lt(1n,B.length(R.Transaction,rows)),R.World.txArena(next),R.World.txArena(w),Frame.sameTxArena(w,next,History.outer(values,w,Graph.source(initial),Body.profile(initial,values,answer)))),Body.groupValid(initial,values,answer))

def zero(+initial: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Count.count(C.world(Steps.iterate(1n+Eval.cost(values),Body.start(initial,values,answer,rest,stack,incoming,rejected))),1n) == 0n : Nat}:
  +actual = C.world(Steps.iterate(1n+Eval.cost(values),Body.start(initial,values,answer,rest,stack,incoming,rejected)))
  +written = History.run(values,Body.ready(initial,values,answer),Graph.source(initial))
  +target = Exit.target(written,1n,0n)
  Equal.trans(Nat,Count.count(actual,1n),Count.count(Output.outer(actual),1n),0n,Equal.sym(Nat,Count.count(Output.outer(actual),1n),Count.count(actual,1n),Count.output(actual,1n)),Equal.trans(Nat,Count.count(Output.outer(actual),1n),Count.count(Output.outer(target),1n),0n,Equal.cong(R.World,Nat,state=>Count.count(state,1n),Output.outer(actual),Output.outer(target),Body.complete(initial,values,answer,rest,stack,incoming,rejected)),Equal.trans(Nat,Count.count(Output.outer(target),1n),Count.count(target,1n),0n,Count.output(target,1n),Count.target(written,1n,0n,afterValid(initial,values,answer)))))
