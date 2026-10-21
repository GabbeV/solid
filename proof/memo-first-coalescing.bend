# Coalescing before the first flush, using the real constructor's staged shape.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/write.bend as W
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-general-states.bend as M
import ./memo-setter-cuts.bend as Cuts
import ./paths.bend as P
import ./memo-staging.bend as Timing
import ./memo-coalescing.bend as Shared

def staging(+initial: Nat, +pending: Nat, +input: Nat) ->
  {W.stageResolved(C.world(M.state_0(initial, pending)), 2n, R.Number{input}) == C.world(M.state_0(initial, input)) : R.World}:
  +before = C.world(M.state_0(initial, pending))
  +after = C.world(M.state_0(initial, input))
  +node = B.node(before, 2n)
  Equal.trans(R.World, W.stageResolved(before, 2n, R.Number{input}), Cuts.tail(after, 2n, node, True{}), after,
    {==}, Shared.tail_suppressed(after, 2n, node, {==}, {==}, {==}))

def resolved(+initial: Nat, +pending: Nat, +input: Nat) ->
  {W.setResolved(C.world(M.state_0(initial, pending)), 2n, R.Number{pending}, R.Number{input}) == C.world(M.state_0(initial, input)) : R.World}:
  +before = C.world(M.state_0(initial, pending))
  Equal.trans(R.World, W.setResolved(before, 2n, R.Number{pending}, R.Number{input}), W.stageResolved(before, 2n, R.Number{input}), C.world(M.state_0(initial, input)), Cuts.entry(before, 2n, R.Number{pending}, R.Number{input}, {==}, {==}, {==}, {==}), staging(initial, pending, input))

def start(+initial: Nat, +pending: Nat, +input: Nat) -> C.Machine:
  C.Machine{C.world(M.state_0(initial, pending)), [C.SetSignalArgument{2n}], [R.Number{input}]}

def middle(+initial: Nat, +pending: Nat, +input: Nat) -> C.Machine:
  C.Machine{C.world(M.state_0(initial, pending)), [C.SetSignalResolved{2n, R.Number{pending}}], [R.Number{input}]}

def end(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{C.world(M.state_0(initial, input)), [], [R.Number{input}]}

def step_0(+initial: Nat, +pending: Nat, +input: Nat) ->
  {C.step(start(initial, pending, input)) == middle(initial, pending, input) : C.Machine}:
  Cuts.step_head(C.world(M.state_0(initial, pending)), C.SetSignalArgument{2n}, [], [R.Number{input}], {==})

def step_1(+initial: Nat, +pending: Nat, +input: Nat) ->
  {C.step(middle(initial, pending, input)) == end(initial, input) : C.Machine}:
  +before = C.world(M.state_0(initial, pending))
  Equal.trans(C.Machine, C.step(middle(initial, pending, input)), C.setResolved(before, [], [], 2n, R.Number{pending}, R.Number{input}), end(initial, input),
    Cuts.step_head(before, C.SetSignalResolved{2n, R.Number{pending}}, [], [R.Number{input}], {==}),
    Equal.trans(C.Machine, C.setResolved(before, [], [], 2n, R.Number{pending}, R.Number{input}), C.Machine{W.setResolved(before, 2n, R.Number{pending}, R.Number{input}), [], [R.Number{input}]}, end(initial, input),
      Cuts.core_default(before, [], [], 2n, R.Number{pending}, R.Number{input}, {==}),
      Equal.cong(R.World, C.Machine, w => C.Machine{w, [], [R.Number{input}]}, W.setResolved(before, 2n, R.Number{pending}, R.Number{input}), C.world(M.state_0(initial, input)), resolved(initial, pending, input))))

def path(+initial: Nat, +pending: Nat, +input: Nat) -> P.Path<start(initial, pending, input), end(initial, input)>:
  P.PathStep{middle(initial, pending, input), step_0(initial, pending, input), P.PathStep{end(initial, input), step_1(initial, pending, input), P.PathEnd{C.world(M.state_0(initial, input)), [R.Number{input}], {==}, {==}}}}

def completes(+initial: Nat, +pending: Nat, +input: Nat) ->
  {C.run(24n, start(initial, pending, input)) == end(initial, input) : C.Machine}:
  Timing.retimed(start(initial, pending, input), end(initial, input), path(initial, pending, input), 22n, 24n, {==})

def public_setter(+initial: Nat, +pending: Nat, +input: Nat) ->
  {A.setSignal(C.world(M.state_0(initial, pending)), 2n, R.Number{input}) == C.world(M.state_0(initial, input)) : R.World}:
  Cuts.api_set_completed(C.world(M.state_0(initial, pending)), 2n, R.Number{input}, 24n, start(initial, pending, input), end(initial, input), C.world(M.state_0(initial, input)), {==}, {==}, {==}, {==}, completes(initial, pending, input), {==})
