# Joined body to heap entry

The selected boundary extends the constructed first joined body from its queued
`Round` into the actual heap task. It does not replace heap execution with a
snapshot, nor claim the later settlement certificate has been constructed.

## Reusable observations and operation contracts

`heap-entry-view.bend` observes promoted writes, dormant nodes, buckets, minimum,
maximum and pending-node intake. It deliberately excludes fault/health, callback
queues, transaction counts and committed values. Preserving this observation is
a safety frame, including on an exhausted transaction-resolution path; it does
not claim that resolution succeeded. `transaction-heap-entry.bend` and
`action-heap-entry.bend` cover actual resolve/join, controller construction,
preparation and retirement operations. `masked-projection.bend` transports a
smaller observation through a checked masking footprint without modifying the
runtime or checker.

`Sweep.Lists` in `sweep-input-frame.bend` selects only promoted and dormant lists.
Induction over arbitrary finite represented held-setter bodies preserves these
lists under the existing initial `held-cache-body-input.Input` certificate.
The actual heap and pending-node intake may change on writes and are not framed
away. Proof-only canonical cache views perform no store. `joined-round-heap-frame`
retains exactly the heap intake produced by the actual write body through
retirement, result delivery and observer draining, rather than equating it to
the pre-write heap. `joined-round-sweep-input` then derives the two empty sweep
lists from the real first opened source/controller and second create/open/join.
The constructed graph's initial bucket vector is `[0]`.

These contracts cover arbitrary `R.Value` payloads, finite body lists, the other
controller's expression, both join directions, either first completed controller,
answer/input/rejection values, and caller task/operand-stack suffixes. Initial
certificates in the generic contracts remain explicit. The raw construction
corollary constructs them; it still uses the existing private opened/held source
factory, not a proof of public action or host reachability.

## Actual scheduler boundaries

`round-entry.bend` executes two real `Core.step` operations from `Round` with
initial empty promoted/dormant lists and healthy state. It accounts for running,
unflushed-staged, pass-transaction/lane, marked and minimum normalization and
constructs `HeapLoop`, `FlushFinally`, `RoundEnd`, then the untouched caller task
suffix; the operand stack is unchanged. Separate field frames retain committed
storage and group counts through this entry normalization.

`joined-round-heap-entry.bend` composes the actual arbitrary finite body prefix
with this entry using a generic initial seed, initial readiness/control flags and
initial empty sweep lists. `joined-body-heap-entry.bend` constructs those initial
premises and proves the complete raw body-through-heap-entry prefix, including
the exact remaining caller tasks and operand stack. It supplies no successful
intermediate World or post-body sweep/health premise. The first direct raw
composition exhausted fuel; the generic-seed refactor passed the independent
kernel with the same 400M fuel. No stopped attempt receives credit.

`empty-heap-seam.bend` covers the trailing height-zero empty bucket with initial
minimum/maximum zero and bucket zero empty. Three real steps advance the minimum,
exhaust the heap and execute the seam to construct `Settle`/`AfterSettle`, retaining
caller work and committed storage. This is an initial-state boundary contract:
it does not assume all actual body heaps are empty. Its loaded heap form is
checked equal to the real implementation before branch selection.

The remaining composition is the changed reader's heap/render processing and
construction of the existing settlement/parking certificate afterward. A fresh
render reader may have no extension and no pending slot until that processing;
allocating it early or assuming a present pending value would change the domain.
Existing mixed settlement/scan/round-return proofs remain conditional on their
initial certificates until that gap is closed. Global group-forest/live-list,
once-only settlement, public/host reachability and eventual reveal remain open.

## Verification boundaries

Only the completed official whole-book independent verdict and tracked-input
seal establish the checked checkpoint. Compact module checks support authoring;
frontend diagnostics alone, resource-stopped attempts, and finite native controls
are not proof credit. Checker profile, 400M fuel and runtime/source pin are
unchanged. This work introduces no runtime change, upstream bug claim or active
deviation.


`heap-entry-count.bend` additionally composes the actual entry equality with
source retirement and Round field frames: the generic certified seed and raw
constructed corollary both retain exactly one action obligation after entering
HeapLoop. No intermediate count or health premise is supplied. These two roots
do not claim the heap is drained or the rendered observer has been parked.


The [read-entry contracts](heap-read-entry.md) now supply the general graph-link
frame, same-flush frame identity and initialized-render held-entry result needed
by the changed-reader arm. Construction from body-produced heap state and
composition through recompute/parking remain required. Displayed output must be
observed separately from internal computed-node values and diagnostic events.
