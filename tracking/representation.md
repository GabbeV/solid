# Constructor and extension representation

The active constructors are `runtime/construct.bend:signal`, `computed`,
`createEffectNode`, `setupComputedNode` and `createOwner`, corresponding to the
separate pinned production literals. `api.allocate` has been removed. Each
constructor uses its source option masks; `CONFIG_SYNC` is opt-in. Effects use
their own lazy/uninitialized literal and skip memo-only option arms. Loading
presence is a `Slot`, so an explicit undefined seed differs from no seed.

The Bend `Node` is a tagged arena record containing the union of fields these
source shapes need. A signal's inactive owner/computed fields have representation
defaults; source membership tests use `NodeKind`, not those defaults. This does
not reproduce or claim JavaScript hidden-class layout/performance. Stable arena
IDs model identity. They are not Solid's hydration ID strings: `inheritId`,
child-ID generation, snapshot capture and context-map APIs remain unfinished.
`scope` stores an inherited context identity; it does not implement lookup.

The explicit-parent API facade installs/restores owner and tracking state to
express the TS test host's `runWithOwner` boundary. The primitive constructor
does not introduce a new owner scope. Root `_parentComputed` is retained and used
at constructor height setup, heap insertion and read-observer selection. Nested
root construction/forwarding have focused probes; full nested callback creation,
root callback API and arbitrary host closures remain unfinished. Cleanup and reentrant
teardown run through the owner continuation machine.

`Node.x = 0` is null. `runtime/extension.bend:ext` lazily appends the source
default extension once, saves a stable nonzero ID, and reuses it on later calls.
The arena's index zero is an inert fallback record, never an allocated live
extension. The two concrete chain proofs check that only that reserved entry
exists after their ordinary synchronous executions.

| Source field/sentinel | Bend representation | Active behavior |
| --- | --- | --- |
| `_notifiedAt`, `_flushedAt`: -1 or clock/epoch | `Unstamped` or `Stamped(Nat)` | Notify rewrite fast path, held-stash bookkeeping. Epoch now starts at source zero; no offset convention. |
| `NOT_PENDING` or payload | `Empty` or `Present(Value)` | Pending slot, flushed stash and lane storage distinguish staged undefined. Lane engine is unfinished. |
| `_error`, `_shownError` | `Value`, including distinct undefined/null/false | Commit's nullish error gate and shown-error clearing. Identity-bearing StatusFailure wrappers retain source/cause and propagate through synchronous error paths. NotReadyFailure retains identity/source; pending helpers execute, while flight callers remain unfinished. |
| `_inFlight`, `_flightTeardown`, `_unobserved`, `_transaction` | Nullable stable host identities | Default initialization and unobserved installer; sync pass and owner death clear flight identity. Restricted cancellation/unobserved callbacks execute; promise settlement, the full iterator protocol and transactions are unfinished. |
| `_blocked`: undefined or boolean | Optional `Slot(Boolean)` | Loading park/settle and self-only landing helpers retain blocked semantics; actual async callers unfinished. |
| `_pendingSources`: undefined or Set | `NoSources` or `Sources(List)` | Unique ordered-ID set helpers implement registration, propagation and retirement; empty retirement restores absence. Actual flights/transactions remain unfinished. |
| `_snapshotValue`: undefined, `NO_SNAPSHOT`, or payload | `NoSnapshotValue`, `UndefinedSnapshot`, `SnapshotValue` | Storage/default only; snapshot engine unfinished. |
| `_pendingFirstChild`, `_pendingDisposal` | Nullable child ID and explicit absent/single/list disposal shape | Source parked teardown is integrated with commit/recompute and exception unwinding; directly compared against TS. |
| `_reask`, `_q`, `_marks` | Boolean and natural counters | Default storage; sync/commit reask reset. Question/mark engines unfinished. |

Commit tests compare null/undefined/error-false separately: `_error == null` is
not a truthiness test. The stash helper preserves the first flushed staging in
one clock even across later rewrites, including undefined, and exposes it only
under the source guards. These direct state probes do not implement a held-frame
transaction program. `setSignal` still lacks held-transaction joining and the
stash caller path; actual held writes must wait for that translation.

Public host options cover default equality/false, transparent/ownedWrite/lazy/sync,
noSnapshot masks and synchronous loading seeds. `unobserved` resolves a named executable callback program; `_extraConfig` stays
primitive-only. Options with getters, custom comparators,
arbitrary thenable-shape probing remains outside the grammar. Typed ordinary promise-like objects and loading suspension execute.

Owner cleanup uses a separate defunctionalized callback protocol:
`World.cleanupPrograms` assigns a stable callable identity to a reusable sequence
of emit/dispose/register/throw actions. A stored disposal keeps its absent/single/
array form; array callbacks run from the end. The list and effect cleanup token
are detached at the source sites before any callback executes. A callback throw
aborts the owner continuation with an explicit `CallbackThrown(Value)` outcome;
it is not a reactive status error or successful cleanup. Reentry returns through
the same owner machine. JavaScript `this` inspection and mutation of a captured
disposal array are outside this protocol. The source probes preserve `.call`
receiver checks for disposal callbacks and the plain-call effect cleanup.

The same protocol executes compute/effect programs and signal writes through the
one shared setter, installs returned cleanup, and invokes unobserved/cancellation
tokens. It does not implement arbitrary host closures, the iterator protocol or
pending/async and boundary error paths. World.dormantNodes represents the source Set as
an ordered unique-ID list; sweeps re-read its live bound and clear only on success.
Graph callback recursion shares owner tasks; pure pointer operations live in
graph-state.bend, avoiding a Bend import cycle without substituting a graph walk.
The owner machine's task fuel is a resource limit, not a general progress theorem.

Synchronous throws use CallbackThrown(Value) only while unwinding a source call.
The host consumes that outcome before a later call, preserving the mutated world.
StatusFailure has a stable per-world identity, source ID and recursively retained
cause. Error propagation preserves the same identity; effect-phase catch allocates
a new wrapper while escaping with the raw payload. The expression machine saves
the caller value stack on each compute frame so a caught nested throw cannot leak
partially evaluated operands. Finally callbacks execute with a suspended outcome;
a new throw from trimming overrides the prior one at the source return edge.

World.halted/haltNotified and ordered RuntimeReport records express production
scheduler halt/logging state. The admitted host installs no global reportError
callback. World.callbackEffect is an ABI parameter slot for the cleanup helper
passed to a user error program; it does not change reactive context/tracking, and
is restored on success/throw. This protocol does not expose arbitrary JS errors,
receiver inspection, reflection, reportError callbacks or arbitrary closures.

NotReadyFailure is separate from StatusFailure: it has a stable identity and
nullable source without a user cause. Both draw identities from World.errorSerial,
so storing or propagating the same object preserves strict equality. Pending sets
are node-owned stable handles with ordered unique-ID membership. removePendingSource returns
both updated world and source bool, and resets the empty set to NoSources.

The pending settle machine keeps a local visited set and deferred release list.
Its early retryReaches return does not mark a node visited: another carrying branch
may retire later in the same walk. Dependency scans include the retained tail.
Deferred owner release starts only after dependent traversal and precedes final
scheduling, including exception partial states. These helpers now connect
ordinary promise registration, core NotReady catch/read logic and held transaction
joining. Active boundary interception remains unfinished.

Transactions are stable arena IDs with every pinned source field retained. Live
transactions are an ordered ID list separate from retired arena records. World
stores flushTransaction/passTx/passLane/judge and deferred zombies. Joins preserve
source redirect resolution and node-stamp compression; frame holds traverse live
children, and the settle machine retains own queues across reverse live landings.
Marks and linked-lane arrays remain storage-only; installed hook behavior for
active boundaries, lanes, affects and stores is unfinished.

Pending Set storage now uses nullable handles into World.pendingSets. A captured
outgoing set remains live after the node drops/replaces its reference. Deletion
leaves internal zero tombstones (all member IDs are nonzero), so an iterator's
cursor survives earlier deletions and observes later appends. View-only SourceSet
values expose absence versus current members to probes/proofs; they are not the
stored mutable Set. This repairs alias fidelity before connecting pending catches.

The internal NotPendingToken payload represents the exact NOT_PENDING object if a
synthetic staged-error commit consumes an empty slot. Source normally stages a
wrapper there, but the helper reads its pending slot, never its prior value.
The token is separate from Empty, undefined and user values; no public encoding
for this private sentinel is exposed.

AsyncValue is a stable external object identity, separate from opaque Reference.
World.asyncObjects retains settlement state and subscription order; AsyncObserver
records each then callback closure and its isSync/resolved/rejected locals. A node
stores the RESULT identity in its existing inFlight slot, never the observer ID.
World.hostJobs records external callback and queueMicrotask(flush) requests. The
host drains this IO in its native microtask queue; Bend makes every reactive
decision. See [async.md](async.md) for the admitted protocol and evidence.
