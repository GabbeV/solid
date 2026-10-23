# Constructed action obligations reach the scheduler blocker

This follows the [constructed action/join checkpoint](transaction-joins.md),
published at 0578dded5af561d01e55796866c87ee4b7d94a56. Its exact input/log hashes
remain historical evidence for that checkpoint. The current extension changes
no runtime, host, source pin or toolchain and activates no semantic deviation.

## Checked connection

`transaction-positive.bend` proves that the actual `blocked` helper returns true
and preserves the **complete World**, including its previous judge, for every
healthy World whose selected transaction has a positive current open count.
Neither a particular arena index nor zero initial judge is assumed. The path
needs two blocker-machine steps; the public helper's existing constant budget
prefix supplies them. No graph-size or extra-fuel premise is added.

`action-blocker.bend` supplies that count from the two real allocation/opening
prefixes and actual distinct join in either direction. Initial health is explicit;
construction and joining preserve it. The true blocker result and full-World
preservation hold after arbitrary finite pair lookups/rejoins too. The count is
established by the constructors, rather than supplied to this composed theorem.

`transaction-positive-update.bend` proves that the current representative remains
an allocated slot when `done` writes its count, and that the following source
schedule preserves this updated record and health. `action-blocker-finish.bend`
then connects the existing first-completion World equation to actual `blocked`:
**either action may finish first, after any admitted finite pair lookup/rejoin
history, and the remaining obligation still blocks the group.** The judgment
preserves the complete post-completion World, including scheduling effects and
saved judge. No count, capture, resolution or traversal-room premise is supplied
beyond the constructors and explicit healthy initial state.

Five new active roots extend the earlier eighteen. These are semantic properties
of the shared Bend implementation, not a formal TS equivalence proof or an
assumption that every arbitrary World is reachable from a public application.
The callback/factory/protocol domain is unchanged from the preceding checkpoint.

## Still open

The second completion, once-only callback delivery, intervening writes/flight
settlements/disposal, global live-list/forest preservation and complete ledger
remain open. The new connection proves a positive blocker judgment before/after
the first completion. It does not assert that zero actions is enough to unblock:
rendered flights and lane/blocker rules still apply. The actual flush/publication
and held-renderer observation theorem is still missing. No eventual-host-delivery
or fairness guarantee follows from this finite safety property.

## Validation

- All four new proof modules and their update/first-completion composition pass the
  independent pinned kernel; the active composed roots are checked and sealed by
  `npm run check`.
- Existing private fixtures now also check 320 positive blocker outcomes with
  exact World preservation; 288 are paired with unchanged native Solid.
- The existing 48 native-generator/public histories also assert the native
  positive blocker while both actions, and then one action, remain outstanding.
  These observations supplement their public value/render trace comparisons;
  they are finite evidence, separate from the quantified history theorem.
- Existing blocker alignment passes 1,190 helper programs /29,700 native
  judgments across ordinary/nested/lane/flight/redirect/previous-judge states.
- Two more source mutations (ignoring action debt and omitting judge restoration)
  are rejected by the independent kernel. Configured totals are 583 =469 finite
  +114 kernel; no new full 583 sweep is claimed.

See [the validation receipt](reviews/action-blocker-validation.json). Source
next@cc3ee740 has no signals drift against our 225014bf pin. Deferred protocol PR
[#4248](https://github.com/solidjs/solid/pull/4248) remains separate from this runtime.
No new Solid bug or semantic workaround was introduced.
