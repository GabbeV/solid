# Active frontier

The objective is increasingly general properties of Solid reactivity and useful
upstream counterexamples. The source-followable Bend translation is their
foundation. Formal TS/Bend equivalence is outside scope. This page describes the
current state; [progress.md](progress.md) holds chronological checkpoints. The
[previous accumulated frontier](reviews/frontier-through-65e7402.md) is historical
and includes superseded omissions and counts.

## Current coverage

Solid is pinned to `2a0da2fc` (rc.18); Bend 2.0.37 and its independent kernel are
unchanged. No semantic deviation is active. This is an incremental production,
non-store port with an explicit callback/host grammar, not the whole package.

| Area | Implementation and correspondence evidence | Semantic proof coverage | Remaining scope |
| --- | --- | --- | --- |
| Graph, owners, reads/writes, queues and errors | One shared runtime; public histories plus operation-level native controls | General publication/frame/representation laws; committed storage/tree/trace frame through actual staging/default setter and finite helper-write histories; closed error/cleanup regressions | Arbitrary topology, callback bodies and error/disposal histories |
| Scalar memo | Actual constructor, setter and flush | Arbitrary finite write/flush histories and nonempty batches for natural payloads; exact carried World | Branching async events and variable graph shape |
| Held actions and transactions | Real reusable action protocol, redirects, joins, parking/landing; native generator and private helper controls | Real action allocation/opening contracts; distinct allocated-root World/queue/count transfer; constructed two-action join and both completion orders with arbitrary finite lookup/rejoin histories before/between/after; positive blocker before/after the first; settled-yield wait-list preservation; completed empty-group eligibility without live lanes; positive-debt landing-scan retention with a constructed live occurrence/position; nonempty rendered snapshot blockage/scan retention and completion-prefix/check history preservation with retained live list and derived final scan | Full once-only protocol, global forest/live-list preservation, full action/flight ledger and publication invariant |
| Lanes, latest/pending, optimistic values | Admitted non-store public crossings and shared internal engine | Local question, lane, frame, answer and read properties; representative exact executions | Held optimistic correction/confirmation across arbitrary branching histories; boundaries and stores |
| Deferred and `from` | Data/thenables, typed streams, direct subscriptions and wrapped async iterables with cancellation | Fixed complete deferred/from lifecycles; arbitrary represented from payloads; Promise/cancellation preservation | Observable/interop and object unsubscribe; mutable protocol objects; general async histories |
| Lists and children | Typed arrays, repeat, positional/keyed/extracted-key mapping, flattening | General array lenses and fixed lifecycle/payload programmes | Full JS values/protocols and arbitrary callback/topology histories |

4,750 public differential histories and 73 closed regressions remain supporting
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
The [blocker bridge](action-blocker.md) now proves the actual healthy-world
judgment true, with exact World/judge preservation, before and after either first
completion, including those arbitrary finite lookup/rejoin histories. This does
not yet cover rendered publication. The [completion extension](action-completion.md)
now checks both completion orders with arbitrary finite pair lookups/rejoins
before, between and afterward. A constructed certificate contains the full World
equality, and its checked corollary gives zero live representative action debt.
A separate invariant connects actual wait marking, lookup and duplicate guards
through arbitrary finite append/settlement histories. The
[eligibility extension](action-eligibility.md) supplies actual `blocked == false`
after both completions for this empty-owned-node prefix, with explicit initial
health/no-live-lane conditions and complete post-completion World preservation.
The [landing scan contract](action-landing-scan.md) now retains the actual World
after either first completion; the constructed pair now derives its live-list
lookup and scan position rather than requiring that premise. The
[nonempty rendered snapshot contracts](rendered-blockers.md) now establish actual
blockage and scan retention from pending/render/membership/posture facts at zero
action debt. Their construction and preservation through writes and settlements is
still open; they do not assume the final blocker or membership judgment. The
[completion-history extension](rendered-completion-history.md) now carries that
nonempty snapshot through actual positive-count completion prefixes and repeated
blocker checks of arbitrary finite length. The graph/trace remains fixed and all
actual check answers are true; initial callback-body construction, flight delivery
and full once-only result protocol remain open. The
[list-construction entry](rendered-list-construction.md) now supplies initial
membership/owned layout through the actual list operation on allocated slots,
and composes directly with the history. Earlier pending-status/posture and
callback/parking construction remain explicit. The complementary
[committed-staging frame](committed-staging.md) now covers actual staging,
notifications, held/default setters and arbitrary finite helper-write histories
for all represented payloads/storage shapes, with an active ordinary core setter
and stack-return bridge. The full pending/membership invariant through writes,
the complete delivery and queued flush/publication remain open. The
[actual fulfillment prefix](async-write-prefix.md) now preserves committed
content and caller stack, rejects stale results by exact identity and returns the
source trim/settlement/schedule/flush/continuation order. Execution of that queued
tail and coordinated final reveal remain open.

## Next proof obligations, in order

1. Extend the constructed two-action/both-completion invariant through
   intervening permitted writes, flight settlements and disposal. Preserve live membership
   and routes across general distinct-component joins; derive the global resolver
   bound from an acyclic finite arena. Pair allocation/transfer/room are now checked.
2. Relate outstanding action/flight identities to the representative open count.
   Complete once-only action delivery beyond the checked settled-yield wait-list invariant, and distinguish scheduling joins from result/question
   authority. The original transaction record's retained count is not live debt.
3. Extend the checked positive-count and empty-group eligibility bridges through
   nonempty owned-node/flight/lane judgments and actual flush/publication boundaries;
   prove the ordinary renderer observation while carrying the real World through
   branching event histories. Keep stack, continuation and ambient scopes explicit.
4. Add supersession/rejection/disposal, then overlapping held optimistic guesses,
   provenance-aware protection, equal confirmation and coordinated correction.

The observation model, admitted environment and resource policy are recorded in
[general-properties.md](general-properties.md). Implement only what these steps
need or what closes a material fidelity gap. Keep exact integration witnesses,
including old domains, without prioritizing another larger state dump.

The next practical extension is the same joined two-action family with real
signal writes and one owned rendered flight: preserve the live representative
and committed observation as action completions and the flight settlement are
interleaved. The current empty-prefix, nonempty snapshot and scan contracts are dependencies, not
that publication result.

## Obstacles and bug status

The 170-step late-push `from` candidate still hits the pinned kernel's reduction limit;
its passing finite controls are not a proof. It remains an explicitly unverified
[archive](../experiments/from-async/README.md), excluded from active roots. The new
small contracts/history proofs avoid that particular expansion without changing
the runtime or checker limits.

`SOLID-DEFERRED-PROTOCOL-ERROR-010` is fixed upstream and integrated from
[#4248](https://github.com/solidjs/solid/pull/4248). Its historical failure receipts
remain linked in [the report](upstream/deferred-protocol-error.md). The
[current source review](reviews/solid-2a0da2fc.md) also integrates #4250's no-value
status on first-error re-asks. No active semantic workaround or new upstream bug.

Latest next checked: `2a0da2fc`. All 77 recorded Solid inputs match the pin.
The new catch-scope roots retain earlier proof domains and 103/118-step bounds.
These production fixes precede the next queued-settlement/flush composition.



The [constructed live-selection proof](live-selection.md) now derives the
representative occurrence and scan position from actual two-action opening/join,
any finite pair lookup/rejoin history and either first completion. Its returned
certificate contains the exact held scan equation. This removes the supplied
lookup premise for that family; global membership/forest validity, intervening
writes/disposal and the queued publication tail remain open. Certified rendered
completion/check histories also preserve the whole live list, carry an initial
occurrence forward and derive the final held scan on the actual audit World; no
final count/lookup/blocker premise is supplied.

The next concrete composition is execution of the fulfillment tail, beginning
with `OwnerTasks/TrimDeps`, `AsyncWriteAfterTrim` and pending settlement traversal,
then the actual scheduled flush. Carry callback/error policy and live root
resolution explicitly: settlement may join held nodes, so unchanged live lists
cannot be assumed across that traversal. The held-count versus still-pending
flight cases must be related before claiming the final coordinated reveal.

## Executed pending continuations

The [pending continuation extension](pending-continuations.md) now checks actual
settlement/schedule task steps and arbitrary finite permitted prefixes for caller
stack preservation, including fault unwinding. Captured release locals/cursor and
self-settlement order are exact contracts; a nonempty prefix is constructed.
The runtime is unchanged. The existing 120 forked non-trim fixtures now execute
880 actual steps through their queued flush boundary. General committed storage through callback-free settlement is now checked in
the later active frame/history extension;
owner callbacks, successful completion and coordinated final publication stay open.

## Owner continuation and local completion

The [owner extension](owner-continuations.md) expands the actual-step prefix
induction to stack-neutral owner work. A healthy no-stale dependency trim now has
a constructed two-step prefix and exact whole-machine completion. All 160 forked
arrivals run to their queued flush in the existing finite controls. This closes a
local internal-completion obligation, not general graph progress or final reveal.
The frozen608 sweep is qualified by the later ABI finding; the corrected619
sweep is now verified on4975adf2. Later focused variants remain separate.

## Selected renderer observation and ABI correction

The [selected observation laws](rendered-observation.md) now expose actual chosen
text writes/application events and preserve that observation through another
renderer/target's actual apply step and an ordinary async-arrival prefix.
Disjointness, mount assumptions and callback boundaries remain explicit. These
are operation safety/visibility contracts, not the full history/reveal theorem.
[HARNESS-LIST-ABI-001](list-abi.md) corrects malformed private-control list tags;
all public/alignment commands pass with canonical encoding. The old608 receipt
has a precise seven-finite-variant caveat; a fresh corrected619 sweep now passes.


## No-subscriber settlement return (2026-10-25)

The [settlement completion contract](empty-settlement-completion.md) adds nine roots: a constructed actual six-step
prefix returns arbitrary caller work/stack, preserves committed content and stays
Healthy from input health/empty-subscriber facts. The actual Core.run decomposition
retains the original remaining fuel and explicit exhaustion policy. These are
local internal-completion results; public input construction, nonempty traversal
and queued flush/publication remain open. Eighty direct-arrival controls, 240 driver
splits and 80 exhaustion controls pass. The corrected full619 negative sweep is
verified separately on frozen4975adf2; four later focused kernel variants pass.


## General pending content safety (2026-10-25)

The [active pending frame/history proof](pending-committed-history.md) closes the previous callback-free settlement
storage-frame obstacle without reducing its observation: all committed values,
the full tree and trace are retained through actual pending steps and arbitrary
finite certified body-only prefixes. Six roots extend 487 to 493. The source
status/tail blocks now have names; an inlining audit recovers the exact previous
statements and order. Public/alignment suites pass; no runtime task, semantic
policy, theorem domain, witness budget or kernel limit changed. Owner callbacks,
general successful termination and coordinated flush/reveal remain open.


## Pending topology and derived leaf control (2026-10-25)

The [topology/leaf extension](pending-topology.md) adds seven roots, retaining the earlier 493. Actual
pending helpers/core steps and arbitrary certified body prefixes retain node
kind/configuration/subscriber heads and all intrusive links. A non-autodisposed
leaf derives its exact control layout around the actual computed World, private
visited/released locals and scheduled bit. The 1,280 step and 80 leaf controls
pass; three new metadata corruptions are kernel-rejected. Runtime/source/task
budgets are unchanged. Successful general traversal and final reveal remain open.


## Constructed one-edge return (2026-10-25)

The [one-edge return family](one-edge-return.md) derives actual control and a ten-step upper room from
Healthy input/one-edge/non-autodisposed-leaf facts, carrying the exact World and
caller work/stack. A no-stale trim composes to twelve. Early returns and faults
are explicit alternatives; the complete segment retains committed content and
uses actual driver fuel. Eight roots extend 500 to 508. Eighty real ten-step and
40 trimmed returns, plus private nine-step/five-step alternatives, pass. Runtime,
source, domains and limits are unchanged. Public premise construction, full
accounting and coordinated flush/reveal remain open.


## Actual graph construction (2026-10-25)

The [graph construction family](graph-construction.md) derives the one-edge
settlement premises from actual `graph.link`/allocation on initially valid,
distinct nodes with empty lists, including either recomputing flag. It retains
node validity/health and committed contents, then constructs the exact bounded
caller return. Eight roots extend 508 to 516; 64 typed constructor controls,
192 actual-driver splits, 144 native graph alignment cases and three focused
kernel negatives pass. Runtime/source/limits are unchanged. Initial public node
allocation, arbitrary graph histories, full accounting and coordinated reveal
remain open.


## Actual node construction (2026-10-25)

The [default constructor family](node-construction.md) derives fresh valid IDs,
node records and the graph input metadata through actual signal/memo/render
allocation and parentless setup. Memo/render allocation then actual `graph.link`
constructs the bounded settlement return, without final-state premises. Nine
roots extend 516 to 525; 48 typed controls and 144 driver splits pass, with three
new focused kernel rejections. Callbacks/flight registration are not executed;
these finite cases cover the absent-carrier alternative. Initial healthy context,
reserved arenas and null-parent computed identity remain explicit. Runtime, host,
source and limits are unchanged. Callback/registration integration, full
accounting and coordinated reveal remain open.


## Actual source registration and retirement (2026-10-25)

The [pending registration family](pending-registration.md) preserves the graph,
committed frame, health and node count through every actual add branch. It
constructs fresh extension/Set membership from initial valid-node/reserved-arena
facts, derives add/delete and duplicate whole-World contracts, and carries a
constructed graph through registration to bounded settlement return. Thirteen
roots extend 525 to 538; 128 actual ten-step cases, 384 driver splits and 384
duplicate no-op checks pass. Five new kernel faults are rejected. Frozen633
completed with all 851 input hashes/trackership verified; current644 has eleven
later focused rejections. Full public callback/flight protocol, global identity/
ledger validity, broad constructor-to-carrier composition and coordinated reveal
remain open. Runtime/source/host/limits are unchanged.


## Permitted source-Set histories (2026-10-25)

The [source-history family](pending-source-histories.md) proves content/topology/
storage safety and a constructed post-history bounded return over arbitrary
finite valid-ID add/remove histories. An arbitrary list of selected-edge commands
gets every validity certificate from the constructed graph, including after
actual default memo/render allocation/setup/link. Nine roots extend 538 to 547.
The 131 finite histories include every binary order through length six and cycles
up to 64 operations, with 393 driver splits and captured tombstone checks. Three
new kernel faults are rejected. This is a helper subprotocol, with ten Core tasks
of room after the history; public controller reachability, general final readiness,
full accounting and coordinated reveal remain open. Runtime/source/host/limits
and prior domains are unchanged.


## General constructor-to-registration context (2026-10-25)

The [context bridge](registration-context.md) closes the fresh-carrier premise
gap for actual default parentless memo/render allocation/setup/link. It derives
valid IDs, zero leaf extension pointer and retained auxiliary arenas, then
constructs membership for the actual source registration result and the bounded
return/frame/helper-retirement corollaries. Six roots extend 547 to 553; 144
constructed registration cases and 432 driver splits pass, with three new kernel
fault rejections. Initial context/sentinels remain explicit; callback/controller
reachability, status/readiness, full accounting and coordinated reveal remain
open. Runtime/source/host/limits and previous domains are unchanged.
