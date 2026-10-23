# Exact payload/cleanup result for every R.Value, independent of its data kind.
# This does not assert that every arena-dependent token is a valid JS input.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./from-value-driver.bend as Driver
import ./from-value-program.bend as Program
import ./from-outcome.bend as Outcome

def result(+input: R.Value, +extra: Nat) ->
  {Outcome.outcome(C.run(Nat.add(120n, extra), Driver.before(input))) == Outcome.Outcome{R.Present{input}, 1n, R.Healthy{}} : Outcome.Outcome}:
  Outcome.transport(C.run(Nat.add(120n, extra), Driver.before(input)), Program.state_120(input), Program.complete(input, extra))
