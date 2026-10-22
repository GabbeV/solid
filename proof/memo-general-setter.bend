import Base
import ../runtime/write.bend as W
import ../runtime/core.bend as C
import ../representation/base.bend as B
import ../representation/records.bend as R
import ./memo-initial-data.bend as M
import ./memo-initial.bend as Constructor
import ./memo-initial-driver.bend as ConstructorDriver
import ./memo-constructor-cuts.bend as ConstructorCuts
import ./memo-setter-cuts.bend as Cuts
import ./memo-general-setter-data.bend as D
import ./memo-general-setter-checks.bend as Checks
import ../runtime/api.bend as A
import ./paths.bend as P
import ./memo-staging.bend as Existing

def staging(+initial: Nat, +input: Nat) ->
  {W.stageResolved(M.finished(initial), 2n, R.Number{input}) == D.scheduled(initial, input) : R.World}:
  Equal.trans(R.World, W.stageResolved(M.finished(initial), 2n, R.Number{input}), B.schedule(W.insertSubs(D.slotted(initial, input), 2n)), D.scheduled(initial, input),
    Cuts.staged_to_slot(M.finished(initial), 2n, R.Number{input}, D.slotted(initial, input), {==}, Checks.prefix(initial, input), {==}, {==}),
    Equal.trans(R.World, B.schedule(W.insertSubs(D.slotted(initial, input), 2n)), D.scheduled(initial, input), D.scheduled(initial, input),
      Equal.trans(R.World, B.schedule(W.insertSubs(D.slotted(initial, input), 2n)), B.schedule(D.inserted(initial, input)), D.scheduled(initial, input),
        Equal.cong(R.World, R.World, w => B.schedule(w), W.insertSubs(D.slotted(initial, input), 2n), D.inserted(initial, input), Checks.notify(initial, input)), Checks.schedule(initial, input)), {==}))

def resolved(+initial: Nat, +input: Nat) ->
  {W.setResolved(M.finished(initial), 2n, R.Number{initial}, R.Number{input}) == D.scheduled(initial, input) : R.World}:
  Equal.trans(R.World, W.setResolved(M.finished(initial), 2n, R.Number{initial}, R.Number{input}), W.stageResolved(M.finished(initial), 2n, R.Number{input}), D.scheduled(initial, input),
    Cuts.entry(M.finished(initial), 2n, R.Number{initial}, R.Number{input}, {==}, {==}, {==}, {==}), staging(initial, input))

def start(+initial: Nat, input: Nat) -> C.Machine:
  C.Machine{M.finished(initial), [C.SetSignalArgument{2n}], [R.Number{input}]}

def middle(+initial: Nat, input: Nat) -> C.Machine:
  C.Machine{M.finished(initial), [C.SetSignalResolved{2n, R.Number{initial}}], [R.Number{input}]}

def end(+initial: Nat, +input: Nat) -> C.Machine:
  C.Machine{D.scheduled(initial, input), [], [R.Number{input}]}

def step_0(+initial: Nat, +input: Nat) -> {C.step(start(initial, input)) == middle(initial, input) : C.Machine}:
  Cuts.step_head(M.finished(initial), C.SetSignalArgument{2n}, [], [R.Number{input}], {==})

def step_1(+initial: Nat, +input: Nat) -> {C.step(middle(initial, input)) == end(initial, input) : C.Machine}:
  Equal.trans(C.Machine, C.step(middle(initial, input)), C.setResolved(M.finished(initial), [], [], 2n, R.Number{initial}, R.Number{input}), end(initial, input),
    Cuts.step_head(M.finished(initial), C.SetSignalResolved{2n, R.Number{initial}}, [], [R.Number{input}], {==}),
    Equal.trans(C.Machine, C.setResolved(M.finished(initial), [], [], 2n, R.Number{initial}, R.Number{input}), C.Machine{W.setResolved(M.finished(initial), 2n, R.Number{initial}, R.Number{input}), [], [R.Number{input}]}, end(initial, input),
      Cuts.core_default(M.finished(initial), [], [], 2n, R.Number{initial}, R.Number{input}, {==}, {==}),
      Equal.cong(R.World, C.Machine, w => C.Machine{w, [], [R.Number{input}]}, W.setResolved(M.finished(initial), 2n, R.Number{initial}, R.Number{input}), D.scheduled(initial, input), resolved(initial, input))))

def path(+initial: Nat, +input: Nat) -> P.Path<start(initial, input), end(initial, input)>:
  P.PathStep{middle(initial, input), step_0(initial, input), P.PathStep{end(initial, input), step_1(initial, input), P.PathEnd{D.scheduled(initial, input), [R.Number{input}], {==}, {==}}}}

def completes(+initial: Nat, +input: Nat) -> {C.run(24n, start(initial, input)) == end(initial, input) : C.Machine}:
  Existing.retimed(start(initial, input), end(initial, input), path(initial, input), 22n, 24n, {==})

def public_setter(+initial: Nat, +input: Nat) -> {A.setSignal(M.finished(initial), 2n, R.Number{input}) == D.scheduled(initial, input) : R.World}:
  Cuts.api_set_completed(M.finished(initial), 2n, R.Number{input}, 24n, start(initial, input), end(initial, input), D.scheduled(initial, input), {==}, {==}, {==}, {==}, completes(initial, input), {==})

# Public constructor-to-setter composition for arbitrary initial/proposed values.
# The larger complete update/drain theorem remains a separate proof obligation.
def transport(+a: R.World, +b: R.World, +input: Nat, known: {a == b : R.World}) ->
  {A.setSignal(a, 2n, R.Number{input}) == A.setSignal(b, 2n, R.Number{input}) : R.World}:
  Equal.cong(R.World, R.World, w => A.setSignal(w, 2n, R.Number{input}), a, b, known)

def public_program(+initial: Nat, +input: Nat, +extra: Nat) ->
  {A.setSignal(A.createMemo(Nat.add(14n, extra), ConstructorDriver.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{input}) == D.scheduled(initial, input) : R.World}:
  Equal.trans(R.World, A.setSignal(A.createMemo(Nat.add(14n, extra), ConstructorDriver.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), 2n, R.Number{input}), A.setSignal(M.finished(initial), 2n, R.Number{input}), D.scheduled(initial, input),
    transport(A.createMemo(Nat.add(14n, extra), ConstructorDriver.signal(initial), ConstructorCuts.expr(), False{}, False{}, 1n), M.finished(initial), input, Constructor.constructed(initial, extra)), public_setter(initial, input))
