# Owner/core callback boundary investigation

The remaining read-capable teardown gap is a translation omission. Solid's source
allows the user function to perform ordinary reads and nested operations. No new
upstream bug or desired semantic difference was found in this investigation.

The active owner machine preserves source return points for detached LIFO cleanup,
recursive children, live sibling reads, unobserved hooks and parked/current frames.
Core callback expressions already use the active read continuation machine. The
remaining boundary is how an owner callback suspends for that machine and resumes
all its callers before their next source operation.

Callers extend beyond public dispose: core recompute preparation and finally,
scheduler commit/parked-frame disposal and trimming, asyncWrite and flight release,
pending-source deferred releases, graph dormancy and watch/until settlement. A
public-dispose-only read interpreter would leave admitted programs failing when
the same cleanup is reached through those other source callers. Cached slot reads
would also omit dependency refresh, tracking, pending/errors and reentrant work.
Neither shortcut was installed.

An isolated prototype threaded a callback executor through those helper boundaries
while keeping their mutation bodies in place. The Bend pin rejects recursive module
imports. Its function values have Type rather than Data, so they cannot be duplicated
as an ordinary reusable executor. A compile-time template parameter permits reuse
but requires a closed argument: a closure capturing runtime recursion depth is
rejected with "a template applied to closed ~ arguments". A direct nested self-call
with an arbitrary callback-supplied argument is also rejected as non-decreasing.
These are representation/totality constraints, not evidence of a Solid bug.

The experiment lives outside the repository at
`/workspace/scratch/owner-executor-proto` with its generation script and compiler
log in `/workspace/scratch`. No prototype code or alternate engine is in the active
runtime, no vendored compiler was changed, and no unsafe recursion was introduced.

The next implementation route should retain explicit owner tasks in the core
continuation driver and split affected helper callers at their actual user-call
return points. Pending-source walks need to retain their visited/released state
while a deferred owner release runs. Effect and recompute finally paths must keep
their saved throw and operand stack, allowing a trim callback's throw to override
it in source order. Scheduler/async publication must resume after successful
teardown and stop at its exact throw partial state. The generic execution-path
lemmas should continue to describe the same active step relation.

First-class named callback values were implemented independently on the existing
core continuations. Their imperative cleanup subset uses the unchanged owner walk;
expression-bearing teardown remains explicitly rejected. There is no semantic
workaround to register or retire.
