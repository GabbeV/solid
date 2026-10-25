# Actual source deletion preserves tombstone positions. Removing the sole live
# source clears the node pointer; repeated removal is a no-op under reserved-zero
# Set storage. This is Set retirement, not a full once-only flight protocol.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ./pending-carrier-existing.bend as Add
import ./pending-auxiliary-lookup.bend as Aux
import ./pending-fresh-set.bend as Fresh

def afterSlots(+w: R.World, +id: Nat, +set: Nat, +slots: List<&2, Nat>) -> R.World:
  +w = B.store_pendingSet(w, set, slots)
  B.choose(~R.World, List.is_empty(&2, Nat, B.liveIds(slots)), _ => B.store_extension(w, id, R.NodeExtension.with_pendingSources(B.extension(w, id), 0n)), _ => w)

def afterSet(+w: R.World, +id: Nat, +source: Nat, +set: Nat) -> R.World:
  afterSlots(w, id, set, P.removeSlot(B.pendingSlots(w, set), source))

def body(+w: R.World, +id: Nat, +source: Nat) -> R.World:
  afterSet(w, id, source, R.NodeExtension.pendingSources(B.extension(w, id)))

def retired(+w: R.World, +id: Nat, +set: Nat) -> R.World:
  +w = B.store_pendingSet(w, set, [0n])
  B.store_extension(w, id, R.NodeExtension.with_pendingSources(B.extension(w, id), 0n))

def exact(+w: R.World, +id: Nat, +source: Nat) ->
  {P.removePendingSource(w, id, source) == B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{body(w, id, source), True{}}, _ => B.Bundle{w, False{}}) : B.Bundle<R.World, Bool>}:
  {==}

def singletonSlot(+source: Nat) -> {P.removeSlot([1n+source], 1n+source) == [0n] : List<&2, Nat>}:
  Equal.cong(Bool, List<&2, Nat>, flag => B.choose(~List<&2, Nat>, flag, _ => [0n], _ => [1n+source]), Nat.is_eq(1n+source, 1n+source), True{}, Add.self(1n+source))

def normalized(+w: R.World, +id: Nat, +source: Nat, +set: Nat,
  known: {R.NodeExtension.pendingSources(B.extension(w, id)) == 1n+set : Nat},
  slots: {B.pendingSlots(w, 1n+set) == [1n+source] : List<&2, Nat>}) ->
  {body(w, id, 1n+source) == retired(w, id, 1n+set) : R.World}:
  Equal.trans(R.World, body(w, id, 1n+source), afterSet(w, id, 1n+source, 1n+set), retired(w, id, 1n+set), Equal.cong(Nat, R.World, slot => afterSet(w, id, 1n+source, slot), R.NodeExtension.pendingSources(B.extension(w, id)), 1n+set, known),
    Equal.cong(List<&2, Nat>, R.World, items => afterSlots(w, id, 1n+set, items), P.removeSlot(B.pendingSlots(w, 1n+set), 1n+source), [0n],
      Equal.trans(List<&2, Nat>, P.removeSlot(B.pendingSlots(w, 1n+set), 1n+source), P.removeSlot([1n+source], 1n+source), [0n], Equal.cong(List<&2, Nat>, List<&2, Nat>, items => P.removeSlot(items, 1n+source), B.pendingSlots(w, 1n+set), [1n+source], slots), singletonSlot(source))))

def singletonPresent(+w: R.World, +id: Nat, +source: Nat, +set: Nat,
  known: {R.NodeExtension.pendingSources(B.extension(w, id)) == 1n+set : Nat},
  slots: {B.pendingSlots(w, 1n+set) == [1n+source] : List<&2, Nat>}) ->
  {P.hasSource(w, id, 1n+source) == True{} : Bool}:
  Equal.trans(Bool, P.hasSource(w, id, 1n+source), B.contains(B.liveIds(B.pendingSlots(w, 1n+set)), 1n+source), True{}, Equal.cong(Nat, Bool, index => B.contains(B.pendingItems(w, index), 1n+source), R.NodeExtension.pendingSources(B.extension(w, id)), 1n+set, known),
    Equal.trans(Bool, B.contains(B.liveIds(B.pendingSlots(w, 1n+set)), 1n+source), B.contains([1n+source], 1n+source), True{}, Equal.cong(List<&2, Nat>, Bool, values => B.contains(B.liveIds(values), 1n+source), B.pendingSlots(w, 1n+set), [1n+source], slots), Equal.cong(Bool, Bool, flag => Bool.or(flag, False{}), Nat.is_eq(1n+source, 1n+source), True{}, Add.self(1n+source))))

def remove(+w: R.World, +id: Nat, +source: Nat, +set: Nat,
  +known: {R.NodeExtension.pendingSources(B.extension(w, id)) == 1n+set : Nat},
  +slots: {B.pendingSlots(w, 1n+set) == [1n+source] : List<&2, Nat>}) ->
  {P.removePendingSource(w, id, 1n+source) == B.Bundle{retired(w, id, 1n+set), True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, P.removePendingSource(w, id, 1n+source), B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, 1n+source), _ => B.Bundle{body(w, id, 1n+source), True{}}, _ => B.Bundle{w, False{}}), B.Bundle{retired(w, id, 1n+set), True{}}, exact(w, id, 1n+source),
    Equal.trans(B.Bundle<R.World, Bool>, B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, 1n+source), _ => B.Bundle{body(w, id, 1n+source), True{}}, _ => B.Bundle{w, False{}}), B.Bundle{body(w, id, 1n+source), True{}}, B.Bundle{retired(w, id, 1n+set), True{}},
      Equal.cong(Bool, B.Bundle<R.World, Bool>, flag => B.choose(~B.Bundle<R.World, Bool>, flag, _ => B.Bundle{body(w, id, 1n+source), True{}}, _ => B.Bundle{w, False{}}), P.hasSource(w, id, 1n+source), True{}, singletonPresent(w, id, source, set, known, slots)),
      Equal.cong(R.World, B.Bundle<R.World, Bool>, state => B.Bundle{state, True{}}, body(w, id, 1n+source), retired(w, id, 1n+set), normalized(w, id, source, set, known, slots))))


def pointer(+w: R.World, +id: Nat, +set: Nat,
  fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool}) ->
  {R.NodeExtension.pendingSources(B.extension(retired(w, id, 1n+set), id)) == 0n : Nat}:
  +next = B.store_pendingSet(w, 1n+set, [0n])
  +record = R.NodeExtension.with_pendingSources(B.extension(next, id), 0n)
  +room = Equal.trans(Bool, Nat.is_lt(R.Node.x(B.node(next, id)), B.length(R.NodeExtension, R.World.extensions(next))), Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))), True{}, Aux.pendingRoom(w, List.set(&2, List<&2, Nat>, R.World.pendingSets(w), 1n+set, [0n]), id), fits)
  Equal.trans(Nat, R.NodeExtension.pendingSources(B.extension(retired(w, id, 1n+set), id)), R.NodeExtension.pendingSources(record), 0n, Equal.cong(R.NodeExtension, Nat, value => R.NodeExtension.pendingSources(value), B.extension(retired(w, id, 1n+set), id), record, Aux.extensionRead(next, id, record, room)), Aux.pendingPointer(B.extension(next, id), 0n))

def zero(+w: R.World, +id: Nat, +set: Nat, known: {B.pendingSlots(w, 0n) == [] : List<&2, Nat>}) ->
  {B.pendingSlots(retired(w, id, 1n+set), 0n) == [] : List<&2, Nat>}:
  +next = B.store_pendingSet(w, 1n+set, [0n])
  +record = R.NodeExtension.with_pendingSources(B.extension(next, id), 0n)
  Equal.trans(List<&2, Nat>, B.pendingSlots(retired(w, id, 1n+set), 0n), B.pendingSlots(next, 0n), [], Aux.extensionSlots(next, id, record, 0n), Equal.trans(List<&2, Nat>, B.pendingSlots(next, 0n), B.pendingSlots(w, 0n), [], Aux.pendingOther(w, 1n+set, 0n, [0n], {==}), known))

def absent(+w: R.World, +id: Nat, +source: Nat, +set: Nat,
  fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool},
  reserved: {B.pendingSlots(w, 0n) == [] : List<&2, Nat>}) ->
  {P.hasSource(retired(w, id, 1n+set), id, source) == False{} : Bool}:
  Fresh.absent(retired(w, id, 1n+set), id, source, pointer(w, id, set, fits), zero(w, id, set, reserved))

def duplicate(+w: R.World, +id: Nat, +source: Nat, missing: {P.hasSource(w, id, source) == False{} : Bool}) ->
  {P.removePendingSource(w, id, source) == B.Bundle{w, False{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, P.removePendingSource(w, id, source), B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{body(w, id, source), True{}}, _ => B.Bundle{w, False{}}), B.Bundle{w, False{}}, exact(w, id, source), Equal.cong(Bool, B.Bundle<R.World, Bool>, flag => B.choose(~B.Bundle<R.World, Bool>, flag, _ => B.Bundle{body(w, id, source), True{}}, _ => B.Bundle{w, False{}}), P.hasSource(w, id, source), False{}, missing))
