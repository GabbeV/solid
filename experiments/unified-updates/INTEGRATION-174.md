# Stage 174 — review creator-retry failures and skip removed children

This checkpoint resolves 41 of the 66 non-deferred signals failures identified
at stage 173: 39 assertion migrations following the accepted creator-retry rule,
and two cases with an actual mixed-context calculation fixed in the runtime.
Six corresponding JSX mount failures are migrated. This is not completion of
the scalar audit.

## Creator retries and retained consistency assertions

A child discovering optimism can retry the creator against committed inputs.
The accepted output can therefore be a new object or DOM node even if its text
matches the old frame. An independent mount can also publish that coherent old
input while the lower actions remain open. The reviewed tests now require those
specific outcomes instead of identity preservation or an unpublished mount.

- The 32 render/repeated-latest/peer-input cases retain their complete-calculation
  consistency checks. The identity tests now assert replacement and cleanup of
  the replaced frame, plus exactly-once cleanup of every created frame.
- Six first-value cases retry the creator to committed `mount=false`, dropping
  the speculative child before it completes. They assert no completed child at
  that point and retain their later publication assertions.
- The 50-cycle subscriber test now expects no live speculative child and only
  the persistent subscriber between proposals. It asserts 50 discarded frames
  plus the final committed frame, and complete disposal without subscribers.
- Six JSX cases now assert the coherent early mounted values, including both
  completion orders. The captured/direct/latest consistency checks remain; the
  tentative-latest JSX check now also verifies captured equals direct.

These are consequences of the user's creator-retry ruling, not permission for
mixed values, weaker cleanup, or arbitrary callback timing. Other identity and
timing failures remain unchanged where their meaning has not been resolved.

## Runtime bug: preparing a child that the update removes

The two parked-child tests initially failed on identity. After migrating that
assertion, their later consistency checks exposed completed calculations
`[captured generation 1, generation() 2, guess 1]` (or generation 3 after
supersession). Publication preparation recomputed a child from the old parked
frame after the same update had already prepared its owner's replacement.

The repair skips that child when the existing `removalStagedBy(child, update)`
check says this update disposes it. Other updates can still use the parked
frame. This matches the existing rule used by observation/lifetime accounting;
there is no new node field, collection, or ordinary-read check.

A trial prioritizing queued creators over their children did not fix the bug:
the creator had already run. That trial is archived and not retained.

Eight added regression cases cover synchronous/async child calculations,
intervening roots, and superseding writes. They verify complete request inputs,
published values, correction after the guess expires, and exactly-once cleanup.
All eight pass with the guard and all eight fail with the mixed values when the
guard is removed. The first draft run lacked the initial explicit flush
used by the surrounding scalar tests; retained tests establish the initial
published state before starting either action.

## Validation and remaining failures

- Full signals, before adding the eight regression cases: **5,720 passed,
  1,978 failed, 2 skipped**. No new failure identities, 41 resolved.
- The eight additional source regression cases all pass.
- Full web: **1,714 passed, 125 failed, 1 skipped**. No new failure identities,
  six resolved.
- Selected mangled-production ownership/retry tests: **132 passed**.
- Builds, types, production/observation purity and diff checks pass.

The remaining signals failures comprise 1,860 optimistic-store cases, 93 until
cases, and **25 non-deferred cases**. Those 25 are the earlier 19 cases, five
held-branch/observation cases, and one first-value async-child case. The web
inventory retains 115 deferred cases and **10 requiring review or repair**.

Two observations guide the next work:

1. The #4010 held-branch case publishes `x=1` in a sibling while the old branch's
   binding still displays `x=0`. A direct equality assertion now documents this
   mismatch before the existing full-screen assertion. This is an implementation
   bug, not an identity migration. It predates this checkpoint's removal guard.
2. In the first-value case where mounting finishes before the optimistic data
   resolves, reading the pending derived data makes the child's later async work
   hold that data's publication. The existing independent-publication assertion
   remains failing; its coordination/lifetime explanation is not yet resolved.

No remaining assertion is waived by those observations.

## Size and cost

Shipped scalar scenarios against unmodified next `4fe75321`:

| Imports                    | next minified / Brotli | experiment minified / Brotli |
| -------------------------- | ---------------------: | ---------------------------: |
| Ordinary core              |         19,825 / 7,421 |               21,429 / 8,035 |
| Scalar optimism            |        30,556 / 11,180 |              36,658 / 13,244 |
| Optimism with observations |        35,643 / 12,920 |              42,752 / 15,095 |

No fresh throughput claim is made. The added guard operates in publication
preparation and only checks removal ownership for parked children. Size and
performance acceptance remain open.

## Receipts

`checkpoints/integration-stage174.tar.xz` preserves full and focused reports,
identity comparisons, the 25-case inventory, diagnostic traces, rejected creator
ordering, the guard-removal control, builds, and size measurements. Diagnostics
using soft assertions were temporary; no soft assertion remains in the retained
tests. Full-run commands are the normal Vitest commands recorded at stage 173;
production uses the archived alias config with the six ownership/retry test
files listed in `production-retained.json`. The production config is removed
from the worktree after validation.
