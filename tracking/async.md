# Promise-like flight milestone

Current source: Solid 71153bf0dbd1325cf29f81cb1e7a34e380e694d2,
production full signals index. `core/async.ts:handleAsync` remains a partial port.
This milestone admits ordinary thenables and typed async-iterator descriptors, including one-level promise-to-iterator flattening.

## Source locations and runtime path

- `runtime/core.bend:finishResult/finishShape` retain recompute's CONFIG_SYNC,
  self-registration and object-result branches. Ordinary non-async objects use
  handleAsync's synchronous landing behavior. AsyncValue is the explicit host
  representation of an object already classified as a thenable; arbitrary shape
  probing/getters are unfinished.
- `runtime/flight.bend:register` stores the RESULT object's stable identity,
  question provenance and undefined pending-source set, in source order.
  AsyncObserver retains the callback closure's node/result and synchronous locals.
  Observer IDs do not replace result identity: multiple registrations of the same
  object remain callbacks for the same flight.
- Core's `subscribeState`, `AsyncFulfill`, `AsyncReject`, and `AfterThen` express
  `.then`'s call/return edge. `flight.thenResult` chooses the immediate rejection,
  loading-seed answer, NotReady throw, or immediate fulfillment after isSync=false.
  A throw still reaches the active recompute catch/finally.
- `flight.handleError` keeps identity checking, loading-window parking, staged
  errors, pending transfer, time and settled-dependent release. `flight.asyncWrite`
  keeps identity/dirty guards, landStatus, comparator containment, first-observable
  loading closure, trim, self retirement and scheduling. Core's `AsyncFlush` calls
  the existing flush machine before `SettleAuto`; a throw skips that continuation.
  Ignored stale/dirty writes still reach settleAutodispose, as the source closure
  does. Rejection does not add a source-absent explicit flush.

## Host boundary and evidence

AsyncObject records external settlement and immediate-versus-microtask callback
mode. The external resolve/reject API settles once, then delivers callbacks in
registration order. No dependency, transaction, commit or effect decision is made
by the JavaScript adapter. World.hostJobs is an ordered IO outbox: DeliveryJob
requests a callback microtask and FlushJob requests source `queueMicrotask(flush)`.
`BendRuntime({async:true})` drains those requests using queueMicrotask. The existing
synchronous harness leaves the outbox undelivered and explicitly calls flush.
Neither harness waits for all outstanding promises to settle.

The reference uses actual native Promise reaction jobs behind its deferred
PromiseLike object, and a controlled `.then` method for immediate callbacks. Its
observation wrapper captures exceptions escaping the actual engine callback;
Bend records the same host callback outcomes. A macrotask checkpoint observes all
currently queued microtasks, including recursively queued work, without resolving
or waiting on any unresolved external object. Other histories observe individual
microtask turns.

68 histories compare returned/thrown values, wrapper identity/source/cause,
compute/read/apply/cleanup order, text, reports, callback failures and restored
ambient state after every operation. They include loading payloads undefined,
null, false, zero, NaN and reference identity, supersession and dirty-write races,
shared/re-registered promises, sync opt-out, equal answers, errors, disposal and
unobserved hooks. 4,096 direct helper-state comparisons additionally cover
registration, immediate verdicts, status/error/source slots, dirty/identity guards,
held staging, loading parks, graph detachment and autodisposal. Synthetic internal
states in this matrix are branch probes, not package-level programs.
Two additional mutation checks reject stale-flight acceptance and treating an
unresolved thenable as an immediate answer; six mutations are rejected in total.

An initial timing mismatch was a reference-adapter mistake: fresh Bend worlds
were compared to a reused TS singleton whose heap minimum/marked memo reflected
previous histories. Every async history now imports a fresh unchanged full-index
bundle instance. The reduced single-history control matched without an engine
change. This is not an upstream bug or a semantic deviation.

## Iterator continuation milestone

`iterator-state.bend` represents external iterable plans/iterator cursors and the
source consumeIterator closure (hadValue/completed/initialRead/syncValue). All
external async objects share one identity arena, so a stream and a promise cannot
collide in the inFlight guard. NextInput supplies bare results, existing thenable
objects or throws; a stream plan is an external producer's method data, not a
replacement reactive algorithm. Every consumption allocates its own cursor.

Core consumeIterator registers close on the ambient owner for LIVE consumption,
or directly on the node for deferred flattening, then stores the same callback
in flightTeardown. Close marks completed before return; return throws and returned
promise rejection are swallowed. Owner disposal and supersede use this same close
program, making repeated closure idempotent. Iterator next/return calls are separate
host observations, compared in exact order.

The IterateStream / AfterStep / AfterConsume return points retain the source
recursive drain. Only isSync AND initialRead stashes a step. A bare or immediately
settled step after an async gap publishes through asyncWrite, flushes, then checks
autodisposal before the next pull. A stale/dirty ignored write does not continue
the pump. Empty completion, later rejection, and initial throw keep their distinct
source continuations and exceptional partial states. Promise fulfillments flatten
only under the source identity/disposed guards; initial and deferred postures use
their different cleanup and publication paths.

255 iterator histories (including 192 seeded generated schedules) now compare
next/return IO, traces, screens, throws/reports and node state after every action.
Node-state observations also strengthen all 68 promise histories: flags/config,
status/time, loading/value/staging, generation, previous/effect-modified state,
flight identity, teardown/disposal presence, error/shown/blocked/source slots are
checked against the unchanged TS nodes. Read-only observation captures the fresh
node's actual NOT_PENDING sentinel; it does not change source functions. User
program trace labels are independent of internal auto-close callback arena IDs.
Two iterator mutations reject lost post-gap synchronous yields and omitted return;
the iterator/flight and public-watcher mutations are joined by a source-counterexample guard and a falsy-until guard: twelve source-changing variants are rejected.

The immediate empty-flatten object leak is preserved, with 18 independent
source-only paired controls and a current-head/history investigation in
[the bug-candidate record](upstream/empty-flatten.md). No deviation or fix is active.

## Unfinished branches

Arbitrary shape/getter/factory/then callbacks, malformed IteratorResult values,
adversarial multi-callback thenables, arbitrary return side effects, projection
setters/onError and nested promise assimilation are outside the admitted protocol.
Fixed next/return descriptors express the admitted external producer; they do not
claim arbitrary JavaScript closure support. Active boundary/lane/mark/store hooks
and public actions remain open. Resolve/refresh watchers now execute in their restricted scope; see [watchers.md](watchers.md). Installed full-index hook bodies
are inert only for the admitted scope.

The earlier composed-proof fuel failure is now diagnosed and repaired as an
exact question-ID representation cost: see [question-ids.md](question-ids.md).
Five closed loading/landing/supersession/diamond laws now pass the independent
kernel directly through the active API/driver. Settlement is an explicit external
thenable input; native job timing, iterators and watchers remain tested domains.
No general async consistency, progress, TS-equivalence or host-runtime proof is
claimed. Pins and source branch obligations remain unchanged/open.

The reviewed pin update replaces the empty-flatten leak and adds Source's catches
for later iterator pulls and deferred thenable-to-stream setup. The typed protocol
now routes later-next throws to the memo via ProtocolCatch; source owner-target
close registration shares owner.cleanup. Custom comparator execution and hostile
protocol getters remain unfinished. See [the pin review](reviews/solid-71153bf0.md).

## Owner callback continuation completion

AsyncWrite, settleAutodispose, handleError, pending-source/error release and
recompute outgoing-source retirement now suspend into the shared owner/core
callback machine. Equal-valued landing trims before flush, while a changed
staged answer may trim at commit. Both controls, throwing/pending callback reads,
iterator release/close and captured multi-dependent release are tested.
[The operation review](reviews/teardown-closure.md) records public admission,
remaining callable exclusions and three concrete async cleanup laws. The source
pin and upstream collector regression remain unchanged.
