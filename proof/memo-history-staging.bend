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
import ./deferred-read-cut.bend as ReadCut
import ./natural-netted-value.bend as Natural
import ./memo-general-cuts.bend as GeneralCuts

def remainder(m: C.Machine) -> List<&2, C.Task>:
  match m:
    case C.Machine{w, tasks, stack}:
      match tasks:
        case Nil{}:
          []
        case h <> tail:
          tail


def stepAt_0(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_0(prior,netted,tick, previous, input, events, jobs)) == M.at_1(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_0(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_0(prior, tick, previous, input, events, jobs)) == M.state_1(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_0(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_1(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_1(prior,netted,tick, previous, input, events, jobs)) == M.at_2(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_1(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_1(prior, tick, previous, input, events, jobs)) == M.state_2(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_1(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_2(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_2(prior,netted,tick, previous, input, events, jobs)) == M.at_3(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_2(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_2(prior, tick, previous, input, events, jobs)) == M.state_3(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_2(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_3(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_3(prior,netted,tick, previous, input, events, jobs)) == M.at_4(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_3(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_3(prior, tick, previous, input, events, jobs)) == M.state_4(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_3(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_4(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_4(prior,netted,tick, previous, input, events, jobs)) == M.at_5(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_4(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_4(prior, tick, previous, input, events, jobs)) == M.state_5(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_4(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_5(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_5(prior,netted,tick, previous, input, events, jobs)) == M.at_6(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_5(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_5(prior, tick, previous, input, events, jobs)) == M.state_6(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_5(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_6(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_6(prior,netted,tick, previous, input, events, jobs)) == M.at_7(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_6(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_6(prior, tick, previous, input, events, jobs)) == M.state_7(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_6(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_7(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_7(prior,netted,tick, previous, input, events, jobs)) == M.at_8(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_7(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_7(prior, tick, previous, input, events, jobs)) == M.state_8(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_7(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_8(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_8(prior,netted,tick, previous, input, events, jobs)) == M.at_9(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_8(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_8(prior, tick, previous, input, events, jobs)) == M.state_9(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_8(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def readAt(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  ReadCut.read(C.world(M.at_9(prior,netted,tick, previous, input, events, jobs)),remainder(M.at_9(prior,netted,tick, previous, input, events, jobs)),C.values(M.at_9(prior,netted,tick, previous, input, events, jobs)),2n,netted)

def readExpected(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>,value: R.Value) -> C.Machine:
  +w = R.World.with_events(C.world(M.at_10(prior,netted,tick, previous, input, events, jobs)),R.World.events(C.world(M.at_9(prior,netted,tick, previous, input, events, jobs))))
  C.served(w,remainder(M.at_9(prior,netted,tick, previous, input, events, jobs)),C.values(M.at_9(prior,netted,tick, previous, input, events, jobs)),3n,2n,value)

def readCase(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {readAt(prior,netted,tick, previous, input, events, jobs) == readExpected(prior,netted,tick, previous, input, events, jobs,B.choose(~R.Value,netted,_=>R.Number{previous},_=>R.Number{input})) : C.Machine}:
  match prior netted:
    case True{} True{}: {==}
    case True{} False{}: {==}
    case False{} True{}: {==}
    case False{} False{}: {==}

def step_9(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_9(prior, tick, previous, input, events, jobs)) == M.state_10(prior, tick, previous, input, events, jobs) : C.Machine}:
  +netted = Nat.is_eq(input,previous)
  +answer = B.choose(~R.Value,netted,_=>R.Number{previous},_=>R.Number{input})
  Equal.trans(C.Machine,C.step(M.state_9(prior, tick, previous, input, events, jobs)),readExpected(prior,netted,tick, previous, input, events, jobs,answer),M.state_10(prior, tick, previous, input, events, jobs),Equal.trans(C.Machine,C.step(M.state_9(prior, tick, previous, input, events, jobs)),readAt(prior,netted,tick, previous, input, events, jobs),readExpected(prior,netted,tick, previous, input, events, jobs,answer),{==},readCase(prior,netted,tick, previous, input, events, jobs)),Equal.cong(R.Value,C.Machine,value=>readExpected(prior,netted,tick, previous, input, events, jobs,value),answer,R.Number{input},Natural.pick(previous,input)))

def stepAt_10(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_10(prior,netted,tick, previous, input, events, jobs)) == M.at_11(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_10(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_10(prior, tick, previous, input, events, jobs)) == M.state_11(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_10(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_11(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_11(prior,netted,tick, previous, input, events, jobs)) == M.at_12(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_11(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_11(prior, tick, previous, input, events, jobs)) == M.state_12(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_11(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_12(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_12(prior,netted,tick, previous, input, events, jobs)) == M.at_13(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_12(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_12(prior, tick, previous, input, events, jobs)) == M.state_13(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_12(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_13(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_13(prior,netted,tick, previous, input, events, jobs)) == M.at_14(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      +w = C.world(M.at_13(True{}, True{}, tick, previous, input, events, jobs))
      +rest = remainder(M.at_13(True{}, True{}, tick, previous, input, events, jobs))
      +value = {R.Number{Nat.add(input, 1n)} : R.Value}
      +ending = {C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n} <> rest : List<&2, C.Task>}
      +a = C.passReleases(w, rest, [], GeneralCuts.frame(R.Number{Nat.add(previous, 1n)}), 0n, value, False{}, False{}, False{}, R.Healthy{})
      +b = Cuts.afterRelease(w, rest, [], value)
      +c = C.afterPass(w, rest, [], 3n, False{}, value, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{})
      +d = C.publishState(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{})
      +e = C.publicationCompleted(ending, [], 3n, R.Number{0n}, 0n, False{}, B.Bundle{C.world(M.at_14(True{}, True{}, tick, previous, input, events, jobs)), True{}})
      Equal.trans(C.Machine, C.step(M.at_13(True{}, True{}, tick, previous, input, events, jobs)), a, M.at_14(True{}, True{}, tick, previous, input, events, jobs),
        GeneralCuts.step_from_shape(R.Number{Nat.add(previous, 1n)}, M.at_13(True{}, True{}, tick, previous, input, events, jobs), w, rest, [], value, {==}, {==}),
        Equal.trans(C.Machine, a, b, M.at_14(True{}, True{}, tick, previous, input, events, jobs), GeneralCuts.release_empty(R.Number{Nat.add(previous, 1n)}, w, rest, [], value, {==}),
          Equal.trans(C.Machine, b, c, M.at_14(True{}, True{}, tick, previous, input, events, jobs), Cuts.after_release_identity(w, rest, [], value, {==}, {==}),
            Equal.trans(C.Machine, c, d, M.at_14(True{}, True{}, tick, previous, input, events, jobs), Cuts.after_pass_live(w, rest, [], value, {==}, {==}, {==}),
              Equal.trans(C.Machine, d, e, M.at_14(True{}, True{}, tick, previous, input, events, jobs),
                Cuts.default_publish(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, B.Bundle{C.world(M.at_14(True{}, True{}, tick, previous, input, events, jobs)), True{}}, {==}, {==}, {==}, M.publicationAt_13(True{}, True{}, tick, previous, input, events, jobs)),
                {==})))))
    case True{} False{}:
      +w = C.world(M.at_13(True{}, False{}, tick, previous, input, events, jobs))
      +rest = remainder(M.at_13(True{}, False{}, tick, previous, input, events, jobs))
      +value = {R.Number{Nat.add(input, 1n)} : R.Value}
      +ending = {C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n} <> rest : List<&2, C.Task>}
      +a = C.passReleases(w, rest, [], GeneralCuts.frame(R.Number{Nat.add(previous, 1n)}), 0n, value, False{}, False{}, False{}, R.Healthy{})
      +b = Cuts.afterRelease(w, rest, [], value)
      +c = C.afterPass(w, rest, [], 3n, False{}, value, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{})
      +d = C.publishState(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{})
      +e = C.publicationCompleted(ending, [], 3n, R.Number{0n}, 0n, False{}, B.Bundle{C.world(M.at_14(True{}, False{}, tick, previous, input, events, jobs)), True{}})
      Equal.trans(C.Machine, C.step(M.at_13(True{}, False{}, tick, previous, input, events, jobs)), a, M.at_14(True{}, False{}, tick, previous, input, events, jobs),
        GeneralCuts.step_from_shape(R.Number{Nat.add(previous, 1n)}, M.at_13(True{}, False{}, tick, previous, input, events, jobs), w, rest, [], value, {==}, {==}),
        Equal.trans(C.Machine, a, b, M.at_14(True{}, False{}, tick, previous, input, events, jobs), GeneralCuts.release_empty(R.Number{Nat.add(previous, 1n)}, w, rest, [], value, {==}),
          Equal.trans(C.Machine, b, c, M.at_14(True{}, False{}, tick, previous, input, events, jobs), Cuts.after_release_identity(w, rest, [], value, {==}, {==}),
            Equal.trans(C.Machine, c, d, M.at_14(True{}, False{}, tick, previous, input, events, jobs), Cuts.after_pass_live(w, rest, [], value, {==}, {==}, {==}),
              Equal.trans(C.Machine, d, e, M.at_14(True{}, False{}, tick, previous, input, events, jobs),
                Cuts.default_publish(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, B.Bundle{C.world(M.at_14(True{}, False{}, tick, previous, input, events, jobs)), True{}}, {==}, {==}, {==}, M.publicationAt_13(True{}, False{}, tick, previous, input, events, jobs)),
                {==})))))
    case False{} True{}:
      +w = C.world(M.at_13(False{}, True{}, tick, previous, input, events, jobs))
      +rest = remainder(M.at_13(False{}, True{}, tick, previous, input, events, jobs))
      +value = {R.Number{Nat.add(input, 1n)} : R.Value}
      +ending = {C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n} <> rest : List<&2, C.Task>}
      +a = C.passReleases(w, rest, [], GeneralCuts.frame(R.Number{Nat.add(previous, 1n)}), 0n, value, False{}, False{}, False{}, R.Healthy{})
      +b = Cuts.afterRelease(w, rest, [], value)
      +c = C.afterPass(w, rest, [], 3n, False{}, value, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{})
      +d = C.publishState(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{})
      +e = C.publicationCompleted(ending, [], 3n, R.Number{0n}, 0n, False{}, B.Bundle{C.world(M.at_14(False{}, True{}, tick, previous, input, events, jobs)), True{}})
      Equal.trans(C.Machine, C.step(M.at_13(False{}, True{}, tick, previous, input, events, jobs)), a, M.at_14(False{}, True{}, tick, previous, input, events, jobs),
        GeneralCuts.step_from_shape(R.Number{Nat.add(previous, 1n)}, M.at_13(False{}, True{}, tick, previous, input, events, jobs), w, rest, [], value, {==}, {==}),
        Equal.trans(C.Machine, a, b, M.at_14(False{}, True{}, tick, previous, input, events, jobs), GeneralCuts.release_empty(R.Number{Nat.add(previous, 1n)}, w, rest, [], value, {==}),
          Equal.trans(C.Machine, b, c, M.at_14(False{}, True{}, tick, previous, input, events, jobs), Cuts.after_release_identity(w, rest, [], value, {==}, {==}),
            Equal.trans(C.Machine, c, d, M.at_14(False{}, True{}, tick, previous, input, events, jobs), Cuts.after_pass_live(w, rest, [], value, {==}, {==}, {==}),
              Equal.trans(C.Machine, d, e, M.at_14(False{}, True{}, tick, previous, input, events, jobs),
                Cuts.default_publish(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, B.Bundle{C.world(M.at_14(False{}, True{}, tick, previous, input, events, jobs)), True{}}, {==}, {==}, {==}, M.publicationAt_13(False{}, True{}, tick, previous, input, events, jobs)),
                {==})))))
    case False{} False{}:
      +w = C.world(M.at_13(False{}, False{}, tick, previous, input, events, jobs))
      +rest = remainder(M.at_13(False{}, False{}, tick, previous, input, events, jobs))
      +value = {R.Number{Nat.add(input, 1n)} : R.Value}
      +ending = {C.FinishPublication{3n, False{}, False{}, False{}, 0n, 0n} <> rest : List<&2, C.Task>}
      +a = C.passReleases(w, rest, [], GeneralCuts.frame(R.Number{Nat.add(previous, 1n)}), 0n, value, False{}, False{}, False{}, R.Healthy{})
      +b = Cuts.afterRelease(w, rest, [], value)
      +c = C.afterPass(w, rest, [], 3n, False{}, value, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, False{}, 0n, False{})
      +d = C.publishState(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, 0n, False{})
      +e = C.publicationCompleted(ending, [], 3n, R.Number{0n}, 0n, False{}, B.Bundle{C.world(M.at_14(False{}, False{}, tick, previous, input, events, jobs)), True{}})
      Equal.trans(C.Machine, C.step(M.at_13(False{}, False{}, tick, previous, input, events, jobs)), a, M.at_14(False{}, False{}, tick, previous, input, events, jobs),
        GeneralCuts.step_from_shape(R.Number{Nat.add(previous, 1n)}, M.at_13(False{}, False{}, tick, previous, input, events, jobs), w, rest, [], value, {==}, {==}),
        Equal.trans(C.Machine, a, b, M.at_14(False{}, False{}, tick, previous, input, events, jobs), GeneralCuts.release_empty(R.Number{Nat.add(previous, 1n)}, w, rest, [], value, {==}),
          Equal.trans(C.Machine, b, c, M.at_14(False{}, False{}, tick, previous, input, events, jobs), Cuts.after_release_identity(w, rest, [], value, {==}, {==}),
            Equal.trans(C.Machine, c, d, M.at_14(False{}, False{}, tick, previous, input, events, jobs), Cuts.after_pass_live(w, rest, [], value, {==}, {==}, {==}),
              Equal.trans(C.Machine, d, e, M.at_14(False{}, False{}, tick, previous, input, events, jobs),
                Cuts.default_publish(w, ending, [], 3n, value, False{}, 0n, False{}, R.Number{0n}, 0n, False{}, False{}, False{}, B.Bundle{C.world(M.at_14(False{}, False{}, tick, previous, input, events, jobs)), True{}}, {==}, {==}, {==}, M.publicationAt_13(False{}, False{}, tick, previous, input, events, jobs)),
                {==})))))

def step_13(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_13(prior, tick, previous, input, events, jobs)) == M.state_14(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_13(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_14(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_14(prior,netted,tick, previous, input, events, jobs)) == M.at_15(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_14(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_14(prior, tick, previous, input, events, jobs)) == M.state_15(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_14(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_15(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_15(prior,netted,tick, previous, input, events, jobs)) == M.at_16(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_15(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_15(prior, tick, previous, input, events, jobs)) == M.state_16(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_15(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_16(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_16(prior,netted,tick, previous, input, events, jobs)) == M.at_17(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_16(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_16(prior, tick, previous, input, events, jobs)) == M.state_17(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_16(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_17(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_17(prior,netted,tick, previous, input, events, jobs)) == M.at_18(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_17(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_17(prior, tick, previous, input, events, jobs)) == M.state_18(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_17(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_18(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_18(prior,netted,tick, previous, input, events, jobs)) == M.at_19(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_18(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_18(prior, tick, previous, input, events, jobs)) == M.state_19(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_18(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_19(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_19(prior,netted,tick, previous, input, events, jobs)) == M.at_20(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_19(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_19(prior, tick, previous, input, events, jobs)) == M.state_20(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_19(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_20(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_20(prior,netted,tick, previous, input, events, jobs)) == M.at_21(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_20(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_20(prior, tick, previous, input, events, jobs)) == M.state_21(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_20(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_21(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_21(prior,netted,tick, previous, input, events, jobs)) == M.at_22(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_21(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_21(prior, tick, previous, input, events, jobs)) == M.state_22(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_21(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_22(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_22(prior,netted,tick, previous, input, events, jobs)) == M.at_23(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_22(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_22(prior, tick, previous, input, events, jobs)) == M.state_23(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_22(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_23(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_23(prior,netted,tick, previous, input, events, jobs)) == M.at_24(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_23(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_23(prior, tick, previous, input, events, jobs)) == M.state_24(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_23(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_24(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_24(prior,netted,tick, previous, input, events, jobs)) == M.at_25(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_24(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_24(prior, tick, previous, input, events, jobs)) == M.state_25(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_24(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_25(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_25(prior,netted,tick, previous, input, events, jobs)) == M.at_26(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_25(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_25(prior, tick, previous, input, events, jobs)) == M.state_26(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_25(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_26(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_26(prior,netted,tick, previous, input, events, jobs)) == M.at_27(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_26(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_26(prior, tick, previous, input, events, jobs)) == M.state_27(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_26(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_27(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_27(prior,netted,tick, previous, input, events, jobs)) == M.at_28(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_27(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_27(prior, tick, previous, input, events, jobs)) == M.state_28(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_27(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_28(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_28(prior,netted,tick, previous, input, events, jobs)) == M.at_29(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_28(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_28(prior, tick, previous, input, events, jobs)) == M.state_29(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_28(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_29(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_29(prior,netted,tick, previous, input, events, jobs)) == M.at_30(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_29(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_29(prior, tick, previous, input, events, jobs)) == M.state_30(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_29(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_30(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_30(prior,netted,tick, previous, input, events, jobs)) == M.at_31(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_30(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_30(prior, tick, previous, input, events, jobs)) == M.state_31(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_30(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_31(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_31(prior,netted,tick, previous, input, events, jobs)) == M.at_32(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_31(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_31(prior, tick, previous, input, events, jobs)) == M.state_32(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_31(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_32(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_32(prior,netted,tick, previous, input, events, jobs)) == M.at_33(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_32(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_32(prior, tick, previous, input, events, jobs)) == M.state_33(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_32(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_33(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_33(prior,netted,tick, previous, input, events, jobs)) == M.at_34(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_33(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_33(prior, tick, previous, input, events, jobs)) == M.state_34(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_33(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_34(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_34(prior,netted,tick, previous, input, events, jobs)) == M.at_35(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_34(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_34(prior, tick, previous, input, events, jobs)) == M.state_35(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_34(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_35(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_35(prior,netted,tick, previous, input, events, jobs)) == M.at_36(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_35(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_35(prior, tick, previous, input, events, jobs)) == M.state_36(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_35(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_36(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_36(prior,netted,tick, previous, input, events, jobs)) == M.at_37(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_36(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_36(prior, tick, previous, input, events, jobs)) == M.state_37(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_36(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_37(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_37(prior,netted,tick, previous, input, events, jobs)) == M.at_38(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_37(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_37(prior, tick, previous, input, events, jobs)) == M.state_38(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_37(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_38(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_38(prior,netted,tick, previous, input, events, jobs)) == M.at_39(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_38(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_38(prior, tick, previous, input, events, jobs)) == M.state_39(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_38(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def stepAt_39(+prior: Bool,+netted: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.at_39(prior,netted,tick, previous, input, events, jobs)) == M.at_40(prior,netted,tick, previous, input, events, jobs) : C.Machine}:
  match prior netted:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def step_39(+prior: Bool,+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(M.state_39(prior, tick, previous, input, events, jobs)) == M.state_40(prior, tick, previous, input, events, jobs) : C.Machine}:
  stepAt_39(prior,Nat.is_eq(input,previous),tick, previous, input, events, jobs)

def witness(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> P.Path<M.state_0(prior, tick, previous, input, events, jobs), M.state_40(prior, tick, previous, input, events, jobs)>:
  P.PathStep{M.state_1(prior, tick, previous, input, events, jobs), step_0(prior, tick, previous, input, events, jobs), P.PathStep{M.state_2(prior, tick, previous, input, events, jobs), step_1(prior, tick, previous, input, events, jobs), P.PathStep{M.state_3(prior, tick, previous, input, events, jobs), step_2(prior, tick, previous, input, events, jobs), P.PathStep{M.state_4(prior, tick, previous, input, events, jobs), step_3(prior, tick, previous, input, events, jobs), P.PathStep{M.state_5(prior, tick, previous, input, events, jobs), step_4(prior, tick, previous, input, events, jobs), P.PathStep{M.state_6(prior, tick, previous, input, events, jobs), step_5(prior, tick, previous, input, events, jobs), P.PathStep{M.state_7(prior, tick, previous, input, events, jobs), step_6(prior, tick, previous, input, events, jobs), P.PathStep{M.state_8(prior, tick, previous, input, events, jobs), step_7(prior, tick, previous, input, events, jobs), P.PathStep{M.state_9(prior, tick, previous, input, events, jobs), step_8(prior, tick, previous, input, events, jobs), P.PathStep{M.state_10(prior, tick, previous, input, events, jobs), step_9(prior, tick, previous, input, events, jobs), P.PathStep{M.state_11(prior, tick, previous, input, events, jobs), step_10(prior, tick, previous, input, events, jobs), P.PathStep{M.state_12(prior, tick, previous, input, events, jobs), step_11(prior, tick, previous, input, events, jobs), P.PathStep{M.state_13(prior, tick, previous, input, events, jobs), step_12(prior, tick, previous, input, events, jobs), P.PathStep{M.state_14(prior, tick, previous, input, events, jobs), step_13(prior, tick, previous, input, events, jobs), P.PathStep{M.state_15(prior, tick, previous, input, events, jobs), step_14(prior, tick, previous, input, events, jobs), P.PathStep{M.state_16(prior, tick, previous, input, events, jobs), step_15(prior, tick, previous, input, events, jobs), P.PathStep{M.state_17(prior, tick, previous, input, events, jobs), step_16(prior, tick, previous, input, events, jobs), P.PathStep{M.state_18(prior, tick, previous, input, events, jobs), step_17(prior, tick, previous, input, events, jobs), P.PathStep{M.state_19(prior, tick, previous, input, events, jobs), step_18(prior, tick, previous, input, events, jobs), P.PathStep{M.state_20(prior, tick, previous, input, events, jobs), step_19(prior, tick, previous, input, events, jobs), P.PathStep{M.state_21(prior, tick, previous, input, events, jobs), step_20(prior, tick, previous, input, events, jobs), P.PathStep{M.state_22(prior, tick, previous, input, events, jobs), step_21(prior, tick, previous, input, events, jobs), P.PathStep{M.state_23(prior, tick, previous, input, events, jobs), step_22(prior, tick, previous, input, events, jobs), P.PathStep{M.state_24(prior, tick, previous, input, events, jobs), step_23(prior, tick, previous, input, events, jobs), P.PathStep{M.state_25(prior, tick, previous, input, events, jobs), step_24(prior, tick, previous, input, events, jobs), P.PathStep{M.state_26(prior, tick, previous, input, events, jobs), step_25(prior, tick, previous, input, events, jobs), P.PathStep{M.state_27(prior, tick, previous, input, events, jobs), step_26(prior, tick, previous, input, events, jobs), P.PathStep{M.state_28(prior, tick, previous, input, events, jobs), step_27(prior, tick, previous, input, events, jobs), P.PathStep{M.state_29(prior, tick, previous, input, events, jobs), step_28(prior, tick, previous, input, events, jobs), P.PathStep{M.state_30(prior, tick, previous, input, events, jobs), step_29(prior, tick, previous, input, events, jobs), P.PathStep{M.state_31(prior, tick, previous, input, events, jobs), step_30(prior, tick, previous, input, events, jobs), P.PathStep{M.state_32(prior, tick, previous, input, events, jobs), step_31(prior, tick, previous, input, events, jobs), P.PathStep{M.state_33(prior, tick, previous, input, events, jobs), step_32(prior, tick, previous, input, events, jobs), P.PathStep{M.state_34(prior, tick, previous, input, events, jobs), step_33(prior, tick, previous, input, events, jobs), P.PathStep{M.state_35(prior, tick, previous, input, events, jobs), step_34(prior, tick, previous, input, events, jobs), P.PathStep{M.state_36(prior, tick, previous, input, events, jobs), step_35(prior, tick, previous, input, events, jobs), P.PathStep{M.state_37(prior, tick, previous, input, events, jobs), step_36(prior, tick, previous, input, events, jobs), P.PathStep{M.state_38(prior, tick, previous, input, events, jobs), step_37(prior, tick, previous, input, events, jobs), P.PathStep{M.state_39(prior, tick, previous, input, events, jobs), step_38(prior, tick, previous, input, events, jobs), P.PathStep{M.state_40(prior, tick, previous, input, events, jobs), step_39(prior, tick, previous, input, events, jobs), P.PathEnd{M.finalWorld(prior, tick, previous, input, events, jobs), [], {==}, {==}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}


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

def flush_eq(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>, +extra: Nat) -> {A.flush(Nat.add(40n, extra), C.world(M.state_0(prior, tick, previous, input, events, jobs))) == C.world(M.state_40(prior, tick, previous, input, events, jobs)) : R.World}:
  Cuts.flush_from_shape(Nat.add(40n, extra), C.world(M.state_0(prior, tick, previous, input, events, jobs)), M.state_0(prior, tick, previous, input, events, jobs), M.state_40(prior, tick, previous, input, events, jobs), {==}, {==},
    retimed(M.state_0(prior, tick, previous, input, events, jobs), M.state_40(prior, tick, previous, input, events, jobs), witness(prior, tick, previous, input, events, jobs), extra, Nat.add(40n, extra), {==}))

def viewTransport(-a: R.World, -b: R.World, e: {a == b : R.World}) -> {Driver.view(a) == Driver.view(b) : Driver.View}:
  %e : {Driver.view(a) == Driver.view(_) : Driver.View}
  {==}

def every_staged_input(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>, +extra: Nat) ->
  {Driver.view(A.flush(Nat.add(40n, extra), C.world(M.state_0(prior, tick, previous, input, events, jobs)))) == Driver.expected(input) : Driver.View}:
  viewTransport(A.flush(Nat.add(40n, extra), C.world(M.state_0(prior, tick, previous, input, events, jobs))), C.world(M.state_40(prior, tick, previous, input, events, jobs)), flush_eq(prior, tick, previous, input, events, jobs, extra))
