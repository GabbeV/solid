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
machine. Local writes call the bound const-pair setter through the shared call machine,
including its source-selected previous-value slot.
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
Variable reassignment and arbitrary JavaScript
closures and general callable initializer inputs remain outside this ABI. The expression-based
function initializer now executes; see [writable-signals.md](writable-signals.md).
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

## Escaped data-signal accessors

`LocalAccessor{depth}` names the actual get function from the local const pair.
Lexical binding replaces it with `Callable.accessor(signal)`; the separate
`AccessorReference(signal)` function family captures the signal ID. Source
`signals.ts:accessor` creates `read.bind(null,node)` and attaches the refresh
target. The port retains that bound target in the value; symbol/property
reflection and arbitrary refresh-target expressions remain unfinished.

The native codec materializes one callable per signal and preserves aliases
across returns, arguments, contexts, updater storage and async settlement. Native
calls re-enter Bend evaluation. No read value, dependency, owner, heap decision or
schedule is computed by that codec. `core.invokeValue` resumes `ReadNode` on the
existing continuation stack, preserving enclosing operands, ambient owner and
tracking. The lifetime of the allocating root does not own the signal or its
escaped accessor.

A raw accessor setter argument takes the source typeof-function branch: read it
once, then hand the answer to the shared write remainder, including when the
answer is another function. An updater-returned accessor is data and is not
called again. The source return points now use `SetSignalArgument` and
`SetSignalResolved`; callback writes discard their result at the original
return point. See [setters.md](setters.md) for the entry-local repair. Existing bound-disposer writes still use the same owner teardown machine.
Active write/lane/snapshot hooks and arbitrary updaters/comparators remain open.

Forty additional differential histories check escape/return, native identity,
retention after root disposal, shadowing and distinct constructions, tracked and
untracked calls, operand/argument preservation, dynamic dependency replacement,
raw versus updater-result setter branches, repeated callable equality, function
results returned by a raw accessor updater, async function settlement, held frames
and captured native-function StatusError text. The original 55 local-signal
histories remain separate. Native alias checks and explicit unsupported-domain
checks are additional controls, not counted as differential histories.

Source read traces are observed after successful calls to the actual bound
function, including a raw accessor updater's setter result. The source callable
is never replaced with a wrapping function. This observation is restricted to
data-signal accessors: their reads do not invoke compute bodies. Native function
String/name/length/property reflection and function allocation/performance
correspondence are not claimed. Earlier signed-zero normalization remains the
admitted numeric representation; direct numeric setter return spelling is retained.

`escaped_accessor_tracks_after_root_disposal` is one closed kernel law through
allocation, returning/storing the accessor, source read/dependency registration,
flush, root disposal and subsequent local writes. The surviving effect displays
21 from a retained signal containing 11. It also checks the function target,
owner/dependency identities, pending queue and ambient restoration. One general
lexical-accessor binder law checks substitution. Four compiled mutations exercise
wrong targets, lost tracking, repeated updater-result invocation and omitted raw
updater invocation. This is concrete Bend evidence, not general closure or formal
TS/Bend equivalence.

Escaped data-signal setters and computed accessors now execute; see
[setters.md](setters.md) and [computed-accessors.md](computed-accessors.md).
Expression-based function-initializer signals now execute; see
[writable-signals.md](writable-signals.md). General callable initializer inputs
and expression-capable owner teardown remain unfinished. Accessor use as onCleanup and raw accessor updater reads in
teardown are explicitly rejected; no owner-machine cached read or accidental
function-as-data fallback is introduced. The source pin and deviation register
are unchanged.
