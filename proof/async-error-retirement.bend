# The three handleError branches preserve their caller's continuation/stack
# and select the parked-frame teardown only after an actual published error.
# These are arbitrary-World continuation laws, not a full async-graph theorem.
import Base
import ../runtime/core.bend as C
import ../runtime/status.bend as A
import ../runtime/owner.bend as O
import ../runtime/constants.bend as K
import ../representation/records.bend as R

def published(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, error: R.Value) ->
  {C.handleErrorNotify(w, rest, stack, id, error, False{}, False{}) == C.Machine{A.notifyStatusWith(w, id, K.STATUS_ERROR(), error), C.OwnerTasks{[O.Enter{id, False{}, True{}}]} <> C.ErrorAfterPending{id, False{}} <> rest, stack} : C.Machine}:
  {==}

def staged(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, error: R.Value) ->
  {C.handleErrorNotify(w, rest, stack, id, error, False{}, True{}) == C.Machine{w, C.ErrorAfterPending{id, False{}} <> rest, stack} : C.Machine}:
  {==}

def pending(+w: R.World, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, +id: Nat, error: R.Value, staged: Bool) ->
  {C.handleErrorNotify(w, rest, stack, id, error, True{}, staged) == C.Machine{A.notifyStatusWith(w, id, K.STATUS_PENDING(), error), C.ErrorSettleSource{id} <> rest, stack} : C.Machine}:
  {==}
