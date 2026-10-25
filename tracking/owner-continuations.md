# Owner bookkeeping and bounded trim return

This extends `abad6134` without runtime, host, representation, source pin,
toolchain, kernel-limit or semantic-deviation changes. The existing ten pending
continuation roots and their domains remain active. Four new roots add owner
bookkeeping and one actual internal-completion case.

## General caller-stack scope

`owner-continuation.bend` classifies the 31 source owner-task constructors by
immediate stack behavior. Three kinds (`WriteValue`, `WriteForward`, `Action`)
are excluded from the stack-neutral phase. The other 28, plus an empty owner
queue, preserve the entire caller stack through actual `Core.step`, including
fault unwinding. Starting `RunCleanup` or `Invoke` queues `Evaluate`; it does not
execute that body in this step. No content, callback termination or success
claim follows from the stack theorem.

The existing `pending-stack-history.bend` phase grammar now includes those owner
queue heads, with their syntactic classification proof. Its induction therefore
covers arbitrary finite permitted prefixes of the real settlement/schedule/owner
steps. It still stops before executing an application callback body, a user-write
phase or a flush. The certificate supplies the actual task layout, not a desired
stack equation or an assumed transition result.

## Actual internal completion

The source dependency trim selects the suffix after the retained dependency tail,
or the dependency head if there is no retained tail. If that selected edge is
zero and the World is healthy, the actual trim and its owner-frame return complete
in exactly two `Core.step` calls. The result is the exact original World, caller
stack and remaining task list. The caller's next settlement or flush is retained.
The theorem requires input graph/health facts, not its conclusion or a guessed
runtime-fuel allowance. A two-step permitted-prefix certificate is constructed
from those facts and its exact height is proved.

This is internal completion of a no-stale trim only. General stale-suffix unlink,
owner-release callbacks, pending-graph termination, full flush and coordinated
rendered reveal remain open.

## Execution and negative evidence

All 240 existing paired public native-generator/Bend action/flight histories
continue to pass. Their 160 accepted forked arrivals now all execute to the
queued flush: 1,360 actual steps, including 80 dependent visits and 80 structural
owner steps. For all 40 queued trims the input graph independently has no stale
suffix; both actual steps retain the exact World and return the exact saved
caller tail. No application callback body is reached by these fixtures. The
checks retain independently saved committed values/tree/trace and nonempty
caller stacks. These are finite Bend boundary checks, not new public histories,
a general storage theorem, or native private-step equivalence.

Three new source-changing kernel negatives clear the resumed stack, clear it
when cleanup is queued, or erase retained dependencies during a no-stale trim.
All are rejected semantically. Configuration is 615 (480 finite /135 kernel).
The [complete 608 receipt](reviews/solid-2a0da2fc-complete-negative.json) is for
frozen source-integration checkpoint 83b633b2; its exact named set, tracked inputs
and hashes are verified. Later continuation variants are focused checks; this
checkpoint does not claim a complete 615 sweep.

## Correction and remaining observation work

An earlier explanation said unobserved disposal directly cleared cached values.
The source `unobserved` and `disposeChildren` paths retain `_value`; the existing
translation does too. That explanation was incorrect and the affected notes are
corrected. Owner release still needs an explicit application-code boundary:
cleanup callbacks can write, flush or dispose. Independent publication also
requires observing the selected renderer/targets instead of freezing all UI work.
The stronger general settlement-storage proof remains archived, unverified and
unused; no kernel/resource failure is credited as a semantic result.

No new upstream bug or semantic workaround was found. See the
[validation receipt](reviews/owner-continuations-validation.json).
