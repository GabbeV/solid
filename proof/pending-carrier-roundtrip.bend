# Constructed fresh-Set add/duplicate/delete/duplicate contract over arbitrary
# Worlds and nonzero sources. An allocated zero-pointer extension is the initial
# context; no singleton membership or final deletion premise is supplied.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ./pending-carrier-existing.bend as Existing
import ./pending-carrier-retirement.bend as Retire
import ./pending-fresh-set.bend as Fresh

def added(w: R.World, id: Nat, source: Nat) -> R.World:
  B.first(R.World, Bool, P.addPendingSource(w, id, source))

def removed(+w: R.World, +id: Nat, +source: Nat) -> R.World:
  B.first(R.World, Bool, P.removePendingSource(added(w, id, source), id, source))

def finalWorld(+w: R.World, +id: Nat, +source: Nat, +sets: List<&2, List<&2, Nat>>) -> R.World:
  Retire.retired(Fresh.canonical(w, id, source, sets), id, 1n+B.length(List<&2, Nat>, sets))

def exact(+w: R.World, +id: Nat, +source: Nat, +extension: Nat, +sets: List<&2, List<&2, Nat>>,
  allocated: {R.Node.x(B.node(w, id)) == 1n+extension : Nat}, empty: {R.NodeExtension.pendingSources(B.extension(w, id)) == 0n : Nat},
  +fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool},
  +arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {removed(w, id, 1n+source) == finalWorld(w, id, 1n+source, sets) : R.World}:
  +next = Fresh.canonical(w, id, 1n+source, sets)
  Equal.trans(R.World, removed(w, id, 1n+source), B.first(R.World, Bool, P.removePendingSource(next, id, 1n+source)), finalWorld(w, id, 1n+source, sets),
    Equal.cong(R.World, R.World, state => B.first(R.World, Bool, P.removePendingSource(state, id, 1n+source)), added(w, id, 1n+source), next, Fresh.actualAdded(w, id, 1n+source, extension, sets, allocated, empty, fits, arena)),
    Equal.cong(B.Bundle<R.World, Bool>, R.World, pair => B.first(R.World, Bool, pair), P.removePendingSource(next, id, 1n+source), B.Bundle{finalWorld(w, id, 1n+source, sets), True{}}, Retire.remove(next, id, source, B.length(List<&2, Nat>, sets), Fresh.canonicalPointer(w, id, 1n+source, sets, fits, arena), Fresh.canonicalSlots(w, id, 1n+source, sets, arena))))

def absent(+w: R.World, +id: Nat, +source: Nat, +extension: Nat, +sets: List<&2, List<&2, Nat>>,
  allocated: {R.Node.x(B.node(w, id)) == 1n+extension : Nat}, empty: {R.NodeExtension.pendingSources(B.extension(w, id)) == 0n : Nat},
  +fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool},
  +arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {P.hasSource(removed(w, id, 1n+source), id, 1n+source) == False{} : Bool}:
  Equal.trans(Bool, P.hasSource(removed(w, id, 1n+source), id, 1n+source), P.hasSource(finalWorld(w, id, 1n+source, sets), id, 1n+source), False{}, Equal.cong(R.World, Bool, state => P.hasSource(state, id, 1n+source), removed(w, id, 1n+source), finalWorld(w, id, 1n+source, sets), exact(w, id, source, extension, sets, allocated, empty, fits, arena)),
    Retire.absent(Fresh.canonical(w, id, 1n+source, sets), id, 1n+source, B.length(List<&2, Nat>, sets), Fresh.canonicalExtRoom(w, id, 1n+source, sets, fits), Fresh.canonicalZero(w, id, 1n+source, sets, arena)))

def duplicateAdd(+w: R.World, +id: Nat, +source: Nat, +extension: Nat, +sets: List<&2, List<&2, Nat>>,
  allocated: {R.Node.x(B.node(w, id)) == 1n+extension : Nat}, empty: {R.NodeExtension.pendingSources(B.extension(w, id)) == 0n : Nat},
  fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool},
  arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {P.addPendingSource(added(w, id, 1n+source), id, 1n+source) == B.Bundle{added(w, id, 1n+source), False{}} : B.Bundle<R.World, Bool>}:
  Existing.duplicate(added(w, id, 1n+source), id, 1n+source, Fresh.contains(w, id, source, extension, sets, allocated, empty, fits, arena))

def duplicateRemove(+w: R.World, +id: Nat, +source: Nat, +extension: Nat, +sets: List<&2, List<&2, Nat>>,
  allocated: {R.Node.x(B.node(w, id)) == 1n+extension : Nat}, empty: {R.NodeExtension.pendingSources(B.extension(w, id)) == 0n : Nat},
  fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool},
  arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {P.removePendingSource(removed(w, id, 1n+source), id, 1n+source) == B.Bundle{removed(w, id, 1n+source), False{}} : B.Bundle<R.World, Bool>}:
  Retire.duplicate(removed(w, id, 1n+source), id, 1n+source, absent(w, id, source, extension, sets, allocated, empty, fits, arena))
