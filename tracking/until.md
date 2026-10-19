# Until watcher and cancellation

`signals.ts:until` now executes for expression predicates with no options and
natural-millisecond timeout/explicit-reason AbortSignal options. This
uses the same watcher, pending/error catches, frame rule, heap, owner teardown and
native-promise IO as resolve/refresh. Active optimistic / deferred-truth scopes,
arbitrary host getter/callback behavior and default AbortError objects remain
unfinished. Option support has separate differential evidence below.

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

`api.untilValue` and host awaitUntil(name,expr,options) expose these admitted paths. Returned
external thenables would require the richer native assimilation protocol already
listed for the other public watchers; it remains unimplemented. The next source
work is richer host errors/callbacks and active truth / lagging and public action
scopes. Default-path tests/proofs do not close those branch obligations.

## Timeout and abort operation correspondence

signals.untilOptions follows the Promise executor: inspect the captured external
signal, reject an already-aborted signal before allocating a root or evaluating
the predicate, capture t, create the root/watch, then register timeout followed by
the abort listener. Zero timeout is present; an explicit undefined timeout is not.
untilResources represents those registrations as host IO after the initial pass,
even when its answer is already queued. settleUntil follows the source closure:
clear timeout, remove abort listener, resolve/reject, dispose the root. It adds no
settled guard around cancellation/disposal. Only native Promise resolution is
once; an already queued answer can invoke the closure again after abort/timeout.

timeoutUntil and abortUntil retain the source's inner fire closures as UntilFire
descriptors. Only after cancellation does fireUntil construct a new TimeoutFailure
identity (mapped to the source TimeoutError name/message/Error shape by the host
codec), or read reason from the captured signal snapshot. AbortSignal dispatch and
timer callback delivery are external inputs; all watcher and disposal decisions
stay in the Bend runtime. The existing foreign-frame and inPass paths are shared.

52 option histories compare ordered set/clearTimeout and add/removeEventListener
calls in addition to node state, execution traces, promise observers, reports,
escaping callbacks and ambient restoration. They cover pre-abort without running
the predicate, falsy/initial-truthy/error cases, cancellation races, repeated queued
answers, shared signals, zero/large delays, async pending/fulfillment/rejection,
lazy observation and cleanup throws. Independent native tests reject a falsy
predicate, resolve an immediate truthy one, check fresh/cached timeout identity,
and preserve reference/thenable abort-reason identity in both runtimes. Native
AbortController supplies abort dispatch in all option histories; source function
bodies are unchanged. Delays in these controlled histories are explicit host
deliveries, not a model of elapsed wall time or browser task scheduling.

Admitted delays are integers 0..2^31-1 milliseconds. Abort requires an explicit
non-undefined reason in the existing payload grammar; default AbortError objects,
arbitrary structural signal implementations/getter throws, reentrant host calls
from user callbacks and returned-thenable assimilation remain unfinished. No
semantic workaround is introduced. The two default-path closed laws remain
unchanged; no new timeout/abort theorem is claimed.
