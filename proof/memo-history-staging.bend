# Repeatable steady-pass transitions with symbolic counters and trace/job prefixes.
# Algebraic helper cuts avoid kernel expansion; the public constructor/setter
# bridge is composed separately by memo-history-public.bend.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../proof/paths.bend as P
import ./memo-driver.bend as Driver
import ../runtime/owner.bend as O
import ../runtime/pending.bend as Q

import ./memo-history-states.bend as M
import ./memo-cuts.bend as Cuts
import ./memo-general-cuts.bend as GeneralCuts

def step_0(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_0(tick, previous, input, events, jobs)) == M.state_1(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_1(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_1(tick, previous, input, events, jobs)) == M.state_2(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_2(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_2(tick, previous, input, events, jobs)) == M.state_3(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_3(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_3(tick, previous, input, events, jobs)) == M.state_4(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_4(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_4(tick, previous, input, events, jobs)) == M.state_5(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_5(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_5(tick, previous, input, events, jobs)) == M.state_6(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_6(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_6(tick, previous, input, events, jobs)) == M.state_7(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_7(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_7(tick, previous, input, events, jobs)) == M.state_8(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_8(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_8(tick, previous, input, events, jobs)) == M.state_9(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_9(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_9(tick, previous, input, events, jobs)) == M.state_10(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_10(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_10(tick, previous, input, events, jobs)) == M.state_11(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_11(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_11(tick, previous, input, events, jobs)) == M.state_12(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_12(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_12(tick, previous, input, events, jobs)) == M.state_13(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def remainder(m: C.Machine) -> List<&2, C.Task>:
  match m:
    case C.Machine{w, tasks, stack}:
      match tasks:
        case Nil{}:
          []
        case h <> tail:
          tail

def step_13(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_13(tick, previous, input, events, jobs)) == M.state_14(tick, previous, input, events, jobs) : C.Machine}:
  +w = C.world(M.state_13(tick, previous, input, events, jobs))
  +rest = remainder(M.state_13(tick, previous, input, events, jobs))
  +value = {R.Number{Nat.add(input, 1n)} : R.Value}
  +ending = {C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n} <> rest : List<&2, C.Task>}
  +a = C.passReleases(w, rest, [], GeneralCuts.frame(R.Number{Nat.add(previous, 1n)}), 0n, value, False{}, False{}, False{}, R.Healthy{})
  +b = Cuts.afterRelease(w, rest, [], value)
  +c = C.afterPass(w, rest, [], 3n, False{}, value, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{})
  +d = C.publishState(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{})
  +e = C.publicationCompleted(ending, [], 3n, R.Number{0n}, 0n, False{}, B.Bundle{C.world(M.state_14(tick, previous, input, events, jobs)), True{}})
  Equal.trans(C.Machine, C.step(M.state_13(tick, previous, input, events, jobs)), a, M.state_14(tick, previous, input, events, jobs),
    GeneralCuts.step_from_shape(R.Number{Nat.add(previous, 1n)}, M.state_13(tick, previous, input, events, jobs), w, rest, [], value, {==}, {==}),
    Equal.trans(C.Machine, a, b, M.state_14(tick, previous, input, events, jobs), GeneralCuts.release_empty(R.Number{Nat.add(previous, 1n)}, w, rest, [], value, {==}),
      Equal.trans(C.Machine, b, c, M.state_14(tick, previous, input, events, jobs), Cuts.after_release_identity(w, rest, [], value, {==}, {==}),
        Equal.trans(C.Machine, c, d, M.state_14(tick, previous, input, events, jobs), Cuts.after_pass_live(w, rest, [], value, {==}, {==}, {==}),
          Equal.trans(C.Machine, d, e, M.state_14(tick, previous, input, events, jobs),
            Cuts.default_publish(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, B.Bundle{C.world(M.state_14(tick, previous, input, events, jobs)), True{}}, {==}, {==}, {==}, M.publication_13(tick, previous, input, events, jobs)),
            {==})))))

def step_14(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_14(tick, previous, input, events, jobs)) == M.state_15(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_15(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_15(tick, previous, input, events, jobs)) == M.state_16(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_16(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_16(tick, previous, input, events, jobs)) == M.state_17(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_17(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_17(tick, previous, input, events, jobs)) == M.state_18(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_18(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_18(tick, previous, input, events, jobs)) == M.state_19(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_19(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_19(tick, previous, input, events, jobs)) == M.state_20(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_20(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_20(tick, previous, input, events, jobs)) == M.state_21(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_21(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_21(tick, previous, input, events, jobs)) == M.state_22(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_22(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_22(tick, previous, input, events, jobs)) == M.state_23(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_23(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_23(tick, previous, input, events, jobs)) == M.state_24(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_24(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_24(tick, previous, input, events, jobs)) == M.state_25(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_25(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_25(tick, previous, input, events, jobs)) == M.state_26(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_26(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_26(tick, previous, input, events, jobs)) == M.state_27(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_27(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_27(tick, previous, input, events, jobs)) == M.state_28(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_28(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_28(tick, previous, input, events, jobs)) == M.state_29(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_29(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_29(tick, previous, input, events, jobs)) == M.state_30(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_30(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_30(tick, previous, input, events, jobs)) == M.state_31(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_31(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_31(tick, previous, input, events, jobs)) == M.state_32(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_32(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_32(tick, previous, input, events, jobs)) == M.state_33(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_33(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_33(tick, previous, input, events, jobs)) == M.state_34(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_34(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_34(tick, previous, input, events, jobs)) == M.state_35(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_35(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_35(tick, previous, input, events, jobs)) == M.state_36(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_36(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_36(tick, previous, input, events, jobs)) == M.state_37(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_37(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_37(tick, previous, input, events, jobs)) == M.state_38(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_38(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_38(tick, previous, input, events, jobs)) == M.state_39(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def step_39(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_39(tick, previous, input, events, jobs)) == M.state_40(tick, previous, input, events, jobs) : C.Machine}:
  {==}

def witness(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> P.Path<M.state_0(tick, previous, input, events, jobs), M.state_40(tick, previous, input, events, jobs)>:
  P.PathStep{M.state_1(tick, previous, input, events, jobs), step_0(tick, previous, input, events, jobs), P.PathStep{M.state_2(tick, previous, input, events, jobs), step_1(tick, previous, input, events, jobs), P.PathStep{M.state_3(tick, previous, input, events, jobs), step_2(tick, previous, input, events, jobs), P.PathStep{M.state_4(tick, previous, input, events, jobs), step_3(tick, previous, input, events, jobs), P.PathStep{M.state_5(tick, previous, input, events, jobs), step_4(tick, previous, input, events, jobs), P.PathStep{M.state_6(tick, previous, input, events, jobs), step_5(tick, previous, input, events, jobs), P.PathStep{M.state_7(tick, previous, input, events, jobs), step_6(tick, previous, input, events, jobs), P.PathStep{M.state_8(tick, previous, input, events, jobs), step_7(tick, previous, input, events, jobs), P.PathStep{M.state_9(tick, previous, input, events, jobs), step_8(tick, previous, input, events, jobs), P.PathStep{M.state_10(tick, previous, input, events, jobs), step_9(tick, previous, input, events, jobs), P.PathStep{M.state_11(tick, previous, input, events, jobs), step_10(tick, previous, input, events, jobs), P.PathStep{M.state_12(tick, previous, input, events, jobs), step_11(tick, previous, input, events, jobs), P.PathStep{M.state_13(tick, previous, input, events, jobs), step_12(tick, previous, input, events, jobs), P.PathStep{M.state_14(tick, previous, input, events, jobs), step_13(tick, previous, input, events, jobs), P.PathStep{M.state_15(tick, previous, input, events, jobs), step_14(tick, previous, input, events, jobs), P.PathStep{M.state_16(tick, previous, input, events, jobs), step_15(tick, previous, input, events, jobs), P.PathStep{M.state_17(tick, previous, input, events, jobs), step_16(tick, previous, input, events, jobs), P.PathStep{M.state_18(tick, previous, input, events, jobs), step_17(tick, previous, input, events, jobs), P.PathStep{M.state_19(tick, previous, input, events, jobs), step_18(tick, previous, input, events, jobs), P.PathStep{M.state_20(tick, previous, input, events, jobs), step_19(tick, previous, input, events, jobs), P.PathStep{M.state_21(tick, previous, input, events, jobs), step_20(tick, previous, input, events, jobs), P.PathStep{M.state_22(tick, previous, input, events, jobs), step_21(tick, previous, input, events, jobs), P.PathStep{M.state_23(tick, previous, input, events, jobs), step_22(tick, previous, input, events, jobs), P.PathStep{M.state_24(tick, previous, input, events, jobs), step_23(tick, previous, input, events, jobs), P.PathStep{M.state_25(tick, previous, input, events, jobs), step_24(tick, previous, input, events, jobs), P.PathStep{M.state_26(tick, previous, input, events, jobs), step_25(tick, previous, input, events, jobs), P.PathStep{M.state_27(tick, previous, input, events, jobs), step_26(tick, previous, input, events, jobs), P.PathStep{M.state_28(tick, previous, input, events, jobs), step_27(tick, previous, input, events, jobs), P.PathStep{M.state_29(tick, previous, input, events, jobs), step_28(tick, previous, input, events, jobs), P.PathStep{M.state_30(tick, previous, input, events, jobs), step_29(tick, previous, input, events, jobs), P.PathStep{M.state_31(tick, previous, input, events, jobs), step_30(tick, previous, input, events, jobs), P.PathStep{M.state_32(tick, previous, input, events, jobs), step_31(tick, previous, input, events, jobs), P.PathStep{M.state_33(tick, previous, input, events, jobs), step_32(tick, previous, input, events, jobs), P.PathStep{M.state_34(tick, previous, input, events, jobs), step_33(tick, previous, input, events, jobs), P.PathStep{M.state_35(tick, previous, input, events, jobs), step_34(tick, previous, input, events, jobs), P.PathStep{M.state_36(tick, previous, input, events, jobs), step_35(tick, previous, input, events, jobs), P.PathStep{M.state_37(tick, previous, input, events, jobs), step_36(tick, previous, input, events, jobs), P.PathStep{M.state_38(tick, previous, input, events, jobs), step_37(tick, previous, input, events, jobs), P.PathStep{M.state_39(tick, previous, input, events, jobs), step_38(tick, previous, input, events, jobs), P.PathStep{M.state_40(tick, previous, input, events, jobs), step_39(tick, previous, input, events, jobs), P.PathEnd{M.finalWorld(tick, previous, input, events, jobs), [], {==}, {==}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}


# This theorem starts at the explicit staged arena. The public setter bridge is
# established separately by memo-history-public; this local drain theorem
# retains its explicit staged-arena precondition.
def retimed(+start: C.Machine, -end: C.Machine, +path: P.Path<start, end>, +extra: Nat, +fuel: Nat,
  lengthEq: {Nat.add(P.length(start, end, path), extra) == fuel : Nat}) ->
  {C.run(fuel, start) == end : C.Machine}:
  Equal.trans(C.Machine, C.run(fuel, start), C.run(Nat.add(P.length(start, end, path), extra), start), end,
    P.fuel_transport(fuel, Nat.add(P.length(start, end, path), extra), start,
      Equal.sym(Nat, Nat.add(P.length(start, end, path), extra), fuel, lengthEq)),
    P.realizes(start, end, path, extra, start, {==}))

def flush_eq(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>, +extra: Nat) -> {A.flush(Nat.add(40n, extra), C.world(M.state_0(tick, previous, input, events, jobs))) == C.world(M.state_40(tick, previous, input, events, jobs)) : R.World}:
  Cuts.flush_from_shape(Nat.add(40n, extra), C.world(M.state_0(tick, previous, input, events, jobs)), M.state_0(tick, previous, input, events, jobs), M.state_40(tick, previous, input, events, jobs), {==}, {==},
    retimed(M.state_0(tick, previous, input, events, jobs), M.state_40(tick, previous, input, events, jobs), witness(tick, previous, input, events, jobs), extra, Nat.add(40n, extra), {==}))

def viewTransport(-a: R.World, -b: R.World, e: {a == b : R.World}) -> {Driver.view(a) == Driver.view(b) : Driver.View}:
  %e : {Driver.view(a) == Driver.view(_) : Driver.View}
  {==}

def every_staged_input(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>, +extra: Nat) ->
  {Driver.view(A.flush(Nat.add(40n, extra), C.world(M.state_0(tick, previous, input, events, jobs)))) == Driver.expected(input) : Driver.View}:
  viewTransport(A.flush(Nat.add(40n, extra), C.world(M.state_0(tick, previous, input, events, jobs))), C.world(M.state_40(tick, previous, input, events, jobs)), flush_eq(tick, previous, input, events, jobs, extra))
