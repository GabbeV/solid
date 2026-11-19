# Optimization implementation trials

Entry: `f5e7a5ce0`. Primary comparator: unmodified next
`4fe75321d61f9e4f1e1c63edc2087d099a36e9e1`. Each trial starts at the same
entry in a detached worktree. No semantic changes are authorized by this pass.

## Candidates and review gates

| Trial | Intended saving | Required evidence |
| --- | --- | --- |
| Inline calculation retry loop | Delete duplicate invocation, normalization, and catch paths | Preserve attempt reset, ownership, rejection sinks, and acceptance; measure JIT consequences |
| Partition insertion journal | Filter against this node's insertions instead of every insertion | Preserve graph order, error prefixes, duplicate entries and reference clearing; establish useful reachability and measure overhead |
| Skip empty landing composition | Avoid temporary queues and empty traversal in settled flushes | Preserve preparation/cleanup, ordering reset, and callbacks enqueued by seam hooks |

The scheduler candidate also applies to next. It is evaluated separately and is
not credited as an experiment-specific simplification.

Sol medium agents implement isolated changes and provide exact patches and JSON
test receipts. The primary reviews patches; the retry and journal agents also
cross-review each other's changes. Agent conclusions alone do not establish a
performance win or correctness.

Initial review: the retry-loop reset and exception handling remain equivalent.
The journal partition preserves membership, but its practical value is uncertain:
instrumented existing tests reduce no membership comparisons; a small nested lazy
memo case does (9 to 3). That operation count is not a timing result. The scheduler
trial initially skipped an ordering reset; primary review required restoring it.
Controls now compare callback ordering against unchanged implementations.

## Measurement

Use the repository's native Vitest benchmark harness against freshly built,
property-mangled production modules. Preserve existing reactivity and creation
cases. Add conventional public-API cases for settled reads, per-flush propagation,
inactive optimism and repeated active guesses. Each active case owns one held
action and checks visible publication and correction outside timing.

All variants use identical fixtures. Build, test, and time serially; do not time
while another agent runs CPU work. Record individual process results and repeat
alternating processes before interpreting differences. Every comparison table
uses unmodified next; entry-to-trial changes are attribution only. Measure the
same core, optimism, and observed-optimism consumer bundles as the prior checkpoint.

These benchmarks do not measure retry-heavy async lifecycles or prove retained
memory behavior. Source regression tests and production public-API controls
remain separate correctness gates. No diagnostic failure is automatically an
existing runtime bug: first compare the unchanged entry and reject an unsafe
optimization without broadening this task.

## Retention decisions

**Retain one calculation loop, with retry cleanup in a separate helper.** Both
initial execution and retries now use the same invocation, normalization and
exception handling. Reset still happens only between attempts, outside the
invocation catch; the outer acceptance finally is unchanged. No publication
guards, node fields, queues or caches were added or removed.

The fully inline version saved slightly more bytes, but enlarged the normal
calculation body with retry-only cleanup. Its longer timing runs raised a possible
small chain regression. The retained variant keeps that cleanup in
`resetCalculation`. We do not claim that outlining makes it faster: the final
board does not establish a repeatable speedup or a consistent added slowdown.

**Reject the journal partition for this pass.** It adds 69 minified / 23 Brotli
bytes to the optimism consumer. Across 885 instrumented existing tests, all 308
snapshot-producing parks had only local journal entries; membership work stayed
914 comparisons. A small ordinary nested-memo example does reduce comparisons,
but that does not establish enough practical benefit to retain the added code.
Its patch and correctness evidence are preserved for reconsideration.

**Keep the scheduler shortcut as a separate, unretained upstream candidate.** It
adds 44 minified / 22 Brotli bytes to the experiment's ordinary consumer (56 / 22
on pinned next). The controls pass, including hooks that enqueue callbacks and
cleanup/preparation opening an action. Repeated native timings did not establish
a convincing general win. The corresponding next patches remain in the receipts;
no general scheduler improvement is credited to this experiment.

## Shipped size

Same Rolldown consumer scenarios and production property-mangling pass as the
preceding checkpoint. Values are minified / Brotli bytes.

| Consumer | Unmodified next `4fe75321` | Entry `f5e7a5ce0` | Retained variant |
| --- | ---: | ---: | ---: |
| Ordinary core | 19,825 / 7,421 | 21,456 / 8,056 | 21,456 / 8,056 |
| Optimism | 30,556 / 11,180 | 37,279 / 13,462 | 37,115 / 13,444 |
| Observed optimism | 35,643 / 12,920 | 43,741 / 15,426 | 43,573 / 15,393 |

The saving is small: 164–168 minified bytes, 18–33 Brotli bytes. Optional-feature
Brotli size remains about 19–20% above next. This pass does not establish
mergeability or close the major size/performance gap.

## Validation

- Focused attempt/context/ownership/error tests: **284/284** pass for both loop
  variants; independent agent review plus primary inspection of reset ordering.
- Full signals suite on the retained variant: **5,802 pass, 1,953 fail, 2 skip**.
  Exact failing identities match the entry checkpoint; no failures were added or
  removed. The comparison uses `correctness-review/final/signals-retained.json`,
  the accepted prior runtime, not its rejected intermediate trial.
- Fresh property-mangled production public-API controls: **180/180** pass.
- **61/61** dist/tree-shaking checks pass as part of the full signals run.
- Production/observe builds, declaration build and purity checks pass. Final
  main-checkout source and production artifacts are checked against the tested
  candidate. This pass does not rerun the entire Solid/DOM suites.

## Measurement qualifications

The final board uses five alternating rounds on CPU 2, Node v24.19.0, with each
benchmark file in a fresh native Vitest process. The ordinary source and active
optimistic cases use identical fixtures on next and the experiment. New cases
warm up for 500 ms and measure for 1,000 ms; existing repository cases retain
their own settings. This is production preserved-module execution, not browser
or scope-hoisted consumer-bundle throughput. Size is measured separately on
consumer bundles. No allocation or retained-memory result is inferred from CPU
time or source inspection.

The first fixture draft used Vitest suite lifecycle hooks. The installed native
benchmark runner does not execute those hooks; Tinybench's default swallowed the
resulting warmup exceptions, leaving empty timing placeholders despite exit 0.
Primary inspection rejected those measurements. The committed fixtures use
Tinybench setup/teardown and `throws: true`; the measurement script also rejects
missing means/sample counts. Full action completion/correction is checked in an
awaited preflight using the same fixture factory. Timed teardown checks the held
result and disposes/releases synchronously; the next case awaits completion.
The final timed action's correction is not separately awaited or asserted.

Earlier screening and unpinned/shorter runs are preserved but are not the final
comparison below. Creation cases have substantial GC/run variance; their raw
results are included rather than promoted to precise speed claims. Existing
batched diamond/fan-out cases perform many writes in one flush. The new settled
cases perform 20 distinct flushes per measured body.

All runtime claims use unmodified next `4fe75321`; benchmark-only additions are
shared. The separately inspected current-next `bcef1041` was used for scheduler
correctness controls, not substituted into this performance baseline.

## Native timing board

Ratios are the median of five paired process means; **lower is faster**. The
range shows all five ratios, not a confidence interval. Each number compares the
retained variant with next. Raw means, sample counts and RME are archived.

| Native case | Time / next | Per-round range |
| --- | ---: | ---: |
| `createSignals` | 0.563× | 0.175–0.931× |
| `createComputations:create0to1` | 1.238× | 1.078–1.628× |
| `createComputations:create1to1` | 0.979× | 0.643–3.577× |
| `updateSignals:update1to1` | 1.060× | 0.916–1.079× |
| `updateSignals:update1to1000` | 0.963× | 0.913–1.097× |
| `propagation:diamond` | 0.998× | 0.879–1.013× |
| `propagation:avoidable` | 0.945× | 0.915–1.012× |
| `createRenderEffects:create1to1` | 0.972× | 0.911–1.421× |
| `createOwners` | 0.979× | 0.822–1.240× |
| `storeWrap:deep 1k records` | 0.705× | 0.503–1.115× |
| `storeWrap:shallow 1k records` | 0.999× | 0.344–1.125× |
| `createDispose:memoTree` | 0.277× | 0.210–1.357× |
| `settled:signalRead` | 0.932× | 0.824–1.029× |
| `settled:memoRead` | 0.696× | 0.569–0.920× |
| `settled:writeFlush` | 1.029× | 0.988–1.083× |
| `settled:chain20` | 1.018× | 0.970–1.089× |
| `settled:diamond` | 1.032× | 0.881–1.107× |
| `settled:fanout250` | 0.940× | 0.796–1.060× |
| `optimism:importedInactive` | 0.952× | 0.839–1.065× |
| `optimism:activeDirect` | 1.910× | 1.848–2.266× |
| `optimism:activeCallback` | 1.882× | 1.731–2.097× |
| `optimism:activeChain16` | 1.954× | 1.814–2.156× |
| `optimism:activeFanout128` | 2.115× | 2.052–2.377× |

Settled memo reads were faster than next in every round; signal reads were
usually faster. The small synchronous write/chain/diamond differences vary
between runs and are not established improvements. Constant-memo creation is
slower than next in this board. Active guesses remain approximately 1.9–2.1×
next by the paired medians. There is no claim of a uniform performance win.

## Where to investigate next

A separate 500-microsecond CPU-sampling run selected the native active-callback
case on next and the retained variant. The analysis distinguishes the worker from
the launcher and excludes setup/harness stacks; warmup remains included. These
profiles are diagnostic and are not included in the timing table.

The retained runtime spends substantial samples in proposal selection, position
calculation, application and adoption: the proposal hook has 29% inclusive sample
share, including `stageLayer` and `adoptOutput`. `settleObservations` has 5.3% self
sample share even though this fixture requests no observation outputs. Inclusive
shares overlap and cannot be summed. GC samples are unassigned; they do not
establish allocation costs.

Prioritize these two bounded investigations:

1. Verify the empty-observation path, then trial avoiding its empty iterations and
   clearing. Preserve live/reentrant iteration when either collection has work.
   Distinguish native full-module imports from consumer bundles that already
   remove the observation module; this cannot be credited to all import cases.
2. Trace proposal preparation/application and ordinary adoption together. Identify
   repeated obligations before attempting consolidation. The three batch phases
   protect nested-guess order independence; do not fuse them merely because the
   single-proposal profile spends time there.

Targeted source inspection also found repeated scope registration and hook
installation. The profile does not resolve those assignments as separate large
costs, so they remain lower-confidence hypotheses. No additional correctness bug
or required semantic decision was identified by this pass.

## Evidence

`checkpoints/optimization-trials-20261111.tar.xz` restores
`results/optimization-trials/`. It contains candidate patches, agent reports,
focused/source/production test receipts, full failure-identity comparison,
build/artifact hashes, size attribution, all native timing phases and CPU-profile
analysis. The `screen-*` results are the rejected fixture attempt and must not be
used as performance evidence. `pinned-*` is the final timing board.

The scripts record historical absolute checkout paths. Reproduction requires
separate checkouts at the recorded baseline/entry revisions, the recorded candidate
patch, and the identical benchmark fixtures; the main checkout now contains the
retained change. Do not rerun an entry-labelled command against today's main
checkout and call it the historical entry runtime.
