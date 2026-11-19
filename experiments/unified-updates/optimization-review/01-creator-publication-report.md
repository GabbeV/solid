# Creator retries and private publication: investigation

Source reviewed at the stage182 review baseline; no runtime changes, builds,
benchmarks, or new ablation results. Line references below are to
`packages/signals/src/layers/coordination.ts` unless another path is named.

## Finding

**No publication guard is established redundant after creator retries.** The
apparent overlap protects different transitions: retry rejects an incompatible
attempt; publication must also protect accepted but unattached proposals and
published children retained while their owner is replaced. A shared ownership
walk may shorten source, but is not presently an optimization recommendation.

## Attempt → acceptance → publication

1. Creation inherits only context actually entered by its creator (570–600).
   Deferred peer reads remain tentative (`deferJoin`, 719–729).
2. `readContext` (795–860) discovers deeper input context and asks
   `retryCreator` (750–783) to invalidate captured reads in private owners.
   An active creator unwinds; an already-completed staged creator is queued.
   Roots are transparent; a parked/ZOMBIE child stops the walk.
3. `computeLayer`/`retryCalculation` (923–1020) reject tentative joins and
   normalize only after retry control flow is handled, including async bodies
   and application catches. Retrying disposes obsolete private children.
4. `acceptCalculation` (883–920) accepts/propagates peer joins. An earlier
   accepted suspension can already entangle updates; a later retry cannot
   undo that entanglement (stage172 observable model).
5. Accepted proposals may still be unattached. `frameRead` (505–521) records
   higher-proposal consumption without merging lifetime; `canPublish`
   (1048–1062) prevents attachment until that higher output can publish.
   `orderUpdates` (1065–1075) supplies landing order, not readiness.
6. Private recalculation replaces obsolete waits (976); disposal removes waits.
   `holdsLifetime` (1027–1045) separately prevents an optimistic consequence's
   async request from extending the originating override's lifetime.

Ownership timeline that creator retries cannot replace:

- P0 is published with C0, which captured P0's inputs.
- P1 stages replacement C1; C0 is parked but still serves another update U.
- U notifies C0. Preparing P before C0 prevents captured-old/direct-new mixtures
  (`scopedCalculation`, 686–710).
- If P's preparation removes C0, defer C0 for that replacing update; another
  update may still use it (`prepareLayers`, 344; `rerunLayer`, 603–612).
- `retryCreator` intentionally stops at parked C0; rebuilding P1 does not
  repair C0's still-published captured inputs.

## Obligations that survive the retry change

| Mechanism | Independent responsibility / falsifier |
| --- | --- |
| `prepareLayers` 324–412 | Restore dependencies of published frames before lower publication; higher replacement may have dropped dependencies still displayed by the old frame. |
| `unpublishedFrame` 456–469 | Classify attachment ownership, including staged completed owners; ZOMBIE children are published history rather than new private children. |
| `frameRead` 505–521 | Preserve eager private proposal consumption and its one-way publication wait; structural readers may suspend while initial detached render initializes. |
| `scopedCalculation` 686–710 | Prepare stale published creator before an old child's incoming heap pass; stage176 captured `a` beside direct `b` is the counterexample. |
| `canPublish` 1048–1062 | Gate attachment separately from context acceptance and override lifetime; stage171 eager-without-gate trial painted new child=1 beside existing reader=0. |
| `sourceHoldsLifetime` 1039–1045 | Expiration/correction cancels obsolete private async work rather than waiting for its own consequence. Stage171 inside/outside-request cancellation controls falsify merging readiness with lifetime. |

Source observation: context discovery is invoked for computed sources in
`core/core.ts:2355`, whereas held-frame selection handles signals too
(`core/core.ts:2361`, `:2443`). Notifications can register publication obligations
in `adoptOutput` (1098–1126) without a fresh execution reaching retry discovery.
Therefore “every private higher read necessarily promoted its creator first” is
not a sufficient proof for deleting private publication checks.

## Smallest historical counterexample inspected

`results/integration-stage172/coordination.publication-trial.ts:362` skips all
held-above preparation. Its receipt `publication-dependencies.json` fails
`unified-publication-adversarial.test.ts` depth=3, seed=11: after the recorded
answer, ordinary repeated reader values are `[0,0,302,0]` while published
outputs are `[0,0,302,401]`. This falsifies the broad preparation bypass.
The trial changes several rules; it does **not** isolate `canPublish` or prove
every current private guard individually necessary. Many archived owned-frame
failures assert superseded expectations, so their counts are not correctness
proofs under today's retry semantics. Stage176's targeted JSX counterexample is
stronger evidence for retained published-owner preparation.

## Narrow replacement candidate, requiring primary review

Investigate an explicit **accepted private publication obligation**, owned only
by coordinated transaction work, rather than treating every `_reruns` entry as
both a stale published-frame replay and a private proposal-consumption wait.
Record the lower attachment update and higher publication dependency when the
private attempt is accepted; abort removes tentative obligations. Refresh on
private recalculation, transfer on merge, remove on disposal/publication.

The deletion target is `canPublish`'s repeated ancestor rediscovery over the
whole waiting-reader registry plus private-wait exceptions in preparation;
published replay preparation and lifetime checks remain independent. This is a
protocol replacement, not an extra predicate layered over the current scans.
It must replace existing private wait representation, not retain both registries
or add persistent state to ordinary nodes. Allocation, merge and invalidation
cost could exceed the scan savings; no favorable result is assumed.

Falsifier: a notification adds a wait after acceptance, ownership changes before
landing, or a merged/disposed/retried child leaves a missing/stale edge. Also
reject if explicit state needs a second unbounded cleanup traversal or delays
private construction. The unresolved question is whether acceptance is a stable
enough registration boundary; current notification paths suggest it may not be.

Minimal next experiment: in an isolated scratch runtime, first isolate deletion
of only the private `frameRead` branch / `canPublish` hook separately, preserving
lifetime logic and published-owner preparation. Run owned-context completion
orders, creator retries including delayed/async discovery, owned-adversarial,
nested/sibling publication oracles, lifetime/dependency removal, and
`web/test/owned-live-input-while-replaced.spec.tsx`. Add only the missing
notification-after-acceptance case if existing controls do not cover it. Then
prototype replacement state only if those traces identify surviving obligations.

Existing attribution: stage182 `size-scalar.json` attributes coordination to
8,962 minified bytes in optimism and 9,390 in observed optimism; it is absent
from ordinary scalar core. These are whole-module attribution, not deletion
savings. The candidate targets active coordination scans/owner walks; exact
shipped-byte and timing changes require isolated measurements after correctness.
