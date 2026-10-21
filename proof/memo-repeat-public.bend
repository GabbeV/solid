# Two actual public updates, arbitrary initial/first/second natural values
# constructor budgets >= 14 and independent drain budgets >= 40.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/records.bend as R
import ./memo-driver.bend as Driver
import ./memo-initial-driver.bend as Constructor
import ./memo-constructor-cuts.bend as ConstructorCuts
import ./memo-general-states.bend as FirstStates
import ./memo-general-staging.bend as FirstDrain
import ./memo-general-public.bend as FirstPublic
import ./memo-public-program.bend as FirstSet
import ./chain-public-program.bend as Transport
import ./memo-repeat-states.bend as M
import ./memo-repeat-setter.bend as Setter
import ./memo-repeat-staging.bend as Drain
import ./memo-repeat-setter-data.bend as SetData

def first_shape(+initial: Nat, +first: Nat) -> {C.world(FirstStates.state_40(initial, first)) == M.origin(initial, first) : R.World}:
  {==}

def flush_identified(+fuel: Nat, +a: R.World, +b: R.World, +end: R.World, +identified: R.World,
  staged: {a == b : R.World}, drained: {A.flush(fuel, b) == end : R.World}, shape: {end == identified : R.World}) ->
  {A.flush(fuel, a) == identified : R.World}:
  Equal.trans(R.World, A.flush(fuel, a), end, identified, Transport.flush_completed(fuel, a, b, end, staged, drained), shape)

def first_completed(+initial: Nat, +first: Nat, +constructorExtra: Nat, +firstExtra: Nat) -> {A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})) == M.origin(initial, first) : R.World}:
  flush_identified(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first}), C.world(FirstStates.state_0(initial, first)), C.world(FirstStates.state_40(initial, first)), M.origin(initial, first), FirstPublic.staged(initial, first, constructorExtra), FirstDrain.flush_eq(initial, first, firstExtra), first_shape(initial, first))

def second_shape(+initial: Nat, +first: Nat, +input: Nat) -> {SetData.scheduled(initial, first, input) == C.world(M.state_0(initial, first, input)) : R.World}:
  {==}

def second_staged(+initial: Nat, +first: Nat, +input: Nat) -> {A.setSignal(M.origin(initial, first), 2n, R.Number{input}) == C.world(M.state_0(initial, first, input)) : R.World}:
  Equal.trans(R.World, A.setSignal(M.origin(initial, first), 2n, R.Number{input}), SetData.scheduled(initial, first, input), C.world(M.state_0(initial, first, input)), Setter.public_setter(initial, first, input), second_shape(initial, first, input))

def public_staged(+initial: Nat, +first: Nat, +input: Nat, +constructorExtra: Nat, +firstExtra: Nat) -> {A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})), 2n, R.Number{input}) == C.world(M.state_0(initial, first, input)) : R.World}:
  Equal.trans(R.World, A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})), 2n, R.Number{input}), A.setSignal(M.origin(initial, first), 2n, R.Number{input}), C.world(M.state_0(initial, first, input)),
    FirstSet.set_transport(A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})), M.origin(initial, first), 2n, R.Number{input}, first_completed(initial, first, constructorExtra, firstExtra)), second_staged(initial, first, input))

def world(+initial: Nat, +first: Nat, +input: Nat, +constructorExtra: Nat, +firstExtra: Nat, +secondExtra: Nat) -> {A.flush(Nat.add(40n, secondExtra), A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})), 2n, R.Number{input})) == M.finalWorld(initial, first, input) : R.World}:
  Transport.flush_completed(Nat.add(40n, secondExtra), A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})), 2n, R.Number{input}), C.world(M.state_0(initial, first, input)), M.finalWorld(initial, first, input), public_staged(initial, first, input, constructorExtra, firstExtra), Drain.flush_eq(initial, first, input, secondExtra))

def complete(+initial: Nat, +first: Nat, +input: Nat, +constructorExtra: Nat, +firstExtra: Nat, +secondExtra: Nat) -> {Driver.view(A.flush(Nat.add(40n, secondExtra), A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})), 2n, R.Number{input}))) == Driver.expected(input) : Driver.View}:
  Drain.viewTransport(A.flush(Nat.add(40n, secondExtra), A.setSignal(A.flush(Nat.add(40n, firstExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), Constructor.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{first})), 2n, R.Number{input})), M.finalWorld(initial, first, input), world(initial, first, input, constructorExtra, firstExtra, secondExtra))
