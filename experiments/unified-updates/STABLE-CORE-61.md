# Stage 61: stable contexts in the real scalar core

This is an implementation checkpoint, **not a successful acceptance result**.
Work is in `packages/signals/src`, using Solid's actual
node, linked-dependency, heap, async, ownership, effect, and transaction code.
The scalar Rollup build removes the legacy lane engine. The isolated JavaScript
reference was not used for these performance or size measurements.

Comparison baseline: unmodified tracked source at next commit
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c` in `/workspace/layered-baseline`.
That checkout also contains earlier untracked audit tests; they do not enter its
production build. Work remains local. Stores have not been expanded.

## What this slice implements

The existing split input/output boundary now selects a stable proposal context.
Both sides use the ordinary committed/proposed value slots. The output's update
and the action keeping its override alive are separate transactions.

```ts
const [first, guessFirst] = createOptimistic(source);
const middle = createMemo(() => load(first()));
const [second, guessSecond] = createOptimistic(middle);
```

With both guesses made by one open action, first=1 can remain held by `load(1)`
while second=2 publishes. Reversing setter order gives the same result. The
rendered override forwards observation to the middle calculation, so hiding it
does not silently release first's hold. Disposing the last observer can release
that hold; a removal still waiting to publish cannot. Pending probes alone do
not observe the input in this sense.

The implementation changes are:

- Freeze the position at each new proposal, using the committed input graph and
  its update context. A batch selects all its boundaries before computing new
  positions. Merely discovering a hidden input dependency does not relocate an
  existing guess. Inactive selectors remain transparent.
- Give same-layer optimistic peers the ordinary proposal-read/merge behavior.
  A higher context uses committed lower inputs. A lower pending/error
  notification schedules a check instead of merging contexts before a read.
- Route a recalculation's values and callbacks through its selected transaction.
  Distinguish preparing a ready proposal from actually joining a hold, preserving
  detached child initialization and scheduled DOM attachment.
- Keep incoming-answer lifetime coupling on the input side. It must not capture
  the independent output calculation just because the selector noticed an answer.
- Forward observation across active value selectors during async readiness
  checks, including retained committed dependencies and observer removal.
  These records are not added to ordinary nodes, and synchronous readiness does
  not traverse the observation graph.
- Avoid replaying downstream work for an equal, settled selector installation.
  A held input still requires context setup even when the initial value is equal.
- Reuse ordinary transaction callback queues during recalculation, including
  merges, instead of allocating three temporary arrays per routed computation.

There is still an older coordinator around this slice. In particular,
`computeLayer` retains provisional committed reads and post-body validation.
**Read-time retry has not been fully ported.** Stable position assignment alone
is not the complete stable-context model.

Supported entry: `src/experimental/scalar.ts`: signals, synchronous and async
memos, render/user effects, roots/cleanup, generator actions, accessor/callback
optimistic boundaries, source-owned pending/latest outputs, and preliminary
Loading/error integration. See [SCALAR-API.md](SCALAR-API.md) for the deliberately
restricted overloads and exclusions. Stores, SSR/hydration, `until`, `refresh`,
and deferred APIs are not claimed as integrated into this entry.

## Observable evidence

`stable-core-audit.mjs` runs identical public-API programs against the two actual
production builds. With guess=1 already published, guess=2 suspended, and an
unrelated rerun:

| Observation | next | Candidate |
| --- | --- | --- |
| Rerun reader's optimistic value | 2 | 1 |
| Separate value/async pair | 1 / 1 | 1 / 1 |
| Newly mounted reader | 2 | 1 |
| After the second flight settles | All 2 | All 2 |

The hidden-input test additionally checks that discovering a deeper dependency
preserves the selected `10:20` request, cannot release the peer hold early, and
does not keep it held after its actual peer finishes. Separate bindings, a pair
memo, and an async label then all publish 10:20 while the deeper work remains
unanswered.

New tests exercise same-action nested guesses at depths 2 and 5, both setter
orders, sync and async-function read-order cases, cleanup of discarded attempts,
observation forwarding, and disposal/conditional/owned-child removal. Existing
scalar suites exercise repeated guesses, unrelated/late readers, sibling joins,
correction and overlapping action lifetimes, stale async answers, errors,
owned-child replacement, real DOM attachment, retained subscribers, and finite
seeded publication campaigns. These are finite tests, not a proof for arbitrary
graphs or arbitrary depth.

Final checks after queue reuse:

- Full signals suite: **5,472 pass, 23 expected failures, 2 skipped** across 324
  files. This includes the compatibility API; it is not all scalar-only coverage.
- Unified-update suite: **299 pass, 3 expected failures** across 28 files. Two expected
  failures belong to legacy pending comparisons; one is the new candidate gap below.
- Selected scalar-only matrix with legacy lanes compiled out: **117 pass,
  1 expected failure** across 13 files.
- Source declaration type check passes. Rollup completes with its existing
  unrelated test-file type warnings and circular-dependency warnings; no new
  source diagnostic remains.

## Difference classification

**Implementation bug, retained as an expected failure:** mounting an ordinary
async memo during unrelated active optimism starts an unnecessary stale request.

```ts
// x has committed 0; an action has proposed x=1 and guessed unrelated view=10.
const result = createMemo(() => fetchFor(x())); // mounted after that flush
```

Next starts `fetchFor(1)`. The candidate starts `fetchFor(0)` and then
`fetchFor(1)`. The old adapter runs a speculative committed-value body before
checking whether it actually reached an optimistic boundary. Request-side effects
have already happened by then. The unchanged assertion expects only `[1]` and
is marked `it.fails`; this is neither an intentional semantic change nor a pass.
The production audit independently reproduces it. The read-order tests that pass
must not be advertised as complete early-retry support.

**Intentional changes following accepted rulings:**

1. An existing child proposal retains its position when its parent later gains
   or loses an override. A new child guess can choose the new input context.
   The former internal depth test dynamically moved the existing guess.
2. A pending-of-pending output can publish true above a held pending output.
   Merely sharing a flush no longer forces these distinct contexts into one
   transaction. The lower boolean and its ordinary consequences remain coherent.
3. A visible child override retains observation of its pending input. Two older
   comparison tests expected next's early lower publication; their next assertions
   are retained, while the candidate assertions now require the accepted hold.
   A ready incoming answer still joins the child's action lifetime. Consequently
   the lower proposal can remain held until that action finishes, and pending
   describes the value actually committed at the output.

No further semantic ruling was needed for this slice. The unresolved retry issue
is an implementation problem. APIs listed above remain explicitly deferred.

## Measurements and acceptance

Final public-API measurements on AMD EPYC 9V74 80-Core Processor, Node v24.19.0.

| Ordinary synchronous workload | Candidate / next elapsed time |
| --- | --- |
| signal-read | 0.929× |
| memo-read | 0.942× |
| write-flush | 0.989× |
| equal-write | 1.037× |
| memo-write | 0.890× |
| batch-10-writes | 0.928× |
| chain | 0.878× |
| diamond | 0.973× |
| fanout-memos | 0.932× |
| fanout-effects | 0.965× |
| branch-switch | 0.888× |
| signal-create | 0.849× |
| memo-create-dispose | 0.952× |

The equal-write result is about 4% slower in this run; these are microbenchmarks,
not a general application speedup claim. With an inactive boundary alive, the
separate memo-read, chain, diamond and creation probes are recorded in
`final/inactive-sync.json`.

| Import scenario (includes action) | next min / Brotli bytes | Candidate min / Brotli bytes |
| --- | ---: | ---: |
| ordinary | 21,918 / 8,116 | 21,144 / 7,845 |
| optimistic | 27,250 / 9,864 | 29,532 / 10,761 |
| pending | 28,812 / 10,419 | 30,954 / 11,169 |
| latest | 28,715 / 10,368 | 30,668 / 11,081 |

Ordinary minified size is 3.5% smaller. The optimistic public import is **8.4%
larger minified and 9.1% larger Brotli**, so the size gate fails. The scalar
measurement harness now imports the public `createOptimistic`, including its
argument check and public return shape; earlier directories used an internal
action-lifetime adapter and are not the final size/memory evidence.

| Synchronous optimistic writes | next ns/write | Candidate ns/write | Ratio of medians |
| --- | ---: | ---: | ---: |
| active-depth-1-write-ns | 1,691 | 4,805 | 2.84× |
| active-depth-4-write-ns | 2,947 | 13,236 | 4.49× |
| active-depth-16-write-ns | 7,096 | 64,456 | 9.08× |
| active-direct-depth-1-write-ns | 1,754 | 5,212 | 2.97× |
| active-direct-depth-4-write-ns | 3,002 | 10,549 | 3.51× |
| active-direct-depth-16-write-ns | 6,786 | 38,852 | 5.73× |

These transparent-wrapper workloads are roughly **2.8–9.1× slower** than next.
A separate workload first reveals overrides at every level, then updates only
the top one, asserting all publications. At depths 1, 4 and 16 its paired ratios
are 3.33×, 2.75×, 2.67×.
It contains no async memo. All active-optimism results fail the performance gate.

The first version of that additional benchmark guessed every level together
and incorrectly expected lower guesses to publish too. Under the accepted
incoming-input/action-lifetime coupling, a lower guess changing an already
overridden child input can instead join that child action. Its failed assertion
is preserved; it produced no accepted performance result. The final benchmark
reveals inputs before activating children and measures equivalent top updates.

| Allocation probe | next sampled bytes/write | Candidate sampled bytes/write |
| --- | ---: | ---: |
| ordinary | 644 | 509 |
| inactive | 635 | 506 |
| layer-1 | 1,379 | 4,829 |
| layer-4 | 1,338 | 5,738 |
| layer-16 | 1,315 | 9,999 |

Retained boundary bytes (median):
- boundaryBytes: next 555; candidate 1181.
- directBoundaryBytes: next 568; candidate 808.

Every measured memory run collected all 30 disposed-reader tokens while the
producer remained alive. This finite check does not establish absence of all leaks.

All measurements use production builds, fresh processes, paired alternating
next/candidate runs, and workload assertions. Timing ratios below 1 mean less
elapsed time than next. Ordinary sync uses seven paired samples per workload;
inactive-boundary checks and allocation sampling use three, active optimistic
and retained-memory probes use five. V8 allocation sampling includes collected
objects and is an estimate, not an exact object count. CPU/Node and bundle hashes
are retained with the measurements. Nested benchmark depth includes transparent
optimistic wrappers; it does not mean every wrapper has a simultaneous override.

The ordinary path looks worth preserving. The current adapter fails the active
optimism and bundle-size gates. It still eagerly transfers and holds downstream
nodes, re-enters the scheduler per computation, repeatedly checks readiness, and
maintains the old speculative graph-validation mechanism alongside context
positions. Queue reuse removes one avoidable allocation source; it does not make
that architecture acceptable. Further work should replace provisional replay
and preparation routing together in the real core, deleting obsolete coordinator
paths, before expanding features or touching stores. Passing the value timelines
is insufficient reason to keep adding mechanisms around this adapter.

## Reproduction and artifacts

`results/stable-core-stage61/` contains before/checkpoint sources, failed
intermediate logs, final logs, public-API audit JSON, built application bundles,
raw timing/allocation records, and source/worker hashes. `final/` and
`sync-queue-reuse/` are the final measured code. Earlier directories are retained
only to make the implementation experiments reviewable; they are not alternate
performance baselines.

```sh
node experiments/unified-updates/build.mjs --scalar
cd packages/signals
node node_modules/vitest/vitest.mjs run
node node_modules/typescript/bin/tsc -p tsconfig.build.json --noEmit
cd ../..
MEASURE_OUT=experiments/unified-updates/results/stable-core-stage61/final \
  node experiments/unified-updates/measure.mjs /workspace/layered-baseline --scalar --bundle-only
SYNC_SAMPLES=7 node experiments/unified-updates/measure-sync.mjs \
  experiments/unified-updates/results/stable-core-stage61/sync-queue-reuse
node experiments/unified-updates/measure-optimistic.mjs \
  experiments/unified-updates/results/stable-core-stage61/final
SYNC_SAMPLES=3 node experiments/unified-updates/measure-inactive.mjs \
  experiments/unified-updates/results/stable-core-stage61/final
node experiments/unified-updates/measure-allocations.mjs \
  experiments/unified-updates/results/stable-core-stage61/final
node experiments/unified-updates/measure-active-contexts.mjs \
  experiments/unified-updates/results/stable-core-stage61/final
node experiments/unified-updates/stable-core-audit.mjs \
  /workspace/layered-baseline/packages/signals/dist/prod/index.js
node experiments/unified-updates/stable-core-audit.mjs \
  packages/signals/dist/scalar/index.js
```
