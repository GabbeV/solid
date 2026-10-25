# Pending settlement retains the caller continuation

This extends checkpoint `83b633b2` without changing the runtime, source pin,
host, representation, toolchain, kernel limits or semantic deviations. All prior
proof domains remain active. The selected joined-action/rendered-flight theorem
is still unfinished.

## What the kernel proves

`pending-continuation.bend` covers actual core continuations for after-trim
settlement, the pending walker, scheduling, exhausted local queues and release
capture. Every `Core.step` at the three admitted task heads preserves the caller's
entire arbitrary `List<R.Value>` stack. This includes a faulted World: dispatch
may be skipped and the local walk abandoned, but its caller stack remains.
The release boundary keeps the private visited/released/scheduled locals and
advanced release cursor across the queued owner walk. It does not execute that
owner walk or assume the callbacks terminate or preserve content.

`pending-stack-history.bend` proves by structural induction over an arbitrary
finite permitted prefix that all those actual core steps retain the caller stack.
Each certificate records the current machine's real task head/layout and its
next `Core.step` state; no stack-preservation or transition-result equation is
supplied as a premise. The prefix evaluator is proved equal to exactly its
height's repeated calls to the same runtime `Core.step`. It is a proof-side trace
fold, not a replacement reactive engine. A constructor supplies a nonempty
pending-queue/schedule prefix of exactly two steps for every World and stack.

The changing machine scope is erased in the induction's proof parameters; the
programme tail is its decreasing runtime argument. This meets the pinned kernel's
structural recursion rule without altering a runtime budget or restricting data.
The general stack roots need no health premise. They do not prove health,
settlement success, valid graph identities, or any bound on finishing the walk.
`Core.run` exhaustion can clear work and stack; no claim here covers that branch.

## Executed checks

The existing 240 paired native-generator/Bend public histories remain unchanged:
two joined actions plus a direct or memo-backed renderer, all six completion/
flight arrival orders, independent publication and success/rejection controls.
On their 80 zero-debt pending snapshots, the existing 160 forked fulfillment
prefixes still retain committed values/tree/trace and the exact queued tail.
Forty queue an owner trim. The other 120 now execute the real after-trim,
`PendingTasks` and scheduling continuations: 880 steps, including 40 dependent
visits, all reach their queued flush with the independently saved committed view,
nonempty caller stack and flush/then/caller tail retained. No release callback is
reached by those 120 fixtures. These are additional finite Bend boundary checks,
not new public histories, native private-prefix equivalence, or a general proof
of their storage observation.

Four source-changing kernel negatives clear the resumed stack, lose the captured
visited list, use the zero source for self-settlement, or clear the stack during
fault unwinding. All are rejected semantically. Configuration is 612 variants
(480 finite /132 kernel). The separate complete 608 sweep is frozen on 83b633b2;
its receipt must not be presented as a complete sweep of this later checkpoint.

## Remaining milestone

The fulfilled-result proof no longer stops at a queued stack obligation: actual
pending dispatch and arbitrary finite admitted prefixes now have a caller-stack
contract. General storage preservation through the whole settled-node body is
still open: the pinned kernel hits reduction fuel in the
[unverified attempt](../experiments/pending-settlement-frame/README.md). It is not
an active root, and no resource failure is counted as a semantic result.

Actual owner trim/release, callback behavior, successful traversal bounds,
reachable-state construction/preservation for the pending graph, the later flush,
coordinated publication and eventual host-delivered reveal remain separate.
Source `unobserved`/`disposeChildren` bookkeeping retains the cached `_value`;
an earlier explanation saying it directly cleared that value was incorrect.
Unrestricted cleanup callbacks can write, flush or dispose, so their observation
contract must be explicit. Independent UI publication also requires a selected
renderer/target observation rather than a blanket whole-World freeze.
No new upstream bug or semantic workaround was found at this checkpoint.

See [the validation receipt](reviews/pending-continuations-validation.json).
