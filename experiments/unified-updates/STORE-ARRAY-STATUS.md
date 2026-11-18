# Store ownership checkpoint — 2026-11-19

Ryan's [#4996 ruling](https://github.com/solidjs/solid/issues/4996#issuecomment-6973759815)
supersedes the plain-holder behavior recorded on November 18. A plain
holder shares an explicitly supplied store proxy, including one supplied by
a later setter. A derived or optimistic store has its own view. If a plain
card captures a derived row, editing through the card changes that row and
leaves the row's input unchanged.

Coverage includes held keyed reconciliation before the first outside read,
shallow seeds, captured and newly read rows under `affects`, aliased rows in
`snapshot` and `deep`, and optimistic edits through accessors. A raw array
inside a shallow slot preserves its elements' identities. A Chromium check
of #5027 showed source/view values of Paris/Paris, Paris/Rome, then
Paris/Paris after the guessing action ended.

An unrelated ordinary setter can copy a published field or return a source
proxy to copy its root slots. One case still needs a ruling. Suppose
`card.person === person` and an action holds a change of `person.score`
from 0 to 1. With an initial `card.copy` of -1, running
`setCard(d => { d.copy = d.person.score })` reveals 0/1 before the action
ends on main (`82f71fddb`), PR #4906 (`bfc7b9af3`), and this checkpoint.
A committed read would give 0/0 followed by 1/0. A draft read that joins
the holding action would give 0/-1 followed by 1/1.

Validation of the runtime at `6f0249fd7` passed all 927 Solid, 1,886 Web
client, 2,010 server, 768 hydration, and 46 distribution tests that ran.
Of the Signals source tests, 8,085 passed in the full run, 135 failures
matched the deferred `until` inventory, and #4561 exceeded its 50 ms limit
during the concurrent suites. #4561 passed three successive focused runs
with the original limit. Build types, bundle purity and the rules index
passed. This checkpoint includes no benchmark comparison.

# Store integration checkpoint — 2026-11-18

Both remaining Web regressions (#4605 and #4613) pass with their existing
assertions. Once a new filter has published, an unguessed row stays behind
Loading while its incoming array replacement is held with a structural edit.
An explicitly guessed field can still publish. JSX tests cover release over
two successive edits and both retained and replaced row keys.

A plain store that receives an explicit store proxy now follows the source
through a local view. Writing through the receiving store edits that view.
Calling `affects(list)` covers its captured and newly read rows while leaving
the independent source clear. Passing the same raw child to two plain stores
retains the existing shared identity. This checkpoint stays on the deep store
engine.

A separate regression test covers a held replacement on plain and derived
stores. Reading a field, calling `deep`, and calling `snapshot` from outside
the open action all see the committed row until release.

Verification at ba287716b:

| Suite | Passed | Failed | Skipped |
| --- | ---: | ---: | ---: |
| Signals source | 8,051 | 135 | 5 |
| Signals distribution artifacts | 46 | 0 | 0 |
| Solid | 927 | 0 | 0 |
| Web client | 1,886 | 0 | 1 |
| Web server | 2,010 | 0 | 3 |
| Web hydration | 768 | 0 | 3 |

All 135 signal failures match the deferred `until` inventory by file and full
test name. Signals build types, the rules index, and the production and observe
purity checks passed. The local server run resolved the shared diagnostics
dependency to the same built signals runtime as the renderer. The hydration
runner allowed Vite to serve this workspace's symlinked dependencies.
Performance and bundle-size measurements remain pending for this checkpoint.

---

# Store integration checkpoint — 2026-11-17

Reran the five Web files with the six previously reported failures. Revised the
assertions for pre-initial writes and structural input coordination. Four of the
six failures were obsolete expectations. Retained the final corrections, request
checks and disposed-owner assertions. The focused group now has 10 pass / 2 fail.
Both failures expose a real consistency issue: a new keyed region (#4613) or
armed Loading boundary (#4605) releases to the old unguessed row 1 under the
closed filter after its incoming structural answer arrived but before it could
publish. The permitted outcome in those tests is still fallback. No runtime
repair or full-suite result is claimed at this checkpoint.

A fresh plain-store probe compared upstream 2.0 main bd06aefed, the experiment
2a0d1d20e, and wrapper proposal a2748e87c. For list = { people: [person] },
upstream and experiment retain row === person, all three pending reads (person,
captured row, path through list) go true during affects(list), and setting the
name through the list writes person. The wrapper proposal isolates the row,
reports [false, true, true], and setting through the list leaves person unchanged.
Whether to adopt those plain-write semantics on this branch is pending.

---

# Current store/affects status — 2026-11-16

The source-local derived-store affects fix is implemented. A declaration is
qualified by its reactive source family; root declarations include future outputs,
and retained wrappers keep coverage across backing replacement. Late-born nodes
inherit every independently active covering declaration. No ordinary signal/memo
fields or read-path traversal were added; extra records are local to affects.

The four prior snapshot-scope failures are migrated to the user's output-source
rule, with final release assertions retained. Twelve new source-local tests pass.
One new plain-store test is deliberately still failing pending clarification:
plain list.people[0] === person, and a plain list setter mutates person directly
(verified HEAD and next 221b5f99f). Does the source-local ruling also require a
plain collection mark not to mark that shared child? No such change is retained.
A trial ancestry exclusion was rejected: it made shared raw child coverage depend
on which alias was read first. All ancestry-based exclusion code was removed.

Source verification before removing that rejected plain guard: 8,071 pass,
138 fail, five skip; exactly 135 match deferred until, and three were stale rule
index checks caused by changed comments. Regenerating the index passes all three.
After guard removal, focused source verification passes 58 tests with only the
new plain-store semantic question failing. This is not a claim that the final
full suite is green. Runtime source types and production/observe purity builds
pass; generated property mappings and rule citations are updated.

Rebuilt framework checks found Solid 927/927 passing; Web client 1,877 pass,
six fail, one skip. The six are existing array/Loading cases (#4613, #4605 twice,
#4525 on=false, #4642 initial add, #4482); none calls affects. They have not yet
been classified against the previous runtime or current rulings. Server and
hydration have not been rerun in this pass. Do not claim API completion.

Receipts are in checkpoints/affects-source-local-20261116.tar.xz. Issue #4914
was filed by the user; no upstream issue or PR was submitted by the agent.

---

# Historical array investigation status — 2026-11-15

Rule A remains the specification: existing-index value-only edits stay granular;
structural changes coordinate the affected array's active direct edits and later
edits. Incoming structural changes must coordinate before publication. The input
of an optimistic boundary is relative and can itself be optimistic. No unguessed
value snapshot, setter replay, or extra observedness forwarding is authorized.

The shape-token rewrite from the previous session was unsuccessful and never
integrated. It is archived as abandoned. Historical reports are diagnostic evidence,
not additional semantic rulings. In particular, neither a new broad read dependency
nor observed behavior in a trial authorizes additional entanglement.

Cleanup retains two narrowly verified fixes: settled producer subscribers are not
blanket-woken by a guess, and cold untracked observation reads materialize the
selected property output. The original #619 callback assertion is restored. The
cold latest test checks a coherent selected length/index before release and the
corrected length/index after release. Their three-file suite passes 28 tests.

The last frozen full run was 8,006 pass / 174 fail / 5 skip; 135 failures match the
explicitly deferred until identities. Subsequent focused migrations and fixes reduced
known other failures to nine, but no fresh full-suite result is claimed here.

## Previous bounded retry result (2026-11-14)

The two-layer case (input [A,B], inner index1=I, outer append M, then input=[])
still fails. No new runtime repair from this retry is retained.

Isolated readers narrow the failure: indexed values and `in` remain coherent in
the simple probe, while adding a latest descriptor reader can make ordinary
descriptor reads report missing entries despite length staying two. The descriptor
trap receives the old backing; composition subsequently reads a proposed empty
body. This is evidence of inconsistent structural read paths, not a demonstrated
gap in rule A.

A trial routed length through the existing selected property output while a
structural marker was active. It passed all eight active-chain tests, but failed
two existing async structural-lifecycle tests by displaying [] before the guessing
action ended. The broader 12-file run was 145 pass / 2 fail. Invalidating the
container output as well did not repair those failures. Both changes were removed;
restoring the baseline gives 10 pass / 4 known fail across those two files.

The retained regression `unified-array-structural-read-surfaces.test.ts` uses
separate bindings for each layer and checks length, values, presence, descriptors,
and keys, including late mount and unrelated rerun. It currently fails, including
an unhandled composition error: a key returned by enumeration has no descriptor
when composition subsequently reads it. An earlier eight-case exploratory version
halted the reactive system on that error, so its later failures are not independent
evidence; only the single isolated regression is retained.

The next direction proposed at that checkpoint was one coherent selection of array structure
(length, presence and descriptor metadata), with per-property values still selected
independently. This is a proposed implementation direction, not a proven repair or
new semantic ruling. In particular, do not turn the structural boundary into a
guess of untouched values, replay setters, or extend optimistic lifetimes.

## Shared structural selection checkpoint 736ed636c (2026-11-15)

That checkpoint replaces the separate length and ownership
marker with one selected metadata frame: length, keys/presence, and descriptors.
Data values remain separate per-property outputs. This implements the agreed
direction; it does not add setter replay, a whole-value guess, or a new lifetime
rule. It is an unfinished implementation checkpoint, not an accepted repair.

The expanded read-surface regression passes all eight combinations of action
release order, latest reader presence, and structure-first versus length-first
reads. It checks each layer in a separate binding, unrelated reruns, and late
mounting. Nested active-array tests at two and three layers now pass as well.

A broader check caught an implementation regression: inserting a row in action A,
removing it in action B, then confirming A and B could expose undefined while the
array retired its overrides. The isolated case passed on the committed baseline.
Neither reverting raw backing traversal nor reverting the held-container pointer
change fixed it. Restoring container/length subscriber discovery on structural
selection and retirement did fix it. Equal metadata does not make that ownership
switch invisible to existing readers. All 900 mutation-matrix cases now pass.

The implementation also repairs a stale held-container backing after a structural
notification joins the writing transaction. Initial structural seeding reads
published metadata without pulling unresolved producers outside the tracked
input. Repeated equal metadata proposals are skipped only while an override is
already active; owner coordination still happens.

Validation against unchanged source at 738fc16b8, using the same 205 selected
store/array/optimistic files and current tests:

- Baseline: 2,832 pass / 59 fail / 4 skip.
- Trial: 2,839 pass / 52 fail / 4 skip.
- Five new failing identities; all other failures also occur on the baseline.
- Targeted matrix and structural/recovery cases: 993 pass / 5 fail.
- Production controls: all 922 mutation-matrix and structural tests pass.
- Signals source typecheck passes.

These are not full-suite counts. The failure set includes deferred until cases.
Baseline structural-reader errors can halt later tests in that file, so the
failure-identity difference is not a count of independently fixed bugs. Exact
reports and comparison are archived in array-structure-frame-20261115.tar.xz.

At that checkpoint, five new assertions were unchanged and unresolved:

1. Error recovery shows `#1 #4 p=true` before `#1 #4 p=false`. This is a changed
   pending verdict timeline, not duplicate error delivery. The new length
   companion is an additional pending dependency; its exact status ordering
   still needs tracing.
2. Four #4336 render cases invoke the callback again with the same displayed
   content when the lower optimistic selection reverts. Their fresh tuple result
   permits a rerun to trigger a callback, but the reason for the extra invalidation
   still needs tracing. No test migration or semantic acceptance is implied.

Both differences also occurred without the discovery callbacks, so those callbacks
are not their cause. The next bounded investigation should trace the structural
input/output status and invalidation at recovery and reversal. Do not remove the
callbacks again without the mutation/inverse matrix as a control. No fresh
performance or bundle-size claims are made for this unfinished trial.

## Follow-up: fix the five introduced regressions (2026-11-15)

Both causes are now corrected, with all original assertions unchanged:

- Array descriptor/presence reads use the structural output, but the store's
  producer-subscription guard still looked for the old per-property presence
  slots. `Object.hasOwn` therefore also subscribed the render directly to the
  family producer. Instrumentation located that exact edge and showed the
  duplicate callbacks on the restored request's response, not on action closure.
  Presence reads now use the same subscription boundary as array length. The
  structural input retains its own producer dependency, including error/status.
- Pending's incoming-input check counted a ready staged answer as pending even
  after that input was no longer held. Its direct-output check already required
  a hold. Applying that same condition to the incoming check removes the spurious
  recovery frame with pending=true; unfinished async work still reports pending.

Adding equality to the structural input was tested and did not fix any of the
five assertions; that trial was removed. The structural discovery callbacks
remain in place. No test expectations or lifetime/entanglement rules changed.

The focused run passes all 968 cases, including the five regressions, nested
structural/read-surface tests and all 900 mutation-matrix cases. The pending,
latest and error selection passes 962 tests; its 25 failures were individually
confirmed on source 736ed636c, so there are no new failure identities in that
selection. Source typecheck passes. The same 968 focused cases pass in production mode.

Full signals validation: **8,042 pass / 141 fail / 5 skip**. Exactly 135 failing
identities match the previously reviewed deferred-until list. The remaining six
also fail against source 736ed636c:

- #3706: a row first read after adoption reports pending where false is expected.
- `affects`: two scope tests report pending for an added record or a separate key.
- Shared-question store hold: the test expects `closed: 3,4`, receives `open: 3,4`.
- #3743: two leaf-reader array cases throw while snapshotting the selected view.

No new non-until failures remain from this follow-up. These six are unresolved,
not approved test migrations. The experiment as a whole remains unfinished;
fixing the five introduced regressions is not a completion claim. Receipts and
source baselines are in `array-regressions-20261115.tar.xz`.

## Follow-up: five of the six remaining cases (2026-11-15)

Five original failures now pass without changing their assertions:

- Two #3743 snapshots no longer instantiate the obsolete whole-array selector
  mid-hold. Composition already has the shared metadata selection and selected
  property values; the extra selector had no published value and threw.
- The shared-question store case no longer merges the guessing action with its
  pending input. Blanket setter-time invalidation ran held selectors before the
  new proposals selected their output context. Changed output notifications and
  structural selection/retirement discovery suffice; incoming-answer discovery
  remains. The 927-case matrix/structural check passes with this deletion.
- The #3706 find case uses metadata equality on the structural input as well as
  its output. A value-only row replacement no longer stages identical metadata
  and creates an unrelated hold. All 19 adoption controls pass.
- The keyed affects case excludes internal accessor discovery from observation
  windows. It no longer probes unrelated fields while determining whether the
  requested field is an accessor. Actual descriptor/value/snapshot reads retain
  their observation semantics; composition itself is not suppressed.

One original case remains: a child added after affects(parent) was declared is
outside the declaration's identity scope, but its selected-body dependency on
that parent makes isPending(child.field) inherit the parent's mark.

A mark-source trial passed the original test but failed additional controls.
An explicit store-slot origin plus removal of direct caller dependencies made
all focused mark controls pass, including later marks on the child and captured
memo/value/presence/key readers. However, the full suite then exposed two new
regressions: a Loading fallback stopped appearing, and a concurrent optimistic
leaf guess failed to display. Both regressions disappear without those changes.
**The entire mark-source trial is removed from the retained runtime.** No new
origin fields, mark propagation hooks, or caller-dependency suppression remain.

The five new tests in unified-store-mark-boundaries.test.ts are retained. Two
alias controls pass; three selected-child memo/read-surface variants expose the
remaining scope problem. They are not accepted behavior or weakened assertions.
The next attempt must preserve value subscriptions and demand while making
explicit marks follow the store identity covered by the declaration. Do not
solve marks by indiscriminately suppressing parent-selection dependencies.

The prior trial's full receipt (8,051 pass / 137 fail / five skip) is rejected
validation, not the current result. Exact ablations, agent traces, source trial,
and retained validation are archived in array-six-remaining-20261115.tar.xz.

Retained validation: **8,049 pass / 139 fail / five skip** in the full signals
suite. Exactly 135 failures match deferred until. The other four are the one
original affects-scope test and its three new memo/read-surface variants. Those
three variants also fail on the earlier source baseline; no other new failure
identities remain. Production controls pass 1,039 cases with the same four known
scope failures; one explicitly development-only assertion is excluded. Source
typecheck passes. The implementation remains incomplete at this mark-scope gap.

### Affects model clarification (2026-11-15)

The user clarified the intended reference model: affects is an invisible pending
input to the targeted source, resolving equal when the surrounding update ends.
It cannot keep that update alive and its resolution must not recalculate values.
A later real update may arrive upstream with additional async between; pending
must remain continuous across that handoff. An active optimistic override must
not hide the declaration: it belongs on the output side in that case.

Non-entanglement is not considered a consistency requirement. Retaining ordinary
coordination is an option if it simplifies the implementation, but no change to
entanglement has been implemented. Error behavior should match real incoming
updates; remove differences only after demonstrating them. A bounded comparison
with an already-errored memo currently reports false downstream for BOTH a mark
and a real pending upstream update, so that probe does not establish a difference.

The previous instruction above to preserve declaration-time identity scope is
no longer an unquestioned acceptance requirement. Source-dependency semantics
must be worked out for store records and captured children before migrating the
four scope assertions; they have not been changed or classified as resolved.

Added two passing observable tests in unified-affects-lifetime.test.ts: equal
mark release does not rerun value computations, and a declaration hands pending
over continuously to an external upstream update with intermediate async even
when the declaring action finishes first. These are targeted checks, not a full
validation of the clarified model. Runtime code is unchanged at this checkpoint.

### Affects source-scope investigation (2026-11-15)

Compared targeted probes with freshly fetched next 221b5f99f. Active/inactive
optimistic output declarations remain downstream-only in four probes. New
captured children report false after a plain insertion or derived-store answer,
but true after an active optimistic insertion in the experiment. Next reports
false for all those new captured children. A restored trial marking the root
store producer fixes the two derived-answer probes (26 focused checks pass),
but does not solve plain stores without a producer. No runtime change retained.

Shared-object scope needs a ruling before a broader implementation: inserting an
existing store object into a marked plain collection leaves the object's own
isPending false. Inserting it before declaring the mark makes it true. Verified
both experiment and next, with captured row === original proxy. Is the mark a
dependency solely of the collection output, or does it declare every currently
reachable shared field affected too? Parent pointers cannot decide this because
shared raw targets are deduplicated and retain only their first wrapping parent.

Error comparison does not isolate a different inherited-error cutoff: both
real async and a mark report false on an already-errored memo. Boundary pending
can differ because real async retries suspend, whereas marks don't recompute
values. A separate probe exposed final boundary undefined after an equal async
answer, identically in next and experiment; undiagnosed, not classified as an
experiment regression or affects bug. Receipts and probes (not acceptance tests)
are in checkpoints/affects-model-review-20261115.tar.xz.

### Affects source isolation ruling and capture checks (2026-11-16)

User ruled that affects(list) must not make an independently held person store
pending merely because list contains it. Reading through list may be pending.
This supersedes the earlier recommendation to cover all current shared contents;
that recommendation was not adopted or implemented.

Verified both experiment 94a48bf42 and next 221b5f99f: rederiving a list using a
returned keyed-row replacement or editing its draft leaves the incoming person
store unchanged. Its derived row proxy is distinct. No input-mutation bug was
demonstrated. A genuinely unresolved store derive suspends a new tracked row
capture before isPending is reached. A mark alone does not suspend that capture
in either implementation: declared pending currently leaves values readable.
The earlier plain-store example involved only a mark, not a pending derivation.
Five controls retained in unified-affects-capture-isolation.test.ts.

Both implementations incorrectly mark person.name pending relative to the new
ruling when person was already present at declaration. This is a mark-scope leak,
not a data-mutation leak. New failing exploratory probes are archived separately
in affects-capture-review-20261116.tar.xz. No runtime changes at this checkpoint;
the store mark implementation still needs migration to source-local semantics.

Captured-row identity follow-up (2026-11-16): both experiment and next use a
distinct wrapper for a row read through a derived store. Editing the derived
draft updates that same captured wrapper without changing the incoming person.
Returning a replacement row in the tested nested-array shape instead replaces
the wrapper; the old captured row remains Alice while list.people[0] becomes Bob.
No universal row-retention guarantee is inferred from matching id alone. An
actual async producer update makes a previously captured row pending while the
original person remains not pending; the six capture/isolation controls pass in
both implementations. This supports separating source identity from the raw
identity coverage used by affects. No runtime behavior changed.
