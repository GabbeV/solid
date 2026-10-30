# core/lanes.ts:laneServed drops only the served source's pending origins.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./pending-state.bend as P

def remove(sources: List<&2,Nat>,w: R.World,+reader: Nat) -> R.World:
  match sources:
    case Nil{}: w
    case source <> rest:
      remove(rest,B.first(R.World,Bool,P.removePendingSource(w,reader,source)),reader)

def selected(w: R.World,reader: Nat,from: R.SourceSet,own: R.SourceSet) -> R.World:
  match from own:
    case R.Sources{sources} R.Sources{items}: remove(sources,w,reader)
    case _ _: w

def served(+w: R.World,+reader: Nat,source: Nat) -> R.World:
  selected(w,reader,B.pendingSources(w,source),B.pendingSources(w,reader))
