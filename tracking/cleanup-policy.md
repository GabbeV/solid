# Cleanup policy at rc.17

[The integration review](reviews/solid-5b1b7776.md) identifies every changed
source site. runtime/cleanup-state.bend implements owner.ts's error box, catch
state and clear/rethrow/drop operations. Owner/Core RunCleanup and CleanupFinally
supply the actual callback return points without a second evaluator.

A supported callback throw stops its own remaining statements. It does not stop
sibling cleanup callbacks, children/ancestors, dependency unlinking or the flush
drain. The first error is preserved even when undefined, null, false or zero.
The public root disposer outside a flush rethrows after teardown; during a flush
the error rethrows only after all scheduled work finishes. Existing effect
pre-rerun and error-handler cleanup-helper calls keep their raw source behavior.
Fatal halt drops a previously collected error; already-halted calls return early.
Unsupported/exhausted protocol work remains a visible refusal, never a collected
user exception or evidence that arbitrary JS inputs are supported.

Thirty-six paired public histories supplement existing owner/core and lifecycle
comparisons. Seven quantified properties in proof/cleanup-policy.bend preserve
the entire arbitrary surrounding World and raw payloads at the stated helper
boundaries. A separate law checks Core's exceptional callback return point with
arbitrary caller and saved operand stacks. No arbitrary-tree termination or
formal TS-equivalence claim follows from these helper laws. Existing closed
collector, trim and commit laws are positive regressions under the new policy.
