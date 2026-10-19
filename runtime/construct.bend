# Source construction literals/setup are shared with callback construction.
# This facade supplies the existing standalone eager driver boundary.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./construct-state.bend as S
import ./core.bend as C

def defaults() -> R.NodeOptions:
  S.defaults()

def signal(w: R.World, value: R.Value, options: R.NodeOptions) -> R.World:
  S.signal(w, value, options)

def createOwner(w: R.World, parent: Nat, transparent: Bool) -> R.World:
  S.createOwner(w, parent, transparent)

def setupComputedNode(fuel: Nat, w: R.World, +id: Nat, lazy: Bool) -> R.World:
  +w = S.setupComputedNode(w, id)
  B.choose(~R.World, lazy, _ => w,
    _ => C.world(C.run(fuel, C.Machine{w, [C.Recompute{id, True{}}], []})))

def computed(fuel: Nat, +w: R.World, expr: R.Expr, +options: R.NodeOptions, parent: Nat) -> R.World:
  +id = B.length(R.Node, R.World.nodes(w))
  +w = S.computed(w, expr, options, parent)
  B.choose(~R.World, R.NodeOptions.lazy(options), _ => w,
    _ => C.world(C.run(fuel, C.Machine{w, [C.Recompute{id, True{}}], []})))

def createEffectNode(w: R.World, expr: R.Expr, kind: R.NodeKind, target: Nat, options: R.NodeOptions, parent: Nat, program: Nat, returnedCleanup: Nat) -> R.World:
  S.createEffectNode(w, expr, kind, target, options, parent, program, returnedCleanup)
