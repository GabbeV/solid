# A nonempty raw constructor/controller family: actual signal/render/link,
# action allocation/opening, source ownership and captured resume. This does
# not assert complete public invocation/parking reachability or publication.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/action-state.bend as A
import ../runtime/transaction.bend as X
import ./ordinary-body-construction-normal.bend as Normal
import ./ordinary-write-constructed.bend as Graph
import ./ordinary-body-entry.bend as Entry
import ./action-body-entry.bend as Prepared
import ./held-write-profile.bend as P
import ./subscriber-walk-step.bend as Path

# Proof-only normal form retains the real hold/list operation rather than
# reconstructing its nodes/extensions/groups by assertion.
def normalized(+initial: R.Value) -> R.World:
  X.holdNode(Normal.normalized(Graph.linked(initial)),Graph.source(initial),1n)

def linked(+initial: R.Value) -> {R.Link.nextSub(B.link(normalized(initial),1n)) == 0n : Nat}:
  {==}

def path(+initial: R.Value) -> Path.Path<normalized(initial)>:
  Path.Edge{0n,Path.End{},linked(initial)}

def profile(+initial: R.Value) -> P.Profile<normalized(initial),Graph.source(initial),0n>:
  P.HeldAt{path(initial),19n,{==},{==},{==},{==},{==},{==},{==},{==},{==},{==},{==},{==},{==},{==},{==},{==}}
