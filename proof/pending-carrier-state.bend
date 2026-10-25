# A representation invariant for one nonzero source across arbitrarily many
# actual add/remove cycles. It is not a flight-controller or status invariant.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/pending-state.bend as P
import ./pending-command-history.bend as Commands
import ./pending-fresh-carrier.bend as New
import ./pending-fresh-set.bend as Fresh
import ./pending-carrier-existing.bend as Existing
import ./pending-carrier-retirement.bend as Retire
import ./pending-carrier-arena.bend as Arena

type CarrierSnapshot<-w: R.World, -node: Nat, -source: Nat> is Data:
  CarrierFresh{extensions: List<&2, R.NodeExtension>, sets: List<&2, List<&2, Nat>>, valid: {B.valid(w, node) == True{} : Bool}, empty: {R.Node.x(B.node(w, node)) == 0n : Nat}, extensionArena: {R.World.extensions(w) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}, setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}}
  CarrierEmpty{extension: Nat, sets: List<&2, List<&2, Nat>>, allocated: {R.Node.x(B.node(w, node)) == 1n+extension : Nat}, room: {Nat.is_lt(R.Node.x(B.node(w, node)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool}, empty: {R.NodeExtension.pendingSources(B.extension(w, node)) == 0n : Nat}, setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}}
  CarrierSingle{extension: Nat, set: Nat, sets: List<&2, List<&2, Nat>>, allocated: {R.Node.x(B.node(w, node)) == 1n+extension : Nat}, room: {Nat.is_lt(R.Node.x(B.node(w, node)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool}, pointer: {R.NodeExtension.pendingSources(B.extension(w, node)) == 1n+set : Nat}, slots: {B.pendingSlots(w, 1n+set) == [1n+source] : List<&2, Nat>}, setRoom: {Nat.is_lt(1n+set, B.length(List<&2, Nat>, R.World.pendingSets(w))) == True{} : Bool}, setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}}

def addWorld(w: R.World, node: Nat, +source: Nat) -> R.World:
  B.first(R.World, Bool, P.addPendingSource(w, node, 1n+source))

def removeWorld(w: R.World, node: Nat, +source: Nat) -> R.World:
  B.first(R.World, Bool, P.removePendingSource(w, node, 1n+source))

def next(w: R.World, node: Nat, source: Nat, command: Commands.Command) -> R.World:
  match command:
    case Commands.AddLeaf{}: addWorld(w, node, source)
    case Commands.RemoveLeaf{}: removeWorld(w, node, source)

def present(-w: R.World, -node: Nat, -source: Nat, snapshot: CarrierSnapshot<w, node, source>) -> Bool:
  match snapshot:
    case CarrierFresh{extensions, sets, valid, empty, extensionArena, setArena}: False{}
    case CarrierEmpty{extension, sets, allocated, room, empty, setArena}: False{}
    case CarrierSingle{extension, set, sets, allocated, room, pointer, slots, setRoom, setArena}: True{}

def sound(+w: R.World, +node: Nat, +source: Nat, +snapshot: CarrierSnapshot<w, node, source>) ->
  {P.hasSource(w, node, 1n+source) == present(w, node, source, snapshot) : Bool}:
  match snapshot:
    case CarrierFresh{extensions, sets, valid, empty, extensionArena, setArena}: New.initiallyAbsent(w, node, 1n+source, extensions, sets, empty, extensionArena, setArena)
    case CarrierEmpty{extension, sets, allocated, room, empty, setArena}: Fresh.absent(w, node, 1n+source, empty, Fresh.zero(w, sets, setArena))
    case CarrierSingle{extension, set, sets, allocated, room, pointer, slots, setRoom, setArena}: Retire.singletonPresent(w, node, source, set, pointer, slots)

def shift_valid(-a: R.World, -b: R.World, -node: Nat, same: {a == b : R.World}, value: {B.valid(a, node) == True{} : Bool}) -> {B.valid(b, node) == True{} : Bool}:
  %same : {B.valid(_, node) == True{} : Bool}
  value

def shift_emptyX(-a: R.World, -b: R.World, -node: Nat, same: {a == b : R.World}, value: {R.Node.x(B.node(a, node)) == 0n : Nat}) -> {R.Node.x(B.node(b, node)) == 0n : Nat}:
  %same : {R.Node.x(B.node(_, node)) == 0n : Nat}
  value

def shift_extensionArena(-a: R.World, -b: R.World, -extensions: List<&2, R.NodeExtension>, same: {a == b : R.World}, value: {R.World.extensions(a) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}) -> {R.World.extensions(b) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}:
  %same : {R.World.extensions(_) == B.blank_extension() <> extensions : List<&2, R.NodeExtension>}
  value

def shift_setArena(-a: R.World, -b: R.World, -sets: List<&2, List<&2, Nat>>, same: {a == b : R.World}, value: {R.World.pendingSets(a) == [] <> sets : List<&2, List<&2, Nat>>}) -> {R.World.pendingSets(b) == [] <> sets : List<&2, List<&2, Nat>>}:
  %same : {R.World.pendingSets(_) == [] <> sets : List<&2, List<&2, Nat>>}
  value

def shift_allocated(-a: R.World, -b: R.World, -node: Nat, -extension: Nat, same: {a == b : R.World}, value: {R.Node.x(B.node(a, node)) == 1n+extension : Nat}) -> {R.Node.x(B.node(b, node)) == 1n+extension : Nat}:
  %same : {R.Node.x(B.node(_, node)) == 1n+extension : Nat}
  value

def shift_room(-a: R.World, -b: R.World, -node: Nat, same: {a == b : R.World}, value: {Nat.is_lt(R.Node.x(B.node(a, node)), B.length(R.NodeExtension, R.World.extensions(a))) == True{} : Bool}) -> {Nat.is_lt(R.Node.x(B.node(b, node)), B.length(R.NodeExtension, R.World.extensions(b))) == True{} : Bool}:
  %same : {Nat.is_lt(R.Node.x(B.node(_, node)), B.length(R.NodeExtension, R.World.extensions(_))) == True{} : Bool}
  value

def shift_emptyPointer(-a: R.World, -b: R.World, -node: Nat, same: {a == b : R.World}, value: {R.NodeExtension.pendingSources(B.extension(a, node)) == 0n : Nat}) -> {R.NodeExtension.pendingSources(B.extension(b, node)) == 0n : Nat}:
  %same : {R.NodeExtension.pendingSources(B.extension(_, node)) == 0n : Nat}
  value

def shift_pointer(-a: R.World, -b: R.World, -node: Nat, -set: Nat, same: {a == b : R.World}, value: {R.NodeExtension.pendingSources(B.extension(a, node)) == 1n+set : Nat}) -> {R.NodeExtension.pendingSources(B.extension(b, node)) == 1n+set : Nat}:
  %same : {R.NodeExtension.pendingSources(B.extension(_, node)) == 1n+set : Nat}
  value

def shift_slots(-a: R.World, -b: R.World, -node: Nat, -source: Nat, -set: Nat, same: {a == b : R.World}, value: {B.pendingSlots(a, 1n+set) == [1n+source] : List<&2, Nat>}) -> {B.pendingSlots(b, 1n+set) == [1n+source] : List<&2, Nat>}:
  %same : {B.pendingSlots(_, 1n+set) == [1n+source] : List<&2, Nat>}
  value

def shift_setRoom(-a: R.World, -b: R.World, -set: Nat, same: {a == b : R.World}, value: {Nat.is_lt(1n+set, B.length(List<&2, Nat>, R.World.pendingSets(a))) == True{} : Bool}) -> {Nat.is_lt(1n+set, B.length(List<&2, Nat>, R.World.pendingSets(b))) == True{} : Bool}:
  %same : {Nat.is_lt(1n+set, B.length(List<&2, Nat>, R.World.pendingSets(_))) == True{} : Bool}
  value

def move(-a: R.World, -b: R.World, -node: Nat, -source: Nat, +same: {a == b : R.World}, snapshot: CarrierSnapshot<a, node, source>) -> CarrierSnapshot<b, node, source>:
  match snapshot:
    case CarrierFresh{+extensions, +sets, +valid, +emptyX, +extensionArena, +setArena}:
      CarrierFresh{extensions, sets, shift_valid(a, b, node, same, valid), shift_emptyX(a, b, node, same, emptyX), shift_extensionArena(a, b, extensions, same, extensionArena), shift_setArena(a, b, sets, same, setArena)}
    case CarrierEmpty{+extension, +sets, +allocated, +room, +emptyPointer, +setArena}:
      CarrierEmpty{extension, sets, shift_allocated(a, b, node, extension, same, allocated), shift_room(a, b, node, same, room), shift_emptyPointer(a, b, node, same, emptyPointer), shift_setArena(a, b, sets, same, setArena)}
    case CarrierSingle{+extension, +set, +sets, +allocated, +room, +pointer, +slots, +setRoom, +setArena}:
      CarrierSingle{extension, set, sets, shift_allocated(a, b, node, extension, same, allocated), shift_room(a, b, node, same, room), shift_pointer(a, b, node, set, same, pointer), shift_slots(a, b, node, source, set, same, slots), shift_setRoom(a, b, set, same, setRoom), shift_setArena(a, b, sets, same, setArena)}


def movePresent(-a: R.World, -b: R.World, -node: Nat, -source: Nat, +same: {a == b : R.World}, +snapshot: CarrierSnapshot<a, node, source>) ->
  {present(b, node, source, move(a, b, node, source, same, snapshot)) == present(a, node, source, snapshot) : Bool}:
  match snapshot:
    case CarrierFresh{extensions, sets, valid, emptyX, extensionArena, setArena}: {==}
    case CarrierEmpty{extension, sets, allocated, room, emptyPointer, setArena}: {==}
    case CarrierSingle{extension, set, sets, allocated, room, pointer, slots, setRoom, setArena}: {==}

def addEmpty(+w: R.World, +node: Nat, +source: Nat, +extension: Nat, +sets: List<&2, List<&2, Nat>>,
  +allocated: {R.Node.x(B.node(w, node)) == 1n+extension : Nat}, +room: {Nat.is_lt(R.Node.x(B.node(w, node)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool}, empty: {R.NodeExtension.pendingSources(B.extension(w, node)) == 0n : Nat}, +setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) -> CarrierSnapshot<addWorld(w, node, source), node, source>:
  +canonical = Fresh.canonical(w, node, 1n+source, sets)
  +snapshot = {CarrierSingle{extension, B.length(List<&2, Nat>, sets), B.append(List<&2, Nat>, sets, [[1n+source]]),
    Equal.trans(Nat, R.Node.x(B.node(canonical, node)), R.Node.x(B.node(w, node)), 1n+extension, Arena.canonicalX(w, node, 1n+source, sets), allocated), Fresh.canonicalExtRoom(w, node, 1n+source, sets, room), Fresh.canonicalPointer(w, node, 1n+source, sets, room, setArena), Fresh.canonicalSlots(w, node, 1n+source, sets, setArena), Arena.canonicalRoom(w, node, 1n+source, sets, setArena), Arena.canonicalArena(w, node, 1n+source, sets, setArena)} : CarrierSnapshot<canonical, node, source>}
  move(canonical, addWorld(w, node, source), node, source, Equal.sym(R.World, addWorld(w, node, source), canonical, Fresh.actualAdded(w, node, 1n+source, extension, sets, allocated, empty, room, setArena)), snapshot)

def removeSingle(+w: R.World, +node: Nat, +source: Nat, +extension: Nat, +set: Nat, +sets: List<&2, List<&2, Nat>>,
  allocated: {R.Node.x(B.node(w, node)) == 1n+extension : Nat}, +room: {Nat.is_lt(R.Node.x(B.node(w, node)), B.length(R.NodeExtension, R.World.extensions(w))) == True{} : Bool}, pointer: {R.NodeExtension.pendingSources(B.extension(w, node)) == 1n+set : Nat}, slots: {B.pendingSlots(w, 1n+set) == [1n+source] : List<&2, Nat>}, setArena: {R.World.pendingSets(w) == [] <> sets : List<&2, List<&2, Nat>>}) -> CarrierSnapshot<removeWorld(w, node, source), node, source>:
  +canonical = Retire.retired(w, node, 1n+set)
  +snapshot = {CarrierEmpty{extension, List.set(&2, List<&2, Nat>, sets, set, [0n]), Equal.trans(Nat, R.Node.x(B.node(canonical, node)), R.Node.x(B.node(w, node)), 1n+extension, Arena.retiredX(w, node, set), allocated), Arena.retiredExtRoom(w, node, set, room), Retire.pointer(w, node, set, room), Arena.retiredArena(w, node, set, sets, setArena)} : CarrierSnapshot<canonical, node, source>}
  move(canonical, removeWorld(w, node, source), node, source, Equal.sym(R.World, removeWorld(w, node, source), canonical, Equal.cong(B.Bundle<R.World, Bool>, R.World, pair => B.first(R.World, Bool, pair), P.removePendingSource(w, node, 1n+source), B.Bundle{canonical, True{}}, Retire.remove(w, node, source, set, pointer, slots))), snapshot)


def step(+w: R.World, +node: Nat, +source: Nat, snapshot: CarrierSnapshot<w, node, source>, command: Commands.Command) -> CarrierSnapshot<next(w, node, source, command), node, source>:
  match snapshot:
    case CarrierFresh{+extensions, +sets, +valid, +empty, +extensionArena, +setArena}:
      match command:
        case Commands.AddLeaf{}:
          +extended = New.extended(w, node)
          +snapshot = addEmpty(extended, node, source, B.length(R.NodeExtension, extensions), sets, New.allocated(w, node, extensions, valid, empty, extensionArena), New.extensionRoom(w, node, valid, empty), New.noSources(w, node, valid, empty), New.setArena(w, node, sets, empty, setArena))
          move(addWorld(extended, node, source), addWorld(w, node, source), node, source, Equal.sym(R.World, addWorld(w, node, source), addWorld(extended, node, source), Equal.cong(B.Bundle<R.World, Bool>, R.World, pair => B.first(R.World, Bool, pair), P.addPendingSource(w, node, 1n+source), P.addPendingSource(extended, node, 1n+source), New.asExtended(w, node, 1n+source, extensions, sets, valid, empty, extensionArena, setArena))), snapshot)
        case Commands.RemoveLeaf{}:
          +missing = New.initiallyAbsent(w, node, 1n+source, extensions, sets, empty, extensionArena, setArena)
          +same = Equal.cong(B.Bundle<R.World, Bool>, R.World, pair => B.first(R.World, Bool, pair), P.removePendingSource(w, node, 1n+source), B.Bundle{w, False{}}, Retire.duplicate(w, node, 1n+source, missing))
          move(w, removeWorld(w, node, source), node, source, Equal.sym(R.World, removeWorld(w, node, source), w, same), CarrierFresh{extensions, sets, valid, empty, extensionArena, setArena})
    case CarrierEmpty{+extension, +sets, +allocated, +room, +empty, +setArena}:
      match command:
        case Commands.AddLeaf{}: addEmpty(w, node, source, extension, sets, allocated, room, empty, setArena)
        case Commands.RemoveLeaf{}:
          +missing = Fresh.absent(w, node, 1n+source, empty, Fresh.zero(w, sets, setArena))
          +same = Equal.cong(B.Bundle<R.World, Bool>, R.World, pair => B.first(R.World, Bool, pair), P.removePendingSource(w, node, 1n+source), B.Bundle{w, False{}}, Retire.duplicate(w, node, 1n+source, missing))
          move(w, removeWorld(w, node, source), node, source, Equal.sym(R.World, removeWorld(w, node, source), w, same), CarrierEmpty{extension, sets, allocated, room, empty, setArena})
    case CarrierSingle{+extension, +set, +sets, +allocated, +room, +pointer, +slots, +setRoom, +setArena}:
      match command:
        case Commands.AddLeaf{}:
          +present = Retire.singletonPresent(w, node, source, set, pointer, slots)
          +same = Equal.cong(B.Bundle<R.World, Bool>, R.World, pair => B.first(R.World, Bool, pair), P.addPendingSource(w, node, 1n+source), B.Bundle{w, False{}}, Existing.duplicate(w, node, 1n+source, present))
          move(w, addWorld(w, node, source), node, source, Equal.sym(R.World, addWorld(w, node, source), w, same), CarrierSingle{extension, set, sets, allocated, room, pointer, slots, setRoom, setArena})
        case Commands.RemoveLeaf{}: removeSingle(w, node, source, extension, set, sets, allocated, room, pointer, slots, setArena)


def isAdd(command: Commands.Command) -> Bool:
  match command:
    case Commands.AddLeaf{}: True{}
    case Commands.RemoveLeaf{}: False{}

def stepPresent(+w: R.World, +node: Nat, +source: Nat, +snapshot: CarrierSnapshot<w, node, source>, +command: Commands.Command) ->
  {present(next(w, node, source, command), node, source, step(w, node, source, snapshot, command)) == isAdd(command) : Bool}:
  match snapshot:
    case CarrierFresh{extensions, sets, valid, empty, extensionArena, setArena}:
      match command:
        case Commands.AddLeaf{}: {==}
        case Commands.RemoveLeaf{}: {==}
    case CarrierEmpty{extension, sets, allocated, room, empty, setArena}:
      match command:
        case Commands.AddLeaf{}: {==}
        case Commands.RemoveLeaf{}: {==}
    case CarrierSingle{extension, set, sets, allocated, room, pointer, slots, setRoom, setArena}:
      match command:
        case Commands.AddLeaf{}: {==}
        case Commands.RemoveLeaf{}: {==}
