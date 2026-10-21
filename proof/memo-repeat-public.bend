# Two actual public updates, arbitrary first/second proposals and both drain
# budgets >= 40. The fixed graph begins at zero, with equals:false.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/records.bend as R
import ./memo-driver.bend as Driver
import ./memo-states.bend as FirstStates
import ./memo-staging.bend as FirstDrain
import ./memo-public-program.bend as FirstPublic
import ./chain-public-program.bend as Transport
import ./memo-repeat-states.bend as M
import ./memo-repeat-setter.bend as Setter
import ./memo-repeat-staging.bend as Drain
import ./memo-repeat-setter-data.bend as SetData

def firstWorld(+input: Nat, +extra: Nat) -> R.World:
  A.flush(Nat.add(40n, extra), A.setSignal(Driver.base(), 2n, R.Number{input}))

def program(+first: Nat, +input: Nat, firstExtra: Nat, secondExtra: Nat) -> R.World:
  A.flush(Nat.add(40n, secondExtra), A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(Driver.base(), 2n, R.Number{first})), 2n, R.Number{input}))

def first_shape(+input: Nat) -> {C.world(FirstStates.state_40(input)) == M.origin(input) : R.World}:
  {==}

# Keep composition abstract while the kernel checks each concrete boundary.
def flush_identified(+fuel: Nat, +a: R.World, +b: R.World, +end: R.World, +identified: R.World,
  staged: {a == b : R.World}, drained: {A.flush(fuel, b) == end : R.World}, shape: {end == identified : R.World}) ->
  {A.flush(fuel, a) == identified : R.World}:
  Equal.trans(R.World, A.flush(fuel, a), end, identified, Transport.flush_completed(fuel, a, b, end, staged, drained), shape)

def first_completed(+input: Nat, +extra: Nat) -> {A.flush(Nat.add(40n, extra), A.setSignal(Driver.base(), 2n, R.Number{input})) == M.origin(input) : R.World}:
  flush_identified(Nat.add(40n, extra), A.setSignal(Driver.base(), 2n, R.Number{input}), C.world(FirstStates.state_0(input)), C.world(FirstStates.state_40(input)), M.origin(input), FirstPublic.constructed_setter(input), FirstDrain.flush_eq(input, extra), first_shape(input))

def second_shape(+first: Nat, +input: Nat) -> {SetData.scheduled(first, input) == C.world(M.state_0(first, input)) : R.World}:
  {==}

def second_staged(+first: Nat, +input: Nat) -> {A.setSignal(M.origin(first), 2n, R.Number{input}) == C.world(M.state_0(first, input)) : R.World}:
  Equal.trans(R.World, A.setSignal(M.origin(first), 2n, R.Number{input}), SetData.scheduled(first, input), C.world(M.state_0(first, input)), Setter.public_setter(first, input), second_shape(first, input))

def public_staged(+first: Nat, +input: Nat, +firstExtra: Nat) -> {A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(Driver.base(), 2n, R.Number{first})), 2n, R.Number{input}) == C.world(M.state_0(first, input)) : R.World}:
  Equal.trans(R.World, A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(Driver.base(), 2n, R.Number{first})), 2n, R.Number{input}), A.setSignal(M.origin(first), 2n, R.Number{input}), C.world(M.state_0(first, input)),
    FirstPublic.set_transport(A.flush(Nat.add(40n, firstExtra), A.setSignal(Driver.base(), 2n, R.Number{first})), M.origin(first), 2n, R.Number{input}, first_completed(first, firstExtra)), second_staged(first, input))

def world(+first: Nat, +input: Nat, +firstExtra: Nat, +secondExtra: Nat) -> {A.flush(Nat.add(40n, secondExtra), A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(Driver.base(), 2n, R.Number{first})), 2n, R.Number{input})) == M.finalWorld(first, input) : R.World}:
  Transport.flush_completed(Nat.add(40n, secondExtra), A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(Driver.base(), 2n, R.Number{first})), 2n, R.Number{input}), C.world(M.state_0(first, input)), M.finalWorld(first, input), public_staged(first, input, firstExtra), Drain.flush_eq(first, input, secondExtra))

def complete(+first: Nat, +input: Nat, +firstExtra: Nat, +secondExtra: Nat) -> {Driver.view(A.flush(Nat.add(40n, secondExtra), A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(Driver.base(), 2n, R.Number{first})), 2n, R.Number{input}))) == Driver.expected(input) : Driver.View}:
  Drain.viewTransport(A.flush(Nat.add(40n, secondExtra), A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(Driver.base(), 2n, R.Number{first})), 2n, R.Number{input})), M.finalWorld(first, input), world(first, input, firstExtra, secondExtra))
