# core/graph.ts boundaries. Pure pointer operations live in graph-state;
# hook/dormancy calls run on the owner continuation machine to express the
# source graph/owner recursion without a Bend module cycle.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./graph-state.bend as L
import ./owner.bend as O

def link(w: R.World, dep: Nat, sub: Nat) -> R.World:
  L.link(w, dep, sub)

def unlinkSubs(+w: R.World, +edge: Nat) -> B.Bundle<R.World, Nat>:
  next = R.Link.nextDep(B.link(w, edge))
  B.Bundle{O.unlinkSubs(w, edge), next}

def clearDeps(w: R.World, id: Nat) -> R.World:
  O.clearDeps(w, id)

def trimStaleDeps(w: R.World, id: Nat) -> R.World:
  O.trimStaleDeps(w, id)

def unobserved(w: R.World, id: Nat) -> R.World:
  O.unobserved(w, id)

def queueDormant(+w: R.World, +id: Nat) -> R.World:
  B.choose(~R.World, B.contains(R.World.dormantNodes(w), id), _ => w,
    _ => R.World.with_dormantNodes(w, B.append(Nat, R.World.dormantNodes(w), [id])))

def sweepDormant(w: R.World) -> R.World:
  O.sweepDormant(w)
