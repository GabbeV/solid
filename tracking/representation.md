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
child-ID generation and snapshot capture remain unfinished. `scope` now stores
an inherited ContextRecord identity used by translated context lookup/copy-on-write
operations; see [contexts.md](contexts.md).

The explicit-parent API facade installs/restores owner and tracking state to
express the TS test host's `runWithOwner` boundary. The primitive constructor
does not introduce a new owner scope. Root `_parentComputed` is retained and used
at constructor height setup, heap insertion and read-observer selection. Nested
root construction/forwarding have focused probes; function-initializer signals, escaping new accessors and arbitrary host closures remain unfinished; nested memo reads and user/render effects execute as documented in [nested.md](nested.md);
root callbacks and selected bound-disposer arguments now execute. Cleanup and reentrant
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
| `_error`, `_shownError` | `Value`, including distinct undefined/null/false | Commit's nullish error gate and shown-error clearing. Identity-bearing StatusFailure wrappers retain source/cause and propagate through synchronous error paths. NotReadyFailure retains identity/source; pending helpers and typed flight callers execute. |
| `_inFlight`, `_flightTeardown`, `_unobserved`, `_transaction` | Nullable stable host identities | Default initialization and unobserved installer; sync pass and owner death clear flight identity. Restricted cancellation/unobserved callbacks, ordinary promise settlement, typed iterator consumption/close and mainline transactions execute. Arbitrary iterator methods and active scopes remain unfinished. |
| `_blocked`: undefined or boolean | Optional `Slot(Boolean)` | Loading park/settle and self-only landing helpers retain blocked semantics; actual typed async callers execute. |
| `_pendingSources`: undefined or Set | Nullable handle into World.pendingSets; view-only NoSources/Sources | Stable aliased sets, tombstone/live iteration, propagation and retirement; typed flights/mainline transactions execute. |
| `_snapshotValue`: undefined, `NO_SNAPSHOT`, or payload | `NoSnapshotValue`, `UndefinedSnapshot`, `SnapshotValue` | Storage/default only; snapshot engine unfinished. |
| `_pendingFirstChild`, `_pendingDisposal` | Nullable child ID and explicit absent/single/list disposal shape | Source parked teardown is integrated with commit/recompute and exception unwinding; directly compared against TS. |
| `_reask`, `_q`, `_marks` | Boolean, exact binary Question, natural mark handle | Quiet reask metadata and flight provenance execute; question stores/counters are distinct. Active action/mark scopes remain unfinished. |

Commit tests compare null/undefined/error-false separately: `_error == null` is
not a truthiness test. The stash helper preserves the first flushed staging in
one clock even across later rewrites, including undefined, and exposes it only
under the source guards. Held-frame transactions, setter joining and the stash caller now execute through
the same runtime, with separate end-to-end/closed-proof evidence; direct probe
counts remain distinct from that composed evidence.

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
tokens. It does not implement arbitrary host closures, arbitrary iterator callbacks or
pending/async and boundary error paths. World.dormantNodes represents the source Set as
an ordered unique-ID list; sweeps re-read its live bound and clear only on success.
Graph callback recursion shares owner tasks; pure pointer operations live in
graph-state.bend, avoiding a Bend import cycle without substituting a graph walk.
The owner machine's task fuel is a resource limit, not a general progress theorem.

Synchronous throws use CallbackThrown(Value) only while unwinding a source call.
The host consumes that outcome before a later call, preserving the mutated world.
StatusFailure has a stable per-world identity, source ID, captured message and
recursively retained cause. runtime/error.bend captures that message at the source
constructor seam; the decoder only materializes the recorded result. Error
propagation preserves the same identity; effect-phase catch allocates
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

Typed StreamPlan/NextInput records supply external iterator method responses.
ExternalIterator keeps the per-consumption producer cursor; StreamState keeps the
engine callback closure's hadValue/completed/initialRead/syncValue and close token.
AsyncObserver.stream distinguishes next callbacks from ordinary fulfillment and
rejection; node-zero observers express swallowed return rejection. Owner cleanup
programs contain an explicit close action, sharing the source flightTeardown
callback identity with disposal. IteratorEvent records method IO only.

Awaiter stores the public promise closure's expression/refresh target, captured own
transaction, root, watcher node and first settlement. WatchStart/WatchDelivery are
microtask IO; PromiseOutcome is synchronous native resolve/reject IO before the
callback's disposal. WatchExpr/WatchFinish retain the callback catch/return edge
inside the actual computation. Known truth/confirmed installers have separate
Boolean presence tags; active truth/lagging scopes remain unfinished.

Question identities now use canonical bijective binary naturals, preserving exact
source values without forcing the kernel to unfold the 0x7fffffff mainline ID as
billions of unary constructors. World.questions is the sequence counter, separate
from ambient World.question. See [question-ids.md](question-ids.md) for numeric
source comparisons, general helper proofs and five composed async laws.

Awaiter.until selects the predicate callback, while confirmation retains
until's pre-root transaction t separately from watch's own. makeWatch captures the
default own at the source watch call; refresh passes its earlier explicit own.
Falsy until delivery keeps the root and watcher subscribed. Awaiter.timer/onAbort
represent the definedness of the source closure locals; they retain their values
after cancellation, as the source does. The awaiter ID identifies each external
timer handle and abort callback. Awaiter.signal indexes AbortInput snapshots of
the host's aborted/reason properties. The adapter installs each snapshot before
native AbortController dispatch and uses actual add/removeEventListener with
once:true; it does not decide watcher settlement or disposal.

StartTimeout/CancelTimeout/ListenAbort/UnlistenAbort are ordered synchronous host
IO requests, not microtasks. TimeoutFailure carries a fresh error identity;
decoding preserves Error/name/message and object identity for the default
core/error.ts TimeoutError constructor. Its serial shares the internal error
identity arena, without wrapping the timeout as a StatusError. The error's stack
and arbitrary host Error objects are not represented. Delays are natural integer
milliseconds through 2^31-1; explicit abort reasons use the admitted Value grammar.
Default abort now retains the native controller's actual DOMException identity.
ExternalError stores selected immutable host properties and a disjoint explicit /
native identity namespace. See [errors.md](errors.md) for admitted types, message
capture, alias checks and remaining host limits. Arbitrary signal/option getters
or callbacks remain unfinished. Timers may be native or an explicit-delivery
test environment; no native clock timing or timeout/abort law is proved.

Named callback programs now admit expression statements, early returns and
evaluated writes/throws on the core machine. Callback tasks are user-code ABI
continuations, not source scheduler operations. Effect application/error arms
have explicit source catch/finally return points. Teardown expression callbacks
are still outside the grammar and rejected before attachment. See [callbacks.md](callbacks.md).

OwnerReference carries stable native owner identity in a namespace separate from
application references. getOwner/getObserver, storage, equality, isDisposed and
runWithOwner consume these handles; arbitrary owner reflection remains open.
RootScope allocates the shared production literal and restores ambient owner and
tracking on success/throw. Initializers now receive a selected RootDisposerReference value; bound function
invocation and explicit root-handle methods both execute disposeRootSelf. See
[ownership.md](ownership.md) for observations and source boundaries.

RootDisposerReference has its own identity namespace and native callable cache.
Named callback arguments are bound by substitution across the admitted expression
grammar, stopping at fresh root init binders. Updater-returned functions remain
data; raw function setter inputs execute first, as source setSignal requires.
See [arguments.md](arguments.md) for the exact family, observation rules and limits.

Context keys and record arenas model fresh Symbol and spread-object identities.
The source context module is runtime/context.bend; ambient owner/tracking stores
are runtime/ambient.bend. ContextFailure represents the two production context
Error subclasses. See [contexts.md](contexts.md) for the exact domain.

Root-disposer data identities have a canonical, lazily materialized callback-arena
encoding for disposal slots. Repeated registrations share that encoding, preserving
source function alias relations. CleanupBoundRoot invokes the same owner machine
with the bound root and self=true. See [cleanup-values.md](cleanup-values.md).

Nested `createMemo(compute, options)()` expressions share constructor literals/setup
with standalone construction, then resume the core driver. The expression-local
accessor does not yet escape into general closures. Local signal const-pair bindings and
captured inline application bodies now execute; see [locals.md](locals.md). See [nested.md](nested.md).


`AccessorReference(signal)` is a separate function identity for the selected
escaped data-signal read family. Lexical binding retains the allocated signal ID;
invocation resumes ordinary core reads. The native codec caches one callable per
signal and performs no reactive work itself. Its strong caches are not a memory
or performance equivalence claim. Data-signal setter and computed accessor values now execute as well; see
[setters.md](setters.md) and [computed-accessors.md](computed-accessors.md).
Function reflection and general teardown reads remain unfinished. See [locals.md](locals.md).

CleanupBoundSetter is a canonical callback-arena identity for a constructor's
bound setter, separately from CleanupBoundRoot. It preserves the captured node
and no-argument call through the ordinary owner machine. Getter and arbitrary
expression callbacks remain unfinished; see [setter-cleanup.md](setter-cleanup.md).

Selected first-class getter/setter/root-disposer initializers now take the real
function overload and share writable-computed construction and selected setter
policy; see [callable-initializers.md](callable-initializers.md). Arbitrary
functions and read-capable owner teardown remain unfinished.

First-class named callback values now retain canonical function identity and
enter the same core call/argument, initializer and updater paths. Their imperative
teardown subset can be selected dynamically; see [callback-values.md](callback-values.md).
Read-capable teardown remains unfinished; the boundary investigation and explicit
next return points are in [the teardown review](reviews/teardown-boundary.md).

For upstream #4164, World.deferredReleases is a nullable-array handle (zero is
null), and releaseLists is its stable list arena. It is separate from pending Sets:
array duplicates and live bounds are retained. PassFrame.released captures each
pass's array; the prior active handle restores only after successful pre-body
teardown, matching Source. PassReleases resumes callbacks through the existing
core machine after context restoration. See [the pin review](reviews/solid-71153bf0.md).
