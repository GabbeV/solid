# Source fidelity and upstream tracking

The source-followable translation is the execution foundation for semantic
properties and upstream bug discovery. It preserves Solid's operations, branch
and mutation order, identities, reentrant callback behavior, queues and
optimizations. Formal TS/Bend equivalence is outside the project objectives.
Reviewed correspondence, differential tests and scoped adapter contracts support
fidelity; neither a passing proof nor a test closes an unreviewed source branch.

Current pin: Solid `0847122e9fc9681fda7feef37d5427db7316e56d`, rc.18. The latest
[source review](reviews/solid-0847122e.md) records the verbatim inputs and checks.
Merged fixes through this pin are integrated where their admitted branches run;
#4231 synchronous-error retirement, #4232 stream wrapping and #4233 late
subscription unsubscribe are no longer blanket omissions. No candidate patch or
semantic workaround is active. See [deviations.json](deviations.json).

## Representation contract

Stable arena IDs encode JS identity; threaded World encodes mutation; tasks and
continuations encode calls, suspension, cleanup and unwinding. Shared mutable
Sets, groups, plans and captured closure cells retain distinct identities.
Absent slots differ from present undefined. Call argument vectors distinguish
no argument from explicit undefined; captured values differ from live reentrant
reads. These encodings do not authorize a replacement publication algorithm.

Function and module boundaries remain source-indexed where practical. Helpers
split at actual call/return segments identify their source. Proof-side predicates,
observations, certificates and algebraic forms may summarize state only when
checked lemmas connect them to the actual runtime; they are not a second runtime.

## Current correspondence and material limits

| Source area | Current admitted crossing | Correspondence records and remaining limits |
| --- | --- | --- |
| Core graph, heap, recompute, staging and publication | Shared graph/owner/core/scheduler, live return-point traversals and raw comparator calls | [owner-core.md](owner-core.md), [general-properties.md](general-properties.md), [comparators.md](comparators.md); arbitrary callbacks/graphs and global progress remain open |
| Ownership, cleanup and errors | Capture, detach/LIFO, reentrancy, original exception precedence, recompute/retirement/disposal and halt/report branches | [cleanup-policy.md](cleanup-policy.md), [errors.md](errors.md); active boundaries and arbitrary host error objects are outside scope |
| Actions and ordinary transactions | Reusable callables, actual argument capture, generator-method protocol, question/hold/join/redirect/queue order, old-identity completion | [actions.md](actions.md), [argument-vectors.md](argument-vectors.md), [general-properties.md](general-properties.md); no arbitrary JS generator or global ledger/publication theorem |
| Public latest/pending and optimistic values | Admitted non-store windows/read/write crossings, shared lane truth/staging/answers/seams | [verdict-windows.md](verdict-windows.md), [optimistic.md](optimistic.md), lane documents; old notes saying all public crossings are unported are superseded, but hidden/mounted boundaries, store/folded families and general held-lane proofs remain open |
| Deferred data, thenables and typed streams | Constructor/window/owner/producer order, first-load and refetch wrappers | [deferred.md](deferred.md), [deferred-stream-refetch.md](deferred-stream-refetch.md); mutable JS protocols and stores remain excluded |
| `from` | Function subscription plus wrapped typed AsyncIterable, owner/supersede cleanup, pending pulls, local catches and late unsubscribe | [from-subscriptions.md](from-subscriptions.md), [from-iterables.md](from-iterables.md); Observable/interop objects, object `.unsubscribe()` and arbitrary protocol getters/methods remain unfinished |
| Arrays, lists and children | Typed arrays, repeat, positional/keyed/extracted-key mapping, flattening and arity-selected index accessors | [repeat.md](repeat.md), map documents, [flatten.md](flatten.md); packed-index overflow and arbitrary JS callback/value semantics are refused or outside grammar |
| Payloads, questions and callbacks | Opaque data identity, represented function/async tokens, exact binary question IDs, defunctionalized expression programmes | [representation.md](representation.md), [question-ids.md](question-ids.md), [callbacks.md](callbacks.md); IEEE arithmetic/negative fractions, symbols/bigint and arbitrary JS closures/reflection are not implied by arbitrary `R.Value` proofs |
| Resource handling | Explicit task fuel; redirect loops and main machine exhaustion fault | Structural bounds remain proof obligations. Some legacy internal scalar/pointer helpers rely on finite well-formed inputs and have partial-result exhaustion limits; do not treat those as successful unrestricted source executions |

Store/projection/folded-family, mounted boundary/snapshot/spectating and nonproduction
attribution/dev hooks remain material omissions. A callable token used as data is
not permission to invoke arbitrary JS; an arena token needs a valid allocation
context before it models an external input. There is one reactive runtime.

## Host and callback boundary

The JS host supplies codecs, native IO and admitted user programmes. Callbacks
return to Bend for reactive operations. Preserve canonical function/object identity,
Promise settlement/delivery order, iterator method binding, local catches and
partial state after exceptions. State each suite's observation limits rather than
fabricate native read/apply events; see [verification.md](verification.md).

The numeric setter facade returns the original JS argument. A facade return check
therefore does not independently prove the machine's numeric return value. Retain
direct machine/stack observations alongside facade comparisons. Private helper
fixtures may expose native module state in memory; they are not public API histories.

The [action/join constructor extension](transaction-joins.md) changes no runtime,
host, vendored source or adapter semantics. Real action prefixes establish their
capture/debt, and selected allocated-root joins establish transfer and pair
resolver room. A two-action family now removes those premises through both
completions in either order, with arbitrary finite pair lookup/rejoin histories
before/between/after them; see [the completion extension](action-completion.md). General forest,
once-only delivery and publication invariants remain open. The
[eligibility extension](action-eligibility.md) follows the source empty-group
blocker path under explicit health/no-live-lane conditions; no runtime delta.

## Upstream review and discrepancies

Pin changes require `npm run upstream:impact -- PATH`, operation-level review,
verbatim source/hash verification, affected tests/proofs and revisiting deviations.
The location ledger in upstream/correspondence.json is an index, not a proof that
all branches are translated. Never edit baseline hashes to conceal drift.

Classify failures as translation, adapter, admitted-protocol, specification or
upstream. Preserve baseline execution. Reduce significant cases against real
pinned Solid, pair controls, and inspect current relevant upstream fixes/issues
before calling them bugs. Reports remain user-controlled. Temporary semantic
changes require the complete deviation record and a retirement condition; missing
operations remain unfinished rather than becoming a false-valued substitute.

[Earlier operation-level audits](reviews/source-fidelity-through-65e7402.md)
retain the original substitution audit, repair evidence, source maps and historical
counterexamples. Their dated coverage statements are superseded by this page and
the linked area reviews. Current milestone priorities are in [frontier.md](frontier.md).

The [landing scan extension](action-landing-scan.md) checks the source retention
branch without a runtime delta. Its live-list lookup premise stays explicit.
At the 2026-10-23 checkpoint, next@b4d8e6bb had zero signals source drift.
The current 4ea2f498 review supersedes that earlier source check.

## Nonempty rendered blocker extension (2026-10-23)

The [snapshot contracts](rendered-blockers.md) and 144 native-generator histories
add proof/control evidence only. Runtime, host, representation, pinned sources
and toolchain are unchanged. Proof-side guard/list/return decompositions are
checked against actual eligible/blockedOne/blockedSubs/blockStep operations.
Terminal membership is tied to the actual extension store. These are explicit
snapshot contracts, not a replacement scheduler or assumed public publication
rule. No new Solid bug or semantic workaround was introduced.

## Rendered completion-prefix history extension (2026-10-23)

[Completion frames and histories](rendered-completion-history.md) use actual
`action.done`, decrement/schedule and `blocked` operations. The audit driver
threads the actual World and proves which read-only checks may be erased; it is
not a second reactive implementation. Runtime/host/source/toolchain remain
unchanged. The initial snapshot and per-prefix resolution/positive-count
preconditions are explicit; full user bodies and result/flight protocol are not
claimed. No new upstream bug or semantic workaround.

## Actual owned-list entry (2026-10-23)

[Rendered list construction](rendered-list-construction.md) proves the existing
`Transaction.list` fresh capture/append and same-capture no-op, using actual
allocated storage lenses. It supplies membership/layout to the checked pending
rendered history; initial status/parking construction remains explicit. The 54
native private fixtures retain untouched source helper bodies. No runtime/host/
representation/source/toolchain/limit/deviation change or new upstream bug.

## Committed observation through staging (2026-10-23)

[Staging/default-setter frames](committed-staging.md) use unchanged actual
write, read-state, heap, transaction and active core setter operations. The
observation explicitly retains committed node storage, tree and event trace; it
is not substituted for source reader/posture behavior. Custom comparator and
lane/override core branches are excluded from the active bridge. Finite source
controls and independent kernel checks remain separate. No runtime/host/source/
representation/toolchain/limit/deviation change or new Solid bug.

## Actual fulfillment prefix (2026-10-23)

[Fulfillment frames and continuations](async-write-prefix.md) run through actual
pending/status/write operations and the active core default/no-override branch.
The complete machine/task equality retains the source tail; no trim, release or
flush is replaced by an atomic publication assumption. Stale result identity is
checked independently of group identity. Runtime/host/source/toolchain/limits
remain unchanged, with no active deviation or new Solid bug.


## Constructed live selection (2026-10-23)

[Live membership](live-selection.md) follows actual action allocation/opening,
transaction join/removal and completion. Present-source membership is derived
before using source removal; absent-source private controls retain its actual
last-entry behavior. No runtime/source rewrite or semantic workaround is used.
A convenience proof projection exceeded pinned kernel fuel and is excluded;
the constructive scan certificate is independently checked at unchanged limits.

Certified rendered completion/check audits retain the live list and derive the
actual final held scan from initial membership and the checked history. Source
cleanup/flush tasks remain queued rather than assumed executed.


## Merged protocol and first-error fixes (2026-10-25)

[The source refresh](reviews/solid-2a0da2fc.md) integrates #4248's existing catch
scope extension and #4250's STATUS_NO_VALUE rules. Result/iterator processing
remains in its source catch until its actual return, using a passive continuation;
no extra happy-path dispatch changes earlier sufficient bounds. notifyStatus's
both pending-source and bare-status flag selections follow the source. The new
erased dev diagnostic type and compiler/web SSR changes remain outside this
production non-store runtime. No semantic deviation or kernel/limit change.

## Private list ABI repair

[HARNESS-LIST-ABI-001](list-abi.md) repairs four private-control files that manually
encoded Cons instead of the emitted Con constructor. Encoding now derives from
actual ABI constructors and decoding rejects malformed tags/fields. The typed
runtime and proofs are unchanged. Full public and alignment suites pass again.
The older frozen608 receipt lists the seven affected finite variants; a fresh
corrected sweep supersedes that evidence. This is a harness defect, not an
upstream Solid bug or a semantic deviation.


## General pending content safety (2026-10-25)

The [active pending frame/history proof](pending-committed-history.md) closes the previous callback-free settlement
storage-frame obstacle without reducing its observation: all committed values,
the full tree and trace are retained through actual pending steps and arbitrary
finite certified body-only prefixes. Six roots extend 487 to 493. The source
status/tail blocks now have names; an inlining audit recovers the exact previous
statements and order. Public/alignment suites pass; no runtime task, semantic
policy, theorem domain, witness budget or kernel limit changed. Owner callbacks,
general successful termination and coordinated flush/reveal remain open.

## Production integration

#4254 (2d9c9aac) makes computed self-disposal request a future flush when the
module pendingNodes queue still contains nodes. The previous pending/transaction
and frame-read conditions remain in their original order, followed by the new
pendingNodes.length condition. Bend owner.afterPark uses the existing World's
pendingNodes list and constant-time emptiness check. scheduler.ts now exports the
same existing queue. No queue algorithm, cleanup policy or machine budget changes.

The native build/declaration checks and full signals suite pass: 344 files,
5,579 tests, two expected failures and two skips. This includes upstream's real
GC/inspector regressions. Bend uses stable arena identities and does not model
JavaScript physical garbage collection; the port checks scheduling/state only.
64 native/Bend guard cases cover queue presence, computed versus root disposal,
self, pending/transaction and frame-read conditions. Two kernel roots establish
scheduled=true on an actual computed-self-disposal family with an arbitrary
nonempty queue and the empty/unheld control. Removing the new guard is rejected.
Neither root claims queue draining or global cleanup/reveal progress.

## Reviewed exclusions and retained scope

#4256/#4260 exempts observe-only merge key-bag memos from an unstable-output
diagnostic. CONFIG_KEY_BAG is generated without changing existing constants;
attribution.ts and store/utils.ts diagnostic behavior is outside this production,
non-store profile. #4253 select handling and #4258 HTML entities touch web/compiler
layers outside the signals translation. No semantic deviation is active.

All earlier theorem domains remain, including the 103-step deferred data and
118-step stream families. Bend 2.0.37, independent kernel, resource limits and
source statement ordering remain unchanged. The current seal records the full
input/kernel result. The completed 633-variant sweep is historical evidence on
frozen 73eda482 at 2a0da2fc; the current 653 configuration has not had a complete
sweep. Twenty later focused kernel variants passed at their individual checkpoints,
including this new scheduling variant; that is not a fresh complete sweep.

## Proof-checker efficiency overlay, 2026-10-26

The [recorded kernel profile](kernel-congruence.md) changes conversion search
order and updates its complete Lean soundness proof. It adds no semantic
substitution to the source-followable runtime. All runtime, representation, host
and pinned-source bytes remain unchanged in this run; correspondence accounting
is not closed by proof counts. New first-arrival contracts remain properties of
the admitted Bend protocol, not a formal TS/Bend equivalence theorem.

## Repin to next@1d6c40fb, 2026-10-26 evening

The [review](reviews/solid-1d6c40fb.md) audits changed operations and explicit
profile exclusions. The lane never-shown read fix and a new generic branch
contract extend645 to646 roots. Native build/declarations and350 files /5,606
tests pass.3,258 helper cases and720 question controls match; a compact kernel
counterexample rejects removal of the reset. The broad mutated oracle's RSS
stop is not credited. The new onFlush API is unfinished at this intermediate
checkpoint; stores and mounted boundaries remain excluded. Budgets and earlier
theorem domains are retained. No semantic deviation is active.

## onFlush integration, 2026-10-26 evening

[The source-followable API and registration contracts](onflush.md) now implement
schedule followed by a raw microtask callback, with no owner capture or effect
cleanup substitution. Arbitrary finite registration histories preserve all World
fields except four scheduling fields; nonempty idle histories have an exact full
World and one ordered callback job per registration. The actual evaluator bridge
is checked. Three roots extend646 to649.22 native public programs and seven new
compiled negative variants pass. Callback execution/fairness and final global
publication remain separate. This supersedes the intermediate repin's explicit
onFlush omission. The source pin and all older theorem domains/budgets remain.

## Repin to0847122e and held-body extension

The [source review](reviews/solid-0847122e.md) records exact shared frame flags/reads/re-entry and excluded boundary APIs. The [held-body result](held-body-histories.md) constructs preserved canonical source/group/extension certificates and evaluates arbitrary finite real setter bodies through retirement. Its raw construction starts at the body task; the full held-before-resume entry bridge, redirects at source entry and publication remain open.
