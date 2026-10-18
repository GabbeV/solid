# Source fidelity and upstream tracking

The user has explicitly set the engineering target: a translation close enough to
line by line to follow future Solid commits. There is no requirement to formally
prove TypeScript/Bend equivalence. The user permits temporary deviations when
needed to continue progress, provided they are strictly tracked, explained and
retired or reconciled when the upstream fix lands. A passing proof/example is not
evidence of correspondence. Preserve source evidence and investigate conflicts;
do not silently present a workaround as the faithful source implementation.

## What line by line means here

Each source function and meaningful operation should be locatable in Bend: branch
conditions, field reads/writes, statement and callback order, traversals, catches/
finally restoration, sentinels, flags, fast paths and shared hooks. A loop may
become recursion, a mutation may become state threading, and mutually recursive
calls may become explicit continuations. These changes require a correspondence
explanation. Reordering, simplifying or replacing source decisions must either
preserve the admitted source behavior or be recorded as a temporary deviation in
[the deviation register](deviations.md). Matching a few traces alone is insufficient.

Unsupported domains stay unfinished. The current expression grammar and one-root
harness define test coverage; they do not establish full source API coverage.
Useful Bend proofs continue, but their limitations must follow the actual program.
A workaround, replacement or extra gate must not be presented as source behavior.
If such a change is necessary, register its exact scope and proof impact and keep
it isolated/reversible in the one active execution path.

## Initial audit of the existing checkpoint

These are port-side observations. None establishes an upstream bug.

| Area | Current gap | Required treatment |
| --- | --- | --- |
| Node construction (`api.allocate`) | One generalized literal sets CONFIG_SYNC for every kind; Solid uses distinct signal/computed/effect/owner literals and options, with different fields/configuration. | Port the source constructors/options separately and preserve lazy extensions. The generalized constructor is unfinished alignment work. |
| Refresh helper | The original port called markNode/enqueueSub, eagerly propagating CHECK and changing the heap minimum; source markRefresh updates the target flags, calls insertIntoHeap, then schedule. | This checkpoint replaces that substitution with core.markRefresh in source order, including REASK flag classification. Async classification remains unfinished. |
| Public refresh | The facade currently exposes invalidation only. Solid's public refresh also implements an awaitable waiter protocol. | Keep the helper mapping distinct from the public API; port the waiter rather than claiming public API parity. |
| Commit (`scheduler.commitPendingNode`) | The earlier checkpoint folded signal/computed commits together and cleared too much state. This checkpoint separates those source branches, restores publication/configuration order, preserves status bits, closes `_loading`, and queues staged effects at commit. | 768 comparisons with the actual TS helper cover internal state/queues, including the in-flight bit branch. The cold extension, staged-error notification and parked-child disposal remain unfinished; these probes do not establish async or transaction execution. |
| Queue/pending intake | Pending nodes and held trims formerly cleared before their walks. They now use live indexed bounds and clear at the source sites, with the source held/override intake guard. | Walk fuel is explicit. Callback-driven growth remains untested because cleanup/reentrant callbacks are not implemented. The effect queue snapshot is source behavior (`GlobalQueue.run` detaches a nonempty queue before running it); the earlier broad audit description did not distinguish it. |
| Staged-read state | A state comparison exposed missing REACTIVE_STAGED_READ recording after a staged dependency read. | This checkpoint restores stagedRead and its uninitialized guard. The source pass flag is retained even before lane support exists. |
| Unflushed reads | This checkpoint replaces the running/staging shortcut with source `unflushedStaged`, `readerSeesCommitted`, `unflushedValue`, `markLateLinker`, promotion/reset helpers and a distinct signal fast block. | 768 internal-state comparisons plus end-to-end late-reader/undefined/drain regressions cover the admitted paths. Held `_flushed` stashes, spectating, status propagation, and hooks remain unfinished. The helper placement in `runtime/read-state.bend` breaks the TS core/scheduler import cycle without replacing its state decisions. Promotion helpers are tested directly; callback writes are still unsupported. |
| Disposal | A worklist and pre-collected children replace the source's live child/sibling walk; cleanup, reentrancy, parked frames and dormancy are absent. | Recreate the source teardown order before admitting those behaviors. |
| Graph/heap helpers | Link identity, generation reuse and intrusive buckets are retained, but shared hooks and some root/lifecycle branches are missing. | Keep local correspondence restricted. Review every source branch; do not exclude a shared path merely because it includes a store hook. |
| Payloads/callbacks | Natural arithmetic, identity tokens and an expression interpreter stand in for host operations and reusable callbacks. | Keep these as explicit representation/host restrictions. They do not authorize different engine decisions or general JS numeric claims. |
| Totality/resource bounds | Execution fuel is explicit, while several scalar/list pointer helpers rely on well-formed finite lists and currently return partial results if their internal bound is exhausted. | Establish invariants/bounds or propagate explicit exhaustion; never treat truncation as successful source behavior. No general progress guarantee is claimed. |

The existing correspondence ledger is a location index with restrictions, not a
certificate of line-by-line alignment. Every source branch remains open for
individual review unless a separate review explicitly closes it. The two concrete
kernel-checked executions and differential tests do not close the gaps above.

## Reviewing a future upstream commit

1. Keep the pinned reference unchanged. Obtain a separate candidate checkout.
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
   also invalidate prior checked-source hashes. Review every active deviation,
   record the reviewed pin, and check whether the upstream fix supersedes its delta.
   Only then prepare an explicit repin.

## Handling a discrepancy

First reduce and classify it as a port mistake, host/test mistake, intended source
behavior, ambiguous specification, unsupported execution, or suspected upstream bug.
A suspected upstream bug record must include source commit/build profile, minimal
program and schedule, observable values/order, the proposed violated contract,
paired controls, relevant source lines/tests/docs, and remaining uncertainty.
Before presenting it as current, reproduce against the version under discussion
and inspect upstream fixes and issue history. State when those checks are incomplete.

Preserve the pinned reference and counterexamples. A candidate correction may be
used to unblock work when its deviation is registered, explained and reversible;
it need not wait for upstream acceptance or require another runtime. Record the
issue/fix links, exact affected source, baseline versus patched expectations, and
what will cause the workaround to be removed. Present report-ready evidence to
the user; filing or contacting maintainers requires the user's explicit instruction.
