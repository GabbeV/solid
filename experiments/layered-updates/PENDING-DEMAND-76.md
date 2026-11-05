# Stage 76: pending outputs forward observedness

The user asked to try propagating observedness through `isPending` after pointing
out that a disabled-button guard observes the pending input. This experiment
retains that change locally. It is not a green or accepted checkpoint: four
existing Loading assertions now fail, and the original feedback case is not
fixed. The two async-fallback cases with an independent outside pending reader now
require its input to remain held, as explicitly requested by the new observedness
rule. The four cases with only the boundary's own arming reader remain unchanged.

## Mechanism

Pending outputs register in the existing input-observer registry used by value
overrides. Their demand lasts while the output is observed, independently of
whether its selected boolean is true or false. The existing observation walk
decides whether a live rendered reader exists. The pending output still publishes
through its higher update; forwarding demand performs no value read or update
join. `latest` has not been changed to forward demand in this stage.

The implementation separates registry access from the value-boundary-specific
`inputStatus` gate. A shared `ObservationKind.observesInput` flag opts pending
outputs in. It adds no properties to ordinary nodes and no new per-observation
fields. Registration uses the existing map/set structure. Last-reader cleanup
must wake the coordinator after removing the demand edge; otherwise a lower
update remains parked until another event makes it reconsider readiness. A new
conditional-removal test caught that bug and the wakeup is retained.

The previous test asserting that a pending probe cannot hold its input was
renamed and changed to require the requested input hold. This is an explicit
semantic change, not a weakened consistency assertion. Six new tests cover
direct/callback guards, conditional removal and revival, stale answers after
supersession, and forty disposal cycles with subscription checks.

## Production comparisons with pinned next

Baseline: `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, tracked tree unchanged.
Each audit uses separately scheduled render bindings and a controlled request.

| While the request is unresolved | next | candidate |
| --- | --- | --- |
| Only a pending guard observes data | id=1, disabled=true | id=0, disabled=true |
| Loading rearmed by pending(data) | id=1, fallback | id=0, fallback |
| Same Loading plus an outside pending guard | id=1, fallback, disabled=true | id=0, fallback, disabled=true |

All resolve to id=1, the new content if rendered, and disabled=false if rendered.
The direct guard is the requested new behavior: input demand holds the lower
update without holding back the pending boolean.

The Loading change needs review. Its `on` computation is deliberately outside
the boundary's content in current core. Once pending reads retain demand, that
arming computation becomes an outside observer too. The fallback publishes but
does not release this additional demand. The four failing assertions cover
ordinary/optimistic input updates and direct/wrapped pending rearm conditions.
Two async-fallback cases with an independent outside pending reader were
updated to require its retained hold. That additional observer is outside the
boundary regardless of how its arming condition is treated.

These are unresolved semantic consequences (category 3), not four confirmed
implementation bugs. A possible rule is for the displayed fallback to cut demand
through its own arming condition, while an independent outside guard continues
holding its input. That would retain normal pending observation forwarding and
give Loading an explicit cut. No such new exception has been implemented.

The original feedback audit is unchanged. With a tracked pending read inside
the request producer, calculations still go `(0,false) -> (1,false) ->
(0,true) -> (1,false)`, and the pending indicator never publishes true. Demand
forwarding is not preservation of a superseded flight. This result establishes
neither that the suppressed indicator is desirable nor that special per-reader
posture is needed. The numeric pending-first variant remains coherent in the
candidate, unlike next's published count/result mismatch described in stage 75.

## Validation

- Full normal-entry run: 5,591 passed, 22 existing expected failures, two skipped,
  **four failed**, across 334 files. All four failures are in `layered-loading`.
- Unchanged upstream scalar migration: 572 passed, two existing expected
  failures, 80 failed, across 117 files/654 tests. Test statuses are identical
  to the stage-75 retained run; the unresolved failures remain unresolved.
- Focused replacement-only run, legacy lanes disabled: **53 passed in six files**,
  including new guard tests, forwarded observation, stable nested contexts,
  previous-value contexts, latest error recovery, and pending/latest publication.
- Source and focused-test typechecks pass, using the repository's existing
  `noImplicitAny: false` setting. The first standalone test check omitted this
  setting and reported pre-existing `flatten.ts` errors; the corrected command
  matches project settings.
- Real scalar Rollup build and shared property-mangling pass succeed.
- Production GC audit: five batches of 200 pending-only observers with unresolved
  requests, all disposed; zero retained captured payloads at each checkpoint in
  both next and the candidate. This checks one retention pattern, not all leaks.

## Size and ordinary synchronous performance

Application bundles use the actual production trees and the existing measurement
scripts. These are comparisons with pinned next, not a previous prototype.

| Bundle | next Brotli bytes | candidate Brotli bytes |
| --- | ---: | ---: |
| Ordinary | 8,116 | 8,072 |
| Optimistic | 9,864 | 11,142 |
| Pending | 10,419 | 11,682 |
| Latest | 10,368 | 11,581 |

Seven alternating process pairs per synchronous workload; optimism is imported
but inactive, and no pending API is used. Ratios are median paired candidate/next
elapsed time (lower is faster):

| Workload | Ratio |
| --- | ---: |
| Signal read | 0.913 |
| Memo read | 0.951 |
| Write and flush | 0.910 |
| Equal write | 0.942 |
| Memo write | 1.011 |
| Batch of ten writes | 0.903 |
| Chain | 0.947 |
| Diamond | 0.982 |
| Memo fan-out | 0.958 |
| Effect fan-out | 1.051 |
| Branch switch | 1.022 |
| Signal creation | 0.881 |
| Memo creation/disposal | 1.078 |

These microbenchmarks do not establish performance acceptance. Active/nested
optimistic throughput was not remeasured in this stage, and the feature bundles
remain larger. No limits have been raised. Pending observation registry cost is
opt-in; its active allocation/throughput has not been quantified here.

## Artifacts and reproduction

`results/compat-stage76/` contains actual published-value audits, the unchanged
suite JSON, size/metafile output, retention samples, and synchronous benchmark
samples with source-bundle hashes. `final/` records the retained sources, build
hashes, validation logs and checkpoint manifest.

```sh
# After building packages/signals/dist/scalar with scalarConfig:
node experiments/layered-updates/pending-demand-audit.mjs packages/signals/dist/scalar/index.js guard
node experiments/layered-updates/pending-demand-audit.mjs packages/signals/dist/scalar/index.js loading
node --expose-gc experiments/layered-updates/pending-demand-retention.mjs packages/signals/dist/scalar/index.js
cd packages/signals
node node_modules/vitest/vitest.mjs run --config vite.scalar76.config.ts
```

Stores and additional API expansion remain paused. The next decision is the
scope of the Loading demand cut, not a special exception for async callers of
`isPending`.
