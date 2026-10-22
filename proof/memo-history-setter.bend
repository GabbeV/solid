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

def staging(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {W.stageResolved(M.origin(tick, previous, events, jobs), 2n, R.Number{input}) == D.scheduled(tick, previous, input, events, jobs) : R.World}:
  Equal.trans(R.World, W.stageResolved(M.origin(tick, previous, events, jobs), 2n, R.Number{input}), B.schedule(W.insertSubs(D.slotted(tick, previous, input, events, jobs), 2n)), D.scheduled(tick, previous, input, events, jobs),
    Cuts.staged_to_slot(M.origin(tick, previous, events, jobs), 2n, R.Number{input}, D.slotted(tick, previous, input, events, jobs), {==}, Checks.prefix(tick, previous, input, events, jobs), {==}, {==}),
    Equal.trans(R.World, B.schedule(W.insertSubs(D.slotted(tick, previous, input, events, jobs), 2n)), D.scheduled(tick, previous, input, events, jobs), D.scheduled(tick, previous, input, events, jobs),
      Equal.trans(R.World, B.schedule(W.insertSubs(D.slotted(tick, previous, input, events, jobs), 2n)), B.schedule(D.inserted(tick, previous, input, events, jobs)), D.scheduled(tick, previous, input, events, jobs),
        Equal.cong(R.World, R.World, w => B.schedule(w), W.insertSubs(D.slotted(tick, previous, input, events, jobs), 2n), D.inserted(tick, previous, input, events, jobs), Checks.notify(tick, previous, input, events, jobs)), Checks.schedule(tick, previous, input, events, jobs)), {==}))

def resolved(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) ->
  {W.setResolved(M.origin(tick, previous, events, jobs), 2n, R.Number{previous}, R.Number{input}) == D.scheduled(tick, previous, input, events, jobs) : R.World}:
  Equal.trans(R.World, W.setResolved(M.origin(tick, previous, events, jobs), 2n, R.Number{previous}, R.Number{input}), W.stageResolved(M.origin(tick, previous, events, jobs), 2n, R.Number{input}), D.scheduled(tick, previous, input, events, jobs),
    Cuts.entry(M.origin(tick, previous, events, jobs), 2n, R.Number{previous}, R.Number{input}, {==}, {==}, {==}, {==}), staging(tick, previous, input, events, jobs))

def start(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{M.origin(tick, previous, events, jobs), [C.SetSignalArgument{2n}], [R.Number{input}]}

def middle(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{M.origin(tick, previous, events, jobs), [C.SetSignalResolved{2n, R.Number{previous}}], [R.Number{input}]}

def end(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> C.Machine:
  C.Machine{D.scheduled(tick, previous, input, events, jobs), [], [R.Number{input}]}

def step_0(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(start(tick, previous, input, events, jobs)) == middle(tick, previous, input, events, jobs) : C.Machine}:
  Cuts.step_head(M.origin(tick, previous, events, jobs), C.SetSignalArgument{2n}, [], [R.Number{input}], {==})

def step_1(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.step(middle(tick, previous, input, events, jobs)) == end(tick, previous, input, events, jobs) : C.Machine}:
  Equal.trans(C.Machine, C.step(middle(tick, previous, input, events, jobs)), C.setResolved(M.origin(tick, previous, events, jobs), [], [], 2n, R.Number{previous}, R.Number{input}), end(tick, previous, input, events, jobs),
    Cuts.step_head(M.origin(tick, previous, events, jobs), C.SetSignalResolved{2n, R.Number{previous}}, [], [R.Number{input}], {==}),
    Equal.trans(C.Machine, C.setResolved(M.origin(tick, previous, events, jobs), [], [], 2n, R.Number{previous}, R.Number{input}), C.Machine{W.setResolved(M.origin(tick, previous, events, jobs), 2n, R.Number{previous}, R.Number{input}), [], [R.Number{input}]}, end(tick, previous, input, events, jobs),
      Cuts.core_default(M.origin(tick, previous, events, jobs), [], [], 2n, R.Number{previous}, R.Number{input}, {==}, {==}),
      Equal.cong(R.World, C.Machine, w => C.Machine{w, [], [R.Number{input}]}, W.setResolved(M.origin(tick, previous, events, jobs), 2n, R.Number{previous}, R.Number{input}), D.scheduled(tick, previous, input, events, jobs), resolved(tick, previous, input, events, jobs))))

def path(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> P.Path<start(tick, previous, input, events, jobs), end(tick, previous, input, events, jobs)>:
  P.PathStep{middle(tick, previous, input, events, jobs), step_0(tick, previous, input, events, jobs), P.PathStep{end(tick, previous, input, events, jobs), step_1(tick, previous, input, events, jobs), P.PathEnd{D.scheduled(tick, previous, input, events, jobs), [R.Number{input}], {==}, {==}}}}

def completes(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {C.run(24n, start(tick, previous, input, events, jobs)) == end(tick, previous, input, events, jobs) : C.Machine}:
  Existing.retimed(start(tick, previous, input, events, jobs), end(tick, previous, input, events, jobs), path(tick, previous, input, events, jobs), 22n, 24n, {==})

def public_setter(+tick: Nat, +previous: Nat, +input: Nat, +events: List<&2, R.TraceEvent>, +jobs: List<&2, R.HostJob>) -> {A.setSignal(M.origin(tick, previous, events, jobs), 2n, R.Number{input}) == D.scheduled(tick, previous, input, events, jobs) : R.World}:
  Cuts.api_set_completed(M.origin(tick, previous, events, jobs), 2n, R.Number{input}, 24n, start(tick, previous, input, events, jobs), end(tick, previous, input, events, jobs), D.scheduled(tick, previous, input, events, jobs), {==}, {==}, {==}, {==}, completes(tick, previous, input, events, jobs), {==})
