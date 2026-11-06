# Stage 70: coordinate through ordinary propagation

The scalar experiment now transfers optimistic publication context through
ordinary value and status notifications. It no longer eagerly walks every
transitive subscriber when an override changes. The unmodified comparison is
next at `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`.

This is a local checkpoint, not scalar acceptance or permission to expand to
stores. Active optimistic throughput and feature bundle size remain open gates.

## Why this change is necessary

```ts
const [view, guess] = createOptimistic(() => 0);
const parity = createMemo(() => view() % 2);
const child = createMemo(() => {
  const value = parity();
  onCleanup(releaseChild);
  return makeChild(value);
});
```

Within an open action, publish `guess(1)`, then `guess(3)`. `parity` remains 1.
Next preserves the downstream child. The experiment's previous eager graph walk
recreated it. That was a prototype implementation bug, not an accepted semantic
difference. The new propagation stops at the unchanged memo, preserving ownership
and avoiding unnecessary downstream work.

An independent pending refetch below `parity` exposes another distinction:
ordinary next permits view=3 while the refetch still runs with parity=1, but its
optimistic lane keeps view=1 until the refetch finishes. The experiment permits
view=3 for both ordinary and optimistic writes. This is an intentional application
of the agreed common propagation model: parity's unchanged output cannot require
a new downstream answer. No consistency assertion was weakened. The production
comparison is executable in `equality-publication-audit.mjs`, with `--ordinary`
selecting the non-optimistic case.

## Mechanism and limits

- A changed output notifies its immediate readers through the existing scheduler.
  The optional layer hook assigns those readers to the output's update.
- Pending/error status notifications use the same context transfer. A settled,
  unchanged memo does not notify or acquire unrelated descendants.
- Moving an already staged proposal/status to another update must notify readers
  even when its next result compares equal. Its publication obligation changed.
- A lower notification cannot demote an existing upper calculation. The render
  reader must retain its upper preparation context as well; retaining only the
  memo's context can publish a binding ahead of its suspended consequence.
- Active optimistic boundaries and unpublished lower owned frames retain their
  existing cuts. Actual reads still select committed lower values or entangle
  same-context proposals according to the previously established rules.

Loading's internal arming computation previously returned `undefined` even when
it changed the displayed control state. Its output now increments a generation
only when it actually flips/redraws. This makes that change participate in ordinary
notification rather than depending on an eager transitive walk. Always using
`equals:false` was rejected: it duplicated fallback callbacks in existing next
compatibility tests. Sibling callback order remains unspecified.

The transfer hook has no per-node storage. Ordinary-only bundles eliminate it.
Additional retained simplifications remove a duplicate boundary registry, avoid
allocating dependency generators while discovering a boundary's position, skip
redundant transaction joins, and avoid searching the parked-update list for an
open action (which cannot already have committed).

This is still not a proof of complete correctness. Status, values, owned frames
and render queues all carry publication obligations. The new code uses the
existing mechanisms for those obligations; the targeted regressions demonstrate
why notifying only on unequal scalar values would be insufficient.

## Validation

The retained runtime passed all 329 compatibility/scalar files: 5,565 tests,
22 pre-existing expected failures, two skips. The scalar campaign with 500 seeds
for pending, branches, overlap, latest and layer timelines passed 183 tests in
10 files. Four further lower-async variants were subsequently added; all 13
focused equality/context tests pass. No runtime changed after the full/campaign
runs. Source typechecking and the production Rollup/mangling build pass.

The new regressions exercise unchanged output and owned children at ordinary,
one-layer and four-layer depths; independent refresh work below equality;
upper pending proposals followed by lower re-guesses; equal initial guesses;
both dependency-read orders; and a lower derivation that also suspends. Existing
campaigns continue to cover expiration, late mounts, errors and supersession.

Logs, source hashes, production comparisons and benchmark samples belong under
`results/coordination-stage70/final/`. Earlier `profile/`, `features/`, and
`notifications/` directories are intermediate investigations, not measurements
of this retained runtime.

## Measurements

All comparisons use production bundles of the actual core and the pinned next
checkout, in alternating fresh processes. Ratios below mean candidate time /
next time; below 1 is faster. This Node 24.19.0 container campaign is reproducible
but does not substitute for testing other engines or machines.

| Workload | Ratio to next |
| --- | ---: |
| Settled signal read | 0.943 |
| Settled memo read | 0.964 |
| Write and flush | 0.854 |
| Memo write | 0.971 |
| Synchronous chain / diamond | 0.967 / 0.983 |
| Memo fan-out | 0.958 |
| Effect fan-out, follow-up | 0.984 |
| Signal creation | 0.826 |
| Memo creation/disposal, follow-up | 0.916 |
| Changed guesses behind unchanged parity, 100 consumers | 0.733 |
| Active-stack top writes, depths 1 / 4 / 16 | 2.411 / 1.852 / 1.689 |

The 13-workload ordinary run uses seven pairs. Effect fan-out initially measured
1.113 and memo creation/disposal 1.015; the nine-pair follow-up measured 0.984 and
0.916. Both runs are retained. The ranges overlap substantially, so these results
do not establish an ordinary regression or a precise portable speedup.

The parity workload uses five pairs and verifies both the published output and
that the 100 downstream consumers do not recompute during the measured updates.
It first publishes a changed guess. Starting with an equal guess did not retain
the same setter lifetime in next and failed the output assertion; that rejected
measurement is retained separately and is not included in the timing result.

The transparent 16-boundary chain remains expensive: direct inputs take median
34.54 microseconds versus next's 7.60; callback inputs take 34.16 versus 7.68.
These are five-sample medians, not median paired ratios. Each boundary currently
has two full computations, but that accepted allocation choice does not justify
all of this throughput gap. Active-stack writes above also remain slower.

Boundary retained memory is 1,113 bytes versus next's 568 for direct inputs, and
1,155 versus 556 for callbacks, approximately the expected two-node cost. This
measurement does not show long-running bookkeeping retention; the separate
lifecycle/subscriber tests exercise that behavior.

| Import scenario | Next minified / Brotli bytes | Candidate minified / Brotli bytes |
| --- | ---: | ---: |
| ordinary | 21918 / 8116 | 21513 / 7975 |
| optimistic | 27250 / 9864 | 30147 / 10919 |
| pending | 28812 / 10419 | 31850 / 11410 |
| latest | 28715 / 10368 | 31402 / 11282 |
| refresh | 27892 / 10117 | 22200 / 8235 |
| optimistic-refresh | 28322 / 10208 | 30825 / 11140 |

The ordinary-only bundle is 1.7% smaller in Brotli; optimism is 10.7% larger.
Refresh-only is smaller because it does not retain the optimism coordinator.
Feature size remains an acceptance gap. No limits were increased.

## Reevaluation and next investigation

The change removes an independent graph walk and makes equality filtering part
of the shared mechanism. That is a reason to retain it beyond its benchmark
results. The discovered failures were violations of already agreed rules:
unchanged output recreating children, staged work losing its consumers, and
lower notifications demoting upper render preparation. They were implementation
bugs; no new exception or semantic ruling was introduced.

The split-boundary strategy remains plausible for ordinary cost and correctness,
but the active chain has not met the performance goal. The next investigation
profiles context routing and repeated parking in the actual core. It must retain
this source snapshot as a validated checkpoint, test every change against these
regressions, and compare measurements only with pinned next. Stores remain paused.
