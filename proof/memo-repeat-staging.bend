# Actual second-update transitions, quantified over first and second proposals.
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

import ./memo-repeat-states.bend as M
import ./memo-cuts.bend as Cuts
import ./memo-general-cuts.bend as GeneralCuts

def step_0(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_0(initial, first, input)) == M.state_1(initial, first, input) : C.Machine}:
  {==}

def step_1(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_1(initial, first, input)) == M.state_2(initial, first, input) : C.Machine}:
  {==}

def step_2(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_2(initial, first, input)) == M.state_3(initial, first, input) : C.Machine}:
  {==}

def step_3(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_3(initial, first, input)) == M.state_4(initial, first, input) : C.Machine}:
  {==}

def step_4(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_4(initial, first, input)) == M.state_5(initial, first, input) : C.Machine}:
  {==}

def step_5(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_5(initial, first, input)) == M.state_6(initial, first, input) : C.Machine}:
  {==}

def step_6(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_6(initial, first, input)) == M.state_7(initial, first, input) : C.Machine}:
  {==}

def step_7(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_7(initial, first, input)) == M.state_8(initial, first, input) : C.Machine}:
  {==}

def step_8(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_8(initial, first, input)) == M.state_9(initial, first, input) : C.Machine}:
  {==}

def step_9(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_9(initial, first, input)) == M.state_10(initial, first, input) : C.Machine}:
  {==}

def step_10(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_10(initial, first, input)) == M.state_11(initial, first, input) : C.Machine}:
  {==}

def step_11(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_11(initial, first, input)) == M.state_12(initial, first, input) : C.Machine}:
  {==}

def step_12(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_12(initial, first, input)) == M.state_13(initial, first, input) : C.Machine}:
  {==}

def remainder(m: C.Machine) -> List<&2, C.Task>:
  match m:
    case C.Machine{w, tasks, stack}:
      match tasks:
        case Nil{}:
          []
        case h <> tail:
          tail

def step_13(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_13(initial, first, input)) == M.state_14(initial, first, input) : C.Machine}:
  +w = C.world(M.state_13(initial, first, input))
  +rest = remainder(M.state_13(initial, first, input))
  +value = {R.Number{Nat.add(input, 1n)} : R.Value}
  +ending = {C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n} <> rest : List<&2, C.Task>}
  +a = C.passReleases(w, rest, [], GeneralCuts.frame(R.Number{Nat.add(first, 1n)}), 0n, value, False{}, False{}, False{}, R.Healthy{})
  +b = Cuts.afterRelease(w, rest, [], value)
  +c = C.afterPass(w, rest, [], 3n, False{}, value, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{})
  +d = C.publishState(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{})
  +e = C.publicationCompleted(ending, [], 3n, R.Number{0n}, 0n, False{}, B.Bundle{C.world(M.state_14(initial, first, input)), True{}})
  Equal.trans(C.Machine, C.step(M.state_13(initial, first, input)), a, M.state_14(initial, first, input),
    GeneralCuts.step_from_shape(R.Number{Nat.add(first, 1n)}, M.state_13(initial, first, input), w, rest, [], value, {==}, {==}),
    Equal.trans(C.Machine, a, b, M.state_14(initial, first, input), GeneralCuts.release_empty(R.Number{Nat.add(first, 1n)}, w, rest, [], value, {==}),
      Equal.trans(C.Machine, b, c, M.state_14(initial, first, input), Cuts.after_release_identity(w, rest, [], value, {==}, {==}),
        Equal.trans(C.Machine, c, d, M.state_14(initial, first, input), Cuts.after_pass_live(w, rest, [], value, {==}, {==}, {==}),
          Equal.trans(C.Machine, d, e, M.state_14(initial, first, input),
            Cuts.default_publish(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, B.Bundle{C.world(M.state_14(initial, first, input)), True{}}, {==}, {==}, {==}, M.publication_13(initial, first, input)),
            {==})))))

def step_14(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_14(initial, first, input)) == M.state_15(initial, first, input) : C.Machine}:
  {==}

def step_15(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_15(initial, first, input)) == M.state_16(initial, first, input) : C.Machine}:
  {==}

def step_16(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_16(initial, first, input)) == M.state_17(initial, first, input) : C.Machine}:
  {==}

def step_17(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_17(initial, first, input)) == M.state_18(initial, first, input) : C.Machine}:
  {==}

def step_18(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_18(initial, first, input)) == M.state_19(initial, first, input) : C.Machine}:
  {==}

def step_19(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_19(initial, first, input)) == M.state_20(initial, first, input) : C.Machine}:
  {==}

def step_20(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_20(initial, first, input)) == M.state_21(initial, first, input) : C.Machine}:
  {==}

def step_21(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_21(initial, first, input)) == M.state_22(initial, first, input) : C.Machine}:
  {==}

def step_22(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_22(initial, first, input)) == M.state_23(initial, first, input) : C.Machine}:
  {==}

def step_23(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_23(initial, first, input)) == M.state_24(initial, first, input) : C.Machine}:
  {==}

def step_24(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_24(initial, first, input)) == M.state_25(initial, first, input) : C.Machine}:
  {==}

def step_25(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_25(initial, first, input)) == M.state_26(initial, first, input) : C.Machine}:
  {==}

def step_26(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_26(initial, first, input)) == M.state_27(initial, first, input) : C.Machine}:
  {==}

def step_27(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_27(initial, first, input)) == M.state_28(initial, first, input) : C.Machine}:
  {==}

def step_28(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_28(initial, first, input)) == M.state_29(initial, first, input) : C.Machine}:
  {==}

def step_29(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_29(initial, first, input)) == M.state_30(initial, first, input) : C.Machine}:
  {==}

def step_30(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_30(initial, first, input)) == M.state_31(initial, first, input) : C.Machine}:
  {==}

def step_31(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_31(initial, first, input)) == M.state_32(initial, first, input) : C.Machine}:
  {==}

def step_32(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_32(initial, first, input)) == M.state_33(initial, first, input) : C.Machine}:
  {==}

def step_33(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_33(initial, first, input)) == M.state_34(initial, first, input) : C.Machine}:
  {==}

def step_34(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_34(initial, first, input)) == M.state_35(initial, first, input) : C.Machine}:
  {==}

def step_35(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_35(initial, first, input)) == M.state_36(initial, first, input) : C.Machine}:
  {==}

def step_36(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_36(initial, first, input)) == M.state_37(initial, first, input) : C.Machine}:
  {==}

def step_37(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_37(initial, first, input)) == M.state_38(initial, first, input) : C.Machine}:
  {==}

def step_38(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_38(initial, first, input)) == M.state_39(initial, first, input) : C.Machine}:
  {==}

def step_39(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(M.state_39(initial, first, input)) == M.state_40(initial, first, input) : C.Machine}:
  {==}

def witness(+initial: Nat, +first: Nat, +input: Nat) -> P.Path<M.state_0(initial, first, input), M.state_40(initial, first, input)>:
  P.PathStep{M.state_1(initial, first, input), step_0(initial, first, input), P.PathStep{M.state_2(initial, first, input), step_1(initial, first, input), P.PathStep{M.state_3(initial, first, input), step_2(initial, first, input), P.PathStep{M.state_4(initial, first, input), step_3(initial, first, input), P.PathStep{M.state_5(initial, first, input), step_4(initial, first, input), P.PathStep{M.state_6(initial, first, input), step_5(initial, first, input), P.PathStep{M.state_7(initial, first, input), step_6(initial, first, input), P.PathStep{M.state_8(initial, first, input), step_7(initial, first, input), P.PathStep{M.state_9(initial, first, input), step_8(initial, first, input), P.PathStep{M.state_10(initial, first, input), step_9(initial, first, input), P.PathStep{M.state_11(initial, first, input), step_10(initial, first, input), P.PathStep{M.state_12(initial, first, input), step_11(initial, first, input), P.PathStep{M.state_13(initial, first, input), step_12(initial, first, input), P.PathStep{M.state_14(initial, first, input), step_13(initial, first, input), P.PathStep{M.state_15(initial, first, input), step_14(initial, first, input), P.PathStep{M.state_16(initial, first, input), step_15(initial, first, input), P.PathStep{M.state_17(initial, first, input), step_16(initial, first, input), P.PathStep{M.state_18(initial, first, input), step_17(initial, first, input), P.PathStep{M.state_19(initial, first, input), step_18(initial, first, input), P.PathStep{M.state_20(initial, first, input), step_19(initial, first, input), P.PathStep{M.state_21(initial, first, input), step_20(initial, first, input), P.PathStep{M.state_22(initial, first, input), step_21(initial, first, input), P.PathStep{M.state_23(initial, first, input), step_22(initial, first, input), P.PathStep{M.state_24(initial, first, input), step_23(initial, first, input), P.PathStep{M.state_25(initial, first, input), step_24(initial, first, input), P.PathStep{M.state_26(initial, first, input), step_25(initial, first, input), P.PathStep{M.state_27(initial, first, input), step_26(initial, first, input), P.PathStep{M.state_28(initial, first, input), step_27(initial, first, input), P.PathStep{M.state_29(initial, first, input), step_28(initial, first, input), P.PathStep{M.state_30(initial, first, input), step_29(initial, first, input), P.PathStep{M.state_31(initial, first, input), step_30(initial, first, input), P.PathStep{M.state_32(initial, first, input), step_31(initial, first, input), P.PathStep{M.state_33(initial, first, input), step_32(initial, first, input), P.PathStep{M.state_34(initial, first, input), step_33(initial, first, input), P.PathStep{M.state_35(initial, first, input), step_34(initial, first, input), P.PathStep{M.state_36(initial, first, input), step_35(initial, first, input), P.PathStep{M.state_37(initial, first, input), step_36(initial, first, input), P.PathStep{M.state_38(initial, first, input), step_37(initial, first, input), P.PathStep{M.state_39(initial, first, input), step_38(initial, first, input), P.PathStep{M.state_40(initial, first, input), step_39(initial, first, input), P.PathEnd{M.finalWorld(initial, first, input), [], {==}, {==}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}


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

def flush_eq(+initial: Nat, +first: Nat, +input: Nat, +extra: Nat) -> {A.flush(Nat.add(40n, extra), C.world(M.state_0(initial, first, input))) == C.world(M.state_40(initial, first, input)) : R.World}:
  Cuts.flush_from_shape(Nat.add(40n, extra), C.world(M.state_0(initial, first, input)), M.state_0(initial, first, input), M.state_40(initial, first, input), {==}, {==},
    retimed(M.state_0(initial, first, input), M.state_40(initial, first, input), witness(initial, first, input), extra, Nat.add(40n, extra), {==}))

def viewTransport(-a: R.World, -b: R.World, e: {a == b : R.World}) -> {Driver.view(a) == Driver.view(b) : Driver.View}:
  %e : {Driver.view(a) == Driver.view(_) : Driver.View}
  {==}

def every_staged_input(+initial: Nat, +first: Nat, +input: Nat, +extra: Nat) ->
  {Driver.view(A.flush(Nat.add(40n, extra), C.world(M.state_0(initial, first, input)))) == Driver.expected(input) : Driver.View}:
  viewTransport(A.flush(Nat.add(40n, extra), C.world(M.state_0(initial, first, input))), C.world(M.state_40(initial, first, input)), flush_eq(initial, first, input, extra))
