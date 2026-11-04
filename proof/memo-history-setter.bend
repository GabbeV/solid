import Base
import ../runtime/write.bend as W
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-history-states.bend as M
import ./memo-setter-cuts.bend as Cuts
import ./memo-history-setter-data.bend as D
import ./memo-history-setter-checks.bend as Checks
import ../runtime/api.bend as A
import ./paths.bend as P
import ./memo-staging.bend as Existing

def staging(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {W.stageResolved(M.origin(prior, tick, previous, events, jobs), 2n, R.Number{input}) == D.scheduled(prior, tick, previous, input, events, jobs) : R.World}:
  Equal.trans(R.World, W.stageResolved(M.origin(prior, tick, previous, events, jobs), 2n, R.Number{input}), B.schedule(W.insertSubs(D.slotted(prior, tick, previous, input, events, jobs), 2n)), D.scheduled(prior, tick, previous, input, events, jobs),
    Cuts.staged_to_slot(M.origin(prior, tick, previous, events, jobs), 2n, R.Number{input}, D.slotted(prior, tick, previous, input, events, jobs), {==}, Checks.prefix(prior, tick, previous, input, events, jobs), {==}, {==}),
    Equal.trans(R.World, B.schedule(W.insertSubs(D.slotted(prior, tick, previous, input, events, jobs), 2n)), D.scheduled(prior, tick, previous, input, events, jobs), D.scheduled(prior, tick, previous, input, events, jobs),
      Equal.trans(R.World, B.schedule(W.insertSubs(D.slotted(prior, tick, previous, input, events, jobs), 2n)), B.schedule(D.inserted(prior, tick, previous, input, events, jobs)), D.scheduled(prior, tick, previous, input, events, jobs),
        Equal.cong(R.World, R.World, w => B.schedule(w), W.insertSubs(D.slotted(prior, tick, previous, input, events, jobs), 2n), D.inserted(prior, tick, previous, input, events, jobs), Checks.notify(prior, tick, previous, input, events, jobs)), Checks.schedule(prior, tick, previous, input, events, jobs)), {==}))

def resolved(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {W.setResolved(M.origin(prior, tick, previous, events, jobs), 2n, R.Number{previous}, R.Number{input}) == D.scheduled(prior, tick, previous, input, events, jobs) : R.World}:
  Equal.trans(R.World, W.setResolved(M.origin(prior, tick, previous, events, jobs), 2n, R.Number{previous}, R.Number{input}), W.stageResolved(M.origin(prior, tick, previous, events, jobs), 2n, R.Number{input}), D.scheduled(prior, tick, previous, input, events, jobs),
    Cuts.entry(M.origin(prior, tick, previous, events, jobs), 2n, R.Number{previous}, R.Number{input}, {==}, {==}, {==}, {==}), staging(prior, tick, previous, input, events, jobs))

def start(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{M.origin(prior, tick, previous, events, jobs), [C.SetSignalArgument{2n}], [R.Number{input}]}

def middle(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{M.origin(prior, tick, previous, events, jobs), [C.SetSignalResolved{2n, R.Number{previous}}], [R.Number{input}]}

def end(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{D.scheduled(prior, tick, previous, input, events, jobs), [], [R.Number{input}]}

def step_0(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(start(prior, tick, previous, input, events, jobs)) == middle(prior, tick, previous, input, events, jobs) : C.Machine}:
  Cuts.step_head(M.origin(prior, tick, previous, events, jobs), C.SetSignalArgument{2n}, [], [R.Number{input}], {==})

def step_1(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(middle(prior, tick, previous, input, events, jobs)) == end(prior, tick, previous, input, events, jobs) : C.Machine}:
  Equal.trans(C.Machine, C.step(middle(prior, tick, previous, input, events, jobs)), C.setResolved(M.origin(prior, tick, previous, events, jobs), [], [], 2n, R.Number{previous}, R.Number{input}), end(prior, tick, previous, input, events, jobs),
    Cuts.step_head(M.origin(prior, tick, previous, events, jobs), C.SetSignalResolved{2n, R.Number{previous}}, [], [R.Number{input}], {==}),
    Equal.trans(C.Machine, C.setResolved(M.origin(prior, tick, previous, events, jobs), [], [], 2n, R.Number{previous}, R.Number{input}), C.Machine{W.setResolved(M.origin(prior, tick, previous, events, jobs), 2n, R.Number{previous}, R.Number{input}), [], [R.Number{input}]}, end(prior, tick, previous, input, events, jobs),
      Cuts.core_default(M.origin(prior, tick, previous, events, jobs), [], [], 2n, R.Number{previous}, R.Number{input}, {==}, {==}),
      Equal.cong(R.World, C.Machine, w => C.Machine{w, [], [R.Number{input}]}, W.setResolved(M.origin(prior, tick, previous, events, jobs), 2n, R.Number{previous}, R.Number{input}), D.scheduled(prior, tick, previous, input, events, jobs), resolved(prior, tick, previous, input, events, jobs))))

def path(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> P.Path<start(prior, tick, previous, input, events, jobs), end(prior, tick, previous, input, events, jobs)>:
  P.PathStep{middle(prior, tick, previous, input, events, jobs), step_0(prior, tick, previous, input, events, jobs), P.PathStep{end(prior, tick, previous, input, events, jobs), step_1(prior, tick, previous, input, events, jobs), P.PathEnd{D.scheduled(prior, tick, previous, input, events, jobs), [R.Number{input}], {==}, {==}}}}

def completes(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.run(24n, start(prior, tick, previous, input, events, jobs)) == end(prior, tick, previous, input, events, jobs) : C.Machine}:
  Existing.retimed(start(prior, tick, previous, input, events, jobs), end(prior, tick, previous, input, events, jobs), path(prior, tick, previous, input, events, jobs), 22n, 24n, {==})

def public_setter(+prior: Bool, +tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {A.setSignal(M.origin(prior, tick, previous, events, jobs), 2n, R.Number{input}) == D.scheduled(prior, tick, previous, input, events, jobs) : R.World}:
  Cuts.api_set_completed(M.origin(prior, tick, previous, events, jobs), 2n, R.Number{input}, 24n, start(prior, tick, previous, input, events, jobs), end(prior, tick, previous, input, events, jobs), D.scheduled(prior, tick, previous, input, events, jobs), {==}, {==}, {==}, {==}, completes(prior, tick, previous, input, events, jobs), {==})
