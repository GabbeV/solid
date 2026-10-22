# Solid next rc.17 integration preflight

This is a review, not a repin. The active, verified program remains
`a2a5b6f8f54addab694a1040721a86208349b8ea` (rc.16), with no semantic deviations.
The clean detached candidate fetched on 2026-10-22 is
`5b1b777648a89b6e207e8bb78514d5c03420e08b` (rc.17). The completed lane checkpoint
is `0371fe66c9cc258381dcd2dd6df16ee7968ad047`.

Six commits advance next: #4213 cleanup continuation, #4210 optimistic keyed
folding, #4211 falsy fallback retention, #4214 compiler CI, and two release
commits. The [impact report](solid-5b1b7776-preflight-impact.json) identifies
changed source functions against the active correspondence table. Its local
snapshot disclaimer is supplemented by the independently checked commit and
clean status in [validation](solid-5b1b7776-preflight-validation.json).

## Cleanup policy is now explicit

#4213 guards each onCleanup callback and effect-returned cleanup during owner
teardown. The rest of the LIFO list, siblings and ancestors continue after a
callback throws. The first thrown payload is boxed, including thrown undefined.
A bound root disposer outside a running flush rethrows after teardown; cleanup
inside a flush rethrows once at the end of the completed flush. Collection also
schedules a flush. Fatal halt drops the collected error before reporting the
fatal error; the development loop guard drops it too.

Actual source sites are owner.runCleanup, owner.rethrowCleanupError,
owner.runDisposal, owner.disposeChildren, owner.disposeRootSelf,
graph.unlinkSubs, scheduler.flush and scheduler.haltReactivity. Core recompute
removes #4176's collector-restoration try/finally because user teardown errors
now stay inside runCleanup until the flush ends. Port that final source tree;
do not retain the finally solely because its earlier regression passed.

The Bend integration must add a missing/present cleanup-error slot, retain the
first payload identity, restore healthy callback execution between guarded
callbacks, and preserve source scheduling and rethrow return points on the
shared owner/core driver. Raw internal disposal helpers must not gain the
public bound-disposer rethrow. Nested disposal and effect-pre-rerun cleanup
need separate call-site review: apply the guard only where source calls it.
Update old interrupted-teardown histories/properties rather than weakening
assertions. The earlier collector fix was a real regression repair at its pin;
this new upstream policy deliberately supersedes its implementation.

## Falsy fallback retention

Merged #4211 changes exactly two retry guards in updateKeyedMap and updateRepeat
from testing the first output's truthiness to testing the output array length.
Successful falsy results then stay mounted; interrupted attempts still retry.
The current Bend map modes intentionally retain the old pin's behavior. On
repin, translate those guards, replace preserved-bug expectations with positive
retention regressions and update SOLID-EMPTY-FALLBACK-006's status. No workaround
is installed by this preflight.

## Optimistic stores and shared lane hooks

#4210 adds an optional Transaction.folded callback, joinPassAt, a folded-read
screening branch in core.read, folded checks in laneRead/verdictValue, and a
boolean-returning lane rebase hook called before the stale-question decision in
laneWrite. The store implementation adds keyed fold and sink-slot bookkeeping.
Store APIs remain outside the admitted profile, but shared imports, hook
installation and entry guards still require review; exclusion is not evidence
that these hooks are unreachable.

The marks, lane identities/groups, verdict bookkeeping, blocker judgments and
laneStage operations added this continuation are unchanged at their source
bodies by this update. Their surrounding read/write/reveal/correction and public
verdict-window engine is still unfinished. Do not admit those scopes by adding
a default return or an entry-only wrapper.

## Validation and next integration milestone

The four selected native files pass: cleanup-throw-continues,
deferred-release-cleanup-throw, empty-fallback-value and optimistic-keyed-fold:
39 tests total, source execution with the package's Vite configuration. These
are source-only controls, not Bend parity or formal proof. An initial invocation
from the monorepo root missed package build defines and collected zero tests;
it is recorded as a failed setup, not successful evidence. The corrected
package-directory run passes all four files. No full rc.17 suite or browser
validation is claimed.

Next: review the new module globals/ABI and callback return points, port cleanup
continuation and fallback guards, audit shared folded hooks without admitting
stores, then re-run affected native/Bend comparisons, public histories,
mutations and the complete independent proof root before changing the pin.
