# Runtime-selected effect cleanup

The application callback can now return undefined, an admitted bound root
 disposer, or a data/writable-memo setter. `returnCleanup: true` selects this
user-code wrapper in the host ABI, with either a named `program` or a captured
inline `body`. Existing wrappers retain their fixed `cleanup` option and continue
to ignore the ordinary body return. These modes are mutually exclusive. This is
an ABI choice about the user closure's body, not a new Solid option or node flag.

The `CleanupProgram.returnsCleanup` field lives in the callback arena. An inline
or named application wrapper uses `CallbackReturn`, then the same callback/core
machine. Its expression may read, write, branch, call another program, construct
primitives, or throw. Named wrappers receive the actual value and previous value;
inline wrappers retain lexical signal captures. Other programs have the existing
false return policy. No field was added to the source reactive-node record.

`runEffect` still captures cleanPass before user code, copies and clears the old
_cleanup, calls it, calls _effectFn, stores the returned cleanup, and finally
stores _prevValue, clears _modified and conditionally trims dependencies. The new
`InstallReturnedCleanup` task is exactly the return point after _effectFn. Its
operand is consumed before the caller stack is restored by `EffectFinally`.
A previous-cleanup or application throw skips the assignment and enters the same
catch/finally; it cannot accidentally install a fixed or previous callback.
The user-error arm still ignores its return and only detaches/invokes the prior
cleanup if the explicit source helper is called.

Selected functions reuse their canonical callback IDs from onCleanup. A returned
function therefore has the same identity when it appears in another effect or
an owner's disposal list. The owner walk invokes the last installed cleanup at
true disposal. Returning undefined removes the slot. Root disposers and setters
keep their bound target, regardless of the owner or callback that invokes them.
Setter cleanup receives no arguments and uses setSignal/setMemo(undefined).

48 complete differential histories compare actual pinned Solid results, traces,
all admitted node fields, cleanup presence and callable aliases jointly across
owner and effect slots, queues/ambient restoration, reports and native promise
observations. They cover user/render, scheduled/deferred creation, replacement,
undefined, imperative untracked selection reads, repeated aliases, prior/body
throws, error-arm helper/ignored return, pending computes, captured eager/lazy
writable setters and disposal of the application's own owner during cleanup.
Two isolated mutations discard the assignment or bind the wrong setter target.

One closed kernel law selects two setters on successive runs, checks distinct
installed callable IDs, commits the previous cleanup's write, disposes the root,
and commits the last cleanup's write through the actual runtime. This concrete
execution does not prove arbitrary cleanup selection or TypeScript equivalence.

Named expression-program cleanup functions now share the owner/core driver.
Direct bound getter values are now supported; see [getter-cleanup.md](getter-cleanup.md).
General returned closures remain outside
the represented callable domain. Invalid production return values are outside this typed ABI; no dev
validation has been imported into the production translation. Unsupported
returned values report an explicit boundary fault rather than being treated as
undefined. The pin and empty deviation register are unchanged.

First-class named callback values now retain canonical function identity and
enter the same core call/argument, initializer and updater paths. Their imperative
teardown subset can be selected dynamically; see [callback-values.md](callback-values.md).
Read-capable teardown remains unfinished; the boundary investigation and explicit
next return points are in [the teardown review](reviews/teardown-boundary.md).

Read-capable named teardown programs are now admitted; the full migration and
remaining callable limits are in [the operation review](reviews/teardown-closure.md).
