# core/scheduler.ts:applyStaged. The source returns NOT_PENDING after assigning;
# callers observe its truthiness (slot presence), never the assigned payload.
import Base
import ../representation/records.bend as R
import ../representation/base.bend as B

def apply(+w: R.World, +id: Nat, slot: R.Slot) -> B.Bundle<R.World, Bool>:
  match slot:
    case R.Empty{}: B.Bundle{w, False{}}
    case R.Present{value}:
      +w = B.store_node(w, id, R.Node.with_value(B.node(w, id), value))
      B.Bundle{B.store_node(w, id, R.Node.with_pending(B.node(w, id), R.Empty{})), True{}}

def applyStaged(+w: R.World, +id: Nat) -> B.Bundle<R.World, Bool>:
  apply(w, id, R.Node.pending(B.node(w, id)))
