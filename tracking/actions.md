# Typed action invocations

Source: Solid b0ad1df5, core/action.ts and scheduler.ts. This milestone translates
production action invocations with the admitted generator/thenable ABI through
the existing core machine. It does not close the complete public action API or
the active optimistic, lane, boundary, mark and store engines. No semantic
deviation is active.

## Source return points

| Source segment | Bend representation |
| --- | --- |
| Promise executor; genFn before transaction | ActionInvoke allocates the external Promise identity and evaluates the factory prelude. ActionOpened calls action-state.open only after success; ActionExecutorEnd rejects an escaping factory/executor error without inventing a done/decrement. |
| newTransaction(false), open = 1, acted = true, nextQuestion | action-state.open retains that order and uses the existing transaction arena and exact binary question counter. |
| Initial joinFuture, question save/set, step, question restore | ActionOpened and ActionRestoreQuestion. There is no unconditional initial flush. The original schedule implementation still queues its microtask; schedule has no actionDepth guard. |
| enterAction; next/throw; catch; exitAction | actionStepMethods and ActionStepReturn. Generator methods execute reads, writes, constructors and callbacks in the shared evaluator. Depth exits on successful method return and generator throw. No owner/tracking scope is invented. |
| Iterator-result thenable | actionStepResult registers a distinct result callback. Rejection calls done directly and never throws back into a completed generator. |
| run: done / yielded thenable / bare yield | actionRun, actionYield and actionSubscribe. Each thenable yield owns its own settled cell in actionWaits; old callbacks cannot resume the generator at a newer suspension point. Bare yields resume synchronously. |
| Yield assimilation catch | ActionYieldCatch surrounds only the original then call, including synchronous callbacks. A throw after settlement is ignored. A later callback executes outside that catch. |
| inTransaction | actionResume saves question, sets the invocation question, joins its transaction, steps, drains only at depth zero, then restores question on normal return. It deliberately has no finally, matching this pin. |
| done | Resolve the original transaction's redirects, decrement the resolved open count, schedule, then settle the invocation Promise. |
| Production flush action guard | flushEntry calls a supplied callback directly without syncDepth entry/drain; plain public flush is a no-op while actionDepth is positive. Dev diagnostics remain unported. |

The native controls include a resumed drain that throws after done. The original
action Promise keeps its settled result. A synchronous callback's surrounding run
catch ignores that throw and the initial question restoration executes; a later
callback lets it escape and skips inTransaction's normal restoration. The port
preserves those partial states and the source halt. It does not add a finally or
classify that broader policy as a new upstream bug.

## Generator and Promise boundaries

ActionMethods/ActionEnd form a typed external generator state chain. A method's
next/throw expression receives the resumed value and rejection flag and returns
IteratorResult(done, value) or an admitted result thenable. Advancing this user
protocol is separate from the source action engine. The reference adapter gives
the same protocol to the actual pinned action(); seventeen additional controls use
independently authored native generators and inspect the source question/depth
exports read-only, including joined open counts and the acted marker. The original four native action-contract controls remain
source-only evidence, separate from the paired histories.

Methods capture admitted lexical signal bindings. Their resume-argument binder
shadows the enclosing callback's arguments, while the factory prelude retains its
own enclosing arguments. The expression-shaped method chain lets the existing
structural lexical binder capture each method without a second evaluator or
mutually recursive binding implementation. Escaped getters retain their original
identity, and disposing the invoking root does not cancel the action.

The shared async-object arena represents the invocation Promise. ActionOutcome
is native resolve/reject IO; ActionAdopt requests the Promise resolution
microtask before subscribing to a returned typed thenable. Nested action returns
and ordinary supplied acyclic thenables are adopted, while rejection reasons are
never assimilated. This is not a complete ECMAScript Promise implementation:
self-resolution/cycles through arbitrary host objects, arbitrary getters/methods,
protocol-bearing errors and arbitrary Promise subclasses remain outside this
profile. Existing future input restrictions still apply. The adapter creates
native Promise ports and drains requests; it does not decide reactive transaction
membership, depth, question provenance, publication or when a slice drains.

The grammar exposes invocations, not first-class reusable action-function
identities or arbitrary JavaScript generator closures. General async-generator
internal await behavior is not encoded. User method bodies may return an admitted
Promise of IteratorResult; this covers the engine's result-Promise branch without
claiming that code after a native async generator's internal await is tracked.
Arbitrary then getters/methods that themselves throw are not yet admitted, even
though the represented catch also covers throws from synchronous callbacks.
Malformed iterator results refuse with Unsupported(24). Execution fuel and finite
well-formed arenas remain explicit resource/invariant assumptions.

## Evidence

- 67 differential histories: initial scheduling/returns, held writes, factory and
  body errors, rejected yields, result-Promise rejection, bare yields, production
  flush callbacks, nested/overlapping actions, return adoption and flight question
  provenance. They compare values, node state, traces, text, native Promise
  observations, ambient restoration and source extension questions.
- Eight lexical action histories: captured/shadowed local signals, rejection,
  escaped getter identity and continuation after root disposal. Original getter
  calls retain the existing native read-trace observation limitation.
- Seventeen native-generator controls: independently authored generator bodies,
  duplicates after a newer suspension, deferred Promise adoption and exact
  synchronous/later drain-error boundaries, including source question/depth.
- Five quantified local properties in proof/action-laws.bend: depth entry/exit
  preserves the whole World; positive-depth flush invokes its callback directly;
  positive-depth plain flush is a no-op; a settled yield callback is inert; a throw
  after settlement clears only the control fault and restores saved operands.
- Two concrete kernel executions use actual action entry, park and resumed seam:
  the initial write remains held at open count one, then the resumed callback
  closes the transaction and lands the reconciled value. These do not establish
  arbitrary-generator termination or TypeScript/Bend equivalence.

The earlier flush entry law now states its action-free precondition explicitly.
All old canonical signal/memo witnesses were regenerated for the extended World;
each claimed equation still requires the independent kernel. The memo witness's
final arena now has a named generated projection, avoiding an accidental reliance
on an interning index when record shapes change.
