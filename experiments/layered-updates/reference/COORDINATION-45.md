# Stage 45: executable scalar adapter and a failed performance gate

## Result and decision

The consolidated mechanism passes the current correctness campaign, including
new initial-publication and observation/action cases. The direct runtime
representation fails the performance acceptance gate by large margins. It must
not replace the production core. The next implementation should retain the
existing ordinary value slots and graph machinery, and materialize coordination
records only where holding or explicit boundaries require them.

This is a decision about the tested representation, not a proof that the
publication rules are complete or that their efficient implementation is assured.
The tests remain a useful executable oracle for the next implementation.

## Correctness refinements

The new initial-publication fixture starts with an async input that has never
produced a value. A constant override must be able to publish while that input
remains unavailable. Floating initial groups previously joined the child guess,
which then waited for its input. Independent initial work now starts in the
ordinary context; owned work still inherits its producing context. The earlier
mount, ownership and join tests continue to pass.

Four observation/action campaigns exposed stalled updates after every answer
was ready. A newer source proposal had committed, leaving an older publication
obligation but no candidate for it. The common source preparation rule now
satisfies that obligation using the current committed source. It cannot revive
the superseded value. This also applies to the private control signals used by
boundaries; no pending-specific source storage was added.

`UnifiedScheduler` consolidates the three inherited implementations into one
class. It distinguishes value identity from owner-frame identity and transfers
publication obligations when replacing updates. Candidate reuse no longer
needs a per-node WeakMap of previous values: preparation carries the previous
proposed scalar locally, and an async token retains it only while needed.

Work is collected from active update records rather than a permanent global
node registry. With tracing disabled, unused ordinary signals are collectible.
Tracing remains available for publication snapshots and traversal permutations.
Dynamic-position reconstruction is skipped when no dynamic update exists.
Preparation epochs avoid repeatedly validating a chain during one stable pass;
notifications and joins invalidate that cache. A completed input group still
requires observation retirement before the ongoing flush finishes.

## Actual scalar API execution

`scalar-runtime.mjs` exposes a limited adapter for createSignal, createMemo,
createOptimistic, createRenderEffect, createRoot, onCleanup, generator actions,
direct-accessor isPending and explicit flush. It uses the consolidated engine
with diagnostic tracing disabled. Existing open guessing actions can accept
further guesses, including the ambient repeated-write shape used by next's
optimistic benchmark.

The adapter passes the repeated-revealed-guess reproduction through separate
render callbacks, unrelated writes and a late reader. Its correction audit
starts 4/1 immediately after A expires, keeps visible 6,2,6/2 until ready, and
ignores the obsolete 6/1 answer. It also exercises shared pending and real owned
cleanup through public-style accessors.

It is deliberately not a complete Solid entry point: automatic microtask
scheduling, complete render scheduling semantics, callback observations, latest,
Loading/ErrorBoundary integration, stores, SSR and other APIs are absent. Promise
calculation completion still drives the model's flush. The production sources
and their prior acceptance status are unchanged.

## Performance evidence

The existing synchronous benchmark worker and its value/render assertions were
reused unchanged. `measure-sync.mjs` gained only an optional candidate entry path;
its default targets, worker, sample calculation and thresholds are unchanged.

```sh
SYNC_SAMPLES=3 \
SCALAR_CANDIDATE_ENTRY=experiments/layered-updates/reference/scalar-runtime.mjs \
node experiments/layered-updates/measure-sync.mjs \
  experiments/layered-updates/results/reference-stage45/bundled-cost
```

Both runtimes are bundled with the same esbuild settings. Each paired sample
runs in a fresh process, with alternating runtime order. The baseline is next
at a24e911ba5e571e7adb1c9b5e5151261f9cf101c. Raw samples, worker hash, bundle
hashes, CPU/Node metadata and bundles are retained in the result directory.

Representative median paired adapter/baseline ratios after refinement:

| Workload | Ratio |
| --- | ---: |
| Settled signal read | 0.61 |
| Settled memo read | 0.50 |
| Equal write | 1.03 |
| Ordinary write/flush | 15.65 |
| Memo write | 10.04 |
| 20-memo chain | 16.94 |
| Diamond | 11.73 |
| 100-memo fan-out | 13.51 |
| Ten writes per batch | 79.98 |
| Signal creation | 4.38 |
| Memo creation/disposal | 10.59 |

The initial unbundled diagnostic had a roughly 70x chain slowdown. Preparation
epochs substantially reduced redundant work, and skipping empty flush work
removed the equal-write regression. The remaining costs are still unacceptable.
This is not a small regression to waive or conceal by raising a threshold.

An ordinary retained-allocation probe, with GC and event-loop turns between
phases, measured approximately 1,362 bytes per retained signal pair versus 353
for baseline, and 1,411 per materialized memo versus 508. This includes accessor
and ownership costs, not just node literals. Memory returned close to the prior
level after references and roots were released; these two-run probes do not
establish long-term absence of leaks. They do establish a large ordinary
allocation disadvantage in this representation.

The active optimistic cost probe checks every final visible value while an
action remains open. Direct input chains of depth 1, 4 and 16 cost approximately
5.4x, 4.1x and 8.0x baseline. It is a coarse diagnostic, not a full paired
optimistic performance campaign.

For the ordinary import scenario, the limited adapter bundles to 15,288 bytes
minified / 4,697 Brotli, versus 21,188 / 7,825 for baseline. Missing features
prevent treating this as shipped-size acceptance. The whole coordinator class
also remains reachable in the adapter's ordinary bundle. Size does not rescue
the failed performance gate.

Snapshots of the adapter and coordinator are saved under
`../results/reference-stage45/runtime-snapshot/` for later comparison.

## Validation and classification

```sh
UNIFIED=1 node --test experiments/layered-updates/reference/*.test.mjs
```

128 tests pass. 79 exercise the consolidated engine, including two scalar API
tests; the other 49 are historical probes tied to earlier models. New coverage
includes 240 observed overlapping-action operations and both traversal orders
for an override above an unpublished input. Earlier nested, sibling, conditional,
error, ownership, equality, stale-answer and cleanup campaigns remain intact.
Finite coverage is not a universal consistency or convergence proof.

The two new stalls were implementation bugs, fixed without weakening publication
assertions. Ordinary-context initial work is the implementation choice that made
the accepted optimism rule work; broader initial/owned behavior remains subject
to testing. Missing APIs are explicitly deferred adapter features. The measured
runtime representation has failed performance acceptance.

## Production direction and remaining risk

The existing ordinary core already stages `_pendingValue` separately from
`_value`, delays dependency-tail trimming until publication, parks owned children
only when needed, and avoids allocating a transaction for every synchronous
write. Those are the mechanisms to reuse. The reference's eager frame Maps,
Sets and transaction records should not be copied into ordinary nodes.

Ordinary transaction merges and lifecycle coupling can remain permanent.
Revisable joins are needed for pending optimistic peers whose relative layer
changes. Original-origin tracking can therefore be confined to that work rather
than required for every ordinary read. This is a proposed implementation route,
not yet an implemented or measured optimization.

One critical integration constraint: the core's retained dependency list is a
union while a proposal is pending. It is not automatically an exact record of
the committed dependency structure used by the model's context rule. Any sparse
snapshot or generation scheme must preserve that distinction without taxing
settled synchronous nodes. Initial committed reads, proposal supersession and
owned-frame migration also need explicit integration tests.

The next port should replace the current layer adapter's opportunistic read
discovery and ancestry searches, retain these executable timelines, and measure
ordinary scenarios immediately. Do not add stores or claim the scalar work
complete on this checkpoint's evidence.
