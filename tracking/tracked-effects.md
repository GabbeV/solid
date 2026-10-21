# Tracked effect milestone

Solid remains b0ad1df5 (rc.16), and the semantic deviation register is empty.
The production `createTrackedEffect` API now executes in the same runtime as
ordinary signals, memos and two-part effects. This is a new supported primitive,
not merely more test cases for an existing one. Owned onSettled uses this source
engine; it is the next consumer to translate. Dev diagnostics, active lane and
boundary hooks, stores and arbitrary JavaScript closure reflection remain outside
this port's admitted program grammar.

## Source operations and representation

`signals.ts:createTrackedEffect` delegates to `effect.ts:trackedEffect`.
`core.trackedEffect` allocates the actual lazy computed literal, then sets cleanup
undefined, clears AUTO_DISPOSE, adds CHILDREN_FORBIDDEN, sets modified and its
tracked kind, and enqueues it in the heap before scheduling. Production public
BaseEffectOptions has only name/loc; no behavioral options are invented. Internal
NodeOptions comparator/loading extensions are not admitted by this public ABI.

The tracked NodeKind represents the existing `_type = EFFECT_TRACKED` slot.
It remains a computed/effect for shared read, graph, status and disposal decisions,
but its queued `_run` is distinct from ordinary runEffect. Queue node IDs retain
the bound node target; `queue_tasks` chooses that tracked runner. Source's `_run`
closure is represented by this target/kind pair, without an additional scheduler
or fictitious user-effect node.

`core.visitHeap` preserves GlobalQueue._update's ordering: tracked comes before
the zombie arm; delete from heap, set modified, enqueue `_run` in EFFECT_USER.
`core.runTracked` checks modified and disposed, clears modified, then recomputes.
Its body does not run at construction or in the heap's compute phase. This retains
#3291's render-write/commit/first-read order. The modified gate is still necessary
when several heap visits queue the same closure before it runs.

`TrackedBody` represents the source computed's `_fn` wrapper, not a public extra
primitive. It captures and clears the previous cleanup, calls it, calls the user's
fn under staleValues, installs the returned cleanup only after success, and returns
undefined. Registered root/setter/getter/named-program cleanup families use the
existing canonical identities and owner/core read continuations. Cleanup throws
and pending/errors enter the real recompute catch/finally; no separate user-error
arm is added. A tracked error follows source's non-user notifier/halt branch;
pending is not treated as a render observer joining the root transaction.

Two other source branches now distinguish tracked explicitly: recompute tears down
its prior frame directly rather than parking it, and its clean dependency tail
trims immediately rather than waiting in heldTrims. commitPendingNode excludes it
from queuing an ordinary effect runner after a staged-value publication.

Source's previously unrepresented module-global `stale` is now a World field.
PassFrame captures prevStale; render/tracked recomputes set it and restore it in
finally. The tracked wrapper's staleValues scope separately restores on success
and exception before assigning cleanup. The current source contains no other
reads of this global in its normal production engine; its operation order is
retained for source fidelity and future commits. This is a missing operation
translated, not a semantic workaround. No source-node field was added.

## Evidence

- 47 public histories compare the actual full production index after every
  operation: startup, batching, dynamic dependencies, cleanup replacement, returned
  getter/setter/root/program functions, owner disposal before first run or async
  settlement, write/commit visibility, pending initial reads and settled refetches,
  rejection/throw/halt behavior, nested creation and captured lexical/argument
  values. An unowned tracked effect survives disposal of an unrelated root.
- Full read traces are compared except getter-cleanup cases, whose native direct
  getter calls have the explicitly documented observer limitation. Those retain
  non-read traces, dependency targets/order/generations, node state, errors,
  screens, reports and ambient restoration.
- 32 private probes invoke the actual native node._run closure with zero to three
  duplicate queue entries, modified/disposed gates, and both incoming stale scopes.
  In mutation mode the fixture imports the mutated runtime copy, not the original
  active implementation. No source runner body is reimplemented by the oracle.
- Status helper coverage expands from 2,880 to 3,840 states, adding the tracked
  notifier posture with existing truthy/falsy error and blocked-forward cases.
- Four new compiled mutations are rejected: early heap execution, a missing
  modified gate, keeping a cleanup installed while calling it, and failure to
  restore the incoming stale scope. Full mutation suite: 105 rejected variants.
- Two concrete independent-kernel laws execute the real constructors/driver.
  One checks deferred first execution and writes reaching the next commit (7,
  then 9). The other checks cleanup before rerun and again on final disposal,
  yielding exactly two cleanup updates, with queues/context/tracking/stale/fault
  checked. These are fixed program laws, not general graph correctness or
  TypeScript/Bend equivalence.

Current totals are 2,216 public histories, full helper alignment including the
32 tracked-run probes and 136 separate owner/core probes, 105 compiled mutations,
and 51 concrete kernel regressions (50 positive, one preserved collector-leak
counterexample), plus the existing general helper laws. The three original merged
upstream fixes remain validated; #4176's unmerged finally change is not applied.
