# Active frontier

The objective is increasingly general properties of Solid reactivity and useful
upstream counterexamples. The source-followable Bend translation is their
foundation. Formal TS/Bend equivalence is outside scope. This page describes the
current state; [progress.md](progress.md) holds chronological checkpoints. The
[previous accumulated frontier](reviews/frontier-through-65e7402.md) is historical
and includes superseded omissions and counts.

## Current coverage

Solid is pinned to `225014bf` (rc.18); Bend 2.0.37 and its independent kernel are
unchanged. No semantic deviation is active. This is an incremental production,
non-store port with an explicit callback/host grammar, not the whole package.

| Area | Implementation and correspondence evidence | Semantic proof coverage | Remaining scope |
| --- | --- | --- | --- |
| Graph, owners, reads/writes, queues and errors | One shared runtime; public histories plus operation-level native controls | General publication/frame/representation laws; closed error/cleanup regressions | Arbitrary topology, callback bodies and error/disposal histories |
| Scalar memo | Actual constructor, setter and flush | Arbitrary finite write/flush histories and nonempty batches for natural payloads; exact carried World | Branching async events and variable graph shape |
| Held actions and transactions | Real reusable action protocol, redirects, joins, parking/landing; native generator and private helper controls | Real action allocation/opening contracts; distinct allocated-root World/queue/count transfer; constructed two-action join and first completion after arbitrary finite lookup/rejoin histories | Second/once-only completion, global forest/live-list preservation, full action/flight ledger and publication invariant |
| Lanes, latest/pending, optimistic values | Admitted non-store public crossings and shared internal engine | Local question, lane, frame, answer and read properties; representative exact executions | Held optimistic correction/confirmation across arbitrary branching histories; boundaries and stores |
| Deferred and `from` | Data/thenables, typed streams, direct subscriptions and wrapped async iterables with cancellation | Fixed complete deferred/from lifecycles; arbitrary represented from payloads; Promise/cancellation preservation | Observable/interop and object unsubscribe; mutable protocol objects; general async histories |
| Lists and children | Typed arrays, repeat, positional/keyed/extracted-key mapping, flattening | General array lenses and fixed lifecycle/payload programmes | Full JS values/protocols and arbitrary callback/topology histories |

4,486 public differential histories and 73 closed regressions remain supporting
evidence. Configured mutation totals and completed frozen sweeps are distinct in
[verification.md](verification.md). These counts are not a completion percentage.
The [fidelity ledger](source-fidelity.md) and [proof catalogue](general-properties.md)
state the restrictions behind this table.

## Selected substantial milestone: joined held actions

For a small fixed signal/derivation/render graph, admit two ordinary actions,
joining in either direction, repeated reads/joins, and completion in either order.
Start with successful terminating callback slices and finite external settlements;
add rejection, supersession and disposal after the corresponding invariants exist.
The target is a theorem over arbitrary finite **permitted branching histories**,
not a fixed list of settlements with different payloads.

At publication boundaries, ordinary rendered content must retain a committed
frame while the relevant group still has an outstanding action/observed-flight
obligation. Releasing an original action identity must charge its current live
representative. Independent work may publish independently where Solid permits.
This target is not proved yet. An open count of zero alone is insufficient: live
rendered flights, lanes and their blocker rules also matter.

## First dependency checkpoint

`transaction-resolution.bend` proves that an actual finite redirect path supplies
a sufficient loop bound, returns its terminal identity and preserves the complete
World. Fresh transaction allocation establishes a terminal certificate. The public
resolver theorem explicitly requires its arena-derived budget to cover the path;
a general forest-size bound is still open. Two aliases with one representative
merge without changing the World.

`transaction-rejoin-history.bend` composes actual lookups and same-component
rejoins over arbitrary finite branching histories, returning every queried
representative and preserving the entire World. Certificates constrain actual
`into` fields and fuel, not assumed transition equations. This is safety within
an established component; it does not create/merge distinct components or settle
work. `action-resolution.bend` connects a certified captured identity to the real
completion prefix, decrementing a positive representative count and scheduling.
These are dependencies of the selected milestone, not its completion.

The [next dependency checkpoint](transaction-joins.md) now establishes real
allocation/opening captures and debt, distinct-root ordered transfer at arbitrary
allocated positions, and public resolver room for the joined pair. Two actual
action prefixes followed by a join have exactly two obligations. Either action's
first completion after any finite sequence of pair lookups/rejoins removes one
obligation from the live representative; no capture/count/room premise is supplied.
This does not yet cover the second completion or rendered publication.

## Next proof obligations, in order

1. Extend the constructed two-action prefix/first-completion invariant through
   the second completion and intervening permitted work. Preserve live membership
   and routes across general distinct-component joins; derive the global resolver
   bound from an acyclic finite arena. Pair allocation/transfer/room are now checked.
2. Relate outstanding action/flight identities to the representative open count.
   Prove once-only completion and distinguish scheduling joins from result/question
   authority. The original transaction record's retained count is not live debt.
3. Connect that invariant to actual blocker, flush and publication boundaries;
   prove the ordinary renderer observation while carrying the real World through
   branching event histories. Keep stack, continuation and ambient scopes explicit.
4. Add supersession/rejection/disposal, then overlapping held optimistic guesses,
   provenance-aware protection, equal confirmation and coordinated correction.

The observation model, admitted environment and resource policy are recorded in
[general-properties.md](general-properties.md). Implement only what these steps
need or what closes a material fidelity gap. Keep exact integration witnesses,
including old domains, without prioritizing another larger state dump.

## Obstacles and bug status

The 170-step late-push `from` candidate hits the pinned kernel's reduction limit;
its passing finite controls are not a proof. It remains an explicitly unverified
[archive](../experiments/from-async/README.md), excluded from active roots. The new
small contracts/history proofs avoid that particular expansion without changing
the runtime or checker limits.

`SOLID-DEFERRED-PROTOCOL-ERROR-010` remains reproduced and preserved at the pin;
see [PR #4248](https://github.com/solidjs/solid/pull/4248) and
[the report evidence](upstream/deferred-protocol-error.md). No new upstream
bug or workaround was introduced by the invariant work. Draft source-rule questions
and intended observations must remain distinct from checked source behavior.
