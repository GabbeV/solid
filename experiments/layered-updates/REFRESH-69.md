# Stage 69: scalar refresh through the common publication machinery

Scalar `refresh` is now implemented and exported. This is a local experimental
checkpoint, not acceptance of the whole scalar model or expansion into stores.
The baseline remains unmodified next at
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`.

## Behavior and comparison with next

Refreshing a memo invalidates that memo. Refreshing an optimistic output
invalidates its own input computation. Both direct-accessor and callback inputs
have that separate computation; neither form invalidates a clean dependency it
reads. Default equality and `equals:false` do not change the invalidation scope.

The promise waits for the refreshed calculation's replacement if its request is
superseded. An action may receive its own staged answer before publication:

```ts
const save = action(function* () {
  const answer = yield refresh(source);
  // The DOM can still show the preceding value here.
  yield finishSaving(answer);
});
```

An outside caller waits for a foreign action's publication. Quiet refetches stay
quiet for `isPending`, including while their answer is held by the action. A
refresh does not silence a different pending question already in progress.
These ordinary timelines match the pinned next production build, including a
second equal synchronous refresh between the first waiter's read and delivery.

The accepted relative-input semantics differ from next's authoritative view:

```ts
const [first, guessFirst] = createOptimistic(() => 0);
const doubled = createMemo(() => first() * 2);
const [second, guessSecond] = createOptimistic(doubled);
```

Publish first=1 in action A, then second=10 in action B. B subsequently refreshes
second while both actions remain open:

| Observation | Pinned next | Scalar prototype |
| --- | --- | --- |
| Refresh promise | 0 | 2 |
| Display while B remains open | first=1, second=2 | first=1, second=10 |
| After B ends | first=1, second=2 | first=1, second=2 |
| After A ends | first=0, second=0 | first=0, second=0 |

The prototype follows the selected output of its relative input and the
previously accepted override lifetime. Neither version reruns the first input
callback merely because second was refreshed. The tests establish that lower
overrides have published before refreshing the upper boundary; proposing every
override simultaneously is a different held-input scenario, not evidence for
this published-input contract.

## Implementation and reevaluation

The waiter is an ordinary owned computation using existing fresh-read and
status mechanisms. It checks permission to deliver on a microtask, after the
calculation has accepted its dependencies and joined the appropriate update.
A foreign holder uses the existing stale-reader queue. Registering that wait
inside the computation, as the old helper did, can repeatedly requeue it during
the layer coordinator's pre-publication replay.

There was one additional local bug in the first implementation: invalidation
between read and delivery could strand the waiter if the replacement produced
an equal synchronous value and therefore sent no notification. The waiter now
explicitly schedules its retry in that case. No consistency assertion was
weakened to fix it.

The existing quiet-flight predicate moved from legacy verdict code to the
shared async module and is reused by both pending implementations. The boundary
registry is a separate module so an ordinary refresh import does not pull in
the optimistic coordinator. There are no new ordinary-node fields, read hooks,
transaction flags, priority rules, or alternate value graphs in this change.

This integration supports the current direction: refresh's special behavior is
confined to invalidation and promise delivery. It did not require another
exception in layer coordination. It does not establish that coordination is
complete or fast enough. Active optimism remains the principal performance
acceptance problem; another API expansion should not obscure that fact.

## Validation

- 24 scalar refresh tests cover target scope, quiet pending, real pending input,
  same-tick coalescing, equal supersession, action-local and foreign delivery,
  superseded async answers, errors/recovery including masked optimistic errors,
  owned-child replacement with equal values, disposed targets, async iterables,
  nested depths 2 and 5, and 100 repeated cycles with bounded subscriber count
  and exact cleanup counts.
- Expanded scalar-only campaign: 150 passing tests in eight files, with 100
  seeds each for pending, branching, overlap, and latest. This run preceded the
  final two refresh cases; the final refresh file passes all 24 separately.
- Full compatibility suite: 5,551 passing, 22 existing expected failures, two
  skips; three rules-index checks initially failed because moving the helper
  changed source line references. The generated index was refreshed and all
  three checks pass. The complete suite is not all exercising the new engine.
- Source declaration checking passes. The repository production build completes;
  unrelated existing test-file type warnings remain. A new fixture's accessor
  annotation warning was corrected before the final build.
- Public-API audit timelines run against both actual production entries and
  against bundles importing refresh without optimism/pending. Ordinary results
  match next. Nested differences are recorded above, not hidden as compatibility.
- This finite matrix is not a universal proof. Store refresh, all public
  options, full renderer integration, and SSR are outside this checkpoint.

## Measurements against pinned next

Results and build metadata are in `results/refresh-stage69/`. All measurements
use the real repository production build and tree-shaken application bundles.
They do not use the isolated reference runtime.

Seven alternating fresh-process pairs cover 13 ordinary synchronous workloads.
Candidate/next paired medians include reads 0.905 (signal) and 0.928 (memo),
write/flush 0.915, chains 0.910, diamonds 0.950, equal writes 1.033, memo writes
1.015, and memo fan-out 1.009. Signal creation is 0.801. These are noisy
microbenchmarks, not application-level speed guarantees.

Memo creation/disposal initially measured 1.107. An eleven-pair follow-up
measured 0.983, with broad overlapping sample ranges (next 98.9–183.6 ns,
candidate 107.7–166.2 ns). The initial 11% slowdown did not reproduce; neither
run warrants a strong improvement claim for that workload. With an unused
optimistic boundary present, the separate five-sample read/write workload also
shows no regression against next in this run.

| Import scenario | Next minified / Brotli bytes | Candidate minified / Brotli bytes |
| --- | ---: | ---: |
| Ordinary | 21,918 / 8,116 | 21,448 / 7,970 |
| Refresh | 27,892 / 10,117 | 22,135 / 8,217 |
| Optimistic | 27,250 / 9,864 | 29,974 / 10,867 |
| Optimistic + refresh | 28,322 / 10,208 | 30,652 / 11,103 |
| Pending | 28,812 / 10,419 | 31,677 / 11,373 |
| Latest | 28,715 / 10,368 | 31,232 / 11,235 |

Active optimism still misses the performance goal. With every override active,
top-only writes at depths 1/4/16 have paired ratios 2.83/2.63/2.23. At depth 16,
next takes 3.28 us and the candidate 7.34 us. Propagating a write through 16
otherwise-transparent direct-input boundaries takes 7.16 us in next versus
33.80 us in the candidate; callback inputs take 8.40 versus 36.53 us.

Sampled retained bytes per optimistic boundary are 568 versus 1,113 for direct
inputs and 556 versus 1,181 for callback inputs. The separate input computation
is an accepted prototype cost; eliminating it remains a future optimization.
The active throughput and feature bundle gaps remain unresolved acceptance
issues. No threshold has been raised, and the experiment is not merge-ready.

## Reproduction

```sh
node experiments/layered-updates/refresh-core-audit.mjs /workspace/layered-baseline/packages/signals/dist/prod/index.js
node experiments/layered-updates/refresh-core-audit.mjs /workspace/layered-solid/packages/signals/dist/scalar/index.js
node experiments/layered-updates/refresh-layer-contract.mjs /workspace/layered-solid/packages/signals/dist/scalar/index.js --nested
```

The raw logs retain the initial index failure and its successful recheck. The
checkpoint includes source hashes so these numbers need not be attributed to a
later implementation.
