# Direct subscription branch of `from`

At Solid next@225014bf (rc.18), `from(fn)` now executes through the same Bend
callback, owner, iterator, flight and scheduler engines as the other primitives.
This closes the callback-subscription branch; it does not complete `from`'s
Observable or wrapped-AsyncIterable branches.

## Source correspondence

| Source segment | Bend location and representation |
| --- | --- |
| `toSubscribe` function arm | `Core.fromInput`, `From.callable`; the original typed callable identity is retained |
| Returned iterable / per-iteration closure | `From.create`, `From.open`, `Core.fromOpen`; factory plans are immutable origins, each opening creates separate subscription state and next/error/complete programmes |
| `latest`, `has`, `done`, `failed`, `failure`, `waiting`, `unsubscribe`, `closed` | `FromSubscription` fields inside its StreamPlan; waiting is a native Promise identity, not another reactive queue |
| `settle`, next/error/complete callbacks | `From.settle/emitted/failed/completed`, `Core.callbackAction`; real callback argument vectors, guards and source order are retained |
| `close` | `From.close`, `Core.fromClose/fromCleanupCatch`; set closed/done and clear captured unsubscribe before invoking it, swallow user throw locally |
| Late teardown after synchronous completion/error (#4233) | `Core.fromSubscribed`; assign cleanup, test closed, clear capture, call once with the same local catch, then bind owner |
| `finish` | `Core.FromFinish/FromFinished`, `From.finish`; close first, clear buffered value and resolve waiting pull as DONE |
| `bindToOwner` | `Core.fromBind`, existing `Supersede.register`, owner cleanup; the same finish programme is captured by all routes, child-forbidden scopes skip owner cleanup |
| `next`, `return` | `From.next`, `Core.iteratorReturn`; buffered result precedes error/done tests, remaining branches allocate native Promises; return invokes finish then Promise.resolve(DONE) |
| Native Promise | `promise-input.bend`; once-only settlement and ordered external delivery jobs, without reactive publication decisions |

The ordinary iterator engine remains the consumer. Callback factory opening runs
through Core before iterator acquisition, including the deferred wrapper's
acquire-before-ask ordering. `attachIterator` and `deferredWrapped` only name
existing source continuations; old raw-stream programme budgets are unchanged.
No new World field, scheduler, publication algorithm or semantic deviation is
introduced. StreamPlan now records a tagged factory/subscription closure.

The host supplies typed user programmes and materializes their callable values.
It calls actual Solid `from`; it does not implement a subscription bridge around
Solid or run a second Bend scheduler. Source-provided callback arguments may be
captured/invoked by later programmes. Observation assigns stable opaque function
aliases when no public name exists; native functions retain their real identity.

## Evidence and proof limits

282 public differential histories compare complete observable prefixes, node and
flight posture, callback/cleanup/iterator order, errors, loading and disposal.
They include synchronous coalescing, falsy payloads, completion/error during
subscribe, late teardown, throwing unsubscribe, async pushes, stale callback
suppression, replacement, shared factory reopening, deferred and ordinary memos,
truth waiters and typed no-op teardown values. These bring the corpus to 4,234.

288 separate private factory controls inspect binding before the outer consumer
installs its own teardown. They compare fresh/active flight slots, direct/chained
hook identity, child-forbidden scopes, shared finish capture and unsubscribe
errors against unchanged Solid. They do not count as public histories.

The independent kernel proves a complete fixed subscription programme: real
owned memo/from construction, a synchronous buffered read, root disposal and
flush, for every admitted ordinary payload and every budget >=120. The exact
final Machine is checked; a corollary proves the returned array contains that
payload and exactly one unsubscribe trace, with Healthy fault. Ordinary payloads
include arbitrary booleans, naturals, strings and opaque reference identities,
undefined/null, NaN and negative zero. Fourteen finite representatives separately
check every one of the 120 prefixes, three sufficient budgets and native value/
identity/cleanup behavior. This programme has one fixed producer/graph shape;
queued native Promise delivery remains an external input, and arbitrary async
histories or arbitrary subscriptions are not proved by this theorem.

Fourteen additional local laws quantify over arbitrary surrounding Worlds. They
cover no-wait settlement, ignored emission after done, closed/open close states,
finish without a waiter, Promise allocation/identity/once-only settlement,
empty observer delivery and local cleanup catch/continuation behavior. Proof-only
single-operation expansions expose guards; the runtime is not altered for them.
All preceding complete-programme domains and sufficient budgets remain unchanged.

Twelve new compiled negative controls target payload/buffer/waiter loss,
unsubscribe and late-teardown omission, owner hooks/forbidden cleanup/wrong
finish identity, escaping unsubscribe errors and stale pushes, plus three kernel
properties. Configuration is 551 (459 finite, 92 kernel). The frozen complete
539-variant rc.18 receipt predates this extension and is kept separate.

## Explicit omissions and source defects

Observable/interop objects, object `.unsubscribe()` teardown, wrapped input
AsyncIterables, arbitrary protocol getters/methods, manual async-generator user
bodies and nonproduction diagnostics remain unfinished. Non-callable input is
an explicit Unsupported boundary, not a fabricated source TypeError. Typed
opaque data has no observable properties. No public `onSupersede` API is invented.

Bug010 remains preserved: a subscribe throw reached during an answered deferred
stream acquisition can leave the previous flight alive. The source-function
catch has already ended before that acquisition. Twenty added factory-throw
controls retain this symptom; it is not silently fixed or a new issue report.
Merged #4233 is now integrated for the admitted direct-subscription branch;
Observable teardown and wrapped-iterable completeness are not claimed.
