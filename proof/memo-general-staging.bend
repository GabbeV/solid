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

import ./memo-general-states.bend as M
import ./memo-cuts.bend as Cuts
import ./memo-general-cuts.bend as GeneralCuts

def step_0(+initial: Nat, +input: Nat) -> {C.step(M.state_0(initial, input)) == M.state_1(initial, input) : C.Machine}:
  {==}

def step_1(+initial: Nat, +input: Nat) -> {C.step(M.state_1(initial, input)) == M.state_2(initial, input) : C.Machine}:
  {==}

def step_2(+initial: Nat, +input: Nat) -> {C.step(M.state_2(initial, input)) == M.state_3(initial, input) : C.Machine}:
  {==}

def step_3(+initial: Nat, +input: Nat) -> {C.step(M.state_3(initial, input)) == M.state_4(initial, input) : C.Machine}:
  {==}

def step_4(+initial: Nat, +input: Nat) -> {C.step(M.state_4(initial, input)) == M.state_5(initial, input) : C.Machine}:
  {==}

def step_5(+initial: Nat, +input: Nat) -> {C.step(M.state_5(initial, input)) == M.state_6(initial, input) : C.Machine}:
  {==}

def step_6(+initial: Nat, +input: Nat) -> {C.step(M.state_6(initial, input)) == M.state_7(initial, input) : C.Machine}:
  {==}

def step_7(+initial: Nat, +input: Nat) -> {C.step(M.state_7(initial, input)) == M.state_8(initial, input) : C.Machine}:
  {==}

def step_8(+initial: Nat, +input: Nat) -> {C.step(M.state_8(initial, input)) == M.state_9(initial, input) : C.Machine}:
  {==}

def step_9(+initial: Nat, +input: Nat) -> {C.step(M.state_9(initial, input)) == M.state_10(initial, input) : C.Machine}:
  {==}

def step_10(+initial: Nat, +input: Nat) -> {C.step(M.state_10(initial, input)) == M.state_11(initial, input) : C.Machine}:
  {==}

def step_11(+initial: Nat, +input: Nat) -> {C.step(M.state_11(initial, input)) == M.state_12(initial, input) : C.Machine}:
  {==}

def step_12(+initial: Nat, +input: Nat) -> {C.step(M.state_12(initial, input)) == M.state_13(initial, input) : C.Machine}:
  {==}

def remainder(m: C.Machine) -> List<&2, C.Task>:
  match m:
    case C.Machine{w, tasks, stack}:
      match tasks:
        case Nil{}:
          []
        case h <> tail:
          tail

def step_13(+initial: Nat, +input: Nat) -> {C.step(M.state_13(initial, input)) == M.state_14(initial, input) : C.Machine}:
  +w = C.world(M.state_13(initial, input))
  +rest = remainder(M.state_13(initial, input))
  +value = {R.Number{Nat.add(input, 1n)} : R.Value}
  +ending = {C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n} <> rest : List<&2, C.Task>}
  +a = C.passReleases(w, rest, [], GeneralCuts.frame(R.Number{Nat.add(initial, 1n)}), 0n, value, False{}, False{}, False{}, R.Healthy{})
  +b = Cuts.afterRelease(w, rest, [], value)
  +c = C.afterPass(w, rest, [], 3n, False{}, value, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{})
  +d = C.publishState(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{})
  +e = C.publicationCompleted(ending, [], 3n, R.Number{0n}, 0n, False{}, B.Bundle{C.world(M.state_14(initial, input)), True{}})
  Equal.trans(C.Machine, C.step(M.state_13(initial, input)), a, M.state_14(initial, input),
    GeneralCuts.step_from_shape(R.Number{Nat.add(initial, 1n)}, M.state_13(initial, input), w, rest, [], value, {==}, {==}),
    Equal.trans(C.Machine, a, b, M.state_14(initial, input), GeneralCuts.release_empty(R.Number{Nat.add(initial, 1n)}, w, rest, [], value, {==}),
      Equal.trans(C.Machine, b, c, M.state_14(initial, input), Cuts.after_release_identity(w, rest, [], value, {==}, {==}),
        Equal.trans(C.Machine, c, d, M.state_14(initial, input), Cuts.after_pass_live(w, rest, [], value, {==}, {==}, {==}),
          Equal.trans(C.Machine, d, e, M.state_14(initial, input),
            Cuts.default_publish(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, B.Bundle{C.world(M.state_14(initial, input)), True{}}, {==}, {==}, {==}, M.publication_13(initial, input)),
            {==})))))

def step_14(+initial: Nat, +input: Nat) -> {C.step(M.state_14(initial, input)) == M.state_15(initial, input) : C.Machine}:
  {==}

def step_15(+initial: Nat, +input: Nat) -> {C.step(M.state_15(initial, input)) == M.state_16(initial, input) : C.Machine}:
  {==}

def step_16(+initial: Nat, +input: Nat) -> {C.step(M.state_16(initial, input)) == M.state_17(initial, input) : C.Machine}:
  {==}

def step_17(+initial: Nat, +input: Nat) -> {C.step(M.state_17(initial, input)) == M.state_18(initial, input) : C.Machine}:
  {==}

def step_18(+initial: Nat, +input: Nat) -> {C.step(M.state_18(initial, input)) == M.state_19(initial, input) : C.Machine}:
  {==}

def step_19(+initial: Nat, +input: Nat) -> {C.step(M.state_19(initial, input)) == M.state_20(initial, input) : C.Machine}:
  {==}

def step_20(+initial: Nat, +input: Nat) -> {C.step(M.state_20(initial, input)) == M.state_21(initial, input) : C.Machine}:
  {==}

def step_21(+initial: Nat, +input: Nat) -> {C.step(M.state_21(initial, input)) == M.state_22(initial, input) : C.Machine}:
  {==}

def step_22(+initial: Nat, +input: Nat) -> {C.step(M.state_22(initial, input)) == M.state_23(initial, input) : C.Machine}:
  {==}

def step_23(+initial: Nat, +input: Nat) -> {C.step(M.state_23(initial, input)) == M.state_24(initial, input) : C.Machine}:
  {==}

def step_24(+initial: Nat, +input: Nat) -> {C.step(M.state_24(initial, input)) == M.state_25(initial, input) : C.Machine}:
  {==}

def step_25(+initial: Nat, +input: Nat) -> {C.step(M.state_25(initial, input)) == M.state_26(initial, input) : C.Machine}:
  {==}

def step_26(+initial: Nat, +input: Nat) -> {C.step(M.state_26(initial, input)) == M.state_27(initial, input) : C.Machine}:
  {==}

def step_27(+initial: Nat, +input: Nat) -> {C.step(M.state_27(initial, input)) == M.state_28(initial, input) : C.Machine}:
  {==}

def step_28(+initial: Nat, +input: Nat) -> {C.step(M.state_28(initial, input)) == M.state_29(initial, input) : C.Machine}:
  {==}

def step_29(+initial: Nat, +input: Nat) -> {C.step(M.state_29(initial, input)) == M.state_30(initial, input) : C.Machine}:
  {==}

def step_30(+initial: Nat, +input: Nat) -> {C.step(M.state_30(initial, input)) == M.state_31(initial, input) : C.Machine}:
  {==}

def step_31(+initial: Nat, +input: Nat) -> {C.step(M.state_31(initial, input)) == M.state_32(initial, input) : C.Machine}:
  {==}

def step_32(+initial: Nat, +input: Nat) -> {C.step(M.state_32(initial, input)) == M.state_33(initial, input) : C.Machine}:
  {==}

def step_33(+initial: Nat, +input: Nat) -> {C.step(M.state_33(initial, input)) == M.state_34(initial, input) : C.Machine}:
  {==}

def step_34(+initial: Nat, +input: Nat) -> {C.step(M.state_34(initial, input)) == M.state_35(initial, input) : C.Machine}:
  {==}

def step_35(+initial: Nat, +input: Nat) -> {C.step(M.state_35(initial, input)) == M.state_36(initial, input) : C.Machine}:
  {==}

def step_36(+initial: Nat, +input: Nat) -> {C.step(M.state_36(initial, input)) == M.state_37(initial, input) : C.Machine}:
  {==}

def step_37(+initial: Nat, +input: Nat) -> {C.step(M.state_37(initial, input)) == M.state_38(initial, input) : C.Machine}:
  {==}

def step_38(+initial: Nat, +input: Nat) -> {C.step(M.state_38(initial, input)) == M.state_39(initial, input) : C.Machine}:
  {==}

def step_39(+initial: Nat, +input: Nat) -> {C.step(M.state_39(initial, input)) == M.state_40(initial, input) : C.Machine}:
  {==}

def witness(+initial: Nat, +input: Nat) -> P.Path<M.state_0(initial, input), M.state_40(initial, input)>:
  P.PathStep{M.state_1(initial, input), step_0(initial, input), P.PathStep{M.state_2(initial, input), step_1(initial, input), P.PathStep{M.state_3(initial, input), step_2(initial, input), P.PathStep{M.state_4(initial, input), step_3(initial, input), P.PathStep{M.state_5(initial, input), step_4(initial, input), P.PathStep{M.state_6(initial, input), step_5(initial, input), P.PathStep{M.state_7(initial, input), step_6(initial, input), P.PathStep{M.state_8(initial, input), step_7(initial, input), P.PathStep{M.state_9(initial, input), step_8(initial, input), P.PathStep{M.state_10(initial, input), step_9(initial, input), P.PathStep{M.state_11(initial, input), step_10(initial, input), P.PathStep{M.state_12(initial, input), step_11(initial, input), P.PathStep{M.state_13(initial, input), step_12(initial, input), P.PathStep{M.state_14(initial, input), step_13(initial, input), P.PathStep{M.state_15(initial, input), step_14(initial, input), P.PathStep{M.state_16(initial, input), step_15(initial, input), P.PathStep{M.state_17(initial, input), step_16(initial, input), P.PathStep{M.state_18(initial, input), step_17(initial, input), P.PathStep{M.state_19(initial, input), step_18(initial, input), P.PathStep{M.state_20(initial, input), step_19(initial, input), P.PathStep{M.state_21(initial, input), step_20(initial, input), P.PathStep{M.state_22(initial, input), step_21(initial, input), P.PathStep{M.state_23(initial, input), step_22(initial, input), P.PathStep{M.state_24(initial, input), step_23(initial, input), P.PathStep{M.state_25(initial, input), step_24(initial, input), P.PathStep{M.state_26(initial, input), step_25(initial, input), P.PathStep{M.state_27(initial, input), step_26(initial, input), P.PathStep{M.state_28(initial, input), step_27(initial, input), P.PathStep{M.state_29(initial, input), step_28(initial, input), P.PathStep{M.state_30(initial, input), step_29(initial, input), P.PathStep{M.state_31(initial, input), step_30(initial, input), P.PathStep{M.state_32(initial, input), step_31(initial, input), P.PathStep{M.state_33(initial, input), step_32(initial, input), P.PathStep{M.state_34(initial, input), step_33(initial, input), P.PathStep{M.state_35(initial, input), step_34(initial, input), P.PathStep{M.state_36(initial, input), step_35(initial, input), P.PathStep{M.state_37(initial, input), step_36(initial, input), P.PathStep{M.state_38(initial, input), step_37(initial, input), P.PathStep{M.state_39(initial, input), step_38(initial, input), P.PathStep{M.state_40(initial, input), step_39(initial, input), P.PathEnd{M.finalWorld(initial, input), [], {==}, {==}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}


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

def flush_eq(+initial: Nat, +input: Nat, +extra: Nat) -> {A.flush(Nat.add(40n, extra), C.world(M.state_0(initial, input))) == C.world(M.state_40(initial, input)) : R.World}:
  Cuts.flush_from_shape(Nat.add(40n, extra), C.world(M.state_0(initial, input)), M.state_0(initial, input), M.state_40(initial, input), {==}, {==},
    retimed(M.state_0(initial, input), M.state_40(initial, input), witness(initial, input), extra, Nat.add(40n, extra), {==}))

def viewTransport(-a: R.World, -b: R.World, e: {a == b : R.World}) -> {Driver.view(a) == Driver.view(b) : Driver.View}:
  %e : {Driver.view(a) == Driver.view(_) : Driver.View}
  {==}

def every_staged_input(+initial: Nat, +input: Nat, +extra: Nat) ->
  {Driver.view(A.flush(Nat.add(40n, extra), C.world(M.state_0(initial, input)))) == Driver.expected(input) : Driver.View}:
  viewTransport(A.flush(Nat.add(40n, extra), C.world(M.state_0(initial, input))), C.world(M.state_40(initial, input)), flush_eq(initial, input, extra))
