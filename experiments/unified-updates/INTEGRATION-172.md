# Stage 172 — retry creators when a child discovers optimism (WIP)

The user clarified that a child discovering an optimistic context must invalidate
incompatible reads in the still-private computations which created it. Pinning the
child to its creator's earlier context is not the desired solution. This applies
to `isPending`, `latest`, and explicit optimistic outputs alike. Avoiding retries
by recording/replaying all prior reads is deferred.

This checkpoint implements the first part of that rule in the real signals core.
It is not a completed replacement of the private-frame rules from stage 171.

## Observable model

```js
const page = createMemo(() => {
  if (!visible()) return;
  const captured = id();
  return createMemo(() => [captured, id(), latest(id)])();
});
```

With committed `id = 0` and an open ordinary update proposing `1`, a newly created
page can initially capture `1`. If the child selects the optimistic context,
retrying only that child would complete `[1, 0, 1]`. The creator must also retry.
When the mount can publish independently, the accepted optimistic calculation is
`[0, 0, 1]`; the eventual ordinary result is `[1, 1, 1]`.

A different case suspends before reaching the observation. That attempt may have
already accepted its ordinary dependencies and entangled the mount with an open
action. The later context retry does not undo that accepted entanglement. The
mount remains unpublished until the action closes. The new tests distinguish
this case rather than requiring late unentanglement.

## Implementation

- Context discovery can unwind through active creating computations, across
  intervening roots. A completed but still-private creator can be queued for
  replacement. Parked published children stop that ownership walk.
- Retry is control flow, not a staged user error. Async functions turn a thrown
  retry into a rejected promise, so the coordinator also checks for the pending
  creator retry before accepting/normalizing their return value.
- Tentative joins from aborted attempts are not accepted. Existing local retry
  behavior is retained when no creator needs to unwind.
- One bit in the existing flags word records a creator retry for publication
  preparation. If its new branch returns an unchanged, childless result before
  reading optimism, preparation lets that result finish. Applying this exemption
  to arbitrary higher computations caused tearing in the seeded tests and was
  rejected.
- Retry temporarily defers automatic observation-lifecycle disposal through the
  existing dormancy queue. Otherwise replacing an owned branch could remove the
  final subscriber, dispose an unowned async input, and start its request again.
  Explicit disposal still removes `AUTO_DISPOSE` and remains immediate. No value
  cache or additional node property was added.

The existing private-read/publication mechanisms are still present. A trial
removing them and broadly skipping preparation of higher computations broke
nested/sibling publication consistency. It is archived, not retained.

## Validation and remaining failures

The new 72 cases cover three primitives, direct and memo-wrapped reads, intervening
roots, immediate and delayed discovery, synchronous memo children, render
children, and async memo children. They assert complete calculations, publication,
and exactly-once cleanup. They pass in source and the production bundle.

The retained full signals run reports **5,658 passed, 2,020 failed, 2 skipped**.
Compared with stage 171, the 72 added tests pass and **48 existing tests newly
fail**. None of those 48 assertions was changed to make this checkpoint pass:

- 42 ownership tests still assert the old private-frame behavior, identity, or
  execution timeline. These need individual migration/review; their location
  does not establish that every failure is intentional.
- Five existing held-branch/verdict cases also need timeline review.
- One existing `latest` test catches the internal creator-retry token. This is an
  observable API consequence of unwinding through application `try/catch`, not a
  staged/rendered user error. Baseline next passes both variants of that test.

The full run passes the strict seeded scalar and nested/sibling publication
oracles. Passing this finite campaign does not prove the mechanism complete.
Stores, deferred APIs, and the earlier failure inventory are not resolved here.

One existing test migration is retained: #4474's ordinary-reader variants now
observe `latest:3 pending:true` before `latest:3 pending:false`. A rebuilt
optimistic reader sees the ready answer before its ordinary publication. The
exact new timeline is asserted, along with a new assertion that no extra request
starts and the existing equivalence with an already-observed memo. All nine
variants pass. The initial duplicate-request regression and unsuccessful release
trials are preserved in the receipts.

Type checking, JavaScript builds, and production/observation purity checks pass.
The selected production public-API run passes all **103** tests (the 72 new
cases, publication/migration controls, and all nine #4474 cases). The full web
run reports **1,708 passed, 131 failed, 1 skipped**, with 12 new failures versus
stage 171: eight owned-render cases and four Loading/held-branch cases. Those
assertions remain unchanged and need review alongside the signals failures.

## Size and cost

Measured shipped scalar scenarios against unmodified next `4fe75321`:

| Imports | next minified / Brotli | experiment minified / Brotli |
| --- | ---: | ---: |
| Ordinary core | 19,825 / 7,421 | 21,427 / 8,003 |
| Scalar optimism | 30,556 / 11,180 | 36,596 / 13,192 |
| Optimism with observations | 35,643 / 12,920 | 42,642 / 15,031 |

No new throughput benchmark or performance claim is made for this WIP checkpoint.
There are no added ordinary-node fields or read journals. The flag masks change,
and automatic disposal has an additional conditional; actual throughput still
needs measurement after the remaining semantics are resolved. These size figures
remain an acceptance gap, not a successful size optimization.

## Receipts and next work

`checkpoints/integration-stage172.tar.xz` preserves the test reports, rejected
runtime trials, diagnostic traces, and bundle measurements under
`results/integration-stage172/`. `retained-new-failures.json` enumerates the 48
newly failing tests. An earlier production run of `unified-experiment.test.ts`
incorrectly mixed its internal source adapter with the built public runtime;
those failures are harness-invalid. The public-API-only production run is the
relevant check.

Next: resolve the exposed control-flow/API consequence, review the remaining
ownership and held-branch timelines without weakening consistency checks, then
remove private-frame exceptions that the completed retry protocol makes obsolete.
Do not repeat the rejected broad preparation bypass. Re-measure against next
once that implementation is stable.
