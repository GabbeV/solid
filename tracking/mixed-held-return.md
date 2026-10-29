# Mixed held settlement through round return

Seven additional composed roots extend [mixed parking](mixed-held-settlement.md)
through actual settlement entry, callback parking, clock update, empty execution
queues, flush-finally, cleanup check and saved-question restoration. Runtime,
source178605cf, checker profile and fuel are unchanged. Only the completed full
composed verdict and exact tracked-input seal grant checkpoint proof credit.

## What is derived

`settle-entry` follows `beginSettle`/`settleJoined`/`applyGuessesAt`. The initial
lane-live and guess queues are empty; the source still clears `flushTransaction`
and records the judged lane prefix. The resulting World is explicit, not assumed
to equal the original. `settle-entered-ready` constructs the mixed admission there
from the original certificate. `mixed-settle-entry-scan` starts at the real
`Settle` task and derives the same actual positive-debt scan as the earlier
`SettleApplied` contract, including retained debt and committed storage.

`held-queue-parking` follows `completeSettle`: resolve the captured group, check
its actual live membership, release the empty ambient-mark scope, append the
captured render/user callback arrays to the group's respective existing queues,
then leave the live execution queues empty. Arbitrary represented callback
identities and pre-existing queue prefixes are retained in source order. The
proof does not run or assume termination of those callbacks.

`arena-observation-lens` generalizes projection-preserving existing-slot updates
to arbitrary represented arenas. `held-queue-frame` uses it to retain all group
metadata other than callback arrays, including counts, redirects, membership,
lane identity and marks. The non-arena footprint and stored committed data/tree/
event trace are separate exact frame contracts. This is not successful allocation
of an out-of-range group slot.

`quiet-round-return` checks six real steps after settlement: clock/schedule,
render queue, user queue, flush finally, cleanup rethrow check and caller-question
restore. Its initial heap/pending/execution queues are empty and its cleanup
error slot is empty. The updated clock and running/pass fields are explicit;
caller work and stack are retained. It does not swallow a cleanup failure.

`mixed-parked-scope` derives all intermediate terminal/live/health/control and
empty-queue obligations from initial facts and the actual entry/hold/settlement
frames. `mixed-settle-return` composes **eleven actual steps** from `Settle` through
the positive-group scan and callback parking to the caller's remaining work. It
also proves stored committed values/tree/trace are retained and the final actual
action count is still `1 + remaining`. The starting mixed certificate, positive
count, singleton live group, captured group ID, empty lane/guess/ambient scopes,
exhausted heap and empty cleanup-error slot remain explicit initial premises.
No post-scan/post-park count, health, queue or caller equation is supplied again.

## Evidence and remaining gap

640 paired unchanged-Solid/Bend private whole-round controls vary the320 earlier
parking cases with/without callbacks and existing callback prefixes. They compare
exact member/queue order, retained action debt, ownership, clock, schedule,
running/pass state and caller-question restoration. Native caller restoration is
an explicit `setQuestion` after `globalQueue.flush`; the Bend proof follows its
actual `ActionRestoreQuestion` task. These inputs are private seeds, not proof of
public action/heap reachability. Marker callbacks would produce observable native
calls and Bend trace events if executed; all remain parked. An initial silent
callback fixture accepted a run-own-queues mutation, so it was strengthened with
markers before rejection credit. A rejected compiler or resource failure never
counts as semantic detection.

Six targeted source mutations cover lost prior/new callback arrays, executing
held callbacks, leaked running state, skipped caller restoration and omitted
judged-prefix recording. The last uses the mandatory unchanged kernel oracle
before compiling the mutant. These focused checks do not replace a full sweep.

The earlier source rebase is complete at0ffa4d49 (789 roots). Mixed parking is
complete at **a5fa2e9504748829c3462d0a9e27f070d8e34990**:798 roots,1335 tracked inputs,
552.370199302 seconds, normal feature-branch push independently verified. The
current seven roots require the fresh805-root composed verdict/seal.

**Still open:** deriving this initial mixed certificate after the raw queued
Round/heap phase, and continuing the complete uninterrupted history to the other
controller's actual delivery. Full public factory/host reachability, group-forest
preservation, once-only action/result and observed-flight ledger, general
branching publication safety and eventual reveal remain further obligations.
This contract does not claim committed render-cache values are unchanged during
the earlier heap phase; publication observations must respect reader posture.
No new upstream bug, workaround or semantic deviation was introduced.
