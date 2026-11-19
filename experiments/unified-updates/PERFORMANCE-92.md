# Stage 92: two more performance rounds

The subsequent [stage-93 size pass](SIZE-93.md) removes duplicate transaction
bookkeeping and contains the current retained measurements.

Two narrowly scoped optimizations are retained: cheaper dependency-frame parking
and avoiding repeated assignment of a reader to the same update. A broader
per-node journal flag was rejected. No semantic rules, API contracts, tests, or
acceptance thresholds changed. Stores remain paused.

Every timing comparison uses unchanged next at
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, Node 24.19.0. All retained runtime
edits are in two experimental modules. There are no independently applicable
upstream optimizations mixed into these changes.

## Ordinary synchronous performance remains a separate priority

The ordinary/action application bundle is **byte-for-byte identical to stage
91**. The ordinary benchmark bundle is also checked against the retained build.
The rejected trial's edits to shared graph code and constants were restored.
The retained changes add no ordinary read checks, node fields, counters, flags,
or allocations.

Consequently, the following stage-91 ordinary-only measurements still describe
the exact retained binary. They were not rerun or credited as new improvements
from these two rounds. Small wins are not subsumed into a general statement of
parity with next.

| Ordinary workload | Retained / next time | Measured difference |
| --- | ---: | ---: |
| Signal read | 0.985 | 1.5% faster |
| Memo read | 0.904 | 9.6% faster |
| Write and flush | 1.011 | 1.1% slower |
| Equal write | 1.026 | 2.6% slower |
| Memo write | 0.959 | 4.1% faster |
| Ten writes per batch | 0.938 | 6.2% faster |
| Chain | 0.969 | 3.1% faster |
| Diamond | 0.937 | 6.3% faster |
| Memo fan-out | 0.936 | 6.4% faster |
| Effect fan-out | 1.064 | 6.4% slower |
| Branch switch | 0.966 | 3.4% faster |
| Signal creation | 0.834 | 16.6% faster |
| Memo creation/disposal | 0.960 | 4.0% faster |

These are paired medians from seven alternating fresh-process pairs, not
guaranteed differences on every machine. The raw ranges and samples remain in
`results/performance-stage91/sync`.

## Round 1: dependency-frame parking

The initial trial gave each node a bit identifying journal work. It skipped
unnecessary commit/clear hooks and WeakMap lookups, and passed all 456 scalar
tests. But synchronous branch switching with an unused optimistic primitive
measured **1.087 times next**, versus 0.985 for the pre-pass code in that trial.
The optimistic bundle grew by 105 Brotli bytes. Creation's small gain was noisy.
That tradeoff was rejected, despite improved active fan-out. Its source and
measurements are retained under `journal/`.

The narrower implementation uses the journal's existing insertion count:

- If there are no inserted links, there is no insertion scan or removal work.
- A saved dependency frame is checked once and retained until publication.
- If parking creates a snapshot, the local result records that fact rather
  than querying the WeakMap again.

The synchronous insertion/commit/clear paths are unchanged. No new bit or
counter survives this round. The first narrow trial is under `park/`.

## Round 2: repeated assignment to an update

Several inputs can notify the same shared reader during one update. Previously,
each notification repeated ownership and publication-list work even when the
reader already belonged to that exact update.

The retained shortcut runs only after the existing owner-frame and optimistic
boundary checks, and only when:

1. The reader is held by this exact transaction record, not merely an alias.
2. There are no inserted dependency links requiring journal work.
3. There is no modified effect callback requiring queue transfer.

Pending detection still sets the update's `_mayPend` flag. The caller still
notifies/queues the computation: this skips redundant bookkeeping, not reactive
propagation. Under these conditions, the old parking callback had no mutation
to perform, and the old list operation returned immediately after pending
detection. Existing saved frames remain intact.

The reader's resolved transaction is also reused across the checks in this
function. No callbacks or writes intervene between those uses. The additional
raw-identity check remains, so a node stamped with a merged transaction still
takes the full path that updates its stamp and membership.

The intermediate implementation is under `adoption/`; the combined version
before transaction-lookup reuse is under `uncached-adoption/`. Only `final/`
contains the retained feature measurements.

## Final active measurements

Seven samples rotate next, the validated stage-91 bundle, and the retained
bundle through fresh processes. Both columns below are ratios to **next**;
the pre-pass implementation is never used as the baseline.

| Workload | Pre-pass / next | Retained / next |
| --- | ---: | ---: |
| Callback input, 1 boundary | 2.102 | 2.036 |
| Callback input, 4 boundaries | 3.045 | 2.749 |
| Callback input, 16 boundaries | 3.956 | 3.730 |
| Direct input, 1 boundary | 1.911 | 1.938 |
| Direct input, 4 boundaries | 2.912 | 2.861 |
| Direct input, 16 boundaries | 4.165 | 3.923 |
| Fan-out to 16 memos | 2.864 | 2.468 |
| Fan-out to 128 memos | 2.630 | 2.399 |
| Fan-out to 512 memos | 3.949 | 4.067 |

These are useful but uneven gains. The final 512-memo comparison does **not**
establish an improvement: its paired ratio is worse, while absolute medians
are nearly identical (501.1 microseconds pre-pass and 499.8 retained), with
substantial range overlap. Earlier trials favored the shortcut more strongly;
those results have not replaced the less favorable final result.

The chain workload writes the first override through otherwise transparent
boundaries. In the separate workload where all boundaries have active
overrides, writes to the deepest override cost 2.040 / 2.013 / 1.903 times next
at depths 1 / 4 / 16 (three alternating pairs).

An intermediate broad-chain run suggested a regression in the first,
single-boundary callback case. A separate longer-warmed worker uses three
50,000-write warm-ups and five 50,000-write samples per input form. Its final
seven-process comparison gives:

| Single-boundary control | Pre-pass / next | Retained / next |
| --- | ---: | ---: |
| Callback input | 2.123 | 2.076 |
| Direct input | 1.941 | 1.989 |

The direct-input control remains slightly worse in this run, with overlapping
ranges. This does not justify claiming every small case improved or that all
regressions have been excluded.

## Synchronous work with inactive optimism

Fresh seven-sample comparisons keep one unused optimistic boundary alive.
There is no async calculation in these workloads.

| Workload | Pre-pass / next | Retained / next |
| --- | ---: | ---: |
| Memo creation/disposal | 0.998 | 1.028 |
| Memo write | 0.979 | 0.989 |
| Ten writes per batch | 0.987 | 0.819 |
| Chain | 0.927 | 0.930 |
| Diamond | 1.045 | 0.989 |
| Branch switch | 0.965 | 0.960 |
| Effect fan-out | 1.018 | 0.976 |

Do not conflate this feature-import scenario with the unchanged ordinary-only
binary above. Inactive creation remains a concern rather than a closed item.
Some measurements, especially batched writes, varied substantially between
processes. The favorable batch result is reported but not attributed entirely
to these edits; the retained changes primarily target active parking/adoption.

## Cost and validation

| Import scenario | Next Brotli bytes | Retained Brotli bytes |
| --- | ---: | ---: |
| Ordinary/action | 8,116 | 8,069 |
| Optimistic | 9,864 | 11,627 |
| Pending | 10,419 | 12,291 |
| Latest | 10,368 | 12,155 |
| Refresh | 10,117 | 8,338 |
| Optimistic and refresh | 10,208 | 11,862 |

The optimistic bundle grows 31 Brotli bytes over stage 91. Feature bundles
remain roughly 18% larger than next. These rounds improve some execution costs;
they do not close the speed/size acceptance gaps.

Five paired GC probes retain zero disposed reader payloads in both runtimes.
Callback boundary heap deltas remain approximately 1,088 bytes versus next's
556; direct inputs approximately 1,073 versus 568. The changes add no heap
records. These estimates include registry capacity/reuse and are not fixed
allocation-size guarantees.

- 456 scalar tests pass with legacy lanes disabled; the same 34 explicit
  baseline/legacy comparisons remain excluded.
- The unchanged migration corpus reports 618 passes and 36 failures, with the
  same identities and classifications: 28 category-2 differences and eight
  deferred outside-read cases. No new semantic difference was accepted.
- The 500-seed, 30,000-operation overlap campaign passes on the retained source.
- 5,683 normal-entry tests pass, zero fail, two skips. This supplementary suite
  still largely exercises legacy exports.
- Source TypeScript checking, production build, and whitespace checks pass.
  Previously documented build warnings remain.

This is finite correctness and performance evidence, not a universal proof.
The scalar API scope, deferred features, and semantic rulings remain unchanged
from [stage 90](SCALAR-MILESTONES-90.md).

## Artifacts and reproduction

`results/performance-stage92/runtime-change.patch` isolates this turn's edits
from the earlier uncommitted experiment. `before/`, trial-specific source
snapshots, source hashes, raw test reports, bundle metadata, worker hashes, and
individual timing samples are retained alongside it. All work remains local;
the pinned next checkout's tracked source was not changed.

Use the build and bundle commands in [stage 91](PERFORMANCE-91.md). The paired
driver is `compare-performance-pass.mjs`, taking output JSON, next bundle,
pre-pass bundle, and candidate bundle paths. `PERF_WORKER` selects
`optimistic-bench.mjs`, `optimistic-fanout-bench.mjs`, or the new
`optimistic-single-bench.mjs`. `PERF_CASE` passes a scenario to
`inactive-sync-bench.mjs` and records its within-process samples too.
Use `PERF_SAMPLES=7`; `MEMORY_SAMPLES=0` omits memory probes for timing-only
comparisons. Run timing commands sequentially without builds/test workers.
