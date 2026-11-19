# Pending observations through the common boundary

Historical stage-three report. The discovery experiment now addresses the two
reductions below; see [DISCOVERY-RESULTS.md](DISCOVERY-RESULTS.md). Stage-three
measurements are archived in `results/pending-cached-stage3/`.

The agreed rule is implemented in the private `createPending(input)` accessor:
its true proposal reads the input update's committed value without joining it.
The pending output, its ordinary derivations, async work and render callbacks
use the same publication machinery as the scalar optimistic experiment.

For input 0 and an action holding input 1, separate bindings and a combined
memo show input 0, pending true, pair `[true, 0]`. Downstream async can hold
that pending output. When the action completes, false rejoins the input update;
async consequences of the final value hold both before they publish.

This is **not an acceptable replacement yet**. The public dynamic `isPending`
API is unchanged; the prototype uses an explicit accessor boundary. Stores,
SSR, latest/until/refresh, overlapping-answer provenance and other features
remain outside the validated implementation. See MODEL.md for the decisions.

## Validation and counterexamples

- Cached implementation: 50 targeted tests passed, including 300 layer seeds
  with 18,000 operation checkpoints and 200 observation seeds with 8,000.
  The observation campaign starts with an actual true publication, compares
  separate and combined rendered values, and requires eventual settlement to
  the last written inputs. These counts are finite coverage, not a proof.
- Production Chromium exercises pending-true async holding, input completion,
  false-proposal async holding and superseded async answers. An event-handler
  inspection compares imperative reads with actual DOM values. Both normal
  completion and supersession pass. This browser run used the uncached build;
  cache validation so far is the source test campaign and full suite.
- Five production memory samples collect all 30 disposed-reader payloads
  after completion while keeping the observation boundary alive. This does
  not establish bounded bookkeeping during an indefinitely open action.
- TypeScript: the same 26 existing diagnostics as baseline, no new diagnostics.
- Final full suite after adding the reductions below: 299 files pass, one
  fails; 5,222 tests pass, two fail, 22 existing expected failures, two skipped.
  Neither new assertion was weakened or converted to an expected failure.

The two failures are in `unified-pending.test.ts`. Following the user's latest
answer, the first is an implementation bug and the second remains a semantic
question:

1. After pending true has published with input 0, mount a new memo reading
   both. Reading pending first publishes `[true, 0]`; reading input first
   leaves the memo's first result held. The user accepted the assertion requiring
   `[true, 0]` in either read order. The existing eager join happens before
   the second read has revealed the boundary dependency.
2. Change a memo from `observe() ? pending() + ':' + x() : 'plain:' + x()`
   to its ordinary branch while x remains held. The previous dependency
   permits `plain:0` to publish. The recommended assertion retains `true:0`
   until input completion, then publishes `plain:1`. The scope of this rule
   is unresolved, rather than an established consistency assertion silently
   changed to match implementation. Retaining the old branch and publishing
   a new branch against committed input can both satisfy consistency. The
   earlier recommendation to retain it is being reconsidered; it must not
   be justified solely by the old implementation's eager joining rule.

These are limitations of discovering context from existing dependency links,
not evidence against the accepted pending-true update rule. Restricting the
walk to already-read current dependencies would lose read-order independence;
using old dependencies can grant an exemption that this pass no longer has.
The current core merges updates while reading, before final dependencies are
known. Any revision must account for owned children and async work as well as
values; speculative re-execution is not automatically harmless.

## Measurement

Five alternating fresh-process samples, Node 24.19.0, no concurrent test or
build work. `results/pending-uncached/` preserves the first measurement.
Current `results/pending-performance.json` records the cached implementation.
No size caps or performance expectations were relaxed.

| Workload | Baseline median ns | Cached candidate median ns |
| --- | ---: | ---: |
| Inactive pending, ordinary read | 6.69 | 7.18 |
| Inactive pending, ordinary write/flush | 232.3 | 241.3 |
| Held input, dependency depth 1 | 1484.7 | 1863.3 |
| Held input, dependency depth 4 | 2260.6 | 3164.2 |
| Held input, dependency depth 16 | 5478.8 | 8199.6 |

The uncached depth-16 candidate was 13,896.8 ns against 4,883.9 ns baseline,
approximately 2.8 times slower. Caching removes much of the repeated traversal
but leaves approximately 1.5 times the baseline cost. This approach fails
performance acceptance. Optimizing the cache alone cannot resolve the two
dependency-discovery cases above.

Retained memory per pending boundary is approximately 516 versus 1,299 bytes.
Two full nodes were allowed for the experiment, but this 2.5-fold increase is
an unresolved cost. The inherited transaction rerun array can also append the
same reader across many passes of one open update; the completed-update weak
reference check does not test or excuse that growth.

| Application import | Baseline minified / Brotli bytes | Candidate minified / Brotli bytes |
| --- | ---: | ---: |
| Ordinary primitives | 21918 / 8116 | 22062 / 8170 |
| Optimistic primitives | 27250 / 9864 | 24704 / 9160 |
| Pending observation | 28812 / 10419 | 25660 / 9448 |

The ordinary import comparison is feature-equivalent. The other two are
mechanism feasibility measurements with incomplete feature parity, so their
smaller bundles are not acceptance evidence. Earlier ordinary performance and
allocation measurements are retained in the stage reports; they do not
establish performance for the latest pending implementation.

## Reproduce

From packages/signals:

```
LAYER_SEEDS=300 PENDING_SEEDS=200 ./node_modules/.bin/vitest run tests/unified-experiment.test.ts tests/unified-action.test.ts tests/unified-pending.test.ts tests/unified-outside-reads.test.ts --testTimeout=60000
```

The latest file includes the mount regression and unresolved branch assertion, so that
command now reports their failures as well as running the campaigns.
`PENDING_REPLAY='op:value ...'` reduces a generated observation timeline.

From the repository root, sequentially:

```
node experiments/unified-updates/build.mjs
node experiments/unified-updates/measure.mjs /workspace/layered-baseline --bundle-only
node experiments/unified-updates/measure-pending.mjs
node experiments/unified-updates/pending-browser.mjs
```
