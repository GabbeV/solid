# Constructing rendered ownership through the real list operation

This extends `45e4e8eed76343ab9bb69a872b1dc3de8da7adfb` without changing runtime,
host, representation, pinned sources, toolchain, kernel limits or deviations.

The [completion-prefix history](rendered-completion-history.md) began with a
pending-render snapshot, including its final membership and owned-list layout.
`transaction-list-construction.bend` now establishes those two premises through
the **actual `Transaction.list` operation**. It also enters the checked history
from that actual result. The final membership/layout are not supplied as inputs.

The fresh branch requires an already allocated extension with no captured group,
a valid allocated terminal nonzero group and an existing pending on-screen render
node. The group's old owned list is any prefix excluded by the real guard. Slot
splits and sentinel heads establish physical extension/group membership and
nonzero identities. The group record and all other work vectors are arbitrary.

The checked source decomposition first retains the already present extension,
then stores its captured group and appends the node to that group's real owned
list. Allocated-slot lemmas connect actual get/set operations to these storage
positions. The result contains the owned prefix followed by the render node;
terminal membership is current and all pending/render/posture facts survive.
The constructor produces the `Pending` certificate used by the previous history.
The separate fresh equality states the exact whole resulting World in this source
normal form; it is not an observation of intermediate writes.

A fourth root proves a same-capture re-list is an exact World identity. This
local identity does not infer list membership from a captured field in an
arbitrary malformed World. It preserves membership when construction or another
reachable invariant already supplies it.

## Entry and remaining assumptions

The composed root constructs the initial membership/layout, then admits any
finite completion-prefix/blocker-check history for that actual resulting World.
Health is preserved by listing. The earlier history's explicit positive-count
and captured-resolution premises remain per completion. The proof does not
replace the complete action/result or flight protocol with `list`.

Pending status, render kind/non-guess/non-disposed/non-zombie posture, existing
extension allocation, the previous inactive prefix and the terminal group slot
are still inputs. Showing the actual callback write, async registration/status
propagation and scheduler parking path establish these earlier premises remains
open. The earlier two-action opening prefixes and this entry contract are useful
components, not a proof of the whole public application programme. Flight
settlement/delivery, final flush/publication and fairness are still outside.

## Validation

The four new roots and the existing composed roots pass the independent kernel.
Fifty-four paired native/Bend private fixtures use real public render-node
creation and real extension/transaction/list helpers at varied allocated
positions and owned-prefix lengths, with zero, undefined and opaque values.
Pending status is installed explicitly in these fixtures, so they are not public
history or full status-propagation evidence. Fresh list calls establish capture
and ordered membership, preserve every other World field/record and produce the
actual zero-debt blocker. Another 162 re-list calls preserve the whole World and
list length exactly. Three finite source mutations (lost capture, lost insertion,
duplicate re-list) are rejected. Configuration is 597 (474 finite /123 kernel),
without a new complete sweep. No new Solid bug or semantic workaround was found.

See [the receipt](reviews/rendered-list-construction-validation.json).
