# The queued source release callback executes the real releaseQueues operation,
# preserving the caller's remaining tasks and value stack. No queue fixture or
# alternate callback implementation is assumed; arbitrary healthy Worlds pass.
import Base
import ../runtime/core.bend as C
import ../runtime/scheduler.bend as S
import ../representation/records.bend as R
import ../representation/base.bend as B
import ./memo-setter-cuts.bend as Step

def callback(+w: R.World, +transaction: Nat, +rest: List<&2, C.Task>, +stack: List<&2, R.Value>, ready: {B.ok(w) == True{} : Bool}) ->
  {C.step(C.Machine{w, C.ReleaseTransactionQueues{transaction} <> rest, stack}) == C.Machine{S.releaseQueues(w, transaction), rest, stack} : C.Machine}:
  Equal.trans(C.Machine, C.step(C.Machine{w, C.ReleaseTransactionQueues{transaction} <> rest, stack}), C.dispatch(w, C.ReleaseTransactionQueues{transaction} <> rest, stack), C.Machine{S.releaseQueues(w, transaction), rest, stack},
    Step.step_head(w, C.ReleaseTransactionQueues{transaction}, rest, stack, ready), {==})
