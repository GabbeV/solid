# The actual joined resume/body/output/slice boundary retains exactly the heap
# intake produced by its finite write body. No invariant is assumed afterward.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../proof/held-first-ready.bend as Ready
import ../proof/held-pair-generic-body.bend as Generic
import ../proof/held-resume-retirement.bend as Resume
import ../proof/action-control-flags.bend as Flags
import ../proof/held-pair-generic-round.bend as Round
import ../proof/held-pair-generic-context.bend as Context
import ../proof/held-source-cache-output-queue.bend as SourceQueue
import ../proof/held-pair-generic-output-queue.bend as PairQueue
import ../proof/action-output-continuation.bend as Queue
import ../proof/action-output-frame.bend as Output
import ../proof/action-output-delivery-loop.bend as Loop
import ../proof/action-body-entry.bend as Entry
import ../proof/action-body-retirement.bend as Exit
import ../proof/held-write-history.bend as History
import ./heap-entry-view.bend as View
import ./action-heap-entry.bend as Action
import ./masked-projection.bend as Projection

def output(+before: R.World,+after: R.World,same: {Output.outer(after) == Output.outer(before) : R.World}) -> {View.observe(after) == View.observe(before) : View.View}:
  Projection.transport(View.View,View.observe,Output.outer,before,after,same,View.outputMasked(before),View.outputMasked(after))

def queued(+machine: C.Machine,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+form: Queue.Queue<machine,rest,stack>) -> {View.observe(Queue.world(machine,rest,stack,form)) == View.observe(C.world(machine)) : View.View}:
  +next = Queue.world(machine,rest,stack,form)
  Projection.transport(View.View,View.observe,Loop.outer,C.world(machine),next,Queue.frame(machine,rest,stack,form),View.jobsMasked(C.world(machine)),View.jobsMasked(next))

def written(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool) -> R.World:
  History.run(values,Entry.prepared(Generic.world(seed,id,values,answer,other,reverse,second),Context.actor(second),R.ActionEnd{}),id)

def retained(+seed: R.World,+id: Nat,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool,+ready: Ready.Ready<seed,id,Generic.left(Resume.methods(values,id,answer),other,second)>,known: {Flags.observe(seed) == Flags.Flags{0n,False{},False{}} : Flags.View}) -> {View.observe(Round.world(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready,known)) == View.observe(written(seed,id,values,answer,other,reverse,second)) : View.View}:
  +input = Generic.world(seed,id,values,answer,other,reverse,second)
  +before = written(seed,id,values,answer,other,reverse,second)
  +target = Exit.target(before,Context.root(reverse),1n)
  +actual = SourceQueue.after(input,Context.actor(second),values,rest,stack,incoming,rejected)
  +work = SourceQueue.work(input,rest)
  +form = PairQueue.classify(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready)
  +after = Queue.world(actual,work,stack,form)
  +same = Generic.complete(seed,id,values,answer,other,reverse,second,rest,stack,incoming,rejected,ready)
  View.compose(before,C.world(actual),after,queued(actual,work,stack,form),View.compose(before,target,C.world(actual),output(target,C.world(actual),same),Action.target(before,Context.root(reverse),1n)))
