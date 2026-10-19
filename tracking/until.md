# Default until watcher

`signals.ts:until` now executes for expression predicates with no options. This
uses the same watcher, pending/error catches, frame rule, heap, owner teardown and
native-promise IO as resolve/refresh. Timeout, AbortSignal and active optimistic /
deferred-truth scopes remain explicit unfinished branches. No option support is
inferred from the default-path evidence.

The predicate is authoritative from its first pass. Falsy answers still queue an
onValue microtask, whose callback leaves the promise and root alive. A later truthy
answer or error settles the promise before disposing the root. An already queued
truthy answer is not rechecked against a later falsy pass: it remains an answer,
as in the source. Errors are unwrapped by watch; NotReady remains pending.

Awaiter keeps the source's two transaction captures separately: own is watch's
reader frame (captured at the watch call), while confirmation is until's t,
captured before root creation. For a successful truthy predicate, inPass runs
AFTER watch's foreign-frame gate. It resolves confirmation's redirect, checks the
open count and running flush, then calls the shared joinFuture with the original
transaction. Error/falsy/closed/outside-flush cases skip that join. The checks and
stores are in watch-state.untilInPass; callbacks are delivered by signals.deliver.
These are the source operations, not a separate waiting or publication algorithm.

136 default histories (96 generated) compare node state, returns/throws, traces,
promise delivery and observer-time screen, reports/host failures, and ambient
restoration. They cover all admitted falsy payload classes, truthy values, lazy /
pending sources, errors, repeated frames, stream yields and cleanup exceptions.
8,192 focused comparisons invoke the actual captured source until closure under
synthetic transaction/flag/open/running/redirect states. They compare the complete
join/merge/rerun/delivery outcome, including the inPass branch. No source function
is rewritten; only private reset/observation exports are appended. These synthetic
states do not establish public action/lane support.

Two closed kernel laws additionally check the public default entry and real
watcher: until_false_waits verifies that its queued zero callback leaves the
promise pending, root/watcher alive and signal observed; until_truthy_resolves
checks the queued 7, native PromiseOutcome IO, root/watcher death and dependency
release. Both check emitted callback payload/order, actual delivery, empty reactive
queues, restored ambient state and successful completion. Host callback delivery
is an explicit input; native timing/timeout/abort/general predicates are not proved.

`api.untilValue` and host awaitUntil(name,expr) expose this admitted path. Returned
external thenables would require the richer native assimilation protocol already
listed for the other public watchers; it remains unimplemented. The next source
work is timeout/AbortSignal registration and cancellation, then active truth /
lagging and public action scopes. Default-path tests/proofs do not close those
branch obligations.
