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

import ./held-pair-generic-output-queue.bend as PairQueue
import ./held-source-cache-output-queue.bend as SourceQueue
import ./action-output-continuation.bend as Queue
import ./held-pair-constructed-debt.bend as PairDebt

def classify(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> Queue.Queue<SourceQueue.after(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),Context.actor(second),values,rest,stack,incoming,rejected),SourceQueue.work(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),rest),stack>:
  PairQueue.classify(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Ready.constructed(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)))

def drain(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Steps.iterate(Queue.cost(SourceQueue.after(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),Context.actor(second),values,rest,stack,incoming,rejected),SourceQueue.work(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),rest),stack,classify(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)),SourceQueue.after(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),Context.actor(second),values,rest,stack,incoming,rejected)) == C.Machine{Queue.world(SourceQueue.after(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),Context.actor(second),values,rest,stack,incoming,rejected),SourceQueue.work(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),rest),stack,classify(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)),SourceQueue.work(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),rest),stack} : C.Machine}:
  Queue.drain(SourceQueue.after(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),Context.actor(second),values,rest,stack,incoming,rejected),SourceQueue.work(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),rest),stack,classify(value,values,answer,other,reverse,second,rest,stack,incoming,rejected),Debt.healthy(Resume.start(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected),1n+Eval.cost(values),Graph.source(value),Pair.targetPred([],[],reverse),1n,PairDebt.complete(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)))
