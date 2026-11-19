# Synchronous reduction and optimistic contexts

This is a diagnostic follow-up to stage 72, with no runtime changes or new
performance claims. User asks whether preserving memo-as-reducer behavior is
possible or desirable, particularly for ordinary values while optimism exists.

`reducer-context-audit.mjs` runs against the actual production entry points of
pinned next (`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`) and the stage-72 candidate.
Raw outputs are in `results/reducer-stage73/{next,candidate}.json`. It uses
controlled action gates to process delta=1 and then delta=2 separately, with an
assertion that the synchronous reducer calculated 0, 1, 3 before optimism starts.
It records render callbacks and calculation arguments through action completion.

## Behavior that already works in both runtimes

```ts
const [delta, setDelta] = createSignal(0);
const sum = createMemo<number>((previous = 0) => previous + delta());
const [preview, guess] = createOptimistic(() => 0);
const display = createMemo(() => sum() + preview());
```

After separately processed +1 and +2 within an open ordinary action, sum has a
held result of 3 while its committed output remains 0. Guessing 10 publishes
display=10, with sum=0. Ending the ordinary action publishes sum=3 and display=13.
Ending the guessing action publishes display=3. The reducer never recalculates
for the optimistic guess or its removal, and retains its held 3 throughout.

A separate case puts an asynchronous memo below the synchronous reducer.
The reducer still calculates 0, 1, 3. Ending the action alone publishes nothing;
resolving the downstream gate publishes the coherent delta=2, sum=3, settled=3.
Superseding downstream asynchronous work does not itself discard the upstream
synchronous accumulator. This case does not combine the async tail with optimism.

These are finite timeline checks, not proof of general reducer guarantees. Signal
writes coalesced before evaluation, equal writes, unobserved computations, refresh,
dynamic dependencies, and context retries require distinct considerations. A
guarantee about every setter call would exceed a guarantee about accepted memo
calculations. Synchronous completion does not by itself exclude context retries.

## Mixing reduction and optimism

Changing the reducer itself to `previous + delta() + preview()` means optimism
reruns the accumulator. Both runtimes inherit the held 3 into that execution.
The candidate publishes 13 while delta remains committed at 0. Next calculates
15 using proposed delta=2, then retries with delta=0 and previous=15, publishing
25. Both expose held lower history; next also accumulates a retried calculation.
Action completion and override removal cause additional accumulation without new
delta writes. The existing behavior is therefore not exactly-once event reduction.

Starting the upper calculation from committed previous=0 would avoid that implicit
exposure, but cannot alone preserve the lower accumulator. Retaining histories
could protect the lower 3; a complete contract must additionally define which
history each subsequent execution advances, when a retained result can be reused,
and how publication, retries, and override removal affect those histories.
An arbitrary reducer cannot be rebased by arithmetic subtraction. Automatically
reducing only ordinary inputs would require defining and maintaining a separate
lower execution when the function also reads optimistic inputs; it is not implied
by passing a different previous argument.

Recommendation for further investigation: preserve reduction within one
coordinated context and composition with downstream optimism. Do not make an
exactly-once event guarantee for a generic context-switching memo or add duplicate
execution machinery just to approximate one. Still choose an explicit, coherent
cross-context previous-value rule; lack of an event guarantee does not justify
leaking held proposals. This is a recommendation, not an accepted user ruling or
an implemented behavior change.

## Direct optimistic input, with each guess published

Follow-up `optimistic-reducer-audit.mjs` checks a reducer whose only dependency is
`value` from `createOptimistic(source)`: `sum = previous + value()`. Both production
runtimes agree. Starting at 0, publishing guess 1 gives sum=1; publishing guess 2
gives sum=3. Ending the action with no source answer restores value=0 but leaves
sum=3. A matching source answer 2 leaves sum=3 without a further reducer call.
A differing answer 5 gives sum=8. Raw records are
`results/reducer-stage73/optimistic-{next,candidate}.json`.

This qualifies the discussion of context switching: reading an optimistic input
does not itself make reduction incoherent. Published optimistic outputs can become
ordinary committed history for a downstream stateful memo. Removing an override
does not undo that history. Using committed previous when crossing contexts would
not change these particular results, since each prior accumulation has published.
The unresolved isolation problem concerns inheriting *unpublished* history from
another context, not all history originating in optimism. A promise to aggregate
only source answers would require a different contract; neither current runtime
provides it through the optimistic output accessor.

## React and Octane comparison

`react-octane-reducer-audit.mjs` executes React 19.3.1 with its matching test
renderer and Octane 0.16.6 with jsdom 25.0.1. Dependencies were installed separately
at `/tmp/solid-reducer-comparison`; no Solid package or lockfile changed. Run with
that dependency directory as the argument. React's test renderer reports its
existing deprecation warning. Results are recorded in
`results/reducer-stage73/react-octane.json`; the script asserts every shown pair.

Both cases use base=5 and two separately published optimistic dispatches, 1 and
2, whose asynchronous transitions remain open until a shared gate resolves.

- Replacement optimism followed by an independent accumulator displays
  value/sum = 5/5, 1/6, 2/8, 5/13 in both runtimes. React uses conditional
  render-phase state updates when the input changes; Octane uses `useLinkedState`
  with `previous.value + input`. Neither uses mutable refs inside memo callbacks.
- Accumulation within `useOptimistic(5, (sum, delta) => sum + delta)` displays
  5, 6, 8, 5. Here the reducer folds temporary dispatched actions over base state;
  expiration removes actions rather than feeding a revert value as another action.

Thus downstream committed accumulation surviving rollback is not unique to Solid.
The optimistic reducer case is a different graph/contract, not evidence that
React or Octane automatically roll back arbitrary downstream history.

Source inspection additionally found that Octane's native `derived$` callback
receives a context with `signal`/`read`, not a Solid-style previous result;
`useLinkedState` is the explicit analogous stateful reconciliation API. Its
contract names previously published source/value, and its aborted-Suspense test
checks that a later reconciliation receives the old committed state rather than
the aborted draft. This is relevant evidence for the unresolved cross-context
previous-value rule, but the executable comparison above tests fully published
steps, not that unresolved held-update scenario.

References:
- https://react.dev/reference/react/useOptimistic
- https://github.com/octanejs/octane/blob/main/packages/octane/src/runtime/actions.ts
- https://github.com/octanejs/octane/blob/main/packages/octane/src/runtime/hooks.ts
- https://github.com/octanejs/octane/blob/main/packages/octane/tests/linked-state.test.ts
- https://github.com/octanejs/octane/blob/main/packages/octane/src/signals/types.ts

## Superseded work that never publishes

`superseded-reducer-audit.mjs` runs the scalar timeline against both production
runtimes. Base=5 initially publishes sum=5. Guess=1 calculates sum=6, but async
work holds publication. Guess=2 supersedes it and can complete synchronously.
The stale gate then resolves; finally the action ends and the output reverts to 5.
Raw observations are `results/reducer-stage73/superseded-{next,candidate}.json`.

Both Solid runtimes behave alike:

- Async below the synchronous accumulator: the accumulator retains its staged
  result 6. Guess=2 calculates 6+2=8 and publishes it. The stale completion changes
  nothing. Reversion calculates 8+5=13.
- Async in the accumulator itself, returning a pending promise for 6: no result
  6 is available to use as previous. Guess=2 calculates 5+2=7. The stale completion
  changes nothing. Reversion calculates 7+5=12.

`react-octane-reducer-audit.mjs <dependency-root> --suspend` puts a suspending
child below the derived-state accumulator, within a Suspense boundary that
already mounted successfully at 5. It asserts a real suspended attempt occurred.
Both React and Octane display fallback for guess=1, then value/sum=2/7, then 5/12
on reversion. A late completion of the superseded child changes nothing. These
frameworks discard the uncommitted reconciliation rather than feeding 6 into the
next reconciliation. The fallback versus retained-content presentation differs
from the scalar Solid setup; no runtime publishes the held value/sum=1/6 pair.

The same suspended-child check on an explicit `useOptimistic` additive reducer
still produces 8 for the second dispatch in React and Octane, and 5 on expiration.
The first dispatched action remains in the queue even though the render that
showed its isolated result was superseded. Render cancellation does not erase a
still-live explicitly dispatched action. This differs from a memo recalculation.

This broadens the earlier question: even within the same coordinated update,
completed-but-unpublished synchronous calculations can become accumulator history
in Solid. A committed-only previous contract would remove that behavior, including
some ordinary synchronous signal-as-event reduction demonstrated above. Thus
cross-context isolation and whether same-context staged results count as history
are distinct choices. Neither has been silently changed by this audit. The 8
result is evidence of calculation-history semantics, not by itself observable
tearing or proof of an implementation defect. A general rule that all speculative
history is forbidden would overstate the already accepted semantics.

## Evidence of design intent

The repository/history and public issue search found evidence that using an
uncommitted previous computation is deliberate, but no explicit ruling on the
exact optimistic supersession/async-placement comparison above.

- Solid's createMemo reference says the callback receives "the value returned
  from the previous execution", not the previous DOM publication. This supports
  stateful computation in general; it does not specify cancellation details.
  https://docs.solidjs.com/reference/basic-reactivity/create-memo
- Ryan's 2021-11-01 commit `f27793e698f54f54d36f8f1084ab632e160d1be8`, "better
  transition protection, fix #703 missing href", explicitly changes
  `runComputation(node, node.value, time)` to select `node.tValue` while a running
  transition owns the node. That selection survives in v1.9.9. It is direct
  evidence of a deliberate implementation choice to continue transition-local
  history, not a newly introduced 2.0 staging accident. No accompanying prose or
  test in that commit specifies the reducer example under cancellation.
  https://github.com/solidjs/solid/commit/f27793e698f54f54d36f8f1084ab632e160d1be8
- The 2.0 WIP commit `e5692ed3` (2025-11-19) already chooses pending result before
  committed result. `3bad9c288` (2026-01-27, "refactor wip, graph propagation")
  preserves that for ordinary computations while removing an optimistic-specific
  exception. Neither commit message explains the accumulator contract.
- A34 and #3733/#3742 explicitly require a writable derived computation to
  receive a staged manual write as previous even across a hold. This is related
  deliberate support for uncommitted state, but a manual proposal is not the same
  as a superseded derived result. The public explanation under Ryan's account is
  labeled "Claude via Cursor", so it is implementation/ruling evidence, not a
  direct human quote about our case.
  https://github.com/solidjs/solid/issues/3733#issuecomment-5941268083
- #3955 / #3977 protects previous from receiving the NOT_PENDING sentinel after
  an equal verdict-lane pass. Its tests keep the previous value equal to [] and
  cannot distinguish committed-history from completed-calculation history.
  The closure comment under Ryan's account is explicitly generated by Claude.
  https://github.com/solidjs/solid/issues/3955

Assessment: intentional previous-result/transition-history mechanism with
longstanding precedent; exact optimistic cancellation consequences not located
as an explicit decision. Do not label the entire behavior incidental, or claim
Ryan has consciously chosen 8 over 7 in the new audit. Local design documents,
commit diffs, and targeted public issue/comments searches were inspected; Discord
discussion was not available and absence of a found ruling is not proof of none.

## Risks beyond additive accumulation

`previous-risks-audit.mjs` checks three further real-core timelines. Both next and
the candidate agree; raw results are `results/reducer-stage73/previous-risks-*.json`.
No runtime implementation changes were made.

- Trend reporting: a memo returns `{ input, direction }`, comparing input to
  `previous.input`. Committed input is 5. Guess 1 computes a new record, held by a
  downstream promise. Guess 2 supersedes it. The displayed value moves from 5 to
  2 while direction says "up", because the calculation compares 2 to the unseen
  1. This is consistent calculation history, but not displayed-value history.
- Object reuse: a memo returns previous if `previous.input === input`, otherwise
  a fresh record. Committed input 5 owns object 1. Held guess 1 creates object 2.
  Guess 5 supersedes it and publishes object 3, despite input 5 being the only
  published input. Diagnostic allocation IDs identify references, not an input
  dependency. This demonstrates identity churn beyond explicit reducers. A
  consumer keyed on object identity may consequently recreate its content; this
  audit observes references, not a renderer-specific remount.
- A stateless `input * 2` control publishes 10 then 4. It neither preserves hidden
  numeric history nor depends on which previous argument the runtime supplies.

These results do not make same-context staged history intrinsically inconsistent.
They do show that the tradeoff is broader than summing events: comparison with the
last shown value, retaining a last-good result, and identity-based reuse can depend
on the contract. Choosing a different previous argument alone cannot change the
result of a deterministic callback that ignores it; changes to scheduling or
publication made alongside that choice would need separate validation.

Assessment for the experiment: keeping existing same-context history is a
defensible compatibility candidate, not a free compatibility win. Keep it distinct
from crossing into another context's uncommitted history, and from guaranteeing
that every setter call is delivered. Supporting both fully isolated contexts and
retention of all reducer history must not silently introduce per-context replay
or duplicate graphs. No new user ruling is assumed here.
