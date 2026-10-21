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

def staging(+first: Nat, +input: Nat) ->
  {W.stageResolved(M.origin(first), 2n, R.Number{input}) == D.scheduled(first, input) : R.World}:
  Equal.trans(R.World, W.stageResolved(M.origin(first), 2n, R.Number{input}), B.schedule(W.insertSubs(D.slotted(first, input), 2n)), D.scheduled(first, input),
    Cuts.staged_to_slot(M.origin(first), 2n, R.Number{input}, D.slotted(first, input), {==}, Checks.prefix(first, input), {==}, {==}),
    Equal.trans(R.World, B.schedule(W.insertSubs(D.slotted(first, input), 2n)), D.scheduled(first, input), D.scheduled(first, input),
      Equal.trans(R.World, B.schedule(W.insertSubs(D.slotted(first, input), 2n)), B.schedule(D.inserted(first, input)), D.scheduled(first, input),
        Equal.cong(R.World, R.World, w => B.schedule(w), W.insertSubs(D.slotted(first, input), 2n), D.inserted(first, input), Checks.notify(first, input)), Checks.schedule(first, input)), {==}))

def resolved(+first: Nat, +input: Nat) ->
  {W.setResolved(M.origin(first), 2n, R.Number{first}, R.Number{input}) == D.scheduled(first, input) : R.World}:
  Equal.trans(R.World, W.setResolved(M.origin(first), 2n, R.Number{first}, R.Number{input}), W.stageResolved(M.origin(first), 2n, R.Number{input}), D.scheduled(first, input),
    Cuts.entry(M.origin(first), 2n, R.Number{first}, R.Number{input}, {==}, {==}, {==}, {==}), staging(first, input))

def start(+first: Nat, input: Nat) -> C.Machine:
  C.Machine{M.origin(first), [C.SetSignalArgument{2n}], [R.Number{input}]}

def middle(+first: Nat, input: Nat) -> C.Machine:
  C.Machine{M.origin(first), [C.SetSignalResolved{2n, R.Number{first}}], [R.Number{input}]}

def end(+first: Nat, +input: Nat) -> C.Machine:
  C.Machine{D.scheduled(first, input), [], [R.Number{input}]}

def step_0(+first: Nat, +input: Nat) -> {C.step(start(first, input)) == middle(first, input) : C.Machine}:
  Cuts.step_head(M.origin(first), C.SetSignalArgument{2n}, [], [R.Number{input}], {==})

def step_1(+first: Nat, +input: Nat) -> {C.step(middle(first, input)) == end(first, input) : C.Machine}:
  Equal.trans(C.Machine, C.step(middle(first, input)), C.setResolved(M.origin(first), [], [], 2n, R.Number{first}, R.Number{input}), end(first, input),
    Cuts.step_head(M.origin(first), C.SetSignalResolved{2n, R.Number{first}}, [], [R.Number{input}], {==}),
    Equal.trans(C.Machine, C.setResolved(M.origin(first), [], [], 2n, R.Number{first}, R.Number{input}), C.Machine{W.setResolved(M.origin(first), 2n, R.Number{first}, R.Number{input}), [], [R.Number{input}]}, end(first, input),
      Cuts.core_default(M.origin(first), [], [], 2n, R.Number{first}, R.Number{input}, {==}),
      Equal.cong(R.World, C.Machine, w => C.Machine{w, [], [R.Number{input}]}, W.setResolved(M.origin(first), 2n, R.Number{first}, R.Number{input}), D.scheduled(first, input), resolved(first, input))))

def path(+first: Nat, +input: Nat) -> P.Path<start(first, input), end(first, input)>:
  P.PathStep{middle(first, input), step_0(first, input), P.PathStep{end(first, input), step_1(first, input), P.PathEnd{D.scheduled(first, input), [R.Number{input}], {==}, {==}}}}

def completes(+first: Nat, +input: Nat) -> {C.run(24n, start(first, input)) == end(first, input) : C.Machine}:
  Existing.retimed(start(first, input), end(first, input), path(first, input), 22n, 24n, {==})

def public_setter(+first: Nat, +input: Nat) -> {A.setSignal(M.origin(first), 2n, R.Number{input}) == D.scheduled(first, input) : R.World}:
  Cuts.api_set_completed(M.origin(first), 2n, R.Number{input}, 24n, start(first, input), end(first, input), D.scheduled(first, input), {==}, {==}, {==}, {==}, completes(first, input), {==})

