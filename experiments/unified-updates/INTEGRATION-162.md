# Transparent latest before an override exists

Retain the user's chosen first step: latest reads its ordinary input while no
hold has selected an override. A synchronous signal update therefore propagates
once through latest, including while unrelated actions or async updates remain
open. Remove eager preparation of unheld latest values and the observation-kind
flag that existed only for that path.

When an action has already established a lifetime, register its queued proposals
before choosing the latest input, but only during a flush. Imperative reads of
unflushed writes retain their prior visibility. An unheld staged error follows
the same input path as an unheld value; returning the previous latest value there
allowed old async answers to recover a displayed error incorrectly.

## Context changes and preparation

For `10 * latest(id) + id()` with id initially 1, an independent update to 2 now
requests **22, 21, 22**, with only the final flight eligible to publish. The old
12 request (stale latest beside proposed ordinary input) is gone. The optimistic
21 cannot supply its own lifetime. With an independently open action, 21 can
publish while the action remains open, then correction 22 publishes after it ends.
Avoiding the expired optimistic request and reusing the first 22 are deliberately
left to the subsequent scheduling investigation; this stage adds no cache or
parallel retained flights.

Observation selection can queue a reader in a higher context just before the
preparation loop replays that same reader for a ready lower input. Let an already
queued higher reader run before lower preparation takes it back. Other ready
readers still prepare in that round. This repairs inline pending feedback without
suppressing a ready shipping preview whose total is waiting for tax.

Rejected trials are archived: preselecting readers from their previous dependency
frames prematurely cleaned children; deferring all preparation after observation
selection lost ready shipping previews. A special selection return code did not
repair those losses. The retained condition uses existing heap membership and
context information; it adds no node field or return protocol.

## Assertions and observable controls

- Twelve new signal controls cover read order, inline/memo latest, and unrelated
  action/async holds. Each completed synchronous calculation and publication is
  `[2,2]`, once.
- Three controlled-flight tests check 22/21/22, both stale-answer arrival orders,
  and the independent action lifetime. Abandoned answers cannot publish.
- Two error controls cover initialized/uninitialized chained async latest reads,
  old-answer arrival after an error, and genuine later recovery.
- Five existing store/signal parity traces replace the invalid pre-hold `0/1`
  calculation with `1/1`. Their complete cross-source trace and publication
  assertions remain.
- Twelve #4393 assertions now pin the coherent input/optimistic/correction request
  sequences rather than global request uniqueness. Existing no-torn-publication
  checks remain. Five other failures in that file remain under audit.
- One #3698 test checks each sibling binding's sequence independently instead of
  requiring a particular sibling's callback to run last. Sibling order remains
  unspecified.

Two keyed-Show construction assertions regress from `[1,2,2]` to `[1,3,3]` in
both signals and web. These remain failing, not waived as semantic changes. New
JSX controls exercise three successive key changes with static and callback
children: every displayed child has a live owner; discarded children clean up
once; input completion preserves the already displayed higher-context DOM node;
final disposal cleans all instances. These controls pass. Extra speculative
construction remains an optimization gap, separate from that ownership evidence.

## Validation

- Full signals: **5,553 passed / 2,002 failed / two skipped**, no collection
  errors. Failures include **1,953 deferred API cases and 49 non-deferred cases**.
  Relative to stage 159, 20 old failures pass, 18 assertion migrations pass,
  and two construction-count regressions remain. The full count includes the
  eight stage-159 controls and 17 new controls.
- Full web before adding the two ownership controls: **1,699 passed / 119 failed /
  one skipped**, no collection errors. Four synchronous calculation-count failures
  are fixed, two keyed construction counts regress. The generated error-recovery
  failure from rejected stages 160/162 trials is absent. The two new JSX ownership
  controls then pass separately. Remaining full-suite failures are 115 deferred
  cases, two construction counts, and two previously reproduced next/Seroval cases.
- **387 public-API controls pass on the rebuilt, property-mangled production
  package.** The new 17 controls run on pinned next `4fe75321`: 15 pass; the two
  expired-flight controls differ at the expected request sequence, because next
  retains the original 22 alongside 21. Stage 160 records next's publication
  behavior for that difference.
- Build tiers, property mangling, purity checks, declarations, rules index and
  diff checks pass. No new performance or bundle-size claim.

The complete failure inventory remains archived. A finite suite does not prove
all coordination graphs correct. First held proposals, detached first callbacks,
other request lifetimes and the remaining scalar failures still need resolution.
Receipts: `checkpoints/integration-stage162.tar.xz`.
