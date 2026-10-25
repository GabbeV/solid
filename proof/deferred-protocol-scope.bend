# Merged #4248 moves the existing source catch through result processing.
# The passive handler closes at return without an extra machine task.
import Base
import ../representation/records.bend as R
import ../runtime/core.bend as C

def closes(cell: Nat, open: Bool, saved: List<&2, R.Value>, rest: List<&2, C.Task>) ->
  {C.deferredReturned(C.DeferredCatch{cell, open, saved} <> rest) == rest : List<&2, C.Task>}:
  {==}

def catches(w: R.World, cell: Nat, open: Bool, saved: List<&2, R.Value>, rest: List<&2, C.Task>, stack: List<&2, R.Value>) ->
  {C.unwind(w, C.DeferredCatch{cell, open, saved} <> rest, stack) == C.deferredUnwind(w, rest, cell, open, saved, R.World.fault(w)) : C.Machine}:
  {==}
