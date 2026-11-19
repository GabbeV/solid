# Readiness lost through optimistic propagation

The user's proposed distinction is more useful than the earlier mixed-dependency
predicate: did the optimistic propagation remove the remaining reason to keep
the update governing its own lifetime open?

"Observer" here means an observation of pending work that holds publication.
The original data node and DOM subscribers can remain alive: moving their work
to a higher context is sufficient to stop their flight holding the lower update.
An open action is another lifetime cause, even with zero async blockers.

The existing `blocked(update)` query incorporates action openness, observed
pending work, and scoped optimistic-input holds. In audit instrumentation around
the existing layer-notification callback, before ownership transfer:

```
parent = current owning update
wasBlocked = blocked(parent)
perform existing optimistic adoption/propagation
becameReady = wasBlocked && !blocked(resolveTx(parent))
```

This measures an immediate readiness transition. It does not count ordinary
subscribers or attempt to recover whether an edge came from user code versus a
callback observation. That avoids the callback-origin ambiguity found in stage 84.

Measured candidate results:

| Case | Before | After |
| --- | --- | --- |
| Original self-feedback | Blocked by data | Ready |
| Pending through an intermediate status memo | Blocked by data | Ready |
| Secondary request with independent primary request | Blocked by both | Still blocked by primary |
| Same secondary shape probing id instead of primary | Blocked by both | Still blocked by primary |
| Action remains open | Blocked | Still blocked by action, despite no async blockers |
| Two pending-consuming async readers | Blocked by both | First adoption leaves one; last makes ready |
| Delayed indicator interrupted by a new data request | Blocked | Still blocked by data |
| Ordinary superseding source write | Blocked | Still blocked; no higher-context adoption |

The two-reader case was run in both creation orders and detected exactly one
blocked-to-ready transition in each. This does not establish arbitrary nested
or sibling-graph completeness.

This is **not yet an installed error rule**. Three distinctions remain:

1. Optimism may legitimately unblock a lower update while its own lifetime is
   kept alive independently. That was accepted when general observedness
   forwarding was removed. The relevant relation is to the proposal's own
   lifetime, not just any lower update losing blockers. Existing observation
   parent / optimistic scope records help identify that relation; indirect or
   merged origins still need validation.
2. The immediate transition can precede queued replacement work. A complete
   guard must distinguish a transient readiness gap from the quiescent readiness
   used to retire the proposal. Deferred disposal and conditional branches are
   not covered by the synchronous adoption measurement. If checking later needs
   a retained per-flush cause marker, that is extra bookkeeping, not free proof.
3. Detecting readiness loss does not automatically imply an invalid program or
   prove it cannot produce coherent final values. It identifies the suspected
   self-shortening lifetime event, a better basis for a deliberate restriction.

No new production fields or hooks were added. The audit uses local before/after
queries plus test logs. A runtime version at this seam could use local variables
for synchronous propagation. `blocked` is a scan, not an O(1) query, so invoking
it around every adoption could be expensive or quadratic; check placement and
production cost must be measured before adopting such enforcement. Ordinary
signal reads need not change.

Evidence: `unified-pending-feedback-metadata.test.ts` (16 cases, extended here)
and `unified-pending-timer-cancellation.test.ts` (1 case), under
`packages/signals/tests`. Results are in `results/pending-readiness-stage85/`.
No production behavior or error policy has changed.
