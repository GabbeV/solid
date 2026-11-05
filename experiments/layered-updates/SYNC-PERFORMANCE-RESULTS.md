# Synchronous-path performance

The later composition corrections and fresh measurements are recorded in
[COMPOSITION-RESULTS.md](COMPOSITION-RESULTS.md). This file preserves stage 17.

The user clarified that pending/optimistic storage is not a critical acceptance
measurement at this stage. Splitting optimism into two full nodes is expected
to increase its cost. Moving overhead from ordinary synchronous use into pending
or optimistic boundaries is desirable. The earlier characterization of roughly
doubled boundary memory as a blocker was incorrect. Correctness and bundle size
still matter; performance investigation should prioritize synchronous use with
no reactive async work or pending observations.

## Focused harness

`measure-sync.mjs` builds matching application fixtures exporting only signals,
memos, roots, render effects and flush. They import no action, pending or
optimistic API. Calculations return synchronous values with the normal public
options. It compares the unmodified baseline at
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c` with the experimental scalar build.

Each of 13 workloads runs in seven alternating baseline/candidate pairs, each
runtime/workload/sample in a fresh Node process. Four warmup/calibration runs
precede five timed runs. The report retains every timing, operation count,
bundle hash and worker source. Every update workload checks its observed output
outside the timed interval. Equal writes additionally check that the effect
never reran; direct fan-out checks all 100 effects.

The final harness uses `flush(update)` with one reused callback. The earlier
`set(); flush()` loop queued a microtask on every iteration and could not drain
them until the tight loop finished. That includes accumulated queue/GC costs
which obscure synchronous propagation. Stages 14–16 preserve those diagnostic
runs and their worker source; they are not the final synchronous-core assessment.
The ordinary creation workload is unchanged by this harness correction.

Signal creation uses bounded batches of 2,048 retained accessor pairs. Memo
creation/disposal creates and disposes roots containing up to 2,048 memos using
a shared calculation and dependency. The latter measures both creation and
cleanup, not creation alone. Natural garbage collection remains part of those
workloads; there is no forced GC inside a timed interval.

## Runtime refinement

The initial focused run showed a potential regression in synchronous memo
creation/disposal: the median paired candidate/baseline ratio was about 1.15.
The prototype's disposed-reader leak fix called `forgetReruns` for every disposed
computation, which walked even an empty set of holders. An initial empty-set
guard reduced the apparent difference in one batch but did not settle it.

The disposal callback is now installed only while there are held readers to
remove. Registering the first set of readers installs it; landing or disposal
clears it when the last set disappears. Ordinary synchronous disposal skips the
callback entirely. This adds no field or lookup table to ordinary nodes and
retains the eager cleanup of disposed readers during open actions.

The creation/disposal regression does not recur in the final batch. Host/JIT/GC
variation remains substantial, so this is evidence consistent with the change,
not proof that it explains every earlier timing difference.

## Final measurements

Node 24.19.0, seven paired fresh processes per workload, five timings within each
process, no concurrent tests/builds. Times below are medians in nanoseconds per
operation; a batched write operation contains ten writes and one flush. The last
column is the median of paired candidate/baseline ratios, not the ratio of the
two separately computed medians. Negative means faster for the candidate.

| Workload | Baseline ns | Candidate ns | Paired difference |
| -------- | ----------: | -----------: | ----------------: |
| signal-read | 6.81 | 6.78 | -1.8% |
| memo-read | 9.51 | 9.26 | -1.4% |
| write-flush | 223.53 | 224.13 | +0.3% |
| equal-write | 7.85 | 8.25 | +2.3% |
| memo-write | 491.97 | 468.90 | -4.1% |
| batch-10-writes | 553.77 | 534.52 | -8.9% |
| chain | 2765.88 | 2603.83 | -7.3% |
| diamond | 766.63 | 766.96 | -2.4% |
| fanout-memos | 16066.74 | 16359.99 | +1.8% |
| fanout-effects | 9233.87 | 9048.17 | -4.0% |
| branch-switch | 590.68 | 534.08 | -5.2% |
| signal-create | 31.53 | 29.22 | -7.2% |
| memo-create-dispose | 112.58 | 111.85 | -1.4% |

Read/write cases are close and their ranges overlap. Several computation and
creation cases improve in this batch; the small differences in equal writes and
memo fan-out do not establish a persistent regression or a guaranteed speedup.
These measurements support continuing the shared-core experiment. They do not
establish performance for every synchronous application or engine.

The matching synchronous fixture is **21,188 versus 20,862 minified bytes**, and
**7,825 versus 7,752 Brotli bytes**. This fixture omits the action export present
in the earlier ordinary bundle: compare baseline and candidate within this
fixture, not its absolute size with the older export set.

## Validation and scope

The scalar tests exercise the new callback lifecycle, including repeated
mount/dispose/revive cycles and transaction coordination: 108 applicable tests
pass; 17 legacy comparison cases are excluded as before. The production GC
reachability check collects all 30 disposed payloads during an open action and
after completion. Its per-boundary byte estimates are not used as acceptance
criteria. All build tiers and the scalar build complete. The full compatibility suite
passes 5,296 tests across 306 files, with the unchanged 22 expected failures and
two skips. TypeScript still reports the same 26 pre-existing diagnostics.

The change preserves the chosen early pending-release behavior and introduces
no semantic decision. Broader API integration and the previously documented
correctness gaps still need work. Expected boundary storage is not a reason to
postpone that work. No thresholds were raised, and no consistency assertions were
weakened. All work remains local.

## Reproduce

From the repository root, after building and with no concurrent tests/builds:

```
node experiments/layered-updates/build.mjs --scalar
node experiments/layered-updates/measure-sync.mjs
```

The default output is `results/sync-scope-stage17/`. Pass another directory as
the first argument to preserve a new campaign. `SYNC_SAMPLES` overrides the seven
process pairs, and `SYNC_CASES` selects a comma-separated workload list. Do not
select only favorable cases when assessing the whole synchronous path.

The directory stores the exact worker used, both application bundles and their
metadata, all samples and the summary. Earlier attempts remain in
`sync-stage14/`, `sync-guard-stage15/` and `sync-cold-cleanup-stage16/`.
