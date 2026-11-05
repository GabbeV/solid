# Source-owned pending output

The user clarified that `isPending(x)` reads one lazily created pending output
belonging to x. It does not create an independent boundary at each call site.
The experimental `isPending` export now implements that identity and shares
ordinary output publication across callers. The package's existing public
export still uses legacy verdict lanes; it has not been replaced wholesale.

## Identity, lifecycle and callback windows

A WeakMap keyed by the source node holds its pending observation. No field is
added to ordinary signals or memos, and ordinary settled reads do not consult
the map. The auxiliary output is an observation-lifecycle computation, detached
from the first caller's owner. That distinction matters: making it a child of
the calling computation would destroy it when that caller reruns or unmounts;
making it a normal child of the source memo would destroy it on source reruns.

The output disconnects when its last subscriber leaves. Its normal disposal
hook releases active observation bookkeeping, and a later read revives it.
The source-keyed weak entry preserves identity without keeping an otherwise
unreachable source alive. This validates first-reader removal, last-reader
disconnection and revival, not every escaped-reference/source-owner-death case.

Callback windows observe the same per-source outputs. Their return value does
not define pendingness: `isPending(() => { x(); return 0; })` now observes x,
just like `isPending(x)`. Conditional callbacks track the inputs they actually
read. A memo computed while a callback probes it keeps ordinary dependency
reads; it does not inherit the callback's probing mode. Callback values use the
ordinary frame rule, with initialized pending reads served their committed value.

Async status propagation exposed a shared-boundary bug: the selector inherited
its input's pending mark without re-running. Boundary outputs now use the
existing CONFIG_REDERIVE path so the selector decides whether to expose the
input or its override. No second value/error/child commit mechanism was added.

Scheduler hooks now activate when experimental work is queued and detach after
it drains. An imported pending module with no observed inputs no longer leaves
its experimental callbacks installed. The common scheduler's optional call sites
remain, so this is not a claim of zero ordinary overhead.

The old explicit `createPending` helper remains as experimental scaffolding.
It is excluded from the measured shared-API application when unused. A possible
future public constructor API has not been specified.

## Validation

- Full suite with the shared pending adapter: 303 files, 5,263 passed,
  22 existing expected failures, two skips. Legacy tests still exercise legacy
  exports unless explicitly redirected; a green suite is not API-parity proof.
- Expanded shared-API campaign: 92 tests across seven files, with 300 scalar
  seeds, 200 pending seeds in each of two configurations and 100 branch seeds:
  38,000 operation checkpoints.
- Thirteen new direct API/lifetime tests cover one shared output, two readers
  with async consequences, first-reader removal, source recomputation, repeated
  disposal/revival, remounting during an open action, lazy input revival,
  callback equivalence/control flow and coherent async input completion.
- The explicit helper's existing targeted tests also pass after the lifecycle
  and hook changes.
- Production Chromium F5b, pending and foreign-input replays pass. Pending
  scenarios now use `createMemo(() => isPending(input))` in both baseline and
  candidate, instead of comparing baseline with the private constructor.
- Five memory samples collect all 30 disposed reader payloads during an open
  action; baseline retains those payloads until completion. Both collect them
  after completion.
- TypeScript retains the same 26 pre-existing diagnostics, with no new ones.

These are finite tests. Initial imperative reads, general dynamic callbacks,
escaped references after source-owner death, quiet refresh/affects behavior,
stores, SSR and the unsettled optimistic-input semantics below remain outside
complete validation. No consistency assertions were weakened.

## Measurements

Baseline `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, Node 24.19.0. Same production
build and application bundler. Five alternating fresh processes without other
build/test work. Raw final data is archived in `results/source-owned-stage7/`;
the version before lazy hook activation is archived separately.

| Median time, ns                           | Baseline | Candidate |
| ----------------------------------------- | -------: | --------: |
| Inactive module, ordinary read            |     6.61 |      6.31 |
| Inactive module, ordinary write           |    204.4 |     217.1 |
| Synchronous writes to the observed source |    388.4 |     405.9 |
| Held input, depth 1                       |   1579.5 |    1449.2 |
| Held input, depth 4                       |   2302.3 |    2323.2 |
| Held input, depth 16                      |   5478.2 |    5660.0 |

Ranges overlap in these workloads. Small differences are not reliable speedup
claims, and the remaining regressions do not establish acceptance. The pre-hook
refinement run had inactive-write medians 212.4 vs 245.1 ns; the final run
improves that comparison, but is still not a zero-overhead result.

| Retained bytes per fixture                                        | Baseline | Candidate |
| ----------------------------------------------------------------- | -------: | --------: |
| Memo observing a constant callback                                |    516.0 |     516.0 |
| Memo observing one common source, amortized over 20,000 observers |    529.0 |     528.8 |
| One signal plus its own observing memo, 20,000 distinct sources   |    737.3 |    1740.7 |

The first case creates no pending output because it reads no source. The second
amortizes one source-owned output across many readers. The third exposes the
additional per-source record and full computed output: approximately 1,003 bytes
above baseline. Sharing fixes duplicated construction, but unique-input memory
is still expensive and must be refined. These are retained-heap estimates, not
exact transient-allocation counts. This stage has no new allocation-profile run.

| Application bytes, minified / Brotli |      Baseline |     Candidate |
| ------------------------------------ | ------------: | ------------: |
| Ordinary                             |  21918 / 8116 |  22237 / 8238 |
| Optimistic                           |  27250 / 9864 |  26725 / 9872 |
| Pending                              | 28812 / 10419 | 27892 / 10176 |

Ordinary imports remain larger. Optimistic Brotli size is slightly larger despite
incomplete API parity; the smaller pending bundle also lacks complete parity.
Performance, retained memory and size acceptance remain open. No thresholds were
raised. The original foundational experiment is not complete or mergeable.

## Optimistic input question (resolved in the next stage)

The user subsequently chose `true`, retaining the upstream rule. The current
prototype implements that decision; see [INPUT-STATUS-RESULTS.md](INPUT-STATUS-RESULTS.md).
The following table records the earlier implementation that prompted the question.

Run `optimistic-pending-question.mjs`. Initially input=0, view=0. An action
starts a new input request and guesses view=1. The guess and its ordinary
consequences publish while the request and action remain open.

| Moment                                  | Legacy isPending(view) | Prototype isPending(view) |
| --------------------------------------- | ---------------------- | ------------------------- |
| Guess published, input request pending  | true                   | false                     |
| Matching answer 1 arrives, action open  | false                  | false                     |
| Differing answer 2 arrives, action open | true                   | true                      |
| Action ends and correction publishes    | false                  | false                     |

Both implementations display input=0 and view=1 while the action holds the
answer. The prototype currently reports the output's own unresolved proposal;
the legacy rule additionally treats the unfinished input calculation as pending
through a published guess. At this stage that was an unresolved semantic difference, not an accepted
change or a failure to be hidden by weakening assertions. The later ruling
and implementation supersede this question.

## Reproduce

From packages/signals:

```
PENDING_API=shared LAYER_SEEDS=300 PENDING_SEEDS=200 BRANCH_SEEDS=100 ./node_modules/.bin/vitest run tests/layered-pending.test.ts tests/layered-foreign-input.test.ts tests/layered-is-pending.test.ts tests/layered-experiment.test.ts tests/layered-action.test.ts tests/layered-coordination.test.ts tests/layered-outside-reads.test.ts --testTimeout=60000
PENDING_API=shared ./node_modules/.bin/vitest run
```

From the repository root, run the build and measurement scripts sequentially as
in previous result files. The pending adapter now calls experimental isPending.
`callback-observation.mjs` and `pending-observer-coordination.mjs` verify shared
query behavior; the optimistic-input question has its own combined bundle so
its primitives share a single runtime. All work remains local.
