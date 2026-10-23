# Unverified late-push `from` proof experiment

This archive is excluded from `PROOF.bend`, the default property checks and the
active proof claims. The `.txt` suffix is deliberate: several proof terms fail
independent kernel validation. Runtime, host and toolchain pins are unchanged.

The fixed seeded subscription programme constructs an owned memo, retrieves its
actual captured sender from context, emits after construction, delivers the
actual queued Promise callback, reads/disposes, drains a queued flush and a late
cancellation callback, then observes the retained result. Eight explicit host /
application phases take 47/0/13/36/71/1/1/1 Core steps, 170 total. A seeded memo's
public `isPending` is false while the iterator pull is waiting.

21 finite native controls compare 3,570 actual step prefixes, four quota vectors
and exact final Machines, including data/function identity and once-only cleanup.
These tests passed. They are not a semantic proof. The complete candidate fails
at `step_3_0` with `out of fuel`; factored candidates also fail at `arriving`,
`begin` or `transition`. No resource failure counts as a negative-test rejection.
Some helper modules checked independently, but the complete programme did not.

To resume in an isolated checkout at this checkpoint, copy each `archivedPath`
listed in manifest.json to its `originalPath` relative to the repository root
(removing only the archival `.txt` suffix). The stored generator and write-frame
candidate include the same `begin` attempt. Run
`node tools/from-async-witness.mjs --check` and
`node tests/from-async-proof-controls.mjs` before editing, then invoke the pinned
Bend CLI on `proof/from-async-program.bend --verdict` with `.tools/lean/bin` on
PATH. Do not add the candidate to active roots until the independent kernel gives
`ALL PROOFS CHECK`. Do not change source semantics or checker limits to force it.

The accompanying evidence records log hashes and bounded verdicts. Original logs
live outside this Git tree; these receipts do not claim the archive is proven.
