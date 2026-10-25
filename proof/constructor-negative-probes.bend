# Small source-changing kernel probes; general constructor contracts are in
# default-computed-construction and memo-render-construction.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/construct-state.bend as N
import ../runtime/constants.bend as K

def memo() -> R.World:
  N.computed(B.empty(), R.Literal{R.Undefined{}}, N.defaults(), 0n)

def effect() -> R.World:
  N.createEffectNode(B.empty(), R.Literal{R.Undefined{}}, R.Render{}, 0n, N.defaults(), 0n, 0n, 0n)

def memoAutomatic() -> {B.has(R.Node.config(B.node(memo(), 1n)), K.CONFIG_AUTO_DISPOSE()) == True{} : Bool}:
  {==}

def effectNotAutomatic() -> {B.has(R.Node.config(B.node(effect(), 1n)), K.CONFIG_AUTO_DISPOSE()) == False{} : Bool}:
  {==}

def effectHeap() -> {R.Node.prevHeap(B.node(effect(), 1n)) == 1n : Nat}:
  {==}
