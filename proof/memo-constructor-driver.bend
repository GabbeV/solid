import Base
import ../runtime/api.bend as A
import ../runtime/core.bend as C
import ../runtime/construct-state.bend as N
import ../representation/base.bend as B
import ../representation/records.bend as R

def signal() -> R.World:
  A.createSignal(A.createWorld(), R.Number{0n}, False{})

def expr() -> R.Expr:
  R.Add{R.Read{2n}, R.Literal{R.Number{1n}}}

def options() -> R.NodeOptions:
  R.NodeOptions.with_equals(N.defaults(), False{})

def before() -> C.Machine:
  +w = R.World.with_tracking(R.World.with_context(signal(), 1n), False{})
  C.Machine{N.computed(w, expr(), options(), 1n), [C.Recompute{3n, True{}}], []}

def step(machine: C.Machine) -> C.Machine:
  C.step(machine)

def finish(+w: R.World) -> R.World:
  +w = B.choose(~R.World, B.ok(w), _ => B.event(w, R.AccessorBound{3n}), _ => w)
  R.World.with_tracking(R.World.with_context(w, 0n), False{})
