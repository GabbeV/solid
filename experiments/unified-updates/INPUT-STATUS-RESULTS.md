# Pending through a published optimistic boundary

The user chose the upstream result: `isPending(view)` is true while the
optimistic boundary's input calculation is unresolved, even after its guess
has published. A matching answer can clear pending while the action remains
open; a differing answer remains pending until its correction publishes.

```ts
const input = createMemo(() => fetchCount(id()));
const [view, guess] = createOptimistic(input);
const pending = createMemo(() => isPending(view));
```

The experiment implements this through `createLayer(input, { lifetime: "action" })`
and the experimental `isPending` export. Public package exports still use the
legacy implementation. A green full suite does not demonstrate API parity.

## Mechanism and two bugs found

A value boundary identifies its relative input producer. Its source-owned
pending output subscribes to that producer as well as to the displayed output.
The relation is fixed and cached when the observation is created; no normal-node
field or settled-read lookup is added. Observation boundaries do not inherit
their own inputs' pending state recursively. A nested value boundary observes
its own producer, which can depend on an already optimistic value.

When the output is already unheld, status coordination can still find the
input's live update through the value boundary. Otherwise pending-true would
join the lower request it needs to describe. Incoming proposals compare against
the displayed guess, including a new guess made after a differing answer is
already held.

Two regression cases exposed bugs:

1. Starting an input request after guess 1 is visible did not wake existing
   pending readers. Legacy reports existing=false, late=true. The prototype
   now reports true to both through the shared output. Two legacy comparisons
   are explicitly expected failures with the same consistency assertions.
2. Staging status and explicit guesses in the same seam merged their updates
   before propagation. An independent async status label held back a ready
   guess. Value proposals now propagate first; status then describes that work,
   matching the ordering after ordinary writes. Consumers actually combining
   status and value still coordinate normally. No extra commit path was added.

Matching confirmation supersedes a suspended pending-true label through normal
async invalidation. Its obsolete answer cannot publish later. An unrevealed
guess held by its own async consequence also retains a coherent combined frame.

The shared fallback function removes redundant per-boundary closures. This is
a small allocation refinement, not a claim that boundary memory is acceptable.

## Validation

- Full shared-adapter suite: 304 files, 5,278 passed, 24 expected failures,
  two skips. Of the expected failures, 22 predate this stage and two are the
  new legacy later-request comparisons above.
- Expanded experimental suite: 107 passed plus those two legacy expected
  failures, eight files. The existing generated campaigns cover 38,000
  operation checkpoints (300 scalar seeds, 200 pending seeds in each of two
  configurations, 100 branch seeds).
- Seventeen direct optimistic-pending cases cover both implementations,
  matching/differing answers, request before/after publication, late readers,
  nested inputs, a second guess against an already held answer, an async
  status consequence, confirmation before that consequence resolves, an
  unrevealed guess, obsolete input answers, and 30 observer disposal/revival
  cycles. Both the output subscription and extra input subscription detach.
- The private pending constructor's 36 targeted tests also pass. It remains
  scaffolding rather than a new public API.
- TypeScript reports the same 26 baseline diagnostics, none in the experiment.
- Production build and annotation check pass. The combined Node replay and
  Chromium matching/differing input-status timelines pass, along with the
  existing F5b, pending and foreign-input DOM replays.

No consistency assertion was weakened. Finite campaigns do not prove arbitrary
graph behavior. Source-owner death with escaped readers, general callback
semantics, overlapping answer provenance, latest/refresh/affects, loading
boundaries, stores and SSR remain outside complete validation. The original
hosted reproduction remains unavailable; the F5b browser case is its local
reduction.

## Measurements of the completed input-status stage

Five alternating fresh processes per workload, Node 24.19.0, baseline
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`. Raw data and application bundles
are archived in `results/input-status-stage8/`. Earlier iterations are in
`input-status-stage8-before-cache/` and `input-status-stage8-cache/`.

| Median ns                  | Baseline | Candidate |
| -------------------------- | -------: | --------: |
| Ordinary settled read      |     6.87 |      6.81 |
| Ordinary write/flush       |    208.6 |     197.1 |
| Signal creation            |     57.0 |      68.9 |
| Memo creation              |    622.7 |     629.3 |
| Ordinary chain write       |   2632.2 |    2734.1 |
| Ordinary diamond write     |    892.2 |     915.1 |
| Ordinary fan-out write     |  15269.9 |   15253.2 |
| Observed-source sync write |    386.2 |     400.4 |
| Held input, depth 1        |   1546.1 |    1516.4 |
| Held input, depth 4        |   2331.4 |    2457.9 |
| Held input, depth 16       |   5345.2 |    6190.4 |
| Optimistic write, depth 1  |   1570.9 |    1189.7 |
| Optimistic write, depth 4  |   2874.9 |    2458.7 |
| Optimistic write, depth 16 |   7099.8 |    7609.1 |

Most timing ranges overlap. Shallow optimism improves, but deep-chain and
observed-source regressions remain. Signal creation has a particularly wide
range (baseline 54.2–83.0 ns; candidate 52.2–116.4 ns), so its median difference
is not evidence of a new per-signal allocation. No ordinary signal shape or
settled-read lookup was added.

Retained bytes per distinct observed-source fixture are 737.3 baseline versus
1692.9 candidate; a common source amortized across many readers is 529.1 versus
528.8. The closure refinement reduced the distinct-source candidate from 1749.2
bytes in the cached-input iteration. An optimistic boundary over a callback is
555.5 versus 1297.0 bytes, down from 1393.5 before closure removal. These are
retained-heap estimates, not transient allocation counts. All five pending
memory samples release the 30 disposed reader payloads during an open action;
baseline retains them until completion.

| Application minified / Brotli bytes |      Baseline |     Candidate |
| ----------------------------------- | ------------: | ------------: |
| Ordinary                            |  21918 / 8116 |  22237 / 8238 |
| Optimistic                          |  27250 / 9864 |  26840 / 9906 |
| Pending                             | 28812 / 10419 | 28250 / 10285 |

The ordinary bundle remains larger. Smaller minified experimental bundles are
not feature-equivalent acceptance, and optimistic Brotli is larger. Memory,
performance and size still prevent declaring this approach mergeable. No
thresholds were raised.

## Follow-up in progress: input-node reuse and equal answers

A subsequent local experiment reuses an existing signal/memo input node instead
of creating a redundant forwarding memo. The original eight experimental files
still pass (107 plus two legacy expected failures), and a new lazy-source
lifetime test passes. Signal inputs must use their notification stamp, not
`_time`: signal writes do not advance `_time`. No ordinary-node field was added.
This optimization has not yet had its expanded campaign or performance run;
the measurements above describe the prior, fully checked stage. Benchmarks now
include both accessor and wrapped-function inputs for the next comparison.

The equal-answer question is now decided provisionally: retain upstream's early
pending release, since changing it is outside the experiment's focus. Revisit
only if preservation requires substantial machinery. For input 0, published
guess 1, and an incoming answer 0, pending becomes false while the action stays
open; correction work begins at action completion. This rule already falls out
of the candidate's normal equality/status path. No special timing bookkeeping
was introduced. The earlier proposed true assertion is replaced by the user's
chosen semantic outcome; consistency assertions remain independent and intact.
See [INPUT-REUSE-RESULTS.md](INPUT-REUSE-RESULTS.md) for the next stage, including
input-node reuse, additional lifetime checks, and the Loading integration
correction required by the common ownership fix.

## Reproduction

From `packages/signals`:

```
PENDING_API=shared LAYER_SEEDS=300 PENDING_SEEDS=200 BRANCH_SEEDS=100 ./node_modules/.bin/vitest run tests/unified-*.test.ts --testTimeout=60000
PENDING_API=shared ./node_modules/.bin/vitest run
./node_modules/.bin/vitest run tests/unified-pending.test.ts tests/unified-foreign-input.test.ts
```

From the repository root, build before bundling or running browser replays:

```
node experiments/unified-updates/build.mjs
node experiments/unified-updates/measure.mjs /workspace/layered-baseline
node experiments/unified-updates/measure-pending.mjs
node experiments/unified-updates/measure-optimistic.mjs
node experiments/unified-updates/optimistic-pending-question.mjs
node experiments/unified-updates/optimistic-pending-browser.mjs
```

The question script retains its historical filename but now asserts the agreed
behavior. Its combined runtime keeps optimism and observation in the same
module graph. Run measurements serially without test/build work alongside them.
