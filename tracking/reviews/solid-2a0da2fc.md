# Solid next 2a0da2fc (rc.18)

Reviewed 17 commits after 225014bf. All 77 recorded Solid inputs match the new
Git checkout byte for byte; four source files change: core/async.ts,
core/constants.ts, core/dev.ts and deferred.ts. The source-impact report is
[solid-2a0da2fc-impact.json](solid-2a0da2fc-impact.json).

## Production integration

Merged #4248 (0dd40b28) extends the EXISTING createDeferred try/catch through
returned-result protocol setup and initial serving. The Bend DeferredResult
continuation installs a passive DeferredCatch across those calls; successful
returns consume it without an extra machine dispatch. Callback exceptions use
the existing sourceFailed ask/land/rethrow policy, with the original caller
stack restored. First-load handleAsync remains outside the closed-window wrapper
return, as in the source. No wrapper, scheduler or iterator algorithm is replaced.
The formerly preserved bug010 cases now assert released flights and current-error
delivery independently of obsolete requests. Historical baseline receipts remain.

Merged #4250 (253561ee, issue #4244) adds STATUS_NO_VALUE and updates notifyStatus.
An error that answered a node with no usable value records that fact; a re-ask
restores uninitialized-pending status. Real successful undefined and loading
seeds remain usable-value controls. Both pending-source and bare-status branches
follow the source bit selections and mutation order. Existing shown-error policy
is preserved: an untracked isPending probe may report the shown error posture
while latest throws NotReady for a never-valued pending answer.

The 24 new public histories cover first sync/async errors, previous concrete and
undefined answers, loading seeds, plain/user observers, latest/pending probes and
recovery. The private status matrix doubles to 6,144 cases, covering every bit
combination through STATUS_NO_VALUE. These are execution evidence, not a theorem
over all error/graph histories. Active loading/error boundaries remain outside
the port; upstream boundary tests are run natively.

## Other changes and retained limits

core/dev.ts adds the ASYNC_MEMO_ELEMENT diagnostic type for the server web fix.
This erased TypeScript union adds no non-store production Bend operation.
Other commits touch examples, compiler SSR and web serialization/SSR/hydration;
those layers remain outside this translation's admitted profile. Their files are
reviewed through the complete Git diff; only recorded signals inputs are vendored.

Bend 2.0.37, Lean and independent kernel/resource limits are unchanged. No active
semantic deviation or new upstream bug is introduced. Every earlier proof domain
and sufficient budget is retained; actual deferred data programmes still take
103 steps and the fixed stream-refetch programme 118. The latter's intermediate
canonical states are regenerated for the passive catch scope, not enlarged into
a new history witness. Two quantified catch-scope roots are added.

The native package builds all three JS tiers and source declarations, passing
343 files /5,576 tests, two expected failures and two skips. All 120 native
protocol repro/control cases and six real JSX cases now pass the fixed policy.
Bend public/alignment/kernel results and hashes are recorded in the
[validation receipt](solid-2a0da2fc-validation.json) and tracking/checked.json.
No fresh complete 608-variant sweep is claimed by this integration receipt.
