> Follow-up: [stage 95](SIZE-95.md) retains the larger deletion with transaction-depth initialization, final validation, and new performance controls.

# Stage 93: register updates once through the common lifecycle

One narrow simplification is retained after testing larger removals. Ordinary
and optimistic updates already enter through the same transaction-creation hook.
The coordinator now registers them there once, rather than trying to discover
and register them again during reads, boundary ownership, and settlement.

This removes `watchParent`, redundant parent resolution/membership checks, an
unnecessary `inputUpdate` lookup at ownership, and the fallback registration scan
and its unused `hasHeldNodes` helper. Existing candidate membership, boundary
publication ownership, and their cleanup remain. No fields, flags, allocations,
semantic rules, APIs, test assertions, or acceptance thresholds were added or
changed. Stores remain paused.

Every comparison uses unchanged next at
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, Node 24.19.0. There are no unrelated
upstream optimizations credited toward this change.

## Why this deletion is valid

Every held node refers to an update created by `newTransaction`. That invokes
the common registration hook before the transaction can reach a reader. Merges
still transfer candidate membership to the surviving transaction; settlement
still prunes finished records. A read cannot discover a previously unregistered
live update. The former registration calls therefore repeated work already
performed by that common lifecycle. This is specific to the unified experiment,
not an assumption that legacy lanes and ordinary updates have the same lifecycle.

## Larger removals were rejected

The first trial removed the boundary's extra transaction pointer and active-layer
set, reading ordinary output ownership instead. A second trial replaced the
candidate-update set with the scheduler's live transaction array. Both looked
promising: their combination saved 151–177 Brotli bytes in feature bundles and
passed the scalar, migration, and overlap checks. A temporary shadow-record audit
also found no conflicting ownership decisions in the scalar suite.

However, a paired control with **16 active nested overrides** exposed a material
performance regression: the combined trial measured 2.329 times next versus
1.778 times next for the pre-pass build. Restoring boundary ownership alone still
left a regression (2.283 versus 1.676). An indexed array walk also failed to fix it
(2.266 versus 1.853). Removing boundary ownership alone was slower in that deep
case too. These removals are **not retained**, including the apparent eight-byte
per-boundary memory saving and the larger independent-action speedup.

V8 tracing showed deoptimizations in both builds, including around the worker's
GC, but did not establish the cause. No compiler explanation is asserted as a
fact, and the regression is not dismissed as noise. This pass does not establish
that those records are semantically necessary; it establishes that these
implementations failed the performance check.

A separate trial reused the committed-dependency generator inside depth
calculation. It saved another 21–45 Brotli bytes but showed a single-boundary
callback slowdown (2.106 times next versus 1.696 without that trial, three
process samples). It was also rejected; the explicit traversal remains.

The retained registration-only change passed the same five-pair nested control:

| Active nested depth | Pre-pass / next | Retained / next |
| --- | ---: | ---: |
| 1 | 2.279 | 2.223 |
| 4 | 2.011 | 1.979 |
| 16 | 1.746 | 1.674 |

Both columns use next as the baseline. The pre-pass column isolates attribution;
it is not an alternative correctness or performance baseline.

## Size

Actual production Rollup output, then the same esbuild/property-mangling and
compression pipeline for both runtimes:

| Imports | Next Brotli | Before this pass | Retained Brotli | Bytes removed |
| --- | ---: | ---: | ---: | ---: |
| Ordinary/action | 8,116 | 8,069 | 8,068 | 1 |
| Optimistic | 9,864 | 11,627 | 11,546 | 81 |
| Pending | 10,419 | 12,291 | 12,202 | 89 |
| Latest | 10,368 | 12,155 | 12,054 | 101 |
| Refresh | 10,117 | 8,338 | 8,319 | 19 |
| Optimistic and refresh | 10,208 | 11,862 | 11,762 | 100 |

Optimistic minified bytes fall from 32,064 to 31,844; pending from 34,331 to
34,108; latest from 33,859 to 33,642. The ordinary/refresh compressed changes are
bundler-layout effects from removing an unused exported helper, not runtime
optimization. Optimistic and pending bundles remain about **17% larger than
next**. This is a modest deletion, not closure of the size acceptance gap.

## Ordinary synchronous performance

Seven alternating fresh-process pairs, measured on the exact final ordinary
benchmark binary (verified after the final rebuild). Ratios are to pinned next.
There is no ordinary runtime optimization in this pass, so these gains describe
the current experiment and are not newly attributed to registration cleanup.

| Workload | Retained / next time | Measured difference |
| --- | ---: | ---: |
| signal-read | 0.951 | 4.9% faster |
| memo-read | 0.925 | 7.5% faster |
| write-flush | 0.974 | 2.6% faster |
| equal-write | 1.020 | 2.0% slower |
| memo-write | 1.017 | 1.7% slower |
| batch-10-writes | 0.938 | 6.2% faster |
| chain | 0.962 | 3.8% faster |
| diamond | 0.937 | 6.3% faster |
| fanout-memos | 0.919 | 8.1% faster |
| fanout-effects | 1.015 | 1.5% slower |
| branch-switch | 0.963 | 3.7% faster |
| signal-create | 0.805 | 19.5% faster |
| memo-create-dispose | 0.924 | 7.6% faster |

Small wins remain relevant individually. These are paired medians, not portable
guarantees; ranges overlap in many cases. Memo-write and effect fan-out do not
establish wins in this run.

## Active feature measurements

Five rotating fresh-process triples per workload. Both columns are ratios to
next. These do not replace the nested-override control above: writing a root
through otherwise inactive boundaries and writing beneath several active
boundaries exercise different paths.

| Workload | Pre-pass / next | Retained / next |
| --- | ---: | ---: |
| active-depth-1-write-ns | 2.248 | 1.936 |
| active-depth-4-write-ns | 2.800 | 2.772 |
| active-depth-16-write-ns | 4.104 | 3.991 |
| active-direct-depth-1-write-ns | 2.003 | 2.092 |
| active-direct-depth-4-write-ns | 2.888 | 2.897 |
| active-direct-depth-16-write-ns | 4.179 | 4.106 |
| fanout-16-write-ns | 2.404 | 2.386 |
| fanout-128-write-ns | 2.327 | 2.356 |
| fanout-512-write-ns | 4.136 | 3.879 |

The direct single-boundary case and 128-memo fan-out have worse point estimates
in this run, with overlapping ranges. They are not omitted in favor of the
callback and large-fan-out gains. The retained build does not reproduce the
large deep-nesting regression of the rejected removals, but these finite runs
cannot rule out every small performance regression.

Five paired GC probes retain zero disposed reader payloads in both runtimes.
Boundary heap deltas are approximately 1,088 versus next's 555 bytes for callback
inputs, and 1,073 versus 568 for direct inputs. They include registry capacity
and reuse, not just object sizes. The final change removes no per-boundary field
and claims no per-boundary allocation saving.

### Longer-warmed single-boundary control

Seven rotating process triples, each with three 50,000-write warm-ups and five
50,000-write samples per input form:

| Input | Pre-pass / next | Retained / next |
| --- | ---: | ---: |
| single-callback-write-ns | 2.165 | 2.047 |
| single-direct-write-ns | 2.029 | 1.959 |

This supports an improvement in the small case, while active single-boundary
updates remain approximately twice next's cost. It does not erase the worse
point estimates in the broad worker.

### Many independent actions

A new worker holds 1, 16, or 128 separate actions open, with an optimistic output,
a doubled memo, and a scheduled render effect for each. Writes rotate through
outputs. Assertions check every published value and all final reversions. Five
rotating process triples; no shared derivation entangles these actions.

| Open actions | Pre-pass / next | Retained / next |
| --- | ---: | ---: |
| 1 | 2.152 | 2.157 |
| 16 | 0.745 | 0.814 |
| 128 | 0.100 | 0.110 |

At 128 actions the retained build is about nine times faster than next in this
stress workload, but the pre-pass build was faster still. The point estimates
worsen at 16 and 128 actions, with overlapping ranges. This is not reported as a
new gain or ignored because both runtimes beat next here. The larger registry
removal improved this workload more, but was rejected for its deep-nesting cost.

## Synchronous work with inactive optimism

Seven alternating pairs keep one unused optimistic output alive. There is no
async calculation and no active guess. This is separate from ordinary-only
imports, whose exact benchmark binary is unchanged by the feature edits.

| Workload | Retained / next time |
| --- | ---: |
| memo-read | 0.955 |
| memo-write | 0.909 |
| batch-10-writes | 0.963 |
| chain | 0.970 |
| diamond | 1.033 |
| branch-switch | 1.007 |
| fanout-effects | 1.011 |
| memo-create-dispose | 1.016 |

These results describe the retained build, not an attributed gain over the
pre-pass build. Small creation, branch-switch, and effect-fan-out overheads remain
visible rather than being hidden by other wins. Raw ranges and samples are saved.

## Validation and scope

- Final scalar variant: 456 passes, zero failures, the same 34 explicit
  baseline/legacy comparisons excluded.
- Final unchanged selected upstream corpus: 618 passes and the same 36 failure
  identities as stage 92 (28 accepted model/layout/expected-failure differences,
  eight deferred outside-read cases). No assertions changed.
- Final overlapping-update campaign: 500 seeds × 60 operations = 30,000
  operations; all 11 tests in the file pass.
- Normal-entry suite during this pass: 5,683 passes and two skips. This largely
  exercises the legacy engine; the final shared-core edit only deletes an unused
  helper. It is not evidence for complete candidate API support.
- Source TypeScript, production build, and whitespace checks pass. Existing
  build warnings are unchanged. No diagnostic or assertion remains in runtime.

This remains a scalar prototype. These tests and finite overlap campaigns are
not a proof for arbitrary graphs. Active optimism cost, feature size, omitted
APIs, renderer integration, and stores remain acceptance work. See
[stage 90](SCALAR-MILESTONES-90.md) for the validated semantic scope.

## Artifacts and reproduction

Use `results/size-stage93/final/` for retained feature measurements. `before/`,
`runtime-change.patch`, and `source-hashes.json` isolate this pass from the
existing uncommitted work. `ownership/`, `transactions/`, `combined/`, `registry/`,
`indexed/`, and `traversal/` are rejected trials; `registration/` is the retained
variant's initial nested control. Do not substitute the rejected builds' more
favorable size, memory, or independent-action numbers for the final results.

Timing processes run sequentially, without concurrent builds/tests. Raw JSON
contains hashes, samples, and ranges. The ordinary benchmark in `sync/` was
measured during this pass and checked byte-for-byte against the final rebuilt
ordinary benchmark, so its measurements still apply to the retained code.

```sh
node experiments/unified-updates/build.mjs --scalar
MEASURE_OUT=experiments/unified-updates/results/size-stage93/recheck node experiments/unified-updates/measure.mjs /workspace/layered-baseline --scalar --bundle-only
node experiments/unified-updates/measure-sync.mjs experiments/unified-updates/results/size-stage93/recheck-sync
```

`compare-performance-pass.mjs` takes an output JSON path followed by the next,
pre-pass, and candidate bundles. `PERF_WORKER` selects the chain (default),
fan-out, single-boundary, independent-action, or nested-context worker. The
nested adapter reuses the existing fixture without duplicating its assertions.
