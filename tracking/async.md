# Promise-like flight milestone

Pinned source: Solid d2ad8b288886a5c7171e6746ccc019ad1d08d8ab,
production full signals index. `core/async.ts:handleAsync` remains a partial port.
This milestone admits ordinary thenables whose settlements are non-async payloads.

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

## Unfinished branches

Async iterables, initial iterator draining, pump cancellation/return, promise-to-
iterable flattening, projection setters/onError callbacks, arbitrary then/getter
exceptions and adversarial multi-callback thenables are not admitted. Nested
promise assimilation is also outside the settlement payload grammar. Active
boundary/lane/mark/store hooks and public actions/refresh waiters remain open.
The installed full-index hook bodies are inert only for the admitted scope.
An attempted composed loading-seed/landing proof exhausted the pinned independent
kernel's reduction fuel, even after narrowing to tree text and splitting named
construction stages. The frontend accepted it; the kernel did not validate it.
Those attempted laws are not active or counted. The existing nine composed
concrete regressions remain the proof frontier; async evidence here is tested.
No general async consistency, progress, TS-equivalence or host-runtime proof is
claimed. Pins and source branch obligations remain unchanged/open.
