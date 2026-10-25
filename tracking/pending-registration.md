# Constructed pending-source registration and retirement

Actual `addPendingSource` now has an arbitrary-World preservation contract for
all branches: duplicates, existing extensions/Sets and fresh allocation. It
retains committed node values/tree/trace, subscriber kind/configuration/heads,
all graph links, node count and fault. The generic proof is instantiated with
checked concrete helper laws; no desired final frame is supplied. A constructed
one-edge graph certificate survives actual registration and still constructs the
same bounded return and whole-segment committed frame.

Membership is proved separately. On an allocated empty Set, actual insertion
creates the singleton membership. The fresh-Set family derives its positive ID,
allocated storage, selected pointer, empty initial slots and room from actual
`newPendingSet`/capture, then proves actual insertion. Its duplicate add returns
false and retains the entire World. Actual deletion leaves a tombstone, clears
the last-source pointer and makes a duplicate removal a whole-World no-op.

The fresh-node family also constructs the extension prerequisite. Its initial
facts are a valid selected node with zero extension pointer, reserved blank
extension slot zero and reserved empty Set slot zero. Actual extension allocation
supplies the positive pointer, allocated record and range; actual Set allocation
and insertion supply membership. Add-then-remove derives source absence and a
zero pending pointer; duplicate add/removal retain the full actual World. Source
identities are arbitrary nonzero represented IDs; allocation/liveness of those
source identities and a global well-formedness invariant are not inferred.

Thirteen roots extend 525 to 538. The typed fixture supplies its input evidence
inside Bend. Its 128 executable cases vary payload, recomputing flag and both
auxiliary arena sizes, check 384 duplicate no-ops, and run 128 actual ten-step
settlement returns plus 384 actual-driver splits. The actual helper round trip
and actual Core settlement are checked separately; the general return theorem
does not additionally prove the Core result's final membership/status judgment.
Five focused kernel faults distinguish missing insertion, wrong duplicate result,
removed tombstone, retained empty pointer and reuse of reserved Set zero.
[Validation](reviews/pending-registration-validation.json).

The complete frozen633 sweep now passes on 73eda482, with exact named-set
agreement and all 851 tracked input hashes unchanged. Eleven later graph/node/
registration faults have focused passing checks. Current configuration is 644 =
484 finite /160 kernel; this is not a new complete644 sweep. Runtime/source/host,
Bend/kernel limits and all prior domains/budgets are unchanged. No semantic
deviation or new upstream bug was introduced or found by this checkpoint.

The arbitrary-World node-constructor and graph family, registration preservation
and fresh carrier contracts are reusable pieces. The compact fixture does not yet
compose all fresh-carrier premises from the arbitrary-sized memo/render constructor
family. Callback evaluation, global source-identity validity, complete action/
flight accounting, owned construction/options and coordinated flush/reveal remain
open. Set add/delete safety is not a once-only flight or eventual-delivery theorem.
