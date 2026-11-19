# Stage 79: correction holds instead of general input-demand forwarding

The user authorized retaining next's hold behavior to limit the experiment's
scope. This explicitly revises stage 49's choice of `0 / 3` in the nested
example, and removes stage 76's pending-demand extension. It does not relax
consistency between ordinary consumers of an optimistic or observation output.

## Model and implementation

An active override cuts value demand for its input. Its subscription still keeps
that input current, but displaying the override does not itself block a different
update producing the input. When the override retires, the replacement and its
ordinary consequences derive and publish through the existing shared machinery.

The guessing action itself still waits for its observed optimistic inputs that
are pending. A narrow action-readiness hook checks the existing scoped boundary
set. This preserves next's own-input-flight hold without forwarding demand into
arbitrary lower updates. Removing the last observer can release that hold;
disposal schedules its readiness check. No fields were added to ordinary nodes.

Removed the input-to-observers Map/Set registry, registration/unregistration,
forwarding traversal, pending-kind demand flag, per-pending-node scheduler
forwarding query, and forwarding-triggered transaction adoption. The ordinary
observation walk remains for action lifetime and selector visibility. This is
not the deletion of all observedness or optimistic lifetime bookkeeping.

Two implementation regressions were found and fixed, rather than accepted:

- `isPending(() => input())` used an ordinary read for callback control flow,
  accidentally retaining an initialized input flight's hold. It now takes that
  flight's committed value; the shared pending output supplies the subscription.
  Uninitialized reads still suspend, nested computations retain their ordinary
  reads, and settled control-flow reads still track normally.
- Without the extra lower hold, a reader of both source and status could publish
  an intermediate `1:false` before `1:true`. Pending-input observation proposals
  are now prepared before commits, through the existing common stageLayer path.
  Direct and wrapped production audits both publish `0:false -> 1:true -> 1:false`,
  matching pinned next. The assertions on complete per-binding sequences remain.

## Observable comparisons

```js
const [first, guessFirst] = createOptimistic(() => 0);
const middle = createMemo(() => first() === 0 ? 0 : answer.promise);
const [second, guessSecond] = createOptimistic(middle);
// Separate scheduled/observable bindings for first and second.
```

| Phase | Pinned next | Candidate |
| --- | --- | --- |
| Guess first=1; middle pending | 0 / 0 | 0 / 0 |
| Guess second=3; both actions open | 1 / 3 | 1 / 3 |
| Middle answers 2; both actions open | 1 / 2 | 1 / 3 |
| Child action ends | 1 / 2 | 1 / 2 |
| Both actions end | 0 / 0 | 0 / 0 |

The third-row difference is the previously accepted override-lifetime rule:
incoming answers join the guessing actions and remain masked until their shared
lifetime ends. This stage does not silently restore next's earlier correction
start or expose hidden input answers through latest.

A disabled guard observing only `isPending(data)` no longer holds its source
update, with either a direct accessor or callback. An explicit optimistic boolean
whose *input reads data* still has an action waiting for that input. Their output
publications share the machinery, but their input/lifetime requirements differ.
The stage-77 equivalence test now asserts that deliberate difference as well as
both complete traces, final state, unrelated reruns, and late readers.

For product A -> B with product information blocking and reviews inside Loading:
`on={isPending(reviews)}` shows A/loading, then B/loading when product B is ready,
then B/reviews B. The candidate now matches next. Ordinary on=id/data still shows
fallback only with the coordinated product-page commit. No Loading-specific
exception was added.

## Validation and classification

- All 427 tests in the unified-update test files pass with both implementations available.
- With legacy lanes compiled out, 393 candidate tests pass in 39 files; the 34
  explicitly named baseline/legacy comparison cases are excluded by the filter.
- Full normal suite: 335 files, 5,620 reported passes (including 22 expected
  failures), 2 skips, zero failures. Much of this suite uses the legacy entry.
- Unchanged upstream migration corpus: 654 tests; 572 ordinary passes, 2 expected
  failures, and the same 80 failures as stage 76. No failed test was added or
  removed. Two ordering-only failures have changed messages, now releasing count
  with fallback rather than waiting for content. Existing failure categories
  and deferred APIs remain as recorded in COMPAT-75.md; this is not full migration.
- Production audit: 21 scenarios per runtime (42 executions), including nested
  overrides, direct/callback pending guards, both completion orders for four
  Loading triggers, and feedback/lifetime variants.
- Production retention: zero retained payloads after each of five batches of
  200 disposed pending-only observers in both runtimes. Zero retained disposed
  readers in the separate live-boundary scenario (30 readers per runtime).
- Source type check and scalar production build pass. Rollup reports pre-existing
  test-file type warnings; the source-only type check reports none.

Changed old assertions are intentional semantic changes: lower values can
publish through selected overrides, pending-only guards do not retain input
holds, and pending-based Loading releases content demand. Ordinary publication,
late-reader agreement, cancellation, correction, error, ownership, and cleanup
assertions remain. Tests exercising F5b and correction waterfalls still pass;
upstream's F5b expected-failure marker remains an unexpected success in the
unchanged migration corpus.

Existing unresolved cases are not reclassified as intentional:

1. Feedback from `isPending(id)` into a memo depending on id can cancel the
   lower request, retire the true proposal before publication, and restart the
   request under correction. The candidate stays `0 / false / 0` while held.
   Next shows true in one read order and tears in the reversed read order. This
   stage neither resolves that lifetime issue nor restores next's read posture.
2. `Loading on={latest(id)}` still withholds the early fallback in the production
   navigation audit, unlike next. It remains an implementation discrepancy.
3. Stores, broader APIs, renderer integration, and whole-API migration remain
   outside this scalar checkpoint.

These finite runs are evidence, not a proof for all dynamic dependency graphs.

## Measurements against pinned next only

Baseline: `a24e911ba5e571e7adb1c9b5e5151261f9cf101c` in
`/workspace/layered-baseline`; candidate uses the real modified scalar core.
Node v24.19.0. Production bundles, original workload scripts, fresh processes,
alternating baseline/candidate order. Sync: 7 paired samples per case, with
optimism imported but inactive. Ratios below are candidate time / next time.

| Synchronous workload | Ratio |
| --- | ---: |
| signal-read | 0.961 |
| memo-read | 0.918 |
| write-flush | 1.013 |
| equal-write | 0.953 |
| memo-write | 0.973 |
| batch-10-writes | 0.984 |
| chain | 0.982 |
| diamond | 0.961 |
| fanout-memos | 0.893 |
| fanout-effects | 1.048 |
| branch-switch | 0.982 |
| signal-create | 0.835 |
| memo-create-dispose | 1.016 |

The active-context workload rewrites the top override while all nested actions
remain open, with synchronous ordinary derivations and no async memo. Three
paired samples: depth 1 = 2.202x next, depth 4 = 1.970x, depth 16 = 1.681x.
It verifies visible results, but is not a measure of arbitrary lower-layer
rewrites or suspended nested updates. These costs remain a performance concern.

| Import scenario | Next minified / Brotli | Candidate minified / Brotli |
| --- | ---: | ---: |
| Ordinary | 21,918 / 8,116 | 21,726 / 8,059 |
| Optimistic | 27,250 / 9,864 | 30,422 / 11,046 |
| Pending | 28,812 / 10,419 | 32,360 / 11,607 |
| Latest | 28,715 / 10,368 | 31,889 / 11,476 |

A single retained-heap diagnostic over 20,000 inactive boundaries estimates
callback-input boundaries at 556 bytes next / 1,155 candidate and direct-input
boundaries at 568 / 1,113. Approximately doubling is consistent with the explicit
two-node prototype. These are approximate retained sizes, not allocation-rate
measurements. No ordinary node storage was changed in this stage.

The ordinary bundle is slightly smaller than next; optimism and pending remain
about 12% larger compressed. Effect fan-out is about 5% slower in this sync run.
Neither performance nor code size acceptance is declared, and no limits changed.

## Reproduction and saved state

All raw results are under `results/correction-holds-stage79/`. `before/` preserves
the prior source and unified-update tests. `final/` records changed sources, scripts,
hashes, and failure-set comparison. Runtime changes remain local.

```sh
node experiments/unified-updates/build.mjs --scalar
# From packages/signals:
node node_modules/vitest/vitest.mjs run
SIGNALS_SCALAR_ONLY=1 node node_modules/vitest/vitest.mjs run unified- \
  -t '^(?!.*(?:baseline|legacy)).*'
# From repository root:
SYNC_KEEP_OPTIMISM=1 node experiments/unified-updates/measure-sync.mjs <output>
MEASURE_OUT=<output> node experiments/unified-updates/measure.mjs \
  /workspace/layered-baseline --scalar --bundle-only
node experiments/unified-updates/measure-active-contexts.mjs <bundle-output>
node experiments/unified-updates/pending-release-audit.mjs \
  packages/signals/dist/scalar/index.js --wrapped
```
