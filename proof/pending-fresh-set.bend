# A fresh actual pending Set supplies its membership premises. The initial node
# extension is allocated and has a zero pending pointer; Set slot zero is empty.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ../runtime/extension.bend as E
import ./pending-add-frame.bend as Generic
import ./pending-carrier-existing.bend as Segment
import ./pending-auxiliary-lookup.bend as Aux
import ./node-allocation-validity.bend as Arithmetic
import ./transaction-list-construction.bend as Extension

def index(w: R.World) -> Nat:
  B.length(List<&2, Nat>, R.World.pendingSets(w))

def grown(w: R.World) -> R.World:
  B.first(R.World, Nat, B.newPendingSet(w, []))

def record(+w: R.World, id: Nat) -> R.NodeExtension:
  R.NodeExtension.with_pendingSources(B.extension(grown(w), id), index(w))

def created(w: R.World, id: Nat) -> R.World:
  Generic.created(w, id)

def pointer(+w: R.World, +id: Nat,
  room: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool}) ->
  {R.NodeExtension.pendingSources(B.extension(created(w, id), id)) == index(w) : Nat}:
  +fits = Equal.trans(Bool, Nat.is_lt(R.Node.x(B.node(grown(w), id)), B.length(R.NodeExtension, R.World.extensions(grown(w)))), Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))), True{}, Aux.pendingRoom(w, B.append(List<&2, Nat>, R.World.pendingSets(w), [[]]), id), room)
  Equal.trans(Nat, R.NodeExtension.pendingSources(B.extension(created(w, id), id)), R.NodeExtension.pendingSources(record(w, id)), index(w), Equal.cong(R.NodeExtension, Nat, value => R.NodeExtension.pendingSources(value), B.extension(created(w, id), id), record(w, id), Aux.extensionRead(grown(w), id, record(w, id), fits)), Aux.pendingPointer(B.extension(grown(w), id), index(w)))

def slots(+w: R.World, +id: Nat) -> {B.pendingSlots(created(w, id), index(w)) == [] : List<&2, Nat>}:
  Equal.trans(List<&2, Nat>, B.pendingSlots(created(w, id), index(w)), B.pendingSlots(grown(w), index(w)), [], Aux.extensionSlots(grown(w), id, record(w, id), index(w)), Aux.newSetSlot(w))

def count(+w: R.World, +id: Nat) ->
  {B.length(List<&2, Nat>, R.World.pendingSets(created(w, id))) == Nat.add(index(w), 1n) : Nat}:
  Equal.trans(Nat, B.length(List<&2, Nat>, R.World.pendingSets(created(w, id))), B.length(List<&2, Nat>, R.World.pendingSets(grown(w))), Nat.add(index(w), 1n), Aux.extensionSetCount(grown(w), id, record(w, id)), Aux.newSetCount(w))

def room(+w: R.World, +id: Nat) ->
  {Nat.is_lt(index(w), B.length(List<&2, Nat>, R.World.pendingSets(created(w, id)))) == True{} : Bool}:
  Equal.trans(Bool, Nat.is_lt(index(w), B.length(List<&2, Nat>, R.World.pendingSets(created(w, id)))), Nat.is_lt(index(w), Nat.add(index(w), 1n)), True{}, Equal.cong(Nat, Bool, size => Nat.is_lt(index(w), size), B.length(List<&2, Nat>, R.World.pendingSets(created(w, id))), Nat.add(index(w), 1n), count(w, id)), Arithmetic.nextRoom(index(w)))

def positive(+w: R.World, +sets: List<&2, List<&2, Nat>>, known: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {index(w) == 1n+B.length(List<&2, Nat>, sets) : Nat}:
  Equal.cong(List<&2, List<&2, Nat>>, Nat, values => B.length(List<&2, Nat>, values), R.World.pendingSets(w), [] <> sets, known)

def zero(+w: R.World, +sets: List<&2, List<&2, Nat>>, known: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {B.pendingSlots(w, 0n) == [] : List<&2, Nat>}:
  Equal.cong(List<&2, List<&2, Nat>>, List<&2, Nat>, values => B.get(List<&2, Nat>, values, 0n, []), R.World.pendingSets(w), [] <> sets, known)

def afterCreated(+w: R.World, +id: Nat, +source: Nat,
  +fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool}) ->
  {Segment.setPart(w, id, source, 0n) == B.Bundle{B.store_pendingSet(created(w, id), index(w), [source]), True{}} : B.Bundle<R.World, Bool>}:
  +next = created(w, id)
  Equal.trans(B.Bundle<R.World, Bool>, Segment.setPart(w, id, source, 0n), Segment.finish(next, source, index(w), B.pendingSlots(next, index(w))), Segment.finish(next, source, index(w), []),
    Equal.cong(Nat, B.Bundle<R.World, Bool>, set => Segment.finish(next, source, set, B.pendingSlots(next, set)), R.NodeExtension.pendingSources(B.extension(next, id)), index(w), pointer(w, id, fits)),
    Equal.cong(List<&2, Nat>, B.Bundle<R.World, Bool>, values => Segment.finish(next, source, index(w), values), B.pendingSlots(next, index(w)), [], slots(w, id)))

def absent(+w: R.World, +id: Nat, +source: Nat,
  empty: {R.NodeExtension.pendingSources(B.extension(w, id)) == 0n : Nat},
  zero: {B.pendingSlots(w, 0n) == [] : List<&2, Nat>}) -> {P.hasSource(w, id, source) == False{} : Bool}:
  Equal.trans(Bool, P.hasSource(w, id, source), B.contains(B.pendingItems(w, 0n), source), False{}, Equal.cong(Nat, Bool, set => B.contains(B.pendingItems(w, set), source), R.NodeExtension.pendingSources(B.extension(w, id)), 0n, empty), Equal.cong(List<&2, Nat>, Bool, values => B.contains(B.liveIds(values), source), B.pendingSlots(w, 0n), [], zero))

def part(+w: R.World, +id: Nat, +source: Nat, +extension: Nat,
  allocated: {R.Node.x(B.node(w, id)) == 1n+extension : Nat},
  empty: {R.NodeExtension.pendingSources(B.extension(w, id)) == 0n : Nat},
  fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool}) ->
  {Segment.addPart(w, id, source) == B.Bundle{B.store_pendingSet(created(w, id), index(w), [source]), True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, Segment.addPart(w, id, source), Segment.setPart(w, id, source, R.NodeExtension.pendingSources(B.extension(w, id))), B.Bundle{B.store_pendingSet(created(w, id), index(w), [source]), True{}},
    Equal.cong(R.World, B.Bundle<R.World, Bool>, state => Segment.setPart(state, id, source, R.NodeExtension.pendingSources(B.extension(state, id))), E.ext(w, id), w, Extension.existing(w, id, extension, allocated)),
    Equal.trans(B.Bundle<R.World, Bool>, Segment.setPart(w, id, source, R.NodeExtension.pendingSources(B.extension(w, id))), Segment.setPart(w, id, source, 0n), B.Bundle{B.store_pendingSet(created(w, id), index(w), [source]), True{}}, Equal.cong(Nat, B.Bundle<R.World, Bool>, set => Segment.setPart(w, id, source, set), R.NodeExtension.pendingSources(B.extension(w, id)), 0n, empty), afterCreated(w, id, source, fits)))

def add(+w: R.World, +id: Nat, +source: Nat, +extension: Nat, +sets: List<&2, List<&2, Nat>>,
  allocated: {R.Node.x(B.node(w, id)) == 1n+extension : Nat},
  +empty: {R.NodeExtension.pendingSources(B.extension(w, id)) == 0n : Nat},
  fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool},
  arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {P.addPendingSource(w, id, source) == B.Bundle{B.store_pendingSet(created(w, id), index(w), [source]), True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, P.addPendingSource(w, id, source), B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{w, False{}}, _ => Segment.addPart(w, id, source)), B.Bundle{B.store_pendingSet(created(w, id), index(w), [source]), True{}}, Segment.exact(w, id, source),
    Equal.trans(B.Bundle<R.World, Bool>, B.choose(~B.Bundle<R.World, Bool>, P.hasSource(w, id, source), _ => B.Bundle{w, False{}}, _ => Segment.addPart(w, id, source)), Segment.addPart(w, id, source), B.Bundle{B.store_pendingSet(created(w, id), index(w), [source]), True{}}, Equal.cong(Bool, B.Bundle<R.World, Bool>, flag => B.choose(~B.Bundle<R.World, Bool>, flag, _ => B.Bundle{w, False{}}, _ => Segment.addPart(w, id, source)), P.hasSource(w, id, source), False{}, absent(w, id, source, empty, zero(w, sets, arena))), part(w, id, source, extension, allocated, empty, fits)))


def canonical(+w: R.World, +id: Nat, source: Nat, sets: List<&2, List<&2, Nat>>) -> R.World:
  B.store_pendingSet(created(w, id), 1n+B.length(List<&2, Nat>, sets), [source])

def actualAdded(+w: R.World, +id: Nat, +source: Nat, +extension: Nat, +sets: List<&2, List<&2, Nat>>,
  allocated: {R.Node.x(B.node(w, id)) == 1n+extension : Nat},
  empty: {R.NodeExtension.pendingSources(B.extension(w, id)) == 0n : Nat},
  fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool},
  +arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {B.first(R.World, Bool, P.addPendingSource(w, id, source)) == canonical(w, id, source, sets) : R.World}:
  Equal.trans(R.World, B.first(R.World, Bool, P.addPendingSource(w, id, source)), B.store_pendingSet(created(w, id), index(w), [source]), canonical(w, id, source, sets),
    Equal.cong(B.Bundle<R.World, Bool>, R.World, pair => B.first(R.World, Bool, pair), P.addPendingSource(w, id, source), B.Bundle{B.store_pendingSet(created(w, id), index(w), [source]), True{}}, add(w, id, source, extension, sets, allocated, empty, fits, arena)),
    Equal.cong(Nat, R.World, set => B.store_pendingSet(created(w, id), set, [source]), index(w), 1n+B.length(List<&2, Nat>, sets), positive(w, sets, arena)))

def createdPointer(+w: R.World, +id: Nat, +sets: List<&2, List<&2, Nat>>,
  fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool},
  arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {R.NodeExtension.pendingSources(B.extension(created(w, id), id)) == 1n+B.length(List<&2, Nat>, sets) : Nat}:
  Equal.trans(Nat, R.NodeExtension.pendingSources(B.extension(created(w, id), id)), index(w), 1n+B.length(List<&2, Nat>, sets), pointer(w, id, fits), positive(w, sets, arena))

def createdRoom(+w: R.World, +id: Nat, +sets: List<&2, List<&2, Nat>>, arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {Nat.is_lt(1n+B.length(List<&2, Nat>, sets), B.length(List<&2, Nat>, R.World.pendingSets(created(w, id)))) == True{} : Bool}:
  Equal.trans(Bool, Nat.is_lt(1n+B.length(List<&2, Nat>, sets), B.length(List<&2, Nat>, R.World.pendingSets(created(w, id)))), Nat.is_lt(index(w), B.length(List<&2, Nat>, R.World.pendingSets(created(w, id)))), True{},
    Equal.cong(Nat, Bool, set => Nat.is_lt(set, B.length(List<&2, Nat>, R.World.pendingSets(created(w, id)))), 1n+B.length(List<&2, Nat>, sets), index(w), Equal.sym(Nat, index(w), 1n+B.length(List<&2, Nat>, sets), positive(w, sets, arena))), room(w, id))

def canonicalPointer(+w: R.World, +id: Nat, +source: Nat, +sets: List<&2, List<&2, Nat>>,
  fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool},
  arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {R.NodeExtension.pendingSources(B.extension(canonical(w, id, source, sets), id)) == 1n+B.length(List<&2, Nat>, sets) : Nat}:
  Equal.trans(Nat, R.NodeExtension.pendingSources(B.extension(canonical(w, id, source, sets), id)), R.NodeExtension.pendingSources(B.extension(created(w, id), id)), 1n+B.length(List<&2, Nat>, sets), Equal.cong(R.NodeExtension, Nat, value => R.NodeExtension.pendingSources(value), B.extension(canonical(w, id, source, sets), id), B.extension(created(w, id), id), Segment.storedExtension(created(w, id), 1n+B.length(List<&2, Nat>, sets), [source], id)), createdPointer(w, id, sets, fits, arena))

def canonicalSlots(+w: R.World, +id: Nat, +source: Nat, +sets: List<&2, List<&2, Nat>>, arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {B.pendingSlots(canonical(w, id, source, sets), 1n+B.length(List<&2, Nat>, sets)) == [source] : List<&2, Nat>}:
  Segment.storedSlots(created(w, id), 1n+B.length(List<&2, Nat>, sets), [source], createdRoom(w, id, sets, arena))

def contains(+w: R.World, +id: Nat, +source: Nat, +extension: Nat, +sets: List<&2, List<&2, Nat>>,
  allocated: {R.Node.x(B.node(w, id)) == 1n+extension : Nat}, empty: {R.NodeExtension.pendingSources(B.extension(w, id)) == 0n : Nat},
  +fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool},
  +arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {P.hasSource(B.first(R.World, Bool, P.addPendingSource(w, id, 1n+source)), id, 1n+source) == True{} : Bool}:
  Equal.trans(Bool, P.hasSource(B.first(R.World, Bool, P.addPendingSource(w, id, 1n+source)), id, 1n+source), P.hasSource(canonical(w, id, 1n+source, sets), id, 1n+source), True{},
    Equal.cong(R.World, Bool, state => P.hasSource(state, id, 1n+source), B.first(R.World, Bool, P.addPendingSource(w, id, 1n+source)), canonical(w, id, 1n+source, sets), actualAdded(w, id, 1n+source, extension, sets, allocated, empty, fits, arena)),
    Segment.singletonContains(created(w, id), id, source, B.length(List<&2, Nat>, sets), createdPointer(w, id, sets, fits, arena), createdRoom(w, id, sets, arena)))


def createdExtRoom(+w: R.World, +id: Nat,
  fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool}) ->
  {Nat.is_lt(R.Node.x(B.node(created(w, id), id)), B.length(R.NodeExtension, R.World.extensions(created(w, id)))) == True{} : Bool}:
  Equal.trans(Bool, Nat.is_lt(R.Node.x(B.node(created(w, id), id)), B.length(R.NodeExtension, R.World.extensions(created(w, id)))), Nat.is_lt(R.Node.x(B.node(grown(w), id)), B.length(R.NodeExtension, R.World.extensions(grown(w)))), True{}, Aux.extensionRoom(grown(w), id, record(w, id)), Equal.trans(Bool, Nat.is_lt(R.Node.x(B.node(grown(w), id)), B.length(R.NodeExtension, R.World.extensions(grown(w)))), Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))), True{}, Aux.pendingRoom(w, B.append(List<&2, Nat>, R.World.pendingSets(w), [[]]), id), fits))

def canonicalExtRoom(+w: R.World, +id: Nat, +source: Nat, +sets: List<&2, List<&2, Nat>>,
  fits: {Nat.is_lt(R.Node.x(B.node(w, id)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool}) ->
  {Nat.is_lt(R.Node.x(B.node(canonical(w, id, source, sets), id)), B.length(R.NodeExtension, R.World.extensions(canonical(w, id, source, sets)))) == True{} : Bool}:
  Equal.trans(Bool, Nat.is_lt(R.Node.x(B.node(canonical(w, id, source, sets), id)), B.length(R.NodeExtension, R.World.extensions(canonical(w, id, source, sets)))), Nat.is_lt(R.Node.x(B.node(created(w, id), id)), B.length(R.NodeExtension, R.World.extensions(created(w, id)))), True{}, Aux.pendingRoom(created(w, id), List.set(&2, List<&2, Nat>, R.World.pendingSets(created(w, id)), 1n+B.length(List<&2, Nat>, sets), [source]), id), createdExtRoom(w, id, fits))

def createdZero(+w: R.World, +id: Nat, +sets: List<&2, List<&2, Nat>>, +arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {B.pendingSlots(created(w, id), 0n) == [] : List<&2, Nat>}:
  +fits = Equal.cong(List<&2, List<&2, Nat>>, Bool, values => Nat.is_lt(0n, B.length(List<&2, Nat>, values)), R.World.pendingSets(w), [] <> sets, arena)
  Equal.trans(List<&2, Nat>, B.pendingSlots(created(w, id), 0n), B.pendingSlots(grown(w), 0n), [], Aux.extensionSlots(grown(w), id, record(w, id), 0n), Equal.trans(List<&2, Nat>, B.pendingSlots(grown(w), 0n), B.pendingSlots(w, 0n), [], Aux.newSetOldSlots(w, 0n, fits), zero(w, sets, arena)))

def canonicalZero(+w: R.World, +id: Nat, +source: Nat, +sets: List<&2, List<&2, Nat>>, arena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) ->
  {B.pendingSlots(canonical(w, id, source, sets), 0n) == [] : List<&2, Nat>}:
  Equal.trans(List<&2, Nat>, B.pendingSlots(canonical(w, id, source, sets), 0n), B.pendingSlots(created(w, id), 0n), [], Aux.pendingOther(created(w, id), 1n+B.length(List<&2, Nat>, sets), 0n, [source], {==}), createdZero(w, id, sets, arena))
