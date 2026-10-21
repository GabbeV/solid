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

def step_0(+first: Nat, +input: Nat) -> {C.step(M.state_0(first, input)) == M.state_1(first, input) : C.Machine}:
  {==}

def step_1(+first: Nat, +input: Nat) -> {C.step(M.state_1(first, input)) == M.state_2(first, input) : C.Machine}:
  {==}

def step_2(+first: Nat, +input: Nat) -> {C.step(M.state_2(first, input)) == M.state_3(first, input) : C.Machine}:
  {==}

def step_3(+first: Nat, +input: Nat) -> {C.step(M.state_3(first, input)) == M.state_4(first, input) : C.Machine}:
  {==}

def step_4(+first: Nat, +input: Nat) -> {C.step(M.state_4(first, input)) == M.state_5(first, input) : C.Machine}:
  {==}

def step_5(+first: Nat, +input: Nat) -> {C.step(M.state_5(first, input)) == M.state_6(first, input) : C.Machine}:
  {==}

def step_6(+first: Nat, +input: Nat) -> {C.step(M.state_6(first, input)) == M.state_7(first, input) : C.Machine}:
  {==}

def step_7(+first: Nat, +input: Nat) -> {C.step(M.state_7(first, input)) == M.state_8(first, input) : C.Machine}:
  {==}

def step_8(+first: Nat, +input: Nat) -> {C.step(M.state_8(first, input)) == M.state_9(first, input) : C.Machine}:
  {==}

def step_9(+first: Nat, +input: Nat) -> {C.step(M.state_9(first, input)) == M.state_10(first, input) : C.Machine}:
  {==}

def step_10(+first: Nat, +input: Nat) -> {C.step(M.state_10(first, input)) == M.state_11(first, input) : C.Machine}:
  {==}

def step_11(+first: Nat, +input: Nat) -> {C.step(M.state_11(first, input)) == M.state_12(first, input) : C.Machine}:
  {==}

def step_12(+first: Nat, +input: Nat) -> {C.step(M.state_12(first, input)) == M.state_13(first, input) : C.Machine}:
  {==}

def remainder(m: C.Machine) -> List<&2, C.Task>:
  match m:
    case C.Machine{w, tasks, stack}:
      match tasks:
        case Nil{}:
          []
        case h <> tail:
          tail

def step_13(+first: Nat, +input: Nat) -> {C.step(M.state_13(first, input)) == M.state_14(first, input) : C.Machine}:
  +w = C.world(M.state_13(first, input))
  +rest = remainder(M.state_13(first, input))
  +value = {R.Number{Nat.add(input, 1n)} : R.Value}
  +ending = {C.FinishPublication{3n, False{}, False{}, False{}} <> rest : List<&2, C.Task>}
  +a = C.passReleases(w, rest, [], GeneralCuts.frame(R.Number{Nat.add(first, 1n)}), 0n, value, False{}, False{}, False{}, R.Healthy{})
  +b = Cuts.afterRelease(w, rest, [], value)
  +c = C.afterPass(w, rest, [], 3n, False{}, value, 0n, False{}, R.Undefined{}, 0n, False{}, False{}, False{}, False{})
  +d = C.publishState(w, ending, [], 3n, value, False{}, 0n, False{}, R.Undefined{}, 0n, False{}, False{}, False{})
  +e = C.publicationCompleted(ending, [], 3n, R.Undefined{}, 0n, False{}, B.Bundle{C.world(M.state_14(first, input)), True{}})
  Equal.trans(C.Machine, C.step(M.state_13(first, input)), a, M.state_14(first, input),
    GeneralCuts.step_from_shape(R.Number{Nat.add(first, 1n)}, M.state_13(first, input), w, rest, [], value, {==}, {==}),
    Equal.trans(C.Machine, a, b, M.state_14(first, input), GeneralCuts.release_empty(R.Number{Nat.add(first, 1n)}, w, rest, [], value, {==}),
      Equal.trans(C.Machine, b, c, M.state_14(first, input), Cuts.after_release_identity(w, rest, [], value, {==}, {==}),
        Equal.trans(C.Machine, c, d, M.state_14(first, input), Cuts.after_pass_live(w, rest, [], value, {==}),
          Equal.trans(C.Machine, d, e, M.state_14(first, input),
            Cuts.default_publish(w, ending, [], 3n, value, False{}, 0n, False{}, R.Undefined{}, 0n, False{}, False{}, False{}, B.Bundle{C.world(M.state_14(first, input)), True{}}, {==}, {==}, M.publication_13(first, input)),
            {==})))))

def step_14(+first: Nat, +input: Nat) -> {C.step(M.state_14(first, input)) == M.state_15(first, input) : C.Machine}:
  {==}

def step_15(+first: Nat, +input: Nat) -> {C.step(M.state_15(first, input)) == M.state_16(first, input) : C.Machine}:
  {==}

def step_16(+first: Nat, +input: Nat) -> {C.step(M.state_16(first, input)) == M.state_17(first, input) : C.Machine}:
  {==}

def step_17(+first: Nat, +input: Nat) -> {C.step(M.state_17(first, input)) == M.state_18(first, input) : C.Machine}:
  {==}

def step_18(+first: Nat, +input: Nat) -> {C.step(M.state_18(first, input)) == M.state_19(first, input) : C.Machine}:
  {==}

def step_19(+first: Nat, +input: Nat) -> {C.step(M.state_19(first, input)) == M.state_20(first, input) : C.Machine}:
  {==}

def step_20(+first: Nat, +input: Nat) -> {C.step(M.state_20(first, input)) == M.state_21(first, input) : C.Machine}:
  {==}

def step_21(+first: Nat, +input: Nat) -> {C.step(M.state_21(first, input)) == M.state_22(first, input) : C.Machine}:
  {==}

def step_22(+first: Nat, +input: Nat) -> {C.step(M.state_22(first, input)) == M.state_23(first, input) : C.Machine}:
  {==}

def step_23(+first: Nat, +input: Nat) -> {C.step(M.state_23(first, input)) == M.state_24(first, input) : C.Machine}:
  {==}

def step_24(+first: Nat, +input: Nat) -> {C.step(M.state_24(first, input)) == M.state_25(first, input) : C.Machine}:
  {==}

def step_25(+first: Nat, +input: Nat) -> {C.step(M.state_25(first, input)) == M.state_26(first, input) : C.Machine}:
  {==}

def step_26(+first: Nat, +input: Nat) -> {C.step(M.state_26(first, input)) == M.state_27(first, input) : C.Machine}:
  {==}

def step_27(+first: Nat, +input: Nat) -> {C.step(M.state_27(first, input)) == M.state_28(first, input) : C.Machine}:
  {==}

def step_28(+first: Nat, +input: Nat) -> {C.step(M.state_28(first, input)) == M.state_29(first, input) : C.Machine}:
  {==}

def step_29(+first: Nat, +input: Nat) -> {C.step(M.state_29(first, input)) == M.state_30(first, input) : C.Machine}:
  {==}

def step_30(+first: Nat, +input: Nat) -> {C.step(M.state_30(first, input)) == M.state_31(first, input) : C.Machine}:
  {==}

def step_31(+first: Nat, +input: Nat) -> {C.step(M.state_31(first, input)) == M.state_32(first, input) : C.Machine}:
  {==}

def step_32(+first: Nat, +input: Nat) -> {C.step(M.state_32(first, input)) == M.state_33(first, input) : C.Machine}:
  {==}

def step_33(+first: Nat, +input: Nat) -> {C.step(M.state_33(first, input)) == M.state_34(first, input) : C.Machine}:
  {==}

def step_34(+first: Nat, +input: Nat) -> {C.step(M.state_34(first, input)) == M.state_35(first, input) : C.Machine}:
  {==}

def step_35(+first: Nat, +input: Nat) -> {C.step(M.state_35(first, input)) == M.state_36(first, input) : C.Machine}:
  {==}

def step_36(+first: Nat, +input: Nat) -> {C.step(M.state_36(first, input)) == M.state_37(first, input) : C.Machine}:
  {==}

def step_37(+first: Nat, +input: Nat) -> {C.step(M.state_37(first, input)) == M.state_38(first, input) : C.Machine}:
  {==}

def step_38(+first: Nat, +input: Nat) -> {C.step(M.state_38(first, input)) == M.state_39(first, input) : C.Machine}:
  {==}

def step_39(+first: Nat, +input: Nat) -> {C.step(M.state_39(first, input)) == M.state_40(first, input) : C.Machine}:
  {==}

def witness(+first: Nat, +input: Nat) -> P.Path<M.state_0(first, input), M.state_40(first, input)>:
  P.PathStep{M.state_1(first, input), step_0(first, input), P.PathStep{M.state_2(first, input), step_1(first, input), P.PathStep{M.state_3(first, input), step_2(first, input), P.PathStep{M.state_4(first, input), step_3(first, input), P.PathStep{M.state_5(first, input), step_4(first, input), P.PathStep{M.state_6(first, input), step_5(first, input), P.PathStep{M.state_7(first, input), step_6(first, input), P.PathStep{M.state_8(first, input), step_7(first, input), P.PathStep{M.state_9(first, input), step_8(first, input), P.PathStep{M.state_10(first, input), step_9(first, input), P.PathStep{M.state_11(first, input), step_10(first, input), P.PathStep{M.state_12(first, input), step_11(first, input), P.PathStep{M.state_13(first, input), step_12(first, input), P.PathStep{M.state_14(first, input), step_13(first, input), P.PathStep{M.state_15(first, input), step_14(first, input), P.PathStep{M.state_16(first, input), step_15(first, input), P.PathStep{M.state_17(first, input), step_16(first, input), P.PathStep{M.state_18(first, input), step_17(first, input), P.PathStep{M.state_19(first, input), step_18(first, input), P.PathStep{M.state_20(first, input), step_19(first, input), P.PathStep{M.state_21(first, input), step_20(first, input), P.PathStep{M.state_22(first, input), step_21(first, input), P.PathStep{M.state_23(first, input), step_22(first, input), P.PathStep{M.state_24(first, input), step_23(first, input), P.PathStep{M.state_25(first, input), step_24(first, input), P.PathStep{M.state_26(first, input), step_25(first, input), P.PathStep{M.state_27(first, input), step_26(first, input), P.PathStep{M.state_28(first, input), step_27(first, input), P.PathStep{M.state_29(first, input), step_28(first, input), P.PathStep{M.state_30(first, input), step_29(first, input), P.PathStep{M.state_31(first, input), step_30(first, input), P.PathStep{M.state_32(first, input), step_31(first, input), P.PathStep{M.state_33(first, input), step_32(first, input), P.PathStep{M.state_34(first, input), step_33(first, input), P.PathStep{M.state_35(first, input), step_34(first, input), P.PathStep{M.state_36(first, input), step_35(first, input), P.PathStep{M.state_37(first, input), step_36(first, input), P.PathStep{M.state_38(first, input), step_37(first, input), P.PathStep{M.state_39(first, input), step_38(first, input), P.PathStep{M.state_40(first, input), step_39(first, input), P.PathEnd{M.finalWorld(first, input), [], {==}, {==}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}


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

def flush_eq(+first: Nat, +input: Nat, +extra: Nat) -> {A.flush(Nat.add(40n, extra), C.world(M.state_0(first, input))) == C.world(M.state_40(first, input)) : R.World}:
  Cuts.flush_from_shape(Nat.add(40n, extra), C.world(M.state_0(first, input)), M.state_0(first, input), M.state_40(first, input), {==}, {==},
    retimed(M.state_0(first, input), M.state_40(first, input), witness(first, input), extra, Nat.add(40n, extra), {==}))

def viewTransport(-a: R.World, -b: R.World, e: {a == b : R.World}) -> {Driver.view(a) == Driver.view(b) : Driver.View}:
  %e : {Driver.view(a) == Driver.view(_) : Driver.View}
  {==}

def every_staged_input(+first: Nat, +input: Nat, +extra: Nat) ->
  {Driver.view(A.flush(Nat.add(40n, extra), C.world(M.state_0(first, input)))) == Driver.expected(input) : Driver.View}:
  viewTransport(A.flush(Nat.add(40n, extra), C.world(M.state_0(first, input))), C.world(M.state_40(first, input)), flush_eq(first, input, extra))
