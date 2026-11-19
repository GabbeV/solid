> Follow-up: [stage 95](SIZE-95.md) retains the larger deletion with transaction-depth initialization, final validation, and new performance controls.

# Stage 94: the larger deletion and benchmark history

This is a diagnostic follow-up, not a newly retained runtime optimization. The
stage-93 runtime remains untouched (verified against its source manifest).

The larger trial removed `Layer.update` and its active-layer cleanup registry,
and replaced the layer candidate-update set with the scheduler's live transaction
array. It saved 151–177 Brotli bytes over stage 92, versus the 81–101 bytes retained
in stage 93. It preserved the separate action lifetime in `scope`; only redundant
publication ownership/membership was removed.

## New evidence

Profiling a fresh process with only depth 16 suggested the rejected version could
be faster. That result was followed by unprofiled comparisons against pinned next
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, with the retained stage-93 implementation
as the control. All numbers below are ratios to **next**, from five rotating
fresh-process triples.

| Workload | Retained stage 93 / next | Larger deletion / next |
| --- | ---: | ---: |
| Depth 16 only, ten 50,000-write windows | 1.776 | 1.473 |
| Original depth 1→4→16 worker, depth-16 result | 1.731 | 2.203 |
| Controlled worker, depth 16 only, one 20,000-write window | 1.905 | 1.618 |
| Same controlled worker, depths 1→4→16, depth-16 result | 1.914 | 2.138 |

The controlled comparison keeps the worker, 15,000-write warm-up, explicit GC,
and 20,000-write measurement window the same. The difference is whether depths
1 and 4 ran and their graphs were disposed beforehand. The original slower case
is retained as evidence, not replaced by the favorable fresh-process result.
Raw ranges overlap in some cases; these are paired medians, not portable bounds.

In separately instrumented copies of the stage-92 and rejected combined bundles,
the original three-depth fixture executes exactly the same counted work:

| Entry point | Calls in each version |
| --- | ---: |
| Core recomputation body | 315,183 |
| Scheduler settlement | 210,069 |
| Layer preparation | 210,066 |
| Layer settlement | 210,066 |
| Layer rerun routing | 315,099 |
| Pending-scope check | 525,141 |

These counters are diagnostic only and are absent from runtime and timing
measurements. Matching counts rules out extra recalculation/preparation passes
as the explanation in this fixture. It does not count every loop iteration or
prove equivalence for arbitrary graphs.

The evidence points toward optimization/GC history influencing the result, not
an intrinsic need for duplicate ownership. It does **not** yet establish the
specific cause: inlining, object layout, tiering, or weak-reference invalidation
remain hypotheses. The profile places substantial time in the coordinator's
preparation/settlement and ordinary recomputation paths.

## Consequence

The larger simplification remains worth pursuing. A useful next experiment is
to stabilize the optional coordinator's hot function boundaries and record
shapes while retaining the deleted bookkeeping. Both fresh-depth and graph-
replacement histories must remain performance checks. Ordinary nodes should not
pay for this investigation. Do not restore the larger trial to the retained
runtime merely by choosing its favorable benchmark history.

Artifacts are under `results/size-stage94/`: original and controlled paired
runs, CPU profiles, the exact diagnostic workers, and instrumented work counts.
`profile/nested-worker-v1.mjs` matches the original isolated-run worker hash;
`profile-nested.mjs` is the controlled variant. The runtime bundles are the saved
stage-93 retained and rejected bundles. No semantic rule or test assertion changed.
