# Closed constructor-to-resume/body boundary for two joined controllers. The
# first source graph/controller/hold and second create/open/join are all actual
# runtime operations. No intermediate World/profile/capture/count is supplied.
# Public factory/parking, host settlement and queued Round remain separate.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./ordinary-graph-data.bend as Graph
import ./held-opened-state.bend as First
import ./held-first-ready-construction.bend as Ready
import ./held-pair-generic-body.bend as Generic
import ./held-pair-generic-next.bend as PairNext
import ./held-next-controller-body.bend as Next
import ./held-count-certificate.bend as Debt
import ./transaction-pair.bend as Pair
import ./held-pair-generic-context.bend as Context
import ./held-resume-retirement.bend as Resume
import ./held-body-evaluation.bend as Eval
import ./held-write-history.bend as History
import ./action-body-entry.bend as Entry
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./pending-stack-history.bend as Steps

import ./held-pair-constructed-next.bend as Constructed
import ./action-retirement-count.bend as Count

import ./held-pair-second-body.bend as Second

def count(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+nextValues: List<&2,R.Value>,+nextAnswer: R.Value,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+nextRest: List<&2,C.Task>,+nextStack: List<&2,R.Value>,+nextIncoming: R.Value,+nextRejected: Bool) -> {Count.count(C.world(Steps.iterate(1n+Eval.cost(nextValues),Resume.start(C.world(Steps.iterate(1n+Eval.cost(values),Resume.start(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),Resume.methods(nextValues,Graph.source(value),nextAnswer),second)),Graph.source(value),values,answer,Resume.methods(nextValues,Graph.source(value),nextAnswer),reverse,second),Context.actor(second),rest,stack,incoming,rejected))),Context.actor(Bool.not(second)),nextRest,nextStack,nextIncoming,nextRejected))),1n+Pair.targetPred([],[],reverse)) == 0n : Nat}:
  Debt.count(Resume.start(C.world(Steps.iterate(1n+Eval.cost(values),Resume.start(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),Resume.methods(nextValues,Graph.source(value),nextAnswer),second)),Graph.source(value),values,answer,Resume.methods(nextValues,Graph.source(value),nextAnswer),reverse,second),Context.actor(second),rest,stack,incoming,rejected))),Context.actor(Bool.not(second)),nextRest,nextStack,nextIncoming,nextRejected),1n+Eval.cost(nextValues),Graph.source(value),Pair.targetPred([],[],reverse),0n,Second.complete(value,values,answer,nextValues,nextAnswer,reverse,second,rest,stack,incoming,rejected,nextRest,nextStack,nextIncoming,nextRejected))

def savedStack(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+nextValues: List<&2,R.Value>,+nextAnswer: R.Value,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+nextRest: List<&2,C.Task>,+nextStack: List<&2,R.Value>,+nextIncoming: R.Value,+nextRejected: Bool) -> {C.values(Steps.iterate(1n+Eval.cost(nextValues),Resume.start(C.world(Steps.iterate(1n+Eval.cost(values),Resume.start(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),Resume.methods(nextValues,Graph.source(value),nextAnswer),second)),Graph.source(value),values,answer,Resume.methods(nextValues,Graph.source(value),nextAnswer),reverse,second),Context.actor(second),rest,stack,incoming,rejected))),Context.actor(Bool.not(second)),nextRest,nextStack,nextIncoming,nextRejected))) == nextStack : List<&2,R.Value>}:
  Next.savedStack(Resume.start(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),Resume.methods(nextValues,Graph.source(value),nextAnswer),second)),Graph.source(value),values,answer,Resume.methods(nextValues,Graph.source(value),nextAnswer),reverse,second),Context.actor(second),rest,stack,incoming,rejected),1n+Eval.cost(values),Graph.source(value),Pair.targetPred([],[],reverse),Context.actor(Bool.not(second)),Context.actor(Bool.not(second)),nextValues,nextAnswer,nextRest,nextStack,nextIncoming,nextRejected,Constructed.complete(value,values,answer,nextValues,nextAnswer,reverse,second,rest,stack,incoming,rejected))
