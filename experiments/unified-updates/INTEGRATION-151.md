# Restore the Loading fixture to the collected suite

No runtime change. An accidental copy of part of the following test was left
inside a `createRoot` in `loading-fallback-in-flush-3540.test.ts` by checkpoint
ff20b4ea. It referenced variables belonging to the other test and did not parse.
Removing that inserted block restores the original test program and collects
72 previously unexecuted cases. The older reported full-suite case counts did
not include these cases; they had one additional collection failure.

With the program restored, 67 tests pass and five fail. Four failures only
compare internal reader counts. Tracing the recorded identities shows the
shared engine records both the held memo and its binding for the two bound
content cases; each record retires at the commit. The fresh async-mount cases
retain next's single-reader count; an earlier migration had incorrectly applied
the held-value count to them. Those four exact counts are corrected. Every
visible callback timeline and every zero-reader assertion after completion is
retained.

The fifth case creates a new memo inside a re-armed boundary and calls latest
imperatively before the memo has any committed output. It now expects the
already-chosen outside-read contract (NotReady until publication), as the other
fresh-mount cases in this file already do. It also records the memo and binding
as two obligations. The fallback, eventual content, pending values and final
cleanup assertions are unchanged. This is migration of a previously accepted
API difference, not a new ruling or a waiver of visible tearing.

The restored/migrated 72 tests pass in dev and production source modes. The
original upstream fixture also passes all 72 cases against pinned next
4fe75321. No cases were removed, skipped, or marked expected-failing.

Stage 150's full run remains the last full-suite result: 5,401 signals passes,
2,047 failures, two skips, plus the now-repaired collection failure. Adding
this focused restored coverage yields 5,473 passing collected signals cases;
that is an incremental total, not a claim of another full-suite run. Web remains
1,691/127/one skipped. The runtime is still stage 150.

Receipts: `checkpoints/integration-stage151.tar.xz`.
