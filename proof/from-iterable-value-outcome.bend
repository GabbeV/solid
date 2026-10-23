# Arbitrary represented payload, exact cancellation result. Tokens are carried
# as data; validity of arbitrary arena references is a separate question.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ./from-iterable-value-driver.bend as Driver
import ./from-iterable-value-program.bend as Program
import ./from-iterable-outcome.bend as Outcome

def result(+input: R.Value, +extra: Nat) ->
  {Outcome.outcome(C.run(Nat.add(84n, extra), Driver.before(input))) == Outcome.Outcome{R.Present{input}, 1n, True{}, [], R.Unresolved{}, R.Fulfilled{R.StepResult{True{}, R.Undefined{}}}, R.Healthy{}} : Outcome.Outcome}:
  Outcome.transport(C.run(Nat.add(84n, extra), Driver.before(input)), Program.state_84(input), Program.complete(input, extra))
