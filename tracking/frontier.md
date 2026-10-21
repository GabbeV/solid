# Active frontier

This is an incremental executable translation, not a completed package port.
[Progress checkpoints](progress.md) compare this session with c446418 without
turning test counts into a package-completion percentage.

Current verification: 2748 differential histories, 172 rejected compiled mutations,
and 67 composed closed Bend regressions, plus general payload/question/callback/path helper laws. The Bend toolchain pin is unchanged; Solid is
now pinned at d682022c (rc.16) and the semantic deviation register is empty. See [verification.md](verification.md).

The user now explicitly requires a source-followable translation. Read
[source-fidelity.md](source-fidelity.md) for the contract and the audit of existing
substitutions. Repair these before expanding affected paths, or register a
necessary temporary deviation under [deviations.md](deviations.md). The user permits
tracked deviations to unblock progress while an issue/fix is investigated. A formal
TS/Bend equivalence proof is not required; no silent semantic repairs are allowed.

## Reviewed next update

The [d682022c review](reviews/solid-d682022c.md) integrates nine upstream commits.
The production projection error fix is source-only coverage because projection
families are not yet represented. Dev diagnostic changes leave the admitted
production behavior unchanged. Twelve new paired equal-compute effect histories
and two source-only projection controls pass; prior fixes and preserved bugs are
revalidated. The b0ad1df5 checkpoint remains on its own baseline branch.

## Typed action milestone

[Action invocations](actions.md) now use the existing transaction/core driver for
initial and resumed slices, held writes, question provenance, nested/overlapping
actions, rejection and typed return adoption. Captured local signals continue
across yields and root disposal. The milestone adds 67 public plus eight lexical
histories; the reusable-wrapper extension adds 45 histories, for 120 action histories,
27 independent native-generator/factory controls, eleven quantified local/capture properties
and three closed action executions. Reusable action-function identities, finite
invocation argument vectors and nested action parameter capture now execute; arbitrary protocols/internal awaits and active optimistic/lane/store
engines remain unfinished. No source pin or semantic deviation changed.

## Variable-arity calls

[User-call vectors](argument-vectors.md) remove the two-argument admission limit
for the existing callback/action callables. Callee/arguments evaluate once in
order before the same callback and action engines run. Seventy new paired
histories, six independent native generator/factory controls, eight local
quantified binding/order laws and two closed nine-argument executions pass.
General JS closures, generator progress and active engines remain unfinished.

## Custom comparator milestone

[Custom comparator programs](comparators.md) now execute at all active source
call sites, including pending/error handling, async results, held seams and
setter cleanups. The milestone adds 134 public histories, 46 direct native helper
comparisons, four closed execution laws and five quantified local helper laws.
Arbitrary closure environments and active scope engines remain unfinished.

## Flush callback milestone

[Public flush callbacks](flush-callbacks.md) now use the shared machine, retaining
nested synchronous drains, exact callback returns, ambient scope, native callback
identity, finally-on-throw and drain-error precedence. The milestone adds 64
public histories, eight native scheduling-IO controls, two closed execution laws
and three quantified entry/finally properties. Typed production action invocations now execute; the full action API remains unfinished.
User-submitted reaction PR [#4188](https://github.com/solidjs/solid/pull/4188) is
open and tracked; its change is not applied to the active source pin.

## Complete scalar-memo proof milestone

The [public program theorem](general-properties.md#complete-scalar-memo-public-program)
now composes the actual constructor, public setter and 40-step drain for every
natural proposal and larger drain budget. A checked 14-step constructor and
two-step setter close the previous staged-arena precondition. The original theorem starts at zero. A new complete family covers every natural
initial value and proposal, all constructor budgets >= 14 and drain budgets >= 40.
Graph topology is fixed and has no effects. This is a complete quantified
program result within that domain, with no runtime change or TS equivalence claim.
The two-memo/render constructor, setter bridge and complete public drain are
now checked as well.

The constructor is also proved separately for every natural initial value and
all budgets >= 14, using a symbolic path. The complete update/drain family now also quantifies the initial value; arbitrary
graphs remain outside that result. Three general transaction-merge laws
now cover open-count sums, redirects and action markers in both directions
between two represented ordinary roots.

## Two-memo/render proof milestone

The [larger graph drain](chain-proof.md) now has a checked 95-step completion
path and exact render-application trace for every natural proposal and all larger
budgets, from its explicit staged arena. Its fixed constructor is also checked.
The setter bridge now closes that starting-state precondition: four public
constructor/setter/drain/final-World/trace properties quantify every natural
proposal and drain budget >= 95. Eight finite native/canonical controls pass
separately. Two general successful-publication
composition laws also check. The runtime is unchanged by this proof milestone.

## Allocation and cleanup proof milestone

Four [extension allocation laws](general-properties.md#lazy-extension-allocation)
now prove exact identity, single append, default fields and idempotence under the
sentinel invariant. Three [cleanup laws](general-properties.md#reactive-cleanup-capture)
prove normal-frame detachment before invocation, non-replay and reverse order.
These are quantified local results over arbitrary surrounding state; the runtime
is unchanged. The two-memo/render setter bridge and complete public program
are now also checked; see the graph milestone above.

## Memo staging proof milestone

Three [general staging properties](general-properties.md#staging-a-changed-memo)
now cover the actual successful memo publication helper: stage before notifying,
exact preservation by the pending-slot store, and the full no-subscriber arm.
They complement the existing commit proofs and preserve the runtime unchanged.

## General semantic proof milestone

[The semantic review](general-properties.md) adds seven quantified publication/read
properties and three complete data-signal properties. Publication covers any
existing arena position and Value while preserving the rest of the World. For a
single numeric signal with equals:false, public reads see the old value before
flush and the new value after; a checked 19-step path proves completion for any
larger budget. These are general results within their explicit domains, beyond
closed examples and binding laws. Arbitrary graph/history correctness remains open.

## Tracked effects milestone

`createTrackedEffect` now uses the actual lazy-computed/heap/user-queue path.
Its body tracks reads, writes only to the next commit, and returns cleanup that
runs before its next body or disposal. The source modified/disposed gates,
children-forbidden posture, pending/error notifier and immediate trim are retained.
[The review](tracked-effects.md) records source segments, 47 public histories,
32 native runner comparisons and two concrete laws. This now underpins owned `onSettled` callbacks.

## Settled callback milestone

`onSettled` now follows both source branches: an owned untracked body in a tracked
leaf, or a node-free plain callback in the user queue. The latter retains its
identity when dirty derivations make it requeue. [The review](settled.md) records
54 public histories, 48 native fire-closure cases, cleanup/throw behavior, two
concrete laws and two general input-binding laws. [Reactions](reactions.md) now also retain the source closure's cleanup/current arm,
replacement disposal, captured owner, deferred user effects and first-class track
function. The milestone adds 66 expression histories and 12 original function
histories, two positive concrete laws and one negative pending-arm counterexample.
[The new source bug](upstream/reaction-pending-rearm.md) is an uncovered pending
case of #2861, reproduced in Chromium on current next; no workaround is applied.
Richer callable closures and active lanes/boundaries remain
unfinished.

## Current source update

The active pin is b0ad1df5, the fetched `next` head on 2026-10-21
(Europe/Stockholm). [The review](reviews/solid-b0ad1df5.md) covers the eight
commits since 71153bf0, two changed source files, dev-only cleanup-write guards,
mount inheritance for active lanes, and untrack documentation. No active lane or
dev support is newly claimed; the admitted production operations are unchanged.
Twelve new public untrack histories run on both pins. The old 71153bf0 checkpoint
is retained at baseline/solid-71153bf0 (075455c). Earlier milestone sections below
retain their historical pin and totals unless superseded here.

## Current owner/core milestone

[The continuation review](reviews/teardown-closure.md) closes the remaining
async/error/pending World-helper crossings for the admitted program grammar.
Cleanup programs now read through the same public core machine at every active
engine caller: 74 new public histories, 136 total direct owner/core probes, four
new rejected mutations and three new closed async cleanup laws. Source/helper
order, interrupted assignments and partial throws are retained. The static
inventory reports zero restricted core crossings; it is not a package-completeness
proof. Earlier staged progress sections below describe the historical boundary.

Direct bound getters now register and return as cleanup functions through the
same read driver. [The getter review](getter-cleanup.md) records 54 new histories,
canonical owner/effect aliases, a concrete law and native trace limits.
Remaining callable work includes arbitrary callable initializers and richer closures; arbitrary comparator closures and
active boundary/lane/store engines remain outside this profile. PR #4176 is
open; its proposed source fix is not silently applied to Bend.

## Established execution path

`api.createMemo/createEffect -> core.recompute -> Evaluate/ReadNode -> graph.link
-> heap marking/pull -> core.finish/publish -> scheduler.commitPendingNode
-> core.runEffect -> tree.setText`.

The same definitions implement explicit `flush` and both differential and proof
scenarios. Setters evaluate pure updater expressions against the staged slot and
retain Solid's return-value behavior. Earlier preferences reported in the uploaded
guide were not treated as new user instructions. No previous implementation or
proof credit was imported.

## Supported grammar and limitations

- Owned synchronous nodes under explicit owner/root callback scopes; stable signal,
  owner/computed, link and mechanical-tree identities. Lazy activation
  and observation-lifecycle dormancy/revival work, including dead-parent freeze. Internal
  constructors support nested-root parentComputed forwarding, tested at height,
  heap and read sites. Callback-based owned/detached roots, runWithOwner, owner/observer handles and
  disposal status now execute; see [ownership.md](ownership.md). Nested createMemo(compute, options)() expressions execute under the actual current
  owner; nested user/render effects also execute. Local data signals and captured inline application bodies also execute; escaped data-signal read accessors now execute; escaped data-signal setters and computed read accessors now execute; expression-based function initializers now execute; arbitrary callable initializers remain open. See [locals.md](locals.md). See [nested.md](nested.md).
- Separate source constructors and lazy extension defaults now exist. Default
  sync is false; loading-seed presence includes explicit undefined. Synchronous
  seed/option histories execute; loading-window pending catches now execute through
  direct source probes; ordinary promise-like registration/settlement now executes; typed iterator consumption/flattening now executes. See
  [representation.md](representation.md) for storage-only extension fields.
- Reusable defunctionalized callback programs, not arbitrary JavaScript closures.
  Render application writes computed text. User application records its value
  and previous value. Owner cleanup programs can emit trace events, dispose
  owners, register cleanup, or throw a payload. They execute on the active owner
  machine, including reentrancy. Compute/effect programs can also write signals, register cleanup in the active context,
  dispose the root and install returned effect cleanup. Expression-bearing compute/application/error callback bodies now use the real
  read machine, with early return and evaluated writes/throws. Expression teardown callback
  reads now execute; arbitrary closure environments, escaped data-signal read accessors now execute; escaped data-signal setters and computed read accessors now execute; expression-based function initializers now execute; arbitrary callable initializers remain open;
  see [callbacks.md](callbacks.md). Synchronous compute/effect error catches,
  user error programs, explicit previous-cleanup helpers and scheduler halts work.
  Pending-source propagation/retirement and loading-window/landing helpers now
  execute through core catches/reads. Mainline transactions join, merge, park,
  judge blockers and land through the same flush. Typed promise-like programs now execute registration and callback delivery.
  Typed iterator consumption/flattening executes; active boundary/lane scopes remain unfinished.
- Default strict equality, `equals:false` and named custom comparator programs
  execute; see [comparators.md](comparators.md). Arbitrary comparator closures
  remain open. No equality-equivalence axiom is assumed. NaN is nonreflexive.
- Payloads distinguish absent staging, undefined, null, booleans, naturals, NaN,
  text, and opaque reference identities. Reference tokens must preserve host
  identity. Signed zero has strict-equality semantics. General binary64 numeric
  computation, arbitrary functions-as-data and arbitrary thenable shape probing still need
  a richer host protocol. Immutable built-in Error/DOMException inputs now retain
  native identity and selected properties; custom errors/getters/coercion remain
  unfinished. See [errors.md](errors.md).
- Nat counters are mathematically unbounded in proofs. The emitted JS backend's
  supported integer range and the facade's 2^48-1 payload/arithmetic bound apply
  to execution. Proofs are about Bend terms, not unbounded JS integer arithmetic.
- Persistent list arenas retain retired records and have linear lookups. This is
  a representation cost, not evidence of Solid's algorithmic performance.
- Pointer walkers rely on structurally valid generated lists and finite resource
  budgets. The composed fixed-graph proofs establish successful completion for
  their inputs. A general representation invariant and progress bound remain
  open. Host tests check both link directions, tails, cycles, context restoration,
  and absence of stranded staging after completion.
- No browser, DOM, JSX, SSR, hydration, or store implementation is attempted.
  The reference build starts at the actual full signals index and retains store
  module initialization when reachable. Tests call no store APIs. Inertness of
  omitted shared store hooks is reviewed/tested for this grammar, not formally
  proved as a general module-initialization theorem.

## Proof coverage

`chain_once` and `chain_twice` check concrete writes `6`, then `9`, on the
source -> (+1) -> (*2) -> render (+source) graph with `equals:false`.
Initial allocation, staging, actual callback reads, memo results, dirty-heap
execution, commit and render application all participate. The result includes
actual attached tree text (`20`, then `29`), source/memo values, successful
completion, empty pending/render/user queues, restored runtime context, and reset
unflushed/promotion state. They also check that no live cold extension is allocated
(the arena retains only its reserved zero record).

A separate reusable path lemma relates actual `core.step` transitions to
`core.run` for arbitrary machine states and a valid finite execution path.
The concrete top-level laws are checked directly through the real API and driver.
No generated result, safety gate, alternate scheduler, or imported axiom supplies
the tree values.

Attempted arbitrary-natural-payload versions passed the frontend, but caused
excessive independent-kernel expansion under open contexts. Even canonical
transition witnesses remained too costly without further helper refinements.
Those attempts are not completed proofs and were removed from the active roots.
The concrete laws pass independent checking. The differential suite has
203 scenarios; focused tests additionally compare 10,752 constructor states,
4,608 commit states, 768 read states and 24 held-stash helper cases with the
actual pinned TS helpers. These include synthetic internal
states to probe branches; their counts are separate from end-to-end histories.
144 graph-state comparisons cover last-subscriber callbacks, cascading dormancy,
pending/zombie/dead guards and exact partial state after callback throws. Twelve
lifecycle comparisons cover recompute/park/commit/cancellation, cleanup-staged
live intake, unchanged frames and flush finally restoration.
Sixteen owner teardown scenarios additionally compare state and cleanup order,
including cleanup exceptions (distinct from reactive error/status programs).
The concrete `cleanup_reentry` law executes a detached disposal array whose
second callback disposes its root. It checks both owners' death, empty child and
disposal heads, effect-cleanup detachment, exact callback order `[22,44,33,11]`
and successful completion through the active owner machine. It is a closed
regression, not a general cleanup/reentrancy theorem.
Eighteen error histories and 2,880 status-state comparisons cover synchronous
error identity/sharing, diamond propagation, rederive/verdict enqueue branches,
clearStatus masks/metadata, later tracked retry, effect error programs/cleanup,
raw versus wrapped throws, halt/report ordering and overriding finally throws.
Status probes include blocked forwards. A separate 2,880-case pending matrix
compares source-set identity/order, new/repeated/stale-link propagation, null
source, loading parks, own-flight-only landing, retained retry paths, converging
settle walks, deferred releases and cleanup throws. These are direct helper
executions over synthetic state, not promise execution. Nine additional cases check
captured Set identity and live deletion/reinsertion/iteration semantics.
The concrete `error_propagates` and `error_recovers_same_value` laws check a
source -> conditional memo -> memo -> user chain through failure and equal-value
recovery: all three status/error slots, preserved wrapper identity, previous/value
slots, reports, empty queues and restored context/tracking/running, with no halt.
These are closed regressions, not a general error/status theorem.
The `pending_diamond_retires` and `pending_other_path_remains` laws additionally
construct initialized nodes, wire a diamond, propagate a NotReady source, and
check source/error/status/blocked slots after the actual settle helper. A node
skipped while another branch carries the source can be revisited after that
branch settles; an independent carrying path preserves pending. Host async
registration, delivery and transaction landing do not participate in those laws.
Sixteen source-changing variants must be rejected. No arbitrary-value, arbitrary-
graph/history, general-error, async, or optimistic theorem is claimed. Exact TypeScript
correspondence and backend compiler correctness are trusted/tested, not proved.

## Concrete async proof extension

Five additional closed laws now check loading seed 0, later fulfillment 6, stale
object 1's ignored answer 99, object 2's committed answer 6, and an unseeded
pending diamond landing 6/7/8/15 with text 15. They use actual API construction,
callback delivery, status/graph/transaction/flush code and the mechanical tree;
settlement is an explicit external thenable input, not a native Promise timing
proof. Together with the earlier nine cases there are fourteen closed composed
regressions. Iterator and watcher semantics remain tested, not generally proved.

The old async proof fuel failure came from representing source 0x7fffffff as unary
Nat. Exact binary Question IDs repair that cost without changing source values or
branches. Three general kernel laws establish increment meaning, small-Nat
conversion meaning and reflexive equality. 4096 source counter steps, five large
counter starts, 69 provenance cases and 4103 mathematical vectors support the
representation. See [question-ids.md](question-ids.md). No generated execution
state, runtime fork or modified kernel supplies the direct new proofs.

## Current transaction milestone and next dependency

2,160 transaction-state comparisons cover source allocation/redirect/merge/join,
list/hold/frame walk, stale-reader and born-held decisions. Another 4,096 blocker
comparisons cover own-source filtering, retained link generations, truthy versus
nullish errors, zombie removal judgments and exact blocker lists. The 2,304 seam
and 48 deferred-zombie comparisons execute actual park/land, full queue ordering,
net-zero writes, cleanup-driven live rewrites and exceptional partial state.
4,096 held-operation comparisons cover signal/memo reads/writes, source unflushed
stash, frame/born-held posture, pending/error throws, recompute catches, staged
errors and error commits. Synthetic states are included; full package coverage
and arbitrary histories are not claimed.

The closed `transaction_parks` / `transaction_lands` laws construct a signal and
render callback, stage a write, and run the actual flush while a transaction's
explicit open count holds it. The text stays old while parked and becomes 6 after
closing the open count and landing. They check held slots/stamps, live and effect
queues, visible text, ambient restoration and successful completion. These laws
use an explicit transaction input, not the public action API or host promises.

1. Ordinary handleAsync thenable registration, callback delivery, supersession
   guards, settlement/rejection and loading windows now execute. Typed iterator initial drain, pumping, flattening and cancellation also execute.
   Continue with richer callbacks and active scopes. Public resolve/refresh watchers now have 158 histories and
   6,144 direct body comparisons; see [watchers.md](watchers.md).
   See [async.md](async.md) for 68 promise histories, 255 iterator histories, 18 source-only controls and
   4,096 flight-helper comparisons. Node state and next/return order are checked.
2. Preserve source behavior while extending actual async histories. Inert full-index
   hook bodies are exercised without boundary/lane/mark/store scopes; those scopes
   require their own translated engines, not an assumption that source hooks are
   absent.
3. Extend the translated transaction path to boundary/lane/action hooks and public
   scopes. Do not replace park/land decisions with waiting for all host promises.
4. Expand to typed error outcomes, loading seeds, ownership/cleanup and boundaries.
   Characterize the documented loading-seed conflict with a current-source repro
   before proposing a stronger law. No conflict is silently resolved by this port.
5. Port lanes/actions/verdict/truth as composed layers; then remaining public
   helpers, context, tracked reactions, marks, deferred/collection helpers and
   nonproduction hooks. Track every meaningful branch in the inventory.
6. Prove actual observation consistency and progress over increasing graph/program
   families, preserving source counterexamples and explicit host assumptions.

All source branches are still marked open for individual branch review, even
where a restricted function port exists. No blended completion percentage is used.

The former fifteenth law was negative evidence at the historical baseline:
`staged_error_recovery_counterexample` checked the successful-value-as-error
recovery failure. It is not a successful coherence guarantee. See
[the upstream candidate](upstream/staged-error-recovery.md) for native/immediate
controls, exact source operations and current-head/duplicate checks. Both bug
candidates are preserved; the semantic deviation register remains empty.

Default until now has 136 histories and 8192 actual source closure probes; two
closed laws check its queued falsy/true callbacks, promise outcome, root lifetime
and dependency release. See [until.md](until.md) for the default/option domain;
the current combined proof/test totals are at the top of this file.
Until's timeout/abort branches now execute for natural millisecond delays and
represented or default native abort reasons, with 60 additional option histories and
native timeout controls. Timer/listener registration and cancellation follow the
source; queued callbacks still run after a competing settlement. Arbitrary
structural signal/getter behavior and active
optimistic/truth/deferred scopes remain unfinished. No new theorem is claimed
for timeout/abort or native scheduling.

StatusError message capture now lives in runtime/error.bend rather than the host
decoder. 99 additional error histories and 50 actual constructor/unwrap probes
cover the admitted Error/DOMException data/failure paths. Existing error laws now
retain the captured message field; no new general error theorem is claimed.
The source inventory indexes constructors for future commit review.

## Callback, ownership and context dependencies

74 callback histories exercise expression reads/returns/writes/throws through
core's active read continuation, including application/error-arm finally frames.
See [callbacks.md](callbacks.md). Another 73 ownership histories cover actual
owned/detached root callbacks, owner/observer identity and exceptional ambient
restoration; see [ownership.md](ownership.md).

71 argument/disposer histories cover argument order/binding, actual effect/error
parameters, retained init-bound callable identity and the distinction between
raw function setter inputs and updater-returned function data. See
[arguments.md](arguments.md). Their closed laws exercise callback reads/returns,
captured-root disposal and invocation of a bound disposer under another owner.
Two general ABI helper laws check argument substitution and fresh root binding.

52 context histories compare fresh keys, default/undefined/null rules, inherited
copied records, entry order/aliasing, owner targeting and context errors. Two
closed laws check parent snapshots and isolated child overrides. See
[contexts.md](contexts.md). High-level component/provider APIs and arbitrary
context/key/prototype reflection remain unfinished.

24 cleanup-value histories compare onCleanup's original-function return,
canonical callable identity, LIFO order and reentrant/throwing disposal. One
closed law checks repeated registration and exactly one detached-target cleanup.
See [cleanup-values.md](cleanup-values.md).

158 nested-construction histories and three closed replacement/queue/disposal laws extend callback construction;
see [nested.md](nested.md). 55 local-signal/captured-body histories and one closed accumulator/lifetime law extend these
operations; see [locals.md](locals.md). Two general lexical-binding laws also check.
Forty escaped-accessor histories and one closed lifetime/tracking law extend
local data-signal read functions; one general lexical-accessor binder law also checks.
Eleven reentrant-setter, forty escaped-setter and fifty-one computed-accessor
histories extend the function domain. Three closed regressions check entry-value
capture and setter/computed lifetime; one general lexical-setter binder law also
checks. See [setters.md](setters.md) and [computed-accessors.md](computed-accessors.md).
Eighty-one writable-signal histories and 4,096 setMemo probes now cover the
expression-based function-initializer overload. Two additional closed laws check
manual previous-value rederivation and the preserved held-function counterexample.
Constructor comparisons total 10,752. See [writable-signals.md](writable-signals.md).
The next callback dependencies are arbitrary callable initializers and expression
reads in teardown callbacks. General closures/functions, general
returned cleanup closures, arbitrary comparator closures and active boundary/lane/
snapshot/truth/action engines remain unfinished. Missing operations are explicit
port limits, not source bugs or unregistered semantic repairs.

A third upstream candidate, [held function values](upstream/held-function-value.md),
retains twelve original source-only controls. The new writable-memo translation
now also preserves its returned-function invocation with a selected bound-function
family, sixteen paired histories and one negative kernel law. No fix has been
silently added to Bend. Open PR
[#4148](https://github.com/solidjs/solid/pull/4148) now addresses the previously
filed staged-error issue #4145; the pin and preserved counterexample are unchanged.

Selected data/writable-memo setters now register directly through onCleanup and
the same detached LIFO owner walk. Forty-two additional histories and a closed
identity/clear law retain no-argument invocation, canonical aliases and held memo
write policy. Getter cleanup, raw setter-updater calls in teardown and arbitrary
expression teardown remain unfinished; see [setter-cleanup.md](setter-cleanup.md).

Runtime-selected effect cleanup now retains actual callback returns for bound root
disposers, data/writable setters and undefined. Forty-eight additional histories
and a closed replacement/disposal law exercise the source assignment/catch/finally
order and aliases shared with owner slots; see [returned-cleanup.md](returned-cleanup.md).

Selected first-class getter/setter/root-disposer initializers now take the real
function overload and share writable-computed construction and selected setter
policy; see [callable-initializers.md](callable-initializers.md). Arbitrary
functions and read-capable owner teardown remain unfinished.

First-class named callback values now retain canonical function identity and
enter the same core call/argument, initializer and updater paths. Their imperative
teardown subset can be selected dynamically; see [callback-values.md](callback-values.md).
Read-capable teardown remains unfinished; the boundary investigation and explicit
next return points are in [the teardown review](reviews/teardown-boundary.md).

Direct disposal/effect-precleanup/recompute-preparation now suspend owner Invoke
tasks to the shared core callback machine. Thirty-five direct source probes and
a concrete cleanup-read kernel fixture check the first stage; global teardown
read admission remains unfinished. See [owner-core.md](owner-core.md).

Core publication/dead-pass trims, effect finally trims and dormant sweeps now use
owner/core return points too. Forty-nine direct probes and a second kernel fixture
retain override errors and caller restoration. Subsequent scheduler and native watcher stages are below; async/pending
callers still block global read-capable teardown admission.

Scheduler commit, parked-frame disposal, held trims and live intake/landing now
resume callbacks on the shared core driver. Sixty-four direct probes, a third
owner/core kernel fixture and sixteen seeded public histories cover these stages.
The sealed owner-boundary call-site report leaves twelve core async/pending/error
World-helper crossings explicit; it is an inventory, not a bug count.

Native resolve/refresh and until disposal now enter the shared owner/core driver
after native settlement, preserving timer/listener cancellation and partial throws.
Eighty-eight direct owner/core probes and two more mutation checks cover the stages.
The remaining frontier is async/error settlement and pending-source release; public
general expression teardown stays restricted until those callers can resume it.

## Reviewed upstream integration

Solid is now pinned at 71153bf0; the prior d2ad8b28 runtime, source and negative
laws remain on baseline/solid-d2ad8b28 (76361a4). All three tracked bug repros
verify the accepted fixes. Fifty new public histories cover the related
lazy teardown, writable error, replacement-flight and protocol changes. The two
negative laws are now positive regressions; four more closed laws also check.
See [the pin review](reviews/solid-71153bf0.md) for exact source operations,
inactive/unported branches, before/after evidence and current validation. Older
milestone paragraphs above describe their original pin unless superseded here.

The repin review also found a new upstream collector-leak regression after a
throwing pre-body cleanup. One of the 45 current concrete laws is explicitly
negative; two public controls preserve it without an active workaround. See
[SOLID-DEFERRED-RELEASE-THROW-004](upstream/deferred-release-throw.md). The candidate
is isolated on integrate/solid-next-fixes; main retains the old baseline.
