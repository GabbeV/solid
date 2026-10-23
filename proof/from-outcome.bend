# Value and once-only resource-release corollary of the actual complete
# constructor/read/dispose/flush Machine family. The producer shape is fixed.
import Base
import ./ordinary-payload.bend as Payload
import ./from-program.bend as Program
import ./from-driver.bend as Driver
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C

def array(value: R.Value) -> Nat:
  match value:
    case R.ArrayReference{id}: id
    case _: 0n

def cleanup(event: R.TraceEvent) -> Nat:
  match event:
    case R.CleanupObserved{callback, code}:
      B.choose(~Nat, Bool.and(Nat.is_eq(callback, 2n), Nat.is_eq(code, 99n)), _ => 1n, _ => 0n)
    case _: 0n

def cleanups(events: List<&2, R.TraceEvent>) -> Nat:
  match events:
    case Nil{}: 0n
    case head <> tail: Nat.add(cleanup(head), cleanups(tail))

type Outcome is Data:
  Outcome{value: R.Slot, cleanups: Nat, fault: R.Fault}

def outcome(+machine: C.Machine) -> Outcome:
  +w = C.world(machine)
  +id = array(B.get(R.Value, C.values(machine), 0n, R.Undefined{}))
  Outcome{B.get(R.Slot, R.ArrayData.slots(B.get(R.ArrayData, R.World.arrays(w), id, R.ArrayData{[]})), 0n, R.Empty{}), cleanups(R.World.events(w)), R.World.fault(w)}

def transport(-actual: C.Machine, -expected: C.Machine, e: {actual == expected : C.Machine}) ->
  {outcome(actual) == outcome(expected) : Outcome}:
  Equal.cong(C.Machine, Outcome, m => outcome(m), actual, expected, e)

def result(+input: Payload.Ordinary, +extra: Nat) ->
  {outcome(C.run(Nat.add(120n, extra), Driver.before(input))) == Outcome{R.Present{Payload.value(input)}, 1n, R.Healthy{}} : Outcome}:
  transport(C.run(Nat.add(120n, extra), Driver.before(input)), Program.state_120(input), Program.complete(input, extra))
