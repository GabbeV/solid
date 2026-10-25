# Unverified general committed-storage settlement frame

This is a proof attempt, **not an active theorem or a runtime implementation**.
The independent pinned kernel reports `out of fuel` in `tailByRemainingFrame`.
It is excluded from LAWS/PROOF and the successful-root count. No rejection caused
by this resource limit is credited as a negative check. No runtime, theorem domain,
kernel limit or toolchain was changed to make it pass.

The candidate states that actual callback-free `Pending.advance` retains all
committed node values, the tree and the complete trace, including faulted input states (the observation itself has no fault field). Helper forms are connected to the actual operation; the difficult
point is reducing the full settled-node continuation. Several cuts at source
status/queue boundaries reduced the expression but did not close that lemma.

To resume, copy runtime/representation/proof into a scratch directory, copy the
`.bend.txt` candidate into its proof directory as `pending-settlement-frame.bend`,
and run the pinned Bend CLI with `--verdict` on that file and the pinned Lean PATH.
Do not import it into the active proof set until the independent check succeeds.
The receipt names the exact source checkpoint and candidate/log hashes.

The separately active pending-continuation and pending-stack-history modules
prove stack/capture contracts and actual-step prefix induction. They do not rely
on this candidate. Owner release can invoke cleanup code; unrestricted callbacks may write or
flush, so a content frame needs an explicit callback contract. The source
bookkeeping itself retains cached `_value`; an earlier explanation that it
directly cleared the value was incorrect. The selected larger milestone also
needs a renderer/target observation that permits independent publication.


## Superseding active result

The original candidate above remains unverified and unimported. The later active
[proof and source-segment audit](../../tracking/pending-committed-history.md)
checks the same all-values/tree/trace claim after naming the original runtime
status/tail blocks. No branch/order/step or checker limit changed. The active
proof does not rely on this archived candidate. Smaller UI-only and World-match
attempts also hit reduction limits; those failures were not credited as proofs.
