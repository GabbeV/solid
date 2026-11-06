# Stage 98: separate node cost from coordination cost

Baseline: unchanged next `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, Node 24.19.0.
Changes are in the real scalar Solid core, locally. The experiment remains
**unaccepted**: default active optimism is substantially slower and feature
bundles are larger than next. The improvements below do not close those gaps.

## How much does the extra node explain?

The counterfactual adds one synchronous identity memo per optimistic boundary
to unmodified next. For this changing-value workload it has the same node count
and visible guesses/corrections as the two-node experiment. It is a calibration,
not a proposed implementation or an alternative correctness baseline.

Five rotating triples, all times divided by next:

| Transparent chain depth | Next with extra nodes / next | Entry checkpoint / next |
| --- | ---: | ---: |
| 1 | 1.084 | 1.973 |
| 4 | 1.168 | 2.507 |
| 16 | 1.505 | 3.663 |

At depth 16, the extra nodes explain about one fifth of the observed excess
under this calibration: `(1.505 - 1) / (3.663 - 1)`. At smaller depths they explain
less. This is **not an exact causal decomposition**: the extra nodes inside our
engine also pay our heavier coordination cost. Removing one there saves both.
The evidence rejects treating a roughly fourfold slowdown as inevitable merely
because optimistic boundaries have twice as many nodes.

Instrumented depth-16 updates perform 32 recomputations in next and 48 in the
entry checkpoint. The latter also performs 48 output adoptions, holds and
commits, 94 frame-read checks, and 53 readiness checks. CPU sampling places
substantial time in recomputation/context setup, reads, adoption, scheduling and
layer computation. It does not identify one isolated extra-node allocation as
the dominant update cost. Instrumented timings are not acceptance measurements.

## Retained implementation

### Borrow a suitable existing input, materialize only when needed

```ts
const doubled = createMemo(() => source() * 2, { sync: true });
const [view, guess] = createOptimistic(doubled);
```

This creates one new output node and uses `doubled` as its producer. It leaves
the source's owner and auto-disposal policy intact. Multiple boundaries can use
the same source. The first `refresh(view)` creates a private input computation
which reads `doubled`; it does not execute `doubled`'s clean callback again.
Later refreshes reuse that computation. Internal materialization also works
when refresh is called from an effect's imperative callback.

The optimization requires a read-only, explicitly synchronous memo, with no
loading seed or boundary input options. Callback inputs, default async-aware
memos, writable computations, optimistic outputs and ordinary signals keep
their producer. A flag in the existing configuration word distinguishes
writable computations; it adds no property or ordinary-read branch. The flag
is also set by the normal entry because experimental and normal APIs can coexist
in that build. Plain value-signal and read-only memo construction are unchanged.

The broader read-only-memo trial was rejected. An async stream can emit a raw
promise value. The existing optimistic input normalizes that value again:

```text
source stream:   0 → unresolved promise → resolves to 2
view on screen:  0 → 0                  → 2
```

Sharing the async-aware source exposed the promise itself instead of retaining
0. A regression test catches this through an actual render callback containing
`{ value: view() }`, so the render calculation cannot accidentally normalize the
value on the optimization's behalf. The failed trial is archived; its default
memo-sharing performance results are not the retained results below. Returning
thenables from `sync: true` callbacks is already documented as undefined
behavior by next; the retained optimization relies on that existing contract.

General callback fusion is not implemented. An input may still own a pending
flight, staged error and children while its output publishes an override.
Moving those into a small record would require redirecting async targets and
dependency/ownership frames, or retaining two logical computations behind one
object. Neither follows simply from deleting a node. There may still be useful
specializations for immutable inputs or lazy materialization of other producer
kinds; this pass does not establish that two full nodes are necessary forever.

### Reduce coordination paid by every staged node

- A bit in the existing configuration word says whether a saved published
  dependency list exists. Stable graphs skip empty WeakMap lookups and deletes.
  Structural changes and errors still save their published dependency frames;
  commit/disposal clear the bit and entry together. Ordinary node shapes and
  ordinary settled reads acquire no new storage or branches.
- Guess lifetimes are indexed by their ordinary transaction. Readiness for an
  output update without guesses now skips all unrelated guess scopes. Ordinary
  merge transfers membership; disposal and expiry remove it. Preparation still
  rechecks ordinary readiness after each retired override because a correction
  may merge more work. This is not a new group-wide release rule. The tradeoff
  is an optional map and a set per active scope.
- The public optimistic adapter now returns its actual accessor/setter pair.
  It no longer allocates and discards an internal clear closure, an extra tuple,
  and a lifetime-options wrapper. The explicit proposal/clear test adapter keeps
  those facilities. The final pair refactor saves 69 minified / 45 Brotli bytes
  relative to its immediate trial, although the complete pass grows bundles.

A transparent-selector bypass also passed the then-current tests but added code
without a reliable speed advantage. It is removed. These optimizations target
the experiment's input split, shared dependency journal and lifetime machinery;
no independent optimization applicable to next is credited as closing the gap.

## Performance

Every ratio below is execution time divided by **next**, lower is better. The
entry checkpoint is validated stage 97 measured in the same rotating campaign;
it is included only to attribute this pass. Ratios are medians of paired ratios,
not ratios of independently computed absolute medians. Raw runs and ranges are
retained. No build or test ran concurrently with the timing campaigns.

| Workload | Stage 97 / next | Stage 98 / next |
| --- | ---: | ---: |
| **Ordinary callback/default-accessor inputs (7 triples)** | | |
| inactive-ordinary-read-ns | 0.938 | 0.900 |
| inactive-ordinary-write-ns | 0.858 | 0.889 |
| active-depth-1-write-ns | 1.783 | 1.681 |
| active-depth-4-write-ns | 2.653 | 2.493 |
| active-depth-16-write-ns | 3.636 | 3.436 |
| active-direct-depth-1-write-ns | 1.828 | 1.743 |
| active-direct-depth-4-write-ns | 2.709 | 2.458 |
| active-direct-depth-16-write-ns | 3.894 | 3.891 |
| **Explicit sync memo inputs (7 triples)** | | |
| transparent-1-write-ns | 1.935 | 1.739 |
| transparent-4-write-ns | 2.436 | 1.987 |
| transparent-16-write-ns | 3.798 | 2.440 |
| **Bulk creation with sync memo source (5 triples)** | | |
| callback-create-ns | 2.771 | 2.798 |
| memo-accessor-create-ns | 1.494 | 1.057 |
| **Complete shared-action cycles (7 triples)** | | |
| shared-1-complete-cycle-ns | 1.235 | 1.291 |
| shared-16-complete-cycle-ns | 2.535 | 2.533 |
| shared-128-complete-cycle-ns | 5.124 | 3.099 |
| **Nested active contexts, uppermost guess (5 triples)** | | |
| depth-1-top | 1.874 | 1.912 |
| depth-4-top | 1.704 | 1.608 |
| depth-16-top | 1.219 | 1.371 |
| **Independent open actions (5 triples)** | | |
| independent-1-write-ns | 1.815 | 1.836 |
| independent-16-write-ns | 0.735 | 0.883 |
| independent-128-write-ns | 0.073 | 0.079 |
| **Inactive optimistic action (5 triples)** | | |
| inactive-sync-action-ns | 0.999 | 1.116 |
| **Pending-observed synchronous writes (7 triples)** | | |
| pending-observed-sync-write | 1.111 | 1.155 |

Seven paired samples per ordinary workload:

| Ordinary workload | Stage 98 / next |
| --- | ---: |
| signal-read | 0.891 |
| memo-read | 0.955 |
| write-flush | 0.939 |
| equal-write | 1.046 |
| memo-write | 0.933 |
| batch-10-writes | 0.940 |
| chain | 0.895 |
| diamond | 1.012 |
| fanout-memos | 0.897 |
| fanout-effects | 1.014 |
| branch-switch | 0.908 |
| signal-create | 0.778 |
| memo-create-dispose | 0.876 |

The large improvements are the explicitly synchronous input chain and a large
shared action's expiry. Default accessor chains still cost nearly four times
next; the optimization deliberately does not apply there. Small independent
action and nested-active workloads are mixed. The 16-deep active-context result
and independent-action cases regress relative to the checkpoint in this run;
they remain reported rather than averaged into the large shared-scope win.

Ordinary imports exclude the optimistic machinery. Ordinary reads, memo writes,
chains, memo fan-out and creation show useful wins against next in this campaign;
equal writes, diamonds and effect fan-out show small regressions. The saved-bit
change does not execute on the settled ordinary path. These numbers do not prove
that tiny source changes caused every small timing difference. Pending-observed
sync writes remain slower than next. Neither small wins nor regressions are
discarded because the active-optimism gap is larger.

## Allocations and retained memory

Five GC-controlled runs of 20,000 boundaries sharing one explicit sync memo:

| Per-boundary retained heap | Next | Entry checkpoint | Retained |
| --- | ---: | ---: | ---: |
| callback reading the memo | 636 B | 1,143 B | 1,143 B |
| direct memo accessor | 569 B | 1,049 B | 770 B |

Sharing removes about 279 bytes per eligible boundary. It is still about 35%
larger than next. The callback form retains both computations and remains about
80% larger in this fixture. These are measured heap deltas, not exact object
sizes or universal allocation counts. Bulk creation timings above include
creation warm-up effects; they are not isolated warmed constructor throughput.

The existing general memory worker, which uses different input shapes, measures
about 1,063 versus 556 bytes for callback boundaries and 1,049 versus 568 for
default direct-input boundaries. All three paired disposal runs retain zero
disposed reader payloads. No claim is made that the new active-scope map is free;
its per-active-action allocation is not separately isolated by these heap runs.

## Size

Same production Rollup/property-mangling/esbuild/Brotli-11 pipeline on both sides.
The table reports shipped import scenarios, not source-character counts.

| Imports | Next minified | Stage 98 minified | Next Brotli | Stage 97 Brotli | Stage 98 Brotli |
| --- | ---: | ---: | ---: | ---: | ---: |
| ordinary | 21,918 | 21,434 | 8,116 | 7,970 | 7,982 |
| optimistic | 27,250 | 31,008 | 9,864 | 11,196 | 11,380 |
| pending | 28,812 | 31,474 | 10,419 | 11,427 | 11,476 |
| latest | 28,715 | 31,041 | 10,368 | 11,320 | 11,350 |
| refresh | 27,892 | 22,097 | 10,117 | 8,180 | 8,198 |
| optimistic-refresh | 28,322 | 31,653 | 10,208 | 11,406 | 11,615 |
| optimistic-pending | 29,242 | 33,689 | 10,518 | 12,024 | 12,245 |
| optimistic-latest | 29,145 | 33,254 | 10,464 | 11,912 | 12,090 |
| optimistic-observations | 29,337 | 34,382 | 10,541 | 12,218 | 12,396 |

The optimistic bundle grows 184 Brotli bytes from stage 97 and is now 15.4%
larger than next. Ordinary imports remain 1.7% smaller than next, although they
grow 12 bytes in this pass. Feature size is an outstanding acceptance failure;
no threshold is raised. The source-sharing check and lazy refresh materializer
buy a conditional runtime/allocation improvement at a code-size cost.

## Validation and reproduction

- 463 scalar tests pass with legacy lanes disabled; 34 explicit baseline/legacy
  comparisons remain excluded.
- The unchanged upstream selection remains 618 passes / 36 classified failures,
  with exactly the same failure identities as stage 97.
- 500 seeds × 60 operations = 30,000 overlap operations pass (all 11 tests).
- Normal-entry suite: 5,690 passes, two skips. TypeScript and production build pass.
- New coverage includes stream-value normalization, raw loading seeds, writable
  thenable setters, direct-input refresh from effects, repeated refresh, and
  shared-source disposal/ownership. No consistency assertion is weakened.

These are finite tests, not a proof over all graphs. No API contract or lifetime
ruling changes, no diagnostic is added, and stores/full renderer integration
remain deferred.

Artifacts: `results/node-cost-stage98/`, including `before/`, trial bundles,
`attribution/` counters/profile/calibration, `runtime-change.patch`, source hashes,
`validation-final.json`, final bundles and timings in `retained/`, and mixed
bundle sizes in `combined-retained/`. Unsafe generic-sharing trial results live
under `rejected-generic-sharing/` and are not final optimistic measurements.
The ordinary and pending timing runs are reused from that campaign only after
verifying their respective final bundles are byte-identical; those imports do
not include the rejected sharing code. The baseline checkout has no tracked
modifications. All work remains local.

Build/size commands are the existing `build.mjs --scalar` and
`MEASURE_OUT=… node experiments/unified-updates/measure.mjs /workspace/layered-baseline --scalar --bundle-only`
(add `--combined` for mixed imports). `compare-performance-pass.mjs` accepts
output JSON plus next/checkpoint/candidate bundles; `PERF_WORKER`, `PERF_CASE`,
`PERF_SAMPLES` and `MEMORY_SAMPLES` select workloads and repetitions. For the new
chain and creation-memory workers use `node-cost-bench.mjs` and
`memo-input-memory.mjs`, respectively, with `PERF_CASE=sync`. The attribution
directory preserves the original default-memo worker and padded-next adapter.
`compare-sync.mjs` runs the ordinary import scenarios. Bundle and worker hashes
are recorded with each campaign.
