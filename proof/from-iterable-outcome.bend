# Complete programme corollary: arbitrary ordinary payload, one inner return,
# closed wrapper, empty pending set and a canceled pull even while the inner
# external Promise stays unresolved. Queued reactions remain external inputs.
import Base
import ./ordinary-payload.bend as Payload
import ./from-iterable-program.bend as Program
import ./from-iterable-driver.bend as Driver
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/from-wrap.bend as Wrapped

def array(value: R.Value) -> Nat:
  match value:
    case R.ArrayReference{id}: id
    case _: 0n

type Outcome is Data:
  Outcome{value: R.Slot, returns: Nat, closed: Bool, pending: List<&2, Nat>, inner: R.AsyncSettlement, pull: R.AsyncSettlement, fault: R.Fault}

def outcome(+machine: C.Machine) -> Outcome:
  +w = C.world(machine)
  +id = array(B.get(R.Value, C.values(machine), 0n, R.Undefined{}))
  +s = Wrapped.get(w, 3n)
  Outcome{B.get(R.Slot, R.ArrayData.slots(B.get(R.ArrayData, R.World.arrays(w), id, R.ArrayData{[]})), 0n, R.Empty{}), R.ExternalIterator.returns(B.iterator(w, 1n)), R.FromWrapped.closed(s), R.FromWrapped.pending(s), R.AsyncObject.state(B.asyncObject(w, 1n)), R.AsyncObject.state(B.asyncObject(w, 4n)), R.World.fault(w)}

def transport(-actual: C.Machine, -expected: C.Machine, e: {actual == expected : C.Machine}) ->
  {outcome(actual) == outcome(expected) : Outcome}:
  Equal.cong(C.Machine, Outcome, m => outcome(m), actual, expected, e)

def result(+input: Payload.Ordinary, +extra: Nat) ->
  {outcome(C.run(Nat.add(84n, extra), Driver.before(input))) == Outcome{R.Present{Payload.value(input)}, 1n, True{}, [], R.Unresolved{}, R.Fulfilled{R.StepResult{True{}, R.Undefined{}}}, R.Healthy{}} : Outcome}:
  transport(C.run(Nat.add(84n, extra), Driver.before(input)), Program.state_84(input), Program.complete(input, extra))
