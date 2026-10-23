# Active core post-updater setter branch. Custom comparator callbacks and
# lane/override writes are explicitly excluded; arbitrary represented values
# are already resolved data at this boundary, not callback expressions.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ../runtime/core.bend as C
import ../runtime/write.bend as W
import ../runtime/equality.bend as Equality
import ../runtime/constants.bend as K
import ./committed-storage-frame.bend as Frame
import ./setter-committed-frame.bend as Setter

def plainExact(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +current: R.Value, +value: R.Value,
  custom: {Equality.custom(w, id) == 0n : Nat}) ->
  {C.setPlainResolved(w, rest, stack, id, current, value) == C.Machine{W.setResolved(w, id, current, value), rest, value <> stack} : C.Machine}:
  Equal.cong(Nat, C.Machine, comparator => B.choose(~C.Machine, Nat.is_eq(comparator, 0n),
    _ => C.Machine{W.setResolved(w, id, current, value), rest, value <> stack},
    _ =>
      +w = W.beforeCompare(w, id)
      B.choose(~C.Machine, W.skipCompare(w, id), _ => C.Machine{W.stageResolved(w, id, value), rest, value <> stack}, _ => C.isSame(w, C.SetSignalCompared{id, value} <> rest, stack, id, current, value))), Equality.custom(w, id), 0n, custom)

def ordinaryExact(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +current: R.Value, +value: R.Value,
  override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool},
  custom: {Equality.custom(w, id) == 0n : Nat}) ->
  {C.setResolved(w, rest, stack, id, current, value) == C.Machine{W.setResolved(w, id, current, value), rest, value <> stack} : C.Machine}:
  Equal.trans(C.Machine, C.setResolved(w, rest, stack, id, current, value), C.setPlainResolved(w, rest, stack, id, current, value), C.Machine{W.setResolved(w, id, current, value), rest, value <> stack},
    Equal.cong(Bool, C.Machine, lane => B.choose(~C.Machine, lane, _ => C.Machine{w, C.LaneWrite{id, value} <> rest, stack}, _ => C.setPlainResolved(w, rest, stack, id, current, value)), B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()), False{}, override), plainExact(w, rest, stack, id, current, value, custom))

def ordinary(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +current: R.Value, +value: R.Value,
  override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool},
  custom: {Equality.custom(w, id) == 0n : Nat}) ->
  {Frame.observe(C.world(C.setResolved(w, rest, stack, id, current, value))) == Frame.observe(w) : Frame.View}:
  Equal.trans(Frame.View, Frame.observe(C.world(C.setResolved(w, rest, stack, id, current, value))), Frame.observe(W.setResolved(w, id, current, value)), Frame.observe(w),
    Equal.cong(C.Machine, Frame.View, result => Frame.observe(C.world(result)), C.setResolved(w, rest, stack, id, current, value), C.Machine{W.setResolved(w, id, current, value), rest, value <> stack}, ordinaryExact(w, rest, stack, id, current, value, override, custom)), Setter.resolved(w, id, current, value))

def result(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, +current: R.Value, +value: R.Value,
  override: {B.has(R.Node.config(B.node(w, id)), K.CONFIG_OVERRIDE()) == False{} : Bool},
  custom: {Equality.custom(w, id) == 0n : Nat}) ->
  {C.values(C.setResolved(w, rest, stack, id, current, value)) == value <> stack : List<&2, R.Value>}:
  Equal.cong(C.Machine, List<&2, R.Value>, machine => C.values(machine), C.setResolved(w, rest, stack, id, current, value), C.Machine{W.setResolved(w, id, current, value), rest, value <> stack}, ordinaryExact(w, rest, stack, id, current, value, override, custom))
