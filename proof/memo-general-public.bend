# Complete public scalar-memo program: all natural initial/proposed values,
# constructor budgets >= 14 and drain budgets >= 40. Fixed graph, equals:false.
# No runtime rewrite, arbitrary-graph result or TypeScript equivalence claim.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/records.bend as R
import ./memo-driver.bend as Driver
import ./memo-initial-driver.bend as ConstructorDriver
import ./memo-constructor-cuts.bend as ConstructorCuts
import ./memo-general-setter.bend as Setter
import ./memo-general-setter-data.bend as SetterData
import ./memo-general-states.bend as M
import ./memo-general-staging.bend as Drain
import ./memo-public-program.bend as Transport

def staged_shape(+initial: Nat, +input: Nat) ->
  {SetterData.scheduled(initial, input) == C.world(M.state_0(initial, input)) : R.World}:
  {==}

def staged(+initial: Nat, +input: Nat, +constructorExtra: Nat) ->
  {A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), ConstructorDriver.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{input}) == C.world(M.state_0(initial, input)) : R.World}:
  Equal.trans(R.World,
    A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), ConstructorDriver.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{input}),
    SetterData.scheduled(initial, input), C.world(M.state_0(initial, input)), Setter.public_program(initial, input, constructorExtra), staged_shape(initial, input))

def complete(+initial: Nat, +input: Nat, +constructorExtra: Nat, +drainExtra: Nat) ->
  {Driver.view(A.flush(Nat.add(40n, drainExtra), A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), ConstructorDriver.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{input}))) == Driver.expected(input) : Driver.View}:
  Transport.flush_view(Nat.add(40n, drainExtra),
    A.setSignal(A.createMemo(Nat.add(14n, constructorExtra), ConstructorDriver.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{input}), C.world(M.state_0(initial, input)), Driver.expected(input),
    staged(initial, input, constructorExtra), Drain.every_staged_input(initial, input, drainExtra))
