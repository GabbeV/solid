# Error fixture audit and input-lifetime conflict

No runtime changes after stage 117. Baseline remains next `4fe75321`.

## Supported error recovery

The three failures in `rejected-first-read-reask-4244.test.ts` are not three
independent recovery defects. The first test catches a reactive-read throw,
returns a substitute, then the rejection halts the graph; the other two tests
inherit that halted graph. The proper error-boundary test passes in isolation.
Next passes the original fixture because its observation posture makes the
catching reader rederive. `RULES-DERIVED.md` D-42 explicitly says that this is a
mechanism, not a contract: reactive-read try/catch is not a supported channel.
The fixture remains unchanged and its failures remain visible.

New `layered-error-first-answer.test.ts` uses actual Error/Loading boundaries
and controlled requests. Four cases cover pending/latest, rejection before any
value or after a published value, retained error during recovery, and final
publication without undefined. All four pass in the experiment and pinned next.
This is a test/contract mismatch classification, not a new runtime workaround.

## Input-lifetime question, unresolved

A reduced public API example initializes an optimistic callback's input to A,
publishes an override A + mine under an open action, then independently changes
id from 0 to 1. The callback returns B either synchronously or from a controlled
promise. A rendered binding reads both id and the optimistic output.

| Input answer | Experiment after id changes | Next after id changes |
| --- | --- | --- |
| Synchronous B | 0 / A + mine | 1 / A + mine |
| Unfinished B request | 1 / A + mine | 0 / A + mine |

Resolving the request while the action remains open changes neither row's
visible values. Ending the action eventually publishes 1 / B in both runtimes.
The existing #4336 scalar tests explicitly pin next's async holding behavior.

The experiment's split follows two accepted rules: an active override does not
forward input demand (stage 79), while an arriving answer joins the guessing
actions and remains masked until their lifetime ends (stage 29). An unfinished
input may therefore let id publish before there is an answer to join. A sync
answer joins early enough to hold id. This is not disagreement between ordinary
readers of the optimistic output: they all consistently read A + mine. It is an
input/output lifetime decision at that explicit boundary.

Making inputs join immediately, including unfinished inputs, would make both
rows hold. Applied uniformly it would also revisit the accepted nested example
in stage 79: a second override can currently release the first override's update
while their intermediate async memo remains pending (1 / 3); retaining that
hold would keep 0 / 3. Conversely, retaining that release consistently suggests
reconsidering the join on ready answers. No fix or new expected behavior has
been silently selected. The reduced trace and both runtime logs are under
`results/integration-stage118/`; the temporary trace file is outside the suite.

Other remaining failures still need audit. In particular, extra publication
callbacks in the signed-zero pending/latest tests and deferred pending tests
were observed but are not yet classified or repaired.

## Hosted next reproduction

At the user's request, the sync/async comparison is available at
https://s.olid.uk/id/Urw8Ko_1SOSIff46AOctEQ . It pins the latest playground next
build available on 2026-11-06, `mizulu/solid2@4fe75321`, with Tailwind disabled.
One Run button starts both guessing actions; separate source writes occur at
500 and 1000 ms to avoid combining them into one ordinary update. The async
answer arrives at 1500 ms; both actions end at about 2000 ms. Browser checks
confirmed sync `1 / A + mine` versus async `0 / A + mine`, including after the
async answer, then final `1 / B` in both rows. There were no page errors. Source,
saved payload, runtime-request receipt and screenshot are under
`/workspace/scratch/optimistic-input-timing/`. No issue or PR was filed.
