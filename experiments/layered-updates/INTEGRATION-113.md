# Pending feedback audit and own-input lifetime question

The own-input lifetime question below is resolved in `INTEGRATION-114.md`:
follow next and retain the pending input after the last reader leaves.

Baseline remains next `4fe75321`; runtime remains stage 112. This checkpoint
adds four tests and records a rejected/pending trial, not a runtime fix.

## #4677

The four upstream tests consume badge requests FIFO. Next asks first for
`id=0,pending=true`, then for `id=1,pending=false` after its pending badge
answers. The shared engine first starts an ordinary `1,false` request, which
pending propagation cancels and replaces with `0,true`. Resolving the first
request in the upstream fixture therefore resolves cancelled work.

The live requests have two coherent timelines:

- Badge first: `0 / Item 0 / false / badge(0,false)` ->
  `0 / Item 0 / true / badge(0,true)` ->
  `1 / Item 1 / false / badge(1,false)`.
- Details first: the initial frame remains until the final badge answers,
  then all four bindings publish their final frame. The unfinished pending-true
  badge is superseded, not awaited. Next waits for and publishes that badge
  before starting its correction.

The second difference follows the accepted rule that superseding an optimistic
proposal does not wait for its obsolete downstream async work. The source-owned
pending output and its ordinary consequences stay consistent. No runtime change
was needed. `layered-pending-async-feedback.test.ts` tests both orders, with and
without an intermediate details memo, including final publication while obsolete
requests remain unanswered and their later harmless delivery. All four pass.
The four upstream FIFO tests are unchanged; their failures remain visible for
migration accounting. They are classified here as request-order assumptions and
an intentional obsolete-work lifetime difference, not new implementation bugs.

## #4690 trial and unresolved decision

Removing `observed(layer._output, update)` from `pendingScope` makes an action
retain its guessed inputs' pending flights regardless of render subscribers.
All 15 scalar cases in `optimistic-outside-reask-4690.test.ts` pass with that
change (the other 30 use the explicitly deferred optimistic store API).

A full signals run against stage 112 finds precisely two existing failures
fixed and one existing pass lost. The lost test is
`a closed action stops waiting when its last override observer is disposed`.
It expects disposal of the final override reader to release another source write
in the same action, before the guessed input answers. Running that exact public
API case against next also fails that assertion: next keeps the source write
held until the input answers. Stage 79's documentation says removing the last
observer may release this hold, so this is a semantic conflict to resolve.

The trial has been reverted pending the user's ruling. Its one-line patch and
full-suite receipt are preserved in `results/integration-stage113/` along with
both runtimes' request traces and next's disposal result. The full trial ran
with a temporary trace test present (two passing trace cases and four failures
matching the upstream FIFO assumptions); those temporary tests are removed.
Do not use that run's raw totals as a final suite result.

The retained tree's focused run passes all 13 tests across the new feedback file
and `layered-forwarded-observation.test.ts`. No shipped runtime or bundle changes,
performance claim, size claim, or upstream posting is part of this checkpoint.
