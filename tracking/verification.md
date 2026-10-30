# Verification process and trust boundary

Verification distinguishes source correspondence, execution evidence, semantic
proofs and environment assumptions. The shared runtime is the one used by the
host, differential suites and proofs. Tests do not prove arbitrary histories;
helper laws do not automatically establish reachable-state premises.

## Current evidence

Solid is pinned to `5e68925c` (rc.20). The Bend2.0.37 frontend and vendored snapshot
remain unchanged. The independent checker uses the recorded, fully Lean-checked
[congruence profile](kernel-congruence.md); Lean4.34.0 and kernel fuel are unchanged. No semantic deviation is active.

| Evidence | Current scope |
| --- | --- |
| Public differential corpus | 4,759 histories; restricted admitted callback/value/IO grammar |
| Closed composed regressions | 73 fixed end-to-end Bend executions; separate from quantified proofs |
| Quantified proofs | General helper/frame/representation laws, arbitrary scalar-memo histories/batches, fixed graph/lifecycle families, and certified redirect/rejoin history safety; see [general-properties.md](general-properties.md) |
| New join/action controls | 288 private join fixtures /1,152 rejoins /576 queries; 32 opening frames; 48 native-generator public graph histories /408 prefixes; see [scope](transaction-joins.md) |
| Previous redirect controls | 28 fixtures / 2,268 queries / 252 rejoins; 84 machine completion prefixes; not public histories |
| Configured mutations | 764 = 520 finite + 244 kernel variants; ten new rc.20 targeted faults are rejected; a fresh complete 764 sweep remains separate |
| Complete negative sweep | Frozen275c89e8/rc.19: all754 exact ordered variants compiled/rejected after107 unchanged kernel baselines; all1365 sealed inputs and outputs unchanged; [receipt](reviews/complete-754-negative.json) |
| Negative-check scope | Complete754 covers frozen814-root275c89e8 at rc.19. The interrupted748 prefix and repaired tail remain separate scopes. Earlier727/726 receipts retain their old commits; no receipt is relabeled as covering later source/proof changes. |
| Blocked proof | 170-step late-push programme, finite controls pass, independent kernel out-of-fuel; [unverified archive](../experiments/from-async/README.md) |

The [live-selection receipt](reviews/live-selection-validation.json) adds seven
roots: actual action opening/join establishes a live occurrence, either first
completion retains it, and certified rendered completion/check histories preserve
the live list and derive their actual final held scan from initial membership.
Fourteen paired native/Bend present-source and two absent-source private controls
pass. Both new negative variants are rejected. The full public test command passes.

The [fulfillment-prefix receipt](reviews/async-write-prefix-validation.json) adds
seven roots for actual status/fulfillment committed frames, stale-result exact
identity, active default-core branch/stack and exact queued continuation. Ninety-six
forked actual prefix calls on retained public-history snapshots pass, including
24 queued owner trims. Two kernel continuation/stack negatives are rejected.
Queued trim/release/flush execution remains outside these prefix contracts.

The [committed-staging receipt](reviews/committed-staging-validation.json) adds
six roots for unchanged committed values/tree/trace through actual heap/staging/
held-default setters and finite helper-write histories, including an active
ordinary core setter/stack bridge. Existing 203 graph/write and 68 Promise
histories pass. Two kernel record-store negatives and one finite premature-commit
negative are rejected. Pure frames are not successful drains or public reads.

The [rendered list-construction receipt](reviews/rendered-list-construction-validation.json)
adds four roots connecting the actual allocated-slot list operation to pending
membership/layout and the history entry, plus exact re-list identity. Fifty-four
paired private construction fixtures /162 re-listings and three finite negatives
pass. Pending status is installed explicitly in these controls, not proved from
the full public callback programme.

The [rendered completion-history receipt](reviews/rendered-completion-history-validation.json)
adds six roots: actual completion graph/owned-work frames, pending snapshot
preservation and a constructed arbitrary-finite completion/check history with
checked graph/trace and all-true check projections. Forty-eight additional actual
Bend blocker and scan calls run on existing public-history snapshots. One focused
kernel and one finite negative are rejected. Initial graph construction and flight
settlement remain outside the quantified history.

The [nonempty rendered blocker receipt](reviews/rendered-blockers-validation.json)
adds five roots covering terminal membership identity, zero-action graph blockage,
subscriber/generation validity and actual retained scan. One hundred forty-four additional
native-generator rendered-flight histories /1,368 prefixes pass all six event
orders. Two focused kernel negatives and one finite control negative are recorded separately from full sweeps.
These snapshot contracts do not establish their callback-body reachability.

The [landing scan receipt](reviews/action-landing-scan-validation.json) adds two
roots for retaining held groups, 288 direct held-scan calls, 48 finite empty
landing-entry calls and one focused kernel rejection. The attempted general
empty landing/preparation call exceeded kernel fuel and is not an active claim.

The [eligibility receipt](reviews/action-eligibility-validation.json) adds actual
false blocker contracts, their constructed both-completion certificate, 48 paired
empty-group outcomes and one focused kernel rejection.

The [completion receipt](reviews/action-completion-validation.json) adds seven
roots for both completion orders and settled-yield preservation, with four
focused kernel rejections. A bypassed-guard attempt hit an RSS limit and is
explicitly excluded from rejection evidence.

The [blocker receipt](reviews/action-blocker-validation.json) adds the exact
positive-count judgment and its constructed before/after-first-completion
corollaries, 320 direct outcomes and two further kernel negatives.

The [constructed action/join receipt](reviews/joined-action-invariants-validation.json)
records the new quantified contracts, constructed branching prefix, native controls
and nine new negative variants. The proof elaboration normal forms/contracts
change no runtime or kernel limit.

The focused [invariant receipt](reviews/transaction-invariants-validation.json)
records the three independent module verdicts, private controls and four
negative variants. Separately, 21 existing native-generator controls and 45
reusable action-function histories still pass.

Earlier receipts remain tied to their exact pins/checkpoints. The
[previous verification ledger](reviews/verification-through-65e7402.md) preserves
suite-specific observations and historical counts. Its old omissions and totals
are not the current frontier. The current successful composed check is sealed in
tracking/checked.json; it records actual inputs and the kernel verdict, not an
assumed package-completion measure.

## Routine commands

- `npm run build`: generate the active runtime and pinned full-index reference;
  record build input hashes. The reference includes reachable module initialization
  and installed production hooks.
- `npm test`: public/native and direct-machine controls, including the focused
  redirect tests; each suite states what it observes and what it omits.
- `npm run test:alignment`: operation-level source/helper comparison suites,
  including synthetic internal states that are not reachable-public-program claims.
- `npm run mutations`: compile source-changing variants and require assertion or
  independent-kernel rejection. Stale targets, compilation errors, resource failures
  and unrelated errors do not count as successful negative checks.
- `npm run check`: validate pins/deviations and generated artifacts, reject stale
  builds, run the composed independent BendTT kernel, check inputs stayed unchanged,
  and seal the result in build/verification.json. Copy that completed record to
  tracking/checked.json at a checkpoint; every listed input must be Git-tracked and
  hash-identical before synchronization.

Use focused checks while developing. At a coherent checkpoint run the composed
kernel and checks appropriate to the actual changes; broaden tests when changes
or unresolved failures justify it. The latest runtime change only extracts the source settled-node status/tail
segments; their exact inlining audit and public/alignment reruns are recorded. Frozen complete sweeps and fresh focused checks
are deliberately distinct evidence.

## What each layer establishes

Source correspondence uses pinned, verbatim files, operation reviews and paired
execution. `upstream:impact` and the correspondence ledger locate affected source
segments; they are not formal equivalence certificates. Native private controls
may expose/reset module state in memory without replacing source function bodies.
Their fixtures establish local branch coverage, not arbitrary reachable-state
invariants. Public generator controls exercise the real `action` API separately.

The kernel checks elaborated Bend proof terms against actual runtime operations.
Witness generators and executable exploration are ordinary untrusted engineering
tools; their proposed equations must be checked. New redirect certificates contain
actual `into`-field equalities, not assumed step equations. The history runner
carries the actual World. Room, allocated references, callback once-only behavior
and observation bridges are separate obligations as documented per theorem.

Backend-generated JS, codecs and host IO connect execution to native controls;
that connection is not a proved compiler/JS semantics theorem. Opaque values retain
per-runtime identity. General JS arithmetic, protocol reflection, native scheduling
fairness and arbitrary callback termination remain outside the admitted contract.
A valid represented function/arena token is not automatically an arbitrary JS input.

## Observation limits worth preserving

- Numeric facade setter returns use the original JS argument; direct machine/stack
  observations are required for an independent machine-return assertion.
- Direct native getter cleanups preserve original callable identity and omit native
  read-trace comparisons they cannot observe. Other admitted observations remain;
  [getter-cleanup.md](getter-cleanup.md) records the exact boundary.
- Reaction/internal application trace omissions are explicit in [reactions.md](reactions.md).
  Compare actual node/edge state, values, errors, returns and cleanup effects rather
  than synthesizing unseen native events.
- A manual flush may leave an already-requested external job queued. Native Promise
  tests and explicit admitted host-event proofs support different timing claims.
- Exact machine equations include source exception/partial-state and exhaustion
  behavior. Kernel out-of-fuel is a proof-checking failure; runtime Exhausted is
  operational behavior. Neither is proof of successful asynchronous progress.

## Trust and reports

The pinned parser/elaborator and independent kernel implementation underlie the
semantic check. Backend code generation, Node/Bun/native IO, codecs and adapter
observations underlie executable comparisons. Source fidelity remains reviewed
and tested. Mathematical theorem premises and source-rule draft questions are
explicit; no TS equivalence, compiler/browser proof or full-package guarantee is
claimed.

Classify significant failures, preserve baseline evidence and reduce to pinned
real Solid before an upstream claim. Relevant current fixes/issues must be checked
before preparing a report. The original deferred protocol-error evidence remains preserved and its merged
fix is integrated; this invariant checkpoint adds no new upstream bug or workaround.
Reports/PRs are user-controlled. Feature-branch checkpoint synchronization is
already authorized and remains separate from upstream publication.


## Derived live selection (2026-10-23)

Seven new roots construct occurrence and exact held-scan certificates through
actual two-action opening/join, arbitrary finite pair lookup/rejoin history and
either first completion. Fourteen native/Bend present-source controls and two
absent-source controls pass. Two focused negatives are rejected (one finite,
one kernel): 604 configured variants, 476 finite /128 kernel; no fresh full
sweep. [Receipt and proof limitations](live-selection.md) distinguish the checked
constructor from an excluded convenience projection that exhausted kernel fuel.
No new Solid bug, runtime change or active deviation.

Certified rendered completion/check histories now preserve the whole live list,
carry an initial occurrence forward and derive the final held scan on the actual
audit World. No final lookup/count/blocker premise is supplied. The full public
test command passes.

The retained rendered-action suite includes 96 additional rejection histories;
240 native-generator/Bend histories and 2,280 observed prefixes now cover that
slice. The public corpus is 4,726. The quantified history still admits only its
explicit completion/check transitions; rejection controls are finite evidence.


## Merged catch and no-value integration (2026-10-25)

[Source review and receipt](reviews/solid-2a0da2fc.md): 24 new public first-error
histories, 184 retained deferred-stream histories with fixed error expectations,
6,144 private status cases over all no-value bit combinations, 120 native
three-tier protocol cases and six actual JSX cases. Four focused finite negative
variants are rejected. Earlier 454 roots check after the production changes;
two catch-scope roots extend them. The final full-input record is checked.json.
No new whole-package, boundary, arbitrary-history or progress guarantee is implied.

## Actual pending continuation prefixes

The [continuation receipt](reviews/pending-continuations-validation.json) records
ten new roots and the existing 456 retained roots. The 120 accepted non-trim
public-history snapshots now execute 880 actual settlement/schedule steps to
their queued flush. Four focused kernel negatives are rejected. Caller-stack
preservation is proved by induction over certified actual-step prefixes; the
stronger settlement storage frame was still unverified at that earlier checkpoint; the later active frame/history extension closes it. No resource failure
is credited as a semantic negative, and no runtime or limit changed.

## Owner bookkeeping and bounded return

The [owner receipt](reviews/owner-continuations-validation.json) records four new
roots with all earlier 466 retained. The prefix domain expands to structural
owner work. All 160 accepted forked arrivals now run 1,360 steps to their queued
flushes, including 40 trims independently confirmed to have no stale suffix.
Three targeted source faults are rejected by the kernel. The separate frozen608
receipt verifies exact named-set equality and all 798 tracked input hashes.

## Canonical ABI and selected observation

The [current receipt](reviews/rendered-observation-validation.json) records eight
new roots and the earlier 470 retained. Actual selected text/events have positive
laws, while independent apply and ordinary arrival preserve that observation.
The list ABI repair is material to private-fixture evidence: four files now use
the emitted constructor and strict decoding, with full public/alignment reruns.
Typed proofs are unaffected. Do not quote the old complete608 receipt without its
subsequent seven-finite-variant caveat. The fresh frozen corrected619 sweep passes with exact named-set equality and
all 817 tracked input hashes unchanged; see the canonical-list receipt above.


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


## General single-source cycle membership (2026-10-25)

The [cycle invariant](carrier-cycles.md) now constructs fresh/empty/singleton
source snapshots through actual add/remove transitions and proves membership for
arbitrary finite command lists, including re-registration and duplicate calls.
Proof-carrying and direct actual-helper World execution agree, and actual default
memo/render construction supplies the initial invariant/source identity. Nine
roots extend 553 to 562. The 131 finite controls and 449 duplicate no-op checks
pass; two new kernel faults are rejected. Status/readiness, complete public
flight/action protocol and coordinated reveal remain open. Runtime/source/host/
limits and old domains/budgets are unchanged.

## Idle-disposal scheduling refresh

[Reviewed next 4ea2f498](reviews/solid-4ea2f498.md) integrates #4254's retained
pending-queue scheduling guard and preserves the earlier source/proof domains.
The native full suite passes 344 files / 5,579 tests; 64 private native/Bend
scheduling cases and two kernel guard roots pass. Physical JavaScript GC is not
modeled. That refresh checked all 564 then-active composed roots; no global
queue-draining or eventual-render theorem follows from this local guard.

## Pending notification connects carrier, status and error

[The notification contract](pending-notification.md) constructs singleton
source membership, Solid's status-bit selection and exact incoming NotReadyError
identity from a prior carrier snapshot and a no-existing-error input condition.
Actual status/error writes preserve committed content. The 120 typed constructed
cases and paired native local-result controls pass; four compact kernel negatives
are rejected. Six roots extend 564 to 570. This stops before effect notification,
propagation and public controller callbacks; readiness/accounting/reveal remain
open. Runtime/source/host and previous theorem domains/budgets are unchanged.

## Notification status carry comes from incoming state

The [stronger input-status contract](pending-notification.md) proves that actual
source registration preserves every node status word, including extension
allocation. Pending notification consequently selects its carry from the actual
input flags. Two roots extend 570 to 572; 108 private/native controls and two
compact kernel negatives pass. No runtime/source/domain/budget change. Full
controller and settlement composition, readiness/accounting/reveal remain open.

## Actual action wait construction and guarded histories

[The wait construction contracts](action-wait-construction.md) derive fresh
observer identity/capture, result-slot subscription, an unsettled lookup and
retained range from actual registration. Arbitrary finite registration/observer-
allocation/mark histories keep the first settled lookup; duplicate yielded-value
callbacks retain the exact current World/tasks/stack, including transaction counts.
The post-callback synchronous throw catch is connected too. Actual action/Promise
creation supplies a typed initial context and nonzero identities. Thirteen roots
extend 572 to 585; 368 typed histories, 736 guard/368 catch checks, six native
sequences and five focused negatives pass. Full generator/once-only debt/flush/
reveal remain open. Pending status composition's resource-stopped attempts are
archived explicitly; no runtime/source/toolchain/domain/budget change.

## General pending status classification

[The status projection contract](pending-notification.md) derives the actual local
pending store's selected word and pending/error bits for every incoming U32 word,
including existing-error cases, from valid node identity alone. Earlier carrier/
error-identity domains remain unchanged. Six roots extend 585 to 591; 240 private/
native controls and two focused kernel faults pass. Callback reachability, full
controller settlement, global accounting and coordinated reveal remain open.
The proof-only dependency split retains every statement and checker limit.

## Notification control dependencies

[The local-store footprint and original-budget contracts](pending-notification.md)
preserve no-error input shape/links/count/fault, retain health and derive two
notifier steps of room from valid node identity. Four roots extend 591 to 595;
81 native/driver controls and two focused faults pass. The actual whole notifier
composition remains [unverified](../experiments/notifier-controller/README.md) at
the dispatch boundary. Its isolated runtime-naming experiment was discarded;
active runtime/source/host/limits and earlier domains remain unchanged.

## Complete frozen664 negative sweep

[The exact named-set receipt](reviews/complete-664-negative.json) verifies all
664 mutations on frozen fb4dd44b: 484 finite and 180 kernel faults. All 962
sealed inputs are unchanged and Git-tracked; the tracked checkout is clean.
No compilation, timeout or resource failure was credited as rejection. This
covers the constructed-wait checkpoint. The four later focused status/footprint
faults and current positive roots are reported separately; this is not a claim
of a complete sweep of current668.

## Other observer clients in action wait histories

[The capture extension](observer-captures.md) admits actual synchronous fulfilled/
rejected capture, stream-step allocation and ignored-return subscription into the
constructed wait histories. Existing guard/range/content/catch domains expand;
seven new helper/capture roots extend595 to602. 408 new orders,12 actual raw
client constructions and three focused faults pass; all old368 cases and six
native sequences remain. First actual delivery/marking, complete generator/debt
and queued flush/reveal remain open. Runtime/source/host/limits are unchanged.

## Derived actor identity and actual first delivery

[HARNESS-ACTION-IDENTITY-001](action-identity.md) corrects a fixture that forced
unallocated actor1 even though create returned0. Four earlier helper domains are
retained under explicit legacy names and their construction wording is qualified.
[The actual callback/retirement family](action-first-delivery.md) now derives the
binding, establishes its settled mark through real first delivery, retires one
constructed obligation/output through actual ActionStepReturn, and preserves
its actual Machine under later stale callbacks/helper histories. General resume/
pre-entry frames and all-value raw rejection laws are checked separately. Sixteen
roots extend602 to618;66 native-model return cases,22 native generators and four
focused faults pass. The general arbitrary-World delivery composition remains
archived unverified; full generator/flight ledger and queued flush/reveal stay
open. Runtime/source/host/limits are unchanged.

## Actor context across helper histories

[The outer-context invariant](action-helper-context.md) masks only the four actual
callback tables and retains every other World field through arbitrary finite
helper histories. Allocated actor room and the full captured cell now follow
after each permitted constructor prefix, and actual terminal retirement's zero
count survives later helper suffixes. Four roots extend618 to622; stronger finite
outer-World observations pass. Three new context corruptions and a fresh run of
all14 later faults are rejected. Full664 remains a separately frozen receipt;
current678 is not claimed as a complete sweep. Runtime/source/host/limits remain
unchanged. General pre-arrival controller composition and full ledger/flush/
reveal remain open.

## Constructed method arrivals and checker efficiency

The [new composition](action-method-first.md) extends622 to630 roots, covering
actual first callback and post-arrival stale guards after arbitrary admitted
helper prefixes, for both End and Body methods. Existing domains remain. The
selected checker profile and complete Lean build/axiom/executable receipt are now
part of each seal. The four new corruptions pass compact positive probes and
are rejected without resource failures; an earlier broad negative RSS stop was
not credited. Frozen678 and current four focused variants have separate receipts.
Runtime/representation/host/source pin and kernel fuel are unchanged.

The [pending completion receipt](reviews/pending-completion-validation.json) records
nine additional roots,162 native/driver controls and three new focused kernel
rejections. Both full execution and full source-alignment commands passed on
frozen a6d4c84b with the same production runtime. The checker now also seals all
tracking documents and receipts, excluding the output seal itself.

The [actual controller receipt](reviews/pending-controller-validation.json) adds
six composed roots,192 native settlement controls and two focused rejections.
All frozen682 names remain a separate complete receipt; five newer negatives
have focused evidence, not a fresh full687 sweep.

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


## Executed action body and baseline-oracle check, 2026-10-26 evening

[The body-return domains](action-body-return.md) and
[receipt](reviews/action-body-validation.json) add nine roots649->658,1,950 typed
body returns,3,900 stale-Machine controls,130 pending adoptions and16 independently
authored native-generator/port cases. Five new compiled kernel variants are
rejected by the separately passing compact oracle. An initial undefined helper
made that oracle fail unchanged; those apparent rejections were discarded.
The mutation runner now requires each selected kernel oracle to pass unchanged
before any mutant can receive credit. A deliberately malformed copied oracle
is refused with zero credited rejections. Current configured700=487 finite+213
kernel targets are current; the independent frozen695 sweep is still in progress,
and this checkpoint does not claim a complete700 sweep. Earlier completed frozen
receipts remain scoped to their exact inputs/checker. Budgets are unchanged.


## Complete frozen700 and ordinary setter bodies

[Complete695](reviews/complete-695-negative.json) verifies all1066 frozen a275f00
inputs and all94 unchanged kernel oracles. The subsequent
[complete700 sweep](reviews/complete-700-negative.json) verifies all1079 frozen
cf7cdf08 inputs and the mandatory unchanged-oracle gate for all95 selected kernel
modules. Every named variant compiles and is rejected exactly once; input trees
and declared checker hashes remain unchanged. No resource or compile failure is
credited. These receipts supersede the earlier in-progress status for those
exact frozen snapshots, without relabeling them as newer source scopes.

The [ordinary setter-body domains](ordinary-action-bodies.md) add ten roots668
in total, with896 finite body/caller checks,8,904 setters,16 native generator/port
programs and eight pending output adoptions. New focused negative tests are
separate from complete700. An initial larger negative oracle hit the4GiB frontend
bound and received no credit; its smaller real-signal boundary oracle must pass
unchanged and reject compiled variants. The full independent composed verdict
is required before this checkpoint is sealed. Diagnostic compiler experiments,
standalone aggregate time/fuel stops and frontend-only checks are not independent
mathematical verdicts. Kernel profile/fuel and negative-probe limits are unchanged.


All five new ordinary-body variants compile and are rejected by the independently
passing runtime-only oracle; the earlier resource-stopped attempts receive no
credit. Current configured705=487 finite+218 kernel targets are current. Complete
frozen700 remains a separate scoped receipt, not a fresh complete705 claim. See
[body validation](reviews/ordinary-action-bodies-validation.json).

### Held staging extension after668

[Held-staging scope and evidence](held-staging.md) and its [receipt](reviews/held-staging-validation.json) add seven runtime-only kernel fault variants: source flight, saved pending slot, clock, group debt, join scheduling, canonical cache and heap extension identity. Configured712=487 finite+225 kernel. Fresh focused credit requires the runner successful seven-variant footer; earlier complete frozen700 and focused body5 are separate. Complete712 subsequently finished on the exact frozen674-root checkpoint; see complete-712-negative.json. Full composed credit requires the fresh independent674-root verdict and exact input seal.

### Canonical held bodies and0847122e

The [body receipt](reviews/held-body-histories-validation.json) records1,792 ordinary/held body controls and the focused8 compiled semantic rejections on0847122e, including a suppressed-comparison join-order fault. Configured713=487 finite+226 kernel; complete frozen712 at8d5e414d is a separate source/corpus. Whole682-root independent verdict and exact input seal are required before checkpoint credit. The [source validation](reviews/solid-0847122e-validation.json) separates exact source bytes, native tests, alignment and regenerated data from that mathematical verdict.


### Held actual resume entry

Five new roots compose actual captured resume through finite held-body evaluation and retirement; [scope](held-resume-retirement.md). The complete712 sweep on frozen8d5e414d now finished:712 exact ordered unique named rejections,97 passing mandatory unchanged kernel oracle modules and1132 unchanged tracked sealed inputs; [receipt](reviews/complete-712-negative.json). This is distinct from the frozen713 run onfc38211d/0847122e and from the new687-root candidate.


The687-root entry/retirement book passed independently in421.9s. Two certified captured-alias join dependencies extend the final candidate to689; they do not assert full callback entry/retirement for aliases. Final checkpoint authority remains the fresh full verdict and input seal.


### Complete713 on0847122e

The full frozenfc38211d/0847122e sweep finished successfully:713 exact ordered unique names,487 finite and226 kernel variants, all compiled and semantically rejected. All97 mandatory unchanged kernel oracle modules passed first. All1150 sealed inputs remain tracked and byte-identical; no compilation/resource failures receive credit. [Receipt](reviews/complete-713-negative.json). The frozen682-root sweep is distinct from the final689-root book.


## 2026-10-28 rc.19 source rebase

The [review](reviews/solid-ac28157a.md) and [receipt](reviews/solid-ac28157a-validation.json) separate77 exact Git source inputs, source-driven replacements of three old equations,355 native files/5646 passing tests, complete helper alignment and expanded entered-reader/public grouping controls. Six new compiled semantic faults are rejected. Configured719=493 finite+226 kernel remains distinct from the old full713 frozen sweep. Fresh whole691-root mathematical verification and exact seal are required for this source checkpoint.


[Ordinary observer-delivery validation](reviews/held-action-delivery-validation.json) records the six-root extension, unchanged checker/runtime, 336 actual bodies,2688 duplicate lookups and three independently compiled finite source-fault rejections. The whole-guard RSS-stopped mutant and early fixture/compile failures receive no credit. The complete frozen719 run remains separate.


[Constructed held-delivery validation](reviews/held-constructed-delivery-validation.json) records actual constructor-supplied entry/lookup/count facts, larger independent import-book verdicts with explicit wall deadlines, preserved2832-body/32-native controls and expanded1008-body/8064-duplicate finite helper-prefix controls. Runtime, fuel, RSS bound, checker rules and earlier theorem domains/step bounds are unchanged. Full713-root checkpoint credit requires its own exact sealed verdict.


[Output/source-cache validation](reviews/action-output-and-source-cache-validation.json) separates the nine-root candidate, source-cache-before-merge controls, finite output-request drains, local slice guards, four compiled kernel rejections and the completed frozen719 sweep. All1008 body-to-queued-Round controls and8064 duplicates pass; full scheduler Round execution/publication remain outside this result.

The five-root constructed outer-task extension requires a fresh727-root whole-book
verdict. Compact versus combined module deadlines are explicit in the runner;
no checker fuel or rules changed. Pending complete726 negative sweep remains
scoped to frozen722-root cb13517d and is not credited before its successful footer
and hash/sequence audit.

The source-cache resume extension adds six roots and one configured kernel fault:
727 configured variants =496 finite+231 kernel. The new fault requires a passing
unchanged cache-rebase oracle before rejection credit. The3120 body controls
include144 distinct source/capture identities; they are finite evidence alongside
the generalized resume proofs. Full733-root checkpoint credit requires a fresh
whole-book verdict/seal.


The joined-controller body candidate adds five roots,640 finite internal pairs
with1,280 body prefixes, and64 native/port public generator histories. The latter
check rendered retention across the first completion and native final reveal.
They are separate from the internal-prefix domain and from proof credit. The
unchanged400M-fuel checker passes the final closed constructor import book; the
first closed-wrapper fuel stop and earlier memory/authoring failures receive zero
credit. Full738-root checkpoint credit requires a fresh complete verdict and seal.
Configured727 mutations and the frozen complete726/727 sweeps remain separately
scoped; no new runtime delta or mutant is introduced by this proof extension.


The [constructed count/blocker extension](held-count-evidence.md) adds direct
closed first-body count and unchanged actual blocker results, plus the constructed
post-body source profile. Reified execution evidence is constructed, and separate
soundness roots discharge count/health/blocker/profile conclusions. All runtime
bytes and checker rules/budgets remain unchanged. The750-root candidate requires
its fresh complete verdict and exact seal; stopped drafts receive no credit.


The [derived other-controller handoff](held-next-body.md) now constructs actual
source/cache and other-controller capture/route/method facts after either first
finite body, then proves the other actual resume/body has zero remaining action
debt and restores its caller stack. Both completion orders and join directions
are quantified. This is a two-resume contract sharing the exact first result
World; uninterrupted queued output/slice/Round and public host composition remain
open, as do result adoption, owned flights and renderer publication. Twelve roots
require a fresh762-root independent verdict and tracked-input seal.


The [joined-body queued-Round extension](joined-body-round.md) connects real
constructed captures/source/body execution to the exact output queue, finite
observer request drain and actual slice-end guards. Its closed initial Machine
reaches Round before saved-question restoration with count1 and an unchanged
actual blocker. Round execution and the uninterrupted host/publication history
remain open. Ten roots require the fresh772-root independent verdict and tracked
seal; runtime/source/checker semantics are unchanged.


[Constructed live-list facts](held-live-list.md) derive the surviving occurrence
through real construction/join/preparation/body/output draining, plus an actual
local scanner step on the queued-Round snapshot. The latter explicitly supplies
the scanner task as an operation input; Round intake/park/lane/seam reachability
is still open. Six roots require the fresh778-root independent verdict/seal.


[Quiet held settlement](quiet-held-settlement.md) now proves actual settlement
creates its scanner task and the following scan retains a positive-debt group,
with committed storage and caller work unchanged. This is an initial-state
operation contract with finite actual pending-list flag certificates and empty
lane/zombie hooks. Its premises are not yet constructed after the queued Round's
heap work; that reachability gap is explicit. Five new composed roots require
the normal whole-book independent verdict and tracked-input seal. No runtime,
source pin or checker change is involved; no new upstream bug or deviation.


[Parking frames](park-transaction-frames.md) generalize action-count preservation
through actual node/child/default-intake walks, including failed/exhausted paths
without claiming their success. A separate initial-state childless-node contract
derives successful holding, the identity child-frame walk and retained health.
Mixed source/render intake and the earlier heap reachability remain open. Six
new roots require the normal composed independent verdict and exact input seal;
no runtime/source/checker change or new upstream bug/deviation is involved.


## Source update to 178605cf (2026-10-29)

The [review](reviews/solid-178605cf.md) separates 78 exact selected inputs,
source-followable non-store runtime changes, admitted helper controls and excluded
store/boundary/dev changes. Native signals builds/declarations and 380 upstream
files /5,858 tests pass. New borrowed-guess, pending-question, ancestor-verdict and
mark-flight controls are paired with unchanged source bodies. Six new compiled
semantic mutations and the six moved-operation negative checks are separate from
the old complete727 frozen sweep; target validation alone is not rejection credit.

The existing 789-root book must pass anew on this runtime. Its lane-end and guess
push boundaries follow the new source; the nonguess leaf-notification statement
retains its original assumptions and result. Preliminary interrupted authoring
checks receive no credit. The final completed verdict/input seal in checked.json
is the mathematical authority, with the unchanged profile and fuel.


The source update completed at0ffa4d4916df2e34aae226be20db74e34f280494:
789 roots,1320 tracked inputs,539.011613221s, normal feature-branch push verified
against the remote. The unchanged checker/profile/fuel passed the complete book.
All remaining public test modules from affects.mjs passed after the shared-build
interruption; original prefix plus resumed tail cover the public suite. The
complete alignment suite and new source controls passed. No incomplete command
is described as an uninterrupted successful whole-suite run.

[Mixed parking](mixed-held-settlement.md) adds320 paired private source/Bend
controls and three compiler-valid semantic rejections, separate from the old
frozen727 full sweep. Nine new roots require the fresh798-root full verdict.
No runtime, source or checker change is involved.


Mixed parking completed ata5fa2e9504748829c3462d0a9e27f070d8e34990:798 roots,
1335 exact tracked inputs,552.370199302s, verified normal feature push. The
[round-return extension](mixed-held-return.md) adds640 paired native controls
and six targeted compiled semantic rejections. Its first run-own-queue fault
was accepted by silent callback placeholders; observable markers now detect it.
The configured total748 and focused checks remain distinct from frozen727.
Seven new roots require the fresh805-root official full verdict/input seal.

The 805-root round-return checkpoint completed at 5b04774a956b5d70c36007a928e45e5844650789
with 1349 exact tracked inputs and 560.738987403s independent check; its normal
feature push was verified. The recovered frozen 748 sweep stopped after 482
rejections at a lane-stage oracle gap. After repair, the targeted 266 tail passes;
[the receipt](reviews/round-heap-mutation-gap.json) explicitly does not combine
them into an unchanged full sweep. New entry/heap checks bring the configured
total to 754; targeted checks and resource-stopped attempts remain separate.
[Round/heap contracts](round-heap-entry.md) require a fresh whole-book verdict.


## 2026-10-30 rc.20 integration

The [source review](reviews/solid-5e68925c.md) and [receipt](reviews/solid-5e68925c-validation.json)
record the exact pin, native package validation, frozen public/alignment/checker
inputs, changed source segments, ten targeted mutation rejections and the
independent 816-root candidate verdict. The deferred-stream fuel stop is retained
as an uncredited attempt; checked source-operation cuts recover the original
claim at the same fuel. The accepted checkpoint's authoritative whole-book/input
record is `tracking/checked.json`. Fresh whole764 mutation coverage is not claimed.
The added heap-entry count roots retain one action obligation through the actual
constructed first body and Round/heap entry; heap execution/publication remains
the next composition, not an assumed post-state certificate.
