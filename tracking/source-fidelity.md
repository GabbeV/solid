# Source fidelity and upstream tracking

Current pin: Solid 5b1b7776 (rc.17), matching fetched next on 2026-10-22.
[The runtime integration](reviews/solid-5b1b7776.md) ports merged #4211 fallback
retention and #4213 cleanup continuation/rethrow timing. Thirteen of 76 vendored
inputs changed, copied verbatim; the complete prior port remains at bb82345.
Seven new helper properties and thirty-six paired public histories check this policy.
Shared optimistic-fold hooks are reviewed but remain unfinished with active
lane read/write and store scopes. No active semantic deviation exists.


The user has explicitly set the engineering target: a translation close enough to
line by line to follow future Solid commits. There is no requirement to formally
prove TypeScript/Bend equivalence. The user permits temporary deviations when
needed to continue progress, provided they are strictly tracked, explained and
retired or reconciled when the upstream fix lands. A passing proof/example is not
evidence of correspondence. Preserve source evidence and investigate conflicts;
do not silently present a workaround as the faithful source implementation.

## Lane reads and authoritative truth

[lane-reads.md](lane-reads.md) maps source branch order, exact provenance,
recursive live dependency reads, raw comparator return/throw continuations and
held finality. Seven functions now execute internally, backed by native controls
and eight scoped properties. Core hook installation, folded-store callbacks and
public windows/lifecycle remain unfinished; no semantic workaround was added.

## Lane staging and group mutation frames

[lane-stage.md](lane-stage.md) maps actual false/true/source interruption forms,
entry/leave statement order, captured shown-parent judgment and frame-pending
leaf refusal. [lane-group-laws.md](lane-group-laws.md) proves whole-World link/
unlink frames, including first-match, absent-member and self-link order.
Native/helper evidence stays separate from public engine/TS-equivalence claims.
Core invocation and remaining lane lifecycle/read/write crossings remain open.

## Lane-aware blocker integration

[lane-blockers.md](lane-blockers.md) maps the scheduler/lanes mutual calls and
saved judge return points in one driver. The source own-flight versus guess/
foreign-source distinction, live parent/group scans and stale membership checks
now execute. Store slot-flight and hidden-boundary hooks remain unfinished.
Four quantified healthy-World boundaries and native matrices support this layer.

## Verdict bookkeeping

[verdict-bookkeeping.md](verdict-bookkeeping.md) maps quiet/loading distinctions,
conditional route/watch/reruns, root forwarding, actual joins/flight observation
and raw staged/held-latest return points. Six quantified properties and native
helpers check this restricted layer. Ambient storage is not public window/read
support; the active downstream engine and comparator crossings remain open.

## Lane identity and routing

[lane-identity.md](lane-identity.md) maps allocation/cache, raw ancestry, shared
mutable group identity and source mutation order, pass entry and value selection.
Core/lane staged reads now call one body with the source collector return point.
Native helpers and five scoped quantified properties support these operations;
active read/seam/correction/dissolution/declarer crossings remain unfinished.

## Not-final marks

[affects-marks.md](affects-marks.md) maps source count/coverage/repoll operations,
error precedence, validated-prefix cutoff and source-order heap enqueue points.
The restricted internal module has native helper comparisons and four quantified
World properties. Public verdict/declarer wiring and store family hops remain
unfinished; no active scope is claimed from a helper implementation alone.

## Current continuation closure

The remaining owner/core async/error/pending crossings have been migrated at
the source's callback return points. Public expression cleanup programs now
execute through the shared core machine. Direct bound getter cleanup values now
use that driver too; [getter-cleanup.md](getter-cleanup.md) records canonical
identity and the explicit native read-observation limit. Arbitrary closures remain excluded. [The operation review](reviews/teardown-closure.md)
records shared mutation segments, source ordering, tests, closed laws and limits.
Older staged notes below retain the history of that migration. No pin change or
semantic workaround is active.

## Plain identity-keyed mapArray

[The source-operation review](map-keyed.md) now follows the plain keyed path,
including duplicate-chain Map matching, pure-removal scratch reset, live suffix
shifts and the separate small-move scan/commit. Its comparison budget, ledgers,
probe, duplicate safeguard and cleanup return point remain source controls.
Private helper probes and public histories are separate from formal claims.
Extracted keys/index accessors now execute as reviewed below; packed-index
overflow remains refused.

## mapArray keyed:false

[The operation review](map-index.md) records the production by-index profile:
raw ownedWrite row signals, actual item accessors, prefix writes, stable-result
identity, staged tail edits and exact mapper catch/commit/cleanup order. The
prefix exhausts a side in this profile, leaving suffix/key matching paths for
the separate matching paths described in [map-modes.md](map-modes.md). Source
Map index preparation retains SameValueZero and undefined/-1/index distinctions.
All three typed keying modes execute without substituting position mapping.
No semantic workaround or new general mapArray theorem is claimed.

## Children resolver

[flatten.md](flatten.md) maps the source top-level accessor loop, optional
filtering, nested array traversal, per-element NotReady catch/last-error throw,
needsUnwrap OR and resolving closure. Core tasks share the existing callback/read
and exception driver; a function descriptor captures the actual results array.
The native adapter calls actual S.flatten and labels original returned functions.
Typed option and array/callable restrictions are explicit; no host traversal or
replacement error policy is introduced.

## Extracted keys and mapper arity

[The mode review](map-modes.md) maps function-length selection, actual item/index
signal allocation, compare callback return points, descending key preparation,
old-window callbacks and the cached new key in stageRemoval. Key errors remain
outside the mapper catch. Captured prefix bounds survive callbacks; live source
stores and partial prefix writes stay live. Optional rows/index vectors retain
separate presence flags, and small moves stay restricted to no-row/no-index
mapping. Native adapters observe the actual public helper and preserve mapper
formal arity; they do not reconcile or schedule. Five general array-storage laws
and three closed map executions are separate from finite native comparisons.

## Repeat and array representation

The production repeat/updateRepeat helpers now follow the source retained-window
algorithm and its mapper catch/commit boundary through the shared core. Stable
array IDs preserve identity and holes separately from present undefined.
[The operation table](repeat.md) records each return point, live/captured state,
owner routing and callback order. The pinned falsy fallback bug is preserved.
General array mutation/protocols, array StatusError string
coercion and non-natural count/offset domains remain unfinished. No active
semantic deviation or new general repeat proof is claimed.

## Tracked effect execution

The specialized tracked effect now follows its distinct heap-to-user-phase path;
it is not implemented as an ordinary user effect. Source stale scope is represented
explicitly and restored through normal/exceptional return points. See
[tracked-effects.md](tracked-effects.md) for the scoped completion and limitations.

## Public flush callbacks

The callback overload follows source syncDepth entry, callback return, outer
finally drain and inner finally decrement through the existing core driver.
The [typed action milestone](actions.md) now adds production actionDepth guards
and invocation/resume semantics. Dev guards and the full arbitrary generator API
remain unported. See
[flush-callbacks.md](flush-callbacks.md) for source return points and proof scope.

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
| Node construction | `api.allocate` has been removed. Separate signal/computed/effect/owner literals retain their own option masks, lazy/loading defaults, parent links and setup order; sync is opt-in. | 10,752 constructor comparisons cover the production subset and lazy extension defaults; nested-root heap/read forwarding has direct probes. Hydration IDs, snapshot/external hooks and arbitrary callbacks, arbitrary callable initializers remain unfinished; expression-based function-initializer signals now execute; escaped data-signal read/set functions and computed read accessors now execute; nested memo-read and user/render effect construction now execute through the same core machine. See [nested.md](nested.md) and [locals.md](locals.md). Owner context lookup/copy-on-write now executes; see [contexts.md](contexts.md). See [representation.md](representation.md). |
| Refresh helper | The original port called markNode/enqueueSub, eagerly propagating CHECK and changing the heap minimum; source markRefresh updates the target flags, calls insertIntoHeap, then schedule. | This checkpoint replaces that substitution with core.markRefresh in source order, including REASK flag classification. Async classification remains unfinished. |
| Public promise helpers | The public resolve/refresh watchers now execute eager resolve, deferred/coalesced refresh, source frame delivery, pending/error handling and native promise IO before disposal. markRefresh remains a separate helper. | 158 histories and 6,144 watch-body comparisons. Arbitrary callback/store targets, returned-thenable assimilation and active truth/lagging/lane scopes remain unfinished; see [watchers.md](watchers.md). |
| Commit (`scheduler.commitPendingNode`) | Separate source branches preserve publication/configuration order and status bits, close `_loading`, queue staged effects, and use nullable extension state for shown-error/reask/flushed resets and the nullish error trim gate. | 4,608 comparisons with the actual TS helper cover internal state/queues, including the in-flight bit branch and absent/null/false/error metadata. Staged-error publication and parked teardown execute; these probes do not establish async or transaction execution. |
| Queue/pending intake | Pending nodes and held trims formerly cleared before their walks. They now use live indexed bounds and clear at the source sites, with the source held/override intake guard. | Walk fuel is explicit. Cleanup-triggered writes now test live intake growth and exact throw partial states. The effect queue snapshot is source behavior (`GlobalQueue.run` detaches a nonempty queue before running it); the earlier broad audit description did not distinguish it. |
| Staged-read state | A state comparison exposed missing REACTIVE_STAGED_READ recording after a staged dependency read. | This checkpoint restores stagedRead and its uninitialized guard. The source pass flag is retained even before lane support exists. |
| Unflushed reads | Source `unflushedStaged`, `readerSeesCommitted`, `unflushedValue`, `stashFlushed`, `markLateLinker`, promotion/reset helpers and a distinct signal fast block are retained. | 768 read-state comparisons, 24 direct held-stash cases and end-to-end regressions cover the admitted helpers. Held entry, pending throw and staged-error callers execute; spectating and active snapshot/verdict/lane/boundary hooks remain unfinished. The memo-only post-pull verdict-bit flags store now has 24 direct source comparisons. The helper placement in `runtime/read-state.bend` breaks the TS core/scheduler import cycle without replacing its state decisions. Callback writes use the shared setter and promotion path. |
| Disposal | The pre-collected child worklist has been replaced with source return-point tasks: detach head, strip AUTO_DISPOSE, delete heap/clear deps, self-predecessor marker, recursive disposal, then live next-sibling read. Parked/current frames and cleanup detachment/LIFO are retained. | 16 comparisons exercise source owner state and cleanup traces, including reentrant disposal/registration, throws, changed siblings, dead children and a dependency-free queued node. Cleanup programs are a restricted callback ABI. Shared owner/core continuations now cover direct disposal, previous-effect cleanup, recompute preparation, core/scheduler trims and native watcher disposal (88 direct native probes); all active core callers now resume through async/error/pending continuations; expression cleanup programs and direct bound getter values are public, while arbitrary closures remain excluded. See [owner-core.md](owner-core.md). Twelve lifecycle cases cover the integrated commit/recompute consumers, including cancellation/cleanup throws and flush finally. 144 graph-state cases cover unobserved cascades and sweep guards; typed iterator close programs now execute; arbitrary callbacks remain unfinished. |
| Graph/heap helpers | Link identity, generation reuse and intrusive buckets are retained, with dormant/revival and restricted unobserved hooks now active. Slot/store hooks still explicitly refuse. | Keep local correspondence restricted. Review every source branch; do not exclude a shared path merely because it includes a store hook. |
| Synchronous errors | Compute/effect catches, wrapper identity, user error arm, raw escaping throws, same-value recovery and root halt/report state now execute through the same driver. | 18 histories and 2,880 helper states compare pinned source behavior; two concrete kernel laws cover a failed/recovered chain. Pending catches, mainline transactions and ordinary typed thenables now execute; active boundaries and arbitrary host errors remain unfinished. |
| Pending bookkeeping | Source sets, identity-preserving NotReady helpers, loading registration, self-only landing, propagation and deferred settle/release walks now exist in pending-state/status/pending modules. | 2,880 direct state comparisons and two closed diamond/path laws exercise helpers; core pending catches and mainline transactions now execute; ordinary typed host flights now execute through the same core; active boundaries remain unfinished. |
| Transactions | Stable records, redirect resolution, joins, held writes/reads, blockers, park/land and queue order now execute in the same driver. | 2,160 transaction, 4,096 blocker, 2,304 seam, 48 deferred and 4,096 held comparisons plus two closed park/land laws. Ordinary typed flight callbacks now join this path; typed iterators/flattening now execute; active lane/boundary/mark/store scopes remain unfinished. |
| Promise-like flights | Result identity, synchronous callback locals, loading/NotReady verdicts, rejection, write/status/flush order and autodisposal now execute in the same runtime. | 68 promise and 255 iterator histories, 18 source-only controls and 4,096 helper states; arbitrary getter/setter/callback and active-scope paths remain unfinished. See [async.md](async.md). |
| Captured pending Sets | Inline member snapshots could lose mutations through the recompute local reference. | Replaced with stable arena handles and tombstone iteration before relying on the new catch path; nine TS alias/iterator comparisons pass. This is a port representation repair, not an upstream workaround. |
| Question IDs | The source mainline number 0x7fffffff formerly expanded to billions of unary Nat constructors in the kernel. | Exact binary naturals retain numeric identity, zero/truthiness, the separate counter and assignment order. 4096 counter/5 boundary/69 provenance cases and three general representation laws; five composed async laws now check directly. This is representation repair, not a semantic workaround; see [question-ids.md](question-ids.md). |
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

## Historical upstream counterexamples

The following paragraphs describe the original d2ad8b28 reports. All five earlier tracked
fixes are integrated at the current pin; see upstream-issues.json and the latest
pin review. Original source snapshots/negative laws remain in Git history.

[SOLID-EMPTY-FLATTEN-001](upstream/empty-flatten.md) records a current-next-head
source-only object leak for an immediately settled promise of an immediately
empty iterable. Direct/native/one-yield controls and related upstream history
were checked. The user submitted fix PR #4144; no workaround or pinned source
change is active. tracking/upstream-issues.json indexes it separately from the
semantic deviation register.

[SOLID-STAGED-ERROR-RECOVERY-002](upstream/staged-error-recovery.md) records a
successful held value thrown as an error after an earlier staged error is replaced
before landing. Eight source-only controls, sixteen parity histories and a closed
negative Bend law preserve this current-head behavior. The user filed #4145;
no workaround is active.
An unregistered bit-clearing mutation is rejected for source mismatch; that is not
a claim that the pinned behavior is desirable.

Default until's own/captured confirmation, frame delivery and truthy inPass join
now execute with 136 histories, 8192 closure probes and two closed regressions.
Natural-millisecond timeout/AbortSignal handling now has 60 option histories and
native timer controls, including the controller's exact default reason.
Arbitrary host signal/getter/callback behavior and active truth/lagging/action APIs remain unfinished; see
[until.md](until.md).

The host codec's repeated reference decoding formerly allocated fresh JS token
objects. It now uses per-runtime reference/async-object caches across all result,
trace/tree, setter/updater, promise and error paths. Strict host alias assertions
match TS, including raw cleanup errors. This repairs an adapter bug, not source
semantics or an active workaround.

Abort-reason comparisons also use the reference observer's existing async-object
identity normalization for raw thrown/rejected payloads. Native thenable rejection
reasons are not assimilated; within-runtime identity is asserted separately from
cross-runtime token comparisons. This is host observation, not error handling or
Promise resolution implemented by the adapter.

StatusError's message was formerly synthesized from the decoded cause at
observation time. It is now captured by runtime/error.bend at source wrapper
construction. Immutable built-in Error/DOMException inputs preserve native
identity and selected property/prototype snapshots, with 99 end-to-end histories
and 50 actual constructor/unwrap probes. The inventory now fingerprints class
constructors. See [errors.md](errors.md) for the admitted host domain and explicit
untranslated operations; this is a representation/port repair, not an upstream
workaround or a proof of general JavaScript error semantics.

Expression-bearing compute/application/error callback bodies now run on the
existing core read continuation machine. Effect catches/finally are explicit
source return points; named expression teardown programs now use the same driver. See
[callbacks.md](callbacks.md) for ABI boundaries, 74 histories and the closed law.

The owner literal is now shared by constructor facades and callback-based roots.
Production runWithOwner/getOwner/getObserver/isDisposed execute on the same core
continuations; see [ownership.md](ownership.md) for the admitted identity API,
73 histories, exact trace-observation repair and remaining initializer limits.

The selected init-bound disposer function family now executes with real callback
arguments and source setter function branching. The shared setter remainder
still owns equality/publication; updater-returned functions are not re-invoked.
See [arguments.md](arguments.md) for 71 histories, the closed bound-disposer law,
ABI helper laws and remaining function/constructor limitations.

Production context.ts now has separate create/get/set functions with fresh key
and copied-record identities, exact undefined/default/null rules and fresh
NoOwnerError/ContextNotFoundError constructors. 52 public histories compare
record contents, order and aliases; two closed laws cover root inheritance and
child isolation. The ambient globals helper moved to runtime/ambient.bend so
runtime/context.bend follows the source module boundary.

The selected bound-disposer family now enters signals.ts:onCleanup and the same
owner.ts:cleanup/disposeChildren operations. A canonical callback ID preserves
its identity across disposal-list registrations, while the source return value
remains the original function. 24 histories compare actual disposal aliases and
reentrant behavior; one composed closed law checks the representation and drain.
See [cleanup-values.md](cleanup-values.md); arbitrary teardown expressions remain
rejected and no scheduling/teardown workaround is active.


The source setter's captured currentValue now survives user updater calls. A
reentrant updater that stages 9 then returns its entry value 1 leaves 9 staged,
matching TypeScript; the former port incorrectly overwrote it. See
[setters.md](setters.md) for the reduced failure, source return-point split and
eleven paired histories. This is a port repair, not an upstream workaround.
Escaped data-signal setters and computed accessors now share those continuations;
computed owner disposal retains its distinct frozen-value behavior. See
[computed-accessors.md](computed-accessors.md).

Selected bound setter values now register with source onCleanup/cleanup and
runDisposal. Their native bound receiver and no-argument undefined value are
retained; writable memo targets execute setMemo's own flag/schedule remainder.
No cached read or replacement disposal walk is introduced. General teardown
expressions remain unfinished; see [setter-cleanup.md](setter-cleanup.md).

The [function-value operation review](reviews/function-values.md) records exact
pinned unit hashes, ordered source return points, tested restrictions and a
read-only impact rehearsal against the existing PR #4163 checkout. It identifies
the held wrapper, node-aware write hook and new data signal hook for a future
repin; it does not silently apply those changes or close full-domain branches.

Runtime-selected effect application returns now reach runEffect's own cleanup
assignment for admitted bound root/setter functions and undefined. The static
wrapper mode remains available; see [returned-cleanup.md](returned-cleanup.md).

Selected first-class getter/setter/root-disposer initializers now take the real
function overload and share writable-computed construction and selected setter
policy; see [callable-initializers.md](callable-initializers.md). Arbitrary
functions and read-capable owner teardown remain unfinished.

First-class named callback values now retain canonical function identity and
enter the same core call/argument, initializer and updater paths. Their imperative
teardown subset can be selected dynamically; see [callback-values.md](callback-values.md).
Read-capable teardown remains unfinished; the boundary investigation and explicit
next return points are in [the teardown review](reviews/teardown-boundary.md).

Direct disposal/effect-precleanup/recompute-preparation now suspend owner Invoke
tasks to the shared core callback machine. Thirty-five direct source probes and
a concrete cleanup-read kernel fixture check the first stage; global teardown
read admission remains unfinished. See [owner-core.md](owner-core.md).

## Reviewed pin update

The active integration branch now uses Solid 71153bf0. The three tracked failures
are fixed by accepted upstream implementations; historical records above retain
their original pin. Negative laws are retained on baseline/solid-d2ad8b28 and
replaced by positive current-pin regressions. The complete changed-file/operation
audit, inactive hook exclusions, original repro matrix and validation are in
[the pin review](reviews/solid-71153bf0.md). No active semantic deviation exists.

## Settled callback source operations

The public onSettled branches now retain their distinct owner test, tracked/untrack
wrapper, plain closure identity, heap gate, passLane routing and production return
drop. User queue entries represent actual source callable identities; no synthetic
reactive node is introduced for unowned callbacks. See [settled.md](settled.md).

## Reaction source closures

createReaction now retains the source cl/owner/arm cells, callable identities,
conditional old-arm disposal/clear, deferred ordinary user effects and assignment
order. Merged #4188 now captures the arm before tracking; pending/error replacement
and the seeded control pass positive regressions; see [reactions.md](reactions.md).

Custom comparator programs now execute through the source isSame catch and all
active write/publication/async/seam sites. The side registry decomposes function
identity without changing `_x` allocation. Default-only World facades refuse a
required custom call rather than approximate it. See [comparators.md](comparators.md)
for exact return points, source observations, evidence and remaining closure limits.
