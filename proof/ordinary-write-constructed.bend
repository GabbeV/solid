# A genuine fresh signal/render-node/link construction supplies all the ordinary
# updater profile facts. This is a raw constructor/graph entry, not a whole public
# render invocation or a claim that the effect's callback has already executed.
import Base
import ./ordinary-graph-data.bend as Data
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ./ordinary-write-outer.bend as Frame
import ./ordinary-updater-evaluation.bend as Eval
import ./ordinary-updater-health.bend as Write
import ./pending-stack-history.bend as Steps
import ./subscriber-walk-step.bend as Path

def signal(initial: R.Value) -> R.World:
  Data.signal(initial)

def source(initial: R.Value) -> Nat:
  Data.source(initial)

def reader(initial: R.Value) -> Nat:
  Data.reader(initial)

def allocated(+initial: R.Value) -> R.World:
  Data.allocated(initial)

def linked(+initial: R.Value) -> R.World:
  Data.linked(initial)

def next(+initial: R.Value) -> {R.Link.nextSub(B.link(linked(initial),1n)) == 0n : Nat}:
  {==}

def path(+initial: R.Value) -> Path.Path<linked(initial)>:
  Path.Edge{0n,Path.End{},next(initial)}

def frame(+initial: R.Value,+value: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+previous: R.Value) -> {Frame.observe(C.world(Steps.iterate(3n,Eval.start(linked(initial),rest,stack,source(initial),value,previous)))) == Frame.observe(linked(initial)) : R.World}:
  Write.frame(linked(initial),path(initial),source(initial),value,previous,19n,rest,stack,{==},{==},{==},{==},{==},{==},{==},{==},{==},{==})
