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
import ./held-pair-generic-context.bend as Context
import ./held-resume-retirement.bend as Resume
import ./held-body-evaluation.bend as Eval
import ./held-write-history.bend as History
import ./action-body-entry.bend as Entry
import ./action-body-retirement.bend as Exit
import ./action-output-frame.bend as Output
import ./pending-stack-history.bend as Steps

def seed(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+second: Bool) -> R.World:
  First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second))

def world(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool) -> R.World:
  Generic.world(seed(value,values,answer,other,second),Graph.source(value),values,answer,other,reverse,second)

def complete(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Output.outer(C.world(Steps.iterate(1n+Eval.cost(values),Resume.start(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected)))) == Output.outer(Exit.target(History.run(values,Entry.prepared(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),Context.actor(second),R.ActionEnd{}),Graph.source(value)),Context.root(reverse),1n)) : R.World}:
  Generic.complete(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Ready.constructed(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)))

def savedStack(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {C.values(Steps.iterate(1n+Eval.cost(values),Resume.start(Generic.world(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected))) == stack : List<&2,R.Value>}:
  Generic.savedStack(First.opened(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Ready.constructed(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)))
