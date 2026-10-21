import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/construct-state.bend as N
import ../representation/base.bend as B
import ../representation/records.bend as R

def expr() -> R.Expr:
  R.Add{R.Read{2n}, R.Literal{R.Number{1n}}}

def options() -> R.NodeOptions:
  R.NodeOptions.with_lazy(R.NodeOptions.with_equals(N.defaults(), False{}), False{})

def entered(w: R.World) -> R.World:
  R.World.with_tracking(R.World.with_context(w, 1n), False{})

def id(w: R.World) -> Nat:
  A.nextId(entered(w))

def prepare(+w: R.World) -> C.Machine:
  C.Machine{N.computed(entered(w), expr(), options(), 1n), [C.Recompute{id(w), True{}}], []}

def restore(+origin: R.World, +w: R.World) -> R.World:
  +w = B.choose(~R.World, B.ok(w), _ => B.event(w, R.AccessorBound{id(origin)}), _ => w)
  R.World.with_tracking(R.World.with_context(w, R.World.context(origin)), R.World.tracking(origin))

def facade(+fuel: Nat, +w: R.World) ->
  {A.createMemo(fuel, w, expr(), False{}, False{}, 1n) == restore(w, C.world(C.run(fuel, prepare(w)))) : R.World}:
  {==}

def from_shape(+fuel: Nat, +w: R.World, +start: C.Machine,
  shape: {prepare(w) == start : C.Machine}) ->
  {A.createMemo(fuel, w, expr(), False{}, False{}, 1n) == restore(w, C.world(C.run(fuel, start))) : R.World}:
  Equal.trans(R.World, A.createMemo(fuel, w, expr(), False{}, False{}, 1n), restore(w, C.world(C.run(fuel, prepare(w)))), restore(w, C.world(C.run(fuel, start))), facade(fuel, w),
    Equal.cong(C.Machine, R.World, machine => restore(w, C.world(C.run(fuel, machine))), prepare(w), start, shape))


def completed(+fuel: Nat, +w: R.World, +start: C.Machine, +end: C.Machine, +output: R.World,
  shape: {prepare(w) == start : C.Machine},
  finished: {C.run(fuel, start) == end : C.Machine},
  result: {restore(w, C.world(end)) == output : R.World}) ->
  {A.createMemo(fuel, w, expr(), False{}, False{}, 1n) == output : R.World}:
  Equal.trans(R.World, A.createMemo(fuel, w, expr(), False{}, False{}, 1n), restore(w, C.world(C.run(fuel, start))), output, from_shape(fuel, w, start, shape),
    Equal.trans(R.World, restore(w, C.world(C.run(fuel, start))), restore(w, C.world(end)), output,
      Equal.cong(C.Machine, R.World, machine => restore(w, C.world(machine)), C.run(fuel, start), end, finished), result))
