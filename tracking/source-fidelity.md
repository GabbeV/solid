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
| Node construction | `api.allocate` has been removed. Separate signal/computed/effect/owner literals retain their own option masks, lazy/loading defaults, parent links and setup order; sync is opt-in. | 7,680 constructor comparisons cover the production subset and lazy extension defaults; nested-root heap/read forwarding has direct probes. Hydration IDs, snapshot/external hooks, context APIs and callbacks remain unfinished. See [representation.md](representation.md). |
| Refresh helper | The original port called markNode/enqueueSub, eagerly propagating CHECK and changing the heap minimum; source markRefresh updates the target flags, calls insertIntoHeap, then schedule. | This checkpoint replaces that substitution with core.markRefresh in source order, including REASK flag classification. Async classification remains unfinished. |
| Public refresh | The facade currently exposes invalidation only. Solid's public refresh also implements an awaitable waiter protocol. | Keep the helper mapping distinct from the public API; port the waiter rather than claiming public API parity. |
| Commit (`scheduler.commitPendingNode`) | Separate source branches preserve publication/configuration order and status bits, close `_loading`, queue staged effects, and use nullable extension state for shown-error/reask/flushed resets and the nullish error trim gate. | 4,608 comparisons with the actual TS helper cover internal state/queues, including the in-flight bit branch and absent/null/false/error metadata. Staged-error publication and parked teardown execute; these probes do not establish async or transaction execution. |
| Queue/pending intake | Pending nodes and held trims formerly cleared before their walks. They now use live indexed bounds and clear at the source sites, with the source held/override intake guard. | Walk fuel is explicit. Cleanup-triggered writes now test live intake growth and exact throw partial states. The effect queue snapshot is source behavior (`GlobalQueue.run` detaches a nonempty queue before running it); the earlier broad audit description did not distinguish it. |
| Staged-read state | A state comparison exposed missing REACTIVE_STAGED_READ recording after a staged dependency read. | This checkpoint restores stagedRead and its uninitialized guard. The source pass flag is retained even before lane support exists. |
| Unflushed reads | Source `unflushedStaged`, `readerSeesCommitted`, `unflushedValue`, `stashFlushed`, `markLateLinker`, promotion/reset helpers and a distinct signal fast block are retained. | 768 read-state comparisons, 24 direct held-stash cases and end-to-end regressions cover the admitted helpers. Held entry, pending throw and staged-error callers execute; spectating and active snapshot/verdict/lane/boundary hooks remain unfinished. The helper placement in `runtime/read-state.bend` breaks the TS core/scheduler import cycle without replacing its state decisions. Callback writes use the shared setter and promotion path. |
| Disposal | The pre-collected child worklist has been replaced with source return-point tasks: detach head, strip AUTO_DISPOSE, delete heap/clear deps, self-predecessor marker, recursive disposal, then live next-sibling read. Parked/current frames and cleanup detachment/LIFO are retained. | 16 comparisons exercise source owner state and cleanup traces, including reentrant disposal/registration, throws, changed siblings, dead children and a dependency-free queued node. Cleanup programs are a restricted callback ABI. Twelve lifecycle cases cover the integrated commit/recompute consumers, including cancellation/cleanup throws and flush finally. 144 graph-state cases cover unobserved cascades and sweep guards; typed iterator close programs now execute; arbitrary callbacks remain unfinished. |
| Graph/heap helpers | Link identity, generation reuse and intrusive buckets are retained, with dormant/revival and restricted unobserved hooks now active. Slot/store hooks still explicitly refuse. | Keep local correspondence restricted. Review every source branch; do not exclude a shared path merely because it includes a store hook. |
| Synchronous errors | Compute/effect catches, wrapper identity, user error arm, raw escaping throws, same-value recovery and root halt/report state now execute through the same driver. | 18 histories and 2,880 helper states compare pinned source behavior; two concrete kernel laws cover a failed/recovered chain. Pending catches, mainline transactions and ordinary typed thenables now execute; active boundaries and arbitrary host errors remain unfinished. |
| Pending bookkeeping | Source sets, identity-preserving NotReady helpers, loading registration, self-only landing, propagation and deferred settle/release walks now exist in pending-state/status/pending modules. | 2,880 direct state comparisons and two closed diamond/path laws exercise helpers; core pending catches and mainline transactions now execute; ordinary typed host flights now execute through the same core; active boundaries remain unfinished. |
| Transactions | Stable records, redirect resolution, joins, held writes/reads, blockers, park/land and queue order now execute in the same driver. | 2,160 transaction, 4,096 blocker, 2,304 seam, 48 deferred and 4,096 held comparisons plus two closed park/land laws. Ordinary typed flight callbacks now join this path; typed iterators/flattening now execute; active lane/boundary/mark/store scopes remain unfinished. |
| Promise-like flights | Result identity, synchronous callback locals, loading/NotReady verdicts, rejection, write/status/flush order and autodisposal now execute in the same runtime. | 68 promise and 255 iterator histories, 18 source-only controls and 4,096 helper states; arbitrary getter/setter/callback and active-scope paths remain unfinished. See [async.md](async.md). |
| Captured pending Sets | Inline member snapshots could lose mutations through the recompute local reference. | Replaced with stable arena handles and tombstone iteration before relying on the new catch path; nine TS alias/iterator comparisons pass. This is a port representation repair, not an upstream workaround. |
| Payloads/callbacks | Natural arithmetic, identity tokens and an expression interpreter stand in for host operations and reusable callbacks. | Keep these as explicit representation/host restrictions. They do not authorize different engine decisions or general JS numeric claims. |
| Totality/resource bounds | Execution fuel is explicit, while several scalar/list pointer helpers rely on well-formed finite lists and currently return partial results if their internal bound is exhausted. | Establish invariants/bounds or propagate explicit exhaustion; never treat truncation as successful source behavior. No general progress guarantee is claimed. |

The existing correspondence ledger is a location index with restrictions, not a
certificate of line-by-line alignment. Every source branch remains open for
individual review unless a separate review explicitly closes it. Concrete
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

## Preserved upstream counterexample

[SOLID-EMPTY-FLATTEN-001](upstream/empty-flatten.md) records a current-next-head
source-only object leak for an immediately settled promise of an immediately
empty iterable. Direct/native/one-yield controls and related upstream history
were checked. This is a reduced bug candidate; no report, workaround or source
change is active. tracking/upstream-issues.json indexes it separately from the
semantic deviation register.
