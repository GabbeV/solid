# No-subscriber settlement completion

The actual queued `AsyncWriteAfterTrim` / pending-settlement / schedule segment
now returns to its caller in six `Core.step` transitions for an arbitrary World,
node identity, caller task suffix and caller value stack, provided the input World
has a Healthy fault and that node has no downstream subscriber edge. This is an
operation contract at the queued continuation, not construction of a public graph.
The node may still read upstream signals; this is not an empty graph or stream.

`proof/empty-settlement-completion.bend` derives the machine layouts and health
through actual pending-source removal. It constructs the permitted six-step
prefix from those input facts; no desired transition equation, output health or
intermediate invariant is assumed. Pending-source Set/extension bookkeeping and
scheduling may change. Committed node values, the complete tree and event trace
are retained. Caller tasks and values return exactly; a queued flush remains to
be executed. Health here means Healthy fault, not global readiness or no halt.

`proof/pending-removal-footprint.bend` proves that the real removal helper retains
all nodes, intrusive links and fault, including the absent-carrier branch.
`proof/core-run-prefix.bend` proves the actual driver split over arbitrary finite
step lengths and remaining fuel, including faulted/empty machines. Applying it
to this segment uses exactly six units and leaves the caller's original remaining
fuel. Zero remaining fuel with unfinished caller work still gives the runtime's
Exhausted fault and empty work/stack. No runtime budget or checker limit changed.

Nine roots extend the earlier 478. Earlier domains, witness sizes and budgets
are retained. There is no runtime, host, source pin or semantic deviation change.

## Executable and negative evidence

The existing 240 paired joined-action/rendered-flight histories and 2,280 public
prefix observations remain. Private forks of 80 accepted direct-render arrivals
meet this contract and return in six real steps. On those states 240 actual-run
split controls and 80 explicit zero-fuel exhaustion controls pass. All 160 direct
and memo-backed arrivals still traverse 1,360 actual owner/settlement steps to
their queued flush; 40 memo-backed arrivals take the no-stale trim branch. None
of those 40 has an empty downstream subscriber head. That branch frequency is
reported, not forced by a fixture or promoted to a theorem premise.

Four new kernel negatives are rejected: hidden exhaustion, lost pending return
suffix, advancing the zero walk cursor, and dropped schedule caller work.
Configured totals are 623 = 480 finite /143 kernel; the complete corrected sweep
is the separate frozen 619 configuration at 4975adf2. Its exact named set and all
817 sealed input hashes are verified in
[the canonical-ABI sweep receipt](reviews/canonical-list-complete-negative.json).
Compilation/resource failures are never credited as semantic negatives.

## Remaining obligation

This closes a bounded internal-completion obligation. Construction/preservation
of these input facts through the public graph and arbitrary branching deliveries,
nonempty subscriber traversal, callback termination, coordinated flush/reveal,
valid identities, once-only host settlement and delivery fairness remain separate.
The general settlement committed-storage attempt remains an unverified archive.
[Receipt](reviews/empty-settlement-completion-validation.json).
