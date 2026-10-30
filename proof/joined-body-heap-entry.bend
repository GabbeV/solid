# Execute the real raw first joined body through its queued Round into the heap.
# Sweep-input and health premises are derived, not supplied after body execution.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../proof/held-pair-generic-body.bend as Generic
import ../proof/held-pair-generic-context.bend as Context
import ../proof/held-resume-retirement.bend as Resume
import ../proof/held-pair-generic-round.bend as Round
import ../proof/held-pair-constructed-round.bend as Raw
import ../proof/held-first-ready-construction.bend as Ready
import ../proof/action-control-flags.bend as Flags
import ../proof/ordinary-graph-data.bend as Graph
import ../proof/action-body-return.bend as Step
import ../proof/core-prefix-compose.bend as Prefix
import ../proof/pending-stack-history.bend as Steps
import ./joined-round-sweep-input.bend as Data
import ./sweep-input-frame.bend as Sweep
import ./round-entry.bend as Entry

import ./joined-round-heap-entry.bend as Joined
def start(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> C.Machine:
  Resume.start(Generic.world(Data.seed(value,values,answer,other,second),Graph.source(value),values,answer,other,reverse,second),Context.actor(second),rest,stack,incoming,rejected)

def cost(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> Nat:
  Joined.cost(Data.seed(value,values,answer,other,second),Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Ready.constructed(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Flags.raw(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)))

def target(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> C.Machine:
  Joined.target(Data.seed(value,values,answer,other,second),Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Ready.constructed(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Flags.raw(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)))

def complete(+value: R.Value,+values: List<&2,R.Value>,+answer: R.Value,+other: R.Expr,+reverse: Bool,+second: Bool,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+incoming: R.Value,+rejected: Bool) -> {Steps.iterate(cost(value,values,answer,other,reverse,second,rest,stack,incoming,rejected),start(value,values,answer,other,reverse,second,rest,stack,incoming,rejected)) == target(value,values,answer,other,reverse,second,rest,stack,incoming,rejected) : C.Machine}:
  Joined.complete(Data.seed(value,values,answer,other,second),Graph.source(value),values,answer,other,reverse,second,rest,stack,incoming,rejected,Ready.constructed(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Flags.raw(value,Generic.left(Resume.methods(values,Graph.source(value),answer),other,second)),Data.initial(value,values,answer,other,second))
