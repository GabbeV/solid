# Constructed action wait identities and duplicate-yield guards

The earlier wait-list theorem started with an existing lookup. Actual Action.wait
now supplies that premise. An input invariant bounds every existing wait observer
ID by the append-only observer arena length; it does not require unique old IDs
or a final lookup. The new observer uses that exact next index. Actual allocation,
wait-list append and result subscription derive its captured observer record,
fresh initially-unsettled lookup and retained bound. Subscription to the specified
result slot additionally requires that initial slot to exist.

The invariant survives arbitrary finite histories of actual Action.wait,
flight.newObserver and the Core action-delivery wait-mark store. Induction also
preserves a previously settled lookup. Starting with actual registration and the
first mark therefore constructs the premise of the actual duplicate-yield guard
after any such history. A duplicate fulfillment or rejection returns the complete
current Machine unchanged: World, caller tasks and value stack, including current
transaction counts. It does not revert the World to an older snapshot.

The same constructed lookup reaches the actual actionYieldThrow catch branch.
A synchronous .then throw after settlement is ignored with the fault cleared and
caller continuation retained, matching the source's A+ 2.3.3.3.4.1 guard. This is
the catch around that .then call, not a policy for later callback exceptions.

All helpers in the permitted histories retain every committed cached value, the
full tree and event trace. A typed integration family starts with actual action
Promise creation/opening and a yielded-result Promise, supplies the initial range,
and derives a nonzero fresh observer after arbitrary prefixes. Arbitrary represented
cached data is retained; natural parameters here are identities/arena positions.

Thirteen roots extend 572 to 585. Controls exercise 368 constructed histories:
every three-event prefix order through length five, with paired suffixes and long
cases through 64 events. There are 736 actual fulfill/reject guard checks and 368
post-callback throw checks. No JS equality evidence is supplied to the proofs.
Six native Solid sequences use repeated thenable yields, overlapping actions and
synchronous settle-then-throw, with 70 stale callback invocations. The native
sequences support correspondence; the arbitrary finite histories are proved by
induction in Bend and checked by the independent kernel.

Five compact source faults are rejected: reused observer ID, initially settled
wait, reversed append order, omitted result subscription and uncleared caught
post-callback fault. Current configuration is 664 = 484 finite /180 kernel; a
complete sweep on this checkpoint is separate from these focused checks.

## Remaining obligations

This is registration/marking and a yielded-value guard, not complete arbitrary
generator execution or once-only action/flight debt accounting. First callback
execution, callback writes/flush/disposal, iterator-result/final-result arms and
host Promise delivery assumptions remain separate. Other IO clients append/update
the shared observer arena; their full client-level range preservation is not yet
this history's theorem. It does not prove global identity uniqueness, arbitrary
reactive histories, final eligibility, eventual reveal or physical JS garbage
collection. Runtime/source/host, old theorem domains/task budgets and kernel/
toolchain limits are unchanged. No semantic deviation or new upstream bug.

The pending-settlement status composition remains open after unchanged-kernel
out-of-fuel attempts; those are [unverified experiments](../experiments/pending-status/README.md),
not active roots or reasons to change the source algorithm.
