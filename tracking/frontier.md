# Active frontier

The goal is a Solid2 signals translation close enough to the TypeScript source
to follow upstream commits, with increasingly general semantic proofs and useful
upstream counterexamples. Formal TypeScript/Bend equivalence is outside scope.
This page states current coverage and next dependencies. Chronological details
belong in [session notes](session-2026-10-28.md) and [progress.md](progress.md).
The [previous accumulated frontier](reviews/frontier-through-388cfefc.md) is an
exact historical snapshot; its earlier omissions and next steps may be superseded.

Solid is pinned to `ac28157a` (rc.19). Reviewed next child17d4d1b5 changes only
Markdown; runtime/package metadata are identical. The Bend2.0.37 frontend/vendor
and fully Lean-checked congruence checker profile/fuel remain unchanged. No
semantic deviation is active. This is an incremental production, non-store port
with an explicit callback/host grammar, not the whole package. See the
[fidelity ledger](source-fidelity.md), [proof catalogue](general-properties.md)
and [verification record](verification.md) for admitted domains and evidence.

## Current coverage

| Area | Implementation and correspondence evidence | Semantic proof coverage | Remaining scope |
| --- | --- | --- | --- |
| Graph, owners, reads/writes, queues and errors | One shared runtime; public histories plus operation-level native controls | General publication/frame/representation laws; committed storage/tree/trace and full ordinary control frames through actual staging/default setter, finite helper histories and finite real setter-body evaluation; closed error/cleanup regressions | Arbitrary topology, callback bodies and error/disposal histories |
| Scalar memo | Actual constructor, setter and flush | Arbitrary finite write/flush histories and nonempty batches for natural payloads; exact carried World | Branching async events and variable graph shape |
| Held actions and transactions | Real reusable action protocol, redirects, joins, parking/landing; native generator and private helper controls | Actual lookup/mark/resume/body/retirement/duplicate guards; constructed finite helper histories; raw joined-controller finite bodies with derived source/cache/capture/count/method facts; internal two-resume count2→1→0 and stack handoff; actual first body/output drain/slice to queued Round with count1 and unchanged blocker; earlier certified rendered-flight/landing-scan contracts remain separate | Full public held entry/parking/host transport, construction of arbitrary source-cache redirects, full once-only protocol, global forest/live-list preservation, full action/flight ledger and publication invariant |
| Lanes, latest/pending, optimistic values | Admitted non-store public crossings and shared internal engine | Local question, lane, frame, answer and read properties; representative exact executions | Held optimistic correction/confirmation across arbitrary branching histories; boundaries and stores |
| Deferred and `from` | Data/thenables, typed streams, direct subscriptions and wrapped async iterables with cancellation | Fixed complete deferred/from lifecycles; arbitrary represented from payloads; Promise/cancellation preservation | Observable/interop and object unsubscribe; mutable protocol objects; general async histories |
| Lists and children | Typed arrays, repeat, positional/keyed/extracted-key mapping, flattening | General array lenses and fixed lifecycle/payload programmes | Full JS values/protocols and arbitrary callback/topology histories |

4,759 public differential histories and 73 closed regressions remain supporting
evidence. Configured mutation totals and completed frozen sweeps are distinct in
[verification.md](verification.md). These counts are not a completion percentage.
The [fidelity ledger](source-fidelity.md) and [proof catalogue](general-properties.md)
state the restrictions behind this table.


## Selected milestone and what is now constructed

The selected larger target is a theorem over arbitrary finite permitted branching
histories of joined held actions on a small source/derivation/render graph. At
publication boundaries, rendered content must retain its committed frame while
relevant action/observed-flight obligations block the group. Original captures
must charge their current representative. Independent work may publish where
Solid permits. This larger target is still open; zero action debt is insufficient
when owned rendered flights, lanes or result adoption remain.

The completed dependencies now connect source construction to actual core work:

- [Constructed ordinary delivery](held-constructed-delivery.md) and
  [output continuations](action-output-continuations.md) derive lookup, marking,
  body/retirement, duplicate no-op and queued Round from raw graph/action/hold/
  wait construction and finite permitted helper histories. Full public factory/
  parking and mixed outer interception are still separate.
- [Source-cache aliases](held-source-cache-aliases.md) allow independently
  certified cache and action captures through actual preparation and arbitrary
  finite setter bodies. Empty bodies retain the real old cache; first writes
  resolve/store it before comparison. [Raw joined bodies](joined-controller-bodies.md)
  construct the pair's initial facts in either join direction.
- [Count/blocker evidence](held-count-evidence.md) derives one obligation and an
  unchanged actual blocker after either first finite body, plus the successor
  source profile. [Other-controller handoff](held-next-body.md) constructs the
  next cache route/profile and other capture/method/route, then proves an actual
  second internal resume/body has zero debt and restores its caller stack.
- [Joined body through queued Round](joined-body-round.md) preserves the actual
  first-body output Machine, drains its classified observer prefix, derives all
  slice scheduling guards and reaches Round before saved-question restoration.
  The actual resulting group still has one obligation and is an unchanged blocker.
  [Live-list construction and frames](held-live-list.md) also derive its live
  occurrence and a local scanner-step contract on that constructed snapshot.
  This does not establish that Round reaches the scanner task.

These quantify over finite admitted body lists and represented values, not a
fixed enumeration of payloads. The generic operation contracts retain explicit
initial well-formedness certificates; separate raw factories construct them.
Proof-only virtual cache views perform no runtime store. Only completed official
independent verdicts receive credit; resource/authoring failures receive none.
The latest complete composed verdict and exact tracked-input seal, rather than
root or test totals, determine the checked checkpoint.

## Remaining composition, in working order

1. Execute the queued Round/landing/restoration path using the constructed live
   group and blocker facts. Transport them through companion resynchronization,
   pending-write intake/parking and lane/seam phases before the actual scan; the
   local scan step on the queued snapshot does not establish that reachability.
   Connect that path to the other controller's next
   actual delivery; the current two-resume handoff does not yet prove the
   uninterrupted queued/public event history.
2. Close full public action factory/parking/host and mixed from/deferred ordinary
   interception reachability. Carry controller, source, ambient question, caller
   stack and queue obligations across those actual boundaries.
3. Establish and preserve the global group forest/live list, once-only result/
   settlement and action/observed-flight ledger over branching permitted event
   histories, including supersession, rejection and disposal. Derive later
   resolver room and eligibility from those invariants.
4. Compose existing rendered-flight, committed-frame and landing-scan contracts
   with that reachable invariant to prove publication safety, then state the
   extra callback termination, host delivery and fairness assumptions needed for
   internal completion and eventual reveal.

The current priority is those missing compositions, not more fixed execution
witnesses. Generalizing graph shape and callback/value/protocol grammar, stores,
boundary/server APIs and broad async lifecycle theorems remain further scope.
The source-followable runtime remains shared by proofs and differential tests;
implementation changes should enable a selected theorem or repair a documented
fidelity gap, with every necessary deviation explicitly tracked.

The archived170-step late-push programme remains independently unverified after
resource stops and receives no credit. It is not an assumption behind the
completed constructed contracts. Current negative totals and frozen complete
sweeps keep their separate identities in the verification ledger.
