# Active frontier

This is an incremental executable translation, not a completed package port.
[Progress checkpoints](progress.md) compare this session with c446418 without
turning test counts into a package-completion percentage.

Current verification: 3952 differential histories, 539 configured compiled mutations,
and 73 composed closed Bend regressions, plus quantified array-storage and
general payload/question/callback/path helper laws. The Bend toolchain pin is unchanged; Solid is
now pinned at b9b6f333 (declares rc.17) and the semantic deviation register is empty. See [verification.md](verification.md).

The user now explicitly requires a source-followable translation. Read
[source-fidelity.md](source-fidelity.md) for the contract and the audit of existing
substitutions. Repair these before expanding affected paths, or register a
necessary temporary deviation under [deviations.md](deviations.md). The user permits
tracked deviations to unblock progress while an issue/fix is investigated. A formal
TS/Bend equivalence proof is not required; no silent semantic repairs are allowed.

## Merged deferred/source fixes

[The b9b6f333 integration](reviews/solid-b9b6f333.md) ports #4231's synchronous
error flight retirement, with 32 additional public histories and three
quantified boundaries. Its core catch clears the active translated fault before
landing and rethrows the original error. The former closedFailure conclusion
changes with source behavior; all complete-program domains/budgets stand.
#4232/#4233 are merged and all three native-tier repros pass; their stream/from
Bend paths remain unfinished. No deviation is active. The prior 521-variant
receipt is historical; this checkpoint adds focused checks to 524 configured
variants before the planned fixed-checkout complete sweep.

## Deferred data payload generalization

[The ordinary-payload proof](deferred-payload-proof.md) extends the complete
owned constructor/event-write/flush/read program to arbitrary admitted ordinary
values: undefined, null, booleans, naturals, negative zero, NaN, strings and opaque
reference identities. Initial and proposed values may have different types.
The exact final Machine and payload are proved at every budget >=103; the numeric
specialization is checked and all old roots remain. Runtime/source/toolchain are
unchanged. There are 196 separate mixed/native controls and two kernel negative
variants that the old numeric theorem accepts. Async histories, callables and
arbitrary graphs/functions remain outside this new theorem.

## Published async errors retire the previous frame

[The 3cbfaf1a integration](reviews/solid-3cbfaf1a.md) ports merged #4228 through
existing owner/core continuations. Sixteen new public timing histories and three
arbitrary-World continuation laws cover actual error publication, staged errors
and pending transfers. A complete concrete public-API lifecycle also proves
cleanup counts 0/0/1 and a Healthy final fault. All old theorem domains/budgets
remain unchanged. Three new branch negative controls and one complete-program
proof negative control join the existing corpus. PRs #4231–#4233 are reported and
unmerged; their candidate patches remain separate. Stream refetch wrapping,
from/onSupersede, store/boundary/snapshot scopes stay unfinished.

## Latest source-only refresh

[The 1c0ff9f8 review](reviews/solid-1c0ff9f8.md) copies four verbatim store/doc
inputs after #4216. All non-store source and all Bend runtime operations are
unchanged. Stores remain unported. The native package passes 337 files /5,521
tests; latest-pin paired/kernel checks are recorded separately from the prior
514-variant run against cdd95616. The deviation register stays empty.

## Upstream refresh

[The cdd95616 integration](reviews/solid-cdd95616.md) ports #4217's landed-frame
re-derivation barrier and associated status/effect/async size refactors. Ten
verbatim inputs change; all 77 recorded Solid files match Git. Eight public
barrier/control histories and 32 multiple-deferred histories bring the public
total to 3,612. The queued callback
also has an arbitrary-healthy-World exact-step property. Existing theorem domains
and budgets stand. from/onSupersede, deferred streams, stores and boundaries
remain explicit unfinished work; the deviation register is empty.

## First-load deferred streams

[The closed-window branch](deferred-first-stream.md) now returns typed streams
through the original iterator engine; 108 histories cover drain/gap/end/error,
loading, cancellation and first-load until/refresh. The deferred corpus is 302
histories, and the whole project is 3,720. Stream refetch wrapping remains
Unsupported88; from/onSupersede and store/boundary/snapshot scopes remain open.
The 103-step data proof and all prior theorem domains/budgets stand.

## Public deferred data and thenables

[The constructor crossing](deferred.md) connects the shared closure arena,
cleanup/window, ordered done/engine observers and authoritative watch gate.
162 new histories bring the total to 3,572. A complete owned data constructor,
event write, flush and accessor read is proved for all natural payload pairs and
budgets >=103, with exact final Machine and a value corollary; 32 finite/native
controls check all prefixes. Direct streams/from/store/boundary/snapshot paths
remain unfinished. Three upstream defects have saved repros/candidate patches;
no workaround or upstream publication is active.

## Deferred lifecycle dependencies

[Flight bookkeeping](deferred-lifecycle.md) now follows the actual ask/land/end
closures, sticky loading windows, error catch and post-async value selection.
1,664 source closure/window controls plus 120 actual serve/handleAsync controls
and eight quantified boundary properties support the translation. Public data/thenable construction and callback/watch integration are now
connected; the stream profile remains open. No deviation is active.

## Deferred dependency

[The lagging-node walk](deferred-lag.md) now preserves exact first-match identity,
current dependency prefixes and source cycle handling. 4,210 private controls
and eight quantified properties, including an arbitrary-fuel whole-World frame,
check this dependency. The public data/thenable constructor now consumes this walk; see deferred.md.

## Public non-store marks

[affects scopes](affects-scope.md) now connect declarations, redirect-aware scope
recording, landing release and ambient parked/own-flight compaction. 41 public
histories and 25 private scope controls supplement seven scoped laws and a
complete all-natural 51-step mark/probe/flush/read program. Stores, boundaries,
snapshots and deferred streams remain unfinished; no deviation is active.

## Public verdict windows

[latest/isPending](verdict-windows.md) now execute their complete non-store read
path, nested catch/finally restoration and active lane crossings. 104 public
histories bring the total to 3,410; 5,322 private read programs and 44 raw
comparator controls support the source mapping. Seven scoped whole-World laws
and one complete nested-window data program for all natural payload pairs and
budgets >=53 supplement the existing guarantees. Boundary/store,
snapshot and external-source paths remain unfinished; no deviation is active.

## Public optimistic construction

[The constructor/setter crossing](optimistic.md) adds 64 public histories and
one complete quantified free data constructor/two-write/flush/read program,
plus 16 native/canonical controls. The async default path now respects lane
overrides; a public held-flight case exposed that port omission. Counts are
3,233 public histories / 72 closed regressions, plus general program laws.
Verdict windows and the excluded boundary/store/mark engines remain next.

## Flush lane crossings

[The flush seam](lane-flush.md) now calls corrections, queued application,
reveal and lane ending, preserving captured transaction and own/lane/landing
queues. 538 native complete-settle programs and five scoped properties support
this integration. Public optimistic constructors are connected above; verdict windows remain next;
public/closed counts stay 3,169 / 72. No active deviation exists.

## Lane passes and status propagation

[Lane recomputation](lane-passes.md) now connects seating/mounts, previous-value
selection, lane staging, captured-lane publication, effect queues, status
propagation and parked-frame cancellation. 7,082 native controls and six scoped
properties check this dependency. The later flush crossing is above; public
optimistic/verdict APIs remain unfinished; public/closed counts stay 3,169 / 72.

## Signed-zero payload repair

[The representation repair](number-values.md) retains negative zero through storage,
callbacks, async/error payloads and admitted arithmetic. Eleven public histories,
52 primitive controls and eight scalar kernel facts (five quantified) check it.
This fixes our codec, with no upstream workaround or source change.

## Queued guesses and seam prefix

[Queued guesses](lane-guesses.md) adds writer composition, reverse lookup,
question allocation, live application and the pre-guess reveal prefix. 3,307
native helper/callback programs and nine quantified properties check this layer,
including newest lookup over any finite prior queue. The cumulative mutation
count was 337 at that checkpoint. Core seating/publication is connected above;
flush and public constructors/windows remain next; public-history and closed-regression counts stay
unchanged, and no semantic deviation is active.

## Lane answers and actual core read/write hooks

[Lane answers](lane-answers.md) adds provenance-aware laneWrite/laneOutcome,
body-end laneCorrections and actual core setter/read crossings. frameRead and
stagedScreen now include the lane/verdict branches. 6,846 separate native
helper/core/callback controls and six scoped properties check this layer.
Fourteen new mutations bring the total to 322. Public optimistic/verdict
construction, lane application/seams and recompute seating remain unfinished;
public-history and closed-regression counts are unchanged.

## Lane lifecycle dependencies

[Lane lifecycle](lane-lifecycle.md) adds supersede, live dissolution, reveal and
nested end paths through existing commit/owner continuations. 3,496 native
helper programs, 82 callback controls and five quantified properties check
this layer. The cumulative mutation count is 308. Lane correction judgment,
application and public hook/window integration remain unfinished; public
history/closed-law counts stay unchanged and no deviation is active.

## Lane reads and raw truth comparisons

[Lane reads](lane-reads.md) adds source laneRead, stale/answered, recursive truth,
truthRead/truthConfirmed and heldNotFinal. Raw comparator return/throw behavior
stays separate from isSame containment. 2,618 native helper programs, 720 question/
provenance controls, 66 comparator controls and eight quantified properties check
this dependency. Fourteen new mutations brought the cumulative total to 296 at that checkpoint.
Public hooks/windows and lane application/reveal/correction/dissolution remain
unfinished; no public histories or semantic deviations were added.

## Latest integrated next update

[The rc.17 review](reviews/solid-5b1b7776.md) integrates six new commits through
5b1b7776, matching fetched next. #4211's falsy fallback retention and #4213's
cleanup continuation policy are ported. Forty-four new public histories and seven
new quantified cleanup helper properties check the changes. The old pin and
finally-specific behavior remain at bb82345 / baseline/solid-a2a5b6f8.
Folded optimistic-store/shared active read hooks are reviewed and stay unfinished
with those excluded engines. No active semantic deviation exists.

## Previous runtime-bearing next update

The [0222d684 review](reviews/solid-0222d684.md) integrates nine commits after
c11277e's d682022c pin. Merged #4176 and #4188 are ported in source order; original
repros now pass, and both negative closed laws become positive regressions.
The verdict-mounted pending fix #4207 is native source-only evidence because
active lane/mount scopes are not admitted. No active semantic deviation exists.

## Quantified children payload program

The fixed nested tree [first,[second,false]] now has an exact complete-machine/
World theorem for every natural first/second payload and all budgets >=128.
The proof follows the real Core.step path and existing generic path composition;
no alternate traversal, runtime change or kernel change is used. Sixty-four
separate canonical/public/native controls compare complete states and values
across four sufficient budgets. One new proof mutation rejects reversed child
order. Public-history and closed-regression counts stay unchanged. The executable
[examples/list.bend](../examples/list.bend) also demonstrates real mapArray
reorder/growth followed by children flattening and root disposal.

## Lane staging and general group mutation frames

[Lane staging](lane-stage.md) now preserves computation/effect entry/exit,
three interruption forms, shown-parent judgments and pending-effect frame refusal.
1,328 native helper programs and four quantified World properties check it.
[Group mutation laws](lane-group-laws.md) add four general whole-World link/unlink
properties and 71 separate canonical/native controls. Twelve new variants bring
the cumulative total to 275. These remain internal engine dependencies: core
hook invocation, public verdict windows, lane read/write/reveal/correction/
dissolution and boundary mounting are still unfinished.

## Lane-aware blocker integration

[Lane blockers](lane-blockers.md) now extend the shared transaction judgment:
linked peer open/own-flight/child holds, nested parent resolution, guess refetch
lifetime and saved judge restoration use one continuation driver. 1,190 native
helper programs / 29,700 judgments and four quantified properties check it.
Twelve added variants bring mutations to 263. Lane stage/read/write/seam/
correction/dissolution and public verdict windows remain the next active gaps.

## Verdict bookkeeping dependency

[Verdict bookkeeping](verdict-bookkeeping.md) now executes quiet/pending checks,
reader/root marks, conditional route/rerun/provisional judgments, observeFlight,
raw staged errors and heldLatest through the actual lane/transaction/read helpers.
2,356 native helper programs, 960 held-latest controls and six quantified
properties check this layer. Eleven added variants bring mutations to 251.
Public latest/isPending windows/read dispatch, heldNotFinal comparison and active
lane block/stage/read/write/seam/correction/dissolution are still unfinished.

## Lane identity and routing dependency

[Lane identity](lane-identity.md) now retains actual transaction allocation,
cached verdict lanes, shared group mutation/aliasing, ancestry, pass entry,
staged-reader intake and lane-dirty flags. One stagedRead body serves both core
reads and lane routing; separate truth/display helpers retain slot precedence.
1,367 native helper programs, 392 value controls and five quantified properties
support this restricted layer. Nine new mutations bring the total to 240.
Read/write/stage hooks, blockers and reveal/correction/dissolution remain open;
public verdict/optimistic APIs are not admitted by these helper results.

## Mark-engine dependency

[The mark module](affects-marks.md) now follows counts, direct/inherited coverage,
current dependency prefixes and depth-first verdict-reader repolling. 2,682
actual-source helper comparisons and four quantified whole-World properties
support this restricted dependency. Eight more compiled mutations target it.
Public latest/isPending and non-store affects are connected in the later
checkpoints above; createDeferred and store/boundary hooks remain unfinished. Public-history and closed-regression
counts stay unchanged; no semantic deviation is active.

## Next connected implementation target

[The verdict/lane readiness review](reviews/verdict-readiness.md) maps the active
read, lane, mark and deferred dependencies behind isPending/latest and the next
public async affordances. Four existing native test files / 36 tests pass at the
unchanged source pin; this is source-only validation, not added Bend coverage.
The review changes no runtime or proof claim.

## Children resolver and full-World array writes

[flatten](flatten.md) now follows source accessor unwrapping, nested traversal,
filtering, last-NotReady collection and deferred resolving closures. Sixty-six
paired histories and seven compiled mutations cover the typed production paths.
One concrete wrapper/setter/flush execution and one quantified function-only
allocation law check independently. Two further general array properties now lift existing-slot writes and append
operations to the actual array arena and exact surrounding World. Two proof
mutations target lost payloads and overwritten prefixes. General recursive children/map
histories remain open; direct map-payload-family normalization exhausted kernel
fuel and is not credited as a proof. Source/runtime semantics and kernel limits
were not changed to make that attempt pass.

## Extracted keys, index accessors and array proofs

[The key/index review](map-modes.md) closes all three production keying modes
within the typed array/callable profile. Mapper formal arity selects real index
signals; extracted keys run as original callbacks at each source return point.
Eighty new paired histories and ten finite mutation assertions cover callback
order, cached removal keys, item/index identity and updates, pending/errors and
partial writes. Five quantified storage properties prove exact holes, dense
slots, existing-slot writes and append-only allocation for arbitrary worlds.
Three closed map programs prove committed reads, retained rows, reactive index
values and final cleanup; they are not a general mapArray theorem. Two further
proof mutations check the new properties. The pin and empty deviation register
are unchanged, and the pinned fallback bug remains.

## Plain identity-keyed mapArray

[The keyed milestone](map-keyed.md) adds actual prefix/suffix matching,
SameValueZero duplicate chains, pure-removal probing/reset, window-sized staging,
direction-safe in-place suffix shifts and publication/removal order. It also
ports the separate source small-move scan/commit with its probe, 256 budget,
32-entry ledgers and duplicate safeguard. Sixty-two new paired histories and
90 separate helper/return-point probes cover normal, boundary and exceptional
paths; nine added mutations target selected missed operations. Existing proofs
are rechecked, without a general mapArray theorem. The key/index extension
above now executes; packing overflow is explicitly refused.

## mapArray by index

[The index-mode milestone](map-index.md) implements production mapArray with
keyed:false: stable item accessors, raw ownedWrite row signals, prefix updates,
stable output identity at equal length, staged tail growth/shrink, mapper abort
and source-ordered commit/cleanup. Fifty-seven new paired histories compare
actual Solid, including pending/error retries, partial writes/throws, row state,
ownership and callback/local/action capture. Eight additional mutations target
selected missed operations. Existing proofs are rechecked; no general mapArray
theorem is claimed. Plain identity-keyed matching/small moves now execute separately. Extracted
keys and index-accessor modes now execute as described above.

## Typed arrays and repeat

[The repeat milestone](repeat.md) adds executable array identities/slots and the
production repeat/updateRepeat path: retained windows, new-row staging, mapper
abort, leaving-row disposal and final publication through the existing core.
Twenty-two array and 54 repeat histories compare native Solid, including owner
trees, callback/cleanup order, pending retries, captured parameters and nested
helpers. Seven additional mutations check selected failure modes. Existing
proofs are rechecked with the extended representation; no general repeat proof
is claimed. Natural count/offsets and the typed callable/array profile are the
limits; richer array protocols/coercion and active engines remain
unfinished. This closes an implementation gap after the proof-only checkpoints.

## Pinned list-helper candidate

[The empty fallback report](upstream/empty-fallback.md) records successful falsy
fallbacks being recreated on empty-to-empty For/Repeat updates. Fourteen native
controls and twelve real JSX browser cases reproduce it, with a one-line truthy
control. The new repeat port preserves this bug and checks it against native Solid;
all three mapArray keying modes now preserve it too. No semantic workaround or general
list-helper proof is claimed. The user submitted fix PR
[#4211](https://github.com/solidjs/solid/pull/4211) from a separate upstream workspace;
the pinned source is unchanged.

## Arbitrary finite scalar-memo histories

[The new history family](memo-history-proof.md) removes the exactly-two-update
limit for the fixed equals:false signal/memo program. Three root laws check a
repeatable public update, full final World and committed view for any finite
nonempty sequence of natural proposals, with the actual constructor and
independent sufficient budgets for every flush. List induction preserves
counters, generations, trace and queued host jobs across all passes. Forty-nine
finite public programs / 1,260 prefixes and 36 synthetic steady-pass controls
support correspondence separately. General graph/effect/async histories remain
open; the runtime and source pin are unchanged.

Four further batch/coalescing laws now allow any finite nonempty number of
writes before each flush, including the first batch after construction. Actual
setter calls retain old committed slots, replace the pending proposal and
schedule/compute once per batch. Thirty-five native/canonical programs check
182 completed prefixes and 791 writes separately from the proof. The graph and
equals:false domain remain fixed; default equality and empty flushes stay open.

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

## Direct owner entry

[Direct owners](direct-owners.md) now use the existing constructor without
entering the returned owner. Its boolean self flag reaches the shared method
teardown path, including child-only clear/reuse. Twenty-five paired histories,
four quantified ambient/entry properties and one complete lifecycle execution
pass. Hydration IDs, properties/reflection and active dev/observe scopes remain
unfinished; no source algorithm or semantic deviation changed.

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
merged and integrated at 0222d684 with the original repro and positive regression.

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

## Two successive memo updates

[The two-update family](memo-repeat-proof.md) now covers every natural initial
value and both proposals, actual constructor budgets >=14, both public setters
and independent >=40-step drains. Three root laws identify the second staged
World, final World and committed values. 512 native/canonical controls support correspondence
separately. The newer arbitrary-finite-history family above removes this length
limit for the same fixed scalar graph; arbitrary graphs remain open.

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
histories and three positive concrete laws after integrating #4188.
[The source report](upstream/reaction-pending-rearm.md) records the original pending
case of #2861; its merged #4188 fix is now integrated without a deviation.
Richer callable closures and active lanes/boundaries remain
unfinished.

## Historical b0ad1df5 source update

At that checkpoint the active pin was b0ad1df5, the fetched `next` head on 2026-10-21
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
merged; its finally restoration is now part of the reviewed source translation.

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

That historical review found the collector-leak regression after a throwing
pre-body cleanup. At the current 0222d684 pin, merged #4176 fixes it and its law
is positive. The old negative remains at c11277e. See
[SOLID-DEFERRED-RELEASE-THROW-004](upstream/deferred-release-throw.md).


The subsequent [stream-refetch checkpoint](deferred-stream-refetch.md) supersedes
older Unsupported88/open-window exclusions above. It adds the actual source
wrapper, 184 public histories (3,952 total), 13 kernel roots including a complete
ordinary-payload fixed one-yield programme for every budget >=118, and ten
compiled negative controls (534 configured). Every prior complete-program
domain/budget is retained. The preceding 524-variant complete sweep applies to
9c1f2ec, as recorded in reviews/solid-b9b6f333-complete-negative.json.
A newly confirmed protocol-error bug010 remains faithfully preserved; from/
onSupersede and store/boundary/snapshot scopes remain unfinished.


The subsequent [internal supersession checkpoint](supersede.md) preserves exact
undefined/null/active flight slots and adds the source onSupersede hook through
the existing callback machine. It adds 3,456 private helper controls and fifteen
quantified roots, with five compiled negative checks (539 configured: 450 finite,
89 kernel). Public histories/closed regressions remain 3,952/73. All earlier
complete-program domains and budgets are retained. The complete preceding
534-variant stream receipt names its frozen 93de532 checkpoint; from wiring is
still unfinished and no deviation is active.
