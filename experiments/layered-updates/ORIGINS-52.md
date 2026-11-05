# Stage 52: isolated origin adapter and a publication-arbitration question

Implementation checkout: `/workspace/layered-origin`, a detached local worktree
of pinned next with the preceding production experiment copied onto it. The
main `/workspace/layered-solid` production sources remain unchanged. This new
adapter is incomplete and **not safe to promote**. No performance or size
acceptance is claimed for it.

## Implemented experiment

`experimental/origins.ts` assigns pending boundary origins before propagation
and records affected computations separately from their value-storage owner.
Only affected nodes have map entries; no ordinary node fields were added.
The adapter still uses the old coordinator for several operations, including
destructive peer merging, so it is not yet the complete reference protocol.

Computations run in their selected ordinary transaction context, but the
adapter parks their proposals after the pure phase. Callback queues belong to
that context. Merely preparing an update no longer makes an unheld staged read
mark its creator as held. Actual reads of held proposals retain their ordinary
ownership semantics. This separation restores immediate initialization of
detached children while their scheduled attachment remains held.

The nine observation-forwarding tests now pass, including same-action nested
guesses in both setter orders. All six existing real DOM scheduling/error tests
also pass. An unrelated render notification must be distinguished from the
reader's outstanding proposal obligations; otherwise the new bookkeeping
unnecessarily traps the render in its previous pending context. Direct
notification and committed-frame refresh are represented separately in this
adapter. This work exposed a missing part of the simplified reference effect
model; it is not permission to drop a memo's outstanding obligations.

The wider suite has many failures, including actual tearing in supersession
campaigns. A full attempted run did not terminate and was stopped after about
a minute; the partial log is preserved. Individual focused runs finish. This
adapter must not be described as a correctness pass merely because the initial
same-action and ownership examples now work.

## A concrete divergence between the models

`ready-lower-audit.mjs` executes the same public-API program against unmodified
next, the preceding production prototype, and the current consolidated
reference. The guessing action stays open throughout these steps:

```js
const [ordinary, setOrdinary] = createSignal(0);
const [view, guess] = createOptimistic(() => 0);
const label = createMemo(() => loadLabel(view(), ordinary()));
// Render view, ordinary, and label separately; loadLabel(0, 0) is synchronous.
// Guess view=1, suspending label(1, 0); then setOrdinary(10).
```

Represent visible output as `[view, ordinary, label]`.

| Step | next | Old production prototype | Consolidated reference |
| --- | --- | --- | --- |
| Guess 1, label unresolved | `[0,0,"0:0"]` | `[0,0,"0:0"]` | `[0,0,"0:0"]` |
| Ordinary write 10 | `[0,10,"0:0"]` | `[0,0,"0:0"]` | `[0,0,"0:0"]` |
| Old label answers 1:0 | `[0,10,"0:0"]` | `[0,0,"0:0"]` | `[1,0,"1:0"]` |
| Combined label answers 1:10 | `[1,10,"1:10"]` | `[1,10,"1:10"]` | `[1,10,"1:10"]` |

Next and the old production prototype start label(1,10) at the ordinary write.
The consolidated reference waits until label(1,0) publishes before starting
label(1,10). Next's early ordinary=10 publication is inconsistent with label's
ordinary=0 consequence and is not a permissible alternative for this experiment.
The two coherent alternatives concern arbitration, not permission to tear:

- Immediately supersede label(1,0), prepare label(1,10), and hold both source
  proposals until that combined answer is ready. This avoids serial work, but
  can delay the optimistic proposal if the combined calculation is slower.
- Preserve the optimistic calculation, publish `[1,0,"1:0"]` when it answers,
  then prepare and publish `[1,10,"1:10"]`. This retains independent optimistic
  progress, but may delay the final result even when the combined request would
  have completed quickly.

Earlier `publication-probe.test.mjs` tests and the current production
`layered-composition.test.ts` expect immediate combined preparation. The
consolidated `scheduler.test.mjs` explicitly tests the sequential behavior in
its "lower update starting after its child" case. These are not equivalent
oracles. The generic historical `SharedFrame` test explicitly calls combined
preparation an arbitration choice, rather than proving the scheduler should
choose it. This divergence must be resolved explicitly before using either
model to classify the production port's failures.

Recommendation presented to the user: immediately prepare the combined result
when the ordinary input proposal is ready, holding it coherently with the
optimistic proposal. Join proposal publication, not the guessing action's open
lifetime. **Accepted by the user; implemented in the reference in
[stage 53](COMBINED-53.md).** The isolated production adapter is unchanged.

## Artifacts

`results/origin-ledger-stage52/` retains the focused and wider logs, three actual
audit traces, and a source/test checkpoint. `checkpoint/` contains the changed
core and experiment files; the full working adapter remains in the isolated
worktree. The active main reference model has not been changed to select either
arbitration policy in this stage.

```sh
node experiments/layered-updates/ready-lower-audit.mjs \
  /workspace/layered-baseline/packages/signals/dist/prod/index.js
node experiments/layered-updates/ready-lower-audit.mjs \
  /workspace/layered-solid/packages/signals/dist/scalar/index.js
node experiments/layered-updates/ready-lower-audit.mjs \
  /workspace/layered-solid/experiments/layered-updates/reference/scalar-runtime.mjs
```

Focused isolated checks, from `/workspace/layered-origin/packages/signals`:

```sh
node node_modules/vitest/vitest.mjs run tests/layered-forwarded-observation.test.ts
node node_modules/vitest/vitest.mjs run tests/layered-render-scheduling.test.ts
```
