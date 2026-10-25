# Semantic properties and current proof direction

These are properties of the shared executable Bend runtime. They are distinct
from reviewed TS correspondence, differential evidence and admitted environment
contracts. [LAWS.bend](../LAWS.bend) and [PROOF.bend](../PROOF.bend) are the active
roots; an archived or generated candidate is not proved merely because it exists.
The runtime and checker were not changed for the current invariant work.

## Current proof coverage

| Family | Quantification and guarantee | Assumptions / limits |
| --- | --- | --- |
| Publication, storage, frames and callback boundaries | Arbitrary surrounding Worlds, valid constructed slots, values/lists as stated; exact field changes and preservation | Named helper/continuation boundaries; not a global reachable-state invariant |
| Committed staging/default setter frame | All represented values, finite node/link storage, Worlds and internal mark fuel: actual staging/heap/notification/held-default setter preserves all stored committed values, tree and event trace; active ordinary core branch/stack bridge; arbitrary finite helper-write histories | A pure observation, not public reads; default core branch excludes overrides/custom callbacks; exhaustion/malformed states retain faults; no full flush, pending-ledger preservation or eventual publication theorem |
| Fulfillment-prefix frame and continuation | Actual pending/status/fulfillment prefix preserves committed values/tree/trace; stale result exact World no-op; active default core arrival retains stack and exact queued trim/settlement/schedule/flush/then/caller order | Default/no-override core; queued tasks are not executed; full protocol/authority, cleanup/callbacks, complete flush and coordinated reveal remain open |
| Scalar memo histories and batches | All natural initial/proposed values, arbitrary finite nonempty update histories and nonempty batches; actual constructor/setter/flush, carried World, exact result and coalescing | Fixed scalar graph/comparator and sufficient per-operation budgets; [memo-history-proof.md](memo-history-proof.md) |
| Two-memo/render programme | Constructor, setter and drain for arbitrary natural proposal, exact World and renderer result | Fixed graph and admitted callbacks; [chain-proof.md](chain-proof.md) |
| Deferred data and stream refetch | Complete fixed constructor/write/read/flush or stream lifecycle, ordinary payload families and sufficient fuel | Explicit event bridges; not all settlement orders; [deferred-payload-proof.md](deferred-payload-proof.md), [deferred-stream-refetch.md](deferred-stream-refetch.md) |
| `from` lifecycles | Complete fixed direct/wrapped lifecycles over every represented `R.Value`, exact payload/cleanup/cancellation; bridges retain ordinary families | Arena-token validity and arbitrary JS protocols are separate; [from-values.md](from-values.md) |
| Promise and wrapped cancellation | Six arbitrary-World/list preservation roots, masking only Promise objects, host jobs and stream plans | Frame safety, not async progress; [from-promise-frame.md](from-promise-frame.md) |
| Redirect resolution and rejoin histories | Arbitrary certified finite path and sufficient budget; fresh-root construction; same-component lookup/rejoin histories of arbitrary finite length, exact World and queried representatives | Actual field certificates and explicit public-budget room; no general arena validity/forest-size theorem yet |
| Action construction and distinct joins | Actual allocation/opening, nonzero captured group, one obligation, exact World; distinct selected allocated roots at arbitrary positions, ordered work/count transfer and derived pair traversal room | Successful factory-return prefix; ordinary roots/represented vectors; global forest/live-list validity remains open |
| Constructed two-action histories | Actual two action allocation/opening prefixes and either join direction; two obligations, arbitrary finite pair queries/rejoins, both completion orders with arbitrary finite pair queries/rejoins before/between/after; constructed full-World certificate and zero-debt corollary | Each action completes once by admission, terminating body slice; no arbitrary writes/settlements or renderer publication theorem |
| Constructed action blocker | Actual positive-count judgment returns true with exact World/judge preservation; two constructed actions before/after either first completion, with arbitrary finite pair lookups/rejoins | Healthy initial World; current constructor/callback domain; no zero-debt eligibility or rendered publication theorem |
| Completed empty-group eligibility | Actual false blocker and exact World/judge preservation; constructed two-action completion certificate supplies zero count, empty nodes and ordinary identity in both orders | Healthy initial World and no live lanes; no executed generator writes, owned flights, rendered publication or fairness theorem |
| Held landing scan | Actual scan retains complete World/stack/frame for a selected nonzero positive-debt group; constructed after-first-completion certificate | General helper scan needs a lookup; constructed two-action/first-completion derives it; no complete flush/rendered-publication theorem |
| Nonempty rendered graph blocker | Pending owned on-screen render snapshot with terminal membership and arbitrary inactive prefix: actual blocker true at zero debt, exact World/judge and existing budget; retained by actual landing scan; live subscriber and generation contracts | Snapshot facts explicit; real callback-body construction and preservation across writes/completions/settlements remain open; no complete publication/fairness theorem |
| Rendered completion-prefix histories | Arbitrary finite branching completion-prefix/check programmes over an explicit pending rendered snapshot: actual audit equality, every real blocker answer true, preserved graph/trace/live list and final snapshot/health; initial occurrence supplies actual final held scan | Each prefix supplies current captured-ID resolution and positive count; initial graph construction, generator/result protocol, once-only completion, flight delivery, intervening writes/disposal and eventual publication remain open |
| Rendered owned-list entry | Actual fresh list call at valid allocated extension/group slots establishes captured membership and owned-prefix append, constructs the pending snapshot and enters the quantified history; exact same-capture no-op | Initial pending/render/posture facts, extension/group slots and earlier inactive prefix explicit; callback/status/parking programme and final flight publication remain open |
| Lanes, latest/pending and optimistic values | Quantified source-helper, question, answer, read, group and frame properties; representative exact programmes | Not general held-guess correction or arbitrary async consistency |
| Committed staging and fulfillment prefix | All represented values and finite storage: actual staging/default-setter helper histories retain committed values/tree/trace; active ordinary core setter returns argument; fulfillment prefix retains caller stack and exact queued continuation | Faults retained without success claims; custom comparator/override and execution of queued trim/release/flush remain open |
| Closed regressions | 73 integrated concrete reactive/error/cleanup/async executions | Integration evidence, not a theorem over arbitrary histories |

The [earlier detailed catalogue](reviews/general-properties-through-65e7402.md)
retains local statements and chronological proof developments. Its statements
about then-unfinished chain/public/window work are historical. Dedicated area
proof documents and the active roots give the current domains. Exact step counts
are internal sufficient bounds, not a measure of semantic generality.

## Selected lifecycle and intended observation property

The next substantial target is a small fixed signal/derivation/render graph with
two ordinary held actions. Its event structure will permit joins in either
direction, repeated observations/joins and completion in either order. Successful
terminating callback slices come first; rejection, supersession and disposal enter
after their authority/cleanup contracts. Payloads should be opaque represented
values where the operation does not need arithmetic. An arbitrary topology or
arbitrary JavaScript callback theorem is not required for this slice.

At a stable publication boundary, fix a designated ordinary renderer whose
admitted dependencies belong to scheduling group `g`. Let `C(h,g)` be that
renderer group's last actually published frame after history prefix `h`, not
merely the newest stored/staged values. The intended safety assertion is:
while the relevant action/observed-flight obligations still block `g`, its
ordinary rendered observation equals `C(h,g)`. When a new frame publishes, its
answers must justify the jointly published derivations. Independent groups may
publish independently. No out-of-band imperative tree writes are admitted.
This is a target definition, not a theorem already established by the open-count
or redirect laws. Zero open actions alone does not imply eligibility.

Use a reader/posture-indexed observation relation. An API read can pull, mark or
join work, so its observation is an actual transition `(World, outcome, trace)`;
a pure snapshot of slots is only a proof projection unless a checked bridge
connects it to that read. Rendered content is observed through the actual tree /
application effects, not inferred solely from a node's stored value.

| Posture | Observation to connect to runtime | Source-grounded allowance |
| --- | --- | --- |
| Ordinary rendered content | Designated render application/tree at publication boundaries | Retain the committed frame while the relevant hold blocks it |
| `latest` and pending verdict readers | Actual source read/window result and resulting World | May expose/derive from pending truth; not required to equal the ordinary screen |
| Optimistic display lane | Shown value, lane/group and question/result provenance | May display ahead, coordinating that lane's rendered async dependencies |
| `createDeferred` consumer | Current served answer and its derivation provenance | Declared lag may retain a previous answer beside newer inputs |
| Error/pending posture | Actual value, NotReady identity, thrown error or halt/report outcome | Follow the source's context-specific error policy; no blanket catch/discard rule |

The source anchors are scheduler `merge`/`blocked`/publication, action `done` and
`inTransaction`, core read/staging, lanes truth/display/answers, and the pinned
[SPEC-ASYNC-SEMANTICS](../upstream/solid/packages/signals/docs/SPEC-ASYNC-SEMANTICS.md),
[RULES-FUNDAMENTALS](../upstream/solid/packages/signals/docs/RULES-FUNDAMENTALS.md)
and [create-deferred](../upstream/solid/packages/signals/docs/create-deferred.md).
The fundamentals document declares draft status. Where rules, examples and
implementation disagree, record the intended property and faithful counterexample
separately rather than promote a draft rule into a proved invariant.

## Reusable redirect and completion contracts

`proof/transaction-resolution.bend` defines proof-side `Route<World>` certificates:
a terminal names an actual zero `into` field; a redirect names an actual positive
`into` field and a connected smaller route. `origin`, `terminal` and `depth`
extract endpoints and number of redirects. Certificates do not contain assumed
resolver transition equations or execute a replacement resolver.

The kernel proves actual `resolveLoop(depth + 1 + extra, w, origin)` returns
`(w, terminal)` for any finite route and any extra fuel. The entire World is
unchanged, including original fault, queues and ambient state. `newTransaction`
really appends a zero-redirect record; an arena lens proves its returned identity
selects that record and establishes a terminal route. The public `resolveTx`
corollary requires `1 + arena length = depth + 1 + extra`. The next structural
proof must derive this room from a valid finite acyclic arena.

The [constructed join extension](transaction-joins.md) supplies allocated selected
roots, real action capture/debt and structural resolver room for that pair, then
composes arbitrary finite pair lookups/rejoins and either first completion. It
does not close the following general-forest restrictions.

A route alone does **not** establish allocated identities: an out-of-range lookup
uses the representation's blank fallback. It also does not prove every transaction
has a route, global redirect acyclicity, liveness or membership in the live list.
These are explicit reachable-state obligations, not consequences inferred from
successful resolution. Cyclic fixture controls fault with Exhausted; no successful
execution is claimed for them.

`transaction-rejoin-history.bend` admits `Lookup(alias)` and
`Rejoin(source,target)`, where each alias carries a route/room certificate to the
same representative in the starting World. The runner passes the real result
World between calls to `resolveTx` and `merge`. List induction proves the complete
World unchanged and every recorded lookup equal to the representative, for any
finite mixture/order of events. This proves repeated same-component joins cannot
create a redirect cycle or duplicate accounting/queues within that admitted
component. It does not yet merge distinct components, resolve a Promise, finish
an action or establish visibility of a rendered graph.

`action-resolution.bend` composes the actual captured `ActionState.transaction`,
certified public resolution and `Action.done`. If the representative open count
is `1 + remaining`, the result is exactly source scheduling after updating only
that representative's count to `remaining`. It does not decrement the stale
original transaction. This is a local whole-World equation including schedule,
not an assertion that scheduling publishes or that arbitrary completion is safe.

## Reachability boundaries for the next slice

Construction must establish valid nonzero IDs, root ownership, actions' captured
transaction identities and initial obligations. Distinct-component merge must
preserve redirect termination, live representative membership, summed outstanding
obligations and ordered queue/mark transfer. Completion must preserve this ledger
through old identities. Keep scheduling-group, result/flight identity and question
provenance distinct: joining scheduling groups does not make every old answer
applicable, nor erase a newer guess's authority.

Use contracts at source segment boundaries. While a callback, teardown or drain
is suspended, a continuation-sensitive invariant must describe saved operands,
remaining tasks, ambient owner/tracking/question/judge state and who restores it.
A temporary source mutation need not satisfy a stable-boundary predicate at every
Core task. Preserve and analyze exceptional partial state rather than assuming
all callbacks return normally.

For later optimistic work, prove observation protection of a newer applicable
guess from an older answer; older truth may legitimately stage underneath it.
Equal confirmation should be visibly silent; differing correction/revert must
coordinate with the relevant hold. Supersession/disposal must account separately
for result authority, question provenance and remaining scheduling obligations.

## Callback, environment and resource assumptions

- Identities and reference arenas must be valid; the admitted callback/programme
  grammar supplies reads/writes/reentrancy/throws through the real core. It does
  not represent arbitrary JavaScript getters, generators or reflection.
- Native Promises settle once, and the admitted callback observer protocol must
  establish at-most-once action completion. The positive-open premise is not a
  proof of that protocol. Arbitrary duplicated calls to low-level `done` are not
  admitted as public action behavior.
- Safety is a property of finite permitted prefixes and needs no fairness claim.
  Internal completion needs structural bounds plus terminating admitted slices.
  Eventual reveal additionally needs relevant external work eventually to settle,
  its actual queued callbacks to be delivered, and sufficient internal drain work.
- Exhaustion is operational behavior, not success. The Core exhaustion path faults
  and drops remaining task work; the resolver returns an Exhausted World. Do not
  claim the invariant's successful-execution conclusion for those results or hide
  a legacy helper's partial-result restriction. Do not raise checker limits or
  replace source algorithms to obtain a theorem.

## Evidence and discovery discipline

Keep generated exact executions as integration proofs, and use branching event
exploration to challenge each proposed invariant. Target opposite settlement
orders, repeated/reversed joins, independent components, disposal during holds,
exceptional exits and overlapping guesses. Classify a failure before making an
upstream claim. Direct machine values/stacks complement facade checks, especially
where the numeric setter facade returns the original JS argument.

Current evidence and new targeted negatives are recorded in
[verification.md](verification.md) and the [invariant validation receipt](reviews/transaction-invariants-validation.json). No fresh
upstream bug or semantic deviation is asserted by these proofs. The longer
late-push `from` candidate remains explicitly unverified after a kernel resource
failure; its finite tests do not fill the missing proof.

The [both-completion extension](action-completion.md) supplies a checked constructed
full-World certificate and a zero-live-action-debt corollary. Actual wait marking,
lookup and duplicate guards also preserve a settled yielded-value wait through
arbitrary finite append/settlement histories. That local invariant does not yet
prove the complete once-only action/result/flight protocol.


[Constructed live selection](live-selection.md) derives real list occurrence
and scan position from actual allocation/opening/join and either first completion,
with arbitrary finite pair lookup/rejoin prefixes. The result carries both lookup
and exact held scan certificates. It does not promote arbitrary helper storage
frames to global validity or full reactive reachability.


The [2a0da2fc source refresh](reviews/solid-2a0da2fc.md) retains every earlier
proof domain and sufficient budget under merged catch/no-value handling. Two
quantified passive-catch close/unwind contracts connect the enlarged source
scope to the existing original-error/caller-stack handler. They are local scope
contracts, not arbitrary error-history or queued-publication proofs.

## Pending continuation and prefix induction

Ten roots in `pending-continuation.bend` and `pending-stack-history.bend` cover
actual core pending/after-trim/schedule stack contracts, exact release capture and
self-settlement, empty-queue return, actual-step agreement and arbitrary finite
permitted prefix induction. A nonempty two-step prefix is constructed. No health
premise, desired stack equation or runtime budget is supplied to the induction.
World content, traversal success, owner callbacks and publication are separate;
see [domains and exclusions](pending-continuations.md). The general settlement
committed-storage attempt is archived and unverified, not an active root.

## Owner continuation and no-stale trim completion

Four roots add stack-neutral actual owner-step safety, a constructed no-stale trim
prefix, its two-step height and exact whole-machine return after those steps.
The existing prefix induction now admits structural owner work, including queuing
a callback without executing its body. The generic stack result needs no health
premise; exact no-stale completion requires input health and the selected suffix
edge to be zero. Full storage, callback and publication properties are separate.
See [the owner domains](owner-continuations.md).

## Selected text/application observation

Eight roots add positive selected text/event laws, foreign target/event frames,
arbitrary node-storage frame, projection of the stronger committed frame, actual
independent ApplyEffect-step safety and the actual ordinary async-arrival bridge.
Payloads are arbitrary `R.Value`; targets/renderers are explicit IDs. Mount
visibility and queued callback execution remain separate. Supporting list lookup
proofs preserve actual sparse/existing-slot behavior. See the
[observation scope](rendered-observation.md).


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
