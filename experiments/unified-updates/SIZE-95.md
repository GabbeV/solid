> Follow-up: [stage 96](SIZE-96.md) separates optional feature lifetimes and measures the remaining size gap.

# Stage 95: retain shared publication ownership and transaction membership

The larger deletion from stages 93–94 is retained with one representation change:
when the optional layer coordinator creates a transaction, it initializes that
transaction's depth to zero. Parent and child transactions therefore start with
the same fields; selecting a child changes an existing numeric field instead of
adding one. No ordinary signal or memo gets a new field, branch, or allocation.
Ordinary-only bundles erase this initialization together with the coordinator.

No semantic ruling, public API, diagnostic, test assertion, or acceptance
threshold changed. Stores remain paused. The baseline is pinned next at
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, Node 24.19.0. All retained changes are
specific to the experiment; there is no unrelated upstream optimization credited
against its overhead.

## What is shared now

- The output node's ordinary transaction stamp is its publication ownership.
  `Layer.update`, the active-layer set, and finished-layer cleanup are removed.
  Ordinary publication already clears that stamp, and ordinary merging resolves
  it. Selecting another guess and joining a correction use the same ownership.
- The scheduler's live transaction array is also the coordinator's update list.
  The candidate-update set, merge transfer, and completed-candidate scans are
  removed. The ordinary creation hook activates coordination; it turns off when
  idle.
- `scope` remains the guessing action's lifetime. That is not duplicate
  publication state: a guess can finish publishing while its action stays open.
  Value/proposal storage, error handling, and child publication still use the
  ordinary output node. This deletion does not conflate a new guess with the
  output's committed value.

A preparation replay can merge and splice the shared transaction array. Such a
replay marks the preparation round changed; the fixed-point loop repeats before
publication and visits entries shifted past the current iterator. Remaining
readers transfer to the surviving update. Sibling callback order is unchanged
and remains unspecified.

## Why the previous regression no longer blocks this version

Stage 94 established that the larger deletion could be faster at depth 16 in a
fresh process, but slower after creating and disposing depths 1 and 4. Separately
instrumented executions counted identical recomputation/preparation passes.
That made optimization history a concrete concern, not a semantic justification
for keeping the duplicate records.

This pass tested three refinements on the real core:

1. Replace the bound selector with a factory closure capturing only selection
   state. All 456 scalar tests passed, but the deep case remained unfavorable.
2. Split reader preparation out of the larger preparation function. It did not
   reliably eliminate the regression.
3. Initialize transaction depth and boundary position at creation. This helped.
   Removing the boundary-position initialization kept the improvement, so only
   transaction-depth initialization remains. The bound selector and original
   preparation function are retained.

The initial nested trial for the final representation measured 1.809 / 1.634 /
1.520 times next at depths 1 / 4 / 16, versus 2.098 / 2.045 / 1.791 for the retained
stage-93 control. Fresh seven-sample controls on the final build then measured:

| Workload | Stage 93 / next | Stage 95 / next |
| --- | ---: | ---: |
| Active depth 1, original sequential worker | 2.137 | 2.034 |
| Active depth 4, original sequential worker | 1.940 | 1.789 |
| Active depth 16, after depths 1 and 4 | 1.783 | 1.425 |
| Active depth 16 alone, fresh process | 1.828 | 1.481 |

Both histories remain checks; the unfavorable history was not removed or given
extra warm-up. Both columns use **next** as baseline. The stage-93 column allows
attribution without treating another prototype as the acceptance baseline.

Initializing the field is a measured remedy, and makes the record representation
more uniform. These measurements do not prove the exact V8 mechanism or establish
performance on every engine. No compiler flags, engine-specific intrinsics, or
benchmark instrumentation remain in runtime.

## Size

Production Rollup output, followed by the same application bundling, property
mangling, and compression pipeline for both runtimes:

| Imports | Next Brotli | Stage 93 | Stage 95 | Saved this pass |
| --- | ---: | ---: | ---: | ---: |
| Ordinary/action | 8,116 | 8,068 | 8,068 | 0 |
| Optimistic | 9,864 | 11,546 | 11,480 | 66 |
| Pending | 10,419 | 12,202 | 12,127 | 75 |
| Latest | 10,368 | 12,054 | 11,997 | 57 |
| Refresh | 10,117 | 8,319 | 8,319 | 0 |
| Optimistic and refresh | 10,208 | 11,762 | 11,693 | 69 |

Compared with the start of the size investigation (stage 92), the feature bundles
lose 147–169 Brotli bytes. The optimistic minified bundle is 31,594 bytes, versus
31,844 at stage 93 and 32,064 at stage 92. This is a modest byte saving coupled to
a bookkeeping simplification. Optimistic/pending bundles are still roughly 16%
larger than next; the broader size acceptance gate is not closed.

## Ordinary synchronous performance

The ordinary application **and ordinary benchmark** are byte-for-byte identical
to stage 93. Its seven-pair measurements therefore describe this exact binary;
these are not new speedups attributed to this pass.

| Ordinary workload | Stage 95 / next time |
| --- | ---: |
| Signal read | 0.951 |
| Memo read | 0.925 |
| Write and flush | 0.974 |
| Equal write | 1.020 |
| Memo write | 1.017 |
| Ten writes per batch | 0.938 |
| Chain | 0.962 |
| Diamond | 0.937 |
| Memo fan-out | 0.919 |
| Effect fan-out | 1.015 |
| Branch switch | 0.963 |
| Signal creation | 0.805 |
| Memo creation/disposal | 0.924 |

The 7.5% memo-read, 6.3% diamond, 8.1% memo-fan-out, and 19.5% signal-creation
wins remain individually relevant. Equal writes, memo writes, and effect fan-out
remain slightly slower in those measurements. Ranges overlap in many small
cases; these are measured paired medians, not portable guarantees.

## Broader performance and inactive-feature controls

All times below are paired ratios to pinned next (smaller is better). These are
fresh-process comparisons of the final bundles, not comparisons to a toy model.
Five triples were used except seven for the longer single-boundary and inactive
action controls. Callback/direct chains contain one active override followed by
transparent boundaries; they differ from the nested active-override worker above.

| Workload | Stage 93 / next | Stage 95 / next |
| --- | ---: | ---: |
| Callback chain 1 | 1.986 | 1.850 |
| Callback chain 4 | 2.509 | 2.352 |
| Callback chain 16 | 3.935 | 3.664 |
| Direct-input chain 1 | 1.821 | 1.544 |
| Direct-input chain 4 | 2.958 | 2.346 |
| Direct-input chain 16 | 4.099 | 3.835 |
| Longer warmed single callback | 2.106 | 1.923 |
| Longer warmed single direct input | 2.065 | 1.801 |
| Optimistic fan-out 16 | 2.238 | 2.382 |
| Optimistic fan-out 128 | 2.414 | 2.400 |
| Optimistic fan-out 512 | 4.372 | 2.810 |
| One independent action | 2.351 | 1.933 |
| 16 independent actions | 0.884 | 0.673 |
| 128 independent actions | 0.091 | 0.072 |
| Ordinary action, unused optimistic boundary alive | 1.264 | 1.045 |

The fan-out-16 point estimate is worse: ranges overlap (stage 93: 11.34–13.32 μs;
stage 95: 11.27–16.08 μs), but it is not counted as an improvement. The independent
action stress test exposes a large pre-existing advantage over next; this pass
must not be credited with creating the whole advantage. Common small optimistic
updates remain materially slower than next.

With an unused optimistic boundary alive, seven-pair synchronous controls give
candidate/next ratios of 0.967 for memo reads, 0.709 for memo writes, 0.892 for
batches, 0.886 for chains, 1.002 for diamonds, 0.877 for branch changes, 0.987 for
effect fan-out, and 1.038 for memo creation/disposal. A separate seven-triple
creation control instead gives 0.935 for stage 93 and 0.921 for stage 95. These
small, variable results do not justify a claim of uniformly improved sync speed.

A final five-triple pending-observer control also exercises the shared coordinator:

| Pending workload | Stage 93 / next | Stage 95 / next |
| --- | ---: | ---: |
| Inactive ordinary read | 0.889 | 0.926 |
| Inactive ordinary write | 0.984 | 0.876 |
| Observed synchronous write | 0.882 | 0.878 |
| Held input, memo depth 1 | 1.161 | 1.006 |
| Held input, memo depth 4 | 1.711 | 1.462 |
| Held input, memo depth 16 | 3.631 | 3.028 |

The deep pending chain still costs about three times next. Inactive reads remain
subject to the variation investigated below; the 0.889 versus 0.926 point
estimates are included rather than silently classified as a win.

### Inactive signal-read uncertainty

The first broad trial suggested a regression, so it received focused controls:

| Control | Stage 93 / next | Stage 95 / next |
| --- | ---: | ---: |
| Seven fresh-process triples | 0.878 | 0.963 |
| Fifteen additional triples, same worker | 0.979 | 0.924 |

The first trial's absolute medians were 6.57 / 7.10 ns; the repeat's were
6.71 / 6.66 ns. Both runs remain in the artifacts. A nine-triple A/A control then
used the **identical stage-95 bundle** in both candidate slots: it reported
0.958 / 0.926 relative to next (absolute medians 7.02 / 6.56 ns). Thus a substantial
spread can occur without any code difference. We have neither a reproducible
inactive-read regression nor evidence for an inactive-read improvement. No extra
fast path was added to offset the initial result, and no favorable run replaces
an unfavorable one.

Separate diagnostic copies confirmed the read functions are structurally
identical modulo identifier names, have the same read-state flags, and both
reach V8's optimizing compiler. Those instrumented copies and native compiler
flags were used only for diagnosis, not acceptance timing or shipped runtime.
Engine and machine coverage remain limited.

Five GC samples found zero retained reader payloads in both runtimes after
disposal. The median heap delta per callback boundary was about 1,080 bytes
versus 556 for next; direct-input boundaries were about 1,065 versus 568. This is
roughly eight bytes below stage 93, with the expected two-node cost still present.
The optional coordinator now initializes a depth field on parent transactions
as well as child transactions; its per-transaction heap cost was not isolated.
The inactive ordinary-action control exercises that path without async work.

## Validation and remaining scope

- 456 scalar tests pass, with the same 34 explicit baseline/legacy comparisons
  excluded.
- The unchanged selected upstream corpus remains 618 passes and 36 classified
  differences. Failure identities match stage 93 exactly: 28 accepted model/
  layout/expected-failure differences and eight deferred outside-read cases.
- 500 seeds × 60 operations = 30,000 overlapping-update operations pass; all 11
  tests in that file pass.
- The normal entry passes 5,683 tests with two skips. This primarily validates
  the legacy entry; it is not evidence of full candidate API coverage.
- Final-source scalar rerun and source TypeScript pass; production build passes. Existing build warnings remain.
  No tests were weakened and no diagnostic was added.

This is a validated scalar simplification, not acceptance of the complete
experiment. Active optimism remains slower than next in common small cases;
feature size, omitted APIs, renderer integration, and stores remain work. See
[stage 90](SCALAR-MILESTONES-90.md) for semantic scope. The finite tests and timing
campaign do not prove arbitrary graph correctness or universal performance.

## Artifacts

Use `results/size-stage95/final/` for retained production measurements. The
`closure/`, `split-readers/`, and `stable-records/` directories are trials;
`stable-update/` is the initial successful representation. `before/`,
`runtime-change.patch`, and `source-hashes.json` isolate this pass from existing
local work. The final helper rename changed minified naming, so the final bundles
were freshly measured instead of substituting the initial trial's numbers.

Timings run sequentially without concurrent builds/tests. The JSON retains
worker/bundle hashes, raw samples, ranges, and paired medians. Baseline bundles
are byte-checked against pinned next. The standard build, bundle, and comparison
commands are the same as in [stage 93](SIZE-93.md).
