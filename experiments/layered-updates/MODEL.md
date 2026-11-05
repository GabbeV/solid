# Shared scalar update experiment

Baseline: `a24e911ba5e571e7adb1c9b5e5151261f9cf101c` (`next` snapshot).
This is a local experiment, not a proposed replacement ready to merge.

Performance reporting: user-facing claims compare only against the pinned,
unmodified `next` baseline above. Comparisons between experimental revisions
are diagnostic and must not be presented as performance wins. Fresh stage-49
baseline comparisons are in `results/status-against-next-stage49/`; distinguish
the reference model from the production experiment in every report.

Latest implementation: [stage 60](STABLE-60.md) adds an isolated self-contained
stable-context scalar engine and accessor adapter. Hidden input propagation stops
at active overrides while observation forwarding continues. The four previously
failing fetch contracts and 18 new targeted tests pass; broad run 232 pass/4
historical context-relocation expectations fail. An async-function suspension
bug was found and fixed. The reference fails measured ordinary performance:
updates approximately 9–16x next and sampled allocation 11 KB versus 650 bytes.
Restricted bundles are smaller but lack API parity. Keep it as a correctness
reference; a compact runtime implementation is still needed. Production sources
and stores remain unchanged. See the stage document for exact snapshots/limits.

Previous theory review: [stage 59](RETRY-OPTIONS-59.md) evaluates limited retries,
stable contexts, numeric strata and broader revisable entanglement. Shared
publication machinery remains viable; strong unrelated-peer equivalence still
conflicts with avoiding late join reversal under hidden ancestry. Depth is not
ruled out, but dynamic speculative depth already failed. No semantics or runtime
changed by this review.

Previous analysis: [stage 58](LOCAL-CONTEXT-58.md) separates local calculation
repair from later reinterpretation of producer proposals. Pinned next can read
`x(), view(), x()` as `1,10,0` in a speculative body, then repair before
publication. A historical retry loop arose when no committed fallback existed.
Read-time local retries with stable producer contexts are a candidate direction,
not an implemented solution; assigning those contexts across hidden nested
dependencies remains open. [Stage 57](LOCAL-RETRY-57.md) records the initial
request comparison. Neither investigation changes the coordinator.

Latest acceptance gate: [stage 56](FETCH-SELECTION-56.md). Dependency discovery
alone must not change the input versions of an already-started fetch. The current
reference fails all four new request-history contracts, even when action lifetime
keeps publication coherent. A public-API audit confirms `10:20 -> 10:0 -> 10:20`
request selection without new view/peer proposals; pinned next keeps its original
request in that audit. Historical tests expecting such discovery-driven rewrites
are no longer valid acceptance targets. No scheduler or production source was
changed; `.contract.mjs` is an explicitly failing gate outside the old glob.

Latest constraint: [stage 55](DEPTH-DISCOVERY-55.md). The user considers depth
priority acceptable only if later dependency discovery cannot retrospectively
remove a blocker from an otherwise-ready optimistic proposal. Explicit writes,
completion/reversion can change eligibility. A small audit falsifies the current
reference's pending-origin depth promotion for explicit-clear boundaries. A
committed-depth-only shortcut avoids that promotion but over-holds after the
peer finishes, so it is not accepted. Main reference and production code remain
unchanged; stable proposal-context assignment is a design gate, not a solved fix.

Latest investigation: [stage 54](DIRECTED-54.md) replaces global depth ordering
in an isolated reference alternative with actual boundary relationships and
peer joins. The user clarified that an optimistic output over a constant and
an unrelated signal should entangle as peers. Stage 53's generic higher/lower
interpretation was too broad. Nine focused planner/runtime tests pass; the broad
alternative still has real lifecycle and crossed-publication failures and is
not ready to port. A sequential crossed-child case now needs clarification about
whether later work can revise an earlier peer join. Both production checkouts
and the main stage-53 reference remain unchanged; older pass counts do not
validate the new relation model.

Latest semantic checkpoint: [stage 49](SEMANTICS-49.md). Observed optimistic
outputs now forward observation to their inputs without joining the override's
publication to them. Observer removal and action input waiting share that rule.
The implementation uses boundary-only indexing and a temporary readiness cache;
ordinary reads are unchanged. The new coordinator remains unported, and neither
performance nor size acceptance has been established.

Latest implementation work: [stage 50](PRODUCTION-50.md) attempted and rejected
the production observation port. Same-action nested guesses expose lost proposal
origins before async discovery; separating transactions locally then breaks
ownership/publication tests. Production sources were restored unchanged.
[Stage 51](INCREMENTAL-51.md) retains incremental obligation discovery and queued
same-source coalescing in the reference. Its 180 tests pass (131 current-model,
49 historical), but fresh next comparisons still show roughly 9–15x ordinary
update cost. This is not a performance-passing implementation. The next port
must keep sparse pending origins separate from storage ownership from the start.

Latest isolated port: [stage 52](ORIGINS-52.md), in `/workspace/layered-origin`.
Origin assignment is separated from parking and restores the focused nested
guess and detached-child cases, but broader composition remains incorrect.
The stage-52 arbitration question was resolved in favor of immediate combined
preparation with coherent publication, independently of the guessing action's
lifetime. [Stage 53](COMBINED-53.md) implements it in the reference, with 205 tests
passing (including historical tests), cancellation-obligation retention, and
preparation of fresh lower work before fresh optimistic contexts. Main and
isolated production sources are unchanged. A further question remains: when a
joined lower proposal becomes pending again, should a fresh guess regain
independent publication using the committed input? The current reference retains
the join and waits; this behavior is explicitly awaiting a ruling.

Latest production checkpoint: [stage 46](PRODUCTION-46.md). The core now retains
committed dependency structure with optional sparse bookkeeping. A peer-gate
coordinator port failed consistency tests and was removed; its code and traces
are preserved. Coordination replacement and feature-bundle size acceptance
remain open. Historical statements below describe their respective checkpoints.

## Coordination rethink after the stage-38 audit

This section is a proposed direction, not an implemented or user-approved
replacement contract. The sections below preserve the experiment's history;
earlier lifetime/API descriptions are superseded by later accepted decisions.
Runtime sources are unchanged by this theory review.

Keep the split input/output boundary and common proposed/published frame. Rework
coordination around explicit evaluation contexts and read obligations rather
than inferring permission opportunistically from whichever hooks are active.
An evaluation context specifies which proposals a computation may consume and
which pending inputs it observes at their committed values. It is not a numeric
priority, a globally authoritative world, or another copy of the reactive graph.

Three responsibilities must remain distinct even if their representations share
storage: action lifetime determines override expiry; a publication group owns
proposals that must land together; an evaluation context determines reads. An
optimistic output can publish before the action that owns its override ends.

Two read relationships drive the common scheduler:

- Consuming a compatible peer proposal joins publication groups. Ordinary
  updates sharing a memo continue to entangle and immediately calculate their
  combined proposal. Sibling optimistic proposals can join in the same way.
- Observing a held input's committed value through an explicit boundary does
  not join its update. It creates a revalidation obligation: before that input
  publishes, affected ordinary derivations must be reconsidered, and any new
  async work must hold the appropriate publication. Merely receiving a
  notification does not consume a proposal.

The published output of an active boundary must convey this relationship through
ordinary derivations too. Whether to represent that through sparse frame metadata
or derive it from frame dependencies remains an implementation question. Any
cache or optional hook must be semantically interchangeable with its uncached
operation. Do not add version maps or general layer traversal to settled reads.

### Discovery is unavoidable, but its policy must be explicit

The bodies `() => [x(), isPending(x)]` and `() => x()` have the same first read.
If x has a committed answer but its next async answer is pending, immediately
throwing on that read prevents the first body from discovering its boundary.
Keeping read-order independence therefore needs provisional execution, a changed
contract, or explicit dependency declarations. Choosing every context before
running arbitrary user code is not a complete solution with the existing API.

Candidate policy for a new computation without an inherited context: discover
against committed held inputs, record tentative reads, and validate whether the
body actually encountered a boundary supporting those reads. If supported,
continue in that boundary's context. Otherwise compute the ordinary proposal
and join its inputs. Never publish an unvalidated result, its error, or its
scheduled owned effects. Returned async work becomes eligible only after
validation; the function may already have started external work, so retries
remain a real cost and must be bounded and measured.

This would make the stage-38 conditional example publish `true:0` consistently,
including without an unrelated pending observer. Current next waits. The user
has since allowed a natural reduction in mount entanglement if it simplifies
the model, without asking us to remove entanglement for its own sake. That
latitude also permits investigating a simpler committed mount without boundary
discovery. It does not establish the candidate policy above as the contract.

The converse conditional is an essential check:

```ts
const text = createMemo(() => {
  const value = x();
  return value === 1 ? `${isPending(x)}:${value}` : "idle";
});
```

With committed 0 and held 1, published-first discovery sees no boundary. An
ordinary proposal can discover one using 1, but that must not repeatedly justify
switching to 0, losing the boundary, and switching back to 1. Observation found
in a proposal is not automatic permission to publish the ordinary input that
made that observation reachable. This needs an explicit eligibility/validation
rule; a retry-until-it-looks-consistent loop is insufficient. Owner-inherited
contexts and newly selected branches must be checked alongside this case.

### Publication protocol to test next

Keep one eligible proposal/async calculation per memo. A conflicting selected
context supersedes that proposal; obsolete answers cannot publish. Lower work
can require recalculation later, not a preserved duplicate graph.

Separate preparation from delivery: proposal computations and committed-input
revalidation are pre-publication prerequisites; render/user callbacks and
promise delivery waiting for a foreign commit belong after publication. The
refresh waiter loop is evidence that these cannot share an undifferentiated
stale-reader queue. Supporting refresh's full API is a separate question.

A progress argument should cover finite, non-self-writing reactive work: each
preparation step must process a new invalidation, resolve/merge an obligation,
or wait for an external answer. Self-reinserting a post-commit waiter is no
progress. Pending observations also need a causal distinction between the work
they report and work holding their own output, to avoid status feedback.

Next validation should compare equivalent graph/read arrangements, not merely
add random timeline seeds: read order, identity memos, conditional boundary
discovery in both directions, disjoint active observers, late mounting, and
owned children created before the first tentative read. Establish the rules on
a small reference model before choosing production bookkeeping. This is not a
proposal for duplicate graphs in the shipped runtime.

### Working agreement: regular reassessment

The user explicitly requested periodic architectural reevaluation and early
notice when further reflection is warranted. Reassess after each coherent
implementation batch and before expanding the supported primitive set. Pause
and tell the user sooner when a fix introduces a new scheduling phase or
exception, unrelated activity changes semantics, two fixes conflict, or progress
depends on weakening an invariant or moving an acceptance boundary. Report what
was simplified or deleted as well as what now passes. More green tests alone
are not evidence that the architecture is converging.

## Stage-39 reference-model checkpoint

The separate [reference experiments](reference/README.md) now have 35 passing
protocol tests. A 10,000-snapshot conditional search and a reduced disagreement
show that supported read contexts are not necessarily unique. Narrowing gives
a bounded policy, but carries extra selection semantics and repeats user code.
It is not the recommended algorithm to port to the runtime at this point.

The next direction is to select frames from the cause of evaluation: independent
mounts read committed inputs, preparation reads the selected update frame, and
children inherit a preparing parent's frame. A shared-frame probe confirms the
need to retain lower work obligations after supersession and rejects old answer
tokens; it deliberately leaves arbitration to its caller. This is not yet a
scheduler, and there is no claim that general coordination has been solved.

Keep the input/output split and common publication frames. Reevaluate the
context-discovery adapter rather than adding more reachability exceptions to it.
The main runtime is unchanged; stage-38 remains an open implementation defect.
See the reference README for limits, concrete timelines and falsification gates.

## Stage-40 automatic scheduler checkpoint

The [separate operational scheduler](reference/SCHEDULER.md) chooses preparation
and publication automatically. Its 21 passing tests include real promises,
owned reactive nodes and cleanup, plus a 300-write finite async-diamond campaign.
Ordinary and nested updates use the same candidate/publication mechanism.

A late-discovered peer join exposes traversal-dependent update membership: both
observed intermediate frames are coherent, but one publishes a sibling with a
child while the other retains it below that child. This is an unresolved semantic
question, not a proven tear or an accepted contract. See the checkpoint for the
small timeline, next/prototype comparisons, implementation limits and remaining
falsification gates. No runtime code was changed for this model.

## Accepted clarification after stage 40

If c is above a and a entangles with b, c's ability to use committed lower values
extends to b. This must behave uniformly when a and b are ordinary signals or
optimistic outputs. The user explicitly answered yes. Keeping publication links
separate from hierarchy is not a reason to choose next's waiting behavior in
this case. The stage-40 traversal discrepancy is therefore a model defect to
resolve, not an open choice to accept either frame. Distinguish implementing
this closure over known joins from discovering a lower join before an eager
upper join obscures it. See reference/SCHEDULER.md for the recorded timeline.

## Accepted crossed-child rule and stage-42 experiment

The user approved both children publishing over committed parents in the crossed
c+b / d+a graph, without requiring a prior a/b entanglement. The new
[layer-position experiment](reference/COORDINATION-42.md) satisfies this and the
earlier operational tests while removing provisional join reconstruction. It
is not yet a complete layer model: counting an inactive optimistic wrapper as a
layer changes publication compared with next and the existing prototype. The
checkpoint records the exact program and measurements. The inactive-boundary
question was subsequently answered below.
The production runtime remains unchanged.

## Accepted inactive transparency and stage-43 experiment

An optimistic boundary must be completely transparent whenever it has no active
override, including after a previous override expires. Declaration nesting alone
must not change which updates coordinate or which values ordinary readers see.

The [active-selector experiment](reference/COORDINATION-43.md) implements this
rule in the operational model. It tests starting and ending parent overrides
while children are suspended, shared sibling derivations, inactive wrappers at
several depths, and real owned selectors. Pending peer groups can separate or
join as the selected layers change. The model still retains only one committed
frame and one eligible candidate per node. Ordinary dependency-frame checks
avoid recomputing an unchanged output for obsolete lower notifications.

49 tests exercise this scheduler; the full reference suite has 98 passing tests.
This is not a production acceptance claim. Action lifetime integration and lazy
pending/observation context discovery remain gates before a runtime rewrite.
Production performance, bundle size and the stage-38 defect are unchanged.

## Representation under test

The latest operational checkpoint is [stage 45](reference/COORDINATION-45.md).
The consolidated engine and limited scalar API adapter pass their current
correctness tests, but the direct representation fails the performance gate:
ordinary writes remain roughly 10–17x baseline and ordinary allocation is much
larger. Reusing the existing ordinary core with sparse boundary coordination is
the next implementation direction. No production replacement has been made.

The preceding [stage 44](reference/COORDINATION-44.md)
adds action lifetime coordination and direct lazy pending observations, and
records why active depth alone failed on override retirement. Publication
coupling and committed dependency structure are now part of the hypothesis;
their necessity and cost must be reassessed before a production port. The latest
reference command passes 120 tests, of which 71 execute the newest scheduler.
Production sources and their acceptance status remain unchanged.

An optimistic boundary has an input producer and an ordinary output memo.
The selector chooses the input or an explicit override. Only the selector
can subscribe to an input without consuming its proposal. All output values,
async results, effect work and owned children use the existing ordinary
transaction staging and publication paths. No lane value is used.

```ts
const [first, guessFirst, clearFirst] = createLayer(source);
const doubled = createMemo(() => first() * 2);
const [second, guessSecond, clearSecond] = createLayer(doubled);
```

`createLayer` is an experimental control surface, not a replacement public
contract. `clear` makes override expiration explicit so the publication
mechanism can be tested before choosing automatic action/input lifetimes.
In particular, its persistent overrides do **not** claim compatibility with
`createOptimistic`'s automatic correction or action completion rules.

The next experiment uses `createLayer(input, { lifetime: "action" })`.
It captures the guessing action, allows the output update to publish ahead
of that action, and retires the override into that action's ordinary update
when the input changes or the action body ends. Input correction and any
async downstream consequence therefore entangle with the guessing action.
The updater function runs once; it is not retained or rebased. This mode
currently requires an action for the initial guess. Overlapping-answer
ordering and source-question provenance are not yet implemented.

An update owns proposals, not permanently assigned graph nodes. At a cut,
pending downstream proposals can move from the input update to an output
update. Published values and retained children remain in place. A later
input update can commit while an overriding output remains held.

Reading a proposal joins its update. Reading the published value of a
pending input update does not join it. An optimistic update may use the committed frame of a separate pending
ordinary update as well as its own input update. It does not consume those
proposals. The relationship remains directed: an optimistic proposal does not
get to read an arbitrary sibling optimistic proposal as committed merely
because both are pending. Explicit parent relationships still cover nested
layers, and shared sibling derivations still coordinate their proposals. Sibling proposals that
meet merge through the ordinary transaction mechanism, including the union
of these input relationships. A numeric priority or one parent pointer is
insufficient for that union. These relationships live on active updates;
settled signal reads have no layer lookup or traversal.

The implementation currently takes over downstream nodes by walking
subscriber links, stopping at active nested overrides. A transfer reruns
readers even when the proposal is equal: an ordinary stale reader may have
already displayed the old value without being held itself. Effects can owe
a queued callback without a transaction stamp, so owed work is requeued
under the new update. The shared callback runner checks its current holder
before publishing. Old queue entries then either wait or become no-ops.

Each boundary remembers its live output update independently of the node's
current holder. The holder can change when input work joins a child. A small
active set drops completed update references at the seam; keeping completed
transactions on persistent boundaries would retain their node lists.

These are hypotheses to test, not invariants to defend. Dynamic dependencies,
shared consumers and queue ownership have already invalidated simpler
transfers. There is no second implementation of value/child/error commit.

Settled input and output take a smaller path: enqueue the output selector
as an ordinary computation. No output transaction, relationship set or
subscriber walk is allocated. Ordinary downstream async opens a hold if
needed. The transfer path is only for an already-held input or output.

## Observable examples

Repeated proposals with an async memo over the output:

```
initial                         output 0; pair 0 / 0
guess 1; async pending          output 0; pair 0 / 0
async 1 resolves                output 1; pair 1 / 1
guess 2; async pending          output 1; pair 1 / 1
unrelated rerun and late mount  output 1; pair 1 / 1; late 1
async 2 resolves                output 2; pair 2 / 2; late 2
```

For an input action holding `source = 10`, a child override of 1 can
publish `[source(), child()] = [0, 1]`. After the input publishes, this is
`[10, 1]`; explicitly clearing the override produces `[10, 10]`, held on
any newly required async work. The override is the declared difference.

## Verified baseline and history

- The checked-in F5b assertion, run without its expected-failure wrapper,
  receives `['1,2', '1,1']` instead of `['1,1', '1,1']`.
- A Chromium DOM reduction also produces an independent reader showing 2,
  a coupled reader showing `1 / 1`, and a late reader showing 2.
- `lanes.ts` writes a repeated guess directly to `_x._lane`; `display()`
  returns that same slot once the lane's `_shown` bit is set. Derived
  values, unlike written guesses, can stage in `_pendingValue`.
- The linked playground returned HTTP 403 through the execution environment
  and was unavailable through web access. The DOM test is a local equivalent,
  not a claim that the hosted artifact was executed.
- Reviewed the F/D rule documents, archived A17/A18/A29/A31 rules, the L2
  history, and discussions [3460](https://github.com/solidjs/solid/issues/3460),
  [3444](https://github.com/solidjs/solid/issues/3444),
  [3698](https://github.com/solidjs/solid/issues/3698),
  [3442](https://github.com/solidjs/solid/issues/3442),
  [2831](https://github.com/solidjs/solid/issues/2831),
  [3028](https://github.com/solidjs/solid/issues/3028), and
  [3884](https://github.com/solidjs/solid/issues/3884).
  Several maintainer-account comments identify themselves as assistant-written;
  they are implementation reports, not independent new semantic rulings.

## Decisions and open questions

The working direction for input correction is derivation entanglement,
following the user's functional-updater example: `x => x + 1` cannot retain
its relationship to a changed base by simply leaving its computed result
in place, and the runtime does not replay/rebase the updater. The executable `questions.mjs`
checks an independently written input while the guessing action stays open:
baseline `[source, view, doubled]` stays `[0, 1, 2]` after `setSource(2)`,
then becomes `[2, 2, 4]` when that action ends. The override is invalidated
internally, but correction is folded into the existing hold. Distinguish
that from an independent correction publishing `[2, 2, 4]` before the action
ends, and from retaining the override over a published input `[2, 1, 2]`.
The action-lifetime mode now reproduces this ordinary-input behavior.
Overlapping answers and equal-valued renewal remain open.

A nested case is now decided for this experiment. Starting with `first = 1`, a second boundary
over `first * 2` guesses `x => x + 1`, showing 3. While the second action
stays open, the first action guesses 2. Legacy lanes immediately display
`first = 2, second = 4`: the optimistic input corrects the child without
waiting for its action. The shared experiment retains `first = 1, second = 3`
until the second action ends, then publishes `first = 2, second = 4`.
`layered-action.test.ts` records both outcomes and checks direct and combined
bindings agree. The user accepts the prototype's entanglement behavior
without rebasing, so this is an intentional semantic change from legacy
lanes. It is also a motivating example for future rebasing: retaining and
reapplying the child's increment could allow `first = 2, second = 5` while
the child action stays open. Rebasing is a future design question, not part
of this implementation or a reason to weaken current consistency tests.

The user clarified Ryan's exception: it concerns `latest`/`isPending` reads
**outside the reactive system**, such as an event handler seeing flushed
work before ordinary publication. It is not an authorization for tracked
memos or their consumers to inherit a special read posture. The previous
notes conflated that exception with the implementation's `CONFIG_VERDICT`
behavior and the material in `size-reduction-carve-step1.md` §21; that
attribution is withdrawn.

The prototype's working contract is that imperative reads observe committed
publication, consistent with rendered bindings. Preserving the outside
flushed-value exception is expendable, like `until`; do not add bookkeeping
just to retain it. Reconsider it after the common core works. Plain accessor
reads already use the committed path, exercised in
`layered-outside-reads.test.ts`. The existing public exports retain legacy behavior. Experimental `isPending`
now shares source-owned output publication; replacement `latest` remains deferred.
The legacy exports are not claimed to satisfy the prototype's new outside-read contract.

The user settled the tracked-computation question: an optimistic pending-true
update reads its input update's committed value without joining that update.
For `status = memo(() => isPending(x))` and `pair = memo(() => [status(), x()])`,
an action holding `x = 1` therefore publishes status `true`, pair `[true, 0]`,
and direct input `0`. Async derived from status must hold status and its
ordinary consumers together. This is a relative update relationship, separate
from Ryan's imperative-read exception.

The experimental `createPending(x)` accessor now exercises this rule. It uses
the same output boundary and `stageLayer` path as guesses. A direct source
accessor now reuses its existing node as the input; an arbitrary callback
still creates an input producer. When the input
update can complete, the false proposal rejoins that update before publication;
new async work on that result holds both. A retiring latch prevents that work
from reporting itself as a new true proposal. Initial loading has no committed
input to observe and follows the ordinary suspension path. This is not yet a
replacement for the public dynamic `isPending(fn)` window API.

Explicit update relationships cover proposals; a dependency walk covers an
already-published sibling output. A positive reachability cache uses weak
update/node keys. It now survives flushes with unchanged dependencies, using a
structural dependency epoch, each node's validated dependency tail, and a
boundary ownership epoch. A proposed computation's old retained links do not
authorize a committed-input read; only its current generation does. This also
applies through intermediate memos. Park/commit searches remain uncached.
Ordinary nodes and settled reads have no added storage or lookup.

The previous per-flush cache was too expensive (approximately 34% slower at
held depth 16 after other refinements). Structural caching brought that
workload close to baseline in repeated runs. Inactive overhead, boundary
memory, bundle size, and broader correctness still prevent acceptance; see
`STRUCTURAL-RESULTS.md`.

The user accepted order-independent mount: new readers of pending and its
input must publish `[true, 0]` in either read order. For a branch that stops
reading the observation, the user prefers retaining `"true:0"` until ordinary
input publication, but permits exploring immediate `"plain:0"` if it follows
from a simpler rule and does not introduce other problems. This is a preference
with experimental latitude, not approval for an accidental stale dependency.

The current discovery experiment handles the accepted mount case and preferred
branch case. For a held read whose parent has been crossed by a boundary, it can
provisionally use committed input, then check this evaluation's dependencies.
If no boundary justifies that read, it joins the parent and recalculates. A
provisional ordinary transaction holds owned children; an owned child's unresolved
context is decided with its owner. Discarded results do not publish, and rejected
Promises from discarded bodies are handled. This may start work that is subsequently
discarded; it is not a claim of physical cancellation or zero wasted calculations.
The computation wrapper is installed only while candidate parent updates are live.

A branch that leaves while pending-true work is still suspended can currently
publish against committed input. This alternative is under exploration. Generated
branch timelines exposed a further tear: input completion published a new input
before the branch's new async result. Derivations that consumed a parent's committed
frame now rederive before that parent publishes, so their new async can hold it.
The common post-commit rerun path remains suitable for direct frame bindings.
The reduced regression checks coherence and eventual publication without requiring
one of the two initially permitted branch timings.

The shared scheduler now deduplicates reruns per update and reader, and removes
disposed readers from live registrations. This also fixes a baseline bug: a direct
reader of two held inputs could miss the second input's completion if it finished
first. The baseline fails that reduction; the candidate passes both completion
orders. No fields or lookups were added to settled signal reads.

Acceptance remains open. See `STRUCTURAL-RESULTS.md` for current validation
and measurement; `DISCOVERY-RESULTS.md` and `PENDING-RESULTS.md` record earlier stages.

## Narrow coordination hypothesis under discussion

The user supplied Ryan's [memo-entanglement note](https://hackmd.io/coJIm_fmQJCGmn69k4qH5Q),
dated 2026-10-14 against `next` 0109a56. It distinguishes racing per-update
versions from a selective committed-frame/one-hold rebase. Its reported probe
failures illustrate the downstream problem: a sync fork can later reach an
async node already doing another update's work. Its size prediction is not
a measurement or a constraint on the new model.

A narrower candidate for this experiment is one current proposed result and
one eligible async calculation per memo, shared by ordinary and optimistic
updates. Peer updates that need incompatible proposals of the same memo
merge; a replacement calculation invalidates the older answer. Unrelated
graphs can still publish independently. A child update explicitly reading a
parent's committed value does not consume the parent's proposal and therefore
does not join it just because of that read. Numeric priority alone does not
describe that relation, particularly where sibling layers combine.

This is not a claim that an arbitrary committed-frame fork is safe. Even a
sync memo has a proposed value, dependencies, possible previous-value input,
and owned children. Letting an ordinary update replace its committed result
while preserving another proposal requires deciding how to rebuild that
proposal and its downstream async. Single-flight storage does not remove
that requirement. For now the scoped candidate retains conservative peer
entanglement and confines committed-parent reads to explicit boundaries.
The preferred branch-switch behavior retains ordinary entanglement; the user
allows exploring the committed-input alternative if it is simpler and coherent.

"One eligible calculation" does not promise physical cancellation of a
Promise's work. The core already rejects results whose `_inFlight` identity
is obsolete. `layered-coordination.test.ts` characterizes two peer actions
meeting at an async derivation: the newer calculation replaces the old one,
both actions gate publication, an obsolete answer cannot publish, and a
disjoint ordinary output still publishes immediately. This is a conservative
existing behavior test with the experimental hooks installed, not an
implementation or validation of selective forking. Order-independent mount and owned discovery are now covered by tests;
more general dynamic control flow and async ownership transfer remain under investigation.

## Classification of differences

1. **Implementation bugs fixed:** F5-style repeated-proposal tearing;
   lost callback ownership on transfer; equal proposals retaining a parent's
   read context; unheld stale readers missed by a transfer; failure to union
   parent exclusions when siblings merge. No assertion was weakened.
2. **Experimental semantic change:** `createLayer` has explicit persistent
   overrides and `clear`, allowing the shared publication mechanism to be
   tested independently of action/input lifetime rules. It is a different,
   private API, not a silent change to `createOptimistic`. In the optional
   action-lifetime mode, nested input corrections intentionally entangle as
   ordinary input corrections do; the user accepted this without rebasing.
3. **Unresolved:** overlapping action answers, equal-valued renewal and
   general dynamic control flow during context discovery. The preferred branch-switch behavior
   and order-independent mount are implemented in the experiment. Rebasing is future work.
4. **Deferred features:** stores (including structural/keyed coherence),
   SSR, `until`/`refresh`, public observation window APIs and loading/deferred boundaries.
   The legacy implementation remains available for these features.

`until`, `refresh`, stores, SSR, deferred boundaries and a replacement
implementation of `latest` are deliberately deferred. Experimental `isPending`
is described below; it has not replaced the package export. Existing
implementations remain in the checkout; their tests being green does not
validate their composition with this adapter. The imperative flushed-value
exception is deliberately deferred; no tracked-reader or downstream tearing
exception is inferred from it.

## Reproduction and measurements

From `packages/signals`, run
`./node_modules/.bin/vitest run tests/layered-experiment.test.ts`.
`LAYER_REPLAY='op:value ...'` reproduces a generated timeline.

From the repository root:

```
node experiments/layered-updates/build.mjs
node experiments/layered-updates/measure.mjs /workspace/layered-baseline
node experiments/layered-updates/measure-optimistic.mjs
node experiments/layered-updates/browser.mjs
```

The baseline uses the normal signals Rollup build and shared property
mangling. The candidate uses that same production build configuration with
experimental scalar and observation entries. Both are bundled as applications by the same
esbuild version. Bundle metadata identifies retained modules, so a source
dependency merely listed as an input is not confused with shipped code.

The optimistic size comparison is a feasibility measurement of the smaller
mechanism, **not feature-equivalent acceptance**: overlapping-answer provenance and several other baseline features
are absent from the experimental entry. The ordinary import comparison is
feature-equivalent. No size caps or performance thresholds are changed.

Performance samples are isolated processes and alternate baseline/candidate
order. Results taken concurrently with builds or tests are exploratory only;
acceptance requires idle reruns and broader workloads. Finite test campaigns
provide counterexamples or evidence, not a proof for arbitrary graphs.
`allocations.mjs` uses V8 sampling including collected objects; its byte
estimates are distinct from retained heap. `memory.mjs` uses weak references
and production builds to check that a live boundary does not keep disposed
readers after its update completes.

## Accepted publication across a separate ordinary hold

The user approved letting pending-true use the committed value of a separate
held ordinary signal. `independent-pending.mjs` now exercises this sequence:

```ts
const status = createMemo(() => isPending(x));
const label = createMemo(() => `${status()}:${y()}`);
```

Start with x=0 and y=0. An action proposes y=10 and stays open; another
proposes x=1 and stays open. The label publishes `true:0`. When y's action
ends, y=10 and `true:10` publish together while x's action remains open.
When x finishes, the label publishes `false:10`.

The boundary's committed-frame relation now covers separate ordinary holds.
New readers discover that relation in either read order. A foreign ordinary
holder used this way is registered for pre-publication rederivation, so async
work discovered at its completion can still hold that holder. There is one
current proposal per memo: a new calculation supersedes the earlier flight.
The lower actions are not linked merely to read their committed frames.

Pending-false explicitly retires the optimistic override through `resumeInput`,
the same ordinary input-resumption path used by guesses. If x finishes first,
its false proposal meets y's ordinary proposal in the combined memo; they
entangle and retain `true:0` until both can publish. A hold extended by that
join does not reopen pending-true unless the observed input changes again.

The action scope supplies an input update even for a guess over a settled
input. Creating a child transaction and transferring the graph on every such
guess caused an unacceptable 1.9–2.8x regression. A conservative check for any
held graph nodes preserves the small synchronous path when only empty action
scopes exist. A later ordinary hold enables context discovery for already
published scoped overrides. The check adds no ordinary-node fields or settled
read lookups. Current validation and measurements are in `FOREIGN-INPUT-RESULTS.md`.

The source-owned `isPending` experiment now observes one lazily created output
per source node, as the user clarified. Calling computations read that output;
they do not construct independent observation boundaries. Its weak source key
adds no ordinary-node field, and its observation lifecycle detaches/revives
without depending on the first caller's lifetime. Callback windows observe the
same per-source outputs, so equal callback return values no longer hide pending
reads. The legacy public export remains separate. See `SOURCE-OWNED-RESULTS.md`
for validation, lifecycle limits and measurements.

## Pending input beneath a published guess

The user chose to retain the upstream rule: a published optimistic guess still
reports pending while its relative input calculation is unresolved. For an input
starting at 0 and a visible guess of 1:

```
input request unresolved             view=1, pending=true
input answers 1, action still open   view=1, pending=false
input answers 2, action still open   view=1, pending=true
action and correction finish         view=2, pending=false
```

The last two rows are the differing-answer branch; the matching-answer branch
finishes at 1. Pending compares the incoming proposal with the displayed output,
not with a universal non-optimistic value. Nested overrides observe their own
input producer. There is no traversal to a global base.

The source-owned pending output subscribes both to the value boundary output and
to its input producer. The latter subscription matters when a request starts
beneath an already visible guess without changing that guess. The relationship
is resolved once when the pending output is created. This does not add a field
or lookup to ordinary signals, memos or settled reads.

Value proposals propagate before pending proposals are staged. Otherwise a guess
and its pending status created in one flush accidentally join before either has
propagated: an async status label then prevents a ready guess from publishing.
With the ordering fixed, pending status and its ordinary consequences form one
coherent update while the guess and its consequences use their own ordinary
publication. A consumer that actually combines them still coordinates through
its dependencies. Both use common value, error and owned-child machinery.

The earlier question script now asserts the accepted sequence against both
baseline and candidate. A separate Chromium replay checks a later input request,
late readers, matching answers and differing corrections. The legacy later-request
case misses the existing status reader while a new reader reports true; two
expected-failure comparisons retain identical consistency assertions for both
implementations. See [INPUT-STATUS-RESULTS.md](INPUT-STATUS-RESULTS.md) for the current
validation and measurements. This stage does not establish overall acceptance.

## Equal answers and input-node reuse

The user provisionally retains upstream's early pending release. If input starts
at 0, guess 1 publishes, and its request answers 0, pending becomes false while
the action remains open. Correction starts when that action ends. This is not
an endorsement of every upstream timing rule; reconsider if preserving it needs
substantial machinery. No such machinery was needed for this case. Pending-false
still shares publication with its ordinary async consequences and late readers.

A canonical input accessor can now supply the input node directly. A function
input still gets its own producer, with equality applied at the output rather
than filtered a second time in the producer. This matters for inputs explicitly
configured to notify on equal results. Starting a request is not an incoming
answer and must not retire the override. The explicit-clear test API detaches
its unused input dependency while overridden; action overrides retain input
notifications to detect corrections.

The common staged-read path now records update ownership at the actual proposal
read. Newly created owned children then inherit the creator's hold before the
first park. Recording ownership later, at child creation, incorrectly captured
unrelated holds entered by another child and was rejected. The final rule adds
no normal-node field and does not run for ordinary settled reads. A baseline
reduction and Chromium replay expose input=0 / child=1; the candidate keeps both
at 0 until they publish 1 together, including an equal-valued owner replacement.
The ownership correction initially exposed two legacy Loading integration bugs:
a fresh boundary treated its creator's hold as a new load, publishing an extra
fallback. The synthetic first-pass catch now distinguishes that inherited hold
from real async work. Real pending work still takes the ordinary status path.
This fixes both regressions and two older async-landing expected failures, now
promoted to normal tests with their assertions unchanged. The full suite passes;
this is not validation of every Loading/optimism composition. Details and
measurements are in [INPUT-REUSE-RESULTS.md](INPUT-REUSE-RESULTS.md).


### Smaller ordinary nodes and removal of legacy branches

The scalar publication model is unchanged. Plain signals no longer carry an
unused computation clock, and the initial loading-value window uses an existing
configuration bit instead of a boolean field on every memo/effect. Boundary
selectors share their implementation; optional layer hooks are module bindings.

The local scalar build now omits the old lane-specific branches in the common
read/recompute path. This makes the ordinary, optimistic and pending application
fixtures smaller than baseline, while the compatibility build still retains the
old APIs for comparisons. The build switch is experimental scaffolding; it does
not confer support on legacy APIs in the scalar tree. Memory per boundary and
API integration remain incomplete. Measurements, supported scope and validation
are recorded in [SCALAR-CORE-RESULTS.md](SCALAR-CORE-RESULTS.md).


### Performance emphasis clarified

The user accepts extra cost in pending observations and optimistic boundaries
at this stage, including the expected cost of splitting one optimistic node
into two full nodes. These are not acceptance blockers by themselves. The
priority is the synchronous path with no async work or pending observations:
reads, ordinary writes, sync derivations, creation and notification fan-out.
Moving cost from those common operations to explicit boundaries is desirable.
The correctness invariant and bundle-size requirements remain unchanged.


Held-reader disposal cleanup now exists as an optional callback only while
holders have readers to remove. It is installed on registration and cleared
when landing/disposal empties the holders. Purely synchronous disposal does not
enter that bookkeeping. The synchronous-only benchmark and validation are in
[SYNC-PERFORMANCE-RESULTS.md](SYNC-PERFORMANCE-RESULTS.md).

### A notification is not a proposal read

A suspended child computation keeps its update context when a lower update
notifies it. Merely reaching that memo does not merge the two updates. Reads
inside the pass decide coordination: consuming another proposal still merges
peer work; a permitted read of a published input registers a rerun before that
input publishes. Ordinary peers meeting a memo continue to merge immediately.

For example:

```ts
const [y, setY] = createSignal(0);
const [view, guess] = createLayer(() => 0, { lifetime: "action" });
const pair = createMemo(() => `${view()}:${y()}`);
const label = createMemo(() => loadLabel(pair()));
```

Suppose `guess(1)` is suspended in `loadLabel("1:0")`, then an independent update
proposes `y = 10` and suspends elsewhere. Finishing the first label can display
`view = 1`, `y = 0`, `label = "1:0"`. When the y update finishes, the memo starts
`loadLabel("1:10")`; y stays 0 until that consequence is ready. If y finishes
first, that new calculation supersedes the old one and the obsolete `"1:0"`
answer cannot publish. A synchronous y update starts the combined calculation
within its flush. These outcomes do not depend on how deep y's other async
calculation sits in the graph.

The implementation temporarily selects the existing child update for the
pass. The common parking loop assigns proposals and owned children to their
update before switching contexts. Before deciding that an input is ready, it
also accounts for flights discovered later in the pure phase. Ready inputs
recompute their stale memo readers in the input context before publication.
Retiring an override rejoins its held output with its input update explicitly.
Errors, supersession, children and final publication continue through the
ordinary machinery.

A changed boundary proposal must retain its relative layer if downstream work
suspends. The original settled-output shortcut lost that relationship. The
first correction allocated an output update for every changed proposal; the
refinement lets synchronous work propagate normally and records the cut when
the common parking loop supplies an update. Separating an already-held input
still creates an output update immediately. An explicit-clear test boundary can
have an output update with no pending parent; an empty exclusion set records
that case. Ordinary nodes gain no additional fields.

The new composition tests also combine two source-owned pending outputs through
both direct `isPending(source)` calls and callback `isPending(() => ...)` calls.
Callback source reads continue to track value/control-flow dependencies. This
fix does not introduce a separate callback graph or a second pending output.
See [COMPOSITION-RESULTS.md](COMPOSITION-RESULTS.md) for validation and limits.


A reusable output update must still be a child update distinct from the input.
If a correction merged it back into the input, a subsequent guess creates a
fresh cut. Reusing the merged update would trap the new guess below its input.
The scalar build also omits legacy lane-only transaction fields and scheduler
callbacks; those remain in the compatibility build until API integration.


The dependency-cache epoch is now installed only while layer coordination is
active. Activation invalidates earlier cache entries; inactive ordinary link
creation and disposal do not advance that cache's counter. A legacy
pending-read branch that became a no-op under the scalar compile switch is
also removed at build time. Both changes target synchronous use without async
work, including applications that import optimism but leave it inactive.


### Store inputs: separate write notifications from backing lifetime

Initial scalar-boundary integration preserves held publication for existing
store properties and for a structural input (value, presence and enumeration).
It also exposes an inherited over-holding case: a second setter touching only
`other` repeats a held `count` slot write because the notification bound is the
set of all keys written since the backing was staged. Ordinary write joining
then entangles that second setter even without a memo connecting the properties.
This is recorded as STORE-G1, not accepted as a layer rule. A future store adapter
must distinguish the current setter's writes from the backing's accumulated
changes, including late-created slots and structural consumers. Clearing the
accumulated key set alone would also change backing folding. The scalar model
and the no-rebasing decisions are unchanged. See the stage-26 follow-up in
[COMPOSITION-RESULTS.md](COMPOSITION-RESULTS.md).

## Shared lifetime clarification (stage 29)

Input arrival no longer retires an action-owned override early. The input update
joins the guessing actions; the selector retains the latest guess until their
shared lifetime ends. This supersedes earlier descriptions of immediate internal
correction. The user explicitly accepts delayed downstream work from an incorrect
guess. Current next already entangles repeated guesses on the same node, even
equal guesses, but can propagate relevant input corrections internally before
release. The prototype deliberately delays that propagation. No action-age
provenance was needed for the overlapping-answer example. Functional guesses
compose on the retained override; input pending observations retain their earlier
contract. Future semantic questions include verified upstream comparisons.

## Pending inputs and shared release (stage 30)

An action body returning is not sufficient to release its group while any
selected override's input remains pending. The pre-publication phase waits for
those inputs as a group, then removes the overrides through ordinary derivation.
This matches upstream even when a child's pending input was caused by a guess
in the same group: the incorrect guess can delay its own group's restoration.
`nested-input-release.mjs` records both production runtimes' visible sequence.
An input error is an answer for release readiness, but does not pierce an override
while its action body remains open. That follows the accepted selector lifetime;
`input-error-lifetime.mjs` records upstream's earlier error reveal explicitly.

An input hidden by an override may outlive the transaction which originally
carried the action. Its eventual answer must resume in live ordinary work, not
reattach proposals to that completed transaction. Used value boundaries also
remove their scope and proposal bookkeeping at final disposal; cleanup schedules
an idle sweep without requiring a later unrelated write. No fields or traversal
were added to ordinary signal or memo reads.

## Latest observes the selected output (accepted stage 31)

The user accepted that the earlier-correction behavior is wrong for this model,
while asking us to keep looking for concrete reasons it was useful. `latest`
therefore observes the proposal of its argument's output; it does not compute
an alternative derivation underneath a retained override. The initial shared
implementation uses one lazy output per source. Pending and latest share the
observation lifecycle; ordinary parked values, errors and child frames still
supply publication. Settled synchronous latest outputs pass through ordinary
updates. Nested observation-window semantics were subsequently accepted below.

Evidence to retain: https://github.com/solidjs/solid/issues/3331 describes a
wrong guess's downstream flight delaying the final result from roughly two to
four seconds. Its maintainer-account comment describes supersession and stale
answer suppression. `layered-correction-waterfall.test.ts` preserves the useful
scalar case without retaining propagation beneath an open action: once the
body and input are ready, correction starts before the wrong guess's flight
finishes, and that obsolete answer cannot publish. A separately open action
still delays correction under the accepted rule. This test uses the supported
memo-input/action shape, not the excluded async-input overload or ambient guess.

The user's clarification limits #3331's relevance: it establishes prompt
supersession once reversion is chosen. It does not establish when to choose
reversion or justify propagating an input beneath a still-selected override.

## Observation composition (accepted stage 32)

Observation windows compose by reading each other's outputs. With an action
holding x=1 over committed x=0, `latest(() => isPending(x))` reads true, just
like latest of a memo wrapping pending. `isPending(() => latest(x))` reads false
when that latest output is ready. Repeated nesting follows the same rule.
Callbacks created or pulled inside a window retain their own ordinary reads.
Only callback observations allocate a temporary window frame; direct accessor
forms and ordinary signal/memo reads do not.

Before publication, observations retire before replaying stale ordinary readers
of a newly ready input. Otherwise callback pending probes can consume the still-
true observation, join its obsolete async consequence into the input update,
and prevent the false observation from superseding it. The ordinary fixed-point
preparation then discovers and completes the replacement work before commit.

Sibling observations staged in the same flush still batch together. A suspended
latest consequence can therefore hold a sibling pending boolean. The production
`observation-siblings.mjs` comparison verifies this behavior in current next too.
This is retained batching, not a special nested-query rule or selective forking.

## Initial observation frames (stage 33)

A first or revived observation has no published frame to retain. Latest starts
from the current flushed proposal; pending starts from the pending sample. This
lets a new async consequence reach its Loading fallback immediately, as in next,
instead of manufacturing a committed-input frame and then holding before attach.
An existing live output continues to retain its actual published frame. This
uses only observation lifecycle state and the existing unflushed-value helper.

Update registration remains in the common publication phase. Moving it eagerly
inside a newly discovered boundary caused earlier ordinary reads in the same
calculation to escape their hold; immediate-caller, owned-child, and lazy-sibling
tests pin the distinction. The eager attempt and a core retry experiment were
withdrawn. Repeated initial async calculation remains an optimization issue.

## Sibling ordering (confirmed stage 34)

Sibling effect callbacks have no fixed creation-order guarantee. This follows
the recorded notification-order ruling in `docs/write-coalescing.md`, item 3,
and the user's explicit instruction not to constrain this experiment by a new
ordering requirement. Correct values, coherent release, notification counts,
parent/child constraints and cleanup-before-replacement constraints still apply.
Current next itself can run siblings A/B on mount and B/A on update when A reads
through an identity memo and B reads the same signal directly.

## Stable contexts in the real core (stage 61)

[STABLE-CORE-61.md](STABLE-CORE-61.md) records the first stable-context slice in
actual Solid production TypeScript after the isolated reference work. It adds
stable proposal positions, separate calculation/action contexts, coherent
callback routing, and forwarding of observation through active value overrides.
It supersedes the earlier blanket same-flush observation batching description:
distinct higher contexts can publish independently, including pending-of-pending.

This is not an acceptance pass. A public-API audit pins an unnecessary stale
request from the older post-body retry adapter, and active optimistic performance
and size remain above next. Ordinary fast paths are retained. Further work stays
in the real core; stores remain paused.
