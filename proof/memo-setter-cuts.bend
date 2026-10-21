# Proof-only algebraic gate cuts of the existing setter; no runtime changes.
import Base
import ../runtime/write.bend as W
import ../runtime/equality.bend as EQ
import ../representation/base.bend as B
import ../representation/records.bend as R
import ../runtime/constants.bend as K
import ../runtime/read-state.bend as V
import ../runtime/core.bend as C
import ../runtime/api.bend as A

def selected(+w: R.World, +id: Nat, +value: R.Value, skip: Bool, +custom: Bool, +same: Bool) -> R.World:
  B.choose(~R.World, skip, _ => W.stageResolved(w, id, value),
    _ => B.choose(~R.World, custom, _ => R.World.with_fault(w, R.Unsupported{23n}),
      _ => B.choose(~R.World, same, _ => w, _ => W.stageResolved(w, id, value))))

def selected_default(+w: R.World, +id: Nat, +value: R.Value, +skip: Bool, +custom: Bool, +same: Bool,
  skipEq: {skip == False{} : Bool}, customEq: {custom == False{} : Bool}, sameEq: {same == False{} : Bool}) ->
  {selected(w, id, value, skip, custom, same) == W.stageResolved(w, id, value) : R.World}:
  %Equal.sym(Bool, skip, False{}, skipEq) : {selected(w, id, value, _, custom, same) == W.stageResolved(w, id, value) : R.World}
  %Equal.sym(Bool, custom, False{}, customEq) : {selected(w, id, value, False{}, _, same) == W.stageResolved(w, id, value) : R.World}
  %Equal.sym(Bool, same, False{}, sameEq) : {selected(w, id, value, False{}, False{}, _) == W.stageResolved(w, id, value) : R.World}
  {==}

def loaded(+w: R.World, +id: Nat, +current: R.Value, +value: R.Value) -> R.World:
  selected(w, id, value, W.skipCompare(w, id), Nat.is_ne(EQ.custom(w, id), 0n), EQ.isSame(w, id, current, value))

def entry(+w: R.World, +id: Nat, +current: R.Value, +value: R.Value,
  beforeEq: {W.beforeCompare(w, id) == w : R.World},
  skipEq: {W.skipCompare(w, id) == False{} : Bool},
  customEq: {Nat.is_ne(EQ.custom(w, id), 0n) == False{} : Bool},
  sameEq: {EQ.isSame(w, id, current, value) == False{} : Bool}) ->
  {W.setResolved(w, id, current, value) == W.stageResolved(w, id, value) : R.World}:
  Equal.trans(R.World, W.setResolved(w, id, current, value), loaded(w, id, current, value), W.stageResolved(w, id, value),
    Equal.cong(R.World, R.World, next => loaded(next, id, current, value), W.beforeCompare(w, id), w, beforeEq),
    selected_default(w, id, value, W.skipCompare(w, id), Nat.is_ne(EQ.custom(w, id), 0n), EQ.isSame(w, id, current, value), skipEq, customEq, sameEq))

# The source's captured node and staged predicate, exposed only for algebraic
# transport across the existing helper return points. All equations are checked.
def intake(+w: R.World, +id: Nat, +value: R.Value, +node: R.Node, staged: Bool) -> R.World:
  +w = B.choose(~R.World, staged,
    _ => B.choose(~R.World, Bool.and(B.has(R.Node.config(node), K.CONFIG_HELD()), Bool.not(R.World.running(w))), _ => V.stashFlushed(w, id), _ => w),
    _ => W.queuePendingNode(w, id))
  B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Present{value}))

def tail(+w: R.World, +id: Nat, +node: R.Node, +staged: Bool) -> R.World:
  +w = B.choose(~R.World, Nat.is_ne(R.World.context(w), 0n), _ => V.notePromotedWrite(w, id), _ => w)
  +w = B.choose(~R.World, B.computed(R.Node.kind(node)), _ => B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w))), _ => w)
  B.choose(~R.World, Bool.and(staged, B.stampMatches(R.Node.notified(node), R.World.epoch(w))), _ => w,
    _ => B.schedule(W.insertSubs(w, id)))

def noSlot(+w: R.World, +id: Nat, +value: R.Value) -> R.World:
  intake(w, id, value, B.node(w, id), False{})

def shape(+w: R.World, +id: Nat, +value: R.Value) ->
  {W.stageResolved(w, id, value) == tail(intake(w, id, value, B.node(w, id), B.present(R.Node.pending(B.node(w, id)))), id, B.node(w, id), B.present(R.Node.pending(B.node(w, id)))) : R.World}:
  {==}

def noExisting(+w: R.World, +id: Nat, +value: R.Value,
  absent: {B.present(R.Node.pending(B.node(w, id))) == False{} : Bool}) ->
  {W.stageResolved(w, id, value) == tail(noSlot(w, id, value), id, B.node(w, id), False{}) : R.World}:
  Equal.trans(R.World, W.stageResolved(w, id, value), tail(intake(w, id, value, B.node(w, id), B.present(R.Node.pending(B.node(w, id)))), id, B.node(w, id), B.present(R.Node.pending(B.node(w, id)))), tail(noSlot(w, id, value), id, B.node(w, id), False{}), shape(w, id, value),
    Equal.cong(Bool, R.World, staged => tail(intake(w, id, value, B.node(w, id), staged), id, B.node(w, id), staged), B.present(R.Node.pending(B.node(w, id))), False{}, absent))

def tailFalse(+w: R.World, +id: Nat, promote: Bool, +computed: Bool) -> R.World:
  +w = B.choose(~R.World, promote, _ => V.notePromotedWrite(w, id), _ => w)
  +w = B.choose(~R.World, computed, _ => B.store_node(w, id, R.Node.with_time(B.node(w, id), R.World.clock(w))), _ => w)
  B.schedule(W.insertSubs(w, id))

def tail_default(+w: R.World, +id: Nat, +promote: Bool, +computed: Bool,
  promoteEq: {promote == False{} : Bool}, computedEq: {computed == False{} : Bool}) ->
  {tailFalse(w, id, promote, computed) == B.schedule(W.insertSubs(w, id)) : R.World}:
  %Equal.sym(Bool, promote, False{}, promoteEq) : {tailFalse(w, id, _, computed) == B.schedule(W.insertSubs(w, id)) : R.World}
  %Equal.sym(Bool, computed, False{}, computedEq) : {tailFalse(w, id, False{}, _) == B.schedule(W.insertSubs(w, id)) : R.World}
  {==}

def tail_signal(+w: R.World, +id: Nat, +node: R.Node,
  contextEq: {Nat.is_ne(R.World.context(w), 0n) == False{} : Bool},
  kindEq: {B.computed(R.Node.kind(node)) == False{} : Bool}) ->
  {tail(w, id, node, False{}) == B.schedule(W.insertSubs(w, id)) : R.World}:
  tail_default(w, id, Nat.is_ne(R.World.context(w), 0n), B.computed(R.Node.kind(node)), contextEq, kindEq)

def staged_to_slot(+w: R.World, +id: Nat, +value: R.Value, +slot: R.World,
  absent: {B.present(R.Node.pending(B.node(w, id))) == False{} : Bool},
  slotted: {noSlot(w, id, value) == slot : R.World},
  contextEq: {Nat.is_ne(R.World.context(slot), 0n) == False{} : Bool},
  kindEq: {B.computed(R.Node.kind(B.node(w, id))) == False{} : Bool}) ->
  {W.stageResolved(w, id, value) == B.schedule(W.insertSubs(slot, id)) : R.World}:
  Equal.trans(R.World, W.stageResolved(w, id, value), tail(noSlot(w, id, value), id, B.node(w, id), False{}), B.schedule(W.insertSubs(slot, id)), noExisting(w, id, value, absent),
    Equal.trans(R.World, tail(noSlot(w, id, value), id, B.node(w, id), False{}), tail(slot, id, B.node(w, id), False{}), B.schedule(W.insertSubs(slot, id)),
      Equal.cong(R.World, R.World, next => tail(next, id, B.node(w, id), False{}), noSlot(w, id, value), slot, slotted),
      tail_signal(slot, id, B.node(w, id), contextEq, kindEq)))

def coreChoice(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +current: R.Value, +value: R.Value, customDefault: Bool) -> C.Machine:
  B.choose(~C.Machine, customDefault,
    _ => C.Machine{W.setResolved(w, id, current, value), rest, value <> stack},
    _ =>
      +w = W.beforeCompare(w, id)
      B.choose(~C.Machine, W.skipCompare(w, id),
        _ => C.Machine{W.stageResolved(w, id, value), rest, value <> stack},
        _ => C.isSame(w, C.SetSignalCompared{id, value} <> rest, stack, id, current, value)))

def core_default(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +current: R.Value, +value: R.Value,
  defaultEq: {Nat.is_eq(EQ.custom(w, id), 0n) == True{} : Bool}) ->
  {C.setResolved(w, rest, stack, id, current, value) == C.Machine{W.setResolved(w, id, current, value), rest, value <> stack} : C.Machine}:
  Equal.cong(Bool, C.Machine, gate => coreChoice(w, rest, stack, id, current, value, gate), Nat.is_eq(EQ.custom(w, id), 0n), True{}, defaultEq)

def step_head(+w: R.World, +head: C.Task, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, ready: {B.ok(w) == True{} : Bool}) ->
  {C.step(C.Machine{w, head <> rest, stack}) == C.dispatch(w, head <> rest, stack) : C.Machine}:
  Equal.cong(Bool, C.Machine, healthy => B.choose(~C.Machine, healthy, _ => C.dispatch(w, head <> rest, stack), _ => C.unwind(w, head <> rest, stack)), B.ok(w), True{}, ready)

def setChoice(+w: R.World, +id: Nat, +value: R.Value, valid: Bool) -> C.Machine:
  B.choose(~C.Machine, valid,
    _ => C.run(B.budget(w), C.Machine{w, [C.setterTask(w, id)], [value]}),
    _ => C.Machine{R.World.with_fault(w, R.BadId{}), [], []})

def api_set(+w: R.World, +id: Nat, +value: R.Value, +fuel: Nat,
  valid: {B.valid(w, id) == True{} : Bool},
  budgetEq: {B.budget(w) == fuel : Nat},
  taskEq: {C.setterTask(w, id) == C.SetSignalArgument{id} : C.Task}) ->
  {A.setSignal(w, id, value) == C.world(C.run(fuel, C.Machine{w, [C.SetSignalArgument{id}], [value]})) : R.World}:
  Equal.trans(R.World, A.setSignal(w, id, value), C.world(C.run(B.budget(w), C.Machine{w, [C.setterTask(w, id)], [value]})), C.world(C.run(fuel, C.Machine{w, [C.SetSignalArgument{id}], [value]})),
    Equal.cong(Bool, R.World, gate => C.world(setChoice(w, id, value, gate)), B.valid(w, id), True{}, valid),
    Equal.trans(R.World, C.world(C.run(B.budget(w), C.Machine{w, [C.setterTask(w, id)], [value]})), C.world(C.run(fuel, C.Machine{w, [C.setterTask(w, id)], [value]})), C.world(C.run(fuel, C.Machine{w, [C.SetSignalArgument{id}], [value]})),
      Equal.cong(Nat, R.World, budget => C.world(C.run(budget, C.Machine{w, [C.setterTask(w, id)], [value]})), B.budget(w), fuel, budgetEq),
      Equal.cong(C.Task, R.World, task => C.world(C.run(fuel, C.Machine{w, [task], [value]})), C.setterTask(w, id), C.SetSignalArgument{id}, taskEq)))

def api_set_shape(+w: R.World, +id: Nat, +value: R.Value, +fuel: Nat, +start: C.Machine,
  valid: {B.valid(w, id) == True{} : Bool},
  budgetEq: {B.budget(w) == fuel : Nat},
  taskEq: {C.setterTask(w, id) == C.SetSignalArgument{id} : C.Task},
  shape: {C.Machine{w, [C.SetSignalArgument{id}], [value]} == start : C.Machine}) ->
  {A.setSignal(w, id, value) == C.world(C.run(fuel, start)) : R.World}:
  Equal.trans(R.World, A.setSignal(w, id, value), C.world(C.run(fuel, C.Machine{w, [C.SetSignalArgument{id}], [value]})), C.world(C.run(fuel, start)),
    api_set(w, id, value, fuel, valid, budgetEq, taskEq),
    Equal.cong(C.Machine, R.World, machine => C.world(C.run(fuel, machine)), C.Machine{w, [C.SetSignalArgument{id}], [value]}, start, shape))

def api_set_completed(+w: R.World, +id: Nat, +value: R.Value, +fuel: Nat, +start: C.Machine, +end: C.Machine, +output: R.World,
  valid: {B.valid(w, id) == True{} : Bool},
  budgetEq: {B.budget(w) == fuel : Nat},
  taskEq: {C.setterTask(w, id) == C.SetSignalArgument{id} : C.Task},
  shape: {C.Machine{w, [C.SetSignalArgument{id}], [value]} == start : C.Machine},
  finished: {C.run(fuel, start) == end : C.Machine},
  result: {C.world(end) == output : R.World}) ->
  {A.setSignal(w, id, value) == output : R.World}:
  Equal.trans(R.World, A.setSignal(w, id, value), C.world(C.run(fuel, start)), output,
    api_set_shape(w, id, value, fuel, start, valid, budgetEq, taskEq, shape),
    Equal.trans(R.World, C.world(C.run(fuel, start)), C.world(end), output,
      Equal.cong(C.Machine, R.World, machine => C.world(machine), C.run(fuel, start), end, finished), result))
