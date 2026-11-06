# Scalar core without legacy lane branches

The scalar prototype now runs without the old lane-specific read, recompute,
value-selection and publication routing in `core.ts`. Its application bundles
are smaller than the unmodified baseline in all three measured scenarios.
This is evidence that consistent layering need not increase bundle size; it is
**not mergeable acceptance**: timing ranges overlap, and the scalar build does
not support the whole API. The user clarified after this measurement that extra
pending/optimistic memory, including two full optimistic nodes, is expected at
this stage. It is not an acceptance blocker by itself. The performance priority
is wholly synchronous use with no async work or pending observations.

The user's provisional upstream pending timing remains intact. For input 0,
published guess 1 and a pending input request, an answer of 0 can clear pending
while the guessing action is open. If an ordinary consequence of pending-false
suspends, that output and its readers wait together. No special early-release
bookkeeping was added. Equal, matching and differing answers and late readers
are exercised in the browser against the scalar build.

## What changed

Plain signals and store slots no longer carry a creation-time `_time` field
that their writes never advanced. Computations retain that clock for retries
and async-answer provenance. Signals use their existing notification epoch.
The measured public signal fixture saves approximately eight retained bytes.

Memos and effects no longer carry a separate `_loading` boolean. Their existing
configuration word records whether they are still serving `loadingValue` before
the first real answer. The commit already updates that word, so closing the
window does not need another field store there. The measured memo fixture saves
approximately eight retained bytes. Store projections read the same flag; this
is a representation change, not a change in their publication policy.

The boundary selector binds a shared function rather than retaining a closure
with its constructor environment. It saves about 64 retained bytes per boundary.
This is additional to the earlier direct-accessor input reuse and source-owned
pending record compaction.

The optional layer hooks are now module bindings with three installation
functions rather than static properties on `GlobalQueue`. This gives bundlers
visibility into who can assign them. Rollup can remove the unused hooks from an
ordinary-only application; the measured esbuild bundles retain unassigned local
bindings, but no class-property lookups for these seams. No ordinary node gets a
layer record, version map or layer-traversal read.

A local build flag keeps the old implementation available for comparisons:

- Normal dev/observe/production builds retain legacy APIs and branches.
- `build.mjs --scalar` writes a separate `dist/scalar` tree with those core
  lane branches omitted. Measured scalar fixtures import ordinary primitives
  and the new optimistic/pending adapters only.
- `SIGNALS_SCALAR_ONLY=1` exercises the same branch removal in source tests.

This flag is experimental scaffolding, not a proposed public configuration.
`dist/scalar/index.js` is not a supported replacement package entry: it still
exports legacy APIs whose contracts are not implemented in this mode. In
particular, legacy optimism/verdict windows, `latest`, `until`, refresh/affects,
general Loading composition, optimistic stores and SSR do not gain support by
being present in that file. The compatibility build remains available to test
those existing implementations. The scalar build also retains some unused
legacy scheduler/async seams and extension fields; this is not a complete source
deletion of the old engine.

## Validation

- The build without core legacy lane branches passes **108 applicable prototype
  tests** in ten files, including 38,000 generated operation checkpoints.
  Seventeen legacy comparison cases are explicitly excluded from this run;
  no assertion is weakened and they still run in the compatibility suite.
- The normal compatibility suite passes **5,296 tests** across 306 files,
  with the same 22 expected failures and two skips as stage 10.
- Production, observe, dev and scalar builds complete; annotation checks pass.
  TypeScript reports the same 26 pre-existing diagnostics, none in the prototype.
- Chromium replays pass against the scalar bundles: F5b, shared pending,
  foreign held input, ordinary owned-child publication, and optimistic-input
  pending with answers 0, 1 and 2. These are local reductions; the original
  hosted F5b page remains unavailable.
- All disposed payloads in the memory fixtures are collected after completion.
  The candidate pending fixture also releases them while the action is open.

This adds evidence for the same mechanism handling ordinary and optimistic
values, async holding, errors and owned publication. It is not a universal
proof. Source-owner death with escaped readers, broader callback queries,
overlapping-answer provenance and full API integration remain incomplete.

## Measurements

Baseline runtime: `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`.
Node 24.19.0; repository builds and property mangling; identical application
bundler and exported fixture operations. Five alternating fresh processes per
timing/memory campaign, with no concurrent tests or builds. Allocation sampling
uses three alternating processes and includes collected objects.

The ordinary fixture exports the same operations on both sides. Optimistic and
pending fixtures implement the tested scalar subset, not full legacy feature
parity. The prototype optimistic adapter still returns its private clear helper.
All min/max samples are retained. Changing signs across earlier batches should
not be hidden by the latest favorable medians.

| Application minified / Brotli bytes | Baseline | Scalar candidate |
| ---------------------------------- | -------: | ---------------: |
| Ordinary | 21918 / 8116 | 21540 / 8017 |
| Optimistic | 27250 / 9864 | 26352 / 9759 |
| Pending | 28812 / 10419 | 27736 / 10095 |

The compatibility build, which retains old branches, is still larger:
ordinary 22357 / 8264, optimistic 27185 / 10009, pending 28564 / 10373 and
Loading 26660 / 9774. Baseline Loading is 26140 / 9584. No threshold was raised.
Removing legacy specialization is material to the size result.

| Ordinary median time, ns | Baseline | Scalar candidate |
| ----------------------- | -------: | ---------------: |
| Settled read | 7.31 | 6.54 |
| Write and flush | 221.89 | 221.12 |
| Signal creation | 57.17 | 50.88 |
| Memo creation | 744.97 | 574.30 |
| Chain update | 3051.76 | 2662.39 |
| Diamond update | 952.32 | 928.93 |
| Fan-out update | 15798.58 | 14643.94 |

| Optimistic median time, ns | Baseline | Scalar candidate |
| ------------------------- | -------: | ---------------: |
| Function input, depth 1 | 1590.85 | 1235.21 |
| Function input, depth 4 | 3130.16 | 2408.35 |
| Function input, depth 16 | 7547.65 | 7355.35 |
| Direct input, depth 1 | 1718.87 | 1284.28 |
| Direct input, depth 4 | 2748.20 | 2130.93 |
| Direct input, depth 16 | 6933.73 | 4973.57 |

Pending remains mixed: observed synchronous writes are 417.57 versus 408.49 ns,
but held depth 1 is 1462.61 versus 1574.23 ns, depth 4 is 2312.50 versus 2335.65 ns,
and depth 16 is 5524.17 versus 5741.99 ns. Ranges overlap. Inactive reads are
6.46 versus 6.59 ns and inactive writes are 219.52 versus 219.31 ns.

| Retained bytes per fixture | Baseline | Scalar candidate |
| -------------------------- | -------: | ---------------: |
| Public signal | 352 | 344 |
| Memo with shared calculation and dependency | 432 | 424 |
| Optimistic function input | 556 | 1218 |
| Optimistic common accessor | 568 | 872 |
| Distinct signal plus pending observer | 737 | 1437 |
| Many pending observers sharing one source | 529 | 521 |

Direct-input optimism is substantially cheaper than function-input optimism,
but both still cost more memory than baseline. Pending's per-source cost remains
close to twice baseline. The full-node selector and input producer are possible later optimization
targets, not prerequisites for this scalar experiment. The current measurements
demonstrate a smaller scalar core with plausible timing, not satisfaction of
every acceptance bound. Further performance investigation should concentrate on
ordinary synchronous reads, writes, derivations, creation and notification.

Sampled allocated bytes per write remain mixed (medians; estimates include
collected objects rather than exact allocation counts):

| Workload | Baseline | Scalar candidate |
| -------- | -------: | ---------------: |
| Ordinary | 729 | 735 |
| Optimism imported but inactive | 670 | 673 |
| Direct layer, depth 1 | 1416 | 1519 |
| Direct layer, depth 4 | 1367 | 1488 |
| Direct layer, depth 16 | 1347 | 1091 |

The depth-1 and depth-4 allocation increases describe active optimism, where
extra overhead is acceptable for this stage. Pending observation allocation is
not separately profiled by this workload. Neither is a reason to postpone
validating and improving wholly synchronous use.

## Artifacts and reproduction

`results/hook-bindings-stage13/` contains the final scalar samples, bundle
metadata, application bundles and browser timelines. Prior stages are preserved:
`signal-storage-stage10/`, `selector-storage-stage10/`,
`loading-storage-stage11/` and `legacy-carve-stage12/`. Root `results/` contains
the current compatibility bundles; do not mistake those for the scalar build.

From the repository root, build before running measurements, then run the
measurement commands serially:

```
node experiments/unified-updates/build.mjs --all-tiers
node experiments/unified-updates/build.mjs --scalar
node experiments/unified-updates/measure.mjs /workspace/layered-baseline --scalar
node experiments/unified-updates/measure-optimistic.mjs experiments/unified-updates/results/scalar
node experiments/unified-updates/measure-pending.mjs experiments/unified-updates/results/scalar
node experiments/unified-updates/measure-allocations.mjs experiments/unified-updates/results/scalar
node experiments/unified-updates/browser.mjs --scalar
node experiments/unified-updates/pending-browser.mjs --scalar
node experiments/unified-updates/foreign-input-browser.mjs --scalar
node experiments/unified-updates/owned-proposal-browser.mjs --scalar
node experiments/unified-updates/optimistic-pending-question.mjs --scalar
node experiments/unified-updates/optimistic-pending-browser.mjs --scalar
```

From `packages/signals`:

```
PENDING_API=shared ./node_modules/.bin/vitest run
SIGNALS_SCALAR_ONLY=1 PENDING_API=shared LAYER_SEEDS=300 PENDING_SEEDS=200 BRANCH_SEEDS=100 ./node_modules/.bin/vitest run tests/unified-*.test.ts --testNamePattern='^(?!.*(?:baseline|legacy)).*$' --testTimeout=60000
```

All work remains local. No commits, pushes or external messages were made.


The subsequent synchronous-only investigation and callback cleanup refinement
are documented in [SYNC-PERFORMANCE-RESULTS.md](SYNC-PERFORMANCE-RESULTS.md).


The next scalar iteration fixes suspended output composition, late-discovered
lower async holds and guesses following corrections. It also moves settled
boundary ownership to ordinary parking and removes legacy transaction fields
and scheduler seams from the scalar build. See
[COMPOSITION-RESULTS.md](COMPOSITION-RESULTS.md) for current validation,
measurements and remaining scope.
