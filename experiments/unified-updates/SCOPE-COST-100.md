# Stage 100: share update scopes, isolate discovery work

Baseline: pinned next `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, Node 24.19.0.
This is another performance pass over the real scalar implementation. The
experiment remains **unaccepted**: this does not establish parity, complete API
coverage, or an acceptable final feature bundle size.

## Retained implementation

An optimistic proposal propagating through a chain already assigns the same
update to its ordinary consequences. Previously each memo separately saved the
ambient update and queues, entered its selected update, calculated, parked its
new proposals, and restored the ambient state. The next memo repeated that scope
setup even when it belonged to exactly the same update.

The heap drain can now retain that scope across adjacent eligible memos. Each
calculation still parks its writes and new children before proceeding. Each also
gets a fresh readiness check: a preceding calculation may start or cancel async
work. There is no cached readiness verdict, early commit, or changed read rule.
The pending-work scan runs only after identifying an eligible continuation;
when sharing cannot continue, the next ordinary visit performs its usual scan.
The normal height order remains intact, including lower entries added during a
calculation.

The fast path is intentionally bounded:

- Only an actual heap visit can authorize continuation. Read-triggered pulls,
  creation, cleanup-triggered calculations and preparation passes cannot drain
  other queued work on behalf of their caller.
- It starts with no ambient update and a non-null selected update.
- Adjacent nodes must be held by that exact update and have the same root-level
  owner. A computed owner, including one behind a root, uses individual scopes.
- A different update, ownership change, merge, effect, zombie, disposed node, or
  height-adjustment entry returns control to the ordinary heap loop. New unheld
  proposals or dependency-only publication obligations also end sharing, so the
  next visit can acquire the ambient update required by normal routing. A merge
  lowering the update to depth zero also ends sharing, even if its identity
  survives.

These conditions mirror the ordinary `rerunLayer` decision for the next visit:
there is no unpublished computed-owner frame, the node is not an effect, its
exact holder still has positive depth, and no unheld work requires an ambient
update. With the incoming scope originally null, that visit would select the
same update again. The optimization shares the setup only in that case.

No heap or node field is added. A private argument carries authorization from
the existing heap callback through the optional layer router. The legacy lane
build does not take this fast path.

The other change extracts calculation admission and retry handling from the
common calculation wrapper. An unchanged same-update read needs neither a set
of newly discovered contexts nor admission work. Calculations that do discover
contexts still complete the same joins, including on an ordinary error. A retry
still cancels the obsolete attempt, cleans up its children and flight, selects
the appropriate previous value, and calculates again before any peer joins.
This is a control-flow refactor, not a relaxation of memo entanglement.

Both optimizations address machinery introduced by this experiment. They are
not generic improvements to next credited as closing the experimental gap.

## What the work counts say

The default 16-boundary input-chain fixture now enters `recomputeInUpdate`
**twice**, versus 32 times at entry. It still performs 32 full calculations and
32 reads (the same full-calculation/read counts as pinned next). Admission and
retry helpers are not called in this stable chain.

It still performs 48 adoptions, holds and commits, and 37 readiness queries.
None of those counts is presented as equivalent-cost work. The pass reduces
scope setup; it does not remove the extra producer/output objects or their
publication bookkeeping. A diagnostic named-source build records the counts;
all acceptance timings use the separate production bundles.

## Trials

The first heap-sharing trial passed 465 scalar tests and improved deep-chain
measurements. Review identified that using only an ambient `runningHeap` marker
was too broad: a pull from a calculation or cleanup could also happen while the
heap was running. That implementation is not retained. The final version uses
explicit authorization from the heap callback and leaves `heap.ts` unchanged.

A subsequent review also retained the ordinary check for unheld proposals and
dependency-only publication obligations between adjacent calculations. The
earlier combined trial lacks that extra exit condition; the final campaign
measures the guarded implementation.

The separate calculation-wrapper trial also passed 465 tests. Its active
measurements were mixed, with modest deep-chain gains; the combined trial gave
larger deep-chain gains. All three trial bundles, timings and source snapshots
remain archived. No semantic difference is being accepted to obtain the gains.

Further trials investigated mixed short-path results:

- A separate drain helper preserved the old single-calculation wrapper, but
  did not establish a better overall performance tradeoff. It is removed.
- Reusing the transaction's pending latch to skip optimistic-lifetime lookups
  passed the scalar suite but gave mixed timing results. It is removed.
- Moving heap routing directly into the heap callback did not recover the
  ordinary memo-write advantage and gave mixed active timings. It is removed.
- Inspection found a redundant pending-work scan when the next node was not
  eligible to share the scope. Moving that scan after eligibility is retained;
  all publication checks still occur before a continuation.

These later trials and the complete campaign before that final scan-order
change are archived under `isolated/`, `latch/`, `route/`, and
`guarded-combined/`. The tables below measure the final scan order.

A final ablation restored the original calculation wrapper while retaining
scope sharing. It passed 467 scalar tests and saved 47 Brotli bytes, but did not
fix the cycle cost: one-override completion measured 1.661× next versus 1.568× for
the combined build in that campaign. It improved some callback-chain cases but
worsened the deep accessor chain (2.782× versus 2.546× next) and 512-reader fan-out
(1.853× versus 1.776×). That mixed result does not establish a better overall
alternative; the split wrapper is retained. Full results are in `no-extraction/`.

## Performance

All ratios below are execution time divided by **next**, lower is better. The
entry checkpoint is stage 99, remeasured in the same rotating process campaign;
it is not an alternative baseline. Raw process measurements, ranges, worker and
bundle hashes are retained. Builds and tests do not run concurrently with the
acceptance timing campaign.

| Workload | Stage 99 / next | Stage 100 / next |
| --- | ---: | ---: |
| **optimistic** | | |
| inactive-ordinary-read-ns | 0.968 | 0.993 |
| inactive-ordinary-write-ns | 0.836 | 0.855 |
| active-depth-1-write-ns | 1.498 | 1.523 |
| active-depth-4-write-ns | 2.188 | 2.054 |
| active-depth-16-write-ns | 2.710 | 2.483 |
| active-direct-depth-1-write-ns | 1.513 | 1.627 |
| active-direct-depth-4-write-ns | 2.248 | 2.053 |
| active-direct-depth-16-write-ns | 3.261 | 2.997 |
| **sync-input-chain** | | |
| transparent-1-write-ns | 1.776 | 1.563 |
| transparent-4-write-ns | 1.795 | 1.719 |
| transparent-16-write-ns | 1.990 | 1.803 |
| **expiry** | | |
| shared-1-complete-cycle-ns | 1.273 | 1.460 |
| shared-16-complete-cycle-ns | 2.216 | 2.244 |
| shared-128-complete-cycle-ns | 2.745 | 3.007 |
| **nested** | | |
| depth-1-top | 1.768 | 1.544 |
| depth-4-top | 1.466 | 1.358 |
| depth-16-top | 1.125 | 1.137 |
| **fanout** | | |
| fanout-16-write-ns | 2.093 | 1.690 |
| fanout-128-write-ns | 2.136 | 1.710 |
| fanout-512-write-ns | 2.015 | 1.368 |
| **independent** | | |
| independent-1-write-ns | 1.665 | 1.667 |
| independent-16-write-ns | 0.586 | 0.550 |
| independent-128-write-ns | 0.076 | 0.090 |
| **inactive-action** | | |
| inactive-sync-action-ns | 1.081 | 1.096 |
| **pending-sync** | | |
| pending-observed-sync-write | 1.106 | 1.137 |

Seven paired samples per ordinary workload:

| Ordinary workload | Stage 100 / next |
| --- | ---: |
| signal-read | 1.009 |
| memo-read | 0.901 |
| write-flush | 0.950 |
| equal-write | 1.009 |
| memo-write | 0.879 |
| batch-10-writes | 0.924 |
| chain | 0.950 |
| diamond | 0.958 |
| fanout-memos | 0.972 |
| fanout-effects | 0.981 |
| branch-switch | 0.967 |
| signal-create | 0.890 |
| memo-create-dispose | 0.902 |

Nine rotating triples per ordinary control:

| Control | Stage 99 / next | Stage 100 / next |
| --- | ---: | ---: |
| signal-read | 1.032 | 1.009 |
| memo-write | 0.945 | 1.012 |
| write-flush | 1.067 | 1.013 |

The clearest gains are in deeper chains and wider memo fan-out. The explicit
sync-input chain is still 1.80× next; default callback/accessor chains remain
2.48×/3.00× next. The 512-reader fixture reaches 1.37× next. Matching next's full
calculation count and reducing scope entries does not establish parity.

There are regressions too. Complete single-override cycles measure 1.46× next
versus 1.27× at entry, and 128-override cycles measure 3.01× versus 2.75×. The
single direct-input update, inactive action, pending-observed synchronous update
and 128-independent-action paired ratios also worsen. No across-the-board
speedup is claimed. The wider independent fixture remains much faster than
next, but that does not excuse a regression against the entry checkpoint.

### Ordinary measurement uncertainty

The ordinary production bundles in `guarded-combined/` and `retained/` are
byte-identical, including the separate synchronous-import bundles. Nevertheless,
their nine-triple controls differed: current signal-read ratios were 0.923 and
1.009; memo-write ratios 1.004 and 1.012; write/flush ratios 0.878 and 1.013. The
complete seven-pair campaigns varied further (for example, memo-write measured
0.917 and 0.879). These differences cannot be attributed to the intervening
scan-order change: there is no ordinary binary change.

A further nine-triple control pins the driver and all children to CPU 4:

| Pinned control | Stage 99 / next | Stage 100 / next |
| --- | ---: | ---: |
| signal-read | 0.978 | 0.982 |
| memo-write | 0.973 | 1.026 |
| write-flush | 0.979 | 0.912 |

This control suggests faster ordinary writes, approximately next's settled
signal-read cost, and a small memo-write regression. It does not eliminate the
measurement spread. The full ordinary table and all controls are retained;
small synchronous differences remain an acceptance concern, not a waived cost.
These runs do not establish a precise small-percentage win or regression for
every ordinary workload. `pinned-controls.py` and `pinned-controls.json` record
and reproduce the additional control.

## Size and memory

The same production Rollup/property-mangling/esbuild/Brotli-11 pipeline builds
both runtimes. These are bundled import scenarios. No per-node storage or new
retained collection is added; preserving two full boundary nodes still has its
previous memory cost.

| Imports | Next minified | Stage 100 minified | Next Brotli | Stage 99 Brotli | Stage 100 Brotli |
| --- | ---: | ---: | ---: | ---: | ---: |
| ordinary | 21,918 | 21,519 | 8,116 | 7,991 | 7,985 |
| optimistic | 27,250 | 32,360 | 9,864 | 11,667 | 11,843 |
| pending | 28,812 | 32,140 | 10,419 | 11,540 | 11,710 |
| latest | 28,715 | 31,717 | 10,368 | 11,392 | 11,557 |
| refresh | 27,892 | 22,182 | 10,117 | 8,251 | 8,234 |
| optimistic-refresh | 28,322 | 33,005 | 10,208 | 11,899 | 12,051 |
| optimistic-pending | 29,242 | 35,041 | 10,518 | 12,532 | 12,661 |
| optimistic-latest | 29,145 | 34,609 | 10,464 | 12,372 | 12,533 |
| optimistic-observations | 29,337 | 35,732 | 10,541 | 12,674 | 12,814 |

Optimistic imports grow 176 Brotli bytes in this pass and remain 20.1% larger
than next. Ordinary imports shrink six bytes and remain 1.6% smaller than next.
These feature costs remain outside an accepted final budget.

Three paired GC runs:

| Per-boundary retained heap | Next | Stage 100 |
| --- | ---: | ---: |
| callback input | 555 B | 1,063 B |
| default direct input | 568 B | 1,049 B |

All runs retain zero disposed reader payloads. These deltas do not measure
every temporary allocation; no per-boundary allocation reduction is claimed.

## Validation and limits

Two new observable regression tests exercise a chain under a plain root and
under a computed owner. They publish a first guess, suspend a second guess,
rerun a sibling reader through an unrelated write, supersede the suspended
work, deliver the obsolete answer, then complete the replacement and expire the
action. Both bindings must retain the previous published value while held. The
committed cleanup waits for publication, while the superseded proposal's
cleanup runs when that proposal is discarded. These tests pass on the validated
stage-99 entry implementation too; they do not introduce new semantics.

Final validation: 467 scalar tests pass with legacy lanes disabled (34 explicit
baseline/legacy cases excluded); 5,694 normal-entry tests pass (two skips).
The unchanged compatibility corpus reports 618 passes / 36 failures with exactly
the stage-99 failure identities. The 500-seed overlap campaign exercises 30,000
operations and all 11 tests pass. Fourteen focused production-define tests pass
(two legacy-baseline cases excluded). Source TypeScript and the new test's
TypeScript checks pass, as does the production scalar build.

A broader tests-included typecheck also exposed existing test typing errors
outside this pass, plus two readonly-tuple annotations in the new test. The new
annotations are fixed. The broader test typing suite is not claimed green; its
initial output is archived in `types-all-initial.log`. The source and new-test
checks have explicit reproducible configurations.

The first extended-overlap command accidentally retained Vitest's five-second
per-test default while increasing the campaign from 20 to 500 seeds. It timed
out at five seconds; the previous stage's same 500-seed test took about 57
seconds. The corrected extended command has an explicit 120-second execution
budget. The initial report is archived as `overlap-default-timeout.json`.
The normal suite retains its default timeout, and no correctness assertion or
performance/size acceptance threshold is relaxed.

A finite matrix and campaign do not prove correctness over all graphs. Stores,
full renderer/API integration, existing classified compatibility differences,
and performance/size acceptance remain outstanding. Sibling ordering remains
unspecified. No semantic ruling, public API change or diagnostic is added.

## Reproduction

Artifacts are under `results/scope-stage100/`. `runtime-change.patch` is the
runtime change relative to stage 99; `before/` contains the entry sources.
`validate.py` reproduces the scoped validation, including the extended overlap
campaign. `profile.mjs` generates diagnostic named/counting bundles from the
actual scalar source; their timings are not acceptance results.

Build with `node experiments/unified-updates/build.mjs --scalar`, then run
`measure.mjs /workspace/layered-baseline --scalar --bundle-only` with
`MEASURE_OUT` pointing to the stage's `retained/` directory. Add `--combined`
with a separate output directory for mixed imports. Run the stage's
`run-performance.mjs` for the serial performance campaign and ordinary controls.
The final runtime source hashes match the validated source; restored production
bundles are checked byte-for-byte against the measured bundles. All work remains
local; the pinned baseline has no tracked changes.
