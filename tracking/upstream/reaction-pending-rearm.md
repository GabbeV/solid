# Pending reaction arm is not replaced

Status: reported in [PR #4188](https://github.com/solidjs/solid/pull/4188), open. Source b0ad1df5 (rc.16), still the next
branch head when checked through the GitHub API on 2026-10-21. No fix or deviation
is applied to the active Bend runtime.

`createReaction` promises one currently armed subscription. Reading a pending
memo in the first track callback throws NotReadyError before the source reaches
`arm = getOwner()`. Calling track again therefore finds arm undefined and leaves
the first effect alive. Its old source resolving still fires the callback; a
later change of the currently selected signal fires it a second time.

The minimal standalone repro is
[reaction-pending-rearm.mjs](../../repros/solid-signals/reaction-pending-rearm.mjs).
With SOLID_MODULE pointing to the built pinned reference:

- pending: old result resolves -> calls 1; current signal changes -> calls 2;
  the desired [0,1] assertion fails.
- seeded: the same memo with loadingValue:0 -> [0,1], passes.
- skip-old: do not track the superseded source -> [0,1], passes.

The [JSX component](../../repros/playground/reaction-pending-rearm.tsx) uses one memo,
three common signal/reaction calls (a current field, a displayed count and the
reaction), ordinary buttons and no explicit roots, private exports, async iterator,
thenable or loading boundary. Click Arm, Finish old result, Change current field.
Expected displayed counts: 0,0,1; actual: 0,1,2. The callback uses a block so its
signal setter's numeric return does not become an invalid cleanup.

The standalone results and six Chromium cases use unchanged source. Production,
development (which requires observe), and observe each reproduce 1/2; each seeded
control displays 0/1, without page errors or console error reports. Verification:
[reaction-pending-rearm-verification.json](../../repros/playground/reaction-pending-rearm-verification.json).
Run the checked source/compiler browser harness with:

    node repros/playground/verify-reaction-pending-rearm.cjs /path/to/solid-at-b0ad1df5

## Existing ruling and fix

This is an uncovered pending case of [#2861](https://github.com/solidjs/solid/issues/2861),
which was closed as fixed. [Ryan's ruling](https://github.com/solidjs/solid/issues/2861#issuecomment-4927897101)
says re-arming before a fire replaces tracked sources, restoring 1.x semantics.
[40d13a9e](https://github.com/solidjs/solid/commit/40d13a9ef3e6f3dc2197885bb2eaec3e294b8c16)
introduced the current handle and disposal. Its assignment is after tracking;
its regression tests cover ordinary signals and re-arming from the callback,
not initial missing async reads. This is an incomplete fix of that behavior,
not a new regression caused by this Bend port or the latest repin.

Repository issue searches for createReaction+arm and createReaction+pending,
and a PR search for createReaction, found #2861 and unrelated reports, with no
separate pending-replacement report or later fix found. Searches are evidence of
what was checked, not proof that no duplicate exists.

## Bend evidence

Eight paired histories preserve exact current-source parity with and without a
loading seed, using immediate and native promise delivery and an intervening
flush control. `pending_reaction_arm_survives_replacement` explicitly proves the
observed negative program: the first handle is zero, its old arm remains live,
and callback counts become 1 and 2. `seeded_reaction_arm_is_replaced` is the
positive 0/1 control. This failure is not relabeled as successful replacement.

At the user’s request, [a hosted repro](https://s.olid.uk/id/iZOM74C9Sda3qJWUKNHJLw) is now saved,
pinned to npm 2.0.0-rc.16. Its source matches the component above; saved-share
reloads preserve 0/1/2 and a local loading-value control gives 0/0/1.
[Hosted verification](../../repros/playground/reaction-pending-rearm-hosted.json)
records this separately from the source-built b0ad1df5 checks. The playground
reports an unauthenticated /api/session 401; there are no page exceptions.
The user submitted the tested candidate as PR #4188; it is not applied to this pin. A fix needs to capture the actual arm even when tracking throws, while
checking that reentrant tracking, callback re-arming and disposal still retain
their existing order. A tested local candidate is now recorded in [the fix review](reaction-pending-rearm-fix.md), separately from the pinned runtime. An additional paired history preserves the analogous initially-throwing tracking case.
