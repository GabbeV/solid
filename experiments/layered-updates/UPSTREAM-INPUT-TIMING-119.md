# Upstream input-timing investigation

Follow-up: the user authorized trying independent incoming-input lifetimes in
the split-node implementation, while retaining same-output guess entanglement.
That implementation and validation are recorded in [stage 120](INTEGRATION-120.md).
The investigation below records the earlier upstream trials, not an outstanding
request for a ruling.

The user requested a playground comparing next's sync/async input holding, then
asked whether it is an obvious fix worth a PR. Public reproduction and initial
comparison are recorded in INTEGRATION-118.md. No PR or issue was opened.

A separate checkout at /workspace/next-input-timing-fix uses next 4fe75321.
Trial patches, before/after JSON reports and notes are in
/workspace/scratch/optimistic-input-timing/upstream-trial/.
The main layered experiment is unchanged by this investigation.

Next explicitly joins an active guess's parent when a changed input causes a
pending status (async.ts notifyStatus, #4336/#4337). The sync laneOutcome path
does not do that join. Adding it fixes the original scalar reproduction, for
both confirmation and correction and with/without an intermediate memo.

The complication is D-33/#4330: a shared answer was deliberately prevented from
merging independent guessing actions. A new probe with two scalar optimistic
callbacks reading fields of one refreshed memo finds that next only preserves
that independence when the response is synchronous. An asynchronous refresh
already joins the actions. The equivalent optimistic-store probe keeps
separate property guesses independent in both cases. Merely saying “refresh
should be exempt” does not describe next's actual behavior.

A further candidate passes recompute's existing saved refresh classification
into laneOutcome, instead of reading its already-cleared flag. It adds no node
fields. The candidate makes both sync and async shared-memo cases entangle;
it leaves the store cases independent. All eight original input-change cases
and the focused existing #4336/#4329 tests pass. The independence probe still
fails for shared scalar sync (changed by candidate), shared scalar async
(already fails on next), and two same-call direct synchronous refreshes
(already fails on next). These failures are not waived or changed expectations.

Semantic decision needed before recommending that upstream patch: should two
scalar optimistic boundaries backed by one changed memo join their guessing
lifetimes, consistently for sync and async input results? This is separate
from the original one-boundary case. No ruling is inferred from the user's
request to continue investigating.

## Alternative requested: no implicit incoming-input lifetime join

A separate local next trial removes the pending-input-to-guess-parent join;
it leaves ordinary graph coordination, same-slot guesses and own-flight holds
alone. Both sync and async versions of guess -> save -> refresh, with an
independent ID change during the save, pass the proposed release timeline:
0 / A + mine -> 1 / A + mine -> 1 / B. Shared memo response actions remain
independent for both response timings. A same-call direct sync refresh still
merges, as on unmodified next. Patch/receipt are preserved in the scratch trial
folder; runtime trial is reverted, and the main experiment is unchanged.

This establishes a small executable alternative, not full-model correctness.
Keeping a guess over an input whose page/resource identity changed can be
application-wrong despite ordinary readers agreeing on the output. Removing
same-slot guess lifetime merging as well is a separate question: a functional
second guess can contain the first guess's contribution. Independent retirement
then needs rebasing or a different overwrite/retention contract. No new ruling
is assumed from the user's question about this alternative.
