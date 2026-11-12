# Store completion decisions — 2026-11-12

The user authorized implementation of setter-read entanglement and the simple
array policy, then continuing to complete stores without `until`. Further
semantic choices should be reasonable and recorded here for review. This is
an implementation log, not a claim that the store milestone is complete.

## Explicitly approved rules

- A setter consuming another action's active override joins both action
  lifetimes; internal cloning does not count as reading the draft.
- Independent writes to existing array indices keep independent lifetimes.
- Index writes carry minimum length requirements, retained even when that
  action later deletes the element. Separate implicit growth is independent.
- A setter reading optimistic length joins the owner supplying that maximum.
  Owners requiring the same maximum through index writes already overlap on
  the same index; there is no separate tie-provenance mechanism.
- An effective explicit resize coordinates existing and subsequent edits on
  that array. `push`'s final unchanged length assignment is not a resize.
- `deep` itself does not merge otherwise independent action lifetimes.

## Choices for review

1. **Structural reads count as reads.** A setter branching on `key in draft`
   or `Object.keys(draft)` consumes the corresponding optimistic presence or
   key-set edits. Those owners join its action just as a read of a value does.
2. **Distinct added object keys can retire independently.** The interim flat
   implementation used one guessed container frame, making additions share
   a lifetime even without a user read. Per-key structure removes that artifact.
   The regression now checks `['a','b'] -> ['b'] -> []` as A then B finish.
3. **Whole-array replacement with a different length is an explicit resize.**
   Returned replacements skip mutation traps; the changed root length must
   still coordinate structure. This does not make same-length index changes
   whole-array writes.

4. **Setter exceptions keep prior draft work, matching next.** The temporary
   flat-only engine validated an isolated replacement before submitting anything.
   The normal store setter notifies draft writes from `finally`, even when the
   callback throws. A non-configurable `defineProperty` rejects under proxy
   invariants, but its preceding/attempted draft writes can still publish while
   the action is open. Verified directly against next bcef1041; tests now exercise
   this inside a held action, not a vacuous ambient write which expires at flush.
   Configurable getters/setters and read-only data descriptors are supported.

## Current evidence

The focused shared-core and store-array tests pass 17/17 at the first array
integration check. They exercise real action ownership, separate render
bindings, async holds, late mounts, and repeated mount/disposal cycles.
These are not a full-suite result. Chained/derived stores and descriptor
payloads remain under integration, with the old temporary constructor rejection
assertions still to migrate into positive supported-behavior tests.


## Expanded checkpoint

- 70 focused tests pass across shared store publication, ownership, reclamation,
  descriptors, nested arrays, and chained stores.
- 967 array/list tests pass, including the 900-case mutation matrix. Its last
  44 failures were missing mapArray dependencies on selected index outputs;
  those subscriptions now use the ordinary graph without container ownership.
- Source TypeScript checking passes.
- The full diagnostic run captured while sources changed is evidence for failure
  discovery only (7,218 pass / 583 fail / 2 skip), not an acceptance claim.
- No changes to `until`; derived pending and keyed cases remain in progress.


## Derived/keyed checkpoint review

The frozen `1e1b1e07a` checkout, after building its artifacts, ran 7,808 tests:
7,521 passed, 285 failed, 2 skipped. Source/helper inspection identified 138
failures dependent on deferred `until`; 147 were still actionable or required
semantic review. Counts include diagnostics and the artifact runner argument
limit, not just observable runtime failures.

The next checkpoint implements direct-property pending-input ownership, keyed
pairing for draft-mutating producer answers, and descriptor readers tracking their
selected shape. Attribution labels now follow the store output. The artifact
runner feeds bundled code through stdin rather than exceeding the OS argument
limit; this changes no bundle-size acceptance threshold.

Accepted test migrations apply existing rulings: `latest` reads the selected
output; incoming producer answers can update unguessed indices while a different
index override remains; `deep` does not extend action ownership. Both per-key
and snapshot/deep channels must agree. A posture fixture now fulfills the actual
additional downstream request before asserting publication. Its expected visible
values and earlier holding assertions are unchanged.

Three upstream store tests that used `until` to keep actions open have controlled
gate counterparts. Their automatic-acknowledgement versions remain executable,
explicitly deferred tests in `store/deferred-optimistic-until.test.ts`.

**Rejected migration:** a same-key echo must not mutate fields inside a still
selected whole-row guess. `push({pending:true})`, setting that field in a second
statement, and an equal redundant assignment expose the distinction. Next keeps
all three guesses until settlement; the experiment currently corrects two early.
The tempting Saved/pending-false expectation changes were withdrawn. Added
regressions intentionally fail until a whole-row boundary preserves that value
without joining the input's lifetime to the guessing action.

**Unfinished:** derived store pending/error propagation, late-created and nested
outputs, guesses before the first input answer, and the whole-row case above.
The scalar first-answer ruling supports investigating store guesses too, but its
original document explicitly deferred list composition. No old diagnostic was
restored just to pass its test. No pending/error prototype has been merged solely
because a narrow example passed.

## Framework checkpoint at `54a7c3aa7`

The official Solid suite passes all 927 tests. The web client suite passes 1,863
with 20 failures and one skipped test. Those 20 store cases were previously
blocked by missing store support; no previously passing client or Solid test
identity regressed. Hydration retains 10 preexisting failure identities. Server
has two confirmed duplicate-package diagnostic-bus failures and one iterator
count failure seen only under the full parallel run. The scratch resolution fix
passes the affected 21 server tests. None of these failures depend on `until`.
Raw receipts and controls are archived in `checkpoints/store-framework-54a-20261112.tar.gz`.

Two proposed shortcuts were rejected during review: choosing a row body from its
action lifetime loses the published/proposed distinction during correction; and
linking a stable parent reference directly to a child's output forwards that
child's error even when the reference never consumes its value. Both mechanisms
remain outside the main implementation.

A separate reported early ordinary-write publication was a diagnostic mistake:
the assertion retained a mutable object which cleanup later changed. Frozen
snapshots show both saved flags held correctly, and next agrees. The independent
second action's optimistic value may publish. No runtime change was made for
that report.
