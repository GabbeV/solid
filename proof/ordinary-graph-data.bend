# Actual raw signal/render/link construction, separate from semantic proofs.
# This is shared proof input data and calls the one source-followable runtime.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct-state.bend as N
import ../runtime/graph-state.bend as G

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
