# Actual fresh graph allocation/link retains all extension identities.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/graph-state.bend as G
import ./graph-empty-allocation.bend as Allocation
import ./graph-fresh-link.bend as Fresh
import ./node-pointer-observation.bend as Pointer

def writes(+w: R.World, +root: Nat, +leaf: Nat, +edge: Nat) ->
  {Pointer.observe(Allocation.writes(w, root, leaf, edge)) == Pointer.observe(w) : List<&2, Nat>}:
  +first = Allocation.first(w, leaf, edge)
  +second = Allocation.second(first, root, edge)
  +third = Allocation.third(second, leaf, edge)
  +fourth = Allocation.fourth(third, root, edge)
  Pointer.compose(w, fourth, Allocation.writes(w, root, leaf, edge), Pointer.bump(fourth),
    Pointer.compose(w, third, fourth, Pointer.write(third, root, edge, Pointer.SubscriberHead{}),
      Pointer.compose(w, second, third, Pointer.write(second, leaf, edge, Pointer.DependencyHead{}),
        Pointer.compose(w, first, second, Pointer.write(first, root, edge, Pointer.SubscriberTail{}), Pointer.write(w, leaf, edge, Pointer.DependencyTail{})))))

def allocated(+w: R.World, +root: Nat, +leaf: Nat) ->
  {Pointer.observe(Allocation.source(w, root, leaf)) == Pointer.observe(w) : List<&2, Nat>}:
  +next = Allocation.appended(w, root, leaf)
  Pointer.compose(w, next, Allocation.source(w, root, leaf), Equal.trans(List<&2, Nat>, Pointer.observe(Allocation.source(w, root, leaf)), Pointer.observe(Allocation.writes(next, root, leaf, Allocation.index(w))), Pointer.observe(next), Equal.cong(R.World, List<&2, Nat>, state => Pointer.observe(state), Allocation.source(w, root, leaf), Allocation.writes(next, root, leaf, Allocation.index(w)), Allocation.exact(w, root, leaf)), writes(next, root, leaf, Allocation.index(w))), Pointer.worldLinks(w, B.append(R.Link, R.World.links(w), [Allocation.record(w, root, leaf)])))

def linked(+w: R.World, +root: Nat, +leaf: Nat,
  depsTail: {R.Node.depsTail(B.node(w, leaf)) == 0n : Nat}, deps: {R.Node.deps(B.node(w, leaf)) == 0n : Nat}, sourceTail: {R.Node.subsTail(B.node(w, root)) == 0n : Nat}) ->
  {Pointer.observe(G.link(w, root, leaf)) == Pointer.observe(w) : List<&2, Nat>}:
  Equal.trans(List<&2, Nat>, Pointer.observe(G.link(w, root, leaf)), Pointer.observe(Allocation.source(w, root, leaf)), Pointer.observe(w), Equal.cong(R.World, List<&2, Nat>, state => Pointer.observe(state), G.link(w, root, leaf), Allocation.source(w, root, leaf), Fresh.freshEmptyDependencies(w, root, leaf, depsTail, deps, sourceTail)), allocated(w, root, leaf))
