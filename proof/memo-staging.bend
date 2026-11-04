# Forty transitions of the actual core.step, checked for every numeric proposal.
# Algebraic helper cuts avoid kernel expansion; the public constructor/setter
# bridge is deliberately excluded from the conditional theorem below.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../proof/paths.bend as P
import ./memo-driver.bend as Driver
import ../runtime/owner.bend as O
import ../runtime/pending.bend as Q

import ./memo-states.bend as M
import ./memo-cuts.bend as Cuts
import ./deferred-read-cut.bend as ReadCut
import ./natural-netted-value.bend as Natural

def remainder(m: C.Machine) -> List<&2, C.Task>:
  match m:
    case C.Machine{w, tasks, stack}:
      match tasks:
        case Nil{}:
          []
        case h <> tail:
          tail


def stepAt_0(+netted: Bool, +input: Nat) -> {C.step(M.at_0(netted, input)) == M.at_1(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_0(+input: Nat) -> {C.step(M.state_0(input)) == M.state_1(input) : C.Machine}:
  stepAt_0(Nat.is_eq(input, 0n), input)

def stepAt_1(+netted: Bool, +input: Nat) -> {C.step(M.at_1(netted, input)) == M.at_2(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_1(+input: Nat) -> {C.step(M.state_1(input)) == M.state_2(input) : C.Machine}:
  stepAt_1(Nat.is_eq(input, 0n), input)

def stepAt_2(+netted: Bool, +input: Nat) -> {C.step(M.at_2(netted, input)) == M.at_3(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_2(+input: Nat) -> {C.step(M.state_2(input)) == M.state_3(input) : C.Machine}:
  stepAt_2(Nat.is_eq(input, 0n), input)

def stepAt_3(+netted: Bool, +input: Nat) -> {C.step(M.at_3(netted, input)) == M.at_4(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_3(+input: Nat) -> {C.step(M.state_3(input)) == M.state_4(input) : C.Machine}:
  stepAt_3(Nat.is_eq(input, 0n), input)

def stepAt_4(+netted: Bool, +input: Nat) -> {C.step(M.at_4(netted, input)) == M.at_5(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_4(+input: Nat) -> {C.step(M.state_4(input)) == M.state_5(input) : C.Machine}:
  stepAt_4(Nat.is_eq(input, 0n), input)

def stepAt_5(+netted: Bool, +input: Nat) -> {C.step(M.at_5(netted, input)) == M.at_6(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_5(+input: Nat) -> {C.step(M.state_5(input)) == M.state_6(input) : C.Machine}:
  stepAt_5(Nat.is_eq(input, 0n), input)

def stepAt_6(+netted: Bool, +input: Nat) -> {C.step(M.at_6(netted, input)) == M.at_7(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_6(+input: Nat) -> {C.step(M.state_6(input)) == M.state_7(input) : C.Machine}:
  stepAt_6(Nat.is_eq(input, 0n), input)

def stepAt_7(+netted: Bool, +input: Nat) -> {C.step(M.at_7(netted, input)) == M.at_8(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_7(+input: Nat) -> {C.step(M.state_7(input)) == M.state_8(input) : C.Machine}:
  stepAt_7(Nat.is_eq(input, 0n), input)

def stepAt_8(+netted: Bool, +input: Nat) -> {C.step(M.at_8(netted, input)) == M.at_9(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_8(+input: Nat) -> {C.step(M.state_8(input)) == M.state_9(input) : C.Machine}:
  stepAt_8(Nat.is_eq(input, 0n), input)

def readAt(+netted: Bool, +input: Nat) -> C.Machine:
  ReadCut.read(C.world(M.at_9(netted, input)), remainder(M.at_9(netted, input)), C.values(M.at_9(netted, input)), 2n, netted)

def readExpected(+netted: Bool, +input: Nat,value: R.Value) -> C.Machine:
  +w = R.World.with_events(C.world(M.at_10(netted, input)),R.World.events(C.world(M.at_9(netted, input))))
  C.served(w,remainder(M.at_9(netted, input)),C.values(M.at_9(netted, input)),3n,2n,value)

def readCase(+netted: Bool, +input: Nat) -> {readAt(netted, input) == readExpected(netted, input, B.choose(~R.Value,netted,_=>R.Number{0n},_=>R.Number{input})) : C.Machine}:
  match netted:
    case True{}: {==}
    case False{}: {==}

def step_9(+input: Nat) -> {C.step(M.state_9(input)) == M.state_10(input) : C.Machine}:
  +netted = Nat.is_eq(input, 0n)
  +answer = B.choose(~R.Value,netted,_=>R.Number{0n},_=>R.Number{input})
  Equal.trans(C.Machine,C.step(M.state_9(input)),readExpected(netted, input,answer),M.state_10(input),Equal.trans(C.Machine,C.step(M.state_9(input)),readAt(netted, input),readExpected(netted, input,answer),{==},readCase(netted, input)),Equal.cong(R.Value,C.Machine,value=>readExpected(netted, input,value),answer,R.Number{input},Natural.pick(0n,input)))

def stepAt_10(+netted: Bool, +input: Nat) -> {C.step(M.at_10(netted, input)) == M.at_11(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_10(+input: Nat) -> {C.step(M.state_10(input)) == M.state_11(input) : C.Machine}:
  stepAt_10(Nat.is_eq(input, 0n), input)

def stepAt_11(+netted: Bool, +input: Nat) -> {C.step(M.at_11(netted, input)) == M.at_12(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_11(+input: Nat) -> {C.step(M.state_11(input)) == M.state_12(input) : C.Machine}:
  stepAt_11(Nat.is_eq(input, 0n), input)

def stepAt_12(+netted: Bool, +input: Nat) -> {C.step(M.at_12(netted, input)) == M.at_13(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_12(+input: Nat) -> {C.step(M.state_12(input)) == M.state_13(input) : C.Machine}:
  stepAt_12(Nat.is_eq(input, 0n), input)


def stepAt_13(+netted: Bool, +input: Nat) -> {C.step(M.at_13(netted, input)) == M.at_14(netted, input) : C.Machine}:
  match netted:
    case True{}:
      +w = C.world(M.at_13(True{}, input))
      +rest = remainder(M.at_13(True{}, input))
      +value = {R.Number{Nat.add(input, 1n)} : R.Value}
      +ending = {C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n} <> rest : List<&2, C.Task>}
      +a = C.passReleases(w, rest, [], Cuts.frame(), 0n, value, False{}, False{}, False{}, R.Healthy{})
      +b = Cuts.afterRelease(w, rest, [], value)
      +c = C.afterPass(w, rest, [], 3n, False{}, value, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{})
      +d = C.publishState(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{})
      +e = C.publicationCompleted(ending, [], 3n, R.Number{0n}, 0n, False{}, B.Bundle{C.world(M.at_14(True{}, input)), True{}})
      Equal.trans(C.Machine, C.step(M.at_13(True{}, input)), a, M.at_14(True{}, input),
        Cuts.step_from_shape(M.at_13(True{}, input), w, rest, [], value, {==}, {==}),
        Equal.trans(C.Machine, a, b, M.at_14(True{}, input), Cuts.release_empty(w, rest, [], value, {==}),
          Equal.trans(C.Machine, b, c, M.at_14(True{}, input), Cuts.after_release_identity(w, rest, [], value, {==}, {==}),
            Equal.trans(C.Machine, c, d, M.at_14(True{}, input), Cuts.after_pass_live(w, rest, [], value, {==}, {==}, {==}),
              Equal.trans(C.Machine, d, e, M.at_14(True{}, input),
                Cuts.default_publish(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, B.Bundle{C.world(M.at_14(True{}, input)), True{}}, {==}, {==}, {==}, M.publicationAt_13(True{}, input)),
                {==})))))
    case False{}:
      +w = C.world(M.at_13(False{}, input))
      +rest = remainder(M.at_13(False{}, input))
      +value = {R.Number{Nat.add(input, 1n)} : R.Value}
      +ending = {C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n} <> rest : List<&2, C.Task>}
      +a = C.passReleases(w, rest, [], Cuts.frame(), 0n, value, False{}, False{}, False{}, R.Healthy{})
      +b = Cuts.afterRelease(w, rest, [], value)
      +c = C.afterPass(w, rest, [], 3n, False{}, value, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{})
      +d = C.publishState(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{})
      +e = C.publicationCompleted(ending, [], 3n, R.Number{0n}, 0n, False{}, B.Bundle{C.world(M.at_14(False{}, input)), True{}})
      Equal.trans(C.Machine, C.step(M.at_13(False{}, input)), a, M.at_14(False{}, input),
        Cuts.step_from_shape(M.at_13(False{}, input), w, rest, [], value, {==}, {==}),
        Equal.trans(C.Machine, a, b, M.at_14(False{}, input), Cuts.release_empty(w, rest, [], value, {==}),
          Equal.trans(C.Machine, b, c, M.at_14(False{}, input), Cuts.after_release_identity(w, rest, [], value, {==}, {==}),
            Equal.trans(C.Machine, c, d, M.at_14(False{}, input), Cuts.after_pass_live(w, rest, [], value, {==}, {==}, {==}),
              Equal.trans(C.Machine, d, e, M.at_14(False{}, input),
                Cuts.default_publish(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, B.Bundle{C.world(M.at_14(False{}, input)), True{}}, {==}, {==}, {==}, M.publicationAt_13(False{}, input)),
                {==})))))

def step_13(+input: Nat) -> {C.step(M.state_13(input)) == M.state_14(input) : C.Machine}:
  stepAt_13(Nat.is_eq(input, 0n), input)

def stepAt_14(+netted: Bool, +input: Nat) -> {C.step(M.at_14(netted, input)) == M.at_15(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_14(+input: Nat) -> {C.step(M.state_14(input)) == M.state_15(input) : C.Machine}:
  stepAt_14(Nat.is_eq(input, 0n), input)

def stepAt_15(+netted: Bool, +input: Nat) -> {C.step(M.at_15(netted, input)) == M.at_16(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_15(+input: Nat) -> {C.step(M.state_15(input)) == M.state_16(input) : C.Machine}:
  stepAt_15(Nat.is_eq(input, 0n), input)

def stepAt_16(+netted: Bool, +input: Nat) -> {C.step(M.at_16(netted, input)) == M.at_17(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_16(+input: Nat) -> {C.step(M.state_16(input)) == M.state_17(input) : C.Machine}:
  stepAt_16(Nat.is_eq(input, 0n), input)

def stepAt_17(+netted: Bool, +input: Nat) -> {C.step(M.at_17(netted, input)) == M.at_18(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_17(+input: Nat) -> {C.step(M.state_17(input)) == M.state_18(input) : C.Machine}:
  stepAt_17(Nat.is_eq(input, 0n), input)

def stepAt_18(+netted: Bool, +input: Nat) -> {C.step(M.at_18(netted, input)) == M.at_19(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_18(+input: Nat) -> {C.step(M.state_18(input)) == M.state_19(input) : C.Machine}:
  stepAt_18(Nat.is_eq(input, 0n), input)

def stepAt_19(+netted: Bool, +input: Nat) -> {C.step(M.at_19(netted, input)) == M.at_20(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_19(+input: Nat) -> {C.step(M.state_19(input)) == M.state_20(input) : C.Machine}:
  stepAt_19(Nat.is_eq(input, 0n), input)

def stepAt_20(+netted: Bool, +input: Nat) -> {C.step(M.at_20(netted, input)) == M.at_21(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_20(+input: Nat) -> {C.step(M.state_20(input)) == M.state_21(input) : C.Machine}:
  stepAt_20(Nat.is_eq(input, 0n), input)

def stepAt_21(+netted: Bool, +input: Nat) -> {C.step(M.at_21(netted, input)) == M.at_22(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_21(+input: Nat) -> {C.step(M.state_21(input)) == M.state_22(input) : C.Machine}:
  stepAt_21(Nat.is_eq(input, 0n), input)

def stepAt_22(+netted: Bool, +input: Nat) -> {C.step(M.at_22(netted, input)) == M.at_23(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_22(+input: Nat) -> {C.step(M.state_22(input)) == M.state_23(input) : C.Machine}:
  stepAt_22(Nat.is_eq(input, 0n), input)

def stepAt_23(+netted: Bool, +input: Nat) -> {C.step(M.at_23(netted, input)) == M.at_24(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_23(+input: Nat) -> {C.step(M.state_23(input)) == M.state_24(input) : C.Machine}:
  stepAt_23(Nat.is_eq(input, 0n), input)

def stepAt_24(+netted: Bool, +input: Nat) -> {C.step(M.at_24(netted, input)) == M.at_25(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_24(+input: Nat) -> {C.step(M.state_24(input)) == M.state_25(input) : C.Machine}:
  stepAt_24(Nat.is_eq(input, 0n), input)

def stepAt_25(+netted: Bool, +input: Nat) -> {C.step(M.at_25(netted, input)) == M.at_26(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_25(+input: Nat) -> {C.step(M.state_25(input)) == M.state_26(input) : C.Machine}:
  stepAt_25(Nat.is_eq(input, 0n), input)

def stepAt_26(+netted: Bool, +input: Nat) -> {C.step(M.at_26(netted, input)) == M.at_27(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_26(+input: Nat) -> {C.step(M.state_26(input)) == M.state_27(input) : C.Machine}:
  stepAt_26(Nat.is_eq(input, 0n), input)

def stepAt_27(+netted: Bool, +input: Nat) -> {C.step(M.at_27(netted, input)) == M.at_28(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_27(+input: Nat) -> {C.step(M.state_27(input)) == M.state_28(input) : C.Machine}:
  stepAt_27(Nat.is_eq(input, 0n), input)

def stepAt_28(+netted: Bool, +input: Nat) -> {C.step(M.at_28(netted, input)) == M.at_29(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_28(+input: Nat) -> {C.step(M.state_28(input)) == M.state_29(input) : C.Machine}:
  stepAt_28(Nat.is_eq(input, 0n), input)

def stepAt_29(+netted: Bool, +input: Nat) -> {C.step(M.at_29(netted, input)) == M.at_30(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_29(+input: Nat) -> {C.step(M.state_29(input)) == M.state_30(input) : C.Machine}:
  stepAt_29(Nat.is_eq(input, 0n), input)

def stepAt_30(+netted: Bool, +input: Nat) -> {C.step(M.at_30(netted, input)) == M.at_31(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_30(+input: Nat) -> {C.step(M.state_30(input)) == M.state_31(input) : C.Machine}:
  stepAt_30(Nat.is_eq(input, 0n), input)

def stepAt_31(+netted: Bool, +input: Nat) -> {C.step(M.at_31(netted, input)) == M.at_32(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_31(+input: Nat) -> {C.step(M.state_31(input)) == M.state_32(input) : C.Machine}:
  stepAt_31(Nat.is_eq(input, 0n), input)

def stepAt_32(+netted: Bool, +input: Nat) -> {C.step(M.at_32(netted, input)) == M.at_33(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_32(+input: Nat) -> {C.step(M.state_32(input)) == M.state_33(input) : C.Machine}:
  stepAt_32(Nat.is_eq(input, 0n), input)

def stepAt_33(+netted: Bool, +input: Nat) -> {C.step(M.at_33(netted, input)) == M.at_34(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_33(+input: Nat) -> {C.step(M.state_33(input)) == M.state_34(input) : C.Machine}:
  stepAt_33(Nat.is_eq(input, 0n), input)

def stepAt_34(+netted: Bool, +input: Nat) -> {C.step(M.at_34(netted, input)) == M.at_35(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_34(+input: Nat) -> {C.step(M.state_34(input)) == M.state_35(input) : C.Machine}:
  stepAt_34(Nat.is_eq(input, 0n), input)

def stepAt_35(+netted: Bool, +input: Nat) -> {C.step(M.at_35(netted, input)) == M.at_36(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_35(+input: Nat) -> {C.step(M.state_35(input)) == M.state_36(input) : C.Machine}:
  stepAt_35(Nat.is_eq(input, 0n), input)

def stepAt_36(+netted: Bool, +input: Nat) -> {C.step(M.at_36(netted, input)) == M.at_37(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_36(+input: Nat) -> {C.step(M.state_36(input)) == M.state_37(input) : C.Machine}:
  stepAt_36(Nat.is_eq(input, 0n), input)

def stepAt_37(+netted: Bool, +input: Nat) -> {C.step(M.at_37(netted, input)) == M.at_38(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_37(+input: Nat) -> {C.step(M.state_37(input)) == M.state_38(input) : C.Machine}:
  stepAt_37(Nat.is_eq(input, 0n), input)

def stepAt_38(+netted: Bool, +input: Nat) -> {C.step(M.at_38(netted, input)) == M.at_39(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_38(+input: Nat) -> {C.step(M.state_38(input)) == M.state_39(input) : C.Machine}:
  stepAt_38(Nat.is_eq(input, 0n), input)

def stepAt_39(+netted: Bool, +input: Nat) -> {C.step(M.at_39(netted, input)) == M.at_40(netted, input) : C.Machine}:
  match netted:
    case True{}:
      {==}
    case False{}:
      {==}

def step_39(+input: Nat) -> {C.step(M.state_39(input)) == M.state_40(input) : C.Machine}:
  stepAt_39(Nat.is_eq(input, 0n), input)

def witness(+input: Nat) -> P.Path<M.state_0(input), M.state_40(input)>:
  P.PathStep{M.state_1(input), step_0(input), P.PathStep{M.state_2(input), step_1(input), P.PathStep{M.state_3(input), step_2(input), P.PathStep{M.state_4(input), step_3(input), P.PathStep{M.state_5(input), step_4(input), P.PathStep{M.state_6(input), step_5(input), P.PathStep{M.state_7(input), step_6(input), P.PathStep{M.state_8(input), step_7(input), P.PathStep{M.state_9(input), step_8(input), P.PathStep{M.state_10(input), step_9(input), P.PathStep{M.state_11(input), step_10(input), P.PathStep{M.state_12(input), step_11(input), P.PathStep{M.state_13(input), step_12(input), P.PathStep{M.state_14(input), step_13(input), P.PathStep{M.state_15(input), step_14(input), P.PathStep{M.state_16(input), step_15(input), P.PathStep{M.state_17(input), step_16(input), P.PathStep{M.state_18(input), step_17(input), P.PathStep{M.state_19(input), step_18(input), P.PathStep{M.state_20(input), step_19(input), P.PathStep{M.state_21(input), step_20(input), P.PathStep{M.state_22(input), step_21(input), P.PathStep{M.state_23(input), step_22(input), P.PathStep{M.state_24(input), step_23(input), P.PathStep{M.state_25(input), step_24(input), P.PathStep{M.state_26(input), step_25(input), P.PathStep{M.state_27(input), step_26(input), P.PathStep{M.state_28(input), step_27(input), P.PathStep{M.state_29(input), step_28(input), P.PathStep{M.state_30(input), step_29(input), P.PathStep{M.state_31(input), step_30(input), P.PathStep{M.state_32(input), step_31(input), P.PathStep{M.state_33(input), step_32(input), P.PathStep{M.state_34(input), step_33(input), P.PathStep{M.state_35(input), step_34(input), P.PathStep{M.state_36(input), step_35(input), P.PathStep{M.state_37(input), step_36(input), P.PathStep{M.state_38(input), step_37(input), P.PathStep{M.state_39(input), step_38(input), P.PathStep{M.state_40(input), step_39(input), P.PathEnd{M.finalWorld(input), [], {==}, {==}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}


# This theorem starts at the explicit staged arena. The public setter bridge is
# is established separately by memo-public-program; this local drain theorem
# retains its explicit staged-arena precondition.
def retimed(+start: C.Machine, -end: C.Machine, +path: P.Path<start, end>, +extra: Nat, +fuel: Nat,
  lengthEq: {Nat.add(P.length(start, end, path), extra) == fuel : Nat}) ->
  {C.run(fuel, start) == end : C.Machine}:
  Equal.trans(C.Machine, C.run(fuel, start), C.run(Nat.add(P.length(start, end, path), extra), start), end,
    P.fuel_transport(fuel, Nat.add(P.length(start, end, path), extra), start,
      Equal.sym(Nat, Nat.add(P.length(start, end, path), extra), fuel, lengthEq)),
    P.realizes(start, end, path, extra, start, {==}))

def flush_eq(+input: Nat, +extra: Nat) -> {A.flush(Nat.add(40n, extra), C.world(M.state_0(input))) == C.world(M.state_40(input)) : R.World}:
  Cuts.flush_from_shape(Nat.add(40n, extra), C.world(M.state_0(input)), M.state_0(input), M.state_40(input), {==}, {==},
    retimed(M.state_0(input), M.state_40(input), witness(input), extra, Nat.add(40n, extra), {==}))

def viewTransport(-a: R.World, -b: R.World, e: {a == b : R.World}) -> {Driver.view(a) == Driver.view(b) : Driver.View}:
  %e : {Driver.view(a) == Driver.view(_) : Driver.View}
  {==}

law every_staged_input:
  for +value: Nat
  for extra: Nat
  {Driver.view(A.flush(Nat.add(40n, extra), C.world(M.state_0(value)))) == Driver.expected(value) : Driver.View}

def every_staged_input(value, extra):
  viewTransport(A.flush(Nat.add(40n, extra), C.world(M.state_0(value))), C.world(M.state_40(value)), flush_eq(value, extra))
