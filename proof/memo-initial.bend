import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-driver.bend as Driver
import ./paths.bend as P
import ./memo-staging.bend as Existing
import ./memo-initial-data.bend as D
import ./memo-initial-steps.bend as Steps
import ./memo-constructor-cuts.bend as Cuts
import ./memo-initial-driver.bend as CD

def initial_shape(+initial: Nat) -> {Cuts.prepare(CD.signal(initial)) == D.state_0(initial) : C.Machine}:
  {==}

def final_shape(+initial: Nat) -> {Cuts.restore(CD.signal(initial), C.world(D.state_14(initial))) == D.finished(initial) : R.World}:
  {==}

def witness(+initial: Nat) -> P.Path<D.state_0(initial), D.state_14(initial)>:
  P.PathStep{D.state_1(initial), Steps.step_0(initial), P.PathStep{D.state_2(initial), Steps.step_1(initial), P.PathStep{D.state_3(initial), Steps.step_2(initial), P.PathStep{D.state_4(initial), Steps.step_3(initial), P.PathStep{D.state_5(initial), Steps.step_4(initial), P.PathStep{D.state_6(initial), Steps.step_5(initial), P.PathStep{D.state_7(initial), Steps.step_6(initial), P.PathStep{D.state_8(initial), Steps.step_7(initial), P.PathStep{D.state_9(initial), Steps.step_8(initial), P.PathStep{D.state_10(initial), Steps.step_9(initial), P.PathStep{D.state_11(initial), Steps.step_10(initial), P.PathStep{D.state_12(initial), Steps.step_11(initial), P.PathStep{D.state_13(initial), Steps.step_12(initial), P.PathStep{D.state_14(initial), Steps.step_13(initial), P.PathEnd{C.world(D.state_14(initial)), [], {==}, {==}}}}}}}}}}}}}}}}



def completed(+initial: Nat, +extra: Nat) -> {C.run(Nat.add(14n, extra), D.state_0(initial)) == D.state_14(initial) : C.Machine}:
  Existing.retimed(D.state_0(initial), D.state_14(initial), witness(initial), extra, Nat.add(14n, extra), {==})

def program(+initial: Nat, extra: Nat) -> R.World:
  A.createMemo(Nat.add(14n, extra), CD.signal(initial), Cuts.expr(), False{}, False{}, 1n)

def constructed(+initial: Nat, +extra: Nat) -> {A.createMemo(Nat.add(14n, extra), CD.signal(initial), Cuts.expr(), False{}, False{}, 1n) == D.finished(initial) : R.World}:
  Cuts.completed(Nat.add(14n, extra), CD.signal(initial), D.state_0(initial), D.state_14(initial), D.finished(initial), initial_shape(initial), completed(initial, extra), final_shape(initial))


def observe(+actual: R.World, +canonical: R.World, +expected: Driver.View,
  reached: {actual == canonical : R.World}, projected: {Driver.view(canonical) == expected : Driver.View}) ->
  {Driver.view(actual) == expected : Driver.View}:
  Equal.trans(Driver.View, Driver.view(actual), Driver.view(canonical), expected, Equal.cong(R.World, Driver.View, world => Driver.view(world), actual, canonical, reached), projected)

def all_initials(+initial: Nat, +extra: Nat) -> {Driver.view(A.createMemo(Nat.add(14n, extra), CD.signal(initial), Cuts.expr(), False{}, False{}, 1n)) == Driver.expected(initial) : Driver.View}:
  observe(A.createMemo(Nat.add(14n, extra), CD.signal(initial), Cuts.expr(), False{}, False{}, 1n), D.finished(initial), Driver.expected(initial), constructed(initial, extra), {==})
