# The actual core fulfillment prefix returns a machine with queued trim/release/
# flush work. These tasks are retained, not run or replaced by an atomic commit.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/flight.bend as F
import ../runtime/write.bend as W
import ../runtime/equality.bend as Equality
import ../runtime/constants.bend as K
import ../runtime/owner.bend as O
import ./committed-storage-frame.bend as Frame
import ./flight-committed-frame.bend as Flight

def machineChoice(+condition: Bool, +w: R.World, +left: C.Machine, +right: C.Machine,
  leftFrame: {Frame.observe(C.world(left)) == Frame.observe(w) : Frame.View},
  rightFrame: {Frame.observe(C.world(right)) == Frame.observe(w) : Frame.View}) ->
  {Frame.observe(C.world(B.choose(~C.Machine, condition, _ => left, _ => right))) == Frame.observe(w) : Frame.View}:
  match condition:
    case True{}: leftFrame
    case False{}: rightFrame

def valuesChoice(+condition: Bool, +stack: List<&2, R.Value>, +left: C.Machine, +right: C.Machine,
  leftValues: {C.values(left) == stack : List<&2, R.Value>},
  rightValues: {C.values(right) == stack : List<&2, R.Value>}) ->
  {C.values(B.choose(~C.Machine, condition, _ => left, _ => right)) == stack : List<&2, R.Value>}:
  match condition:
    case True{}: leftValues
    case False{}: rightValues

def afterValue(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +then: List<&2, C.Task>) ->
  {Frame.observe(C.world(C.asyncWriteAfterValue(w, rest, stack, id, then))) == Frame.observe(w) : Frame.View}:
  +ending = {C.AsyncWriteAfterTrim{id} <> C.AsyncWriteSchedule{} <> C.AsyncFlush{} <> B.append(C.Task, then, rest) : List<&2, C.Task>}
  machineChoice(Bool.not(B.present(R.Node.pending(B.node(w, id)))), w,
    C.Machine{B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{})), C.OwnerTasks{[O.TrimDeps{id}]} <> ending, stack}, C.Machine{w, ending, stack}, Frame.loading(w, id, False{}), {==})

def afterValues(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +then: List<&2, C.Task>) ->
  {C.values(C.asyncWriteAfterValue(w, rest, stack, id, then)) == stack : List<&2, R.Value>}:
  +ending = {C.AsyncWriteAfterTrim{id} <> C.AsyncWriteSchedule{} <> C.AsyncFlush{} <> B.append(C.Task, then, rest) : List<&2, C.Task>}
  valuesChoice(Bool.not(B.present(R.Node.pending(B.node(w, id)))), stack,
    C.Machine{B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{})), C.OwnerTasks{[O.TrimDeps{id}]} <> ending, stack}, C.Machine{w, ending, stack}, {==}, {==})

def fast(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +result: Nat, +value: R.Value, +then: List<&2, C.Task>) -> C.Machine:
  +pair = F.beginAsyncWrite(w, id, result, value)
  +w = B.first(R.World, Bool, pair)
  B.choose(~C.Machine, B.second(R.World, Bool, pair), _ => C.asyncWriteAfterValue(w, rest, stack, id, then), _ => C.Machine{w, rest, stack})

def slow(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +result: Nat, +value: R.Value, +then: List<&2, C.Task>) -> C.Machine:
  +pair = F.prepareAsyncWrite(w, id, result)
  +w = B.first(R.World, Bool, pair)
  B.choose(~C.Machine, B.second(R.World, Bool, pair), _ => C.setResolved(w, C.Discard{} <> C.AsyncWriteAfterSetter{id, then} <> rest, stack, id, B.current(B.node(w, id)), value), _ => C.Machine{w, rest, stack})

def fastGuard(+w: R.World, +id: Nat,
  custom: {Equality.custom(w, id) == 0n : Nat},
  override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool}) ->
  {Bool.and(Nat.is_eq(Equality.custom(w, id), 0n), Bool.not(B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()))) == True{} : Bool}:
  Equal.trans(Bool, Bool.and(Nat.is_eq(Equality.custom(w, id), 0n), Bool.not(B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()))), Bool.not(B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE())), True{},
    Equal.cong(Nat, Bool, comparator => Bool.and(Nat.is_eq(comparator, 0n), Bool.not(B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()))), Equality.custom(w, id), 0n, custom),
    Equal.cong(Bool, Bool, override => Bool.not(override), B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()), False{}, override))

def exact(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +result: Nat, +value: R.Value, +then: List<&2, C.Task>,
  custom: {Equality.custom(w, id) == 0n : Nat},
  override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool}) ->
  {C.asyncWrite(w, rest, stack, id, result, value, then) == fast(w, rest, stack, id, result, value, then) : C.Machine}:
  Equal.cong(Bool, C.Machine, ordinary => B.choose(~C.Machine, ordinary, _ => fast(w, rest, stack, id, result, value, then), _ => slow(w, rest, stack, id, result, value, then)), Bool.and(Nat.is_eq(Equality.custom(w, id), 0n), Bool.not(B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()))), True{}, fastGuard(w, id, custom, override))

def fastFrame(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +result: Nat, +value: R.Value, +then: List<&2, C.Task>) ->
  {Frame.observe(C.world(fast(w, rest, stack, id, result, value, then))) == Frame.observe(w) : Frame.View}:
  +pair = F.beginAsyncWrite(w, id, result, value)
  +next = B.first(R.World, Bool, pair)
  Frame.compose(w, next, C.world(fast(w, rest, stack, id, result, value, then)),
    machineChoice(B.second(R.World, Bool, pair), next, C.asyncWriteAfterValue(next, rest, stack, id, then), C.Machine{next, rest, stack}, afterValue(next, rest, stack, id, then), {==}), Flight.write(w, id, result, value))

def observed(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +result: Nat, +value: R.Value, +then: List<&2, C.Task>,
  custom: {Equality.custom(w, id) == 0n : Nat},
  override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool}) ->
  {Frame.observe(C.world(C.asyncWrite(w, rest, stack, id, result, value, then))) == Frame.observe(w) : Frame.View}:
  Equal.trans(Frame.View, Frame.observe(C.world(C.asyncWrite(w, rest, stack, id, result, value, then))), Frame.observe(C.world(fast(w, rest, stack, id, result, value, then))), Frame.observe(w),
    Equal.cong(C.Machine, Frame.View, machine => Frame.observe(C.world(machine)), C.asyncWrite(w, rest, stack, id, result, value, then), fast(w, rest, stack, id, result, value, then), exact(w, rest, stack, id, result, value, then, custom, override)), fastFrame(w, rest, stack, id, result, value, then))

def stack(+w: R.World, +rest: List<&2, C.Task>, +values: List<&2, R.Value>, +id: Nat, +result: Nat, +value: R.Value, +then: List<&2, C.Task>,
  custom: {Equality.custom(w, id) == 0n : Nat},
  override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool}) ->
  {C.values(C.asyncWrite(w, rest, values, id, result, value, then)) == values : List<&2, R.Value>}:
  +pair = F.beginAsyncWrite(w, id, result, value)
  +next = B.first(R.World, Bool, pair)
  Equal.trans(List<&2, R.Value>, C.values(C.asyncWrite(w, rest, values, id, result, value, then)), C.values(fast(w, rest, values, id, result, value, then)), values,
    Equal.cong(C.Machine, List<&2, R.Value>, machine => C.values(machine), C.asyncWrite(w, rest, values, id, result, value, then), fast(w, rest, values, id, result, value, then), exact(w, rest, values, id, result, value, then, custom, override)),
    valuesChoice(B.second(R.World, Bool, pair), values, C.asyncWriteAfterValue(next, rest, values, id, then), C.Machine{next, rest, values}, afterValues(next, rest, values, id, then), {==}))

def ending(+id: Nat, +then: List<&2, C.Task>, +rest: List<&2, C.Task>) -> List<&2, C.Task>:
  C.AsyncWriteAfterTrim{id} <> C.AsyncWriteSchedule{} <> C.AsyncFlush{} <> B.append(C.Task, then, rest)

def afterExact(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +then: List<&2, C.Task>) ->
  {C.asyncWriteAfterValue(w, rest, stack, id, then) == B.choose(~C.Machine, Bool.not(B.present(R.Node.pending(B.node(w, id)))),
    _ => C.Machine{B.store_node(w, id, R.Node.with_loading(B.node(w, id), False{})), C.OwnerTasks{[O.TrimDeps{id}]} <> ending(id, then, rest), stack},
    _ => C.Machine{w, ending(id, then, rest), stack}) : C.Machine}:
  {==}
