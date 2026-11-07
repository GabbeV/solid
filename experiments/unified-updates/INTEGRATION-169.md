# Eager private rendering with coherent inherited reads

Stage 168 repaired owned calculations that combined input 1 with latest 0, but
left the new child's first DOM binding empty until publication. This stage
finishes the first-render path. It does not make an unpublished subtree visible.

## Selection versus publication

The optimistic selector already uses `NOT_PENDING` as its inactive override:
`selectGuess` reads the input when no override is present. A sentinel does not
replace the output's published/proposed distinction. Removing an override can
start an async correction; the old output must remain published until the
correction and its ordinary consequences can publish coherently.

The defects were in consuming that selection. Stage 168 repaired ready latest
selection and owned-frame proposal reads. Its structural guard also caught
render effects, because they share CONFIG_FRAME. A ready first render prepares
private DOM; unlike later or scheduled callbacks, that calculation must not be
held merely because structural publication waits.

## Retained implementation

- Mark the first effect calculation using the existing creation scope. It may
  consume the ready observation of its creator's input. Structural computations
  and subsequent renders retain their publication guard.
- Capture the creator's inherited read flags before computing a new effect.
  Apply a ready first unscheduled render value to its private callback slot.
  Pending/error answers remain held, as do independent mounts over first answers.
  Scheduled/user callbacks and all later callbacks still wait for their holder.
- A first render also inherits proposals its creators tentatively consumed before
  their peer joins were accepted. Otherwise a newly created branch could read
  its own condition as still closed. This uses a temporary stack of references
  to existing calculation read sets, only while those creations execute. It does
  not add per-node state, cache results, or merge the creator's updates early.
  Pulling an existing computation does not inherit that creation scope.

The latter problem was exposed by enabling the first callback: five #4341 cases
had previously calculated a stale branch condition without exposing it. Their
expected values remain unchanged. All 30 variants now additionally assert every
completed calculation, not only callbacks; these stronger assertions pass in
source, mangled production, and pinned next. Initial calculation must be coherent
before its private callback is allowed to run.

## Test accounting

Six actual JSX cases cover ordinary, inline latest, and memo-wrapped latest
bindings, with both completion and cancellation. They assert initialized text
immediately after constructing the detached span; no attachment or scheduled
callback during the hold; held later writes; correct final attachment; and
cleanup when a proposed child is discarded. All six fail before this stage and
pass on pinned next 4fe75321.

Several hand-written scalar tests used an unscheduled first render callback as
an external publication monitor. Those monitors now use `schedule: true`:
composition's child map, pending's child publication log, equal-input ownership,
the L2 shell publication callback, and the #3540 boundary attachment log. Their
publication and cleanup expectations are unchanged. The owned-proposal test
separately records the private first callback and the scheduled publication,
asserting private 1 beside published input/child/owner 0. The corrected form
also passes next; its original held-first-callback assertion failed next.

The original L2 and #3540 cases passed next before this change: next delays those
particular private callbacks. The experiment now prepares that detached work
as permitted by the user's eager-construction ruling. This is an intentional
callback-timing difference, not permission for visible publication or an
inconsistent calculation. The new JSX tests verify the actual attachment seam.

## Validation

- Full signals run: **5,598 passed / 1,975 failed / two skipped**. Three failures
  were the generated rules index becoming stale after comment changes. After
  regenerating it, all three pass in the targeted 33-test calculation/index run.
  The resulting inventory is **5,601 passed / 1,972 failed / two skipped**:
  **1,953 deferred API cases and 19 non-deferred cases**. Eight old scalar
  failures are fixed; there are no newly failing behavioral cases.
- Full built web: **1,709 passed / 119 failed / one skipped**. All six new JSX
  cases pass; the previous failure set is unchanged.
- Mangled production public set: **522 passed**. The stronger #4341 calculation
  assertions also pass all 30 production cases in the follow-up run.
- Build tiers, declarations, property mangling, purity, rules-index and diff
  checks pass. The final full reports are `signals-complete` and `web-complete`;
  `validation-summary` records the index regeneration follow-up without changing
  the raw full report. Earlier reports are intermediate trials.

The 19 non-deferred failures still need work: six ordinary derived-store cases,
four fallback construction counts, two keyed-boundary counts, four duplicate
final render callbacks, two first-held latest cases, and one extra optimistic
render calculation. Their existing assertions remain. The complete classified
inventory is in the receipts.

This is a correctness checkpoint, with no measured performance or size claim.
The experiment remains incomplete; optimistic stores and until remain deferred.

Receipts: checkpoints/integration-stage169.tar.xz.
