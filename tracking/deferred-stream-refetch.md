# Deferred stream refetch

The open-window branch of `deferred.ts:createDeferred` now runs through the
existing core iterator consumer. It no longer refuses Unsupported88. Direct
streams and synchronously flattened promise-to-stream results use the source
wrapper, including merged #4232's first bare iterator-result handling.

`runtime/deferred-stream.bend` keeps the producer iterator, captured wrapper `s`,
and returned iterable distinct. A DeferredIterator record captures the cell,
inner iterator, wrapper iterator and mutable first flag. The typed boundary in
`runtime/iterator-input.bend` expresses external method results and throws; it
makes no reactive publication decisions. DeferredArena gains nested storage;
the top-level World still has 71 fields. Existing ordinary iterator consumption,
publication, error handling and owner cleanup remain authoritative.

The source order is preserved: acquire the producer iterator, construct `s`,
ask(s), register the flight, and consume the returned iterable. First next calls
forward an explicit undefined argument. A bare result lands s immediately;
a promised result registers its done observer before the engine observer. A
synchronous next throw occurs before first=false and before either observer.
Return forwards an explicit undefined and uses Promise.resolve(DONE) only for
missing/nullish inner results. Factory failure allocates neither wrapper nor
flight. The post-iterator serve continuation preserves held pending values.

The 184 paired histories compare every command prefix: node state, values,
marks, reports, traces, screen/ports, full external iterator IO, exact method
argument vectors and external then registrations. Opaque flight identities are
alpha-renamed consistently rather than discarded as undefined or compared to
incidental arena numbers. Coverage includes eager/lazy and seeded construction,
empty/falsy completion, immediate/native steps, cancellation, stale steps,
repeated replacement, held values and promise flattening. These are finite
correspondence checks, not universal correctness proofs.

The independent kernel checks a complete owned stream-refetch programme for
every pair of admitted ordinary initial/yielded values and every budget >=118.
It proves the exact final Machine and returned value using actual constructors,
setter, flush and getter. The payloads can differ in type and include undefined,
null, booleans, naturals, NaN, negative zero, strings and opaque reference IDs.
The fixed graph/one-yield producer shape is not quantified. 196 mixed native/
canonical controls support the proof separately, comparing all 118 prefixes.
Eleven additional quantified helper laws preserve throws, unresolved states,
return fallbacks and the exact post-protocol unwind. All preceding complete
programme domains and sufficient budgets remain unchanged.

Ten new compiled negative variants target missed/duplicate landings, wrong
wrapper identity, first-flag order, observer order, return fallback, factory
failure and held values. They are separate from the proof claim. The configured
corpus is 534 (446 finite, 88 kernel). The complete 524-variant receipt applies
to the preceding 9c1f2ec checkpoint; subsequent full sweeps identify their own
frozen checkpoint rather than inheriting that credit.

The [protocol-error report](upstream/deferred-protocol-error.md) retains the earlier
failure evidence. The defect is now fixed upstream and integrated at 2a0da2fc;
protocol processing shares the source catch and retires the current flight. No workaround or semantic deviation is
installed. `from`/onSupersede, arbitrary JavaScript protocol getters/method bodies,
store/boundary/snapshot scopes and nonproduction hooks remain unfinished.
