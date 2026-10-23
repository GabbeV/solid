# Invoke the actual factory/method implementations at the plain iteration
# boundary. Promise reactions are delivered by the existing host afterwards.
import Base
import ../../representation/records.bend as R
import ../../representation/base.bend as B
import ../../runtime/from-state.bend as F
import ../../runtime/core.bend as C
import ../../runtime/iterator-methods.bend as Methods

type Opened is Data:
  Opened{world: R.World, iterator: Nat}

def iterator(value: R.Value) -> Nat:
  match value:
    case R.IteratorReference{iterator}: iterator
    case _: 0n

def result(+machine: C.Machine) -> Opened:
  Opened{R.World.with_context(C.world(machine), 0n), iterator(B.get(R.Value, C.values(machine), 0n, R.Undefined{}))}

def open(w: R.World, source: Nat, owned: Bool) -> Opened:
  +pair = F.create(R.World.with_context(w, B.choose(~Nat, owned, _ => 1n, _ => 0n)), R.FromIterable{source})
  result(C.run(256n, C.Machine{B.first(R.World, Nat, pair), [C.FromOpen{B.second(R.World, Nat, pair)}], []}))

def pull(w: R.World, iterator: Nat, argument: R.Slot) -> B.Bundle<R.World, R.NextInput>:
  Methods.next(w, iterator, argument)

def close(w: R.World, iterator: Nat, argument: R.Slot) -> C.Machine:
  C.run(256n, C.Machine{w, [C.IteratorReturn{iterator, argument}], []})
