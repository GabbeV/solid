# Synthetic source-helper probes. Node numbers below are identity labels only;
# these probes stop before owner cleanup and do not claim public graph execution.
import Base
import ../../runtime/api.bend as A
import ../../runtime/core.bend as C
import ../../runtime/arrays.bend as Arrays
import ../../runtime/keyed-map.bend as M
import ../../runtime/small-move.bend as Small
import ../../representation/base.bend as B
import ../../representation/records.bend as R

def nil() -> List<&2, R.Value>:
  []

def cons(+value: R.Value, +tail: List<&2, R.Value>) -> List<&2, R.Value>:
  value <> tail

def number(+n: Nat) -> R.Value:
  R.Number{n}

def nan() -> R.Value:
  R.NotANumber{}

def undefined() -> R.Value:
  R.Undefined{}

def reference(+id: Nat) -> R.Value:
  R.Reference{id}

def labels(+size: Nat, +index: Nat) -> List<&2, Nat>:
  match size:
    case 0n:
      []
    case 1n+rest:
      index <> labels(rest, 1n+index)

def mappings(+size: Nat, +index: Nat) -> List<&2, R.Value>:
  match size:
    case 0n:
      []
    case 1n+rest:
      R.Number{index} <> mappings(rest, 1n+index)

def setup(+old: List<&2, R.Value>, +next: List<&2, R.Value>) -> R.World:
  +size = B.length(R.Value, old)
  +items = Arrays.allocate(A.createWorld(), Arrays.slots(old))
  +mapped = Arrays.allocate(B.first(R.World, Nat, items), Arrays.slots(mappings(size, 1n)))
  +incoming = Arrays.allocate(B.first(R.World, Nat, mapped), Arrays.slots(next))
  R.World.with_maps(B.first(R.World, Nat, incoming), [R.MapState{0n, size, R.Literal{R.Undefined{}}, 0n, R.Undefined{}, 1n, labels(size, 1n), [], R.NoInlineBody{}, False{}, [], False{}, R.Undefined{}}])

def direct(+old: List<&2, R.Value>, +next: List<&2, R.Value>, +start: Nat) -> B.Bundle<R.World, R.SmallPlan>:
  Small.trySmallMove(setup(old, next), 0n, 2n, B.length(R.Value, next), start)

def probe(+old: List<&2, R.Value>, +next: List<&2, R.Value>, +start: Nat, +end: Nat, +newEnd: Nat) -> Bool:
  Small.probe(setup(old, next), 0n, 2n, start, end, newEnd)

def branch(+old: List<&2, R.Value>, +next: List<&2, R.Value>, +start: Nat, +end: Nat, +newEnd: Nat) -> C.Machine:
  C.mapAfterTrim(setup(old, next), [], [], 0n, 2n, B.length(R.Value, next), start, end, newEnd)

def tasks(+machine: C.Machine) -> List<&2, C.Task>:
  match machine:
    case C.Machine{w, tasks, values}:
      tasks

def removalActive(+tasks: List<&2, C.Task>) -> Bool:
  match tasks:
    case C.MapRemovalMatch{frame, oldIndex, newIndex} <> tail:
      True{}
    case C.MapRemoval{frame, index} <> tail:
      True{}
    case other:
      False{}

def runRemoval(+fuel: Nat, +machine: C.Machine) -> C.Machine:
  match fuel:
    case 0n:
      C.Machine{R.World.with_fault(C.world(machine), R.Exhausted{}), tasks(machine), C.values(machine)}
    case 1n+rest:
      B.choose(~C.Machine, removalActive(tasks(machine)), _ => runRemoval(rest, C.step(machine)), _ => machine)

def removal(+old: List<&2, R.Value>, +next: List<&2, R.Value>, +start: Nat, +end: Nat, +newEnd: Nat) -> C.Machine:
  +w = setup(old, next)
  +temp = Arrays.fresh(w, B.length(R.Value, next))
  +w = B.first(R.World, Nat, temp)
  +frame = M.frame(0n, 2n, B.length(R.Value, next), end, start, B.second(R.World, Nat, temp), False{}, newEnd, False{}, False{})
  runRemoval(4096n, C.Machine{w, [C.MapRemovalMatch{frame, start, start}], []})

# Stop just before mapWindowRows' final publication: this is commitWindow only.
def windowActive(+tasks: List<&2, C.Task>) -> Bool:
  match tasks:
    case C.MapWindowGrowShift{frame, cursor, destination} <> tail:
      True{}
    case C.MapWindowShrinkShift{frame, index, destination} <> tail:
      True{}
    case C.MapWindowRows{frame, index} <> tail:
      Nat.is_lt(index, R.MapFrame.newEnd(frame))
    case other:
      False{}

def runWindow(+fuel: Nat, +machine: C.Machine) -> C.Machine:
  match fuel:
    case 0n:
      C.Machine{R.World.with_fault(C.world(machine), R.Exhausted{}), tasks(machine), C.values(machine)}
    case 1n+rest:
      B.choose(~C.Machine, windowActive(tasks(machine)), _ => runWindow(rest, C.step(machine)), _ => machine)

def window(+old: List<&2, R.Value>, +next: List<&2, R.Value>, +start: Nat, +end: Nat, +newEnd: Nat) -> C.Machine:
  +w = setup(old, next)
  +temp = Arrays.fresh(w, B.length(R.Value, next))
  +w = B.first(R.World, Nat, temp)
  +frame = M.frame(0n, 2n, B.length(R.Value, next), end, start, B.second(R.World, Nat, temp), False{}, newEnd, False{}, False{})
  +frame = R.MapFrame.with_nodes(frame, labels(Nat.sub(newEnd, start), Nat.add(B.length(R.Value, old), 1n)))
  runWindow(4096n, C.mapWindow(w, [], [], frame))

def fits(+bits: Nat, +n: Nat) -> Bool:
  Small.fits(bits, n)
