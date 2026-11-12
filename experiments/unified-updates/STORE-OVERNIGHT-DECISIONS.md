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

## Parent/child setter publication

**Choice for review:** one setter is a single optimistic boundary with multiple
outputs, including a parent row and a field of that row. Its outputs publish
together above their external inputs. An internal dependency between those
outputs does not add another optimistic depth. Overlapping setter groups are
unified; a dependency cycle between groups is one publication component. This
groups publication, not the underlying producer's lifetime with the action.

The common scalar and same-depth setter paths avoid constructing that component
graph. Mixed groups use their committed dependency graph. A held previous version
of the same group must not count as another input layer: four superseding guesses
now retain the same depth, including through a memo, while an external optimistic
input still adds a depth. Eighteen focused checks cover proposal order, overlapping
groups, cycles, external inputs, async holds, late readers, retirement and stale
answers. The integrated 215-test subset passes 209, with six known row-body
preservation failures remaining. Source type checking passes. This is not a size
or performance acceptance claim.

Three upstream frame-lifetime failures were outside-read expectation mismatches.
The tests now expect the displayed card positions during a hold, as already ruled
for ordinary outside reads, and assert the new positions after publication. All
eight tests in the two files pass; frame cleanup and side-effect ordering
assertions remain intact.

## Guesses before the first producer answer

A property guess can publish before its input has ever answered, matching the
scalar primitive. It does not expose untouched seed properties. First readers
may have suspended before subscribing to that property; selecting the guess now
wakes them so they can discover its output. Initializing a companion tolerates
an unanswered input, but still propagates context-retry control flow and real
errors instead of aborting a setter partway through its changes.

**Choice for review:** an implicit array growth floor is not a complete length
override. Mapping a list before its first input answer still waits for that
input's length. This avoids pretending the seed is a published answer or hiding
an unknown longer input. The write itself is accepted; it is not the old
`OPTIMISTIC_WRITE_BEFORE_LOAD` rejection. Explicitly guessed properties may be
read independently. The focused integration run passes 43 tests, including both
completion orders and an add/filter/add sequence that previously aborted during
companion initialization.

The original signals and JSX before-load rejection tests now exercise accepted
writes and coherent first publication/correction. The signals migration subset
passes 22 of 23 tests; its remaining unkeyed row correction failure is unchanged
and belongs to the parent-object work. The updated JSX test awaits validation
against the final rebuilt package. Generated rule references were refreshed.

The full source-discovery run at `4d891e564` reports 7,611 passes, 232 failures
and five skips. `until` accounts for many failures; the remaining cases are still
under review. Artifacts were from `54a7c3aa7`, so this is not final built-package
acceptance. Raw receipts and unmerged trial snapshots are preserved in
`checkpoints/store-progress-20261112.tar.xz`.

That run also caught a regression in client error reporting from the common
same-answer notification fix. Explicit boundary reset now reports an unchanged
primitive error as a fresh sight, while ordinary graph propagation retains
same-answer suppression. The fix is local to reset, adds no node fields, and
passes the original reporting and optimistic-error checks (18 tests on main;
103 related tests on the isolated patch).

## Parent objects and derived input status

The integrated parent-object boundary reads its actual published parent output.
It applies to whole object properties, nested objects, keyed rows and positional
rows. Child field inputs take their values from that selected body; the ordinary
producer continues updating its own inputs. Same-key echoes cannot change the
body of a still-selected object guess. Descriptor, presence, enumeration and
nested array reads participate in that selection too.

Derived property companions now own their producer's pending/error input. A
getter delegates to that output instead of independently checking the producer
first. Ordinary reads, `latest` and `isPending` therefore observe the same selected
output. A selected descendant keeps its existing ancestor object reference
available, but unguessed sibling fields still consume producer status. In
particular, `isPending(() => store.object)` may be false while a read of an
unguessed field of that object is pending. This reference-versus-content
distinction is a choice for review, not a whole-object loading guarantee.

A first guess can also replace an already-errored input. The internal priming
read retains that error state and allows the proposal; it still rethrows context
retries and exceptions not recorded as the output's error. All 32 integrated
error-publication tests pass with no unhandled errors, covering first guesses,
undefined errors, late readers, observation APIs, correction holds and recovery.
The error arm compares original errors rather than newly allocated status
wrappers; successful recovery clears that display so a later recurrence is
reported again.

Disposal uses existing ownership and release queues: an unobserved companion can
discard an abandoned pending input after its producer is disposed and its action
closes. A mere dependency-validation mark does not retain a subscriber-free
companion; visible association cleanup still uses the stricter idle check. Tests
retain published held corrections across reader disposal and late mounting, and
exercise repeated producer disposal without growing subscriptions.

**Still being fixed in this checkpoint:** the complete resize output must avoid
reading the base length it replaces, whereas a growth floor must keep that input
dependency. The integration exposes two before-first-length failures and a
repeated-edit publication failure in this area. Producer reconciliation now uses
the writer view, preventing an internal pending read during answer adoption.


## Length input routing and discovery context

An explicit resize now reads its own selected output before consulting the
length it replaces. A growth floor still combines with, and therefore observes,
the input length. This fixes the before-first-input distinction without letting
an implicit floor publish an unknown seed length. The producer bypass is gated
on optimistic families; ordinary derived arrays retain their status check.

Discovery can notify a lower input while an upper update is executing. A
notification alone does not consume the upper proposal. The lower computation
now keeps its own unfinished update context until an actual higher dependency
selects a retry. Without that rule, its ordinary hold join accidentally merged
the input action with the optimistic output, leaving an existing reader stuck
while a late reader displayed the guess. Scalar controls reproduce the defect
without stores. Genuine higher dependency adoption still passes at two depths.

Validation: 62 focused tests pass, plus typechecking. A 123-test projection/status
run passes 121; the remaining enumerator repeat and untracked store-context cases
are being investigated. The full discovery run before the ordinary-family gate
reported 7,663 passes, 268 failures and five skips; it exposed the gate regression
and is not final acceptance. Full-suite failure counts include deferred `until`.

## Discovering length proposals before consuming their input

The length derivation now reads active growth outputs before consulting the base
length. That establishes the optimistic calculation context first; an initialized
lower input supplies its committed length there. Previously the pending input
could throw before the reader discovered the growth output, leaving a whole-list
reader stuck while an index reader displayed the guess. An input that has never
published still blocks an incomplete length guess. All three original bare-refetch
regressions now pass without changing their expectations.

Readers of a complete resize no longer depend directly on base length. Discovery
therefore also wakes readers of current and retiring length outputs when another
growth proposal appears. A resize-and-later-push regression covers live and retired
resize outputs. The 900-case upstream mutation matrix now passes 898 cases; the
two remaining chained-row inverse failures are being fixed separately.

Independent producer errors remain visible through unguessed fields while guessed
fields retain their own values. Three original error/disposal tests now assert
that stage-120 behavior explicitly, including the selected guessed index and actual
region cleanup. They deliberately differ from next's family-wide lifetime hold;
the comparison ran the original next tests successfully (11/11). Nested value-only
writes no longer wake ancestor key enumerators: the keys have not changed.

## Equal-answer status adoption

A pending source can settle in a higher optimistic context without changing its
value. Its readers must still discover that context. Status settlement now uses
the same existing adoption path as a changed value, instead of merging the
reader's obsolete lower hold into the upper update. This fixes filtering an object
list during refetch and repeated list edits; a small test compares primitive and
object rows through actual render callbacks. The isolated review passed 113 tests;
the root review passed 57 with one independently reproduced positional-row failure.

The broader source run at this point reports 7,714 passes, 225 failures and five
skips. It remains an intermediate receipt, with deferred `until` and store work
still outstanding. Eight newly failing #4577 assertions came from a test helper:
it searched for an `other:closed` request that no longer existed, then
`splice(-1)` delivered its `O-closed` payload to an `other:open` request. The tests
now assert named requests exist and answer optimistic re-requests for their actual
keys. All original publication-consistency assertions remain unchanged, and all
14 cases pass. The remaining four newly failing mount tests are still under review.

## Complete property selection and safe list reconciliation

A changed property now selects its presence and descriptor metadata together with
its value. Otherwise an independent input could delete a property that still had
a displayed optimistic value. Tests cover a guessed number and a present
`undefined`, including descriptor values and readers that only use descriptors.
Internal selection of a parent object's body no longer consumes the hidden raw
field's pending state. The existing companion owns that raw node's identity until
it is released, using the existing deferred-release queue rather than a cache or
an artificial reactive dependency. Tracked data fields on a selected object get
their own correction notifications; getters retain their proxy receiver.

Enumeration has an ordinary producer-aware input, including pending and errors,
and composes selected metadata over it. A cold selected output must establish its
calculation context before a later read can throw on the lower input. Unknown
initial shape still waits: guessing one property does not publish the seed's
other keys. Reclamation tests cover disposal during a pending correction.

Optimistic list mapping resolves its selected input snapshot before entering the
internal row owner and changing retained reconciliation state. Retrying context
discovery midway through those mutations caused both an infinite retry on sparse
arrays and wrong retained rows after a delete/add sequence. The successful pass
reuses the snapshot as the mapper's existing commit copy; it does not allocate a
second items array. Aborted attempts can allocate this copy earlier than before.
Ordinary arrays retain their previous path. These are implementation allocation
counts, not performance measurements.

The combined root check passes 993 tests, including the upstream 900-case mutation
matrix, both 100-seed #4642 scenarios, sparse output controls, positional/keyed
parent corrections, errors, descriptors and reclamation. Typechecking also passes.
This is not full-suite acceptance; cold companions, pending classification and
remaining test migrations are still under review.

**Choice for review — genuinely sparse composition:** fixed-index overrides do
not preserve unguessed indices when an independent input removes them. Starting
with `["A"]`, an action's `push("M")` selects index 1 and a minimum length of 2.
If the input independently becomes `[]`, the output may be `[hole, "M"]` until
the action ends. Keys, `in`, descriptors, indexed reads, native iteration, memos and
all three mapArray modes must agree on that same sparse array. A push that reads
length supplied by another active override still joins that action, as ruled.
No length-read heuristic was added to snapshot carried rows, and no operation
replay/rebasing was introduced. Next instead retains the old dense rows together
with the independent input's old length in the comparison controls.

The #4491 tests now verify every queued whole-display snapshot and each binding's
full value sequence. They no longer require an ordering between sibling callbacks,
which the user explicitly left unspecified. Status-context retries can emit one
identical callback for an equal answer; the tests state that explicitly and still
check all pending-state and display transitions. The common adoption mechanism is
retained for effects because excluding them broke legitimate list publication.
