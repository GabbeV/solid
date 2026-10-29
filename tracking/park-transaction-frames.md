# Parking preserves action debt; successful leaf parking

Actual node holding, finite child-frame holding and the default parking intake
now preserve every transaction field other than its node-membership array. In
particular, all action-open counts, redirects, lane identity, queues and other
group metadata remain unchanged. These are general operation contracts over
arbitrary represented Worlds, group identities, task lists and walk fuel.

The count frame holds even when a child walk exhausts or the default-only
facade reports an unsupported custom comparator. It is a safety property about
group metadata, not a claim that those paths complete successfully, retain
health or publish anything. The core continuation path that invokes custom
comparison callbacks is outside this default-facade contract.

`transaction-membership-frame` masks only transaction node lists. It proves
the actual extension/list/config stores and every hold-step branch retain the
rest of each group, then inducts over the real `holdRun`. `park-transaction-frame`
composes those contracts through all branches of `parkPendingNode`, the actual
`park_list` and the public `parkPendingNodes` facade. No final count or group
projection is supplied as a premise. Existing-slot updates and blank fallbacks
are handled structurally; they are not silently treated as successful object
allocation.

There is also a separate successful parking contract for an allocated, unowned,
childless node with a present pending value and `equals: false`, within that
explicit allocated/pending-value domain. The current raw render pass instead
needs the fresh/absent-slot branch linked below. Its `held-park-leaf.Ready` certificate states only
initial facts: actual node/extension/group slot membership, an existing positive
extension pointer, zero cached ownership, no children, initial park eligibility,
present pending data, no custom comparator and the false equality option.

That contract derives the actual result:

`parkPendingNode(w, id, group) == holdNode(w, id, group)`

`held-node-listing` establishes the existing node/extension/config correspondence
through the actual node-holding operation. Its child pointer survives. The real
`holdFrame` walk has no children to traverse; `held-frame-leaf` derives its
nonzero source budget from a nonempty node arena, without extra loop fuel. The
optional staged-child-frame branch is therefore an identity. The initial health
is retained, and the general count frame still applies. These facts are
derived, rather than supplied as post-parking assumptions.

This extends the ingredients available for [quiet settlement](quiet-held-settlement.md).
Tracing the actual constructed first-body Round shows why it is needed: a
changed source puts the render reader in the heap and recomputes it. The reader
can be staged while its pending slot remains empty and its extension is still
unallocated; its proposal is held in the render value/previous-value fields. An unchanged/no-write body avoids that
work. The earlier quiet-intake theorem alone does not cover the changed case.
[Mixed parking](mixed-held-settlement.md) now composes source/reader intake,
including that fresh render branch; [round return](mixed-held-return.md) also
composes the callback-parking/finally/restore continuation. Constructing their
premises from the actual heap pass remains explicit work at the frontier.

`R.Value` can represent asynchronous results as well as ordinary data. A reader
pass cannot be assumed synchronous merely because its body is a source read.
Any synchronous restriction in a later theorem must be explicit; full flight
accounting and branching publication remain open.

Six additional roots require the normal composed verdict and input seal.
Standalone independent checks retain the same checker profile, 400M fuel and
4 GiB RSS / 90 s guards. Two reduced, compiler-valid count-loss mutations are
checked separately from the frozen complete negative sweep. There is no runtime,
source pin, checker or semantic-deviation change, and no new upstream bug claim.

The [validation receipt](reviews/park-transaction-frames-validation.json) records
compact verdicts and focused faults. An initial mutant failed affine compilation
and receives no rejection credit; both final source mutations compile before
being rejected by independent checks of reduced count projections.
