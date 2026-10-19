# Error constructors and external error values

The production StatusError constructor and one-layer unwrap now have a separate
source-followable module, runtime/error.bend. statusError captures the message at
wrapper creation, keeps the original cause/source, and allocates a fresh internal
wrapper identity. Existing notifyStatus/stageError callers retain their source
rules for preserving an existing wrapper; effect catches still create a new one.

The selector follows `original instanceof Error ? original.message :
String(original)`. StatusFailure stores the captured String explicitly, alongside
identity/source/cause. The host decoder reads this String; it no longer invents
the message by stringifying the decoded cause later. This repairs an omitted
source operation and an adapter mistake, without changing the upstream pin or
introducing a semantic workaround. The two existing composed error laws now
include the captured `99` message in their expected wrapper records. No new
general constructor or JavaScript equivalence theorem is claimed.

For the existing payload grammar, non-Error String conversion covers undefined,
null, booleans, naturals through 2^48-1, NaN, text and the plain object identity
tokens. Known internal Error types expose their stored/default messages. An
ExternalError retains an immutable host snapshot of native prototype kind, name,
message, legacy DOMException code, and the actual `instanceof Error` result. The
runtime uses that boolean for the source branch; it does not assume every
DOMException or every foreign-realm Error has the same prototype relationship.

## Host contract and identity

host/errors.mjs owns only object identity, input metadata and observations.
Native built-in Error/TypeError/RangeError/SyntaxError/ReferenceError/EvalError/
URIError and DOMException objects can cross the current host boundary unchanged.
The registry retains the actual object, including its native prototype and any
opaque user properties/cause. Its selected immutable fields become Bend inputs;
reactive error classification, wrapper construction, propagation, unwrapping and
disposal remain in Bend.

Declarative `{error: id, kind, name, message}` inputs identify preexisting host
objects, like the older reference/future descriptors. Explicit IDs and native
allocations have separate namespaces, represented by ExternalError.explicit.
Equal IDs across namespaces never alias. Equality uses namespace and identity,
not matching messages or prototype names. Host observation labels are assigned
in first-observation order, independently of input compiler allocation order;
native alias assertions separately check that these labels do not hide cloning.
Observation records are not native-error input tokens. Raw native object inputs
and returned native objects preserve their identity across subsequent calls.

For a standard native AbortController, a host property-input listener runs before
until's engine listener, installs the signal's aborted/reason snapshot, and binds
the actual reason object. Calling abort with no argument or explicit undefined
lets the native controller allocate its default DOMException. until rejects with
that exact object, including for pre-aborted/shared signals; no fabricated
AbortError replaces it. Repeated abort calls retain the first reason. This is
external input delivery, not a second error or settlement algorithm.

## Evidence and remaining limits

99 end-to-end histories compare node fields, captured wrapper messages, aliases,
callback ordering, traces, reports/halts and native promise observers with the
unchanged TS runtime. They cover successful Error data versus throws/rejections,
all eight admitted native classes with empty/Unicode messages, same-value recovery,
callback/cleanup/error-handler failures, and explicit/native identity separation.
Independent assertions check original cause identity, message text, shared
wrappers, successful Error data and the signal's exact default abort reason.

60 until option histories additionally check timer/listener IO, default and
explicit abort, pre-abort, races and cancellation. 50 direct constructor/unwrap
probes use the actual pinned source constructor, without rewriting it. They
include numeric boundaries, nested wrappers, NotReady/Timeout, and genuine
foreign-realm Errors to exercise the false `instanceof Error` branch. Those
foreign-realm probes are helper evidence, not end-to-end host support.

The public host input grammar admits immutable string name/message fields on
same-realm built-in errors and standard DOMExceptions. Custom subclasses,
protocol-bearing errors, proxies, property mutation, getter/coercion failures,
non-string message fields, arbitrary object reflection and error stack semantics
remain unfinished. Custom TimeoutError message arguments and round-tripping
internal StatusError/NotReady/Timeout classes as arbitrary input data are also
unfinished. The existing formatting/protocol escape report #4112 is not silently
fixed by this port; its offending host callbacks remain outside this grammar.

The source inventory now indexes class constructors explicitly. StatusError and
the default TimeoutError constructor have restricted/partial location mappings;
untranslated constructor operations and all unreviewed branches remain open.
The read-only upstream-impact test changes the candidate StatusError constructor
and requires its fingerprint and Bend mapping to be reported. Vendored source
and pinned hashes are unchanged.
