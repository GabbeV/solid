# Production owner introspection and runWithOwner's ambient stores.
# Callback execution/try/finally is split at core.EnterOwner/RestoreContext.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./constants.bend as K

def getOwner(w: R.World) -> Nat:
  R.World.context(w)

def getObserver(+w: R.World) -> Nat:
  B.choose(~Nat, R.World.tracking(w), _ => R.World.context(w), _ => 0n)

def isDisposed(w: R.World, id: Nat) -> Bool:
  B.has(R.Node.flags(B.node(w, id)), K.REACTIVE_DISPOSED())

def reference(+id: Nat) -> R.Value:
  B.choose(~R.Value, Nat.is_eq(id, 0n), _ => R.Null{}, _ => R.OwnerReference{id})

def enterOwner(w: R.World, owner: Nat) -> R.World:
  R.World.with_tracking(R.World.with_context(w, owner), False{})

def restore(w: R.World, owner: Nat, tracking: Bool) -> R.World:
  R.World.with_tracking(R.World.with_context(w, owner), tracking)
