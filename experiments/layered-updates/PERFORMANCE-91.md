# Stage 91: performance pass against pinned next

Subsequent trials and retained measurements: [stage 92](PERFORMANCE-92.md).

This pass reduces some of the experiment's active propagation overhead without
changing its semantic rules. It does **not** establish performance or size
acceptance. The scalar scope and migration classifications remain those of
[stage 90](SCALAR-MILESTONES-90.md). Stores remain paused.

All baseline results use unchanged next at
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, Node 24.19.0. The baseline's three
pre-existing untracked comparison tests were preserved. Nothing was pushed.

## Retained changes

- Move the optional update-routing check into a small `recompute` wrapper. A
  scoped calculation calls `recomputeBody` directly, avoiding recursive entry
  through the large calculation function and its routing argument.
- A scoped pass that queues only its own already-held result and has no live
  children removes that duplicate ambient queue entry with `pop()`. Its
  transaction's landing list still owns publication. Additional writes, pulled
  computations, and owned children retain the complete parking walk. Subsequent
  passes no longer repeatedly scan this common case's accumulated queue prefix.
- Replace the layer coordinator's effect-membership `WeakSet` with one spare
  bit in the existing configuration word. The flag is consumed at the same
  routing points as the old membership record. No node fields were added.
- Use the existing selector flag to avoid boundary-registry lookups for ordinary
  nodes during adoption and ownership assignment.
- Delete input-node placeholders from the boundary registry. Every consumer
  treated these null entries identically to absence; only actual boundaries
  need entries. The registry type now reflects that invariant.

There is no added bookkeeping on ordinary signal reads, no version map, and no
new layer traversal in the ordinary read path. The optimistic primitive still
has two full nodes. These optimizations concern the experiment's machinery;
they are not independent next improvements credited toward closing its gap.

No independently applicable upstream optimization was validated in this pass.
The upstream baseline was never modified for measurements. If a later pass
finds such an optimization, it should be retained as a separate patch and
measured on next as well as the experiment.

## Active propagation

Numbers below are paired median time ratios to **the same next baseline**.
Below 1 is faster. Pre-pass is the validated stage-90 bundle, included to
distinguish progress from machine/sample variation; it is not the baseline.
Seven samples rotate all three runtimes through fresh processes. These are
combined-change measurements, not independent attribution to each micro-edit.

The first workload writes one active override through a chain of otherwise
transparent optimistic boundaries and ordinary memos, while its action remains
open. It is not a workload with every boundary overridden.

| Input form / boundary count | Pre-pass / next | Retained / next |
| --- | ---: | ---: |
| Callback / 1 | 2.030 | 2.042 |
| Callback / 4 | 3.329 | 3.025 |
| Callback / 16 | 4.664 | 3.891 |
| Direct / 1 | 2.112 | 1.942 |
| Direct / 4 | 3.161 | 2.813 |
| Direct / 16 | 4.590 | 4.007 |

A separate five-sample comparison fans one override out through ordinary memos
into one scheduled render binding. The rendered total is checked after each
warm-up and timed batch. It exercises queue breadth rather than chain depth.

| Memo count | Pre-pass / next | Retained / next |
| --- | ---: | ---: |
| 16 | 2.933 | 2.607 |
| 128 | 3.743 | 2.761 |
| 512 | 6.427 | 3.826 |

The larger fan-out benefits most, consistent with removing repeated prefix
scans. This is not a claim that all remaining coordination is linear or that
active propagation is now inexpensive.

In the distinct workload where **all** boundaries have live overrides, writes
to the deepest override cost 2.095 / 2.042 / 1.716 times next at depths 1 / 4 /
16 respectively (three alternating process pairs). The other overrides remain
unchanged. These numbers should not be conflated with the chain workload.

## Ordinary synchronous workloads

Seven alternating process pairs per workload; no async calculations. The
ordinary benchmark bundle byte-matches a fresh bundle of the retained build.
These characterize the current experiment; existing advantages over next are
not all improvements discovered in this pass.

| Workload | Retained / next time |
| --- | ---: |
| Signal read | 0.985 |
| Memo read | 0.904 |
| Write and flush | 1.011 |
| Equal write | 1.026 |
| Memo write | 0.959 |
| Ten writes per batch | 0.938 |
| Chain | 0.969 |
| Diamond | 0.937 |
| Memo fan-out | 0.936 |
| Effect fan-out | 1.064 |
| Branch switch | 0.966 |
| Signal creation | 0.834 |
| Memo creation/disposal | 0.960 |

Ranges often overlap. In particular, this does not establish a universal
improvement or rule out smaller regressions such as effect fan-out.

With an unused optimistic boundary alive, seven pairs give memo reads 0.913,
chains 0.931, diamonds 0.979, and memo creation/disposal 0.975 times next.
Creation samples overlap substantially: approximately 101–127 ns for the
candidate versus 100–120 ns for next. An earlier intermediate measurement in
this pass gave 1.080 for creation. The earlier inactive-creation concern is not
declared resolved on the strength of the favorable final median.

## Memory and bundle size

Five paired GC probes reclaim every disposed reader payload in both runtimes.
Measured heap deltas per callback boundary are approximately 1,088 bytes versus
next's 556; direct-input boundaries approximately 1,073 versus 568. These include
registry capacity and reuse effects, not a guaranteed fixed allocation size per
node. Two full nodes remain the dominant boundary storage cost.

| Import scenario | Next Brotli bytes | Retained Brotli bytes |
| --- | ---: | ---: |
| Ordinary/action | 8,116 | 8,069 |
| Optimistic | 9,864 | 11,596 |
| Pending | 10,419 | 12,260 |
| Latest | 10,368 | 12,125 |
| Refresh | 10,117 | 8,338 |
| Optimistic and refresh | 10,208 | 11,828 |

The ordinary bundle remains slightly smaller than next. Feature bundles are
still roughly 18% larger. The optimistic bundle grew 17 Brotli bytes relative
to the pre-pass checkpoint: this is a speed pass, not a size improvement.
No thresholds were raised. The remaining active speed and feature-size gaps
still prevent acceptance.

## Validation and rejected trials

- 456 candidate tests pass, with legacy lanes disabled; 34 explicitly named
  baseline/legacy comparison cases remain excluded.
- The unchanged 654-test migration corpus still reports 618 passes and 36
  failures, with exactly the same failure identities and classifications as
  stage 90: 28 category-2 differences and eight deferred outside-read cases.
- 5,683 normal-entry tests pass, zero fail, two skips. This largely exercises
  legacy exports and is supplementary to candidate validation.
- The 500-seed overlap campaign covers 30,000 operations. The initial expanded
  trial exceeded Vitest's default five-second timeout; the campaign was rerun
  with a 120-second timeout. No consistency assertion was changed.
- Existing repeated-publication checks keep transaction lists bounded through
  500 cycles; the owned-frame, error, fresh-mount, late-reader, and cancellation
  assertions remain intact.
- Production build and source TypeScript checking pass. Existing build warnings
  remain. No semantic ruling or test expectation changed in this pass.

Broadly compacting every scoped queue suffix passed the scalar tests but was
slower. A revised version using `pop()` avoided expensive empty `copyWithin`
and array-length operations, but was replaced by the smaller, narrowly guarded
common case. Those broad compaction variants are not retained.

A proposed journal guard for never-published nodes duplicated an existing guard
in `graph.ts`. It was removed and is not counted as an optimization. Results
under `with-redundant-journal-guard` are intermediate, not the retained build.

The profiler still attributes substantial work to calculation, context routing,
and output adoption. Further work should target that overhead and the extra
computation at transparent boundaries, while retaining the current consistency
and ownership tests. This pass supplies finite evidence, not a proof for every
reactive graph or every engine's optimizer.

## Reproduction and artifacts

`results/performance-stage91/runtime-change.patch` isolates this pass from the
earlier uncommitted experiment. Source hashes, source snapshots, before/retained
CPU profiles, raw test reports, minified bundles, metadata, and rejected trials
are alongside it. `compat.json` is the next control run;
`retained-compat.json` is the candidate run. Use `final/` for retained feature
measurements and `sync/` for the byte-verified ordinary measurements.

Build and bundle from the repository root:

```sh
node experiments/layered-updates/build.mjs --scalar
MEASURE_OUT=/tmp/scalar-perf node experiments/layered-updates/measure.mjs /workspace/layered-baseline --scalar --bundle-only
```

`compare-performance-pass.mjs` takes an output JSON path followed by next,
pre-pass, and candidate bundle paths. It records worker/bundle hashes and raw
samples. `PERF_WORKER=experiments/layered-updates/optimistic-fanout-bench.mjs`,
`PERF_SAMPLES=5`, and `MEMORY_SAMPLES=0` select the fan-out comparison.
The default chain comparison uses seven samples and five paired memory probes.
`measure-inactive.mjs`, `measure-sync.mjs`, and `measure-active-contexts.mjs`
provide the other recorded workloads. Run timing commands sequentially, without
concurrent builds or test workers.
