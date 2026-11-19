# Preserve a new child's provisional parent frame

Fix the remaining #4341 calculation failure without changing its assertion.
A held condition opens a branch. Inside that branch, a wrapper memo creates a
memo reading latest(zone) and the branch condition. The first calculation saw
`ready:stale`, even though the parent had just consumed the proposal that made
the condition true. It corrected before the branch's DOM attached.

The parent's provisional update had not yet merged with the input update.
That deferred merge is intentional: later dependency discovery must remain
free to choose a different context. But the child's frame-read check treated
its observation as permission to read the peer input's old value, despite
recognizing that the child belonged to an unpublished parent frame.

Preserve that frame when reading a peer proposal. Existing higher/lower update
checks still apply; no early transaction merge, new ownership field or new
context is introduced. The child now computes `ready:selected` on its first
pass. A trial that only recognized already-held ancestors did not help: the
parent in this case has consumed a proposal but is not parked yet.

## Validation

- All **145 focused cases pass**, including the original 30 #4341 combinations,
  nested ownership, late mounts, observation context and staged-error recovery.
- Full signals: **5,508 passed / 2,022 failed / two skipped**. This includes
  stage 156's ten assertion migrations and this one runtime repair. No new
  failures or collection errors relative to stage 155.
- Full web: **1,697 passed / 121 failed / one skipped**. Stage 156's six
  migrations are the only changes in failures; no new failures or collection
  errors. The 49 actual Show/Match controls still pass.
- **362 public-API controls pass against the rebuilt, property-mangled
  production package**, including all 30 #4341 cases.
- Build tiers, property mangling, purity, declarations, rules-index and diff
  checks pass. No performance or size comparison is claimed.

The refreshed inventory retains 1,953 explicitly deferred signals failures,
67 untriaged signals failures and the two known first-proposal ownership
failures. Web retains 115 deferred failures and six untriaged failures. These
categories do not waive consistency, work-count or initialization assertions.
The experiment is not ready to merge.

Receipts and the rejected trial: `checkpoints/integration-stage157.tar.xz`.
