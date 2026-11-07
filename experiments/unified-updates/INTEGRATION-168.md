# Coherent latest reads in owned frames

Stage 167 exposed a completed calculation with captured input 1, ordinary input
1, and latest 0. This stage repairs calculation and propagation. Eager first
callbacks are still separate, unfinished work; no callback-timing workaround is
part of this checkpoint.

## Where the implementation diverged

The creating-update stamp from stage 159 is necessary: removing it lets a new
child switch to the optimistic context and read ordinary input 0 beside the 1
captured by its parent. Its unpublished-frame read rule was incomplete, however.
It always served a higher output's old publication, even when that output was
latest of the very input proposal that created the child.

There was also a second path hidden by the direct API call: latest's eager
selection ran when calling latest(), but a memo wrapper could pull the already
allocated output without that call. It could consequently cache the old value,
both on the first held proposal and on a second proposal after publication.
The diagnosis in stage 167 described the already-selected case; instrumentation
in this stage additionally identified the not-yet-selected wrapper case.

The retained repair does the following:

- Keeps the child in its creating update. A ready observation of that update's
  input may supply its proposal to the private child without merging the two
  update lifetimes. Other optimistic inputs retain the committed-read rule.
- Keeps structural nodes on the publication side of that distinction. They wait
  for the observation to publish; using its private proposal could prematurely
  replace content or hold an error boundary's optimistic recovery in a lower
  update. Pending/error reads still use the ordinary status machinery.
- Selects an established hold from the latest output's own computation too.
  First initialization keeps its existing path: it has no old publication to
  replace. A selection made during a pull gets the same propagation round as a
  selection made by observation preparation, before restoration is considered.
- Does not notify subscribers of an executing selector's old result while
  transferring its update. The computation's outcome supplies the notification.
- Preserves pending initialization of a retained producer in its input context,
  rather than retrying it against the optimistic caller's older input. This
  matters for a retained child whose first result was an error.
- Remembers optimistic notifications that precede parking the old subtree.
  Removal ownership is checked when executing queued work: the update removing
  a subtree does not redundantly recompute it, while an independent optimistic
  update can still update the retained visible subtree.

This uses existing node/update storage. The proposal-read decision adds no field
or map lookup to settled ordinary reads. The extra dependency walks occur only
in owned cross-update reads and retained initialization. Performance and size
have not been measured in this correctness pass.

## Validation and semantic accounting

The eight strengthened owned-render tests and eight new repeated-write variants
check complete calculations, not just final callbacks. Both sets pass against
pinned next 4fe75321 too. They cover direct/memo-wrapped latest, both read orders,
and intervening owners. Existing controls exercise unrelated mounts, nested
optimism, async supersession, error/recovery, removal, and structural publication.

One execution-count assertion changes: the second-write #4400 case no longer
starts m1:33 from the expired optimistic m0:32. The final m1:35 publication
assertion remains. This follows the accepted rule that optimistic async work
cannot extend its own lifetime; no consistency assertion is weakened.

- Full signals: **5,593 passed / 1,980 failed / two skipped**: 1,953 deferred
  API cases and 27 non-deferred failures. The eight strengthened calculations
  and eight new repeated-write cases pass. One previously passing scalar case,
  `latest-shadow-owned-write` with its live output, now encounters normal
  NotReady control flow and reverses its final two callback entries. Its old
  assertions remain unchanged; classify this with the unfinished initial
  callback work, not as a silently accepted semantic change.
- Full web: **1,703 passed / 119 failed / one skipped**, exactly the previous
  failure set. The latest error/recovery/removal controls all pass unchanged.
- Mangled production public set: **522 passed**. Declarations, all build tiers,
  purity, rules-index and diff checks pass.

The earlier full reports in the receipts are rejected trials. `signals-complete`
and `web-complete` describe this checkpoint. No performance or bundle-size claim.

Rejected trials included exposing every higher proposal to a new child,
restarting every latest selection through its input, postponing all private
reads, and broad first-callback release. They either mixed unrelated contexts,
changed holds, duplicated callbacks, or broke recovery. Their reports and source
snapshots are preserved as investigation receipts, not alternate implementations.

The detached-DOM trace still starts with an empty span in the experiment and
with initialized text in next. Calculation consistency is repaired before
addressing that callback difference. The experiment is not merge-ready.

Receipts: checkpoints/integration-stage168.tar.xz.
