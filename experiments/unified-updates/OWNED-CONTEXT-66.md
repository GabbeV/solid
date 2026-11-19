# Stages 64–66: owned frames retain their update context

The retained scalar implementation now handles unpublished owned frames that
read another layer's output. This extends the read/join correction documented
in [DEFERRED-JOINS-63.md](DEFERRED-JOINS-63.md). It does not extend the public
experimental API or claim stores, refresh, or complete scalar acceptance.

## Observable case

An optimistic guess of 1 has an async consequence that is still pending. An
independent ordinary action proposes mounting a subtree that reads that output.
The mounting action remains open.

When the optimistic consequence finishes, the output and its consequence publish
1. The mounting frame remains held by its action. When that action finishes,
the child mounts showing 1. If the mounting frame finishes first, it may mount
with an already committed 0; its now-visible async consequences then participate
in publication of the optimistic 1.

A child's captured proposed inputs and its reactive reads must stay in the same
context. Giving the child the higher update's context would, for example, combine
captured `mounted = true` with a read of committed `mount() = false`.

The pre-stage-64 candidate instead merged the output into the mounting action
and delayed its independent publication. Pinned next releases the output
independently in this timeline. It also runs the new child's scheduled callback
before the parent frame publishes; a callback on a detached element is not
proof that the element is visible. The candidate preserves the scheduled owned
frame hold while leaving unscheduled detached initialization eager. Actual DOM
attachment tests distinguish these operations.

## Common mechanism

- A proposed owned frame keeps its creator's context. When it encounters a
  higher proposal, it reads that output's committed value and registers for its
  publication. The old parked frame remains a visible consumer.
- If the output has never published, there is no committed value to return.
  The read suspends and waits for publication, without consuming the proposal
  or merging the two updates. This uses the existing pending/error protocol.
- Notifications of pending work and its settlement request recomputation. They
  must not merge an unpublished lower frame into a higher update before its
  read selects a value. The optional status hook is shared by propagation and
  settlement, and held render effects in unpublished frames keep that context.
- A ready higher publication wakes these unpublished lower readers after its
  commit. The lower update cannot publish while that new work is queued. This
  avoids attaching an obsolete child at the same seam.
- Only ready updates with such unpublished readers require ordering. Independent
  updates and same-level siblings retain unspecified callback order.

No ordinary node fields, version maps, or duplicate value graph were added.
Ownership is found through existing owner/frame flags. The scheduler uses its
existing transaction nodes, pending slots, dirty queue, and stale-reader list.

The first attempt put the queued-work test into the general pending predicate.
That wrongly delayed unscheduled detached initialization. It was moved to the
publication gate; the initialization assertion was kept unchanged.

## Why the initial-publication case matters

The first fix worked for a child reading the optimistic output but failed when
the child read its async derivation. The async settle walk eagerly merged the
child's holder; after that was corrected, the child's render-effect replay still
entered the notifying context. Both were instances of coordination occurring
before a proposal was consumed. The final 12-case first-publication matrix
covers both targets, synchronous/async children, and all three completion orders.

`first-publication-audit.mjs` checks an ordinary initially pending source followed
by an async memo. Both pinned next and the candidate wait to publish the source
until its consequence is ready. The candidate's optimistic first publication
uses that same rule; next's specialized optimistic path can publish its source
before the first async consequence in the corresponding audit.

## Validation

- Full suite: **5,522 pass, 22 expected failures, two skips**, 327 files.
- Scalar-only expanded campaign: **110 pass**, seven files, with 100 seeds each
  for pending, branch switching, overlap, and latest. Legacy lanes are compiled
  out in this run.
- The new ownership file has 27 tests: DOM attachment at ownership depths zero
  and three; both release orders and simultaneous release; synchronous and async
  children; parked old frames; superseded replacement frames; first publication;
  and 50 successive unpublished replacements.
- The repeated-replacement case checks exactly-once cleanup, two live source
  subscriptions throughout replacement, and no subscribers after disposal.
- Source declaration checking and the scalar production build complete.
- Production audits cover the published-output and never-published-output
  timelines separately. Baseline is pinned next
  `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`.

The 22 expected failures belong to the existing compatibility/baseline cases;
none of the candidate scalar tests is marked as an expected failure. That does
not prove completeness of the model or cover APIs outside the scalar entry.

## Cost refinements

Stage 65 removed an empty ambient transaction that was created even when all
work already belonged to a layer's update. An ambient holder is still created
when ordinary unheld proposals need to be kept apart. Held dependency tails stay
retained even in a flush with no ambient transaction.

Other cold-path refinements avoid repeated hook installation, unnecessary
transaction sorting, iterator allocations over the proposal maps, and layer
traversal for plain signal inputs. The three passes that select all proposals,
assign their stable positions, and stage them remain distinct, preserving
setter-order independence.

Final production measurements are recorded under
`results/first-publication-stage66/`; earlier stage-64 and stage-65 artifacts are
intermediate snapshots. Compare performance only against pinned next. The
ordinary-path gains do not by themselves establish acceptance of active costs.
