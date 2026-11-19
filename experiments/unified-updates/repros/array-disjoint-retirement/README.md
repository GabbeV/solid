# Disjoint array override retirement

Playground: https://s.olid.uk/id/48181e7d-f0eb-4055-83a2-4c4ba66e3d5c

Runs upstream next bcef1041 (November 11), comparing [0, 0] with
{ 0: 0, 1: 0 }. Neither setter changes keys or length. Same action writes
both stores; index 1 starts first, index 0 starts 500 ms later, each waits
1000 ms. Chromium verified the object reverts index 1 at 1000 ms while the
array retains it until 1500 ms. No browser errors.

The issue form was prepared for user review; it has not been submitted by
the agent. This repro supersedes the sparse-array example for reporting
expired per-index retention: sparse structural writes have additional
entanglement questions.

Additional source probes compare ordinary and numeric-key objects against
arrays. Separate release probes show rc.20/rc.21 retain the same displayed
array values, but also hold the first action's ordinary write until the
second ends. At #4729 the ordinary write starts publishing independently;
the array remains retained. Therefore the visible retention is not a new
regression introduced by #4729. An action promise resolving alone is not
proof that its update published.

Receipts: ../../checkpoints/array-retirement-report-20261112.tar.xz.
