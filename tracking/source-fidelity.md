# Source fidelity and upstream tracking

The user has explicitly set the engineering target: a translation close enough to
line by line to follow future Solid commits. There is no requirement to formally
prove TypeScript/Bend equivalence. Runtime changes made solely to make a proof or
example pass are unacceptable. Explain conflicts and investigate potential
upstream bugs instead of silently repairing the source baseline.

## What line by line means here

Each source function and meaningful operation should be locatable in Bend: branch
conditions, field reads/writes, statement and callback order, traversals, catches/
finally restoration, sentinels, flags, fast paths and shared hooks. A loop may
become recursion, a mutation may become state threading, and mutually recursive
calls may become explicit continuations. These changes require a correspondence
explanation. Reordering, simplifying or replacing source decisions is not justified
by matching a few traces.

Unsupported domains stay unfinished. The current expression grammar and one-root
harness define test coverage; they do not establish full source API coverage.
Useful Bend proofs continue, but their limitations must follow the actual program.
No equivalent replacement algorithm, display wrapper, or extra publication gate
may make an unfaithful translation appear correct.

## Initial audit of the existing checkpoint

These are port-side observations. None establishes an upstream bug.

| Area | Current gap | Required treatment |
| --- | --- | --- |
| Node construction (`api.allocate`) | One generalized literal sets CONFIG_SYNC for every kind; Solid uses distinct signal/computed/effect/owner literals and options, with different fields/configuration. | Port the source constructors/options separately and preserve lazy extensions. The generalized constructor is unfinished alignment work. |
| Refresh helper | The original port called markNode/enqueueSub, eagerly propagating CHECK and changing the heap minimum; source markRefresh updates the target flags, calls insertIntoHeap, then schedule. | This checkpoint replaces that substitution with core.markRefresh in source order, including REASK flag classification. Async classification remains unfinished. |
| Public refresh | The facade currently exposes invalidation only. Solid's public refresh also implements an awaitable waiter protocol. | Keep the helper mapping distinct from the public API; port the waiter rather than claiming public API parity. |
| Commit (`scheduler.commitPendingNode`) | Signal and computed commits are folded together, some writes are reordered, and the status/extension/held-frame branches are absent. | Restore separate source branches and mutation order before extending outcomes or transactions. Current tests cover only successful sync commits. |
| Queue/pending intake | The port snapshots/clears some lists before walks; Solid uses specific live-array bounds and clears at specific points. | Preserve those exact loop bounds and clear sites; restricted callbacks currently hide some differences. |
| Staged-read state | A state comparison exposed missing REACTIVE_STAGED_READ recording after a staged dependency read. | This checkpoint restores stagedRead and its uninitialized guard. The source pass flag is retained even before lane support exists. |
| Unflushed reads | The port tests running/staging directly in serve instead of retaining unflushedStaged and the source helpers/fast paths. | Translate the source helpers and flags. This is a simplified path, not a completed operation-level port. |
| Disposal | A worklist and pre-collected children replace the source's live child/sibling walk; cleanup, reentrancy, parked frames and dormancy are absent. | Recreate the source teardown order before admitting those behaviors. |
| Graph/heap helpers | Link identity, generation reuse and intrusive buckets are retained, but shared hooks and some root/lifecycle branches are missing. | Keep local correspondence restricted. Review every source branch; do not exclude a shared path merely because it includes a store hook. |
| Payloads/callbacks | Natural arithmetic, identity tokens and an expression interpreter stand in for host operations and reusable callbacks. | Keep these as explicit representation/host restrictions. They do not authorize different engine decisions or general JS numeric claims. |
| Totality/resource bounds | Execution fuel is explicit, while several scalar/list pointer helpers rely on well-formed finite lists and currently return partial results if their internal bound is exhausted. | Establish invariants/bounds or propagate explicit exhaustion; never treat truncation as successful source behavior. No general progress guarantee is claimed. |

The existing correspondence ledger is a location index with restrictions, not a
certificate of line-by-line alignment. Every source branch remains open for
individual review unless a separate review explicitly closes it. The two concrete
kernel-checked executions and differential tests do not close the gaps above.

## Reviewing a future upstream commit

1. Keep the active baseline unchanged. Obtain a separate candidate checkout.
2. Run `npm run upstream:impact -- /path/to/candidate` (or add `--json`). The report
   compares source file and function fingerprints and identifies existing Bend
   mappings. It is read-only and does not fetch, repin, or approve correspondence.
3. Review actual source diffs, including module initialization, flags, fields,
   imports, tests and semantic documentation. Function hashes miss changes outside
   functions, so file-level differences are also reported.
4. Update mapped operations and review all meaningful affected branches. Keep
   missing, new, removed and moved units explicit; a move is reported as removal/
   addition, not presumed equivalent. Store changes still require review because
   the full TS entry can install shared hooks.
5. Treat correspondence/parity evidence as stale on source drift. Run appropriate
   differential scenarios and Bend checks after the port is updated. Runtime edits
   also invalidate prior checked-source hashes. Only then prepare an explicit repin.

## Handling a discrepancy

First reduce and classify it as a port mistake, host/test mistake, intended source
behavior, ambiguous specification, unsupported execution, or suspected upstream bug.
A suspected upstream bug record must include source commit/build profile, minimal
program and schedule, observable values/order, the proposed violated contract,
paired controls, relevant source lines/tests/docs, and remaining uncertainty.
Before presenting it as current, reproduce against the version under discussion
and inspect upstream fixes and issue history. State when those checks are incomplete.

Preserve the faithful baseline, including counterexamples. A candidate correction
must be separate and explain its semantic effect. Present report-ready evidence to
the user; filing or contacting maintainers requires the user's explicit instruction.
