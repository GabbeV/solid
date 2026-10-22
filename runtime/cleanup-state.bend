# core/owner.ts cleanupError, runCleanup's catch, rethrowCleanupError.
# A Slot represents the optional one-element box, so thrown undefined counts.
# Callback invocation/return points live in owner/core, not in this state helper.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def collectSlot(+w: R.World, +cause: R.Value, slot: R.Slot) -> R.World:
  match slot:
    case R.Empty{}:
      B.schedule(R.World.with_cleanupError(w, R.Present{cause}))
    case R.Present{old}:
      B.schedule(w)

def collect(+w: R.World, cause: R.Value) -> R.World:
  collectSlot(w, cause, R.World.cleanupError(w))

# Only actual user throws are caught; unsupported/exhausted host computations
# remain profile refusals, never silently successful cleanup calls.
def runCleanupCatch(+w: R.World, fault: R.Fault) -> R.World:
  match fault:
    case R.CallbackThrown{cause}:
      collect(R.World.with_fault(w, R.Healthy{}), cause)
    case _:
      w

def rethrowSlot(+w: R.World, drop: Bool, error: R.Slot) -> R.World:
  match error:
    case R.Empty{}:
      w
    case R.Present{cause}:
      B.choose(~R.World, drop, _ => w, _ => R.World.with_fault(w, R.CallbackThrown{cause}))

def rethrowCleanupError(+w: R.World, drop: Bool) -> R.World:
  rethrowSlot(R.World.with_cleanupError(w, R.Empty{}), drop, R.World.cleanupError(w))

# owner.disposeRootSelf's check follows disposeChildren, outside its hot path.
def disposeRootSelfEnd(+w: R.World) -> R.World:
  B.choose(~R.World, R.World.running(w), _ => w, _ => rethrowCleanupError(w, False{}))
