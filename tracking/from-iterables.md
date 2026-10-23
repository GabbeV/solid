# Wrapped AsyncIterable branch of `from`

The direct subscription checkpoint at 16f33b1 is extended to the typed
`from(asyncIterable)` branch at Solid next@225014bf (rc.18). The source remains
unchanged and the deviation register remains empty. Observable/interop objects
and object unsubscribe are still open; this is not a claim that all `from`
inputs or arbitrary JavaScript protocol bodies are implemented.

## Operation correspondence

| Source `wrapIterable` segment | Bend |
| --- | --- |
| Returned factory / inner acquisition | `FromIterable` origin, `Core.fromOpenState/FromWrapOpened`; call inner factory once before allocation/binding; nested typed factories re-enter Core; a deferred result's cached factory returns its original iterator |
| Captured inner, closed, pending resolve Set, finish | `FromWrapped` inside StreamPlan; pending is an insertion-ordered list of distinct native Promise resolver identities |
| `next(...args)` | `iterator-methods.bend:nextDepth`; closed returns a fresh native resolved DONE Promise; otherwise forward the exact argument slot to inner next; bare result and throw pass through |
| Native Promise executor / `step.then` | `Wrapped.wrapInput/observerState`; allocate fresh native output, add resolver, register actual inner observer, preserve immediate versus queued callback delivery |
| Promise callbacks | `Wrapped.deliver`; delete the captured resolver if present, then resolve/reject output; callbacks after cancellation cannot change it |
| `finish` | `Core.FromWrappedFinish`, `Wrapped.finish`; already-closed returns DONE; otherwise closed=true, resolve every pending pull in insertion order, clear Set, then invoke captured inner return with **no arguments** |
| Return catch / ignored rejection | `Core.FromWrapFinishFinally`, existing `ignoredReturn`; user return errors are swallowed locally; returned thenables receive the existing rejection-swallow observer |
| Binding / `return()` | Existing `Core.fromBind/fromSetFinish`, internal onSupersede and owner cleanup; return invokes that same finish identity, then allocates native Promise.resolve(DONE) |

Pending wait metadata records the `.then` callback's captured plan/output IDs.
Lookup recovers those closures before the existing deferred/action/flight
observer selection. It makes no publication or scheduling decision. No World
field, new pump or substitute reactive engine is added. All native Promise
resolutions queue reactions; resolving the pending Set cannot re-enter it during
the source loop.

Iterator references in the admitted grammar form an allocation-ordered DAG.
The method dispatcher uses the existing iterator arena's size as a structural
lookup-depth bound. It does not cap the number of source steps or pending pulls;
a malformed cyclic internal reference fails explicitly. Arbitrary JS factories
that return themselves or arbitrary recursive method bodies remain outside the
grammar. Existing deferred wrapper methods keep their argument behavior and
first-result boundary; `afterNext` only names their original post-call segment.

## Validation and formal scope

204 public histories compare every value/error/flight/trace and external
iterator/then registration prefix against actual unchanged Solid. They cover
bare and promised steps, immediate/native callbacks, settled-before-open,
loading and lazy inputs, refetch, supersession, missing/throwing/promised return,
repeated source opening, up to three nested wrappers and wrapped callback
subscriptions using a shared iterable factory. The public corpus is 4,438.

384 separate actual factory/method controls create two simultaneous pulls.
They compare cancellation before/after/among inner settlements, rejection races,
owner disposal, repeated return, return rejection suppression and closed next.
Both next and return are called with [], [undefined] and [7]; the inner next
receives the original vector and inner return always receives []. Their exact
native Promise outcomes and external method/then registration logs are checked.
These are protocol probes, not additional public histories or proofs.

The independent kernel checks a complete actual constructor/read/dispose/flush
programme for every admitted ordinary payload and every budget >=84. It proves
the exact final Machine. The result corollary states that the read contains the
original payload, inner return ran once, the wrapper is closed with an empty
pending Set, and its pending pull is fulfilled with DONE **while the inner
external Promise remains unresolved**. Fourteen finite representatives compare
every one of the 84 prefixes, exact Machines at three budgets and native payload/
identity/pull/return behavior separately. The producer and graph shape are fixed;
queued reactions are external inputs and arbitrary async histories are not
proved. The preceding direct-subscription 120-step and all earlier complete
programme domains/budgets are retained.

Thirteen local quantified laws cover bare/throw pass-through, unresolved inputs,
canceled delivery, empty Set/wait lookup boundaries, local return catch and
idempotent finish. A cached-iterator opening law prevents accidentally reopening
a deferred result as an external producer. These quantify whole surrounding
Worlds at stated source guards; they do not establish arbitrary graph progress.

Thirteen new compiled variants target bare payloads, pending registration,
cancellation settlement/clear/order, repeated return, argument forwarding,
native Promise timing, missing then callbacks, rejection, wrong finish capture
and the cached-iterator identity. Configuration is 564 (469 finite, 95 kernel).
Frozen prior complete-sweep receipts remain separate from the new focused checks.

No new upstream defect or workaround is introduced. Bug010 remains preserved,
including throwing inner factory/first next paths in an answered deferred
wrapper. Observable/interop objects, mutable protocol properties/getters,
object unsubscribe, custom then calls that throw or inspect callback return
values, arbitrary manual async-generator bodies and nonproduction hooks remain
unfinished.
