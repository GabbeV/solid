# Public flush callback overload

Source: core/scheduler.ts:flush at Solid b0ad1df5 (rc.16). The production,
action-free callback overload now executes through the same core machine as
ordinary reads, writes, callbacks and plain flushes. No source pin or semantic
deviation changed. The supplied callback is synchronous user code; its returned
Promise is ordinary data and is not awaited by flush.

## Source operations

- Callback entry increments the existing World.syncDepth, without entering a new
  owner, disabling tracking or draining earlier queued work before the body.
- The callback result is retained while its finally invokes the ordinary public
  drain. Nested callback/plain flush calls therefore drain at each level.
- A thrown callback still drains. Its error is held in a finally continuation,
  while the drain runs with a healthy control state. A drain error overrides the
  callback error or return. The inner finally decrements depth in both cases.
- Caller operands are retained across the drain; partially evaluated callback
  operands are discarded when the callback throws. Ambient scope is retained.
- Running/halted no-op guards apply to the drain, not to callback invocation.
  Callback writes from inside an effect are handled by the enclosing flush's
  continuation. Production has no dev warning/throw in those guards.
- Existing schedule checks syncDepth/running before requesting a host microtask.
  It is unchanged; the callback overload now maintains that depth at the source
  sites rather than asking the host adapter to emulate batching.

Bend return points are flushCallback, flushCallbackFinally,
flushCallbackRestore, FlushArgument and publicFlush in runtime/core.bend.
FlushCallback represents an inline closure body; FlushValue evaluates a callback
argument once and invokes its original admitted function with zero arguments.
The production falsy-argument arm selects the plain drain. FlushNow represents
an explicit no-argument call inside user expressions. Callback/lexical binders
capture enclosing arguments and local signals through these expressions.

## Evidence

64 public differential histories compare native Solid flush callbacks against
Bend: coalescing, committed-before/drained-after reads, nested drains, value and
function results, original native callback values, preserved ownership/tracking,
callback/drain errors and precedence, pending reads, native Promise return data,
queue reentry, halt behavior and later scheduling recovery. Eight additional
native microtask-IO controls check suppression during callback scopes and restored
ordinary scheduling, with/without a prior job, nested scopes and body throws.
They observe queueMicrotask requests; they implement no reactive decisions.

Direct native getters supplied to flush are unwrapped. The native host cannot
observe their read events, so only that focused family omits read-event comparison;
other traces, state, ordered dependencies, results/errors and screens still match.
All other histories retain complete admitted traces.

Two closed end-to-end laws check nested return/commit ordering and a drain error
overriding a callback error through the actual constructors and shared machine.
Three additional quantified helper laws cover every World, caller continuation,
operand stack and relevant payload: callback entry preserves all world fields
except incrementing depth; the inner finally restores a successor depth and exact
saved operands without undoing drain-world changes; and a callback throw still
enters the same public drain carrying the original error in its finally frame.
These are local semantic properties, not termination or correctness for arbitrary
callbacks or whole graphs. See proof/flush-callbacks.bend and the root laws.

Eight new compiled mutations target entry depth, skipped drain, leaked depth,
callback/drain error precedence, retained returns and both capture binders.

## Remaining scope

The later [action milestone](actions.md) adds the production actionDepth guard.
Dev/observe diagnostics remain explicitly unported. The quantified callback-entry
law now explicitly assumes actionDepth is zero; positive-depth behavior has its
own quantified laws.
The no-active-action profile always reaches the source's ordinary branch. This
milestone does not implement actions, lanes, boundaries, stores or arbitrary host
JavaScript closures. Resource exhaustion remains an explicit failure; the proofs
do not assert every callback or drain terminates within a uniform budget.
