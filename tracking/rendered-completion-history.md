# Pending rendered graphs survive completion-prefix histories

This extends `fb61a5bf75ae363c4b57c86c56bce9f5d0133e46` without runtime, host,
representation, source, toolchain, kernel-limit or deviation changes.

The [previous nonempty blocker contract](rendered-blockers.md) supplied the
actual blocker judgment from explicit pending-render snapshot facts. The new
`pending-rendered-snapshot.bend` certificate packages those primitive facts:
owned-node layout, an arbitrary excluded prefix, pending/non-disposed/non-guess
render node, terminal captured membership and on-screen posture. It is not a
certificate of the final blocker result. Entering the judge scope transports it
through the actual unchanged node/extension/transaction fields.

`completion-graph-frame.bend` and `completion-pending-preservation.bend` prove
that the real `action.done` prefix preserves that snapshot. Its captured identity
must resolve, without a resolver fault, to the selected group and its current
count must be positive. The actual decrement and scheduling preserve the entire
node/link/extension storage and committed event trace, along with the selected
group's owned nodes and redirect. Health is preserved. Scheduling requests,
flags and reports are retained in the real resulting World; they are not erased.
A separate allocated-slot contract gives the exact complete World for arbitrary
transaction records/work vectors, changing the count and performing source
scheduling rather than replacing the group with an empty test record.

## The quantified history

`rendered-completion-history.bend` admits any finite sequence of:

- A completion prefix whose current captured-ID resolution and positive count
  are certified in that precise current World.
- A real `Transaction.blocked` check.

The World is threaded through the actual operations. Each completion advances
the programme's indexed World. No intervening write or flight delivery is hidden
in an event. The constructed certificate contains:

- Exact equality of the whole actual audit result to the World after those real
  completion prefixes, with every blocker-check answer equal to true. Only the
  proven identity blocker checks may be erased from that expected World.
- The pending-render snapshot and healthy runtime at the end.
- Equality of complete node/link/extension storage and committed event trace to
  the initial snapshot.

Two checked projection roots expose graph/trace preservation and that all actual
check answers are true. The history is quantified over branching choices and
finite lengths, not a list of enumerated event orders. The structural height used
for proof induction is derived from the programme; it changes no runtime budget.

## What this does and does not close

This closes preservation of a nonempty rendered blocker through completion-prefix
steps and repeated blocker observations. Initial pending-render construction from
the actual user callback/write/propagation programme is still explicit. Native
histories exercise that construction, but finite agreement is not a proof of it.

The event type enforces current positive-count/resolution preconditions. It does
**not** prove full action protocol validity, fresh identities or once-only
completion: an admitted prefix can be called again while its preconditions hold.
It does not settle the action's returned Promise, resume its generator body, or
settle the rendered flight. Rejoins that change ownership, writes, rejection,
supersession, disposal, final publication and fairness remain outside this theorem.
The initial snapshot has current terminal membership; stale node captures that
need compression into another group require another transfer contract.

## Validation

The six new roots use the same source-followable runtime. The existing 144
native-generator/Bend rendered-flight histories still pass all six event orders.
They now additionally invoke actual Bend blocker/landing helpers on 48 zero-debt
pending snapshots produced by those public programmes. Each returns true and
retains the complete World/judge or machine World/stack/frame/next task. These
additional calls are finite Bend boundaries paired with native blocker evidence,
not direct native scan equivalence or a formal reachability bridge.

A kernel negative that erases committed trace during scheduling and a public
control negative that discards the group's owned nodes during completion are
both rejected. Configuration is 594 (471 finite /123 kernel); there is no fresh
complete sweep. No resource failure is counted as rejection. See the
[validation receipt](reviews/rendered-completion-history-validation.json).
