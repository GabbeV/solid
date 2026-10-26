# A genuine fresh signal/render-node/link construction supplies all the ordinary
# updater profile facts. This is a raw constructor/graph entry, not a whole public
# render invocation or a claim that the effect's callback has already executed.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct-state.bend as N
import ../runtime/graph-state.bend as G
import ../runtime/core.bend as C
import ./ordinary-write-outer.bend as Frame
import ./ordinary-updater-evaluation.bend as Eval
import ./ordinary-updater-health.bend as Write
import ./pending-stack-history.bend as Steps
import ./subscriber-walk-step.bend as Path

def signal(initial: R.Value) -> R.World:
  N.signal(B.empty(),initial,N.defaults())

def source(initial: R.Value) -> Nat:
  B.length(R.Node,R.World.nodes(B.empty()))

def reader(initial: R.Value) -> Nat:
  B.length(R.Node,R.World.nodes(signal(initial)))

def allocated(+initial: R.Value) -> R.World:
  N.createEffectNode(signal(initial),R.Read{source(initial)},R.Render{},0n,N.defaults(),0n,0n,0n)

def linked(+initial: R.Value) -> R.World:
  G.link(allocated(initial),source(initial),reader(initial))

def next(+initial: R.Value) -> {R.Link.nextSub(B.link(linked(initial),1n)) == 0n : Nat}:
  {==}

def path(+initial: R.Value) -> Path.Path<linked(initial)>:
  Path.Edge{0n,Path.End{},next(initial)}

def frame(+initial: R.Value,+value: R.Value,+rest: List<&2,C.Task>,+stack: List<&2,R.Value>,+previous: R.Value) -> {Frame.observe(C.world(Steps.iterate(3n,Eval.start(linked(initial),rest,stack,source(initial),value,previous)))) == Frame.observe(linked(initial)) : R.World}:
  Write.frame(linked(initial),path(initial),source(initial),value,previous,19n,rest,stack,{==},{==},{==},{==},{==},{==},{==},{==},{==},{==})
