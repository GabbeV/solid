# Observation context discovery experiment

Historical stage-four results. See [STRUCTURAL-RESULTS.md](STRUCTURAL-RESULTS.md)
for the subsequent structural cache and boundary-construction refinement.

The preferred branch-switch behavior and order-independent late mount now
pass. This iteration still fails performance acceptance and is not a mergeable
common foundation. The existing public optimistic and observation APIs have
not been replaced. The scalar/private observation entries exercise the proposed
machinery without claiming compatibility with all legacy features.

## Decisions and implementation

The user prefers retaining `"true:0"` when an ordinary branch switch stops
reading the pending indicator while input 1 remains held. Immediate `"plain:0"`
is permitted for exploration if a simpler consistent rule supports it. This
does not authorize an exemption that accidentally survives through old links.

The accepted late-mount rule is implemented for the tested scalar case: reading
the published pending indicator and held input in either order yields `[true, 0]`.

The experimental held-read path can provisionally read committed input while
discovering whether the current computation reads a boundary over that parent.
If its final dependencies do not justify the read, it joins the ordinary parent
update and recalculates. The wrapper is active only while candidate parents are
live. Settled signal reads and ordinary signal/memo node shapes are unchanged.

Provisional calculations use ordinary update holds for owned children. A child
whose context depends on its still-running owner defers that decision to the
owner. Discarded child frames are disposed; discarded returned Promise rejections
are handled. Async functions may nevertheless have started work that cannot be
physically cancelled. This is a cost and semantic consideration, not free replay.

The initial version passed value tests but let an owned child publish a discarded
value. The owned-frame hold fixes that reduction. Tests also cover synchronous
errors and rejected async results from discarded bodies, plus retention of the
previously published child until the replacement is ready.

A generated branch-switch case exposed another tear: after a branch published
`plain:0`, the input published 3 before the branch's new async result. The memo
was being rerun after the parent's commit. Such derivations now rederive before
the parent publishes, allowing newly discovered async to hold the input. A
deterministic regression retains the consistency assertion while allowing either
of the two experimentally permitted initial branch timings. The original
preferred-`true:0` assertion remains unchanged.

## Shared scheduler changes

The common rerun array grew once per evaluation throughout an open action.
It is now a lazily allocated Set per update. A reader registers with each held
input it reads; disposal removes registrations without waiting for action end.
Merging updates unions the sets and releases the old registration container.
The same mechanism serves ordinary readers, legacy lanes and the experiment.

This also fixes an independently reproduced baseline bug: a direct reader of
two held inputs misses the second input's completion when that update finishes
first. The unmodified baseline fails that timeline; the candidate passes both
completion orders. This is a correctness fix, not an intentional semantic change.

## Validation

- Latest full signals suite: 301 files, 5,235 passed, 22 existing expected
  failures, two skipped. The legacy F5b expected failure remains in the old API;
  the experimental scalar reproduction passes.
- Expanded targeted campaign: 300 layer seeds, 200 pending-observation seeds,
  100 branch-switch seeds: 30,000 operation checkpoints. It compares separate
  rendered bindings with their derived outputs and requires final settlement.
  The subsequent small deterministic regression also passes in the full suite.
- Production Chromium scalar and pending-observation replays pass, including
  event-handler reads matching the DOM, async holding and supersession.
- All five production memory samples collect all 30 disposed reader payloads
  while their input action is still open. The baseline retains all 30 until
  completion. Both collect all payloads after completion.
- A 1,000-rerun test keeps one registration for a live reader and removes it
  on disposal while its action stays open.
- TypeScript: the same 26 existing diagnostics as baseline; no new diagnostics.
- `git diff --check` passes. No consistency assertions were weakened.

These are finite tests, not a proof. Dynamic control flow depending on values
used during discovery, general ownership transfer, multiple-parent readiness,
overlapping answer provenance and broader observation scope need further work.
Public `isPending` window integration, latest/until/refresh, stores and SSR are
still deferred. The observation helper's different spelling is scaffolding,
not an established requirement for a new public API.

## Measurements

Baseline: `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`. Node 24.19.0. Production
Rollup build plus the repository's shared property mangling, then identical
application bundling. Timings below use five alternating fresh-process samples
without concurrent build/test work. Raw data is in `results/`; earlier stages
are archived in its named subdirectories.

| Ordinary workload | Baseline median ns | Candidate median ns |
| --- | ---: | ---: |
| Settled signal read | 6.70 | 6.42 |
| Write and flush | 221.7 | 225.8 |
| Signal creation | 87.2 | 130.8 |
| Memo chain write | 2623.0 | 2641.6 |
| Diamond write | 962.7 | 946.2 |
| Fan-out write | 15274.7 | 15013.5 |
| Memo creation | 630.0 | 712.3 |

Creation remains a regression/noise concern: signal samples span 55.1–151.1 ns
baseline and 85.4–178.3 ns candidate. This does not establish acceptance, even
though node representation is unchanged. Read medians also vary between runs;
the small differences are not reliable speedup claims.

| Pending workload | Baseline median ns | Candidate median ns |
| --- | ---: | ---: |
| Inactive observation, ordinary read | 6.57 | 6.55 |
| Inactive observation, ordinary write | 222.0 | 224.4 |
| Held input, depth 1 | 1614.1 | 1436.2 |
| Held input, depth 4 | 2200.8 | 2466.7 |
| Held input, depth 16 | 5154.2 | 6883.7 |

The depth-16 regression is approximately 34%, with separated sample ranges.
Earlier versions were approximately 2.8 times baseline without caching and
1.6 times with discovery before allocation refinement. Profiling identified
repeated searches and allocation/GC costs. Removing per-read search Sets and
closures and per-computation wrapper objects improved the result but did not
meet the constraint. No threshold was raised.

Pending boundary retained memory is approximately 516 versus 1,299 bytes.
Two full nodes remain expensive. The open-action collection improvement does
not excuse this per-boundary cost.

| Application | Baseline minified / Brotli bytes | Candidate minified / Brotli bytes |
| --- | ---: | ---: |
| Ordinary imports | 21918 / 8116 | 22323 / 8250 |
| Optimistic imports | 27250 / 9864 | 25909 / 9586 |
| Pending imports | 28812 / 10419 | 26863 / 9874 |

Ordinary imports grow by 405 minified / 134 Brotli bytes. The other comparisons
have incomplete feature parity, so their smaller bundles are not acceptance
evidence. `allocations.mjs` records sampled allocated bytes, separately from
retained heap; those samples are estimates rather than exact allocation counts.
The latest single sampled run reports ordinary writes at 737 versus 1,030 bytes,
inactive optimism at 669 versus 665, and active depth 1/4/16 at approximately
1425/1373/1360 versus 1460/1243/1460. The ordinary-scenario increase remains an
unresolved allocation concern; the scenario variation and sampling do not
establish allocation acceptance.

## Reproduce

From packages/signals:

```
LAYER_SEEDS=300 PENDING_SEEDS=200 BRANCH_SEEDS=100 ./node_modules/.bin/vitest run tests/unified-experiment.test.ts tests/unified-action.test.ts tests/unified-pending.test.ts tests/unified-outside-reads.test.ts tests/unified-coordination.test.ts --testTimeout=60000
```

`BRANCH_REPLAY='0:3 1:2 3:3 2:1'` exercises the reduced branch timeline.
The unmodified baseline's missed-rerun reduction is in the separately added
`unified-coordination-regression.test.ts` in the baseline worktree; it does
not modify baseline runtime code or its measured bundles.

From the repository root, sequentially:

```
node experiments/unified-updates/build.mjs
node experiments/unified-updates/measure.mjs /workspace/layered-baseline
node experiments/unified-updates/measure-pending.mjs
node experiments/unified-updates/browser.mjs
node experiments/unified-updates/pending-browser.mjs
```
