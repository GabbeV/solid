# The broader theorems begin at the same actual constructor inputs as the
# preceding ordinary-data families. No theorem domain or budget is removed.
import Base
import ./ordinary-payload.bend as Payload
import ./from-driver.bend as Ordinary
import ./from-value-driver.bend as Value
import ./from-iterable-driver.bend as IterableOrdinary
import ./from-iterable-value-driver.bend as IterableValue
import ../runtime/core.bend as C

def subscription(input: Payload.Ordinary) ->
  {Value.before(Payload.value(input)) == Ordinary.before(input) : C.Machine}:
  {==}

def iterable(input: Payload.Ordinary) ->
  {IterableValue.before(Payload.value(input)) == IterableOrdinary.before(input) : C.Machine}:
  {==}
