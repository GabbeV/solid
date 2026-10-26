# Progress checkpoints

The working translation is still an incremental port. These checkpoints measure
concrete additions and checked guarantees, not a percentage of the whole package.
The earlier baseline checkpoint is c446418; the earlier action/proof session started at e6a17b5; the current continuation started at c4f0bbf; the active source pin
is 225014bf (declares rc.18). The latest integration ports merged synchronous-error
flight retirement (#4231), with 32 added histories and three quantified
boundaries; merged #4232 is now integrated in the typed stream wrapper; #4233 is integrated in the admitted direct from(fn) branch; wrapped AsyncIterables now execute too, while Observable objects remain unfinished. The earlier fallback/cleanup checkpoint
remains at bb82345. Active
store/folded-lane read paths remain explicit omissions. The deviation register
remains empty.

| Area | Starting checkpoint | Current checked work |
| --- | --- | --- |
| Public flush callbacks | No callback overload | Inline/original admitted functions, nested drains, return values, ambient scope and finally/error precedence through the shared core |
| Custom comparators | Strict/default and equals:false | Named callback programs at setter, memo publication, async landing and held-seam sites, including NotReady and ordinary errors |
| General local guarantees | Existing publication/read/signal and representation laws | 48 added quantified flush/comparator/staging/allocation/cleanup/action/transaction properties, plus seven array-storage properties and one flatten-wrapper allocation property |
| Nontrivial graph drain | Closed graph examples | Complete scalar-memo constructor and arbitrary finite nonempty write/flush history for every natural initial/proposed value, constructor budget >= 14 and each drain budget >= 40; 14-step constructor and two-step setter bridges checked; complete two-memo/render constructor/setter/95-step drain and exact final World/application trace for every natural proposal and sufficient drain budget |
| Typed actions | No public action engine | Reusable function identities, finite argument vectors without a fixed arity cap and nested parameter capture, plus typed invocation/resume, held writes, nesting/overlap, lexical capture, errors and return adoption |
| Children resolver | Unported | Typed zero-arity accessor chains, nested arrays, filtering, pending/error collection and deferred resolving wrappers through the core |
| Collection helper | Array payloads/repeat unported | Typed arrays, production repeat and mapArray keyed:false row-signal/staged-commit/abort paths through the existing core; plain identity-keyed matching and small moves; extracted keys and formal-arity-selected reactive index accessors |
| Public comparison corpus | 2,348 histories | 4,438 histories, plus separate native scheduling and finite memo-boundary controls |
| Closed semantic regressions | 56 | 73 positive regressions; two formerly preserved bugs now pass their merged fixes |
| Compiled mutation checks | 116 | 568 configured (469 finite, 99 kernel); frozen preceding sweep receipts and focused new controls are tracked separately |

Implementation additions and semantic proofs are separate forms of progress.
Differential histories compare behavior with pinned Solid; mutation checks test
whether the oracles notice selected bad changes. They do not establish the
quantified theorems. Every positive formal claim requires the independent kernel.
[Verification](verification.md) records the trust boundary and counts;
[general properties](general-properties.md) states the theorem domains and gaps.

The remaining package work is substantial: arbitrary action closures/arguments/generator protocols,
active verdict/lane/boundary/mark/deferred engines, richer
closures/protocol objects and dev/observe behavior. [The action readiness review](reviews/action-readiness.md)
records the original dependency review; [the action milestone](actions.md) now
records 120 paired histories, 21 native-generator controls, eleven local properties and three closed laws. Production flush(fn) inside an action
invokes its callback without draining; the review explicitly preserves that arm. Arbitrary graph/effect/async-history correctness remains open.
The scalar-memo family now proves any finite nonempty sequence of updates for
every natural initial value and proposal, with constructor/drain budgets >=14/40. None of the test counts should be read as that fraction of Solid completed.


The latest proof checkpoint closes the previously explicit scalar-memo boundary:
its constructor and setter are now proved to reach the staged arena, rather than
being supported only by finite controls. Two new quantified public staging/drain
properties compose the real APIs. The runtime is unchanged by this proof work.

The constructor also has a separate theorem for all natural initial values and
budgets >= 14. Three quantified merge bookkeeping properties now check open sums,
redirects and action markers in both arena directions. These extend semantic
coverage without claiming arbitrary graph or active-engine completeness.

The c4f0bbf continuation closes the reusable action wrapper gap in the typed
profile and removes the scalar-memo complete proof's fixed-initial-value limit.
It adds 45 histories, four independent native-generator controls, eight selected
compiled-mutation rejections, six quantified local action/capture properties and
one closed repeated-call regression. The new two-parameter memo family proves
both the public staging boundary and the full constructor/setter/flush program;
64 additional finite native/canonical controls are separate supporting evidence.

The reviewed d682022c update adds twelve paired effect-equality histories and
keeps two native projection rejection controls explicitly source-only. Its full
signals suite passes 330 files / 5,432 tests. Active dev diagnostics and projection
families remain outside the Bend implementation; prior integrated fixes and the
two then-preserved bugs were revalidated at that historical pin. Both are fixed
at the current pin.

The preceding checkpoint established the two-memo/render conditional 95-step
drain, exact application trace and fixed constructor boundary for every natural
proposal and sufficient budget. Its public setter bridge was still open then.
Eight finite native/canonical controls supported it without proving it. Two general
publication composition laws and two additional rejected compiled variants were
added; the runtime did not change. See [the proof boundary](chain-proof.md).

The next continuation closes that larger graph's public setter bridge. A single
subscriber iteration is checked with symbolic remaining fuel and the actual
canonical arena, then the two iterations compose at the real setter's return
points. Four public properties now connect the fixed constructor, actual setter,
complete final World, values and exact render applications for every natural
proposal and drain budget >= 95. The runtime and original kernel are unchanged.
The earlier staged-arena condition remains only on the supporting drain lemma.

The argument-vector extension removes the callable ABI's two-argument cap while
keeping internal source pair calls and the existing callback/action engines.
It adds 70 paired histories, six independent native generators/factories, eight
quantified binding/order laws and two complete nine-argument executions. Eight
additional compiled variants are rejected separately. No source pin, trusted
kernel or semantic deviation changed. See [the call boundary](argument-vectors.md).

The owner entry now exposes the already translated constructor directly, keeping
the caller scope unchanged. Boolean self=false reaches the same teardown driver
for child-only clear/reuse; the source-bound createRoot disposer remains true.
Twenty-five new histories, four quantified frame/entry laws and a complete
lifecycle execution extend coverage. Four finite mutation assertions pass. The
runtime continues to preserve the source's production dead-parent behavior.

The 0222d684 source update integrates both user-submitted fixes #4176/#4188.
Original repros and controls distinguish old/new pins; both former negative laws
now state passing behavior. Two new quantified continuation properties preserve
the exact exceptional machine and captured node. Active verdict-mount fix #4207
is checked only in native Solid because those engines remain outside Bend.

[Two successive memo updates](memo-repeat-proof.md) now compose the real
constructor, both public setters and both drains for every natural initial value
and proposal pair, every constructor budget >=14 and independent drain budgets >=40. Three new public staging/final-World/view laws
close the second-update boundary. 512 finite native/canonical controls are
separate evidence; no runtime, source pin or deviation changed.

The next list-helper audit found a source-only successful-falsy-fallback remount
case, with 14 native controls and twelve real For/Repeat JSX browser cases. It
is tracked separately from implemented capabilities and formal proofs; no issue,
PR, source patch or active semantic deviation was introduced.

The next proof checkpoint removes that fixed two-update limit. Three new root
laws establish the repeatable public update, exact final World and committed
view for any finite nonempty list of scalar-memo writes/flushes. The proof
inducts on the list while keeping clocks, generations and accumulated trace/jobs.
Forty-nine finite public programs / 1,260 prefixes and 36 synthetic pass controls
support correspondence separately. Runtime, source pin, existing history/mutation
counts and the empty deviation register are unchanged. The user also submitted
source-only fallback fix PR #4211; it remains separate from the pinned baseline.

The coalescing extension removes the one-write-per-flush restriction too. Four
further quantified roots cover pending replacement, arbitrary batch staging,
complete public final World and committed view. Both batch sizes and history
length are arbitrary finite nonempty lists, from the actual constructor.
Thirty-five native/canonical programs compare 182 prefixes and 791 writes,
including equal and net-zero batches. The runtime, source pin and prior
history/mutation/closed-regression counts stay unchanged.

The final a2a5b6f8 repin catches up with the fetched next tip. Its one additional
commit changes only release/size metadata; all 76 vendored Solid files and the
runtime are unchanged. No proof/test count is credited for a metadata-only pin.

The next implementation checkpoint adds typed array identities/slots and the
production repeat helper, with retained overlap, staged new rows, abort cleanup
and source-ordered commit disposal. It adds 76 paired histories and seven
compiled mutation checks. Existing kernel properties are rechecked after the
World extension; the 68 closed-regression count is unchanged and no general
repeat theorem is claimed. The pinned falsy-fallback bug is preserved while
#4211 remains outside the baseline. See [the implementation boundary](repeat.md).

The next implementation checkpoint closes the mapArray keyed:false profile.
Rows retain their positions while their real ownedWrite item signals update;
mappers receive stable accessors plus numeric indices. Prefix writes, output
identity, staged tail edits and error/cleanup ordering follow source. Fifty-seven
paired histories and eight mutations are added. Existing kernel claims pass on
the extended World; general keyed modes and a general mapArray theorem remain
open. See [map-index.md](map-index.md).

The next checkpoint adds the production plain identity-keyed mapArray path,
including duplicate chains, pure removals, in-place window commit and the source
small-move optimization. It adds 62 public comparisons, 90 distinct private
helper/engine-return-point probes and nine mutation assertions. Existing formal
claims are rechecked; no general map theorem is added. Extracted keys, index
accessors and active engines remain unfinished; see [map-keyed.md](map-keyed.md).

The next checkpoint closes extracted-key callbacks and reactive index accessors
for typed mapArray. Formal arity is distinct from actual call argument count;
item/index signals, key comparisons, reverse key preparation, cached removal keys
and suffix writes follow source return points. Eighty paired histories and ten
finite mutation assertions are added. Five quantified storage properties prove
hole/present distinctions, payload retention and exact append-only allocation
with preservation of arbitrary surrounding World state. Three concrete complete
map lifecycle executions and two proof-property mutation rejections add separate
formal evidence. This brings the totals to 3,048 histories, 213 rejected compiled
variants and 71 closed positive regressions. No general mapArray theorem, source
pin change, kernel modification or semantic deviation is introduced. See
[the mode/arity operation review](map-modes.md).

The children-resolver checkpoint adds actual flatten/flattenArray traversal,
both options, original callable identities and resolving closures. It adds 66
paired histories, seven finite mutation assertions, one concrete wrapper/read/
setter/flush program and one quantified allocation boundary. Full-World array
write/append theorems and two proof mutations extend the five prior storage properties.
Totals are 3,114 histories, 222 rejected variants and 72 closed regressions.
The broad and one-row map-payload-family direct proofs hit original kernel fuel
limits; they remain unproved and require decomposition. No runtime workaround,
source pin change or kernel limit change is credited. See [flatten.md](flatten.md).


The next-engine dependency review identifies active verdict/lane routing, marks
and deferred lagging as connected implementation work rather than entry-wrapper
patches. Four existing native source-only test files / 36 tests pass without
adding Bend counts. See [verdict readiness](reviews/verdict-readiness.md).


A further complete children program now quantifies both natural payloads of the
fixed tree [first,[second,false]] and every budget >=128. It proves the exact
final machine and World, including all array arenas, with the real expression
API and Core.step path. Sixty-four finite public/canonical/native controls and
one proof mutation support it separately. The runtime behavior, 3,114 paired
histories and 72 closed regressions are unchanged; there are now 223 rejected
compiled variants. A standalone executable Bend list example exercises mapping,
reorder/growth, flattening and root disposal. This family does not quantify tree
shape, arbitrary accessor chains or histories.


The next dependency milestone adds the source mark engine: direct/inherited
not-final coverage and current-dependency traversal, exact mark counts, and
source-ordered verdict/truth-reader repolling. 2,682 native helper comparisons
and four quantified whole-World properties check this module. Eight added
compiled mutations bring the current total to 231. Public isPending/latest and
mark declarers are not connected yet, so public-history and composed closed
regression totals stay 3114 / 72. See [affects-marks.md](affects-marks.md).


The following lane dependency milestone adds allocation/cached verdict lanes,
shared mutable group identities, raw parent ancestry, enterLane routing and
staged-reader/lane-dirty bookkeeping. Core and lane routing now share one actual
stagedRead body. 1,367 native helper programs, 392 value controls, five quantified
identity/value/allocation properties and nine added mutations check this layer.
Current total: 240 compiled mutations; public histories / closed regressions
remain 3114 / 72. Lane read/write/stage/seam/correction/dissolution and public
verdict/declarer engines remain unfinished; see [lane-identity.md](lane-identity.md).


The verdict bookkeeping layer now follows quiet/loading, reader/root marking,
conditional routing and provisional seam watch, ordered reruns, flight observation,
raw staged throws and heldLatest. It has 2,356 native helper programs, 960 value/
throw controls and six quantified properties. Eleven new variants bring the
mutation total to 251; public histories / closed regressions stay 3114 / 72.
Public windows and active lane engine crossings remain open. See
[verdict-bookkeeping.md](verdict-bookkeeping.md).


The shared transaction blocker now includes actual lane group/nested/guess-flight
judgments with saved judge call/return state. 1,190 native helper programs /
29,700 judgments, four quantified properties and twelve new mutations support
this integration. Current mutations: 263; public histories / closed regressions
remain 3114 / 72. Stage/read/write/reveal/correction/dissolution and public window
crossings remain unfinished. See [lane-blockers.md](lane-blockers.md).


LaneStage now executes computation/effect entry/exit, interrupted pass distinctions,
shown-parent judgment and pending effect frame refusal: 1,328 native helper
programs and four quantified properties. Four additional general group link/unlink
properties cover exact World preservation, first/absent-member behavior, cached
identity and fresh single-member self allocation, with 71 separate controls.
Cumulative mutations: 275. Public histories / closed regressions stay 3114 / 72;
active core stage invocation, public windows and remaining lane lifecycle/read/
write crossings stay open. See [lane-stage.md](lane-stage.md) and
[lane-group-laws.md](lane-group-laws.md).

## rc.17 integration

Six upstream commits reviewed; 13 changed vendored inputs copied verbatim.
Cleanup now finishes teardown/drain before first-error rethrow, and successful
falsy fallbacks retain their owner. Thirty-six cleanup-policy and eight rejected-flight public histories bring the
total to 3158; seven new scoped quantified helper properties and the updated
callback-catch continuation law supplement the existing 72 closed regressions.
This integrates source changes into implemented paths; public verdict/lane
lifecycle, stores and boundary gaps remain open. See the rc.17 review.

The overnight continuation adds seven internal lane/truth/finality source
functions, 3,404 native helper/provenance/comparator controls and eight scoped
quantified properties. This advances the active-engine dependency path while
public-history and closed-regression counts stay unchanged. Raw comparisons
retain source exception policy; no workaround is active. See lane-reads.md.

The next overnight checkpoint adds four lifecycle source functions and their
commit/cleanup/comparator return points, 3,578 native controls and five scoped
properties. Confirmation, correction, reveal and nested teardown now execute
internally. The remaining application/correction/public-hook work is explicit;
this does not change public admission or claim complete lane correctness.

The next overnight layer connects real core getter/setter branches to the lane
helpers and adds incoming-answer/body-end correction logic. 6,846 native branch/
callback controls and six scoped properties support it. The existing general
memo and chain programs still cover the same domains, with the inactive-lane
setter condition stated explicitly. Public optimistic/verdict construction and
flush/seating are still the remaining admission boundary.

Queued guesses and seam ordering now execute internally: 3,307 native helper/
callback programs and nine scoped properties supplement prior layers. The
newest-value theorem covers any finite prior guess queue. Typed queue/prefix/
mount representation extends the existing World frames. Public optimistic and
verdict admission still waits on core seating/publication/flush integration.

## Signed-zero payloads

The codec formerly collapsed -0 to positive zero. A distinct payload now follows
strict equality, falseyness, String conversion and admitted arithmetic. Eleven
public histories and 52 primitive controls compare pinned Solid; eight kernel
facts include five quantified natural-counterpart laws. Seven added mutations
brought the total to 344 at that checkpoint. This is a port repair with no active deviation; general
JavaScript numeric coercion and nonnatural repeat offsets remain excluded.

## Lane passes

[The pass crossing](lane-passes.md) connects actual recompute seating, mounts,
staging/publication/queues and status propagation, plus parked-frame heap
cancellation. 7,082 native controls and six scoped properties check it. The
source-object propagation hook was a port omission found by graph/error
controls, now translated with no workaround. Complete scalar/history/chain
claims retain their domains/budgets; the generic effect leaf now explicitly
requires the source stale/clean guards. Public constructors/windows and flush
are next.

## Flush lane integration

[The actual settle path](lane-flush.md) now connects corrections, application,
reveals and lane teardown before landing. Captured transaction and three queue
layers survive callbacks. 538 native full-settle programs, five quantified return
properties and eighteen new mutations check the crossing. Complete existing
program proof domains and budgets remain unchanged. Public optimistic creation
and verdict windows are next; no source bug or semantic workaround was found.

## Public optimistic input and setter

[The public crossing](optimistic.md) admits data/function constructors and
their actual optimistic bound setter through the lane driver. 64 new public
histories bring the total to 3,233. One complete free data program is quantified
over every natural initial/proposal triple and every budget >=56, with an exact
Machine/World result and read corollary. 16 native/canonical controls and eleven
new mutations support this addition. Default async override dispatch was a port
omission, now repaired with no source workaround. Verdict windows are next.

## Public verdict windows

[The cold read/window path](verdict-windows.md) connects latest/isPending only
after their lane dependencies. 104 new public histories, 5,322 full private
reads and 44 raw comparator controls check source order and callback behavior.
Seven whole-World finally/catch laws and one complete data program for every
natural payload pair and budget >=53 add quantified guarantees. Existing
program domains/budgets remain unchanged. Explicit boundary/store,
snapshot and external source paths remain next. No semantic deviation is active.

The overnight mark crossing adds the public non-store affects API, 41 histories,
seven scoped laws and a complete all-natural pending-before/after-flush program.
The current totals are 3,410 public histories and 455 useful mutation rejections;
closed composed regressions remain 72. These counts measure growth of checked
behavior, not a package percentage. See [affects-scope.md](affects-scope.md).

The deferred dependency checkpoint adds the actual non-store lagging identity
walk, eight quantified properties and 4,210 private comparisons. The general
frame theorem covers arbitrary fuel/work/typed Worlds. Public histories stay
3,378 at that checkpoint and composed closed regressions stay 72; public createDeferred remains open.

The aece1d44 refresh follows the new from() feature without silently enabling its
unported protocols. Thirty-two more affects crossings and six binding mutations
bring totals to 3,410 public histories /455 useful rejections. All 455 compiled
variants are rejected by assertions (384 finite, 71 kernel). The native refresh
passes 336 files /5,501 tests. Two source-only from integration defects are
confirmed with reduced JSX and Node repros, passing controls and isolated
candidate patches; see the issue register. No issue/PR has been filed and no
semantic workaround is active.


The deferred lifecycle dependency adds the original closure-local flight/mark
bookkeeping, first-held-input landing, disposal guard, loading window and source
catch. Eight quantified properties and 1,784 private comparisons check these
segments. Public createDeferred is still unfinished; the public/closed counts
remain 3,410 /72. No active semantic deviation is introduced.

The lifecycle checkpoint rejects 25 additional compiled mutations (22 finite
assertions, three kernel assertions), bringing the distinct useful total to 480
(406 finite, 74 kernel). The earlier 455-variant full run and the corrected
25-variant run cover this checkpoint's unchanged prior runtime plus new helpers.
A new complete run is also scheduled; it is not credited until completion.


The public deferred checkpoint adds 162 data/thenable histories (3,572 total),
shared closure/Set storage, ordered done/engine callbacks, cleanup and truth
reader gating. It adds an exact complete owned constructor/event-write/flush/read
program theorem for all natural initial/proposal pairs and all budgets >=103,
plus 32 finite/native prefix controls. Old theorem domains and budgets stand.
Twenty finite and two kernel mutation variants extend the corrected corpus to
502 (426 finite, 76 kernel). One previous private probe compile failure had been
mistakenly counted; its variant is now correctly typed and semantically rejected,
and the runner refuses such compiler/resource failures. The eight lifecycle
boundary laws and eight lagging laws retain their original domains. The three
new upstream bug records are unfiled; no semantic workaround is active.


The cdd95616 integration ports the next upstream landing barrier and related
core refactors without another World field or an alternate scheduler. It adds
eight public before/after/control histories, bringing the total to 3,580, and a
queued release callback theorem for arbitrary healthy Worlds and continuations.
All old domains and budgets, including the 103-step deferred family, remain.
The negative corpus is now 510 configured variants (433 finite, 77 kernel);
completion of the fresh full run is recorded in the integration validation.
The unmodified new Solid suite passes 336 files / 5,502 tests with two expected
failures and two skips. All three reported upstream bugs still reproduce.


Thirty-two multiple-deferred histories add mixed lazy/eager construction,
independent requests, both landing orders, separate and combined truth waiters,
and disposal before/after settlement. Three new compiled variants specifically
break shared Set storage, cell isolation and callback routing; all are rejected.
These bring the current public corpus to 3,612 and configured negative corpus to
513 (436 finite, 77 kernel), without changing the runtime or theorem domains.


The first-load deferred stream branch follows the source's closed-window return
through original Finish/handleAsync/iterator machinery. It adds 108 real public
histories (3,720 total), including truthy/falsey loading seeds, pending queries
and first-load until/refresh. Refetch wrapping remains an explicit omission.
The configured negative corpus is 514; the new ordinary-async-return variant
compiles and is rejected, and the entire corpus is rerun in two disjoint shards.
No old theorem domain/budget changed and no workaround is active.


A final source-only refresh to 1c0ff9f8 integrates #4216's unported store update.
All non-store sources and Bend runtime files remain identical to the verified
stream checkpoint. Native validation passes 337 files /5,521 tests. The 514
compiled negative receipt retains its cdd95616 reference pin; latest-pin full
public/alignment/kernel checks are recorded separately. No store implementation
or new theorem is claimed by this refresh.

A final quantified frame law proves that `releaseQueues`, for arbitrary Worlds
and transaction IDs, preserves every field except renderQueue, userQueue and
txArena. A compiled clock-corruption mutation is independently rejected by this
law. This supplements the complete 514-variant receipt with one kernel variant
(515 total: 437 finite, 78 kernel); no runtime change or async-graph correctness
claim is introduced.

The 3cbfaf1a runtime refresh integrates #4228's published-error frame retirement.
Sixteen new paired histories bring the public corpus to 3,736; three quantified
continuation laws and a complete concrete public-API cleanup program add to the
formal guarantees. Counts are 73 closed regressions and 519 compiled negative
variants (438 finite, 81 kernel). See reviews/solid-3cbfaf1a.md for the precise
new proof scope and retained unfinished work.


## Ordinary data without numeric restriction

The complete public deferred constructor/event-write/flush/read theorem now
quantifies over all admitted ordinary represented initial/proposal pairs,
including mixed types and arbitrary string contents/object identities. The exact
final Machine and proposed value hold at every budget >=103. A checked numeric
specialization connects it to the old program, which remains proved unchanged.
This broadens a complete-program guarantee without implementing a new runtime
primitive or changing source behavior. See [deferred-payload-proof.md](deferred-payload-proof.md).

196 mixed finite/native controls compare all 103 canonical prefixes and final
Machines at three budgets. Two new compiled kernel variants affect strings or
object references, preserve the original all-natural theorem, and fail the
broader theorem. These are separate from the 3,736 public histories; the concrete
closed-regression count stays 73. The mutation corpus is 521 (438 finite,83
kernel), backed by the prior complete 519 receipt on identical runtime/source and
two new variant receipts. Arbitrary computation functions/graphs, callable and
async payloads remain distinct proof work.


## Merged synchronous-error flight retirement

The pin advances to b9b6f333, integrating #4231 in the admitted deferred catch.
The old held flight/mark is ended before the original synchronous error is
re-thrown, and the core clears the translated active fault while executing the
catch. Four prior baseline histories now assert the fixed answer; 32 new paired
histories bring the public corpus to 3,768. Three quantified boundaries and a
small catch projection pass the kernel. The old closedFailure conclusion changes
with upstream behavior over its original domain; all complete-program domains
and budgets, including ordinary payloads, stand.

#4232 and #4233 are also merged, copied verbatim and validated in all native tiers
(60 source repro cases), with the native suite at 341 files /5,547 passing tests.
Their affected Bend stream/from profiles remain unfinished. The configured
negative corpus is 524, with the preceding full 521 receipt kept historical and
new/current affected variants recorded separately. The deviation register stays
empty. See reviews/solid-b9b6f333.md.


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


The subsequent [rc.18 source refresh](reviews/solid-225014bf.md) pins 225014bf,
reviews seven changed inputs among all 77 recorded Solid files, and preserves
the production runtime and every existing theorem domain/budget. Development
event diagnostic windows remain outside Bend. All three merged fixes and the
new protocol-error bug/control are revalidated on unchanged source-built tiers.
The current source receipt is reviews/solid-225014bf-validation.json.

The direct subscription milestone ports from(fn) closure state, real callback
invocation, coalescing and owner cleanup through the existing engines. It adds
a complete ordinary-payload owned lifecycle proof (constructor/read/dispose/flush
and exactly one unsubscribe, budgets >=120) and fourteen local World laws.
The 282 paired histories and 288 private binding controls support source
fidelity separately from these proofs. See [the scope](from-subscriptions.md).

The [wrapped AsyncIterable milestone](from-iterables.md) connects cancellation
of pending pulls to source owner/supersede cleanup, including nested wrappers.
It adds a complete ordinary-payload lifecycle proof with an unresolved inner
Promise and canceled outer pull, plus thirteen local laws. 204 public histories
and 384 separate protocol controls support correspondence. This extends
implementation and proof coverage together; arbitrary async histories stay open.

The [arbitrary-value proof extension](from-values.md) changes no runtime. Six
new roots quantify both complete from lifecycles over every R.Value and prove
their exact payload/cleanup/cancellation results, with bridges retaining the
ordinary families and sufficient budgets. 36 separate native/executable
controls check 3,708 prefixes, including function identity and self-iterable
data. Two targeted kernel variants bring configuration to 566 (469 finite,
97 kernel); the frozen 551 direct-subscription receipt is recorded separately.
Arbitrary arena-token validity and arbitrary async histories remain open.

The [Promise/cancellation preservation checkpoint](from-promise-frame.md) adds
six quantified roots without runtime changes. The longer late-push complete
programme remains an explicitly unverified archived experiment, blocked by the
pinned independent kernel reduction limit; its finite native controls pass.


## Reusable invariants and branching histories (2026-10-23)

After 65e7402, the project priorities were updated to emphasize general reactive
properties and upstream counterexamples. The accumulated frontier/fidelity/proof/
verification text is preserved under reviews/*-through-65e7402.md; those four
current documents now distinguish implementation, tests, local laws, broader
proofs and missing scope without chronological claims overriding one another.

The selected substantial milestone is a fixed rendered graph with two held
actions, branching joins/settlements and an ordinary-content visibility invariant.
It is not yet complete. Its first dependency checkpoint adds seven quantified
roots without runtime/host/source changes: certified arbitrary finite redirect
resolution and fresh-root construction, identity-preserving merges of aliases,
completion through a resolved representative with a positive open count, and
arbitrary finite lookup/rejoin histories inside an established component. The
history runner carries the actual World and proves all lookup representatives
and the complete unchanged World, rather than assuming transition equations.

28 private native-helper fixtures check 2,268 resolver queries and 252 rejoins;
84 actual Bend completion prefixes check the representative update and other
fields; a cyclic fixture faults. These are not new public histories or a proof
of reachable actions. Four compiled kernel negatives are rejected; 572 variants
are configured (469 finite, 103 kernel), with no fresh complete 572 sweep claimed.
The prior 564 sweep remains tied to its frozen checkpoint. Public/closed totals
stay 4,438 / 73. The source pin and empty deviation register are unchanged.

The remaining obstacle is constructing/preserving the action/flight accounting
and valid redirect forest through distinct-component joins and completion, then
connecting it to actual publication/render observations. The intended reader-
indexed model, environment/once-only/resource assumptions and source draft-rule
limits are in general-properties.md. No new source bug or workaround was found.


## Constructed action groups and first completion (2026-10-23)

The [join checkpoint](transaction-joins.md) moves from assumed capture/count/room
premises to real action allocation/opening and a constructed two-action family.
It proves exact distinct-root transfer at arbitrary allocated positions, derives
the pair's actual resolver bound, and carries any finite sequence of lookups and
rejoins before either action completes first through its captured identity. The
representative starts with two obligations and that completion leaves one with
source scheduling. The full World, queued work order and retained retired-source
metadata are explicit. The second/once-only completion, global live forest and
rendered publication remain open. Runtime, host, source pin and deviation register
are unchanged.

288 private join fixtures plus 32 opening-frame controls, and 48 new paired
public histories with independently authored native generators support fidelity
separately. Nine new kernel negatives are rejected. Public totals are 4,486;
closed regressions stay 73. Configured mutation totals are 581 (469 finite /112
kernel); the earlier frozen complete sweep is not relabeled.

Nested constructor elaboration first ran out of memory, and the next join
composition exhausted kernel fuel. Checked normal forms and opaque operation
boundaries remove repeated expansion; the final roots pass without increasing
limits or changing theorem domains. The user filed deferred protocol-error PR
#4248; the baseline bug remains preserved and no new source bug was found.


The [blocker connection](action-blocker.md) extends this with five quantified roots:
the actual healthy-world positive-count judgment, constructed two-action and
arbitrary finite pair-history judgments, and the corresponding judgments after
either first completion. The complete post-completion World/judge is preserved.
The existing public/native controls still pass; private controls add 320 positive
judgments and the broad 1,190-program blocker alignment passes. Two more kernel
negatives bring configuration to 583 (469 finite /114 kernel), without a new
full-sweep claim. The second completion, zero-debt eligibility and rendered
publication remain open. No runtime/source/host change or new Solid bug occurred.


## Both joined completions and settled-yield preservation (2026-10-23)

The [completion extension](action-completion.md) adds seven active roots. Two
actual action allocation/opening prefixes and either join direction now support
both completion orders, with arbitrary finite original-ID lookups and same-group
rejoins before, between and afterward. The checked constructed certificate holds
the full World equality; its generic corollary gives zero representative action
debt while preserving the retired source's stale count and both scheduling effects.
The independently checked wait-list invariant preserves a settled yielded-value
callback through arbitrary finite append/settlement histories and connects this
to the actual duplicate guard, retaining World/continuation/stack exactly.

The full once-only action/flight protocol, intervening writes/settlements/disposal,
global forest/live-list validity and rendered publication remain open. Existing
public/native/private controls pass. Four new kernel negatives bring configured
variants to 587 (469 finite /118 kernel), without a new full-sweep claim. A separate
guard-bypass mutation hit the RSS limit and is not credited. An indexed certificate
avoids repeated constructor unfolding that exhausted kernel fuel; its result field
and construction are checked without changing runtime or kernel limits.
No runtime/representation/host/source changes, new Solid bug or deviation occurred.


## Empty completed-group eligibility (2026-10-23)

The [eligibility extension](action-eligibility.md) adds the general actual false
blocker contract for a healthy ordinary transaction with zero actions, no owned
nodes and no live lanes. It preserves the full World/judge using the existing
public budget. A constructed certificate supplies the transaction premises after
both actual completions in either order, including arbitrary finite pair
lookup/rejoin histories; initial health and empty live lanes remain explicit.
Forty-eight paired private empty-group controls and the existing public/native
histories pass. One additional kernel negative brings configured variants to
588 (469 finite /119 kernel); no full-sweep claim. The nonempty owned-node/flight
and lane branches and actual rendered publication remain open. No runtime,
source, host, toolchain or deviation changed, and no new Solid bug was found.


## Held groups reach the actual landing scan (2026-10-23)

The [landing scan contracts](action-landing-scan.md) add two roots. A selected
healthy positive-debt group is retained by the actual scan with complete World,
caller stack, frame and next scan position preserved. The constructed group after
either first completion supplies that positive blocker after arbitrary finite
pair lookups/rejoins; its selected live-list lookup is still explicit. Global
live-list/forest preservation and the full renderer theorem remain open.

Private controls add 288 actual held-scan checks and 48 actual empty landing-entry
checks. A direct general empty-preparation theorem exceeded kernel fuel and is
not credited; those 48 outcomes remain finite evidence. One more kernel negative
brings configuration to 589 (469 finite /120 kernel), without a fresh full sweep.
A fresh fetch/impact review of next@b4d8e6bb reports no signals drift; only the
canvas example changed. No runtime/host/source/kernel/deviation change or new
Solid bug occurred, and #4248 remains separate and open.


## Nonempty rendered snapshots at zero action debt (2026-10-23)

The [nonempty blocker contracts](rendered-blockers.md) add five active roots.
A pending on-screen owned render node keeps the actual zero-action group blocked;
the public budget is derived from the arbitrary inactive prefix, the complete
World/judge is restored, and the real landing scan retains its World/stack/frame.
Terminal membership is proved through actual lookup/compression, and subscriber
generation/validity contracts prepare the memo path. Construction of this graph
from callback bodies and preservation through completion/settlement remain open.

One hundred forty-four independently authored native-generator/Bend action-flight histories
cover all six completion/flight orders, both creation orders, opaque/text/nullable
values and independent publication (1,368 prefixes). No runtime/host/source/kernel
change or new Solid bug; two focused kernel negatives and one finite negative extend configuration to
592 (470 finite /122 kernel), with no fresh complete sweep.


## Nonempty rendered snapshot preservation over histories (2026-10-23)

The [new completion-prefix history](rendered-completion-history.md) proves any
finite branching sequence of source completion prefixes and blocker checks from
an explicit pending rendered snapshot. Real decrement/schedule steps preserve
owned work, node/link/extension storage and committed trace; every actual blocker
check returns true. The indexed certificate retains exact audit/World equality
and final snapshot/health. Initial callback-body construction, flight settlement,
full once-only action/result protocol and final publication remain open.

Six new roots, 48 actual Bend zero-debt blocker checks and 48 retained scan checks
on public-history snapshots are added. The 144 native rendered-flight histories
are retained. One kernel trace-frame negative and one finite owned-work negative
are rejected; configuration is 594 (471 finite /123 kernel), no fresh full sweep.
Runtime, host, pin, toolchain and limits remain unchanged; no new Solid bug.


## Real list construction supplies rendered ownership (2026-10-23)

The [list entry contracts](rendered-list-construction.md) now construct the
pending history's captured membership and owned-node layout through the actual
source operation at physically allocated nonzero group/extension slots. A fresh
node is appended after an arbitrary inactive prefix, preserving the arbitrary
group record, and the history starts from this real resulting World. Four roots
include the exact same-capture no-op. Initial pending-status/render/posture facts
and the complete callback/parking/flight-delivery/publication path remain open.

Fifty-four paired native/Bend private fixtures and 162 exact re-listings pass;
pending status is installed explicitly in the fixtures. Three finite mutations
are rejected; configuration 597 (474 finite /123 kernel), no new complete sweep.
No runtime, host, representation, pin, toolchain or semantic deviation changed.


## Writes retain committed observations across arbitrary storage (2026-10-23)

The [staging frame](committed-staging.md) adds six roots over arbitrary represented
payloads and finite node/link storage: actual heap/notifications, stage replacement,
held joins/default comparison and arbitrary finite helper-write histories retain
all committed values, the rendered tree and event trace. An active ordinary core
post-updater setter bridge retains the observation and returns the real argument
on its machine stack. Fault/exhaustion behavior is retained, not proved successful.
Full pending/membership preservation through writes and complete queued flush/
flight publication remain open. No runtime/source/toolchain changes.

Existing 203 differential graph/write scenarios and 68 Promise histories pass.
Two kernel record-store negatives and one finite premature-publication negative
are rejected: configuration 600 (475 finite /125 kernel), no new complete sweep.
No new Solid bug or semantic workaround was introduced.


## Fulfillment reaches an exact queued continuation (2026-10-23)

The [fulfillment-prefix contracts](async-write-prefix.md) add seven roots. Actual
status/source bookkeeping and the default core arrival retain all committed
values, tree, event trace and caller stack, while stale result identity gives an
exact World no-op. The returned machine retains optional owner trim, settlement,
schedule, flush, captured continuation and caller work in source order. Execution
of that tail and coordinated final publication remain open. A proof-only generic
projection was specialized for the pinned kernel without narrowing payload/World
domains or changing runtime/limits.

The retained 144 native-generator histories pass. Ninety-six forked actual prefix
calls, including 24 queued owner trims, check independent pre-observations and
nonempty stacks on public-history snapshots. Two kernel tail/stack negatives are
rejected: 602 configured variants (475 finite /127 kernel), no fresh full sweep.
No new Solid bug or semantic workaround was introduced.


## Live scan position derived from construction (2026-10-23)

Seven roots now derive the representative's actual live-list occurrence and scan
position through actual action opening/join, any finite pair lookup/rejoin history
and either first completion. Callers no longer supply that lookup for this family.
The checked result carries the exact held scan machine certificate. General live
membership/forest validity and queued publication remain open. Fourteen paired
native/Bend controls, two absent-source source-behavior controls and two focused
negative variants pass; configuration 604 (476 finite /128 kernel), no new full
sweep. Runtime/source/limits unchanged; no new Solid bug or workaround.

Across this approximately two-hour continuation, six checked milestones extend
pending rendered graph histories, actual list construction, committed staging
and fulfillment-prefix frames, then derived live scan selection. The public
comparison corpus is 4,630 histories; 73 closed regressions remain retained.

Certified rendered completion/check histories now preserve the whole live list,
carry an initial occurrence forward and derive the final held scan on the actual
audit World. No final lookup/count/blocker premise is supplied. The full public
test command passes.

The continuation adds 35 active proof roots and removes none of the earlier
roots. This is supporting accounting, not a package-completion percentage.

Ninety-six additional actual-native-generator/Bend action-rejection histories
pass and are retained: all settlement orders, either rejecting action and both
creation orders, with direct/memo-backed render and independent work. The selected
suite now has 240 histories /2,280 prefixes; public corpus 4,726. Rejection remains
outside the quantified completion/check theorem. No new source bug was found.


## Merged fixes restored before settlement proofs (2026-10-25)

Solid is refreshed from 225014bf to 2a0da2fc (rc.18). #4248 protocol-flight
retirement is integrated and bug010 is marked fixed with its earlier evidence
retained; #4250 supplies no-value status on first-error re-asks. The native repro
now passes all 120 three-tier cases and all six JSX cases. Twenty-four new public
histories bring the corpus to 4,750; private status coverage expands to 6,144.
Two catch-scope roots retain earlier domains and 103/118 sufficient bounds.
Four new finite negatives are rejected: 608 configured (480 finite /128 kernel),
no fresh full sweep claimed yet. No active deviation or kernel/limit change.

## 2026-10-25 — Actual pending continuations

After syncing the upstream integration at 83b633b2, added ten roots for actual
settlement/schedule caller-stack contracts, captured owner-release continuation,
self-settlement and finite-prefix induction over actual Core.step. Constructed a
nonempty prefix without assuming the desired stack equation. Retained 456 earlier
roots and all earlier domains. The modified existing public-history controls
execute 120 prefixes /880 steps to the queued flush; four kernel negatives reject
targeted stack/capture/source faults. A general settlement storage-frame proof
still hits kernel reduction fuel and is archived unverified; runtime/source/limits
unchanged. Owner release, graph progress and final publication remain open.

## 2026-10-25 — Owner continuation and local completion

Expanded the actual-step caller-stack induction to structural owner queue heads.
Four new roots prove owner-step stack retention and construct/finish a healthy
no-stale dependency trim in exactly two steps with the whole World and caller
continuation unchanged. All 160 forked arrivals now execute 1,360 actual steps to
their queued flushes; 40 trim returns preserve the exact machine. Three new kernel
negatives are rejected. The complete frozen608 sweep on 83b633b2 also finishes:
all named variants rejected, all 798 tracked sealed hashes unchanged. Corrected
an earlier explanation about direct cache-value clearing: source unobserved
bookkeeping retains `_value`; arbitrary cleanup bodies remain a separate boundary.
No runtime, source, limits or semantic deviation changed. Full graph progress and
coordinated publication remain open.

## 2026-10-25 — Selected observation and canonical list ABI

Added eight selected text/application laws, including positive visibility and an
actual independent apply-step frame. The ordinary async arrival also retains the
selected observation through the prior committed frame. Distinct mechanical
targets and 80 real private apply steps now complement 2,280 native-backed public
text observations. The probe exposed malformed Cons lists in four private-control
files; the actual emitter uses Con. Added ABI-derived encoding and strict decode,
reran the full public/alignment suites, and qualified the old608 receipt's seven
affected finite variants. Typed proofs were unaffected. No runtime/source/limits
or semantic deviation changed; general graph construction and final publication
remain open. Four new kernel negatives are rejected; a fresh corrected sweep
follows on a frozen checkpoint.


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

## 2026-10-25: final next refresh and idle-disposal guard

Reviewed four further next commits and repinned 77 exact inputs to 4ea2f498.
The production owner guard follows #4254, with 64 paired controls and two new
local kernel roots (562 to 564). Native build/types and 344 files / 5,579 tests
pass. Full rebase seal and execution results are recorded with this checkpoint.
No new upstream bug was found; physical GC remains outside Bend semantics.

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


The evening [actual method-return checkpoint](action-body-return.md) adds nine
composed roots649->658: general output/stack and route transport, two-step literal
body completion, captured resume, constructed retirement after arbitrary admitted
helper prefixes, retained stale-callback guards and zero debt through suffixes.
The source's group retirement precedes returned-Promise adoption. Full public
protocol reachability, real body writes, flight accounting and queued publication
remain open. Runtime/source/host and budgets are unchanged; malformed negative
oracle failures receive no credit, and unchanged kernel oracles must pass first.
