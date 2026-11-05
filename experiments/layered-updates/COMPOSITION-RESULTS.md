# Suspended output composition

Current work: [scalar acceptance audit, stage 28](SCALAR-ACCEPTANCE.md). Store stage 27 is paused and shelved.

This stage continues the scalar experiment. It does not expand the supported
API set or make the scalar build a complete replacement for the public package.

## Failure and change

A callback pending query exposed a general coordination bug:

```ts
const status = createMemo(() => isPending(() => { x(); y(); }));
const label = createMemo(() => loadLabel(status()));
```

Start independent updates to x and y while the true label is suspended. When
that label resolves, the previous prototype could show the combined status as
true while x's own pending output remained false. Recomputing a held memo joined
the notifying update before the body could use the boundary's committed-input
read rule. This captured an optimistic output in the lower update.

Scoped recomputation now retains the child update until a proposal read actually
requires a merge. The common parking loop assigns queued proposals and children
before switching contexts; it is also the ordinary scheduler's parking loop.
The layer adapter recomputes readers in the lower context when that input is
ready. It examines the whole pure phase, including async work discovered after
the first child pass. Retiring an override explicitly rejoins its held output.

The first correction created an output update for every changed boundary
proposal. That fixed the settled-input case but added unnecessary transactions
to synchronous guesses. The refinement lets those guesses propagate normally;
when ordinary parking discovers their downstream suspension, the existing
ownership hook records their relative layer on that common update. Separating
an already-held input still creates an output update immediately. The adapter
also reuses its live candidate set instead of maintaining a redundant weak set.
No ordinary-node field, per-read version map or callback observation graph was
added.

## Observable browser example

The production Chromium fixture uses a guess of 1, a later y proposal of 10,
and async labels for `1:0` and `1:10`. The independent y calculation sits behind
eight memo levels. Controls are ordinary event handlers; there are no manual
flushes in the browser program.

| Event | Baseline view / y / label | Candidate view / y / label |
| --- | --- | --- |
| Both updates suspended | 0 / 0 / 0:0 | 0 / 0 / 0:0 |
| First label resolves | 1 / 0 / 1:0 | 1 / 0 / 1:0 |
| y's independent work resolves | **1 / 10 / 1:0** | **1 / 0 / 1:0** |
| Final label resolves | 1 / 10 / 1:10 | 1 / 10 / 1:10 |
| Guessing action ends | 0 / 10 / 0:10 | 0 / 10 / 0:10 |

The baseline lets y publish ahead of its ordinary label consequence. The
candidate holds them together. A late direct reader agrees with the published
view at every recorded step. Neither runtime reports a browser error.

## Validation

The new file has 29 composition cases: direct/callback pending, action/async
holds, either completion order, action-lifetime/explicit-clear guesses, shallow
and deep dependency paths, late readers, owned child replacement, obsolete
async answers and rejections, error recovery, and a ready synchronous lower
update, plus a new guess following a correction of an unrevealed guess. Controls verify that synchronous and asynchronous ordinary peer work
still merges beneath an already published override.

The full compatibility run passes 5,325 tests in 307 files, with the same 22
expected failures and two skips. The scalar run passes 137 applicable tests;
17 legacy comparison cases are excluded as before. Expanded seeded cases cover
18,000 timeline steps across branching, nested expiration, pending outputs and
supersession. The first expanded run exceeded the default five-second test
budget; the recorded rerun uses a 60-second per-test budget. No assertion was
weakened. All build tiers and pure-annotation checks pass. TypeScript reports
the same 26 pre-existing diagnostics.

A finite set of programs and seeded timelines does not prove every graph or
lifecycle. Stores, SSR, the complete observation API set and escaped readers
outliving their source owner remain outside this stage's acceptance claim.
The existing provisional pending-release timing and no-rebasing decisions are
unchanged.

## Measurements

Measurements and exact fixture snapshots are under
`results/composition-stage18/` (eager updates) and
`results/composition-stage19/` (parking-time ownership). The wholly synchronous
runner uses seven
alternating fresh-process pairs per workload. The optimistic and allocation
workers now also use `flush(update)` with a reused callback, so their tight
loops do not accumulate scheduler microtasks. Their absolute timings should
not be compared directly with earlier workers using `set(); flush()`.

The final stage also removes legacy lane-only transaction fields and scheduler
callbacks from the scalar build. The compatibility build retains them for the
existing public APIs and comparison tests. This extends the existing scalar
compile switch; it does not make deferred APIs supported. The recompute hook's
guard is ordered so ordinary-only bundles can erase the entire hook check.
The final source also makes the dependency-cache epoch optional while layer
coordination is inactive and removes a legacy pending-read branch that was a
no-op in the scalar build. Activation invalidates older cache entries. Final
validation and measurements are in `results/composition-stage24/`.

A new guess after a correction cannot reuse the old output update if that update
has merged into the input. The new tests caught this reuse error; staging now
requires that the reusable update remains independent of the input. These are
implementation bugs in the prototype, not semantic changes or loosened tests.

Application fixture sizes (baseline → final candidate, minified / Brotli):

| Fixture | Baseline bytes | Candidate bytes |
| --- | ---: | ---: |
| ordinary | 21,918 / 8,116 | 21,359 / 7,915 |
| optimistic | 27,250 / 9,864 | 26,815 / 9,859 |
| pending | 28,812 / 10,419 | 28,201 / 10,228 |

The ordinary fixture includes the action export. All three are smaller than
baseline in minified, gzip and Brotli measurements. The initial correction grew
the optimistic Brotli fixture by 48 bytes; the parking-time refinement grew it
by 70. Removing unused legacy scheduler machinery restored a reduction without
raising a threshold. The optimistic Brotli margin is now only five bytes.
These fixtures exercise the supported scalar subset; the comparison must be
repeated when public API integration is complete.

Final synchronous measurements, Node 24.19.0, seven alternating fresh-process
pairs per workload (five timed samples per process). Negative paired change
means faster for the candidate. These measure the matched scalar fixture,
not every engine or application.

| Workload | Baseline ns | Candidate ns | Paired change |
| --- | ---: | ---: | ---: |
| signal-read | 7.30 | 6.58 | -3.8% |
| memo-read | 9.77 | 9.68 | +1.1% |
| write-flush | 228.28 | 229.20 | +1.2% |
| equal-write | 8.26 | 8.78 | +12.1% |
| memo-write | 501.54 | 476.95 | -9.6% |
| batch-10-writes | 597.82 | 593.60 | -3.7% |
| chain | 2796.41 | 2556.25 | -4.3% |
| diamond | 733.74 | 772.53 | +5.3% |
| fanout-memos | 15847.07 | 15496.11 | -2.2% |
| fanout-effects | 11175.20 | 10558.40 | -2.8% |
| branch-switch | 579.16 | 548.53 | -6.5% |
| signal-create | 36.62 | 31.60 | -7.8% |
| memo-create-dispose | 115.43 | 122.62 | +2.8% |

The fixture excluding the action export is **21,188 / 7,825** baseline
versus **20,623 / 7,624** candidate (minified / Brotli bytes).

With one unused optimistic output mounted, the same worker gives:

| Inactive optimism workload | Baseline ns | Candidate ns | Paired change |
| --- | ---: | ---: | ---: |
| memo-read | 9.83 | 10.65 | +6.8% |
| chain | 2893.05 | 2831.66 | -4.3% |
| diamond | 850.31 | 830.21 | -3.4% |
| memo-create-dispose | 120.75 | 126.01 | +2.3% |

The inactive memo-read result remains an open performance concern: approximately
+6.8% paired in this batch. Earlier batches ranged from approximately level to
+6.9%; a three-runtime diagnostic before the final cold-bookkeeping refinement
put reads at +0.9% against upstream and +2.4% against the preceding prototype.
Ranges overlap, but that is not a reason to declare the regression absent.
Creation/disposal also varied: a 14-pair repeat before optional epoch tracking
showed +8.9%; the comparable run after it showed -0.9%, and the final batch above
shows +2.3%. Baseline timing variation is substantial too. The code now performs
less unnecessary work, but these measurements do not establish how much of each
timing change it caused. No performance threshold was raised.

Active guesses use five fresh processes per runtime. Parking-time ownership
removes the earlier 2–3× eager-update cost. Direct-input chains improve in this
batch; callback inputs retain the cost of the second full computation.

| Active guess workload | Baseline ns | Candidate ns |
| --- | ---: | ---: |
| active-depth-1-write-ns | 1686 | 1147 |
| active-depth-4-write-ns | 2938 | 2327 |
| active-depth-16-write-ns | 7544 | 7316 |
| active-direct-depth-1-write-ns | 1832 | 1367 |
| active-direct-depth-4-write-ns | 2871 | 2023 |
| active-direct-depth-16-write-ns | 7734 | 5404 |

Allocation sampling includes collected objects and is not an exact allocation
count. It gives:

| Workload | Baseline sampled bytes/write | Candidate sampled bytes/write |
| --- | ---: | ---: |
| ordinary | 635 | 650 |
| inactive | 640 | 641 |
| layer-1 | 1401 | 1512 |
| layer-4 | 1341 | 1455 |
| layer-16 | 1311 | 1060 |

The stage-18 eager approach allocated approximately 2,855–3,893 bytes per active
write in the same worker. Final boundary storage remains approximately
555 → 1,219 bytes for callback inputs and 568 → 872 for direct inputs, an expected
cost of splitting the primitive. These figures are recorded rather than treated
as acceptance blockers. The production GC test releases all 30 disposed-reader
payloads during the open action and after completion.

This is a stronger scalar prototype, not a merge-ready result. Correctness
coverage is finite, inactive synchronous timing still needs investigation, and
stores, SSR and the deferred APIs remain unintegrated. The size and active-update
results support continuing; they do not override the remaining constraints.

## Reproduce

From the repository root:

```sh
node experiments/layered-updates/build.mjs --all-tiers
node experiments/layered-updates/build.mjs --scalar
node experiments/layered-updates/measure.mjs /workspace/layered-baseline --scalar --bundle-only
node experiments/layered-updates/measure-sync.mjs /tmp/layered-sync
```

From `packages/signals`:

```sh
./node_modules/.bin/vitest run
SIGNALS_SCALAR_ONLY=1 PENDING_API=shared LAYER_SEEDS=100 BRANCH_SEEDS=100 PENDING_SEEDS=100 \
  ./node_modules/.bin/vitest run tests/layered-*.test.ts --testTimeout=60000 \
  --testNamePattern='^(?!.*(?:baseline|legacy)).*$'
```

For browser and active-boundary measurements, copy the six application `.mjs`
fixtures from `results/scalar/` into the chosen results directory, then run
`composition-browser.mjs`, `measure-optimistic.mjs` and
`measure-allocations.mjs` with that directory as their first argument. Archive
the worker scripts with the output. The fresh ordinary-read check in
`compare-sync.mjs` takes an output directory followed by baseline, previous and
candidate synchronous bundle paths. Run performance jobs without concurrent
builds or tests.



## Settled-read refinement and initial store inputs (stage 26)

This follow-up addresses the inactive synchronous memo-read concern above. It
changes the shared `read()` implementation, not layer semantics. The initial
`typeof node._fn === "function"` check now supplies one local boolean reused by
the signal fast path, tracked pull, error arm and dormancy tail. Node kind does
not change during preparation: external-source setup can replace the computation
function, but neither preparation nor disposal turns a computation into a signal.
There are no new node fields, allocations or layer lookups.

V8 profiling of the exact optimistic fixtures found both baseline and candidate
read functions too large to inline into the benchmark loop. Their optimized
read bodies were 1,320 and 1,288 bytes before this refinement. Reusing the kind
check reduces the candidate body to 1,164 bytes on Node 24.19.0. This is evidence
of less generated work, not a portable promise about every JavaScript engine.
The trace logs are in `results/read-profile-stage25/` and
`results/read-classification-stage26/read-code.log`.

Nine fresh-process samples per runtime, with rotating/reversed order, compared
upstream, the saved stage-24 prototype and this candidate with an optimistic
boundary mounted but inactive:

| Workload | Upstream median ns | Stage 24 median ns | Current median ns | Paired current / upstream | Paired current / stage 24 |
| --- | ---: | ---: | ---: | ---: | ---: |
| Memo read | 9.724 | 9.813 | 8.839 | 0.897 | 0.916 |
| Signal read | 6.557 | 6.867 | 6.557 | 0.999 | 0.963 |
| Memo creation/disposal | 116.366 | 113.356 | 110.963 | 1.007 | 0.979 |
| Chain | 2711.05 | 2581.52 | 2555.80 | 0.958 | 0.990 |

The median of paired ratios need not equal the ratio of the independent medians.
The ordinary-only run uses seven alternating fresh-process pairs per workload:

| Workload | Paired candidate / upstream |
| --- | ---: |
| Signal read | 1.012 |
| Memo read | 0.940 |
| Write and flush | 0.960 |
| Equal write | 1.010 |
| Memo write | 0.899 |
| Ten-write batch | 0.978 |
| Chain | 0.905 |
| Diamond | 0.934 |
| Memo fan-out | 0.931 |
| Effect fan-out | 0.994 |
| Branch switch | 0.982 |
| Signal creation | 0.871 |
| Memo creation/disposal | 0.985 |

All samples, ranges, fixture hashes and worker snapshots are archived under
`results/read-classification-stage26/`. Performance jobs ran without concurrent
builds or tests. These batches support the refinement and do not reproduce the
earlier inactive memo-read regression. They do not establish an engine-independent
speedup. No threshold was relaxed. This step changes no node representation;
the stage-24 allocation and retained-memory results remain the last measurements
of those properties, rather than newly measured claims.

Application fixture sizes after the refinement:

| Imports | Upstream minified / Brotli bytes | Candidate minified / Brotli bytes |
| --- | ---: | ---: |
| Ordinary with action | 21918 / 8116 | 21332 / 7920 |
| Optimistic | 27250 / 9864 | 26788 / 9864 |
| Pending | 28812 / 10419 | 28174 / 10227 |

The final compatibility run has 5,329 passes, 24 expected failures and two skips
in 308 files. The scalar run has 141 passes, two expected failures and 17 legacy
comparison skips in 12 files, including the expanded 18,000 seeded timeline steps.
The two new expected failures below are explicitly unresolved store integration
cases, not newly accepted behavior. All prior assertions remain intact.
Production Chromium F5b and suspended-composition checks pass, including late
readers and imperative reads. All build tiers and pure-annotation checks pass;
TypeScript has the same 26 normalized pre-existing diagnostics after correcting
two readonly annotations in the new tests.

### Store integration boundary: STORE-G1

`layered-store-input.test.ts` adds three passing integrations: the second held
guess with a store-property input at depths one and three, and a structural
store input whose scalar override publishes before its input. The structural
case checks direct values, optional-property presence, enumeration, async
correction and a late combined reader. An ordinary-signal independence control
also passes.

A fourth scenario exposes an existing store limitation:

```ts
const [state, setState] = createStore({ count: 0, other: 0 });
const status = createMemo(() => isPending(() => state.count));
const pair = createMemo(() => [status(), state.count, state.other]);

const changeCount = action(function* () {
  setState(draft => { draft.count = 1; });
  yield finishCount;
});
changeCount();
// After pending publishes: [true, 0, 0].

setState(draft => { draft.other = 9; });
// Desired next publication: [true, 0, 9].
// Actual: [true, 0, 0] until finishCount resolves.
```

Separate direct readers also remain at `[0, 0]`; this is excessive holding,
not disagreement between published readers. A reduction without `isPending`,
optimism or a shared memo fails in the unmodified baseline runtime too. The
upstream reduction and failure log are archived with these results.

The stack trace identifies `notifyWrites` repeating the earlier `count` slot
write: `t.wk` accumulates written keys until the backing commits. Repeating that
held write calls the ordinary write-before-equality joining rule and captures
`other`. A signal twin with separate direct readers publishes `[0, 9]`.

Both store variants are executable `it.fails` cases with the desired assertions
unchanged. Classification: **category 4, store write/publication integration still
outside the scalar prototype**, with an inherited implementation limitation
identified. This is not an intentional semantic change and does not require a
new ruling. Resetting `t.wk` alone would be unsafe: the same set also bounds
backing folds, and held backing versions and late node creation need coherent
publication. The store integration must separate a setter's actual notifications
from the pending backing's lifetime and validate both paths. Optimistic stores,
arrays/keyed arrangements and the full store acceptance matrix remain unfinished.

To reproduce the three-runtime inactive comparison from the repository root:

```sh
SYNC_INACTIVE=1 SYNC_CASES=memo-read,signal-read,memo-create-dispose,chain \
  node experiments/layered-updates/compare-sync.mjs /tmp/layered-inactive \
  experiments/layered-updates/results/composition-stage24/baseline-optimistic.mjs \
  experiments/layered-updates/results/composition-stage24/candidate-optimistic.mjs \
  experiments/layered-updates/results/read-classification-stage26/candidate-optimistic.mjs
```

The whole experiment remains a scalar prototype, not a merge-ready replacement.
The synchronous performance concern has better evidence now; store integration,
SSR and the deferred observation APIs still need implementation and acceptance.


## Store setter windows and a draft-read question (stage 27)

**Paused at the user’s request.** The stage-27 store changes and integration tests
are preserved in `results/store-input-stage27/shelved-store-integration.patch`
and removed from the active source/test tree. The draft-read question is not
blocking scalar work. Return to scalar acceptance before resuming this stage.

The STORE-G1 assertions now pass without modification. `pendingNotify` carries
the keys written by each open setter, while `t.wk` retains the backing fold's
accumulated keys. The first window shares that Set rather than allocating both.
No fields were added to store targets or ordinary nodes.

A late-reader test then found that an unobserved property still lacked an
independent publication home while the container was held. Writes crossing an
existing container hold now materialize that property's ordinary node before
mutating the backing. The node retains committed/proposed storage and uses the
ordinary scheduler. Unobserved nodes remain until the backing catches up, so
removing a reader cannot reveal an older backing value. Synchronous stores with
no hold retain their existing lazy-node path.

Eight scalar/store integration tests pass, including imperative reads before
and after flush and late readers with/without a previously materialized slot.
The existing store tests have 1,840 passes and one skip across 77 files. The
previous expected failure in `unchanged-presence-no-hold-3743.test.ts` now passes
and was promoted with its assertions unchanged. TypeScript still reports 26
pre-existing diagnostics. These are provisional write-path changes: the full
structural, retention, performance and size validation has not been completed
for stage 27. Stage 26's performance measurements do not measure this addition.

The changed notification scope exposes a semantic decision rather than a new
reason to repeat unrelated writes:

```ts
const [state, setState] = createStore({ count: 0, copied: 0 });
const save = action(async () => {
  setState(draft => { draft.count = 1; });
  await saveToServer();
});
// Render state.count and state.copied in separate bindings.
save();
// Later, while save is pending:
setState(draft => { draft.copied = draft.count; });
```

Both runtimes serve 1 to the draft read. Upstream displays `0 / 0` until the
action ends, then `1 / 1`; the prototype now displays `0 / 1`, then `1 / 1`.
The upstream join is the repeated-notification bug, not a dependency recorded
by the draft read. Executable source and both timelines are archived under
`results/store-input-stage27/draft-question*`; the diagnostic is intentionally
not installed as an acceptance test for either outcome.

**Category 3, awaiting a ruling:** should consuming a held proposal in a setter's
draft join that setter to the proposal's update, or is a draft an explicit
observation boundary that can publish its copied proposal independently?
Recommendation: join on the actual read, preserving `0 / 0` then `1 / 1`, while
an absolute `draft.copied = 9` remains independent. This preserves proposed-value
and read-your-writes draft semantics without relying on notification accidents.
There is no rebasing or persistent derivation implied: the setter body still
runs once. No behavior change for this question has been implemented yet.
