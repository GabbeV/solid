# Comparator-query quiescence: initial candidate and rejected cleanup trials

Discovery/implementation: supervised Sol medium agents; primary review.

The equal-selector enqueue correction remains under validation. The generic
core `!tracking` dormancy extension and synchronous final scheduler sweep below
were **retracted**, without changing existing test assertions.

The full candidate passed 5,790 tests and failed 1,967 (2 skipped). Compared with
the stage182 full receipt, it introduced 14 failures and resolved none of the
1,953 existing failures. Independent scratch isolation found:

- The final sweep changes #3554's deliberately tested cleanup timing. A lazy
  memo revived by its owner's cleanup is reclaimed immediately and recomputes
  on the next read. Both entry HEAD and current next retain it after a turn.
- The generic `!tracking` extension changes ordinary memo reuse in
  `untrack.test.ts` and introduces 12 stale-pending publication failures in the
  two #4648 verdict files. These assertions remain requirements.
- The other two changes alone do not introduce those failures.

Source-owned observation reclamation is being investigated separately. Generic
ordinary-memo untracked lifetime is outside this correction: changing it would
require a semantic ruling. Neither the synchronous final sweep nor a new
maintenance scheduling mode is retained. No throughput claim is made.

The following sections preserve the rejected trial's mechanism and validation,
so its green focused selection is not mistaken for final acceptance.

## Failure mechanism

With B held by an open action, an ordinary observer reads B and isPending(B).
B's equality comparator reads isPending(unrelated C), then returns Object.is.
C has no observers. Its source-owned pending companion initializes false and
subscribes to C. Observation settlement installs an equal false selector and
stageLayer unconditionally enqueues that companion. The next internal flush
sweeps it dormant before the heap; settlement reads/revives it again. Repeating
this creates work without changing a public answer and prevents flush return.
The original observation worklist matrix bounds comparator calls to expose it.

## Final candidate changes

`layers/coordination.ts`, existing equal-settled stageLayer branch:

- Existing conditions remain: inputUpdate is null; output is not held; its
  pending value is NOT_PENDING; proposal is concrete and comparator says it
  equals the output's committed value.
- Keep position, override and enableReads mutations exactly where they were.
- Skip enqueue only when output has no subscribers, has CONFIG_AUTO_DISPOSE,
  has none of STATUS_ERROR/STATUS_PENDING/STATUS_UNINITIALIZED, has no shown
  error, no live children, no pending children and no pending disposal.
- Every other case retains original enqueue. In particular optimistic outputs
  deliberately clear AUTO_DISPOSE, so their error/status/equal-override paths
  retain the scheduled pass. Existing source subscriptions remain established
  by observation fallback/markObservation; readOverride retains the input edge.

`core/scheduler.ts`, GlobalQueue.flush:

- Keep the original pre-heap sweep inside \_running/try, after companion resync.
- After effects and holdEnd, before dev quiescence validation, call
  `if (!scheduled) sweepDormant()` inside that same \_running/try boundary.
- A clean query left by settlement can then release without another full
  observation preparation round. Actual cleanup writes set scheduled and the
  ordinary outer drain continues. No resync/attribution hook is moved.
- No separate microtask, deferred worklist, node field or cache remains.

## Rejected trials and preserved obligations

Moving reclamation from internal pre-heap rounds to public drain boundaries
broke lifecycle behavior. Keeping nodes alive during pure work, then even only
during settlement, caused a commit cleanup's untracked read-then-dirty ownerless
memo to start abandoned async request 1: requests [0,1] versus entry [0].
Heap flags cannot distinguish that real dependency invalidation from the equal
selector's self-enqueue: both may have only IN_HEAP before lazy heap marking.

Initial sweep outside \_running/companion resync and final sweep outside \_running
also permit different cleanup reads/reentrant flush behavior; those changes were
rejected. All generic worklist/relocation prototypes were restored. A temporary
per-query dormancy microtask was replaced by the final in-flush sweep above.

Skipping the equal selector alone terminates synchronously but strands C's
subscription while B remains open. The final sweep is necessary: the added
control keeps the comparator armed across two event-loop turns, verifies its
call count stops increasing, requires C's source subscription to release, and
keeps B's display held throughout.

## Source-state dependencies

The retained run includes independently owned fixes under review:

- latest.ts maintenance registration uses untrack around holdQueuedProposals
  to avoid accidental comparator-driven self-dependency while preserving held
  read context. Observation agent owns that patch/matrix.
- core.ts queues subscriberless AUTO_DISPOSE computeds for reclamation on
  untracked reads even with an active context. Creator-publication agent owns
  that eligibility patch and separate open-action lifetime controls.

The latest held-context test's final subscriber retention failed both with and
without the initial coordination patch; do not attribute that separate leak to
this enqueue change. Combined validation must include both independent fixes.

## Validation and remaining failure

Direct package Vitest, maxWorkers=1 throughout:

1. Original entry runtime passes four dedicated controls: effect read-then-dirty
   does not start abandoned requests; cleanup's real writes publish before flush
   returns; nested cleanup flush does not publish callbacks before cleanup ends;
   committing child cleanup read-then-dirty does not start abandoned requests.
2. Added controls cover late pending/latest observer admission and retirement,
   unobserved optimistic shown-error to equal last-good override, lazy undefined
   output/late reader, and armed idle-held quiescence/reclamation across two turns.
3. Current observation matrix plus eight dedicated controls and observation
   dormancy/owner retry/context-retry-error/equality-publication: 123 passed in
   six files with the combined candidate/source dependencies.
4. Broader requested source selection: **508 passed, 1 failed in 39 files**.
   Failure: dormant-memo-chain-3554.test.ts, "a lazy memo a cleanup reawakens
   while its owner's held children are torn down stays on the chain", line172.
   Expected owner chain [cleanup2,m2,m1], received [cleanup2,m2] after flush.
   This could reflect the final sweep or expanded untracked-read eligibility;
   no isolation was run because primary froze edits/tests as the run completed.
   Primary must compare each change against this control before retention.

Broader selection included all unified observation-_, pending_, latest*, owned/
stable/owner-retry/context-retry-error controls, isPending memo consistency,
unified-is-pending, unified-review-*, equality-publication, createMemo,
released-memo-retry-runs-4474, disposed-read-lifecycle and dormant-memo-chain-3554.
No production or size claim is made. Primary owns serial remaining validation.
