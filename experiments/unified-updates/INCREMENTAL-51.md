# Stage 51: incremental obligation discovery, still not performance acceptance

This change refines the **reference scheduler**, not the production runtime.
The rejected production port is described in [stage 50](PRODUCTION-50.md).
The accepted observation, coordination, and publication rules are unchanged.

## Retained implementation

Learning an already-recorded dependency obligation no longer sends another
notification through the reader's entire downstream graph. Before this change,
evaluating every memo in a simple chain repeated that walk. A real write still
invalidates affected computations, including a second write in an existing
pending origin after its earlier calculation started.

The nontracing scheduler also caches its affected-node enumeration until a new
obligation, publication, or disposal invalidates it. Trace mode retains the
explicit node ordering used by traversal-order tests. This is a pending-work
snapshot, not a version lookup on ordinary reads. It is cleared on publication
and disposal; no new fields are added to ordinary nodes.

Repeated implicit ordinary writes to the **same source before preparation**
replace one queued proposal. Different sources retain distinct origins; explicit
groups and open actions do not coalesce this way. A ten-write batch no longer
creates ten origins only to merge them on the first downstream read. Already
dirty computations also avoid repeating the same origin's notification walk.
No previously evaluated proposal is silently treated as clean.

## Validation

The full reference test command passes **180 tests: 131 current-model cases and
49 historical-model cases**. Twelve new cases cover:

- Same-action nested guesses with independent publication, tracing on and off.
- Linear notification visits through a 64-memo chain over repeated updates.
- Superseding an async calculation by another write in its existing origin.
- Coalescing repeated source writes while a different source publishes
  independently of the first source's pending calculation.
- Four 100-operation campaigns, each replayed on the conservative pre-change
  model. Actual publication callbacks and visible snapshots match exactly;
  pending update, scope, and forwarding registries drain. These use trace=false
  to exercise the cached affected-node path used by the accessor adapter.

The campaigns add 800 executed operations including both implementations. They
are finite evidence, not a universal proof. The production coordinator remains
unreplaced, with its previously documented semantic holes. No store work began.

## Measurements against pinned next

Baseline: `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, unmodified.
Three alternating process pairs per unchanged synchronous workload, all worker
assertions enabled. The final measurements ran after tests completed. Ratios
below are reference time / next time; lower is faster. Small differences are
noisy, but the large update/creation deficits are unambiguous.

| Workload | Reference / next |
| --- | ---: |
| Settled signal read | 0.650 |
| Settled memo read | 0.491 |
| Write and flush | 14.962 |
| Equal write | 1.112 |
| Memo write | 9.171 |
| Ten writes in one batch | 10.825 |
| Twenty-memo chain | 10.214 |
| Diamond | 10.016 |
| Memo fan-out | 12.043 |
| Effect fan-out | 13.196 |
| Branch switch | 9.759 |
| Signal creation | 4.541 |
| Memo creation/disposal | 10.604 |

This representation still decisively fails performance acceptance. Faster
settled reads do not make it viable. There is no evidence here that these
costs are inherent to the chosen semantics; ordinary work still allocates full
reference frames, dependency maps, and update membership sets. Further research
should concentrate on sparse pending metadata and reuse of production value,
ownership, and graph storage rather than incremental tuning of this reference
representation or importing it wholesale into the runtime.

Separate unbundled CPU profiles of ordinary writes and chains place garbage
collection, frame relinking, and pending-group preparation among the largest
sampled costs. They support investigating representation/allocation costs next;
they do not isolate an inherent semantic cost. The profiled timings are not
benchmark results and are excluded from the table above. Raw profiles and a
function summary are under `profile/`.

For the restricted signal/memo/render/root/flush import scenario, minified /
Brotli bytes are **18,018 / 5,349** for the reference versus **21,188 / 7,825** for
next. Missing features prevent interpreting that as a full-runtime size win.
Production sources and bundle size are unchanged from the stage-49 status
report. Active/nested cost and retained heap were not remeasured in this stage;
the bounded-record tests are not allocation measurements.

## Artifacts and reproduction

`results/incremental-obligations-stage51/` retains the pre-change scheduler,
intermediate and final test logs, and both exploratory and final benchmark data.
Only `final-against-next/` measures the final implementation. `before.mjs` is also
the conservative semantic replay oracle; comparisons with it are not reported
as performance gains. The final source is retained as `after.mjs`.

```sh
UNIFIED=1 node --test experiments/unified-updates/reference/*.test.mjs
SCALAR_CANDIDATE_ENTRY=experiments/unified-updates/reference/scalar-runtime.mjs \
  SYNC_SAMPLES=3 node experiments/unified-updates/measure-sync.mjs \
  /tmp/solid-reference-against-next
```

The next implementation experiment must combine origin assignment before
propagation, sparse outstanding obligations, and context revalidation with the
real runtime's ordinary publication mechanism. Stage 50 demonstrates why
changing only transaction grouping or hold predicates is insufficient.
