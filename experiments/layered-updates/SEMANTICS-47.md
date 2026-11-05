# Stage 47: pending input contexts and an unresolved input-lifetime question

The new coordinator has not been ported into the runtime. This checkpoint fixes
one reference-model error and one runtime boundary-lifetime error, then isolates
a semantic difference that needs a ruling before the reference's readiness and
lifetime rules are changed further. Stores remain paused.

## A boundary must account for its pending input context

The reference's layer calculation used committed input dependencies. That avoids
letting a speculative branch choose the context that decides that same branch,
but it was insufficient to position an active optimistic boundary.

The new regression starts with `a = 1` already revealed, `b` optimistic over `a`,
and an ordinary input memo initially taking a branch that does not read `b`:

```js
const input = createMemo(() => chooseB() ? b() : 0);
const [c, guessC] = createOptimistic(input);
const doubled = createMemo(() => c() * 2);
const pair = createMemo(() => c() + b());
```

A proposal of `b = 2` is held by an independently rendered async consequence.
Then `chooseB = true` discovers that pending deeper proposal, and `c` proposes
10. In the reference's explicit-lifetime test, the old rule left `c = 0` behind
the pending input. The corrected rule permits `b = 1, input = 0, c = 10,
doubled = 20, pair = 11`. Once the lower work finishes, the values become
`b = 2, input = 2, c = 10, doubled = 20, pair = 12`.

The boundary's input position now includes the contexts of its pending input
work, as well as its committed dependency structure. An override is above that
position; a correction belongs to that position. Inactive graph wrappers remain
transparent. Ordinary memo dependency traversal still uses committed structure.

Both dependency traversal orders pass. Eight additional campaigns exercise 960
operations over five boundaries, changing input branches, sibling combinations,
async answers, supersession and expiration. Four campaigns also include a shared
pending output and its async label. Every recorded publication checks the
ordinary input selections, sums and labels; all updates drain. Layer positions
remain bounded in these tests. These finite campaigns do not prove convergence
or that numeric positions suffice for every graph.

## A ready proposal can predate the guessing action

The accessor/action version of the conditional-input example exposed a separate
runtime bug. A ready input proposal already held by another update could escape
while the child guessing action remained open. The previous implementation
noticed later answers using an input evaluation timestamp, but that timestamp
did not establish whether the action had adopted an already-existing hold.

The action-lifetime guess now adopts an already-held **ready** input proposal.
Its output proposal remains separate and can publish ahead of that input. This
applies the previously accepted lifetime rule; it does not rebase the guess.
Two production tests cover matching and differing guesses, including release of
the parent optimistic proposal when the child action ends while the parent's
action remains open.

The scalar adapter, the baseline next checkout, and the runtime were executed
with the same action timeline. The runtime and reference now retain the lower
proposal until the child ends in this ready-input case. Baseline next has other
observable differences, including intermediate inconsistent derived bindings;
those are evidence, not compatibility requirements.

## Unresolved: an input calculation with no answer yet

Blindly adopting every held input, including unresolved calculations, failed an
existing nested pending test. It prevented the first override from publishing
when a second override hid its pending downstream calculation. The runtime fix
is restricted to ready proposals and preserves that existing behavior.

The smaller reproduced program is:

```js
const [first, guessFirst] = createOptimistic(() => 0);
const middle = createMemo(() => first() === 0 ? 0 : middleResult);
const [second, guessSecond] = createOptimistic(middle);

createRenderEffect(first, showFirst);
createRenderEffect(second, showSecond);
```

`middleResult` is unresolved. An action guesses first=1 and stays open. A second
action then guesses second=3 and stays open. Nobody renders `middle` directly.

At that point:

- Baseline next publishes first=1, second=3.
- The current runtime publishes first=1, second=3.
- The reference retains first=0, second=3.

The reference both couples pending input work to the child's action and treats
the unresolved input calculation as a remaining publication obligation. Merely
changing one coupling condition may therefore be insufficient: readiness must
also account for the calculation being hidden behind the active boundary.
If its upstream inputs publish before it answers, a future ordinary reader
must not be served an obsolete result as though it were still a valid committed
frame. The production core has `CONFIG_INPUTS_PUBLISHED` machinery for this
distinction; the reference's all-affected-node readiness rule has not modeled
it faithfully yet. Ownership and late readers will need tests for that change.

This question is distinct from the existing ruling about ready incoming answers.
When `middleResult` later answers 2, baseline next replaces the second override
with 2 immediately. The runtime instead retains 3 until the second action ends,
as previously agreed. Asking about the earlier unresolved stage does not propose
reversing that decision.

Recommendation for the unresolved stage: allow first=1, second=3, since the
explicit boundary hides the unresolved calculation and there is no ordinary
consumer requiring its answer. This recommendation is awaiting confirmation;
the reference has not been changed to implement it.

## Evidence and validation

Artifacts are under `results/relative-input-stage47/`:

- `before.mjs`, `before-tests.log`: previous reference and failing new example.
- `reference-tests.log`: 138 passes, of which 89 exercise the consolidated
  model and 49 remain historical tests of earlier models.
- `runtime-before.log`: the two failing ready-input runtime tests before the fix.
- `runtime-scalar-tests.log`: 281 passes and two existing expected failures.
- `runtime-tests.log`: 5,454 passes across 322 files; existing 22 expected
  failures and two skips unchanged.
- `baseline-actions.json`, `runtime-actions-after.json`, `model-actions.json`:
  the conditional-input action timeline.
- `baseline-unanswered.json`, `runtime-unanswered.json`, `model-unanswered.json`:
  the smaller unanswered-input timeline above.

The scalar build passes. The test-inclusive type check retains the same 26
normalized diagnostics as stage 46. Performance and size acceptance have not
been re-established: the reference representation still fails its performance
gate, and the runtime feature-size deficit from stage 46 is still open. No
ordinary signal/memo hot-path changes were made in this checkpoint.

Reproduce the audit from the checkout root:

```sh
node experiments/layered-updates/unanswered-input-audit.mjs \
  /workspace/layered-baseline/packages/signals/dist/prod/index.js
node experiments/layered-updates/unanswered-input-audit.mjs \
  /workspace/layered-solid/packages/signals/dist/scalar/index.js
node experiments/layered-updates/unanswered-input-audit.mjs \
  /workspace/layered-solid/experiments/layered-updates/reference/scalar-runtime.mjs
```
