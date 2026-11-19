# Observation revival correctness repair

## Confirmed bug and repair

Clean HEAD independently reproduces a source-owned pending output publishing stale
`true` after its held input has finished. A calculation reads an ordinary condition
and queries its pending companion under `untrack`; a standalone query before the
held request resolves allows the existing dormancy sweep to dispose that companion.
The final render and user effect then receive `{ value: 5, pending: true }`.
The standalone query does not need an explicit flush. The control without it passes
on HEAD, and the failure also reproduces with production source defines.

Disposal removed the companion's watched input question and retirement state.
Revival was consequently treated as first initialization while the input proposal
was still held, selecting another `true` rather than restoring the finished input.
The repair keeps an existing question watch and its parent/time/retirement metadata
through dormancy, while still discarding cached output storage and subscriptions.
Existing preparation retires the observation in its original input update. Pending
fallback does not initialize a new observation during that restoration.

The retained watch also requires invalidating retirement when the input revision
changes. The public supersession regression holds a false restoration with a new
async consequence, makes the companion dormant, and starts a replacement request.
Before the revision guards, the replacement incorrectly reports pending=false.
The dirty, watched, and selected paths now all discard retirement of an older input
revision. The regression checks pending=true, latest retaining the preceding answer,
no early visible completion, final replacement publication, and no overwrite from
the obsolete restoration.

Explicitly dead outputs or input owners release the watch. A dormant lazy source
may already have detached from its owner's child chain when that owner dies; the
input-parent disposal check mirrors core prepareComputed's existing revival rule.
There is no added wakeup on owner disposal: dead bookkeeping is reclaimed at the
next actual reactive flush or parent completion.

No new node fields, work queues, registry, core changes, or scheduler changes are
part of this repair. Existing latest.ts comparator untrack and coordination.ts
settled-equal-output repair remain separate changes owned by the primary.

## Validation

Final scratch candidate: 112 passed / 113 cases in 15 focused files. Receipt:
`/workspace/scratch/correctness-review/observation-revival/minimal-final-validation.log`.
This includes 24 verdict committed/landing cases, two standalone-query revival
cases, the public supersession case, ordinary dormant-chain and untrack controls,
observation publication/worklist cases, and selected latest/error/first-answer/
context-retry/owned-repeat controls.

The only failure is the previously identified, deferred assertion
`a latest companion queried by a comparator releases its held input subscriptions`
in unified-review-observation-worklist.test.ts. It is a proactive reclamation
lifetime question, not claimed fixed by this patch. No existing assertion was
weakened. Additional source-output reclamation/quiescence assertions are likewise
not acceptance evidence for this minimal repair.

Scratch-only instrumentation adds five passing retirement audits, including
20 real dormant questions whose consumers never query pending again, 20 standalone
action/query cycles, first-load owner disposal, owner disposal during an open action,
and a detached lazy source whose owner dies. Watched and dirty sets drain to zero;
the detached-owner check is made after an actual unrelated reactive flush. The
diagnostic globals are absent from the shared runtime.

Core/core.ts and core/scheduler.ts in the validated scratch candidate were checked
byte-for-byte against HEAD. The primary owns formatting and the broader source,
build, production, and size validation after this focused handoff.

## Rejected or deferred candidates

- Broad untracked-read dormancy and synchronous final sweeping changed ordinary
  memo reuse and owned cleanup timing; those trials remain rejected.
- Mark-only companion enrollment reproduced stale pending in 12 verdict cases
  and could strand final-phase enrollment after the scheduler overwrote schedule().
- Forcing retirement or bypassing initialization solely because the parent was
  ready failed four later-flight landing controls; it lost a newly discovered hold.
- A source-only WeakSet plus deferred microtask sweeper passed 67 focused cases,
  but proactive source-output reclamation changes lifetime behavior relative to
  the comparison baseline. It is deferred for an explicit user lifetime decision.
  No part of that enrollment, registry, or sweeper remains in shared runtime.

Owned scratch variants and receipts remain under
`/workspace/scratch/correctness-review/observation-revival/` for audit.
