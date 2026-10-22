# Next deferred stream frontier

This is a source review and implementation boundary, not an admitted refetch
stream implementation. First-load streams use the ordinary iterator engine.
The open/answered-window wrapper below remains Unsupported88.

## Identities and source order to retain

The result r, the underlying iterator it, the wrapper iterator s and the
iterable carrier passed to serve are distinct objects in deferred.ts. ask(s)
records s, while handleAsync registers the carrier as its engine flight. A port
must not use the original r for both identities or merge the done and engine
subscriptions. The existing DeferredWait lookup can carry a distinct typed
iterator identity, but the present AsyncValue descriptor alone does not express
all four objects.

Create it by calling the original iterator factory with r as receiver, then
allocate first=true and done=()=>land(s,true), construct s, ask(s), and call
serve on the carrier whose iterator factory returns that same s. serve must
still call handleAsync and only afterward select a held pending value. The held
landing scan and source-order mark release already exist; no substitute hold or
stale-value algorithm is needed.

s.next(v) calls it.next(v); on its first invocation it clears first before
subscribing p.then(done,done), and returns the identical p. Later pulls do not
install another done observer. The observer registration precedes the engine's
reaction to p, including immediate thenables. Captured s identity is needed for
stale callbacks after replacement and disposal.

The pinned source unconditionally calls p.then on that first result. A bare
buffered IteratorResult therefore throws the confirmed upstream TypeError. That
is a legal producer shape, so admitting this baseline branch must preserve an
ordinary computation error and its message/identity, not an interpreter-stop
fault or a silent isThenable repair. The isolated candidate patch is not active.

s always has a return method. It calls it.return with the original receiver
when present, then applies the source nullish fallback: an absent method or a
method returning null/undefined produces Promise.resolve({done:true,value:v}).
A present method returning a non-nullish value preserves that exact result;
method presence alone cannot select the fallback.
That default fulfilled native-promise path is observable callback/protocol IO
and must be represented explicitly, including the engine's rejection-swallow
registration. The existing ordinary close machinery supplies the cleanup and
supersede boundaries, but simply aliasing s.return to an absent underlying
return would change this source branch.

## from/onSupersede prerequisites

from(source) itself does not subscribe. Iterating its result opens the source.
The subscription form coalesces latest/has, separately retains done,
failed/failure, one waiting resolver/rejecter pair, unsubscribe and closed.
settle serves a buffered value before a queued error before done; finish closes,
drops the buffer and resolves a waiting pull as done. WrapIterable instead
preserves each pull, with a Set of pending resolvers and once-only inner return.
Both forms require callback/iterator identities and real factory execution in
the current owner, beyond the present static stream plans. Observable receiver
and interop precedence must remain explicit if admitted.

onSupersede uses the existing flightTeardown slot, composing the previous
callback with try/finally. Fresh extension allocation must restore inFlight to
undefined, preserving recompute's before/after identity comparison with null.
The current no-hook profile can use its existing numeric absence encoding;
onSupersede admission needs this distinction explicitly, without changing the
old call paths or their budgets. Source children-forbidden scopes still register
supersede/return cancellation while skipping owner cleanup, and no-owner calls
register neither. Later handleAsync stream registration intentionally replaces
the teardown slot with its close callback; a returned from stream closes via
return(), while a nested source retains its owner-cleanup backstop.

The synchronous late-unsubscribe exception defect must also stay at baseline
until an upstream fix or registered deviation is admitted. These two new
protocols remain unported. No proposed representation or algorithm above is
installed by this review, and no semantic workaround is active.
