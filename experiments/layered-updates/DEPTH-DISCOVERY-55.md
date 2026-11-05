# Stage 55: dependency discovery must not retroactively confer eligibility

The user is willing to accept depth priority's broader ordering, subject to this
constraint: discovering dependencies must not reveal that an optimistic proposal
could have published earlier all along. A new source update or another update
completing and causing reversion may legitimately change eligibility.

Operational interpretation under test: an internal async answer that merely lets
an already-pending derivation reach more reads cannot by itself increase an
existing override's priority and remove an unrelated, still-pending blocker.
This is distinct from an action ending, an override expiring, or a fresh source
write. No ordinary/optimistic observable consistency rule was relaxed.

## Falsification of the current reference

`reference/depth-discovery-audit.mjs` uses active first/deep optimistic layers,
an independently held peer override, an async enabled flag, and an input that
cannot reach its deep dependency until that flag resolves. A view overrides
that input. A memo and separate render readers display the view and peer.
The input's action stays open. The deep calculation and peer calculation stay
pending. Resolving the flag does not publish the input update or end any action.

With the explicit-clear boundary:

- Before flag resolution: view depth 1, peer depth 1; shown pair `[0,0]`.
- Resolving the flag lets input discover the depth-2 dependency.
- `inputPosition` includes newly learned pending origins, raising view to depth 3.
- View publishes 10 and the pair `[10,0]`, although the peer remains pending.

That violates the new eligibility constraint. Both traversal orders reproduce
it. This is a reference-model reproduction, not a claimed current-next defect.
The action-lifetime version stays held in this fixture because its input-lifetime
coupling changes the groups. That extra hold is not evidence that the underlying
depth computation satisfies the rule generally.

All reads are tracked synchronously. The first pending read prevents the deeper
read from being reached until a later synchronous run. There are no tracked
reads after await and no new external writes between the two checkpoints.

## Rejected shortcut

`reference/committed-depth-audit.mjs` tries deriving the boundary depth only from
its committed input dependency frame, omitting pending-origin depth. It prevents
the premature promotion, but the explicit-clear version then remains held even
after the actual peer blocker completes. Higher input obligations still compete
with its lower output context. This is not accepted as a fix merely because the
negative assertion passes. Both variants eventually drain after all holds end.

The audits assert coherence of every recorded pair publication and zero remaining
update records after completion and disposal. Four variants per implementation
cover action lifetime/explicit clear and both traversal orders. They are small
falsification experiments, not a proof or a production acceptance suite.

## Next design gate

Priority must not be improved just by extending a suspended calculation's
speculative dependency set. Candidate alternatives include stable proposal
context assignment and explicit context transitions associated with genuine
updates/publications. A proposal snapshot is not automatically sufficient:
parent activation/expiration, an input discovering a deeper context, and an
initially unpublished input must still compose without losing ownership or
blocking forever. Do not silently change those semantics to satisfy this case.

No main scheduler, production source, old assertion, performance threshold, or
bundle threshold changed. No new performance or size result is claimed.
Artifacts are under `results/depth-discovery-stage55/`.
