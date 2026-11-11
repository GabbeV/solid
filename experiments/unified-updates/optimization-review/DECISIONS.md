# Primary review and next experiments

Five Sol (`gpt-6.1-sol`) agents at medium reasoning investigated the five plans.
The primary agent reviewed their checkpoints, redirected weak hypotheses, asked
for counterexamples, and obtained a creator-lifecycle cross-review of the attempt
loop proposal. Runtime code and shared build artifacts were not changed.

## Findings and disposition

| Area | Finding after review | Disposition |
| --- | --- | --- |
| Creator retry / private publication | Retry rejects incompatible attempts; publication waits also protect accepted detached proposals and retained published children. No guard proved redundant. | Do not delete guards. Keep a larger accepted-obligation redesign as research. |
| Ordinary scheduler | A no-landings scope check could avoid empty queue allocation/composition, but most of that opportunity also exists in next. | Separate upstream-applicable trial; do not credit its general gain to the experiment. |
| Attempts / transfer | First attempt and retry duplicate execution/normalization handling. Proposal ownership already transfers in O(1); callback state has distinct obligations. | Trial one inline attempt loop. Preserve request reuse and publication machinery. |
| Observation lifecycle | Watching records readiness changes not supplied by current value-notification queues. Naive two-pass iteration changes live Set behavior. | Reject naive scan cleanup. Transaction-local replacement remains a redesign with bookkeeping costs. |
| Dependency walks | A parked node filters its dependencies against unrelated journal entries. Local partitioning can remove that amplification. | Trial in-place partition first; consider a temporary park-only Set only if broad insertion workloads justify it. |

These findings narrow the original hypotheses. They do not establish enough
savings to close the measured ~2.25–2.41 KB Brotli optional-feature gap. Deleting
old source already removed by tree-shaking gets no shipped-byte credit.

## First experiment: one attempt loop

Owner area: coordination.ts computeLayer/retryCalculation. Keep the initial
attempt inline; run reset only between local retries; delete the duplicate
invocation/owner-retry/normalization/catch body and the separate retry function.

The independent creator review requires:
- One outer acceptance finally; never accept tentative joins between retries.
  Preserve the current treatment of ordinary errors' discovered context.
- Check pending creator retry immediately after _fn and before normalization.
  Keep the rejection sink when async code or a user catch consumes the token.
- An unhandled creator retry propagates without locally resetting its ancestor.
- Preserve reset order: flight invalidation, teardown release, tentative-child
  disposal, dependency/discovery reset. Exactly one reset per discarded attempt.
- Preserve the original previousPosition across the loop. Keep initial private
  wait cleanup and retry-marker conversion outside the per-attempt loop.

Validate delayed discovery through a completed staged creator, async/user-catch
paths, prev values, equal-value ownership changes, request counts and cleanup.
Measure the normal successful attempt separately from retry-heavy work. A loop
backedge can affect JIT optimization, so code sharing alone is not acceptance.
No publication guard or transfer optimization should change in this trial.

## Second experiment: localize insertion-journal membership

Partition the existing journal once so entries for the parking node form a
suffix. Preserve graph dependency order when filtering; then clear/remove that
suffix. Existing journal removal already permits reordering journal entries.

Extracted algorithm controls passed 2,012 cases; primary review reran them.
At D=128 dependencies / I=1 local insertion / J=257 total insertions, membership
comparisons fell from 32,896 to 128. That is an operation-count result, not a
runtime timing or full-reactivity correctness result. Partition remains O(J+D*I)
and does not fix broad local insertion's quadratic membership cost.

Keep count==0 gating, error-prefix frames, retained snapshots, merge/disposal
behavior and the targeted rerun-holder registry. Trial on the real runtime with
committed-dependency and ownership/context tests before timing. Check small-J
cases for added swap/branch overhead. Avoid additional ordinary-node fields or
persistent caches. A temporary Set, if tried, is confined to actual snapshot
creation and must justify its allocation/code-size cost separately.

## Separate upstream opportunity

The no-landings scheduler fast path needs a local check after preparation and
commit/cleanup, not a cached entry-of-flush decision: cleanup can open a hold.
Skip only empty landing machinery, preserving later phase hooks and callback
order. Both pinned next revisions have the main empty queue allocation/composition
opportunity (legacy next also needs to account for lane work).

Keep this trial separate. Apply an equivalent optimization to next when judging
whether it closes any experiment-specific gap. Only avoidance of the experiment's
extra ordering dispatch/repeated landing loop is intrinsically experiment-specific.
A new branch can increase bytes; this is principally a potential sync-performance
improvement, not an established size reduction.

## Larger structural work, after those trials

1. **Accepted private publication obligations.** Investigate replacing overloaded
   private rerun waits and repeated ownership rediscovery with one explicit
   lifecycle at acceptance. A replacement must account for later notifications,
   peer merges, retries, disposal and retained published children. Adding another
   ledger alongside current mechanisms is not a simplification.
2. **Update-local observation lifetime delivery.** A replacement for watching
   scans would need transaction readiness delivery, merge/reparent/disposal
   handling and non-transaction questions such as declared changes. Existing
   queues alone do not provide this. Require deletion of current scanning/state
   before accepting the complexity. Do not assume latest's equal restoration
   makes downstream publication or ownership irrelevant.

The observation collection probe demonstrates missed newly-added or re-added
records under naive two-pass iteration. Source inspection finds a comparator can
query a previously unqueried pending source, synchronously marking an observation
without a write. Exact watcher-only end-to-end reachability remains unverified;
this is a reason to preserve behavior, not a new comparator semantic ruling.

## Measurement and scope

Refresh a reproducible unmodified-next baseline before runtime trials. Historical
size receipts use next 4fe75321; separately inspected current next is bcef1041.
Keep matching build/mangling/import scenarios. Report performance only against
next; candidate-before/after size comparisons may attribute a particular change.
Run timing sequentially after investigation agents/builds/tests are idle. Ordinary
reads, writes, chains, diamonds and creation remain acceptance priorities.

No new runtime tests or performance benchmarks ran in this review. The two small
probes under probes/ exercise extracted algorithms/collection behavior only.
No new semantic ruling is currently needed for the two bounded experiment trials.
Stores and until remain deferred; this review does not establish mergeability.
