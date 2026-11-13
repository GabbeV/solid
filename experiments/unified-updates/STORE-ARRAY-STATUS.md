# Current array investigation status — 2026-11-14

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

## Bounded retry result

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

Next investigation should establish one coherent selection of array structure
(length, presence and descriptor metadata), with per-property values still selected
independently. This is a proposed implementation direction, not a proven repair or
new semantic ruling. In particular, do not turn the structural boundary into a
guess of untouched values, replay setters, or extend optimistic lifetimes.
