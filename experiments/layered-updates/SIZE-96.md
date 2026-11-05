# Stage 96: separate feature lifetimes from common publication

This pass keeps the scalar semantics and common publication machinery. It makes
user-guess lifetime an optional module, selects boundary behavior at creation,
and removes redundant source identity from temporary update admission records.
The ordinary core is unchanged from stage 95. The complete experiment remains
unaccepted: feature costs, missing APIs, renderer integration, and stores remain.

Baseline: unchanged next `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, Node 24.19.0.
All performance ratios below are to **next**, not to a toy implementation or an
arbitrary prototype. The stage-95 column attributes the change to this pass.

## Where the bytes were going

Stage 95's optimistic application was 31,594 minified / 11,480 Brotli bytes,
versus next's 27,250 / 9,864. The per-module esbuild attribution showed:

| Contribution, minified bytes | Next | Stage 95 |
| --- | ---: | ---: |
| Core computation | 7,092 | 6,205 |
| Scheduler | 5,341 | 6,393 |
| Legacy lanes | 5,111 | 0 |
| Layer coordinator, including guessing lifetime | 0 | 8,008 |
| Committed-dependency journal and depth traversal | 0 | 1,088 |

Other modules and the entry account for the remainder. These are minified
module contributions, not independently additive compressed sizes. The
experiment had removed the old lane implementation; it was not shipping both
engines. Its replacement coordinator was larger, with late context discovery,
retry/admission of fresh children, transfer of existing proposals, and retained
published dependencies. Some of these obligations cover cases next handles
differently or incorrectly; that does not establish that the extra code is
irreducible. Two full nodes mainly affect allocation cost, not this byte gap.

A separate avoidable problem was import coupling: pending/latest retained user
setter, proposal-batch and action-lifetime code. Internal layer fields also
lacked the underscore convention used by the repository's property mangler.

## Retained changes

- `coordination.ts` owns context selection, proposal transfer, readiness and
  publication. `optimistic.ts` owns user guesses and their action lifetime.
  `layer.ts` remains a small compatibility facade for explicit proposal/clear
  tests. Pending/latest import the coordinator without importing user guesses.
- Guess and observation lifetimes use the same prepare/settle interface. Calls
  are direct and ordered: retire guesses, prepare observations, then prepare
  ordinary readers; stage guesses before observations sample their consequences.
  Registration/import order cannot reverse these phases.
- Each boundary binds its selector once at allocation. Feature selectors choose
  input versus override. The common override read preserves the input
  subscription without consuming its proposal; ordinary node publication owns
  every resulting value, error, flight and child frame.
- Temporary admission records hold a set of consumed transactions, rather than
  a source-to-transaction map whose keys were not otherwise used. Merged aliases
  still resolve before coordination; no proposal read or publication assertion
  is dropped. Repeated resolution of the first input and merge depths is removed.
- Internal layer fields use the existing private-property mangling convention.
  Three metadata-inspection tests update member names; their assertions and
  visible-value expectations are unchanged. No new node fields, diagnostic,
  public API change or semantic ruling is introduced.

There is no unrelated optimization to unchanged next credited here.

## Shipped size

The same production Rollup, property-mangling, esbuild and Brotli-11 pipeline is
used for both runtimes. Ordinary and refresh scenarios remain available.

| Imports | Next Brotli | Stage 95 | Stage 96 | Saved |
| --- | ---: | ---: | ---: | ---: |
| ordinary | 8,116 | 8,068 | 8,068 | 0 |
| optimistic | 9,864 | 11,480 | 11,408 | 72 |
| pending | 10,419 | 12,127 | 11,625 | 502 |
| latest | 10,368 | 11,997 | 11,474 | 523 |
| refresh | 10,117 | 8,319 | 8,313 | 6 |
| optimistic-refresh | 10,208 | 11,693 | 11,659 | 34 |

The optimistic bundle loses 571 minified bytes, but only 72 Brotli bytes. Most
of the roughly 500-byte compressed savings in observation-only bundles comes
from no longer retaining the guessing lifetime. Optimism is still about 15.7%
larger than next; pending/latest remain about 11.6% / 10.7% larger.

Mixed imports were also measured, rebuilding **the exact stage-95 source**
(verified against its saved source hashes), then restoring and rebuilding the
working source through the same pipeline:

| Imports | Next Brotli | Stage 95 | Stage 96 | Saved |
| --- | ---: | ---: | ---: | ---: |
| optimistic-pending | 10,518 | 12,363 | 12,284 | 79 |
| optimistic-latest | 10,464 | 12,236 | 12,145 | 91 |
| optimistic-observations | 10,541 | 12,552 | 12,474 | 78 |

Thus the reduction is real for mixed applications too, but substantially smaller
when the application actually needs the user-guess lifetime.

## Rejected deletion and other trials

Deleting the separate registry of transactions with stale readers passed the
scalar tests and saved code, but was a bad tradeoff. Disposal then scanned all
live updates, including provisional transactions from fresh computations which
had not yet reached a flush. Repeated subtree creation/disposal before that
flush made the walk grow quadratically. With one open action the trial measured
967 times next, versus 2.68 for stage 95; with 128 actions it measured 2,057 times
next, versus 2.04. The targeted registry is restored, and the stress worker is
retained. A zero-leak result alone would not have detected this performance bug.

A generic lifecycle array was replaced with direct ordered calls. Further trials
moved the selector's indirect lifecycle callback to allocation and then removed
unneeded fallback dispatch from the common override read. Trial artifacts remain
separate; their favorable timings are not substituted for retained-bundle results.

## Performance

Ordinary-only application bundles are byte-identical to stage 95. The fresh
13-workload ordinary run in `final/sync/` measures that same code and retains all
raw samples. Existing small synchronous advantages matter; they are not newly
attributed to this pass. Feature-loaded and active results are mixed, not a claim
of uniform speedup. Seven triples were used for nested active overrides, five
for the broader active/pending workers, and three for the disposal stress check.

| Workload | Stage 95 / next | Stage 96 / next |
| --- | ---: | ---: |
| depth-1-top | 2.018 | 1.830 |
| depth-4-top | 2.171 | 1.833 |
| depth-16-top | 1.487 | 1.384 |
| inactive-ordinary-read-ns | 1.040 | 0.900 |
| inactive-ordinary-write-ns | 0.710 | 0.689 |
| active-depth-1-write-ns | 1.662 | 1.780 |
| active-depth-4-write-ns | 2.334 | 2.537 |
| active-depth-16-write-ns | 3.477 | 3.398 |
| active-direct-depth-1-write-ns | 1.608 | 1.572 |
| active-direct-depth-4-write-ns | 2.426 | 2.398 |
| active-direct-depth-16-write-ns | 3.536 | 3.446 |
| inactive-read-ns | 1.130 | 0.948 |
| inactive-write-ns | 0.939 | 1.038 |
| observed-sync-write-ns | 1.013 | 1.164 |
| held-input-depth-1-ns | 1.142 | 1.242 |
| held-input-depth-4-ns | 1.571 | 1.624 |
| held-input-depth-16-ns | 3.381 | 3.356 |
| dispose-with-1-open-updates-ns | 2.742 | 2.696 |
| dispose-with-128-open-updates-ns | 2.346 | 2.123 |

In particular the callback chains at depths 1 and 4 have worse point estimates;
these are not averaged away behind the nested or direct-input cases. The initial
pending worker also measured worse synchronous observed writes and worse shallow
held-input cases. These results limit any performance acceptance claim.

Two focused synchronous controls follow the initial unfavorable results:

| Control | Stage 95 / next | Stage 96 / next |
| --- | ---: | ---: |
| pending-observed-sync-write | 1.138 | 1.044 |
| memo-create-dispose | 1.042 | 1.010 |

The pending control uses `flush(update)` and longer warmed windows to avoid
accumulating a microtask per loop iteration. It verifies that pending remains
false and does not publish extra renders. The original worker remains reported.
The nine-triple creation control uses the unchanged inactive worker. Its paired
ratios do not reproduce the earlier candidate/next 1.156 result, but absolute
medians are 135 ns for next, 135 for stage 95 and 152 for stage 96, with wide
ranges. Small regressions or wins are not settled by these variable measurements.
No ordinary hot-path change was added to offset them.

Three paired GC checks retain zero disposed reader payloads in both runtimes.
Median callback-boundary heap deltas are about 1,064 bytes versus 556 for next;
direct boundaries about 1,049 versus 568. Binding only the selector and layer
reduces the boundary delta by roughly 16 bytes relative to stage 95. The two-node
cost remains. These are measured heap deltas, not exact object-layout guarantees.

## Validation and limits

- 456 scalar tests pass; the same 34 explicit baseline/legacy comparisons are
  excluded. Final source passes TypeScript and the production build.
- The unchanged selected upstream corpus remains 618 passes and 36 differences;
  failure identities match stage 95 (28 accepted model/layout/expected-failure
  differences, eight deferred outside-read cases).
- 500 seeds × 60 operations = 30,000 overlap operations pass, across all 11 tests.
- The final normal suite passes 5,683 tests with two skips. The ordinary core
  is byte-for-byte unchanged from stage 95; this suite does not establish
  coverage for the new scalar API.
- No test assertion was weakened and no warning/error diagnostic was added.
  Stores and the previously documented deferred APIs remain out of scope.

This is a locally retained size reduction with performance qualifications, not
proof that every graph is correct or that performance and size acceptance are
closed. The remaining coordinator is still the largest place to look for real
algorithmic sharing, especially discovery/admission and transfer of retained
frames. Dropping those obligations without a replacement would reintroduce
inconsistent publications.

## Reproduction and artifacts

Retained feature bundles and timings: `results/size-stage96/retained/`.
`combined-stage95/` and `combined-retained/` contain mixed-import sizes;
`measure-combined-history.py` reconstructs/verifies the two source checkpoints
and restores the workspace in a `finally` block. The main `measure.mjs` accepts
`--combined --bundle-only`. `source-hashes.json` and `module-bytes.json` identify
runtime sources and minified module contributions. `before/` records the entry
state. Earlier directories are trials, including the rejected reader-list walk.

Benchmarks run sequentially with no concurrent builds or tests. All baseline
bundles and the ordinary candidate are checked byte-for-byte against stage 95.
The pinned baseline checkout is not modified. No changes have been pushed.
