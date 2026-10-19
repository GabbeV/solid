# Local signals and captured application bodies

`SignalScope{initial, options, body}` represents a user block containing
`const [read, set] = createSignal(initial, options)`. The initializer evaluates
before the actual signal allocation. `LocalRead{depth}` and `LocalWrite` name
immutable lexical bindings, with zero the innermost block. They are user-code ABI
operations, not extra Solid primitives. Each block execution allocates a fresh
source signal using the shared signal literal; signals have no owner/child link.

`runtime/lexical.bend` substitutes the allocated signal ID into its lexical
occurrences. It crosses root/compute/application closures to capture the binding;
new signal blocks shadow it only in their bodies, while their initializers still
see the surrounding environment. The resulting `Read` uses the ordinary read
machine. `WriteExpr` uses the same source setter and staged previous-value slot.
A raw bound-disposer input invokes the function before writing undefined; a
function returned by an updater is stored as data. Throws retain earlier argument
side effects and skip the interrupted write.

An inline nested effect body gets a fresh callback-arena identity when its closure
is created. Captured local IDs are already substituted into that body. Application
arguments are bound at invocation, separately from compute arguments and root init
arguments. Reads, writes and exceptions execute in the existing core machine and
its catches/finally frames. Body values are discarded by the admitted effect
wrapper; its returned cleanup is the separate static token already supported.
Dynamic cleanup-return selection is still unfinished.

The Source adapter actually calls createSignal and createEffect/createRenderEffect.
Native accessor refresh-symbol metadata is inspected read-only for signal-state
observations; it is never used to decide a value, write, dependency or schedule.
Bend IDs and source const-pair closures represent the same admitted user bindings.
General escaping accessors/setters, variable reassignment, arbitrary JavaScript
closures and function-initializer/writable-memo overloads remain outside this ABI.
Unbound local indices are invalid programs and fail explicitly.

55 histories compare initializer/setter return values, staged updater composition,
equality/config masks, shadowing, root capture, queued callbacks after scope exit,
separate closure instances, new locals inside retained callbacks, parent reruns,
async/error/function data, unobserved callbacks, throws/partial writes and callback
identity labels. Every local signal's actual committed/staged values, config,
comparator selection and write time are checked, as are computed/owner fields,
callback traces, screens, reports and ambient restoration.

One closed composed law checks an input accumulator retained by user/render
closures: 1 + 3 + 5 produces 9, then owner disposal stops subsequent applications
without disposing the unowned signal. Two general helper laws check direct lexical
read binding and shadowing with the surrounding initializer. Five compiled
mutations check binding identity, shadowing, captured bodies, staged previous values
and function-updater result semantics. These are Bend properties and parity
evidence; formal TypeScript/Bend equivalence is not claimed.
