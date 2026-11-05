# Stage 78: Loading follows the update selected by its `on` expression

The user challenged stage 77's endorsement of the pending-forwarding result and
asked about the product A -> B discussion with Ryan. Matching two implementations
of the proposed rule did not establish that its publication/lifetime policy was
desirable. The additional hold introduced by pending forwarding is reopened as
a semantic question; the green test suite is not acceptance of that policy.

## Recorded discussion

The exact product-page discussion is in
[issue #3540](https://github.com/solidjs/solid/issues/3540), especially
[the proposed frame-following semantics](https://github.com/solidjs/solid/issues/3540#issuecomment-5753222253),
[the product/comments explanation](https://github.com/solidjs/solid/issues/3540#issuecomment-5759227475),
and [the final resolution](https://github.com/solidjs/solid/issues/3540#issuecomment-5772472253).
The implementation is [PR #3575](https://github.com/solidjs/solid/pull/3575).

The final resolution agrees with the requested product-page behavior: an ordinary
`on={id()}` rearm releases the boundary's content hold immediately, but stages its
fallback into the navigating update. The shell's product fetch still holds that
update, so the reviews fallback appears with product B, not beside product A.
If reviews finish first, no fallback is ever shown.

The same resolution explicitly distinguishes `latest`, `isPending`, and optimistic
values in `on`: they publish an update ahead of the underlying navigation, and
their fallback can therefore appear beside the still-committed A page. This
distinction is in the checked-in D-15/D-17 rules and implementation tests.
The replies under Ryan's account are signed "Claude via Cursor"; #3976's later
rule consolidation is also AI-generated/coauthored. This is evidence of the
merged documented contract, not an independent new personal statement by Ryan.
No reversal of the product-page frame-following rule was found in these sources.

## Actual production timelines

`loading-navigation-audit.mjs` renders ID, product info, and a reviews boundary
through separate scheduled render effects. A -> B starts product/reviews requests
in parallel. Controlled gates settle them in either order. `data` in the mode
name means the reviews accessor, not the shell's product accessor.

With product B finishing first, pinned next publishes:

| `on` expression | Both pending | Product B ready | Both ready |
| --- | --- | --- | --- |
| `id()` | A / Reviews A | B / Loading | B / Reviews B |
| `reviews()` | A / Reviews A | B / Loading | B / Reviews B |
| `isPending(reviews)` | A / Loading | B / Loading | B / Reviews B |
| `latest(id)` | A / Loading | B / Loading | B / Reviews B |

The candidate matches next for `id()` and `reviews()`, in both completion orders.
Thus the original product-page behavior is not broken for those spellings.

For `isPending(reviews)`, the candidate publishes A / Loading immediately, just
as next does. The new difference comes later: even when product B is ready, it
continues displaying A / Loading until reviews B is ready. The pending reader
in `on` now forwards demand to reviews, retaining the ordinary navigation hold.
This additional hold is the stage-76 experimental change. The early fallback is
the older, documented meaning of using an already-published observation in `on`.
Those must not be conflated.

When reviews finish first, ordinary `id()`/`reviews()` variants keep the whole A
page until product B is ready, then publish B / Reviews B with no fallback. The
pending variants show A / Loading until both are ready in both runtimes.

An additional `latest(id)` comparison exposes a separate candidate discrepancy:
all three repeated runs per completion order withheld the fallback with A, unlike
next's early fallback. One initial product-first audit did show the early fallback;
the initial raw result is retained rather than overwritten. That variation has
not been explained, and no semantic change is claimed for it. The three forms
the user asked about (`id`, `data`, `pending`) were stable across these repetitions.

## Status

No runtime changes are made in this stage, and no new exception for Loading or
pending is implemented. Stage 77's matching explicit-optimistic tests remain
evidence about the current model, not proof of its desirability. The four updated
Loading assertions describe the experimental forwarding policy; that policy's
additional hold is again classified as unresolved pending the semantic review.
The original pending-feedback lifetime remains unresolved too.

Raw production results, three repeated runs per runtime/trigger/completion order,
and the retrieved discussion text are in `results/loading-navigation-stage78/`.
The runtime still matches stage 76's source/build hashes and measurements.

```sh
node experiments/layered-updates/loading-navigation-audit.mjs /workspace/layered-baseline/packages/signals/dist/prod/index.js id product-first
node experiments/layered-updates/loading-navigation-audit.mjs packages/signals/dist/scalar/index.js pending product-first
```
