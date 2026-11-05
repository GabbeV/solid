> Current integration checkpoint: [stage 105](INTEGRATION-105.md). The normal public entry now uses the shared engine; the separate experimental build and test aliases are retired. The suite is not green, optimistic stores are not migrated, and the observation bundle still fails its unchanged size cap. Earlier test totals below describe historical configurations.

> Current checkpoint: [scalar checkpoints, stage 90](SCALAR-MILESTONES-90.md), with [stage-104 exact membership, allocation and performance results](OWNED-MEMBERSHIP-104.md). Stage 103’s cache is rejected and removed. The three scoped scalar checkpoints are complete. 472 candidate tests pass with legacy lanes disabled. The unchanged 654-test corpus reports 618 passes and 36 classified differences: 28 model/layout/expected-failure differences and eight deferred outside-read cases. The derived-guess executing-update lifetime rule is accepted; the known fresh Loading mount bug is fixed. Active optimism costs, feature size, full API/renderer integration, and stores still prevent acceptance of the broader experiment. The sections below are historical; use stage 90 for scope and stage 104 for current measurements.

# Scalar acceptance audit — active stage 36

The scalar prototype is **not accepted as complete**. This document records the
current gates; older results files describe historical stages, not remaining
work that has necessarily been resolved.

Stores are paused. Stage 27's changes and tests are preserved in
`results/store-input-stage27/shelved-store-integration.patch` and removed from
the active source/test tree. The store draft-read question is postponed.

Current evidence: 238 scalar tests pass in 24 files, including the existing
47,000 generated steps. The compatibility suite passes 5,443 tests in 320 files
(22 expected failures, two skips); normal exports still use the legacy APIs.
Sibling render-callback ordering at a shared initial commit is unspecified,
confirmed by the user and the design-document audit below. Initial observation registration can repeat an async
calculation; that cost remains to refine. Neither these runs nor the smaller
bundles establish complete correctness or performance acceptance.

## Strategy review checkpoint (stage 38; no runtime changes)

A new unresolved coordination defect invalidates any inference that the passing
scalar matrix closes this stage. The same late-mounted conditional memo can
publish during a hold only when a disjoint pending observer is active. The
prototype's optional context-discovery machinery changes the read context when
it is enabled elsewhere. This is not an accepted semantic difference.

With x committed at 0 and an action holding x=1, mount:

```ts
const text = createMemo(() => {
  const value = x();
  return value === 0 ? `${isPending(x)}:${value}` : `value:${value}`;
});
```

A scheduled render callback does not publish until x releases when run alone.
With an independently held y and a live `isPending(y)` observer, the same
callback publishes `true:0` before x releases. A held y with no observer, and an
idle observer of y, leave it waiting. Current next waits in all five audited
variants (including a pre-existing observer of x). All eventually publish
`value:1`. This does not demonstrate tearing; it demonstrates that unrelated
observation activity affects which frame the computation derives from.

`strategy-context-audit.mjs` runs each mode in a fresh process. Production
results are in `results/strategy-review-stage38/read-context.json`. The initial
scratch reduction returned assignment expressions from render callbacks, which
are interpreted as cleanup values; that invalid reduction was corrected before
these recorded comparisons. Runtime sources remain unchanged.

The split input/output representation and shared commit path remain promising.
Context discovery, update merging and pre-commit replay need an explicit common
operational model before further feature expansion. In particular, enabling or
disabling optional hooks must not change observable semantics, and prerequisite
rederivation must be distinguished from work intentionally waiting for commit.
The deferred refresh loop is evidence for that second architectural obligation,
even though refresh remains outside the supported scalar entry. Stores remain
paused. No additional per-case runtime fix was applied in this review.

## Findings from returning to the scalar core

### Publication readiness must reach a fixed point

Two action-owned sibling boundaries and an ordinary async memo suffice:

1. Inputs are 4 and 0; guesses 6 and 2 publish with label `6/2`.
2. The second action guesses 1; label `6/1` suspends.
3. The first action ends, proposing its input 4 again.
4. Before the fix, the bindings publish `4 / 2` while the label still says `6/2`.

The pre-commit hook retired the first override and queued another pure pass.
That pass discovered a stale reader/async obligation after readiness had already
been checked. The scheduler now repeats preparation and pure work until no more
preparation is requested, before committing any transaction. This reuses the
common scheduling phase and adds no node fields or version storage.

`layered-overlap.test.ts` contains the small regression. The original generated
failure, its reduction to ten operations, and the small regression's pre-fix
failure are archived under `results/scalar-audit-stage28/`. The seed campaign
combines two nested layers and a sibling, overlapping/repeated action guesses,
answers, branch changes, obsolete async results, pending readers, unrelated
writes and reader creation/removal. Every seed begins from a revealed override.
It checks actual rendered values against the shared async consequence, direct
imperative reads and late readers. It does not specify which action answer ought
to win in every possible graph.

### Correction: detached initialization is not publication

The second reported failure used an **unscheduled** new render-effect callback
as a publication oracle. That conflated synchronous initialization of a detached
subtree with attachment to the visible document. The cleanup-order question
based on it is withdrawn; no semantic decision is needed for this case.

The documented rule is explicit: synchronous initial render callbacks can run
while building the subtree; queued callbacks wait. `schedule: true` queues the
initial callback as well. See `RULES-DERIVED.md` D-19, `SCENARIOS.md` S-23,
`documentation/plans/size-reduction-carve-step1.md` §27 7g, and the root insertion
and Portal implementations in `packages/web/src`. The earlier §23 description
allowing queued render updates behind fallbacks was superseded by §27 7g.

The broad provisional creation-time hold was removed. Its patch is archived as
`results/scalar-audit-stage28/withdrawn-creation-hold.patch`. The independent
scheduler fixed-point fix above remains. The new tests that treat an owned
callback as externally observable now explicitly schedule that initial callback;
the consistency and exactly-once cleanup assertions remain. They pass without
the withdrawn hold at ownership depths one and three.

`layered-render-scheduling.test.ts` additionally tests actual DOM attachment for
ordinary and optimistic proposals: the new detached span initializes to `1`
while the connected old span remains `0`, the old owner stays alive during the
hold, and the scheduled attachment replaces it only after the async result is
ready. This preserves synchronous construction and coherent visible publication.

## Further scalar audit: Loading, errors, and the explicit entry

Loading's `on` computation previously affected its output only through an
imperative rearm and legacy lane transfer. The common layer walk had no graph
edge connecting that computation to the output. A direct dependency link now
represents the relationship. That lets the shared mechanism move the fallback
and its downstream work with the observation that selected it. No new ordinary
node fields or alternate publication path were added.

`layered-loading.test.ts` covers ordinary and optimistic inputs, no rearm,
value-based rearm, direct `isPending` and a memo wrapping it, both async completion
orders, async fallbacks including supersession, and 100 mount/dispose cycles
with no subscribers left on a surviving source. Action expiry tests now include
throwing/rejected actions and obsolete async rejection at child depths 0, 1, 3.
DOM tests check active and obsolete errors, recovery and exactly-once cleanup.

The scalar build now uses `experimental/scalar.ts`, a deliberately limited
entry documented in [SCALAR-API.md](SCALAR-API.md). It exports the shared
optimistic and pending implementations rather than exposing unimplemented
legacy APIs. Normal package exports are unchanged. An end-to-end entry test
covers nested boundaries, a repeated proposal, unrelated writes and pending.

## Shared override lifetime — accepted stage 29

The user confirmed that an incorrect optimistic value delaying downstream work
is an accepted consequence of retaining the override until its shared lifetime
ends. Current `next` already entangles the parent transactions when actions guess
the same optimistic node, including an equal repeated guess (`applyGuesses`).
Unmodified production-baseline checks verify both action completion orders and
both equal/different guesses: after the second guess, visible values are
`2 → 2 → 0` as the first and then last action finish.

The prototype now keeps selecting the override when an input answer arrives.
It joins that input update to the action scope and resumes the input when the
shared scope ends. This suppresses intermediate downstream correction without
adding action-age tracking. The explicit input join matters when an already-held
output recomputes in its own context: merely joining the ambient context to the
scope could leave the incoming update independent. An existing source/output
publication assertion caught that bug and remains unchanged.

Comparison with current `next`: both entangle same-slot guesses. Upstream can
still start a relevant input correction beneath the displayed override before
the actions finish; the prototype now delays that calculation until release.
That difference is intentional and accepted. An older tagged refetch under a
newer guess starts no downstream correction in either implementation. Functional
guesses now compose on the retained override, not a correction underneath it.

`layered-answer-order.test.ts` records the upstream comparisons and functional
composition. Two equal-answer tests now retain the upstream early-calculation
expectation only for the legacy implementation; all publication/pending assertions
remain. The fresh-proposal composition regression now explicitly guesses 3 so
it still exercises an independent new proposal; a separate regression verifies
that incrementing the retained 1 produces 2 even after input 10 has arrived.

Future semantic questions must include verified current-`next` behavior as an
explicit comparison point, with observable examples and any proposed difference.
Stage 29 evidence is under `results/joint-release-stage29/`.

## Current evidence and remaining gates

- The full compatibility suite is regression evidence; it still uses legacy
  public exports. Scalar tests and production-browser replays exercise the
  shared implementation separately. Finite campaigns are not a proof.
- Preparation reaches a fixed point by retiring ended scopes once, removing
  stale-reader markers before rederivation, and marking pending-output retirement
  before scheduling work. Newly discovered work can require another round.
  Expanded campaigns terminate; a universal termination proof for arbitrary
  dynamic graphs/user computations has not been established.
- The shared-lifetime decision removes the need for action-age filtering in
  the tested overlap case. Further boundary,
  ownership/error, effect and renderer combinations remain audit targets.
- `latest`, deferred/reveal-order integration, `refresh`, `until`, SSR and the
  full public overload/options surface are not validated. `until` and the
  outside flushed-value exception remain intentionally deferred. Stores stay
  paused. The limited entry is not feature-equivalent package acceptance.

## Current performance, size, and retention evidence

Results and immutable bundle copies are in `results/scalar-audit-stage28/`.
The ordinary 13-workload run uses seven fresh, alternating process pairs;
`write-check` compares upstream, stage 26, and the current prototype in nine
rotating triples. The plain write/flush regression repeats at about **2.7%**
against upstream and is essentially unchanged against stage 26. Equal writes
are roughly unchanged. Other ordinary cases in the broad run improve by about
2–19%; these are local microbenchmarks, not a universal performance claim.
The 2.7% regression remains an acceptance concern; no bound was relaxed.

The earlier `inactive` triple comparison, before narrowing the entry, found
signal reads about 2%, memo reads 5.5%, writes 4.8%, chains 4.8%, and diamonds
6.8% faster than upstream. Diamonds were 4.6% slower than stage 26 in that
sample, while the other cases matched or improved. That run measures an unused
optimistic boundary, not active/nested optimism. Active cost/allocation sampling
still needs refreshing before final acceptance.

Application bundles with the same selected exports (minified / Brotli bytes):

| Imports | Upstream | Current scalar |
| --- | ---: | ---: |
| Ordinary + action | 21,918 / 8,116 | 20,811 / 7,730 |
| Optimistic | 27,250 / 9,864 | 26,281 / 9,683 |
| Pending | 28,812 / 10,419 | 27,666 / 10,037 |

The explicit entry removes otherwise retained legacy initialization. These are
selected-import comparisons, not equal-feature whole-package sizes. No caps
changed. A production GC check retains zero disposed-reader payloads in both
runtimes. A single retained-size sample is approximately 1,217 bytes per callback
boundary versus 557 upstream, or 872 versus 568 with an input accessor reused;
this is consistent with the deliberately split optimistic primitive. It is not
an ordinary-node cost or an exact allocation count.

## Latest validation

The expanded scalar run after the Loading edge and explicit entry passes 173
tests in 16 files, excluding 19 legacy comparisons, including 25,000 overlapping
action steps plus the earlier 18,000-step campaigns. Subsequent targeted runs
pass the additional async-fallback, repeated-disposal and answer-order cases.
The final full suite passes 5,370 tests in 313 files, with 22 expected failures
and two skips (`full-final.log`). Type checking has
the same 26 pre-existing diagnostics, normalized identical to the earlier run.
Production Chromium F5b and composition replays pass for the candidate and
retain the observed baseline failures. Source hashes are recorded in
`source-manifest-current.json`.

No existing compatibility assertion was weakened to obtain these results.
Stage 29 supersedes the older unresolved answer-order characterization with
the accepted shared-lifetime rule; broader scalar acceptance is still open.

### Stage 29 validation

The expanded scalar run passes 185 tests in 17 files (25 legacy comparisons
excluded), including the 43,000 generated steps. The full suite passes 5,381
tests in 313 files, with the same 22 expected failures and two skips. The scalar
production build succeeds. Its ordinary/action application bundle is byte-for-byte
identical to stage 28; the optimistic and pending bundles each add 55 minified
bytes / 13 Brotli bytes (26,336 / 9,696 and 27,721 / 10,050 respectively). No new
ordinary read/node overhead or performance-acceptance claim is introduced.

## Input flights, errors, and effect timing — stage 30

`layered-refresh-lifetime.test.ts` now compares overlapping refreshes, both
answer orders, input errors before/after the body ends, a new action starting
during the previous input flight, and multiple/nested guesses in one action.
The refresh cases characterize core lifetime behavior; they do not expose or
validate `refresh` as part of the scalar entry.

The group keeps its overrides while any selected input is pending. Retiring
only one boundary had exposed `[1, 0]` where upstream retains `[1, 2]`; the
pre-publication release check now waits for the group's inputs together.
Nested input work caused by a guess in that same group also delays restoration,
as it does upstream. This is the accepted cost of retaining incorrect guesses,
not rebasing. An input error stays behind a selected override until the body's
shared lifetime ends, whereas upstream can reveal it early. Both recover on a
successful input. Production timelines are recorded by
`input-error-lifetime.mjs` and `nested-input-release.mjs`.

An input can outlive its original transaction. Resuming it through the completed
transaction stranded proposed values and left a pending observation true; the
release now joins live ordinary work. Final disposal also releases used value
boundaries' scope/proposal bookkeeping and schedules an idle sweep. A production
GC check disposes 50 roots with never-resolving inputs and retains zero payloads.
The upstream control retains 50; the earlier candidate retained its final one.
This is a narrow retained-object check, not a complete memory bound.

The expanded campaign found an additional error at seed 221: rederiving one
reader merged its holder, then the pre-publication loop continued using the
emptied holder. The loop now revisits the destination's readiness instead.
A six-operation reduction runs as a permanent regression. Initial runs whose
assertions passed but reported an unhandled rejection are failed evidence;
`merge-fixed.log` and `scalar-final.log` contain the clean reruns.

`createEffect` is now exported by the limited entry. DOM tests cover callback
execution after attachment, callbacks suppressed for superseded children, and
exactly-once frame/effect cleanup for ordinary and optimistic replacements.
Existing effect/error-phase tests also passed against the scalar compile mode.
Unscheduled render initialization remains synchronous; the withdrawn ownership
patch was not restored.

The expanded scalar run passes 197 tests in 19 files, with 31 legacy cases
excluded, including the 43,000 generated steps and reduced merge regression.
Two subsequently added upstream/prototype cases for a new action during an old
input flight also pass. The full suite passes 5,401 tests in 315 files, with
22 expected failures and two skips. Type checking has the same 26 normalized
pre-existing diagnostics. Builds succeed. This remains finite, scoped evidence,
not scalar feature completeness or a proof of arbitrary graph behavior.

Stage 30 bundles (minified / Brotli bytes): ordinary/action 20,811 / 7,726;
optimistic 26,587 / 9,768; pending 27,869 / 10,088. The same upstream import
scenarios are 21,918 / 8,116; 27,250 / 9,864; and 28,812 / 10,419. Exporting
`createEffect` changed mangled identifiers, so the ordinary bundle is no longer
byte-identical to stage 29, although its minified length is unchanged. All raw
results, reproductions and source hashes are under `results/input-flight-stage30/`.

### Stage 30 performance sampling

The refreshed 13-workload synchronous run uses seven alternating fresh process
pairs per workload (`ordinary/performance.json`). Paired medians improve by
about 5% for signal reads, 7% for memo reads, 6% for plain write/flush, 9% for
chains, and 20% for signal creation. Diamonds and effect fan-out show roughly
1.2% and 1.4% paired slowdowns. Ranges overlap substantially and timings vary
between samples; this run does not erase the earlier repeated 2.7% write
regression or establish acceptance. A supplemental nine-triple write check
compares the earlier ordinary-only bundles with the current ordinary/action
bundle, so it is diagnostic rather than a strictly identical-import comparison.
The 13-workload run uses identical imports for both runtimes.

Five fresh-process active-optimism samples measure callback-boundary depth 1/4/16
writes about 25%/17%/6% faster than upstream, and reused-accessor boundaries about
19%/29%/32% faster. Inactive ordinary reads/writes improve about 7%/2% in this
sampling. Boundary retained bytes are approximately 1,219 versus 556 upstream
for callback inputs, or 872 versus 568 when reusing an accessor. These remain
microbenchmarks and retained-size estimates, not exact allocation counts or
whole-application acceptance. No thresholds were relaxed.

## Next unresolved scalar API question: latest under a selected override

Category 3: integrating `latest` requires explicitly deciding how it relates to
the accepted selector lifetime. The production upstream characterization is
`latest-selected-override.mjs`, with output in
`results/input-flight-stage30/latest-selected-override-baseline.json`.

Start with input 0, publish guess 1, then set the input to 10 while the action
remains open. For `doubled = createMemo(() => view() * 2)`, upstream renders
`view = 1`, `doubled = 2`, `latest(view) = 10`, `latest(doubled) = 20`.
The selected-output model currently proposes 1 and derives 2 throughout that
interval. Reading its proposals would therefore give 1 and 2 through `latest`
as well; inspecting `latest(source)` could still expose the input proposal 10.

Recommendation for the upcoming integration: `latest` observes the proposal of
its argument's output. It does not traverse a selected optimistic boundary to
compute an alternative answer underneath it. New guesses can still have proposed
output values ahead of publication. Preserving upstream's 20 for the derived
memo would require early correction propagation beneath the selected override,
or another computation of the derivation; neither has been added. This API
difference is awaiting the user's answer. `latest` remains excluded from the
scalar entry, and no compatibility test has been reinterpreted as passing.

The final production Chromium F5b replay keeps every candidate reader at 1
through the second proposal's hold, including the unrelated rerun and late
mount, then publishes 2 together. Upstream still displays 2 beside `1 / 1`.
The composition browser replay likewise keeps the lower value at 0 until its
new shared consequence is ready, whereas upstream publishes 10 beside the old
label. Both browser runs report no page errors; raw timelines are archived in
the stage 30 result directory.

### Re-guess after correction begins: upstream comparison

`reguess-after-correction.mjs` characterizes synchronous and suspended
consequences, both a later slice of the same action and a new overlapping action.
The current upstream sequence computes the derivation for inputs
`0, 1, 10, 2, 10`: the second guess creates a new lane over the held correction,
supersedes the first calculation of 10, and recomputes from 10 at restoration.
An outstanding result for the superseded calculation of 10 is ignored. The
functional updater receives the displayed 1, not the proposed correction 10.
The prototype computes `0, 1, 2, 10`, retaining override selection as agreed.

The separate-action comparison also exposes an upstream lifetime difference:
after correction has removed the original override flags, the new guess's lane
is attached to the existing holder without merging the new action into it.
In the synchronous case, ending the original action restores 10 even while the
new action body remains open. The prototype keeps 2 until the second body ends.
This is an observed upstream discrepancy from the accepted shared-lifetime rule,
not a behavior added to the prototype. Both observations reproduce without any
`latest` readers; all scripts reach the final visible 10 / 20. Raw timelines are
`reguess-after-correction-*.json` in the stage 30 directory.

## Source-owned latest output — stage 31

The stage-30 selected-output question is resolved: the user agreed that upstream's
behavior is wrong here, and asked us to retain evidence for useful cases. The
latest output now reads the boundary's selected proposal. It does not skip a
retained override. A new `observation.ts` shares the previous pending lifecycle
with latest: source identity, dirty/watching sets, restoration into the input
update, and disposal. Both use `stageLayer` and ordinary publication. No fields,
lookups or layer traversal were added to ordinary signals or memos. A latest
boundary alone records its input for pending queries.

An unheld, settled latest output follows ordinary synchronous propagation. This
avoids an extra initial user-effect callback exposed by an upstream control.
A source that commits after the latest output read its old value still owes a
publication; a small regression with `latest(pendingMemo)` caught that missing
notification. Sampling now completes that publication before returning to
ordinary propagation. A tentative stale-reader registration caused a synchronous
loop and was removed; it is not in the final source.

### Evidence for useful correction behavior

[Issue #3331](https://github.com/solidjs/solid/issues/3331) reports a wrong guess's
slow consequence delaying the final result from about two to four seconds.
The [maintainer-account comment](https://github.com/solidjs/solid/issues/3331#issuecomment-5632493645)
records the correction/provenance rationale and identifies commit b5bd6fba / PR
#3370. The comment is explicitly attributed there to Claude via Cursor; this
is a recorded explanation, not additional independent maintainer testimony.
The local `spec-async-semantics` #3331 tests cover the concrete two-flight shape.

`layered-correction-waterfall.test.ts` adds a supported scalar counterpart:
action, async input memo, wrong guess 3, input answer 2, and separately gated
consequences. With the body already finished, both implementations start the
2-flight before the 3-flight finishes and can publish 2/20 first. The obsolete
3-flight then changes nothing. With the body still open, upstream starts the
correction earlier; the prototype delays it until body completion, as accepted.
This is evidence that retaining selection need not reintroduce the reported
wait on obsolete downstream work. It does not cover every ambient-guess or
async-input-overload shape from upstream.

### Validation and compatibility classification

The expanded scalar run passes 209 tests in 21 files, with 34 legacy comparisons
excluded. It includes 4,000 latest sibling/supersession/late-mount steps plus the
previous 43,000 generated steps. The full suite passes 5,414 tests in 317 files,
with the same 22 expected failures and two skips. Type checking still has the
same 26 normalized pre-existing diagnostics. The production build passes, and
`latest-disposal.mjs` retains zero of 50 payloads for both runtimes after disposing
roots whose latest consequences never resolve.

`upstream-latest-controls.mjs` copies eight upstream test files into a temporary
directory and changes imports only. It removes the directory after running.
Thirty-one assertions pass unchanged; nine fail in `latest-held-till-flush`:

- Five scalar imperative read cases rely on the flushed-value exception or
  its lazily revived observation equivalent. That exception remains deliberately
  deferred under the user's direction (category 4), not restored to turn these
  controls green.
- One scalar case constructs a tracked memo after an unflushed rewrite of an
  already held source and expects its initial latest value to be the previous
  flushed proposal. The prototype initializes it from the committed input and
  catches up at flush. This is an unresolved construction-time implementation
  gap (category 1), not justified by the outside-read exception.
- Three cases exercise stores (category 4); store integration remains paused.

These control failures are separate from the passing compatibility suite, whose
normal exports still use the legacy APIs. No assertions were weakened and the
control replay still exits unsuccessfully. Latest remains preliminary; its
first-read and nested-window contracts are not claimed complete.

### Next question: nesting observation APIs

[Issue #3104](https://github.com/solidjs/solid/issues/3104) and the local
`latest-probe-order-independence` tests document previous problems with these
windows. The standalone `nested-observation-windows.mjs` verifies current
production behavior, using an action holding x=1 over committed x=0 and a
memo `pending = createMemo(() => isPending(x))`:

| Expression | Upstream | Preliminary prototype |
| --- | --- | --- |
| x() | 0 | 0 |
| latest(x) | 1 | 1 |
| isPending(x) | true | true |
| latest(() => isPending(x)) | false | true |
| latest(pending) | true | true |
| isPending(() => latest(x)) | false | false |

Callback-wrapped source reads reproduce the same distinction. All settle to
false when the action ends. Upstream's outer latest window changes the channel
that the inner pending operation probes; it does not merely observe a pending
boolean. Recommendation: use ordinary composition of explicit outputs, making
outer-latest/inner-pending read the latest pending boolean (true here), while
outer-pending/inner-latest asks whether the latest value is pending (false here).
This is category 3, awaiting a ruling. The preliminary result is not an accepted
semantic change, and completing nested-window dispatch requires that ruling.

### Size and remaining performance gate

Ordinary/action and optimistic application bundles are byte-identical to stage
30, so this stage introduces no change to those measured scenarios. Pending is
27,987 minified / 10,168 Brotli bytes, versus upstream 28,812 / 10,419. The new
latest scenario is 27,664 / 10,062, versus upstream 28,715 / 10,368. These are
identical-import comparisons with incomplete prototype API semantics, not
feature-equivalent acceptance. The stage-30 ordinary performance uncertainty
remains; no bound has been relaxed. All stage-31 evidence is under
`results/latest-output-stage31/`.

The refreshed pending microbenchmarks use five alternating fresh-process samples.
With an inactive pending observer, ordinary reads/writes are about 6%/3% faster
than upstream in this sample. Synchronous writes to a pending-observed source
are about 4% slower; held-input workloads at depths 1/4/16 are about 4%/7%/0%
faster. These are not acceptance bounds. A unique observed-source retained-size
sample is about 1,437 bytes versus 737 upstream; per-reader reuse measurements
are approximately 508/521 versus 516/529 bytes. The candidate retains zero
disposed-reader payloads during the open-action retention check. Ordinary and
optimistic code remain byte-identical to stage 30; no ordinary measurements were
repeated just to replace the earlier performance uncertainty.

## Observation composition (stage 32)

The user accepted composition of explicit observation outputs. During an action
holding x=1 over committed x=0, `latest(() => isPending(x))` observes true, like
`latest(pendingMemo)`. `isPending(() => latest(x))` observes false when the latest
output is ready. This supersedes stage 31's unresolved nesting question.

Pending and latest callback forms now share a window stack. An outer window
observes the inner operation's output; it does not silently alter which source
channel the inner operation queries. Nested computations own their reads.
Direct accessor forms allocate no window frame; callback forms allocate one
temporary frame per invocation. Ordinary signal/memo reads are unchanged.

The adversarial tests cover a pending boolean held by its own async consequence,
latest of that boolean held by another consequence, late readers, unrelated
reruns, repeated nesting, exceptions, and supersession before either async
consequence resolves. They exposed a callback-specific retirement bug: stale
readers replayed against a still-true observation before its retirement and
joined obsolete async work back into the ready input. Observation retirement
now precedes that replay, within the existing fixed-point preparation.

An initial assertion that pending-of-pending must publish true beside a suspended
sibling latest output was incorrect about existing batching. Both current next
and the prototype batch sibling observation proposals from the same flush;
`observation-siblings.mjs` verifies this. The combined test retains that batching,
and a separate isolated test requires pending-of-pending to publish true. No
consistency assertion was relaxed.

Stage 32 passed 217 scalar tests and 5,422 compatibility tests. Type checking
retained the same 26 normalized existing diagnostics. The ordinary bundle was
byte-identical to stage 31. The five-sample callback benchmark measured median
latest callback reads at 54 ns versus 39 ns before the window-stack change and
16 ns upstream. Synchronous writes with a callback latest observer measured
983 ns versus 995 ns before and 1,588 ns upstream. These are narrow measurements,
not acceptance bounds; the explicit callback overhead is a remaining refinement
opportunity. Results are under `results/observation-composition-stage32/`.

The user's correction to the #3331 interpretation is retained: that issue is
evidence for discarding obsolete async work **after reversion is chosen**. It
does not justify when to choose reversion or propagating an input beneath a
still-selected override.

## Initial observation frames and revival (stage 33)

A new latest preview mounted while x=1 is held over committed x=0 incorrectly
derived from 0 first, then suspended before anything attached. Current next
starts from 1 and shows the new preview's Loading fallback. The same gap existed
for a new pending observation and for both observations after their last reader
had disappeared. Eight initialization/revival cases now cover both APIs,
direct/callback forms, scheduled observable publication, and completion.

New latest outputs initialize from the last flushed proposal, using the core's
existing `unflushedValue` helper. New pending outputs initialize from the same
pending sample used by their subsequent updates. Dormant source-owned observation
outputs lose their initialized frame and derive a fresh one on revival. Existing
observed outputs retain their committed frame throughout a hold. No ordinary
node fields or read paths changed.

An attempted eager update registration inside initial computation was withdrawn.
Discovering a boundary after an earlier held read could publish `[1, 1]` beside
input 0; owned-child and lazy-sibling cases demonstrated that patching only the
immediate caller was insufficient. A core-level retry experiment recovered those
cases but still repeated the initial async computation. The retained version
keeps registration in the existing publication phase and needs neither the
owner walk nor the core retry branch. New tests pin `[0, 1]` before input release,
both read orders, owned depths one and three, and lazy sibling discovery.

This currently entails two initial async calculations in the reduced Loading
case, compared with one upstream. Both calculate from the correct proposal,
and the obsolete calculation cannot publish. The test asserts the proposal and
actual Loading/content publications; it does not invent an exactly-once compute
contract. The duplicate work is recorded as an implementation/performance issue
to refine, not hidden as a semantic requirement.

### Validation and control classification

The expanded scalar and compatibility counts are recorded at the top. Production
build and initialization/revival comparisons pass. Type checking has the same
26 normalized pre-existing diagnostics. The disposal test retains zero of 50
payloads after disposing never-resolving latest consequences. A compatibility
run accidentally overlapped the temporary control-file replay; its seven missing
temporary-file errors are archived as an invalid run and a separate clean run
passes. No temporary control files remain in the test tree.

The original eight-file upstream replay now passes 38 of 40 assertions unchanged.
Its remaining two failures involve stores (category 4). The formerly failing
scalar first-read controls now pass through correct initialization and revival,
without adding an imperative flushed-world bypass or retaining another graph.
The user-authorized outside-read exception deferral remains in force generally.

Seven additional upstream observation files pass 21 of 23 assertions unchanged:

- `latest-pending-probe-mid-flight` reads a newly staged memo imperatively before
  publication and receives `NotReadyError` instead of true. This is retained
  committed-only outside-read behavior (category 4 under the accepted deferral),
  not a reason to bypass an observation's own held publication. The production
  `nested-observation-late-mount.mjs` reduction separately verifies scheduled
  publication: both runtimes produce `[true, false]` through the flight and its
  completion, with the new reader showing true after the mounting flush.
- `ispending-memo-gate-3766` publishes the correct two values together but runs
  sibling callbacks B then A instead of A then B. The production
  `initial-observation-order.mjs` comparison verifies that neither runtime runs
  either callback early. R57 in `docs/rules-mining/core-store.md:255` specifies
  parent-before-child ordering, not sibling order. The subsequent stage-34 audit
  found an explicit no-guarantee ruling, and the user confirmed that sibling
  ordering must not constrain this experiment. This is an accepted difference
  in incidental ordering (category 2), not a publication-consistency exception.
  The original assertion remains unchanged and the raw replay still fails.

### Size and remaining gates

The ordinary/action bundle remains byte-identical to stages 31/32: 20,811
minified / 7,726 Brotli bytes, versus upstream 21,918 / 8,116. Current optimistic
is 26,592 / 9,768 versus 27,250 / 9,864; pending is 28,207 / 10,234 versus
28,812 / 10,419; latest is 27,921 / 10,124 versus 28,715 / 10,368. These compare
identical export scenarios with an incomplete prototype API, not full feature
equivalence. No threshold has been raised. The earlier ordinary performance
uncertainty and callback/initialization overhead remain open. Stage 33 evidence
is under `results/latest-initialization-stage33/`; stores remain paused.

## Sibling ordering audit (stage 34)

The user prefers a defined order in principle but explicitly excludes that
requirement from this experiment. The document search found no general sibling
creation-order promise. More strongly, `packages/signals/docs/write-coalescing.md`,
"Rulings (settled 2026-07-08)", item 3, says:

> **Notification order is unguaranteed.** Deferred insertion may reorder
> same-height effects relative to today; re-pin tests that notice. Same
> posture as the effect-cleanup refactor.

That design is marked icebox; this is its recorded settled ordering ruling,
not a claim that the proposed coalescing implementation shipped. Cross-checks:

- `rules-mining/core-store.md:255` R57 specifies parent effects before owned
  children, including paths through memos. It says nothing about siblings.
- `QUEUE_EXECUTION_CONTROL.md` specifies compute before callbacks and render
  before user callbacks, with legacy lane/regular publication phases. Queue
  traversal descriptions are not a fixed creation-order guarantee for siblings.
- `documentation/plans/size-reduction-carve-step1.md:2090` records lane/own/held
  phase ordering at the seam, pinned by shell/swap lifecycle tests. This is a
  phase/lifetime constraint, not sibling creation order.
- `createEffect.test.ts:611` explicitly labels its cleanup-order assertions as
  implementation ordering, not a documented end-user guarantee. Cleanup before
  replacement side effects is still a distinct lifecycle constraint.

`sibling-mount-update-order.mjs` verifies the user's mount/update observation in
production next: sibling A reads through an identity memo, sibling B directly
reads the same signal. Unscheduled mount calls A then B; update calls B then A.
The prototype does the same. With both reading the signal directly, both runs
were A then B; the absence of a guarantee does not require order to vary.

The new controlled-gate scalar test preserves the relevant requirements: no
callback before the shared release; both exact values; each callback once.
Only their relative sibling order is unconstrained, under the existing ruling
and explicit user decision. The original upstream assertion remains untouched.
Evidence is under `results/sibling-order-stage34/`.

## Async iterator publication and cancellation (stage 35)

Five new controlled tests cover async iterable publication through ordinary,
optimistic, and latest outputs, and reuse of the same iterable with a new
iterator. They check rendered consequences, unrelated writes, late readers,
superseding held yields, stale answers and rejections, and iterator cleanup.
Only one iterator remains active. Earlier iterators close exactly once. Duplicate
initial computation can still open and immediately close extra iterators; that
cost remains explicitly unresolved rather than asserted away.

The reused-iterable test found an inherited upstream defect: an already-closed
iterator's late answer can overwrite the new iterator's published result when
both came from the same iterable object. The production comparison publishes 20,
then incorrectly 10 on baseline. The prototype remains at 20. This is an
implementation bug (category 1), not an intentional semantic change.

The fix checks the iterator's existing `completed` flag before accepting a value
or rejection, and before pumping another iteration. It adds no node fields,
allocations, or ordinary-read branch. Focused stream/iterator tests pass 18 tests
in three files. Evidence is under `results/stream-publication-stage35/`.

## Remove unused scalar lane queues (stage 36)

The scalar scheduler still allocated a lane callback queue pair even though its
legacy lane engine had been compiled out. It now skips those three empty arrays
per settle and uses the ordinary/held queues directly, preserving their phase
order. The normal compatibility entry retains its existing lane path.

Expanded scalar tests pass 238 tests in 24 files, with 34 legacy comparisons
excluded and the existing 47,000 generated steps. The compatibility suite passes
5,443 tests in 320 files, with 22 expected failures and two skips. Production
build passes; TypeScript reports the same 26 normalized pre-existing diagnostics.
The production browser replay again keeps both F5b bindings and the late reader
at the first published guess while the second guess is suspended.

Current bundles, minified / Brotli bytes (baseline in parentheses):

| Scenario | Prototype | Baseline |
| --- | ---: | ---: |
| Ordinary/action | 20,788 / 7,711 | 21,918 / 8,116 |
| Optimistic | 26,569 / 9,763 | 27,250 / 9,864 |
| Pending | 28,184 / 10,209 | 28,812 / 10,419 |
| Latest | 27,898 / 10,134 | 28,715 / 10,368 |

Queue removal saves 39 minified bytes against stage 35. These remain identical
import scenarios against an incomplete API, not full feature-equivalence claims.

Seven paired production samples per synchronous workload compare baseline,
stage 35 and stage 36 in fresh processes, rotating runtime order. Median paired
write/flush time improves 5.6% versus stage 35 and 19.9% versus baseline; chain
improves 4.9% / 7.3%, diamond 9.3% / 11.8%. Equal writes are 2.0% / 1.1% slower.
Creation is variable: signal creation is 16.2% slower than stage 35 but 6.9%
faster than baseline, despite no construction-code change. Full ranges, samples,
CPU/runtime information and bundle hashes are in `results/scalar-queues-stage36/`.
No tests or builds ran alongside those measurements. These encouraging results
and the directly removed allocations do not close the performance acceptance
gate or erase previous variation. Active/inactive optimism timing measurements need a
current comparison; callback observation cost and duplicate initial work remain.

Allocation sampling (three alternating runs, collected objects included) estimates
646 versus 514 bytes per ordinary write, and 640 versus 506 with an inactive
boundary. Active nested cases also use fewer sampled bytes in this workload.
These are sampling estimates, not exact allocation counts or retained-memory
measurements; the raw samples are archived with stage 36.

## Refresh integration audit (stage 37; API still excluded)

Baseline's quiet re-ask displays value 0 / pending false while refreshing, then
value 1 / pending false. The scalar production entry deliberately omits refresh;
an initial attempt to import it failed and established no behavioral comparison.
A separate source-built audit entry explicitly exports the existing refresh
implementation alongside the scalar APIs, in one reactive module instance.

That comparison reveals two integration gaps: shared pending becomes true during
the quiet re-ask, and after its answer arrives the refresh waiter loops in
`prepareLayers`. The same program without the pending observer completes. A
bounded diagnostic identifies the repeated reader as `watch`'s promise-delivery
computation. `watch` intentionally re-registers itself in `_reruns` to wait for
foreign publication; the layer preparation loop incorrectly treats it as a
pre-commit derivation and keeps visiting the reinserted reader. Integrating this
API requires distinguishing post-commit promise delivery from derivation work.
No diagnostic guards were added to the implementation.

These are deferred API integration failures (category 4), not accepted behavior
or passing controls. The quiet-refresh contract is documented upstream; no new
semantic choice has been made. Refreshing an optimistic output also still needs
a relative-input contract in place of the old authoritative read. No refresh
export or implementation change is included. Evidence and a reproducible audit
builder are under `results/refresh-audit-stage37/` and
`build-refresh-audit.mjs`; stage 36 remains the active implementation.
