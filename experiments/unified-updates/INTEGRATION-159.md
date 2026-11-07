# Preserve the creating update across nested pulls

An existing detached-binding fixture exposed a reentrancy gap in the owner
query. A parent reads id=1 from an ordinary action update and creates a render
binding. Pulling latest(id) temporarily executes a higher update. The owner
query returned that ambient higher update as the still-running parent's frame,
allowing the new binding to leave the frame that created it. Its completed
calculation then paired captured id=1 with ordinary id=0.

Stamp the creator's provisional update before creating children after it has
consumed staged or held inputs. The owner query can then use that existing
stamp across nested pulls. This does not merge peers early: normal dependency
acceptance still decides entanglement. No field, cache, context stack or saved
version map is added. The change runs in active coordination's creation path;
its cost has not been measured against next.

## Focused evidence

Eight new public-API controls vary inline/memo latest, read order and zero/two
intermediate owner memos. The displayed parent stays at `0:0` during the action,
then reveals `1:1`; no completed new-child calculation may pair `[1,0]`.
The pre-change engine passes four and fails four. The retained engine and
pinned next `4fe75321` both pass all eight.

Adding staged-owner recognition alone, or stamping only deferred proposal
joins, did not fix the issue. The parent can create children before its first
input has been parked. Those trials are archived.

The existing C4 and held-frame fixtures still expect particular initial
callbacks into detached children. The retained change makes C4 inline/memo
forms both wait, but those old assertions remain failing and unchanged. This
stage does not classify all their callback timing requirements or treat passing
DOM tests as permission to discard the calculation failures.

## Validation

- Full signals before adding the eight controls: **5,510 passed / 2,020 failed /
  two skipped**. Stage 158's two migrated assertions are the only old-suite
  changes relative to stage 157; no new failures or collection errors.
- The eight new controls pass independently. The related 187-case focus has
  164 passes and the same 23 existing failures.
- Full web: **1,697 passed / 121 failed / one skipped**, unchanged from stage
  157; no new failures or collection errors.
- **370 public-API controls pass against the rebuilt, property-mangled
  production package**, including all eight new controls.
- Build tiers, property mangling, purity, declarations, rules-index and diff
  checks pass. No performance or size acceptance claim.

Two web serializer failures are also reproduced in the pinned next checkout
with the same installed dependencies: an already-failing Seroval stream emits
`error,data,done` rather than `error,done`. The serializer implementation and
fixtures have no experiment diff and do not depend on reactive core. The normal
next web setup initially failed collection on a dependency path; the isolated
serializer configuration collects both cases and reproduces both failures.
Keep these as unchanged upstream/dependency failures, separate from the four
remaining non-deferred web calculation-count failures. They remain counted in
the full suite; no assertion or serializer code was changed.

Receipts: `checkpoints/integration-stage159.tar.xz`.
