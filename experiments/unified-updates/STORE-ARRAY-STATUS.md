# Current array investigation status — 2026-11-15

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
