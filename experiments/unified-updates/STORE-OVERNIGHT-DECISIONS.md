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
