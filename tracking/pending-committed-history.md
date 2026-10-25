# Committed content through pending traversal

The general callback-free settlement frame now passes the pinned independent
kernel. Actual `Pending.settled`, `Pending.advance`, and `Core.step` on a pending
continuation retain every committed node value, the full tree and the complete
trace. Worlds, payloads, graph topology, visited/released lists, source identities,
caller tasks and caller stack are arbitrary. Faulted states and malformed graphs
are included in this safety statement; their faults may change and successful
traversal is not inferred. The observation has no fault/health field.

`proof/pending-committed-history.bend` reuses `pending-stack-history`'s existing
certificates of actual `Core.step` prefixes. A syntactic classifier admits
pending traversal, after-trim settlement entry and scheduling; it excludes owner
work, callback evaluation and flush. Induction over any finite such permitted
prefix retains the complete committed observation. A corollary retains arbitrary
selected renderer text/application observations. The existing successful six-step
constructor is checked to belong to this domain. No output frame, transition
result or stable health invariant is supplied as a premise to this induction.

The exact two-step no-stale trim contract can still be used before this segment;
owner work in general remains a separate boundary. `Core.pendingTasks` queues an
eligible owner release with captured locals/cursor, retaining content and stack.
The proof stops before executing that owner work. Callback code may write/flush.

## Source segmentation, not a semantic change

The earlier monolithic proof attempt exceeded the unchanged kernel reduction
limit. `runtime/pending.bend` now names the original status block `settledStatus`
and enqueue/unblock/release-list tail `settledTail`. These segments preserve the
original locals, branches, field mutations and order. They introduce no Core task
or altered step budget. `tools/pending-segment-check.mjs` is part of `npm run check`:
inlining them recovers the exact earlier Bend statements, with identical body
SHA256 `0c2b78444faa0e4f1b13558924b662c0c87d9d933632d45cf87d985aa3a1538b`.
That textual audit supports review; it is not a formal TS/Bend equivalence proof.
The source correspondence ledger names both segments. No semantic deviation,
toolchain or checker-limit change is active. Earlier theorem domains and budgets
remain intact, including the stronger all-node-value observation.

The [original failed candidate](../experiments/pending-settlement-frame/README.md)
and its failure receipt remain historical. The new active proof relies on actual
named runtime segments, not that failed candidate or a reduced observation.

## Evidence and boundary

Six roots extend the earlier 487; the composed 493-root check passes. Full public
and alignment commands pass after the extraction. All 240 paired joined-flight
histories and 2,280 selected observations remain, with 160 forked settlement
prefixes executing 1,360 steps. Two additional actual-step controls exercise
eligible owner-release queueing and two exercise fault unwinding. Those forks do
not install their state in a native public history or execute the queued callback.

Four new source faults are rejected: three by existing executable observations,
one by the kernel. Initial kernel attempts at two of those variants hit the
unchanged process-group RSS limit and are recorded as infrastructure failures,
never credited as semantic rejection. Configured totals are 627 = 483 finite /
144 kernel; the complete 619 sweep is a separate older frozen checkpoint.
[Receipt](reviews/pending-committed-history-validation.json).

This establishes safety through general finite pending-body prefixes. It does not
prove that an arbitrary graph traversal terminates, establish input invariants
from the public constructor, execute callbacks/flush, settle the full joined
flight/action ledger, or prove eventual coordinated reveal. The no-subscriber
six-step theorem is the separate successful internal-completion result.
