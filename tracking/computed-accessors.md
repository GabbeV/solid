# First-class computed accessors

`MemoAccessor(compute,options)` represents createMemo(compute,options) without an
immediate invocation. The existing MemoRead ABI adds that invocation. Both now
use `core.memoExpression`, the actual shared computed constructor and the same
eager/lazy branch. An eager body runs before the accessor is returned; a lazy
body runs at its first ordinary read. No wrapper signal or cached-value getter
is used.

The accessor's value captures its computed node ID and reuses the existing
AccessorReference family. Calls resume core.ReadNode on the existing continuation
stack. Dependency links, pulls, height changes, pending/errors, async flights and
ambient restoration therefore use the original source paths. Raw accessor updater
arguments also run there; the setter entry local is retained across reentrant
writes made by a pulled compute body.

Source function aliases are the real bound read functions. The observer reads
native refresh-target metadata to name lazy nodes before their first body runs;
that metadata does not decide a value, write or schedule. Successful calls are
observed after return, including raw accessor updater returns. Native aliases
and calls are checked directly. Source/host function property reflection,
arbitrary callback inputs, symbol reflection and general memory/performance
correspondence are not claimed.

The computed remains owned by its actual allocating owner. An escaped function
reference does not extend that owner's lifetime. After owner disposal it serves
the source's frozen last value; a lazy computed disposed before first invocation
follows the source's uninitialized/dead branch. This differs from an unowned data
signal and is not normalized by the codec.

Fifty-one differential histories cover data values, eager/lazy options, sync and
equality options, dependency tracking/untrack, argument and local captures,
parent reruns, distinct function identity, owner disposal, pending and rejected
flights, synchronous errors/recovery, raw-versus-returned function setter inputs
and reentrant writes during a lazy pull. Tests compare actual node fields,
parent/child identities, traces, outcomes, screens and ambient state. Native alias
and lifetime controls are separate from that history count.

A closed kernel law constructs and escapes a lazy computed accessor, activates it
through a separate render effect, updates its input, disposes its allocating root
and changes the input again. It retains the frozen value 6 while the surviving
input becomes 9, with the expected owner/death/queue/ambient state. It is one
concrete Bend regression, not a general closure theorem or formal TS equivalence.
Two additional mutations exercise lazy creation and captured parameters.

Computed setter/function-initializer overloads, arbitrary closures/options/getters,
refresh-property reflection and expression-capable owner teardown remain open.
Existing source counterexamples and source pins are unchanged. No workaround or
active semantic deviation is added.
