# First-publication trial rejected; deeper scalar failures exposed

## Retained change

The ordinary derived-store #4355 regression now also runs with a sibling async
consumer holding the input update open. All twelve variants pass on both the
experiment and pinned next `4fe75321`. They forbid publishing the seed before
or after the sibling finishes and retain the original exact publication history.
No runtime changes are retained in this stage.

## Rejected latest trial

Allowing `latest` to select a ready, held first proposal fixes both #4429
failures and the additional first-proposal replacement probes. Keeping initial
imperative reads on the committed side avoids the never-published optimistic
value regression from stage 127. But a derived-store reader can publish its
uninitialized seed during observation adoption.

A narrower trial skipped adoption when the input update was already ready.
That passed the original #4355 cases and an action-held variation. Adding a
sibling async consumer exposed the seed again, in both direct and memo readers.
The narrowing was rejected, not retained as a fix. The trace shows a store
producer and its property writes can occupy different update contexts after
adopting already-computed work. Store publication needs explicit integration;
a readiness condition must not hide that missing step. All trial runtime edits
were restored from exact baseline copies. The failing probes and traces are
archived, not part of the shipped implementation.

## Triage beyond the first assertion

Temporary diagnostic copies used soft assertions to continue through the rest
of each timeline. Original assertions were restored afterwards; no tests were
weakened. This distinguishes intermediate expectations from completion failures:

- #4544's observation cases remain on `0 signed out` even after the real gate
  resolves. These are not merely inherited-posture expectations. The newly
  mounted branch asks for signed-out data, and that request can keep the lower
  update open. This scalar completion failure is the next investigation.
- #4403's held-error case still recovers after both actions end, but shows the
  staged error earlier than next. Error publication timing needs classification.
- Held error recovery otherwise finishes correctly. Two tests differ only in
  calculation histories; two invoke the unchanged error fallback twice before
  recovering. The duplicate callbacks remain an open issue.
- #4166 and S46 finish at the expected final frame. Their differences are the
  mid-hold mount showing committed values instead of waiting/fallback.
- `resolve` after quiet refresh delivers the new value rather than next's stale
  value. It completes and performs exactly two requests; it is not a deadlock.
  Its semantics still need review against the accepted refresh contract.

The overall audit remains incomplete. These observations do not classify every
remaining failure as intentional or establish complete scalar correctness.
Receipts are in `results/integration-stage129/` and its checkpoint archive.
