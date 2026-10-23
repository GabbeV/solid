# A caught callback throw is no longer an active machine fault while the
# source catch executes ask/land. sourceFailed rethrows the original value.
import Base
import ./deferred-error-probe.bend as Probe
import ../runtime/core.bend as C
import ../runtime/deferred-runtime.bend as D
import ../representation/records.bend as R

def caught(w: R.World, cell: Nat, open: Bool, error: R.Value, rest: List<&2, C.Task>, saved: List<&2, R.Value>) ->
  {C.deferredUnwind(w, rest, cell, open, saved, R.CallbackThrown{error}) == C.Machine{D.sourceFailed(R.World.with_fault(w, R.Healthy{}), cell, open, error), rest, saved} : C.Machine}:
  {==}
