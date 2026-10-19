# Callback arguments and bound root disposers

The user-code ABI now passes up to two evaluated arguments into named programs.
Arguments evaluate left to right in the caller scope before any callee statement;
`Callback` retains their values across statement execution, nested reads and
suspension. `callback.bind` substitutes argument leaves with data. Nested calls
introduce their own parameters, and RootScope introduces a fresh init parameter
binder. The latter is deliberately not traversed by an enclosing binding.
This is explicit lexical parameter representation, not a new Solid algorithm.
Arbitrary closure environments and argument reflection remain unfinished.

Application-body programs receive the actual value and previous value. Error
body programs receive the original unwrapped cause; their cleanup helper remains
the existing explicit `previousCleanup` action and callbackEffect parameter slot.
That helper is not exposed as an arbitrary function value. Named calls without
arguments still receive undefined. The compute expression's `prev` remains its
separate source parameter; updater expressions similarly receive the setter's
current staged value.

Root initializers now receive the actual init-bound dispose function. The
`RootDisposerReference(owner)` value represents the unique bound function created
for a root, separately from owner objects and opaque application references.
Plain invocation runs `disposeRootSelf` with its captured receiver and self=true,
regardless of the ambient owner or call receiver. The host materializes one actual
callable per root, preserving alias identity and re-entering Bend teardown on a
native host call. The host owns no teardown decisions. Persistent materialization
caches and arenas retain retired entries; no memory/performance equivalence is
claimed. Arbitrary function properties/getters/binding remain outside the grammar.
The native bound-function String result used by StatusError is represented for
this selected function family.

Function values require the source setter's typeof-function branch. A raw bound
disposer passed to a setter runs before the setter remainder and yields undefined;
a throw skips all later setter stores. Returning the same function from an
updater stores it as data, without invoking it again. `setSignal`/`setterValue`,
owner.writeValue's teardown continuation and evaluated callback writes preserve
these sites. `updateExpr` is the callback form of a real updater and can retain a
function. Async settlements write returned function data through the existing
internal value path. Function initializers select createSignal's writable-memo
overload in Solid; that constructor remains unfinished and is explicitly rejected.

71 differential histories compare argument order/binding, early/nested returns,
suspension/errors, application/error parameters, root disposer retention,
receiver binding, native callable identity, idempotent teardown, raw/updater
setter distinctions including throwing cleanup, captured error messages and
async function data. Additional identity and input-domain checks are separate.
Four compiled mutations exercise binder capture, repeated invocation of updater
results, incorrect bound receivers and swapped effect arguments.

`init_disposer_is_bound` is a closed composed law through real init binding,
updater storage, flush and invocation under another root. It checks the captured
root's death, survival of the other root, parent links, stored function identity,
cleared disposal and ambient restoration. Two general ABI helper laws check
argument-zero substitution and the fresh root binder. These do not constitute a
formal TS/Bend equivalence or general closure/lifetime/progress theorem.

Init-bound disposers can now also be registered/returned through onCleanup;
see [cleanup-values.md](cleanup-values.md).

Nested signal/memo/effect creation now executes; see [nested.md](nested.md).
Local data-signal read accessors now escape and execute; see [locals.md](locals.md).
Arbitrary function-valued inputs, dynamic
returned effect-cleanup selection, expression teardown callbacks and active
boundary/lane/provider/snapshot scopes remain unfinished. No source workaround
or deviation is active; the pinned upstream counterexamples are preserved.
