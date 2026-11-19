# Owned-frame latest reads: history and strengthened regression

The user requires eager detached-DOM construction and reiterates the boundary
contract: inactive optimism reads through its input, including the initial
synchronous attempt and final correction; only an active override selects a
different value. Latest must not lag a direct read in the same calculation.
The delayed-initialization contract question in stage 166 is withdrawn. The
mixed calculation is an implementation defect before any callback runs.

## Exact divergence

Instrumentation of all eight owned-render-context variants records a lower
creating update at depth 0 reading a higher output at depth 1. That output has
committed value 0, proposed value 1, and (for the direct latest boundary) active
override 1. `frameRead` nevertheless returns the committed 0 because the reader
belongs to an unpublished owner. Its ordinary input read returns the parent's
proposal 1. The result `[captured=1, direct=1, latest=0]` completes.

This is not an inactive selector falling through incorrectly, nor a correction
already in progress: the override has been selected. It is the generic
unpublished-owner read rule choosing an obsolete publication instead of a
coherent context for the calculation. That rule is already present in pre-rebase
checkpoint ff20b4ea; it was not introduced by stage 162's transparency repair.

Next `4fe75321` serves the held source's proposal through `heldLatest`, while
`route` keeps a reader already belonging to its held creating frame in that
frame. The experiment's generic separate-output read path loses that combination.
The strengthened public controls pass all eight variants on next.

## Revert experiment

Reverse only stage 159's creating-update stamp and owner lookup (2ba03bfb):

- Four inline variants return `[1,0,1]`: the child changes context and loses
  the ordinary input version captured by its parent.
- Four memo-wrapped variants still return `[1,1,0]` before later coherent runs.

Restore the repair. It is necessary but incomplete; reverting it exchanges one
mixed-context bug for another. Stage 162's inactive-latest read-through remains
necessary and addresses a different phase. Neither revert is retained.

## Tests and state

The eight owned-render controls previously checked captured versus ordinary
values and discarded latest's return. They now record all three and assert that
latest never trails the direct value in this controlled 0-to-1 transition, both
before release and across the complete calculation history. They intentionally
remain failing until the read-context repair is complete; no callback-delay
expectation replaces them.

Restored focused set: **15 passed / eight failed**. All twelve inactive-latest
transparency controls and three eligible-flight controls pass. Next passes all
eight strengthened owned-render tests. Rules-index and diff checks pass.
Runtime is byte-identical to stage 165; no build, size or performance claim.
The last full-suite counts are still stage 165's; these eight strengthened
previously-passing assertions expose the already-known bug and have not been
folded into a new full-suite inventory.

Receipts, instrumentation and the rejected revert:
`checkpoints/integration-stage167.tar.xz`.
