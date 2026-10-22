# Checked: actual public setter reaches the complete graph's staged arena.
import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/write.bend as W
import ../runtime/scheduler.bend as S
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../proof/memo-setter-cuts.bend as Cuts
import ../proof/paths.bend as P
import ../proof/memo-staging.bend as Existing
import ../proof/chain.bend as Chain
import ./chain-constructor.bend as Constructor
import ./chain-notification.bend as Notify
import ./chain-states.bend as M

# Source helper checkpoints are independently checked, not generated answers.
def prefix(+input: Nat) -> {Cuts.noSlot(M.origin(), 2n, R.Number{input}) == M.setter_slot(input) : R.World}:
  {==}

def notify(+input: Nat) -> {W.insertSubs(M.setter_slot(input), 2n) == M.setter_inserted(input) : R.World}:
  Notify.complete(input)

def schedule(+input: Nat) -> {B.schedule(M.setter_inserted(input)) == M.setter_scheduled(input) : R.World}:
  {==}

def staged_shape(+input: Nat) -> {M.setter_scheduled(input) == C.world(M.state_0(input)) : R.World}:
  {==}

def stage_end(+w: R.World, +value: R.Value, +slotted: R.World, +inserted: R.World, +scheduled: R.World, +end: R.World,
  noPending: {B.present(R.Node.pending(B.node(w, 2n))) == False{} : Bool},
  slot: {Cuts.noSlot(w, 2n, value) == slotted : R.World},
  signalKind: {B.computed(R.Node.kind(B.node(w, 2n))) == False{} : Bool},
  noContext: {Nat.is_ne(R.World.context(slotted), 0n) == False{} : Bool},
  notify: {W.insertSubs(slotted, 2n) == inserted : R.World},
  schedule: {B.schedule(inserted) == scheduled : R.World},
  shape: {scheduled == end : R.World}) ->
  {W.stageResolved(w, 2n, value) == end : R.World}:
  Equal.trans(R.World, W.stageResolved(w, 2n, value), B.schedule(W.insertSubs(slotted, 2n)), end,
    Cuts.staged_to_slot(w, 2n, value, slotted, noPending, slot, noContext, signalKind),
    Equal.trans(R.World, B.schedule(W.insertSubs(slotted, 2n)), B.schedule(inserted), end,
      Equal.cong(R.World, R.World, world => B.schedule(world), W.insertSubs(slotted, 2n), inserted, notify),
      Equal.trans(R.World, B.schedule(inserted), scheduled, end, schedule, shape)))

def staging(+input: Nat) -> {W.stageResolved(M.origin(), 2n, R.Number{input}) == C.world(M.state_0(input)) : R.World}:
  stage_end(M.origin(), R.Number{input}, M.setter_slot(input), M.setter_inserted(input), M.setter_scheduled(input), C.world(M.state_0(input)), {==}, prefix(input), {==}, {==}, notify(input), schedule(input), staged_shape(input))

def resolved(+input: Nat) -> {W.setResolved(M.origin(), 2n, R.Number{0n}, R.Number{input}) == C.world(M.state_0(input)) : R.World}:
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
      Cuts.core_default(M.origin(), [], [], 2n, R.Number{0n}, R.Number{input}, {==}, {==}),
      Equal.cong(R.World, C.Machine, w => C.Machine{w, [], [R.Number{input}]}, W.setResolved(M.origin(), 2n, R.Number{0n}, R.Number{input}), C.world(M.state_0(input)), resolved(input))))

def path(+input: Nat) -> P.Path<start(input), end(input)>:
  P.PathStep{middle(input), step_0(input), P.PathStep{end(input), step_1(input), P.PathEnd{C.world(M.state_0(input)), [R.Number{input}], {==}, {==}}}}

def completes(+input: Nat) -> {C.run(44n, start(input)) == end(input) : C.Machine}:
  Existing.retimed(start(input), end(input), path(input), 42n, 44n, {==})

def public_setter(+input: Nat) -> {A.setSignal(M.origin(), 2n, R.Number{input}) == C.world(M.state_0(input)) : R.World}:
  Cuts.api_set_completed(M.origin(), 2n, R.Number{input}, 44n, start(input), end(input), C.world(M.state_0(input)), {==}, {==}, {==}, {==}, completes(input), {==})

def constructor_transport(+a: R.World, +b: R.World, +input: Nat, same: {a == b : R.World}) ->
  {A.setSignal(a, 2n, R.Number{input}) == A.setSignal(b, 2n, R.Number{input}) : R.World}:
  Equal.cong(R.World, R.World, w => A.setSignal(w, 2n, R.Number{input}), a, b, same)

def constructed(+input: Nat) -> {A.setSignal(Chain.initial(), 2n, R.Number{input}) == C.world(M.state_0(input)) : R.World}:
  Equal.trans(R.World, A.setSignal(Chain.initial(), 2n, R.Number{input}), A.setSignal(M.origin(), 2n, R.Number{input}), C.world(M.state_0(input)),
    constructor_transport(Chain.initial(), M.origin(), input, Constructor.constructed()), public_setter(input))
