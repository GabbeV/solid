# Callback expression milestone

`CleanupProgram` is the admitted user-code ABI, not a replacement implementation
of a Solid function. `CallProgram` now executes statements in the active core
continuation machine. `eval`, `return`, `setExpr` and `throwExpr` can use the
existing expression grammar, including actual reads, nested calls, branches,
untrack, errors and async objects. Named calls can now pass up to two arguments, with effect/error parameter
plumbing; see [arguments.md](arguments.md). `prev` inside a named body is
undefined. The enclosing compute expression still receives
its source previous-value argument normally.

`Callback` retains the remaining statements. A return schedules only its
expression and the caller continuation, so it exits its own invocation. Eval
removes its value; evaluated writes call the shared `write.setSignal`, and throws
enter the existing unwind path. Ordinary imperative statements use
`owner.invokeAction`, preserving callback identity, registration, reentrant
teardown and partial state. Nested computes preserve the caller's operand stack.
Returned thenables/iterables enter the original recompute async path.

`effect.runEffect` has explicit `ApplyEffect`, `InstallEffectCleanup`,
`EffectFinally` and `ErrorArmFinally` return points. They split the original
function at its user callback calls; they do not add a tracking/owner scope.
The adapter's application wrapper records the value, runs the named body,
ignores its ordinary return, and returns its separately configured cleanup token.
Both hosts use that same wrapper. Application/error body reads are consequently
imperative reads under the existing source ambient context. Source cleanup
helper detachment, catch allocation/escalation, previous-value/modified stores,
clean-pass capture and overriding trim exceptions retain their original order.

74 differential histories compare actual pinned Solid callbacks and node fields,
statement/read/apply order, early and nested return, tracked/untracked reads,
lazy computed pulls, evaluated writes/throws, native host error data, returned
async values, pending/error reads, error arms and ambient restoration. Additional
input-restriction checks are not counted as Solid histories. Two isolated
compiled mutations exercise return fallthrough and lost callback tracking.

`callback_reads_and_returns` is a closed composed law through source allocation,
callback reads and return, a live outer operand, application-body writes, shared
setter, heap/flush and final queues/context. It also checks that the effect's
imperative read does not add a dependency. This is one concrete execution, not a
general callback/progress/equivalence theorem.

The owner teardown machine cannot yet suspend for expression evaluation.
Expression-bearing programs are rejected before installation as cleanup or
unobserved callbacks; the raw owner action boundary also returns Unsupported(9).
There is no fake cached read, swallowed throw, or source workaround. Teardown
reads, arbitrary closures, general function values, dynamic returned cleanup
selection, function-initializer signals, escaping new accessors and active scopes remain unfinished.
Nested createMemo(compute, options)(), createEffect and createRenderEffect expressions now execute; see [nested.md](nested.md). Local signal bindings and captured inline bodies also execute;
see [locals.md](locals.md).
The semantic deviation register is unchanged and empty.
