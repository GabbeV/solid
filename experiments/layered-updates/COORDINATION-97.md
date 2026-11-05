# Stage 97: remove duplicated readiness and speculative allocation

Baseline: unchanged next `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, Node 24.19.0.
The retained changes run in the real scalar Solid core. Stores and the previously
deferred APIs are not added. The broader experiment is **not accepted**: active
optimism remains substantially slower and feature bundles remain larger than next.

## Retained changes

1. **A discovery scope is not an update.** Fresh computations enter an isolated
   execution scope, but acquire a transaction only when consuming a held proposal
   or starting asynchronous work. Root and owned-child creation use one path.
   Settled synchronous subtrees no longer accumulate empty transactions while an
   unrelated action is open. No field is added to ordinary nodes.
2. **Discarded children cannot replay the accepted parent.** The first lazy-scope
   trial exposed a stale rerun obligation on a provisional child which a context
   retry had disposed. Eager parent allocation had masked it by changing update
   iteration order. At acceptance, remove that parent's obligation from the
   discarded child's original update. Do not resolve the discarded update and
   delete obligations from its surviving merge target. Accepted children retain
   their deferred peer joins. The existing multi-peer owned-child regression is
   unchanged; a new bounded-bookkeeping test exercises 500 create/read/dispose
   cycles without an intervening flush and checks values and exact cleanup counts.
3. **Preparation reuses the scheduler's waiting-reader index.** It no longer walks
   every open transaction, calls readiness for updates without waiting readers,
   or creates empty arrays for those entries. Merge and disposal already maintain
   this index. A replay requests another preparation round before publication.
4. **Override expiry uses ordinary readiness.** The separate action-specific
   `ownFlights` test, input-waiting scan, and temporary waiting set are removed.
   The existing `pendingScope` hook includes guessed inputs in ordinary readiness.
   Upper calculations have their own transaction ownership; the legacy lane's
   distinction between its flights and its parent's flights is no longer needed
   here. Expiry still merges correction into the action and supersedes obsolete
   upper async work. Cancellation, correction waterfalls, overlapping scopes,
   matching answers, and owned frames retain their observable assertions.
5. **Remove now-unused lane bookkeeping from the scalar build.** `ownSource`
   filtering is legacy-only. So are the action-origin flag, action question
   stamps, and the cold extension's `_q`/`_lane` slots. Their remaining consumers
   are the legacy lane/store implementation. Ordinary flight identity still
   rejects superseded async answers. This removes one transaction field and two
   cold-extension fields; it adds no hot-node storage. The normal entry retains
   the legacy machinery. These are compile-time exclusions, not runtime feature
   branches in scalar production bundles.
6. **Smaller local work.** A proposal-read check computes dependency depth at most
   once before a retry. Internal observation records and dispatch fields follow
   the private-property mangling convention already used by the repository. One
   metadata test updates member names; no observable assertion is weakened.

The readiness change is tied to the layered model's ownership, not a generic
optimization credited against next. The provenance/slot deletions likewise rely
on the replacement engine. No unrelated upstream optimization is counted here.

## Size

Same production Rollup/property-mangling/esbuild/Brotli-11 pipeline for both.

| Imports | Next Brotli | Stage 96 | Stage 97 | Saved this pass |
| --- | ---: | ---: | ---: | ---: |
| ordinary | 8,116 | 8,068 | 7,970 | 98 |
| optimistic | 9,864 | 11,408 | 11,196 | 212 |
| pending | 10,419 | 11,625 | 11,427 | 198 |
| latest | 10,368 | 11,474 | 11,320 | 154 |
| refresh | 10,117 | 8,313 | 8,180 | 133 |
| optimistic-refresh | 10,208 | 11,659 | 11,406 | 253 |

The optimistic bundle loses 560 minified / 212 Brotli bytes this pass. Ordinary
imports lose 324 minified / 98 Brotli bytes. Optimism remains 13.5% larger than
next compressed; ordinary imports are 1.8% smaller. This is a real but limited
reduction, not evidence that the remaining coordination cost is irreducible.

| Mixed imports | Next Brotli | Stage 96 | Stage 97 |
| --- | ---: | ---: | ---: |
| optimistic-pending | 10,518 | 12,284 | 12,024 |
| optimistic-latest | 10,464 | 12,145 | 11,912 |
| optimistic-observations | 10,541 | 12,474 | 12,218 |

## Performance

Every ratio is execution time divided by **next**. Lower is better. The stage-96
column is the validated checkpoint measured in the same rotating three-process
campaign, for attribution; it is not an alternative baseline. No build or test
ran concurrently with these timing campaigns. All samples, ranges, bundle hashes
and worker hashes are retained. Small improvements and regressions are not
averaged away behind the much larger active-optimism costs.

Seven paired samples per ordinary workload:

| Ordinary workload | Stage 97 / next |
| --- | ---: |
| signal-read | 0.937 |
| memo-read | 0.922 |
| write-flush | 1.168 |
| equal-write | 0.995 |
| memo-write | 0.945 |
| batch-10-writes | 0.953 |
| chain | 0.993 |
| diamond | 0.951 |
| fanout-memos | 0.930 |
| fanout-effects | 0.960 |
| branch-switch | 0.920 |
| signal-create | 0.850 |
| memo-create-dispose | 1.003 |

Five triples per feature workload, except the nine-triple pending control:

| Workload | Stage 96 / next | Stage 97 / next |
| --- | ---: | ---: |
| depth-1-top | 1.819 | 1.945 |
| depth-4-top | 1.842 | 1.893 |
| depth-16-top | 1.367 | 1.412 |
| dispose-with-1-open-updates-ns | 3.300 | 1.248 |
| dispose-with-128-open-updates-ns | 1.686 | 1.613 |
| inactive-ordinary-read-ns | 0.939 | 0.993 |
| inactive-ordinary-write-ns | 0.847 | 0.807 |
| active-depth-1-write-ns | 1.759 | 1.493 |
| active-depth-4-write-ns | 2.619 | 2.898 |
| active-depth-16-write-ns | 3.704 | 3.865 |
| active-direct-depth-1-write-ns | 1.568 | 1.686 |
| active-direct-depth-4-write-ns | 2.663 | 2.803 |
| active-direct-depth-16-write-ns | 4.004 | 3.837 |
| pending-observed-sync-write | 1.042 | 1.128 |
| pending-observed-sync-write (control) | 1.200 | 1.115 |
| shared-1-complete-cycle-ns | 1.245 | 1.263 |
| shared-16-complete-cycle-ns | 2.584 | 2.324 |
| shared-128-complete-cycle-ns | 5.375 | 5.231 |
| independent-1-write-ns | 1.980 | 1.910 |
| independent-16-write-ns | 0.749 | 0.709 |
| independent-128-write-ns | 0.074 | 0.067 |
| inactive-sync-action-ns | 1.151 | 1.198 |

The initial ordinary write/flush result warranted a direct 11-triple control
against next and the validated stage-96 ordinary bundle. It measured **0.964×
next for stage 96 and 0.926× next for stage 97**, with absolute medians of
232.5 / 222.5 / 218.5 ns (next / stage 96 / stage 97). This does not reproduce
the initial 1.168× next result. Both campaigns remain reported; the variation
prevents treating a small difference as a guaranteed improvement.

Active results are mixed. The disposal improvement is substantial; deep transparent
optimistic chains still cost about four times next, and completing a shared action
across 128 boundaries costs about five times next. The latter worker is new and
checks both guessed and corrected publications on every cycle; open-action write
benchmarks alone would not expose expiry cost. The grouped-lifetime trial below
remains a possible scaling direction, not an accepted solution.

The pending control does not reproduce the initial worsening relative to the
checkpoint, but both builds remain slower than next. These measurements do not
establish a universal performance improvement or close the acceptance gap.

Three paired GC runs retain zero disposed reader payloads for either runtime.
Median optimistic boundary heap deltas are about 1,064 bytes versus 555 for next;
direct-input boundaries about 1,049 versus 568. Two full nodes remain the main
boundary allocation cost; cold-slot deletion does not halve it.

## Rejected trials

- Merely making the root transaction lazy failed an existing owned-child
  multi-peer retry test. The stale rerun obligation was diagnosed and fixed;
  the failure was not relabeled as a semantic change.
- Bypassing the discovery wrapper for internal active selectors passed tests but
  added a branch/code and did not establish a speed advantage. It is removed.
- Indexing boundaries by their action scope passed 456 tests and improved the
  many-independent-actions trial, but added a map of sets plus merge bookkeeping
  and 174 minified bytes relative to its starting variant. It is not retained.
  It deserves a separate targeted experiment on shared-action expiry; the
  broader improvement cannot simply be attributed to that index because the
  trial also included the other changes under test.

## Validation and limits

- 457 scalar tests pass with legacy lanes disabled (34 explicit baseline/legacy
  comparisons excluded, as before).
- The selected upstream corpus remains 618 passes and 36 failures, with exactly
  the same failure identities as the entry checkpoint: 28 classified model,
  layout or expected-failure differences, and eight deferred outside-read cases.
- 500 seeds × 60 operations = 30,000 overlap operations pass (all 11 tests).
- Normal-entry suite: 5,684 passes, two skips. TypeScript and production build pass.
- No consistency assertion is weakened, no diagnostic is added, and no new API
  or semantic ruling is assumed. Finite tests do not prove all graphs correct.

The highest remaining cost is still coordination/adoption through transparent
boundary chains, plus expiry across many boundaries. The pass removes genuine
redundancies but does not justify declaring the broader experiment mergeable.

## Reproduction

Artifacts live in `results/coordination-stage97/`: `before/`, trial source snapshots,
`runtime-change.patch`, `source-hashes.json`, validation JSON, and production bundles
in `retained/` and `combined-retained/`. Existing measurement commands use the
pinned baseline checkout. `optimistic-expiry-bench.mjs` adds complete shared-action
cycles. All changes remain local; the baseline has no tracked modifications.
