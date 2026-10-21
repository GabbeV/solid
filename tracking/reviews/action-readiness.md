# Action engine readiness review

Reviewed against Solid b0ad1df5 (rc.16), core/action.ts, SHA256 5f0e684fd404cf4ea0b835323be6a989989df4f21916c15f909249ac4084b358.
This historical dependency review preceded the implementation. The current
[typed action milestone](../actions.md) records its restricted execution/proof
scope; the complete source units remain partial. No semantic deviation is introduced.

## Source operations to retain

| Segment | Required order / return point |
| --- | --- |
| action(genFn) runner | Call genFn inside the Promise executor before allocating a transaction. A factory throw rejects that Promise without creating a transaction. |
| Invocation setup | newTransaction(false), open = 1, acted = true, then nextQuestion. Initial joinFuture and question entry precede step; restore the previous question afterward. The first slice relies on scheduled flush, rather than an unconditional initial drain. |
| done | Resolve transaction redirects, decrement open, schedule, then resolve/reject the original action Promise. Preserve return/error identity. |
| step | enterAction before iterator next/throw, catch generator-body failure, exitAction before run/thenable result handling. Result-Promise rejection calls done, rather than throwing back into an already completed generator. |
| run | A done result settles immediately. Otherwise assimilate the yielded value with the local settled flag. Only the first callback counts; a throw before settlement is thrown back into the generator, and a throw after settlement is ignored. A nonthenable yield resumes synchronously. |
| inTransaction | Save question, set this action's question, joinFuture, run the slice, flush only when actionDepth is zero, then restore question. A nested synchronous action cannot drain the outer body mid-slice. |

inTransaction has no try/finally in this pin. An exception before its final
setQuestion skips restoration. A translation must retain that ordering, without
adding exception recovery merely for convenience. No new upstream bug is claimed
by this observation; a report would require a reduced application scenario,
controls and a check of existing rulings/fixes.

## Existing pieces and missing dependencies

The transaction arena, redirects/merges, joins, open counts, acted flag, pending
park/land, mainline flight handling, exact question IDs and ordinary flush already
have executable translations. Actions must use those operations, preserving
source nesting and landing decisions. They must not emulate a transaction by
waiting for all host Promises before publishing writes.

At this review checkpoint World had no actionDepth field. Adding actions requires that state and
source enterAction/exitAction and the public
flush action guard before the ordinary callback-overload branch. In development
that guard throws; in production it invokes a supplied callback directly and
returns its value, without a drain or syncDepth increment. It does not suppress
the callback. The existing callback-overload
proofs intentionally cover action-free scopes. The new fields also require the
record generator, handwritten World patterns, both signal/memo witness generators
and independent proofs to be reviewed; a passing default build alone is insufficient.

The iterator protocol for action bodies is distinct from a memo's AsyncIterable
consumption: next and throw accept the resumed value/error and can return a plain
IteratorResult or a thenable result. Yielded-value thenable assimilation has its
own once-only guard and exception boundary. A future typed generator ABI should
carry user continuation/protocol results only; all reads/writes and transaction,
question, depth and drain decisions must stay in Bend's shared evaluator.
Existing callback programs and native Promise settlement jobs provide useful
mechanisms, but do not already implement those action semantics.

Production with no active lane/boundary/store scopes is a reasonable first
explicit profile. Optimistic state, marks, verdict windows, stores, arbitrary
JavaScript generator factories/closures, async-generator internal await behavior,
protocol getters and dev/observe brackets remain separate work. No owner/root
lifetime or automatic cancellation should be invented for an action: this source
stores no owner/disposer for its invocation.

## First validation targets

Public controls should cover first-slice scheduling, nonthenable/bare yields,
fulfilled/rejected yielded Promises, caught/uncaught generator errors, iterator
result rejection, nested and overlapping actions, redirected open counts,
question/depth restoration on ordinary exits, duplicate callback/throw-after-
callback behavior, and production flush(fn) invoking fn without draining inside a slice (development
throws instead).
Cleanup errors must preserve this pin's exact partial state and existing upstream
regressions. Active hook branches remain unfinished until their engines exist.

Four source-only public controls in tests/upstream/action-contract.mjs pass against
the unchanged pinned production bundle: initial scheduling and callback-without-
drain behavior, held writes across a yielded Promise, a caught yield rejection,
and a nested bare-yield slice that cannot drain its outer body. These controls
caught and corrected an initial review assumption that production suppresses the
flush callback; the source actually invokes it directly. They are future
translation fixtures, not evidence that Bend actions are implemented.

Review correction during implementation: scheduler.schedule has no actionDepth
suppression. Its existing syncDepth/running guards remain unchanged. The depth
guard belongs to public flush and inTransaction's resumed-slice drain decision.
