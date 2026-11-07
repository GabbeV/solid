# Unified updates — scalar API and status

Current accepted API decision: [scalar guesses before the first input answer, stage 124](INTEGRATION-124.md).
Previous failure audit and rejected trials: [stage 123](INTEGRATION-123.md).
Latest adversarial review: [owned-frame defect, publication controls, performance and size, stage 170](INTEGRATION-170.md).
Current runtime checkpoint: [creator context retries, WIP stage 172](INTEGRATION-172.md).
Previous runtime checkpoint: [private calculation, publication and override lifetime, stage 171](INTEGRATION-171.md).
Previous runtime checkpoint: [eager private rendering with coherent inherited reads, stage 169](INTEGRATION-169.md).
Previous calculation repair: [coherent latest reads in owned frames, stage 168](INTEGRATION-168.md).
Previous investigation: [owned-frame latest reads and strengthened regression, stage 167](INTEGRATION-167.md).
Previous investigation: [first callbacks in unpublished owned subtrees, stage 166](INTEGRATION-166.md).
Previous rejected trial: [first held values and derived-store result transfer, stage 163](INTEGRATION-163.md).
Previous creation-context repair: [stage 159](INTEGRATION-159.md).
Deferred scheduling investigation: [lifetime readiness before optimistic execution, stage 161](INTEGRATION-161.md).
Previous investigation: [inactive latest and request lifetime, stage 160](INTEGRATION-160.md).
Previous ownership repair: [provisional parent-frame reads, stage 157](INTEGRATION-157.md).
Previous observation repair: [latest selection and structural replay, stage 155](INTEGRATION-155.md).
Previous error callback repair: [stage 152](INTEGRATION-152.md).
Previous runtime repair: [error observations and ordinary recovery, stage 150](INTEGRATION-150.md).
Previous callback repair: [coherent callback release, stage 148](INTEGRATION-148.md).
Previous repair: [store parking at context switches, stage 147](INTEGRATION-147.md).
Observation context semantics: [common observation context, stage 141](INTEGRATION-141.md).
Latest suite counts: [stage 172](INTEGRATION-172.md).
Earlier failure inventory: [stage 157](INTEGRATION-157.md).
Previous assertion migration: [eligible flights and input lifetimes, stage 164](INTEGRATION-164.md).
Previous assertion migration: [first-value read checks, stage 158](INTEGRATION-158.md).
Previous context migration: [stage 156](INTEGRATION-156.md).
Previous lifetime migration: [stage 154](INTEGRATION-154.md).
Latest rejected ownership trials: [stage 153](INTEGRATION-153.md).
Failure inventory: [error publication and collection audit, stage 150](INTEGRATION-150.md).
Restored collection coverage: [72 Loading cases, stage 151](INTEGRATION-151.md).
Mount coverage: [committed-frame mounts and DOM coverage, stage 146](INTEGRATION-146.md).
Previous runtime investigation: [rejected synchronous latest simplification, stage 149](INTEGRATION-149.md).
Earlier preparation trials: [early latest, stage 145](INTEGRATION-145.md).
Accepted branch rule: [ordinary branch consistency, stage 144](INTEGRATION-144.md).
Earlier error publication checkpoint: [held latest error publication choice, stage 134](INTEGRATION-134.md).
Previous runtime checkpoint: [snapshot observations and pending migration, stage 125](INTEGRATION-125.md).
Latest accepted lifetime ruling: [pending lifetime and mount tests, stage 127](INTEGRATION-127.md).
Ruling evidence: [async pending-badge retirement, stage 126](INTEGRATION-126.md).
Previous runtime repair: [unheld observation restoration, stage 122](INTEGRATION-122.md).
Previous audit: [held proposals and first publication, stage 121](INTEGRATION-121.md).
Current lifetime model: [independent input and override lifetimes, stage 120](INTEGRATION-120.md).
Earlier audit: [error recovery and input-lifetime conflict, stage 118](INTEGRATION-118.md).
Earlier repair: [fresh boundary publication, stage 117](INTEGRATION-117.md).
Earlier repair: [error supersession, stage 116](INTEGRATION-116.md).
Recent repairs: [deferred refresh and observation revival, stage 115](INTEGRATION-115.md),
and [retaining own-input holds after reader removal, stage 114](INTEGRATION-114.md).
Public API migration: [normal package integration, stage 105](INTEGRATION-105.md).
Previous scalar checkpoint: [stage 90](SCALAR-MILESTONES-90.md).
Historical costs against the old rc.14 baseline and retained simplifications: [exact ownership membership, allocation and performance, stage 104](OWNED-MEMBERSHIP-104.md).
Stage 103’s cache experiment was rejected and removed. Stage 104 removes per-update membership arrays instead; its storage optimization is isolated in a separate patch.
The selected migration failures are classified and the fresh Loading mount bug
is fixed. Displayed dependencies retain their publication obligations across
speculative branch changes; inputs used only by the speculative branch can
publish independently. Guesses written in derivations belong to the update
executing the setter, without inheriting an input override's longer lifetime.
The earlier scoped scalar checkpoints passed their test matrices. The broader
normal-suite audit now includes rc.21. Upstream’s F2 reveal repair is integrated
and the pinned reveal tests pass, but additional scalar failures remain under
audit. Scalar correctness, active optimism costs and bundle size remain
acceptance gaps. Earlier performance percentages do not compare to this new
current-next baseline.
General input-demand forwarding is removed. Active overrides can release lower
updates, pending-only observations do not hold initialized input updates, and a
guessing action still waits for its own pending inputs. Correction uses ordinary
coherent publication. The current pending self-feedback cancellation/reversal
behavior is accepted as the working baseline; no suppression exception, tearing
exception, assertion, or logged diagnostic is installed. Convergence in broader
feedback graphs still needs validation. The earlier Latest/Loading navigation matrix passed against pinned rc.14;
the expanded current-next audit is incomplete. Unchanged-flight transfer fixes duplicate requests in the
tested scalar chains; owned-subtree reuse remains incomplete. This is not a
complete scalar or performance/size acceptance result.

The normal `packages/signals/src/index.ts` now exports the shared implementation.
The runtime modules live in `src/layers/`; the separate experimental entry,
Rollup target, and compatibility-test aliases are retired. Use the package's
normal build, Vitest configuration, and existing benchmark files. See
[the integration checkpoint](INTEGRATION-105.md) for supported APIs, failures,
and reproducible commands. Nothing has been published.

The integrated scope includes scalar signals, memos, effects, actions,
optimistic boundaries, source-owned pending/latest outputs, refresh, Loading,
errors, ordinary stores, and projections. Optimistic stores remain the next
migration surface; the public function currently fails explicitly rather than
silently entering the disabled legacy lane engine. `until` is explicitly deferred.

This is a testable scope, not a claim that every combination or option has been
validated. The acceptance audit lists the evidence and remaining gates.

## Optimistic input and lifetime

```ts
const [source, setSource] = createSignal(0);
const [view, guess] = createOptimistic(source);

const save = action(function* () {
  guess(previous => previous + 1);
  const answer = yield request();
  setSource(answer);
});
```

This entry accepts plain initial values, no argument, input accessors, and sync
or async callbacks. A callback receives
its own producer’s previous result (initially undefined), including a staged
result from a preceding run in the same update context. A computation moving
above a pending lower context starts from its committed result instead. An output guess does not become that argument.
A first functional guess uses the published output, even while its input has
a held proposal. Subsequent functional guesses use the preceding guess, including
an unpublished one. Equality and
loadingValue options have focused coverage; full hydration/attribution option
behavior remains unaudited. Guesses use action lifetime or the pending update
that parks an ambient write's flush. A guess with no pending update does not
flash. Guesses written during derivations belong to the update executing the setter,
without inheriting an input override's longer lifetime (stage 90). Functional guesses evaluate
once and do not rebase. In the stage 120 trial, incoming input updates do not
join the guessing actions merely by reaching the boundary. The input can publish
while the selected override stays visible. Overlapping guesses on the same
output still share their action lifetime; the existing pending-input hold still
delays retirement until that input has answered. Ending the override resumes an
ordinary input read, which coordinates correction with its downstream work.
Delayed downstream correction remains an accepted consequence.

Callback inputs receive a separate input computation. A direct accessor for a
read-only memo declared `sync: true` can share that memo as its input when no
boundary input options are supplied. Its first refresh creates a private input
computation, preserving the scope of refresh without invalidating the source.
Async-aware memos, writable computations, loading seeds, optimistic outputs,
plain signals and configured inputs retain their separate producer. In particular,
async streams may emit raw thenables which the boundary input must normalize;
removing that producer unconditionally changes observable values. This allocation
optimization adds no ordinary-node fields or ordinary-read branches.

## Scalar refresh

`refresh(memo)` invalidates that memo. `refresh(optimistic)` invalidates its own
input callback computation, including when the original argument was a tagged
accessor. Clean dependencies are read without being invalidated. Plain signals
are unchanged. Same-tick calls coalesce, and superseded requests wait for the
replacement answer. A refresh flight is quiet for `isPending`, as in next; it
cannot silence a different pending question already in progress.

The promise receives the refreshed computation's result. A caller in the
holding action can receive its staged answer before publication, permitting
`yield refresh(source)` without deadlocking that action. A caller outside that
update waits for publication. The waiter reuses ordinary computations and the
existing transaction rerun queue; it adds no ordinary-node fields or read hooks.

For deferred values, the waiter uses the existing flight hook to wait for the
answer rather than returning the displayed old value. It subscribes directly to
that flight so an equal answer through an unchanged memo also releases it.

For an optimistic target, refresh crosses only that boundary. With an upstream
override already published as 1 and a downstream override of 10 over
`createMemo(() => first() * 2)`, refreshing the downstream boundary returns 2.
It retains 10 until its action ends under the previously accepted lifetime.
Pinned next returns 0 from its authoritative view and replaces 10 with 2 before
that action ends. Those are existing accepted model differences, not changes to
refresh's upstream invalidation scope. No authoritative duplicate graph is added.

This export accepts scalar source accessors only; refreshable stores remain
outside this experiment. See [stage 69](REFRESH-69.md) for validation and limits.

Removing the last rendered reader does not release an existing own-input hold
early; the experiment follows next here (stage 114).

The action body returning does not finish that lifetime while an input in the
group is still pending. All overrides in the group stay selected until those
inputs settle. This includes input work derived from another guess in that group,
matching current `next`. Input errors, like input values, remain masked by a
selected override until the shared lifetime ends; current `next` can forward
those errors earlier. These cases have executable production comparisons.

`createLayer` with explicit clearing remains available only through the separate
experimental layer module as a testing scaffold. Its persistent-override
lifetime is not the public `createOptimistic` prototype contract.

## Exclusions

The normal package entry now includes ordinary stores, projections, deferred
and Loading helpers, renderer integration and existing hydration paths. Their
passing suites are evidence for those exercised cases, not complete acceptance.
Optimistic stores still reject explicitly. `until` and the imperative
flushed-value read exception remain deferred under the user's direction.

Stage 108 clears the accepted scalar migration differences in the normal suites.
The expected-failure audit exposes ordinary reveal tearing (F2), also present
in the old pinned next baseline. Current next already fixes it in #4217, and
the published rc.21 JSX timeline passes; that repair is not yet incorporated here. F2 it is now an ordinary failing test with four additional failing
variants. Other Loading expected failures, optimistic stores, broader feedback
convergence, performance and feature size remain open. Avoid combining
this runtime with a separately bundled reactive runtime: two module instances
would have separate coordination state.

## Ready but unpublished answers

Pending remains true for a changed answer held by another dependency at any
depth. A ready answer equal to the displayed value can clear pending while a
sibling still holds publication; the existing comparator implements this.
Next's derived optimistic lanes also clear pending for a differing unpublished
answer. The user identified that behavior as a bug, so it is not preserved.
See stage 105 for the executable equal/different comparison. No compatibility
bookkeeping is needed for the accepted rule.

## Preliminary latest output

`latest` observes its argument's selected output, as accepted after the stage-30
comparison. An incoming answer hidden by an active optimistic override is not
an output proposal. A repeated guess can be an output proposal; `latest` exposes
it through its own publication, which ordinary async consequences can hold.
Direct accessors and wrapped reads share one lazily created output per source.
The latest output passes through ordinary settled synchronous updates.

Observation reads select the whole calculation's update context, including
under `untrack`. Discovering a higher output can restart the calculation before
it mixes ordinary input versions. Pending callbacks use that same context for
control-flow values, and promise-returning readers have no special replay
exclusion. `untrack` still suppresses subscriptions: a memo-wrapped snapshot can
retain its sampled boolean until another dependency causes a rerun. See
[stage 141](INTEGRATION-141.md) for executable timelines and changed test results.

`isPending(() => latest(x))` describes that latest output, including unresolved
input work. `latest(() => isPending(x))` observes the pending boolean's proposal.
The user accepted this composition rule in stage 32. With committed x=0 and
an action holding proposed x=1, the two expressions return false and true,
respectively. Upstream returns false for both; wrapping pending in a memo makes
upstream's outer latest return true. The prototype consistently composes outputs
in both forms. Each output still waits for its own ordinary async consequences.

Callback windows use a shared stack only while evaluating the callback. Nested
computations own their ordinary reads; a caller's window does not change those
computations' dependencies. New or revived observation outputs initialize from
their current proposal; existing observed outputs keep their committed value
during a hold. Initialization and revival now have Loading and ownership tests.
Sibling callback order is unspecified, as confirmed by the user and the existing
notification-order ruling. The acceptance audit records duplicate initial work
and deliberately deferred imperative flushed-value exceptions.
`latest` is not feature-complete.

Current validation and measurements against pinned next are in
[stage 108](INTEGRATION-108.md). Tracked observation feedback into its own
pending cause retains the current coherent supersession and reversal behavior,
including possible repeated work and an unrevealed pending proposal. The user
explicitly deferred diagnostics.
Optimistic propagation now honors ordinary memo equality, preserving downstream
owned children and independent refetch work when a memo output is unchanged.

The producer-local previous-value contract was accepted after the explicit
next/prototype comparison in stage 71. Dependency changes and repeated refreshes
are covered in `unified-previous-input.test.ts`.

The stage-74 cross-context contract is accepted for the experiment: preserve
staged history within a coordinated context, including entangled peers, but use
committed history when replacing work with a calculation in another context.
There is no saved stack of abandoned results or replay of lower reducer history.
Published optimistic values can still enter downstream calculation history;
expiration does not undo accumulation. This is not an event-delivery guarantee.
