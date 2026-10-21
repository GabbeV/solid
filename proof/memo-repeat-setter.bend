import Base
import ../runtime/write.bend as W
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-repeat-states.bend as M
import ./memo-setter-cuts.bend as Cuts
import ./memo-repeat-setter-data.bend as D
import ./memo-repeat-setter-checks.bend as Checks
import ../runtime/api.bend as A
import ./paths.bend as P
import ./memo-staging.bend as Existing

def staging(+initial: Nat, +first: Nat, +input: Nat) ->
  {W.stageResolved(M.origin(initial, first), 2n, R.Number{input}) == D.scheduled(initial, first, input) : R.World}:
  Equal.trans(R.World, W.stageResolved(M.origin(initial, first), 2n, R.Number{input}), B.schedule(W.insertSubs(D.slotted(initial, first, input), 2n)), D.scheduled(initial, first, input),
    Cuts.staged_to_slot(M.origin(initial, first), 2n, R.Number{input}, D.slotted(initial, first, input), {==}, Checks.prefix(initial, first, input), {==}, {==}),
    Equal.trans(R.World, B.schedule(W.insertSubs(D.slotted(initial, first, input), 2n)), D.scheduled(initial, first, input), D.scheduled(initial, first, input),
      Equal.trans(R.World, B.schedule(W.insertSubs(D.slotted(initial, first, input), 2n)), B.schedule(D.inserted(initial, first, input)), D.scheduled(initial, first, input),
        Equal.cong(R.World, R.World, w => B.schedule(w), W.insertSubs(D.slotted(initial, first, input), 2n), D.inserted(initial, first, input), Checks.notify(initial, first, input)), Checks.schedule(initial, first, input)), {==}))

def resolved(+initial: Nat, +first: Nat, +input: Nat) ->
  {W.setResolved(M.origin(initial, first), 2n, R.Number{first}, R.Number{input}) == D.scheduled(initial, first, input) : R.World}:
  Equal.trans(R.World, W.setResolved(M.origin(initial, first), 2n, R.Number{first}, R.Number{input}), W.stageResolved(M.origin(initial, first), 2n, R.Number{input}), D.scheduled(initial, first, input),
    Cuts.entry(M.origin(initial, first), 2n, R.Number{first}, R.Number{input}, {==}, {==}, {==}, {==}), staging(initial, first, input))

def start(+initial: Nat, +first: Nat, input: Nat) -> C.Machine:
  C.Machine{M.origin(initial, first), [C.SetSignalArgument{2n}], [R.Number{input}]}

def middle(+initial: Nat, +first: Nat, input: Nat) -> C.Machine:
  C.Machine{M.origin(initial, first), [C.SetSignalResolved{2n, R.Number{first}}], [R.Number{input}]}

def end(+initial: Nat, +first: Nat, +input: Nat) -> C.Machine:
  C.Machine{D.scheduled(initial, first, input), [], [R.Number{input}]}

def step_0(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(start(initial, first, input)) == middle(initial, first, input) : C.Machine}:
  Cuts.step_head(M.origin(initial, first), C.SetSignalArgument{2n}, [], [R.Number{input}], {==})

def step_1(+initial: Nat, +first: Nat, +input: Nat) -> {C.step(middle(initial, first, input)) == end(initial, first, input) : C.Machine}:
  Equal.trans(C.Machine, C.step(middle(initial, first, input)), C.setResolved(M.origin(initial, first), [], [], 2n, R.Number{first}, R.Number{input}), end(initial, first, input),
    Cuts.step_head(M.origin(initial, first), C.SetSignalResolved{2n, R.Number{first}}, [], [R.Number{input}], {==}),
    Equal.trans(C.Machine, C.setResolved(M.origin(initial, first), [], [], 2n, R.Number{first}, R.Number{input}), C.Machine{W.setResolved(M.origin(initial, first), 2n, R.Number{first}, R.Number{input}), [], [R.Number{input}]}, end(initial, first, input),
      Cuts.core_default(M.origin(initial, first), [], [], 2n, R.Number{first}, R.Number{input}, {==}),
      Equal.cong(R.World, C.Machine, w => C.Machine{w, [], [R.Number{input}]}, W.setResolved(M.origin(initial, first), 2n, R.Number{first}, R.Number{input}), D.scheduled(initial, first, input), resolved(initial, first, input))))

def path(+initial: Nat, +first: Nat, +input: Nat) -> P.Path<start(initial, first, input), end(initial, first, input)>:
  P.PathStep{middle(initial, first, input), step_0(initial, first, input), P.PathStep{end(initial, first, input), step_1(initial, first, input), P.PathEnd{D.scheduled(initial, first, input), [R.Number{input}], {==}, {==}}}}

def completes(+initial: Nat, +first: Nat, +input: Nat) -> {C.run(24n, start(initial, first, input)) == end(initial, first, input) : C.Machine}:
  Existing.retimed(start(initial, first, input), end(initial, first, input), path(initial, first, input), 22n, 24n, {==})

def public_setter(+initial: Nat, +first: Nat, +input: Nat) -> {A.setSignal(M.origin(initial, first), 2n, R.Number{input}) == D.scheduled(initial, first, input) : R.World}:
  Cuts.api_set_completed(M.origin(initial, first), 2n, R.Number{input}, 24n, start(initial, first, input), end(initial, first, input), D.scheduled(initial, first, input), {==}, {==}, {==}, {==}, completes(initial, first, input), {==})

