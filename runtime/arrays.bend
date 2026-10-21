# Ordinary JavaScript array storage for collection results and user payloads.
# Stable IDs preserve === identity; Empty slots preserve holes separately from
# present undefined. This module contains no reactive scheduling decisions.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def holes(+size: Nat) -> List<&2, R.Slot>:
  match size:
    case 0n:
      []
    case 1n+rest:
      R.Empty{} <> holes(rest)

def slots(+values: List<&2, R.Value>) -> List<&2, R.Slot>:
  match values:
    case Nil{}:
      []
    case value <> rest:
      R.Present{value} <> slots(rest)

def allocate(+w: R.World, +items: List<&2, R.Slot>) -> B.Bundle<R.World, Nat>:
  +id = B.length(R.ArrayData, R.World.arrays(w))
  B.Bundle{R.World.with_arrays(w, B.append(R.ArrayData, R.World.arrays(w), [R.ArrayData{items}])), id}

def fresh(+w: R.World, +size: Nat) -> B.Bundle<R.World, Nat>:
  allocate(w, holes(size))

def get(+w: R.World, +id: Nat) -> List<&2, R.Slot>:
  R.ArrayData.slots(B.get(R.ArrayData, R.World.arrays(w), id, R.ArrayData{[]}))

def length(+w: R.World, +id: Nat) -> Nat:
  B.length(R.Slot, get(w, id))

def at(+w: R.World, +id: Nat, +index: Nat) -> R.Value:
  B.selected(B.get(R.Slot, get(w, id), index, R.Empty{}), R.Undefined{})

def put(+w: R.World, +id: Nat, +index: Nat, +value: R.Value) -> R.World:
  +items = B.put(R.Slot, get(w, id), index, R.Empty{}, R.Present{value})
  R.World.with_arrays(w, List.set(&2, R.ArrayData, R.World.arrays(w), id, R.ArrayData{items}))

# Array.slice's admitted nonnegative [start,end) arm, preserving sparse slots.
def take(+size: Nat, +items: List<&2, R.Slot>) -> List<&2, R.Slot>:
  match size items:
    case 0n _:
      []
    case _ Nil{}:
      []
    case 1n+p head <> tail:
      head <> take(p, tail)

def drop(+size: Nat, +items: List<&2, R.Slot>) -> List<&2, R.Slot>:
  match size items:
    case 0n rest:
      rest
    case _ Nil{}:
      []
    case 1n+p head <> tail:
      drop(p, tail)

def slice(+w: R.World, +id: Nat, +start: Nat, +end: Nat) -> B.Bundle<R.World, Nat>:
  allocate(w, take(Nat.sub(end, start), drop(start, get(w, id))))
