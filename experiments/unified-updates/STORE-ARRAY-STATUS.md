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

## Shared structural selection trial (2026-11-15)

The current working implementation replaces the separate length and ownership
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

The five new assertions remain unchanged and unresolved:

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
