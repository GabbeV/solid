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

Next work is bounded to the existing two-layer regression: input [A,B], inner
index1=I, outer append M, then input=[]. Diagnose the first incorrect publication
against the approved rule. Do not resume the archived rewrite or widen semantics.
If a missing ruling is required, present the program and competing observable
sequences before implementing an alternative.
