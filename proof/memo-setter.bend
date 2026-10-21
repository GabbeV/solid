import Base
import ../runtime/write.bend as W
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-states.bend as M
import ./memo-setter-cuts.bend as Cuts
import ./memo-setter-data.bend as D
import ./memo-setter-checks.bend as Checks
import ../runtime/api.bend as A
import ./paths.bend as P
import ./memo-staging.bend as Existing

def staging(+input: Nat) ->
  {W.stageResolved(M.origin(), 2n, R.Number{input}) == C.world(M.state_0(input)) : R.World}:
  Equal.trans(R.World, W.stageResolved(M.origin(), 2n, R.Number{input}), B.schedule(W.insertSubs(D.slotted(input), 2n)), C.world(M.state_0(input)),
    Cuts.staged_to_slot(M.origin(), 2n, R.Number{input}, D.slotted(input), {==}, Checks.prefix(input), {==}, {==}),
    Equal.trans(R.World, B.schedule(W.insertSubs(D.slotted(input), 2n)), D.scheduled(input), C.world(M.state_0(input)),
      Equal.trans(R.World, B.schedule(W.insertSubs(D.slotted(input), 2n)), B.schedule(D.inserted(input)), D.scheduled(input),
        Equal.cong(R.World, R.World, w => B.schedule(w), W.insertSubs(D.slotted(input), 2n), D.inserted(input), Checks.notify(input)), Checks.schedule(input)), Checks.matches(input)))

def resolved(+input: Nat) ->
  {W.setResolved(M.origin(), 2n, R.Number{0n}, R.Number{input}) == C.world(M.state_0(input)) : R.World}:
  Equal.trans(R.World, W.setResolved(M.origin(), 2n, R.Number{0n}, R.Number{input}), W.stageResolved(M.origin(), 2n, R.Number{input}), C.world(M.state_0(input)),
    Cuts.entry(M.origin(), 2n, R.Number{0n}, R.Number{input}, {==}, {==}, {==}, {==}), staging(input))

def start(input: Nat) -> C.Machine:
  C.Machine{M.origin(), [C.SetSignalArgument{2n}], [R.Number{input}]}

def middle(input: Nat) -> C.Machine:
  C.Machine{M.origin(), [C.SetSignalResolved{2n, R.Number{0n}}], [R.Number{input}]}

def end(+input: Nat) -> C.Machine:
  C.Machine{C.world(M.state_0(input)), [], [R.Number{input}]}

def step_0(+input: Nat) -> {C.step(start(input)) == middle(input) : C.Machine}:
  Cuts.step_head(M.origin(), C.SetSignalArgument{2n}, [], [R.Number{input}], {==})

def step_1(+input: Nat) -> {C.step(middle(input)) == end(input) : C.Machine}:
  Equal.trans(C.Machine, C.step(middle(input)), C.setResolved(M.origin(), [], [], 2n, R.Number{0n}, R.Number{input}), end(input),
    Cuts.step_head(M.origin(), C.SetSignalResolved{2n, R.Number{0n}}, [], [R.Number{input}], {==}),
    Equal.trans(C.Machine, C.setResolved(M.origin(), [], [], 2n, R.Number{0n}, R.Number{input}), C.Machine{W.setResolved(M.origin(), 2n, R.Number{0n}, R.Number{input}), [], [R.Number{input}]}, end(input),
      Cuts.core_default(M.origin(), [], [], 2n, R.Number{0n}, R.Number{input}, {==}),
      Equal.cong(R.World, C.Machine, w => C.Machine{w, [], [R.Number{input}]}, W.setResolved(M.origin(), 2n, R.Number{0n}, R.Number{input}), C.world(M.state_0(input)), resolved(input))))

def path(+input: Nat) -> P.Path<start(input), end(input)>:
  P.PathStep{middle(input), step_0(input), P.PathStep{end(input), step_1(input), P.PathEnd{C.world(M.state_0(input)), [R.Number{input}], {==}, {==}}}}

def completes(+input: Nat) -> {C.run(24n, start(input)) == end(input) : C.Machine}:
  Existing.retimed(start(input), end(input), path(input), 22n, 24n, {==})

def public_setter(+input: Nat) -> {A.setSignal(M.origin(), 2n, R.Number{input}) == C.world(M.state_0(input)) : R.World}:
  Cuts.api_set_completed(M.origin(), 2n, R.Number{input}, 24n, start(input), end(input), C.world(M.state_0(input)), {==}, {==}, {==}, {==}, completes(input), {==})
