# Proof-only cuts for the actual publication helper, no runtime change.
import Base
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../runtime/core.bend as C
import ../runtime/scheduler.bend as S
import ../runtime/equality.bend as EQ
import ../proof/publication-stage.bend as Stage
import ./chain-states.bend as M

def and_false_right(b: Bool) -> {Bool.and(b, False{}) == False{} : Bool}:
  match b:
    case True{}:
      {==}
    case False{}:
      {==}

def disabled(+w: R.World, +id: Nat, +a: R.Value, +b: R.Value, off: {R.Node.equals(B.node(w, id)) == False{} : Bool}) ->
  {EQ.isSame(w, id, a, b) == False{} : Bool}:
  Equal.cong(Bool, Bool, e => Bool.and(e, B.equal(a, b)), R.Node.equals(B.node(w, id)), False{}, off)

def flags(+effect: Bool, +shown: Bool) ->
  {Bool.or(Bool.and(Bool.not(effect), False{}), Bool.or(shown, Bool.not(False{}))) == True{} : Bool}:
  match effect shown:
    case True{} True{}:
      {==}
    case True{} False{}:
      {==}
    case False{} True{}:
      {==}
    case False{} False{}:
      {==}

def selected(+w: R.World, +id: Nat, +value: R.Value, +height: Nat, same: Bool) -> B.Bundle<R.World, Bool>:
  C.publishValueChanged(w, id, value, False{}, height, False{}, Bool.or(Bool.and(Bool.not(B.effect(R.Node.kind(B.node(w, id)))), False{}), Bool.or(B.truth(R.NodeExtension.shownError(B.extension(w, id))), Bool.not(same))))

def changed(+w: R.World, +id: Nat, +value: R.Value, +height: Nat, no: {EQ.isSame(w, id, B.current(B.node(w, id)), value) == False{} : Bool}) ->
  {C.publishValue(w, id, value, False{}, height, False{}, False{}) == C.publishValueChanged(w, id, value, False{}, height, False{}, True{}) : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, C.publishValue(w, id, value, False{}, height, False{}, False{}), selected(w, id, value, height, False{}), C.publishValueChanged(w, id, value, False{}, height, False{}, True{}),
    Equal.cong(Bool, B.Bundle<R.World, Bool>, same => selected(w, id, value, height, same), EQ.isSame(w, id, B.current(B.node(w, id)), value), False{}, no),
    Equal.cong(Bool, B.Bundle<R.World, Bool>, flag => C.publishValueChanged(w, id, value, False{}, height, False{}, flag), Bool.or(Bool.and(Bool.not(B.effect(R.Node.kind(B.node(w, id)))), False{}), Bool.or(B.truth(R.NodeExtension.shownError(B.extension(w, id))), Bool.not(False{}))), True{}, flags(B.effect(R.Node.kind(B.node(w, id))), B.truth(R.NodeExtension.shownError(B.extension(w, id))))))

def notified(+w: R.World, +id: Nat, +value: R.Value, +slotted: R.World, +subs: Nat,
  live: {Nat.is_ne(subs, 0n) == True{} : Bool}, slot: {Stage.staged(w, id, value) == slotted : R.World}) ->
  {Stage.stagedAndNotify(w, id, value, subs) == B.Bundle{S.insertSubs(slotted, id), True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, Stage.stagedAndNotify(w, id, value, subs), B.Bundle{S.insertSubs(Stage.staged(w, id, value), id), True{}}, B.Bundle{S.insertSubs(slotted, id), True{}},
    Equal.cong(Bool, B.Bundle<R.World, Bool>, active => B.Bundle{B.choose(~R.World, active, _ => S.insertSubs(Stage.staged(w, id, value), id), _ => Stage.staged(w, id, value)), True{}}, Nat.is_ne(subs, 0n), True{}, live),
    Equal.cong(R.World, B.Bundle<R.World, Bool>, world => B.Bundle{S.insertSubs(world, id), True{}}, Stage.staged(w, id, value), slotted, slot))

def notify_end(+w: R.World, +id: Nat, +middle: R.World, +end: R.World,
  a: {S.insertSubs(w, id) == middle : R.World}, b: {middle == end : R.World}) ->
  {S.insertSubs(w, id) == end : R.World}:
  Equal.trans(R.World, S.insertSubs(w, id), middle, end, a, b)

def memo_complete(+w: R.World, +id: Nat, +value: R.Value, +height: Nat, +slotted: R.World, +end: R.World,
  off: {R.Node.equals(B.node(w, id)) == False{} : Bool},
  nonEffect: {B.effect(R.Node.kind(B.node(w, id))) == False{} : Bool},
  subs: {Nat.is_ne(R.Node.subs(B.node(w, id)), 0n) == True{} : Bool},
  slot: {Stage.staged(w, id, value) == slotted : R.World},
  notify: {S.insertSubs(slotted, id) == end : R.World}) ->
  {C.publishValue(w, id, value, False{}, height, False{}, False{}) == B.Bundle{end, True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, C.publishValue(w, id, value, False{}, height, False{}, False{}), C.publishValueChanged(w, id, value, False{}, height, False{}, True{}), B.Bundle{end, True{}},
    changed(w, id, value, height, disabled(w, id, B.current(B.node(w, id)), value, off)),
    Equal.trans(B.Bundle<R.World, Bool>, C.publishValueChanged(w, id, value, False{}, height, False{}, True{}), Stage.stagedAndNotify(w, id, value, R.Node.subs(B.node(w, id))), B.Bundle{end, True{}},
      Stage.memo_change(w, id, value, height, False{}, nonEffect),
      Equal.trans(B.Bundle<R.World, Bool>, Stage.stagedAndNotify(w, id, value, R.Node.subs(B.node(w, id))), B.Bundle{S.insertSubs(slotted, id), True{}}, B.Bundle{end, True{}},
        notified(w, id, value, slotted, R.Node.subs(B.node(w, id)), subs, slot),
        Equal.cong(R.World, B.Bundle<R.World, Bool>, world => B.Bundle{world, True{}}, S.insertSubs(slotted, id), end, notify))))

def slot_13(+input: Nat) -> {Stage.staged(C.world(M.state_13(input)), 3n, R.Number{Nat.add(input, 1n)}) == M.slot_13(input) : R.World}:
  {==}

def notify_13(+input: Nat) -> {S.insertSubs(M.slot_13(input), 3n) == M.notify_13(input) : R.World}:
  {==}

def final_13(+input: Nat) -> {M.notify_13(input) == C.world(M.state_14(input)) : R.World}:
  {==}

def complete_13(+input: Nat) -> {C.publishValue(C.world(M.state_13(input)), 3n, R.Number{Nat.add(input, 1n)}, False{}, 0n, False{}, False{}) == B.Bundle{C.world(M.state_14(input)), True{}} : B.Bundle<R.World, Bool>}:
  memo_complete(C.world(M.state_13(input)), 3n, R.Number{Nat.add(input, 1n)}, 0n, M.slot_13(input), C.world(M.state_14(input)), {==}, {==}, {==}, slot_13(input),
    notify_end(M.slot_13(input), 3n, M.notify_13(input), C.world(M.state_14(input)), notify_13(input), final_13(input)))

def slot_33(+input: Nat) -> {Stage.staged(C.world(M.state_33(input)), 4n, R.Number{Nat.mul(Nat.add(input, 1n), 2n)}) == M.slot_33(input) : R.World}:
  {==}

def notify_33(+input: Nat) -> {S.insertSubs(M.slot_33(input), 4n) == M.notify_33(input) : R.World}:
  {==}

def final_33(+input: Nat) -> {M.notify_33(input) == C.world(M.state_34(input)) : R.World}:
  {==}

def complete_33(+input: Nat) -> {C.publishValue(C.world(M.state_33(input)), 4n, R.Number{Nat.mul(Nat.add(input, 1n), 2n)}, False{}, 1n, False{}, False{}) == B.Bundle{C.world(M.state_34(input)), True{}} : B.Bundle<R.World, Bool>}:
  memo_complete(C.world(M.state_33(input)), 4n, R.Number{Nat.mul(Nat.add(input, 1n), 2n)}, 1n, M.slot_33(input), C.world(M.state_34(input)), {==}, {==}, {==}, slot_33(input),
    notify_end(M.slot_33(input), 4n, M.notify_33(input), C.world(M.state_34(input)), notify_33(input), final_33(input)))

# The effect branch marks and queues before it writes its value. Its captured
# subscriber pointer is still the pre-store one, as in publishValueChanged.
def effect_prepare(+w: R.World, +id: Nat) -> R.World:
  S.enqueue(B.store_node(w, id, R.Node.with_modified(B.node(w, id), True{})), id)

def effect_output(+w: R.World, +id: Nat, +value: R.Value, pending: Bool) -> B.Bundle<R.World, Bool>:
  B.Bundle{B.choose(~R.World, Bool.not(pending),
    _ => B.store_node(w, id, R.Node.with_value(B.node(w, id), value)),
    _ => B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value}))), True{}}

def effect_loaded(+w: R.World, +id: Nat, +value: R.Value, pending: Bool) -> B.Bundle<R.World, Bool>:
  +mid = B.choose(~R.World, Bool.not(pending), _ => effect_prepare(w, id), _ => w)
  effect_output(mid, id, value, B.present(R.Node.pending(B.node(mid, id))))

def effect_loaded_eq(+w: R.World, +id: Nat, +value: R.Value, height: Nat) ->
  {Stage.loaded(w, id, value, False{}, height, False{}, True{}, True{}, 0n) == effect_loaded(w, id, value, B.present(R.Node.pending(B.node(w, id)))) : B.Bundle<R.World, Bool>}:
  {==}

def effect_selected(+w: R.World, +id: Nat, +value: R.Value, +height: Nat,
  effect: {B.effect(R.Node.kind(B.node(w, id))) == True{} : Bool},
  subs: {R.Node.subs(B.node(w, id)) == 0n : Nat}) ->
  {C.publishValueChanged(w, id, value, False{}, height, False{}, True{}) == effect_loaded(w, id, value, B.present(R.Node.pending(B.node(w, id)))) : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, C.publishValueChanged(w, id, value, False{}, height, False{}, True{}), Stage.loaded(w, id, value, False{}, height, False{}, True{}, B.effect(R.Node.kind(B.node(w, id))), R.Node.subs(B.node(w, id))), effect_loaded(w, id, value, B.present(R.Node.pending(B.node(w, id)))),
    Stage.loadedEq(w, id, value, False{}, height, False{}, True{}),
    Equal.trans(B.Bundle<R.World, Bool>, Stage.loaded(w, id, value, False{}, height, False{}, True{}, B.effect(R.Node.kind(B.node(w, id))), R.Node.subs(B.node(w, id))), Stage.loaded(w, id, value, False{}, height, False{}, True{}, True{}, R.Node.subs(B.node(w, id))), effect_loaded(w, id, value, B.present(R.Node.pending(B.node(w, id)))),
      Equal.cong(Bool, B.Bundle<R.World, Bool>, e => Stage.loaded(w, id, value, False{}, height, False{}, True{}, e, R.Node.subs(B.node(w, id))), B.effect(R.Node.kind(B.node(w, id))), True{}, effect),
      Equal.trans(B.Bundle<R.World, Bool>, Stage.loaded(w, id, value, False{}, height, False{}, True{}, True{}, R.Node.subs(B.node(w, id))), Stage.loaded(w, id, value, False{}, height, False{}, True{}, True{}, 0n), effect_loaded(w, id, value, B.present(R.Node.pending(B.node(w, id)))),
        Equal.cong(Nat, B.Bundle<R.World, Bool>, s => Stage.loaded(w, id, value, False{}, height, False{}, True{}, True{}, s), R.Node.subs(B.node(w, id)), 0n, subs), effect_loaded_eq(w, id, value, height))))

def effect_complete(+w: R.World, +id: Nat, +value: R.Value, +height: Nat, +queued: R.World, +end: R.World,
  off: {R.Node.equals(B.node(w, id)) == False{} : Bool},
  effect: {B.effect(R.Node.kind(B.node(w, id))) == True{} : Bool},
  subs: {R.Node.subs(B.node(w, id)) == 0n : Nat},
  firstEmpty: {B.present(R.Node.pending(B.node(w, id))) == False{} : Bool},
  prepared: {effect_prepare(w, id) == queued : R.World},
  stillEmpty: {B.present(R.Node.pending(B.node(queued, id))) == False{} : Bool},
  stored: {B.store_node(queued, id, R.Node.with_value(B.node(queued, id), value)) == end : R.World}) ->
  {C.publishValue(w, id, value, False{}, height, False{}, False{}) == B.Bundle{end, True{}} : B.Bundle<R.World, Bool>}:
  Equal.trans(B.Bundle<R.World, Bool>, C.publishValue(w, id, value, False{}, height, False{}, False{}), C.publishValueChanged(w, id, value, False{}, height, False{}, True{}), B.Bundle{end, True{}},
    changed(w, id, value, height, disabled(w, id, B.current(B.node(w, id)), value, off)),
    Equal.trans(B.Bundle<R.World, Bool>, C.publishValueChanged(w, id, value, False{}, height, False{}, True{}), effect_loaded(w, id, value, B.present(R.Node.pending(B.node(w, id)))), B.Bundle{end, True{}},
      effect_selected(w, id, value, height, effect, subs),
      Equal.trans(B.Bundle<R.World, Bool>, effect_loaded(w, id, value, B.present(R.Node.pending(B.node(w, id)))), effect_loaded(w, id, value, False{}), B.Bundle{end, True{}},
        Equal.cong(Bool, B.Bundle<R.World, Bool>, pending => effect_loaded(w, id, value, pending), B.present(R.Node.pending(B.node(w, id))), False{}, firstEmpty),
        Equal.trans(B.Bundle<R.World, Bool>, effect_loaded(w, id, value, False{}), effect_output(queued, id, value, B.present(R.Node.pending(B.node(queued, id)))), B.Bundle{end, True{}},
          Equal.cong(R.World, B.Bundle<R.World, Bool>, world => effect_output(world, id, value, B.present(R.Node.pending(B.node(world, id)))), effect_prepare(w, id), queued, prepared),
          Equal.trans(B.Bundle<R.World, Bool>, effect_output(queued, id, value, B.present(R.Node.pending(B.node(queued, id)))), effect_output(queued, id, value, False{}), B.Bundle{end, True{}},
            Equal.cong(Bool, B.Bundle<R.World, Bool>, pending => effect_output(queued, id, value, pending), B.present(R.Node.pending(B.node(queued, id))), False{}, stillEmpty),
            Equal.cong(R.World, B.Bundle<R.World, Bool>, world => B.Bundle{world, True{}}, B.store_node(queued, id, R.Node.with_value(B.node(queued, id), value)), end, stored))))))

def prepare_end(+w: R.World, +id: Nat, +marked: R.World, +end: R.World,
  a: {B.store_node(w, id, R.Node.with_modified(B.node(w, id), True{})) == marked : R.World},
  b: {S.enqueue(marked, id) == end : R.World}) ->
  {effect_prepare(w, id) == end : R.World}:
  Equal.trans(R.World, effect_prepare(w, id), S.enqueue(marked, id), end,
    Equal.cong(R.World, R.World, world => S.enqueue(world, id), B.store_node(w, id, R.Node.with_modified(B.node(w, id), True{})), marked, a), b)

def store_end(+w: R.World, +id: Nat, +value: R.Value, +middle: R.World, +end: R.World,
  a: {B.store_node(w, id, R.Node.with_value(B.node(w, id), value)) == middle : R.World}, b: {middle == end : R.World}) ->
  {B.store_node(w, id, R.Node.with_value(B.node(w, id), value)) == end : R.World}:
  Equal.trans(R.World, B.store_node(w, id, R.Node.with_value(B.node(w, id), value)), middle, end, a, b)

def mark_55(+input: Nat) -> {B.store_node(C.world(M.state_55(input)), 5n, R.Node.with_modified(B.node(C.world(M.state_55(input)), 5n), True{})) == M.modified_55(input) : R.World}:
  {==}

def queue_55(+input: Nat) -> {S.enqueue(M.modified_55(input), 5n) == M.queued_55(input) : R.World}:
  {==}

def value_55(+input: Nat) -> {B.store_node(M.queued_55(input), 5n, R.Node.with_value(B.node(M.queued_55(input), 5n), R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)})) == M.value_55(input) : R.World}:
  {==}

def final_55(+input: Nat) -> {M.value_55(input) == C.world(M.state_56(input)) : R.World}:
  {==}

def complete_55(+input: Nat) -> {C.publishValue(C.world(M.state_55(input)), 5n, R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}, False{}, 2n, False{}, False{}) == B.Bundle{C.world(M.state_56(input)), True{}} : B.Bundle<R.World, Bool>}:
  effect_complete(C.world(M.state_55(input)), 5n, R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}, 2n, M.queued_55(input), C.world(M.state_56(input)), {==}, {==}, {==}, {==},
    prepare_end(C.world(M.state_55(input)), 5n, M.modified_55(input), M.queued_55(input), mark_55(input), queue_55(input)), {==},
    store_end(M.queued_55(input), 5n, R.Number{Nat.add(Nat.mul(Nat.add(input, 1n), 2n), input)}, M.value_55(input), C.world(M.state_56(input)), value_55(input), final_55(input)))
