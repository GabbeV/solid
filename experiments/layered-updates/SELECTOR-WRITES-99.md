# Stage 99: selectors use ordinary writes

Baseline: unchanged next `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, Node 24.19.0.
This pass works in the real scalar core. The experiment is still **unaccepted**:
the improvements below do not establish performance parity, complete API support,
or acceptable final feature size.

## What changed

An optimistic boundary's input still performs the user computation, normalizes
async values, and owns its children and errors. The output chooses a value. A
settled, structurally unchanged selection does not need to run another full
computation just to stage that value.

```ts
const [first, guess] = createOptimistic(() => source());
const input = createMemo(() => first() + 1);
const [second] = createOptimistic(() => input());
```

After initialization, writing a new guess can stage `first` through the ordinary
setter in its selected update. When `second` is transparent, its input producer
still runs normally; its settled value can then stage `second` through the same
setter. The outputs retain separate committed/proposed slots, dependency links,
transaction membership and ordinary publication. Downstream async still holds
the proposal. There is no direct-to-screen commit shortcut.

This is deliberately conditional. Errors, pending state, a new/stale dependency
list, owned children or cleanups, custom equality, snapshot state, active
attribution hooks, and nested user computation contexts retain the full
computation path. A refreshed shared input must be linked before direct guess
staging is eligible. Function values remain values; the setter's updater form
must not accidentally invoke them. The existing async-input normalizer remains
in place, including the stream-value regression from stage 98.

The implementation shares `stageSelectedValue` between forwarding and guesses.
It checks the selector's eligibility, updates its computation metadata, and calls
the existing ordinary setter. Guess writes temporarily select their output
update; they run no user calculation or owned-child setup. No ordinary-node
field, value version, dependency map or retained record is added. The only new
closures on this path are for forwarding a function as a value to the existing
functional setter API.

The optimization is installed by the optional optimistic module. Observation-
only applications do not retain the selector-staging helper. This keeps the
specialization at the explicit primitive while values still use the common
holding, notification and publication machinery.

The other retained change handles exact update matches in ordinary reads. When
the source's actual holder is already the current update, the scalar core skips
the layer posture query and redundant join. It preserves the creation-inheritance
mark, including the existing exception for ready preparation. Reads involving a
different or merged holder retain the full path. The legacy build keeps its
original lane-aware read path; settled ordinary reads gain no layer traversal.

## A correctness failure found and fixed

The first direct-guess trial passed the rendered scalar cases but failed an
unchanged compatibility test:

```ts
const [value, guess] = createOptimistic(0);
guess(1);
const done = action(function* () { yield gate; })();
flush();
value(); // must be 1, even with no render subscriber
```

Selection runs after the current seam has judged its updates. The trial removed
its queued write as though it were a normal compute-phase staging; with no
subscriber to dirty, no further publication round occurred. The proposal stayed
unpublished. The fix keeps ordinary write scheduling, including an equal guess
whose new update still needs a publication judgment. It neither forces a commit
nor adds a special unobserved-read rule.

The unchanged compatibility assertion now passes. Focused coverage additionally
checks 100 equal guesses while the action remains open, visible values, and the
absence of retained completed output transactions. Another equivalence test
compares the optimized selector with an equivalent custom comparator's full
computation path using callable values, objects, null, NaN and signed zero.

## Work counts and remaining direction

For a repeated guess feeding the default 16-boundary chain, the retained build
performs **32 full computations and 32 reads per update**, matching the pinned
next fixture's counts. The earlier instrumented two-node path performed 48 full
computations. Keeping two objects no longer implies evaluating two bodies on
each transparent hop.

The retained chain still performs 48 adoptions/holds/commits, 32 scoped
recomputations and 37 readiness queries. Next's recorded fixture performs four
readiness queries. These are diagnostic counts, not interchangeable operations
with equal cost. The profile continues to place substantial time in calculation
setup, scoped execution, adoption, reads and scheduling. The guarded selector
write itself also has a cost.

That supports a further pass on scope routing and ownership/publication
bookkeeping. It does not show that transaction records can safely be recycled:
unobserved async work and boundary lifetimes can outlive a publication and retain
its identity. Nor does it justify removing input producers that still own async
normalization and lifecycle work. No such shortcut is taken here.

## Performance

Every ratio is execution time divided by **next**, lower is better. The stage-98
column is the validated entry checkpoint measured in the same rotating campaign,
not an alternative baseline. Ratios are medians of paired ratios. Raw process
runs, absolute medians, ranges and bundle/worker hashes are retained. No build or
test runs concurrently with the final timing campaign.

| Workload | Stage 98 / next | Stage 99 / next |
| --- | ---: | ---: |
| **Ordinary callback/default-accessor inputs (7 triples)** | | |
| inactive-ordinary-read-ns | 0.869 | 0.970 |
| inactive-ordinary-write-ns | 0.825 | 0.848 |
| active-depth-1-write-ns | 1.905 | 1.900 |
| active-depth-4-write-ns | 2.407 | 2.001 |
| active-depth-16-write-ns | 3.895 | 3.156 |
| active-direct-depth-1-write-ns | 1.665 | 1.587 |
| active-direct-depth-4-write-ns | 2.605 | 2.084 |
| active-direct-depth-16-write-ns | 3.777 | 3.324 |
| **Explicit sync memo inputs (7 triples)** | | |
| transparent-1-write-ns | 1.830 | 1.583 |
| transparent-4-write-ns | 2.141 | 1.783 |
| transparent-16-write-ns | 2.604 | 2.018 |
| **Complete shared-action cycles (7 triples)** | | |
| shared-1-complete-cycle-ns | 1.213 | 1.399 |
| shared-16-complete-cycle-ns | 2.672 | 2.182 |
| shared-128-complete-cycle-ns | 2.857 | 2.438 |
| **Nested active contexts, uppermost guess (5 triples)** | | |
| depth-1-top | 1.829 | 1.712 |
| depth-4-top | 1.633 | 1.633 |
| depth-16-top | 1.357 | 1.280 |
| **One override with many memo readers (5 triples)** | | |
| fanout-16-write-ns | 2.182 | 1.870 |
| fanout-128-write-ns | 2.053 | 1.939 |
| fanout-512-write-ns | 2.139 | 2.054 |
| **Independent open actions (5 triples)** | | |
| independent-1-write-ns | 1.826 | 1.735 |
| independent-16-write-ns | 0.687 | 0.574 |
| independent-128-write-ns | 0.072 | 0.094 |
| **Inactive optimistic action (5 triples)** | | |
| inactive-sync-action-ns | 1.094 | 1.073 |
| **Pending-observed synchronous writes (7 triples)** | | |
| pending-observed-sync-write | 1.141 | 1.099 |

Seven paired samples per ordinary workload:

| Ordinary workload | Stage 99 / next |
| --- | ---: |
| signal-read | 1.055 |
| memo-read | 0.879 |
| write-flush | 1.005 |
| equal-write | 0.966 |
| memo-write | 1.046 |
| batch-10-writes | 0.986 |
| chain | 0.966 |
| diamond | 0.998 |
| fanout-memos | 0.932 |
| fanout-effects | 0.983 |
| branch-switch | 1.031 |
| signal-create | 0.762 |
| memo-create-dispose | 1.011 |

The strongest improvements are in chains and larger shared-action completion.
The explicit sync-input chain reaches about twice next; default callback and
accessor chains remain above three times next. Wider notification still costs
about twice next. Reducing full-computation counts to next's count is useful,
but plainly does not itself achieve parity.

Single-override completion regresses from 1.213× to 1.399× next. The 128-independent-
action case regresses from 0.072× to 0.094× next, while the 16-action case improves.
Both regressions remain reported despite the much larger absolute wins against
next in the independent-action fixtures. No across-the-board speedup is claimed.

Ordinary signal creation, settled memo reads, chains and memo fan-out show wins
against next. Initial signal reads, memo writes and branch switching show small
regressions. The controls below address the first two and ordinary write/flush;
small results are not discarded because the optimistic gap is larger.

Nine rotating triples per control, using the ordinary import bundles:

| Ordinary control | Stage 98 / next | Stage 99 / next |
| --- | ---: | ---: |
| signal-read | 0.916 | 1.003 |
| memo-write | 0.897 | 0.982 |
| write-flush | 0.864 | 0.902 |

The controls put current signal reads near parity and memo writes/write-flush
below next, rather than confirming the initial above-next results. However,
they also show that the entry checkpoint's ordinary wins are not all retained.
In particular, this pass does not claim to preserve its earlier signal-read
advantage. The spread between campaigns matters; the compiled read body's
layout/inlining effects remain an unresolved performance concern.

Two subsequent controlled trials investigated that concern. All entries below
are again execution time divided by next; each row compares bundles in the same
rotating campaign. Ordinary controls use nine triples; active cases use five.

| Trial | Workload | Retained / next | Trial / next |
| --- | --- | ---: | ---: |
| Remove exact-holder shortcut | signal-read | 1.040 | 0.988 |
| Remove exact-holder shortcut | memo-write | 0.959 | 0.959 |
| Remove exact-holder shortcut | write-flush | 0.959 | 0.987 |
| Remove exact-holder shortcut | default accessor depth 4 | 2.046 | 2.717 |
| Remove exact-holder shortcut | default accessor depth 16 | 2.947 | 3.291 |
| Combine held-read helpers | signal-read | 0.973 | 0.975 |
| Combine held-read helpers | memo-write | 0.924 | 0.917 |
| Combine held-read helpers | write-flush | 0.932 | 0.917 |
| Combine held-read helpers | default accessor depth 4 | 1.948 | 2.255 |
| Combine held-read helpers | default accessor depth 16 | 2.761 | 3.050 |

Removing the shortcut recovered some signal-read performance but lost substantial
active-chain performance. Combining visibility checking and joining in one
larger held-read function did not establish a signal-read improvement and also
slowed active chains. Neither establishes a better overall alternative. Both
passed the 465-test scalar suite, but neither is retained. Their source/bundles
and full results remain under `no-read-shortcut/` and `merged-read/`.
The retained source was restored exactly: all 57 runtime source hashes match
the fully validated variant, and all 12 rebuilt baseline/candidate bundles are
byte-identical to the retained bundles. These trials do not replace the complete
campaign above with selectively favorable numbers.

## Size and allocation

The same production Rollup/property-mangling/esbuild/Brotli-11 pipeline builds
both runtimes. These are bundled import scenarios, not source-character counts.

| Imports | Next minified | Stage 99 minified | Next Brotli | Stage 98 Brotli | Stage 99 Brotli |
| --- | ---: | ---: | ---: | ---: | ---: |
| ordinary | 21,918 | 21,506 | 8,116 | 7,982 | 7,991 |
| optimistic | 27,250 | 31,839 | 9,864 | 11,380 | 11,667 |
| pending | 28,812 | 31,622 | 10,419 | 11,476 | 11,540 |
| latest | 28,715 | 31,189 | 10,368 | 11,350 | 11,392 |
| refresh | 27,892 | 22,169 | 10,117 | 8,198 | 8,251 |
| optimistic-refresh | 28,322 | 32,484 | 10,208 | 11,615 | 11,899 |
| optimistic-pending | 29,242 | 34,520 | 10,518 | 12,245 | 12,532 |
| optimistic-latest | 29,145 | 34,088 | 10,464 | 12,090 | 12,372 |
| optimistic-observations | 29,337 | 35,211 | 10,541 | 12,396 | 12,674 |

Optimistic imports grow 287 Brotli bytes this pass and remain 18.3% larger than
next. Ordinary imports grow nine bytes and remain 1.5% smaller than next. The
optional-module move saves 200 Brotli bytes in the pending-only scenario versus
the direct-coordinator trial; the final optimistic bundle includes its dispatch
cost. These are real size costs, not an accepted final budget.

The shared-input allocation optimization from stage 98 is unchanged. This pass
removes recurring work, not the remaining producer/output objects. It adds no
per-node storage. The final GC runs below measure the unchanged boundary shapes
and check disposal retention; they do not measure every temporary allocation.

Three paired GC runs:

| Per-boundary retained heap | Next | Stage 99 |
| --- | ---: | ---: |
| callback input | 556 B | 1,063 B |
| default direct input | 568 B | 1,049 B |

All runs retain zero disposed reader payloads. These heap deltas remain
essentially unchanged from stage 98; this pass does not claim a per-boundary
allocation reduction.

## Trials and validation

- Exact-holder read handling improved the initial chain trial and is retained.
- Immediately computing an input's transparent selector in the same scope passed
  tests but did not establish a convincing additional speed gain. It is removed;
  eligible selectors now use the ordinary setter instead.
- Bypassing discovery around known selectors likewise added code without a
  robust gain. That branch is removed. All full calculations still use shared
  discovery/retry machinery.
- The initial direct-write scheduling bug is archived in
  `selected-write/no-observer-failure.log`; it is an implementation bug, not an
  intentional semantic difference.
- Moving the selector shortcuts behind the optimistic lifecycle hooks keeps them
  out of observation-only imports. The final measurements include that dispatch.

Final validation: 465 scalar tests pass with legacy lanes disabled (34 explicit
baseline/legacy cases excluded), 5,692 normal-entry tests pass (two skips), and the
unchanged compatibility corpus reports 618 passes / 36 failures with exactly the
same failure identities as stage 98. The 500-seed overlap campaign checks 30,000
operations and all 11 tests pass. Twelve focused tests also pass with production
defines; their two legacy-baseline comparison cases are excluded just as in the
scalar configuration. The extended selector tests pass in scalar/dev,
scalar/prod and normal-entry configurations. TypeScript and production builds
pass. No consistency assertion or performance/size threshold is relaxed.

An initial full normal run overlapped several other test/build processes and hit
the existing five-second timeout in the seeded timeline test. The unchanged
suite passes when rerun without that contention; that test then takes about 2.8
seconds. Its timeout is not increased. The first production test command also
included two explicitly named legacy-baseline cases; those expect the excluded
legacy semantics and are not candidate failures. Both initial reports are kept.

This finite matrix is not a proof over all graphs. Stores, full renderer/API
integration and previous acceptance gaps remain outside this pass. Sibling
ordering remains unspecified. No new semantic ruling or diagnostic is added.

## Reproduction

Artifacts live in `results/coordination-stage99/`: entry source snapshots,
individual trial bundles/timings, `runtime-change.patch`, `source-hashes.json`,
validation reports, diagnostic named/counting bundles and CPU profiles, and
final bundles/timings under `retained/` and `combined-retained/`.

After the ordinary scalar build and `measure.mjs --scalar --bundle-only` build
the final bundles (add `--combined` for mixed imports), run
`node experiments/layered-updates/results/coordination-stage99/run-performance.mjs`.
It runs the same workers against pinned next, the stage-98 checkpoint, and the
retained candidate, followed by the ordinary synchronous import campaign.
Diagnostic counting/profile timings are not used as performance results.
All work remains local and the baseline has no tracked modifications.
