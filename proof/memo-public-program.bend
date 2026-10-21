import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/records.bend as R
import ./memo-states.bend as M
import ./memo-driver.bend as Driver
import ./memo-staging.bend as Existing
import ./memo-constructor.bend as Constructor
import ./memo-setter.bend as Setter

def set_transport(+a: R.World, +b: R.World, +id: Nat, +value: R.Value, e: {a == b : R.World}) ->
  {A.setSignal(a, id, value) == A.setSignal(b, id, value) : R.World}:
  Equal.cong(R.World, R.World, world => A.setSignal(world, id, value), a, b, e)

def constructed_setter(+input: Nat) ->
  {A.setSignal(Driver.base(), 2n, R.Number{input}) == C.world(M.state_0(input)) : R.World}:
  Equal.trans(R.World, A.setSignal(Driver.base(), 2n, R.Number{input}), A.setSignal(M.origin(), 2n, R.Number{input}), C.world(M.state_0(input)),
    set_transport(Driver.base(), M.origin(), 2n, R.Number{input}, Constructor.constructor_eq()), Setter.public_setter(input))

def flush_view(+fuel: Nat, +a: R.World, +b: R.World, +view: Driver.View,
  e: {a == b : R.World}, result: {Driver.view(A.flush(fuel, b)) == view : Driver.View}) ->
  {Driver.view(A.flush(fuel, a)) == view : Driver.View}:
  Equal.trans(Driver.View, Driver.view(A.flush(fuel, a)), Driver.view(A.flush(fuel, b)), view,
    Equal.cong(R.World, Driver.View, world => Driver.view(A.flush(fuel, world)), a, b, e), result)

def public_program(+input: Nat, +extra: Nat) ->
  {Driver.view(A.flush(Nat.add(40n, extra), A.setSignal(Driver.base(), 2n, R.Number{input}))) == Driver.expected(input) : Driver.View}:
  flush_view(Nat.add(40n, extra), A.setSignal(Driver.base(), 2n, R.Number{input}), C.world(M.state_0(input)), Driver.expected(input), constructed_setter(input), Existing.every_staged_input(input, extra))
