# Latest preparation and ownership investigation

No runtime changes are retained. Stage 152 remains the runtime checkpoint.
The investigation distinguishes two missing ownership operations from callback
ordering and speculative calculation counts.

## Inactive latest propagation

Re-testing the stage-149 transparent synchronous path after the error fixes
still repairs the one-pass controls, but loses other observations and exposes
an early Loading swap. A trace identifies the swap mechanism: installing the
latest override transfers its already calculated consumer, the newly built
fallback, and then the boundary output. The fallback's selected value becomes
an independently published structural swap before the action-held navigation.

A trial gave the separately retained fallback an unpublished-frame relationship
to its output. That prevents this early swap without another node field, but
it is not a complete retained solution: the broader latest simplification
still fails derived-store recovery and a pending/latest combination. It also
needs more lifecycle coverage for already displayed fallbacks. The trial
sources are archived, not shipped.

The #3698 `show:undefined` regression was previously described too strongly:
that is the intended final hidden branch; the failing assertion selects the
last callback across siblings. The user has explicitly left sibling ordering
unspecified. This trial did not migrate that assertion or use it to waive a
publication failure.

## Selecting a context before writes

A first observation can select a higher context before it has a held-node
marker. A trial considers that active boundary when its consumer reads it,
including when there is no ambient transaction yet. Allowing the first ready
proposal then repairs both #4429 cases, but the existing store seed guards
still reject it. Forcing store producers to rederive reduces six seed failures
to three; all three remaining cases have an async producer and a sibling
holding the first input answer. The independent manual-write guards pass,
but that is insufficient: no seed may be published.

The trace shows why this does not solve the whole problem. The async input's
first answer initially propagates unheld. A producer can write its draft in
that ordinary pass before the sibling's hold is known. Later context selection
must either preserve the complete proposal or rederive it with correctly owned
writes. Selecting the context at the read is useful only when that context is
already known. No family-wide transfer or provenance bookkeeping was added.

All runtime sources were restored exactly. Restored controls: eight retry
cases, 24 seed cases and two independent manual-write cases pass; #4429 retains
its two known failures and two passing controls. No performance claim or new
full-suite run. Raw trial sources and reports are in the stage-153 archive.
