# Source graph pointer operations (owner callback continuation lives in owner.bend): stable link identities, both list directions,
# generation-stamped in-order reuse and validated-prefix duplicate suppression.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def allocate(+w: R.World, +dep: Nat, +sub: Nat, +prevDep: Nat, nextDep: Nat, +prevSub: Nat) -> R.World:
  +id = B.length(R.Link, R.World.links(w))
  edge = {R.Link{dep, sub, nextDep, prevSub, 0n, R.Node.depGen(B.node(w, sub))} : R.Link}
  +w = R.World.with_links(w, B.append(R.Link, R.World.links(w), [edge]))
  +w = B.store_node(w, sub, R.Node.with_depsTail(B.node(w, sub), id))
  +w = B.store_node(w, dep, R.Node.with_subsTail(B.node(w, dep), id))
  +w = B.choose(~R.World, Nat.is_ne(prevDep, 0n),
    _ => B.store_link(w, prevDep, R.Link.with_nextDep(B.link(w, prevDep), id)),
    _ => B.store_node(w, sub, R.Node.with_deps(B.node(w, sub), id)))
  +w = B.choose(~R.World, Nat.is_ne(prevSub, 0n),
    _ => B.store_link(w, prevSub, R.Link.with_nextSub(B.link(w, prevSub), id)),
    _ => B.store_node(w, dep, R.Node.with_subs(B.node(w, dep), id)))
  B.bump(w)

def append_or_duplicate(+w: R.World, +dep: Nat, +sub: Nat, prevDep: Nat, nextDep: Nat, recomputing: Bool) -> R.World:
  +tail = R.Node.subsTail(B.node(w, dep))
  +edge = B.link(w, tail)
  duplicate = Bool.and(Nat.is_ne(tail, 0n), Bool.and(Nat.is_eq(R.Link.sub(edge), sub),
    Bool.or(Bool.not(recomputing), Nat.is_eq(R.Link.gen(edge), R.Node.depGen(B.node(w, sub))))))
  B.choose(~R.World, duplicate, _ => w,
    _ => allocate(w, dep, sub, prevDep, nextDep, tail))

def reuse_or_append(+w: R.World, +dep: Nat, +sub: Nat, +prevDep: Nat, +nextDep: Nat, +recomputing: Bool) -> R.World:
  same = Bool.and(recomputing, Bool.and(Nat.is_ne(nextDep, 0n), Nat.is_eq(R.Link.dep(B.link(w, nextDep)), dep)))
  B.choose(~R.World, same,
    _ => B.store_node(B.store_link(w, nextDep, R.Link.with_gen(B.link(w, nextDep), R.Node.depGen(B.node(w, sub)))), sub,
      R.Node.with_depsTail(B.node(w, sub), nextDep)),
    _ => append_or_duplicate(w, dep, sub, prevDep, nextDep, recomputing))

def link(+w: R.World, +dep: Nat, +sub: Nat) -> R.World:
  +prev = R.Node.depsTail(B.node(w, sub))
  +recomputing = B.has(R.Node.flags(B.node(w, sub)), 4)
  next = B.choose(~Nat, recomputing,
    _ => B.choose(~Nat, Nat.is_ne(prev, 0n), _ => R.Link.nextDep(B.link(w, prev)), _ => R.Node.deps(B.node(w, sub))),
    _ => 0n)
  B.choose(~R.World, Bool.and(Nat.is_ne(prev, 0n), Nat.is_eq(R.Link.dep(B.link(w, prev)), dep)),
    _ => w, _ => reuse_or_append(w, dep, sub, prev, next, recomputing))

def unlinkSubs(+w: R.World, +id: Nat) -> B.Bundle<R.World, Nat>:
  +edge = B.link(w, id)
  +dep = R.Link.dep(edge)
  +next = R.Link.nextSub(edge)
  +prev = R.Link.prevSub(edge)
  +w = B.choose(~R.World, Nat.is_ne(next, 0n),
    _ => B.store_link(w, next, R.Link.with_prevSub(B.link(w, next), prev)),
    _ => B.store_node(w, dep, R.Node.with_subsTail(B.node(w, dep), prev)))
  +w = B.choose(~R.World, Nat.is_ne(prev, 0n),
    _ => B.store_link(w, prev, R.Link.with_nextSub(B.link(w, prev), next)),
    _ => B.store_node(w, dep, R.Node.with_subs(B.node(w, dep), next)))
  B.Bundle{w, R.Link.nextDep(edge)}


# graph.ts:deferredReleases/deferReleases. Nonzero arena handles retain the
# array identity captured across nested passes; collection preserves duplicates.
def beginReleases(+w: R.World) -> B.Bundle<R.World, Nat>:
  +id = B.length(List<&2, Nat>, R.World.releaseLists(w))
  +w = R.World.with_releaseLists(w, B.append(List<&2, Nat>, R.World.releaseLists(w), [[]]))
  B.Bundle{R.World.with_deferredReleases(w, id), id}

def deferRelease(+w: R.World, id: Nat) -> R.World:
  +list = R.World.deferredReleases(w)
  +nodes = B.get(List<&2, Nat>, R.World.releaseLists(w), list, [])
  R.World.with_releaseLists(w, List.set(&2, List<&2, Nat>, R.World.releaseLists(w), list, B.append(Nat, nodes, [id])))
