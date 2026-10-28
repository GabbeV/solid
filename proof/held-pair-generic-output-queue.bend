# Either real joined controller runs a finite setter body and retires exactly
# its captured obligation, with the other obligation retained in the target.
# Raw graph/controllers/hold/join supply every input profile/capture/count fact.
# This starts at captured resume; host parking/delivery and Round remain separate.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ./held-first-ready.bend as Ready
import ./held-pair-generic-state.bend as State
import ./held-pair-generic-context.bend as Context
import ./held-pair-generic-aliases.bend as Aliases
import ./held-source-cache-debt.bend as Cache
import ./held-count-certificate.bend as Debt
import ./held-pair-generic-body.bend as Generic
import ./held-resume-retirement.bend as Resume
import ./held-body-evaluation.bend as Eval
import ./held-write-history.bend as History
import ./action-body-entry.bend as Entry
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./pending-stack-history.bend as Steps
import ./transaction-pair.bend as Pair

import ./held-source-cache-output-queue.bend as SourceQueue
import ./action-output-continuation.bend as Queue
import ./held-pair-generic-debt.bend as PairDebt

def classify(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,Generic.left(Resume.methods(values,id,answer),other,second)>) -> Queue.Queue<SourceQueue.after(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),values,rest,stack,incoming,rejected),SourceQueue.work(Generic.world(seed,id,values,answer,other,reverse,second),rest),stack>:
  +methods = Resume.methods(values,id,answer)
  +l = Generic.left(methods,other,second)
  +r = Generic.right(methods,other,second)
  SourceQueue.freshQueue(State.joined(seed,r,reverse),Context.actor(second),values,id,answer,rest,stack,incoming,rejected,Pair.targetPred([],[],reverse),Context.actor(second),1n,Context.profile(seed,id,l,r,reverse,ready),Aliases.first(seed,id,l,r,reverse,ready),Aliases.cached(seed,id,l,r,reverse,ready),Aliases.selected(seed,id,l,r,reverse,second,ready),Aliases.captured(seed,id,l,r,reverse,second,ready),Aliases.selectedIdentity(seed,id,l,r,reverse,second,ready),Context.empty(seed,id,l,r,reverse,ready),Context.count(seed,id,l,r,reverse,ready),Generic.method(seed,id,values,answer,other,reverse,second,ready))

def drain(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,Generic.left(Resume.methods(values,id,answer),other,second)>) -> {Steps.iterate(Queue.cost(SourceQueue.after(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),values,rest,stack,incoming,rejected),SourceQueue.work(Generic.world(seed,id,values,answer,other,reverse,second),rest),stack,classify(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready)),SourceQueue.after(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),values,rest,stack,incoming,rejected)) == C.Machine{Queue.world(SourceQueue.after(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),values,rest,stack,incoming,rejected),SourceQueue.work(Generic.world(seed,id,values,answer,other,reverse,second),rest),stack,classify(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready)),SourceQueue.work(Generic.world(seed,id,values,answer,other,reverse,second),rest),stack} : C.Machine}:
  Queue.drain(SourceQueue.after(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),values,rest,stack,incoming,rejected),SourceQueue.work(Generic.world(seed,id,values,answer,other,reverse,second),rest),stack,classify(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready),Debt.healthy(Resume.start(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected),1n+Eval.cost(values),id,Pair.targetPred([],[],reverse),1n,PairDebt.complete(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready)))
