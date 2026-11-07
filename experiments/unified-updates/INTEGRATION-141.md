# Observation reads select the whole calculation context

Implement the user's requested common context rule for `isPending`, `latest`,
and optimistic outputs. `untrack` suppresses subscriptions; it does not opt a
calculation out of context selection. Discovering a higher output can restart
the whole calculation before later reads or requests use mixed input versions.
Sync and promise-returning calculations use the same mechanism.

For an action holding id=1 over committed id=0:

```ts
const sample = createMemo(() => {
  revision();
  const before = id();
  const observed = untrack(() => isPending(id));
  return [before, observed, id()];
});
```

An unrelated revision during the established hold publishes `[0, true, 0]`.
Replacing the observation with `latest(id)` publishes `[0, 1, 0]`. At release,
these become `[1, false, 1]` and `[1, 1, 1]`. Callback and accessor forms agree;
an async function does not get a separate completion-replay exception.

An untracked **memo snapshot** remains distinct from a subscription. Reading a
dirty wrapper does not pull its correction. A wrapper of pending can therefore
leave the sample at `[1, true, 1]` at release; a later explicit revision samples
the published false value. No pending-specific completion subscription is added
to repair that ordinary untrack behavior. The original stage-138 scalar/JSX
controls now expect `0:true` after the independent revision, while retaining
their final untracked-wrapper snapshot assertion.

## Implementation

- Remember the depth discovered by untracked reads only during the current
  calculation attempt. Reuse ordinary coordination, retries, cancellation,
  ownership cleanup, and publication. No ordinary-node fields are added.
- Scope active calculations so selecting a new update cannot change the rest
  of the flush's context. Normal effect queues and parking remain unchanged
  unless the calculation actually forks. Existing explicit update scopes keep
  their batching behavior.
- Preserve the existing publication-preparation context. Re-entering a higher
  output on every preparation would repeatedly schedule the same reader rather
  than calculate the incoming update beside already-published outputs. This
  uses the existing explicit release phase, not a test of whether a request has
  happened to finish while dependencies are being discovered.
- A settled observation may retain a selector such as pending=false without
  retaining a live update context. Its status boundary remains intact; simply
  removing that selector broke the existing early-false behavior for equal
  answers and was rejected.
- Pending callback control flow uses ordinary value selection in the chosen
  context. Held inputs are read without adding ordinary value demand; the
  pending output supplies their wakeup. Settled branch selectors remain tracked
  so changing a selector can ask a different pending question. Preserve the
  first-answer case where no committed input exists.
- Clear the existing dev caught-read record when the runtime retries or handles
  its own NotReady throw. No new warning, error policy, or diagnostic is added.

`latest` uses this same coordination through its existing source-owned output.
Its selector, retirement, and unchanged-flight optimizations are retained.
The four callback/intermediary unchanged-flight controls and the three ordinary
optimistic cancellation controls pass in both dev and prod source configurations.

## Validation and changed failures

Full normal signals suite: **5,306 passed, 2,113 failed, two skipped**.
Stage 140 was **5,240 passed, 2,111 failed, two skipped**. There are 68 added
tests, two existing failures fixed, four newly failing existing tests, and no
missing tests. All **658 unified scalar tests pass**.

The four newly failing assertions are retained for visibility and classified as
intentional consequences of the requested rule, rather than implementation bugs:

1. Two `verdict-probe-committed-4648` cases require an async pending reader to
   run only twice. It now runs three times, including the coherent completion
   calculation; there is no async-only replay exclusion.
2. Two `superseded-transition-verdicts-3884` cases assume untracked latest reads
   inside the async producer leave publication timing unchanged. On the second
   source change, that producer now selects the latest output's context. The
   latest display retains `/slow1` until the replacement completes, then the
   pending display becomes `-`; the original shape's outside latest reaches
   `/slow2`. The earlier assumptions that these reads were inert diagnostics
   no longer apply. They still add no ordinary subscription.

The two repaired `verdict-probe-landing-4648` cases consume the hold's flight
before/after the pending probe and now land coherently under their own async hold.
This stage does not resolve or reclassify the other 2,109 existing failures.

Additional evidence:

- 64 context cases: pending/latest/optimistic outputs, callback and memo forms,
  tracked/untracked reads, both read orders, sync/async calculations, publication
  during the hold and after release.
- Four added untracked retry cases verify that no completed calculation sees
  mixed ordinary input versions, no request uses the mixed `1:10` input, and
  every owned cleanup runs exactly once. An explicit revision samples the
  already-published override because an untracked read is not notified by it.
- **51 JSX tests pass** against the built dev package: 16 new context cases,
  plus all 35 existing selected pending-sample, first-value Show/Match, and
  latest-error publication/recovery cases.
- **95 tests pass with prod source defines**, covering context selection,
  existing nested/late-discovery controls, owned retries, and cancellation.
- All signals build tiers, property mangling, purity checks, declarations,
  rules-index check, targeted formatting, and diff checks pass.

No benchmark or size comparison is claimed. Active-update scoping costs still
need measurement against next; the pure synchronous path with no coordination
installed gains no node fields or additional scope. The full web/hydration suite
was not rerun. These finite tests are not a proof for every dependency graph.

Reports, failure names, trial sources, and rejected-trial evidence are in
`checkpoints/integration-stage141.tar.xz`. Two repetitive debug logs retain a
bounded prefix/tail with an explicit truncation marker. The first scoping trial
changed effect order; the retained version preserves normal queues and removes
those regressions. The original broader API deferrals, including `until` and
optimistic stores, remain in place.
