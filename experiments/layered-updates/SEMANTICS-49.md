# Stage 49: optimistic outputs forward observation to their inputs

The user authorized exploring this rule after reconsidering stage 48: displaying
an optimistic prediction is not itself a reason to release the update that is
producing its input. An observed optimistic output now preserves observation of
its input in the consolidated reference model. The output still publishes its
override independently, subject to its ordinary downstream readiness.

This supersedes stage 48's choice to drop that observation. It does not restore
stage 47's overly broad rule that *all* affected calculations block publication.
Unobserved calculations still do not hold. The production coordinator has not
been changed or replaced in this stage; stores remain paused.

## Observable behavior and separate relationships

```js
const [first, guessFirst] = createOptimistic(() => 0);
const middle = createMemo(() => first() === 0 ? 0 : answer.promise);
const [second, guessSecond] = createOptimistic(middle);
createRenderEffect(first, showFirst);
createRenderEffect(second, showSecond);
```

One action guesses first=1; another guesses second=3. Both remain open.

| Step | New reference | Baseline next | Current production experiment |
| --- | --- | --- | --- |
| First guess; middle pending | 0 / 0 | 0 / 0 | 0 / 0 |
| Second guess; middle pending | 0 / 3 | 1 / 3 | 1 / 3 |
| Middle answers 2; both actions open | 0 / 3 | 1 / 2 | 1 / 3 |
| Child action ends; parent remains open | 1 / 2 | 1 / 2 | 1 / 2 |
| Both actions end | 0 / 0 | 0 / 0 | 0 / 0 |

The three accessor timelines were executed, not inferred. Ready input answers
still join the guessing action's lifetime, per the earlier ruling. Accordingly,
first can remain held after middle answers until the child action ends.

Observation is distinct from both value dependency and update membership:

- A boundary's observation edge says its incoming calculation is still needed.
- The edge serves no value, propagates no notifications, and performs no joins.
- The selected override and ordinary derivations of its output follow the
  existing common publication mechanism.
- Input readiness holds the update computing that input, not the independent
  override publication. This also works for sibling inputs and several depths.
- Inactive boundaries use ordinary dependencies. Pending probes do not forward
  input observation merely because their booleans are rendered.

A late ordinary reader of the held input can still read its coherent committed
frame. If every observer disappears and its inputs then publish, the old async
answer becomes unavailable; the stage-48 late-reader protection remains needed.

## Removal and action lifetime

The observation predicate is evaluated relative to the publication being judged.
A ready proposal in that publication can remove its own observer or replace its
owning frame. A proposed removal held by another publication has not removed the
currently displayed observer yet. Failed or unanswered passes do not establish a
successful removal of their old dependencies.

The first implementation revealed a separate old reference-model hold: a closed
action waited unconditionally for its guessed input, even after its last observer
was disposed. Both disposal and an action retiring its own observing child could
leave an ordinary source held forever. Action input waiting now uses the same
observation predicate. Explicitly open action bodies still keep their lifetime
open; losing an observer does not complete an awaited action body.

Correction can start before obsolete work derived from the guess finishes. A
parent's correction supersedes that work normally, even when a child override
forwarded observation to it. This avoids turning observation forwarding into a
wait for a prediction that is already being withdrawn.

## Implementation and cost controls

The new state is confined to the scheduler and optimistic boundaries:

- `inputObservers`: a map from an input to its active forwarding boundaries.
  Registration occurs on activation, not on every repeated guess. Expiration and
  disposal remove entries. No new ordinary node or dependency-link fields.
- `scopedBoundaries`: active action lifetimes, replacing global scans/filtering
  of every boundary. With no scoped boundaries, lifetime coordination returns
  without allocating a temporary waiting set.
- A publication check considers only unresolved inputs affected by that update.
  Unrelated active boundaries are not scanned for forwarding. Synchronous read,
  source creation, memo evaluation and dependency-registration code is unchanged.
- The downstream observation search runs only on that cold path. Its cache lives
  for one readiness check and is thrown away before any graph change or commit.
  Absence is cached only after the entire reachable search fails; encountering a
  recursive back edge alone never establishes absence. This avoids stale caches
  and repeated walks through a shared unobserved chain.

The candidate does not need a persistent observedness counter on every signal,
version maps on reads, a second value graph, or general layer traversal on reads.
The temporary query cache is reachability information for a single stable graph,
not value provenance. Cached and uncached executions have identical complete
publication traces in the new campaigns.

A production port should reuse the existing pending-node readiness path and
owner/frame lifetime information. The boundary registry can remain in the
optional optimism module, consulted only while judging pending input work. It
must not be inserted into the ordinary read path. This is a concrete porting
location, not an implemented production hook or a size/performance proof. The
reference's simplified effect and owner model is not a substitute for validating
actual scheduled effects, Loading, createDeferred, and error boundaries there.

## Validation

`UNIFIED=1 node --test experiments/layered-updates/reference/*.test.mjs`:
**168 pass**: 119 consolidated-model cases and 49 historical-model cases.

The 24 new cases cover both traversal orders, direct and conditional observer
removal, held removal under another update, equal-valued owner replacement,
siblings, four layers, pending-only readers, cancellation before obsolete answers,
and a closed action removing its own observer. Forty repeated action cycles
exercise matching answers, correction, rejection/recovery and bounded node,
subscriber, action and forwarding records. Four seeded campaigns exercise 480
operations changing observers and overlapping actions, replayed with and without
the readiness cache (960 operations total); every publication is checked and
cached/uncached traces are compared exactly. These are finite tests, not proof of
termination or general graph correctness.

The four previous observed-hold cases changed expected values explicitly to the
newly chosen semantics: parent=0 and late ordinary reader=[0,0] while the child
override displays 3. No consistency assertion was weakened. Their stage-48 form
is archived as `observed-holds-before.mjs`.

## Measurements, including limitations

All numbers below compare the reference with stage 48, **not production next**.
Fresh processes, alternating before/after order, the existing synchronous worker,
five process samples per case, and all raw within-process samples are retained.
The custom synchronous probes assert that no observation searches execute.

| Workload | After / before time |
| --- | ---: |
| Settled signal read | 1.018 |
| Settled memo read | 1.011 |
| Ordinary write/flush | 0.929 |
| Synchronous memo write | 1.009 |
| Chain | 1.025 |
| Diamond | 0.977 |
| Memo fan-out | 1.062 |
| Effect fan-out | 0.937 |
| Signal creation | 1.048 |
| Memo creation/disposal | 0.996 |
| Unrelated write beside 256 inactive boundaries | 0.608 |
| Unrelated write beside 256 active boundaries | 0.646 |
| Repeated guesses at depth eight | 0.937 |
| 64 unanswered inputs sharing an unobserved chain | 1.277 |

Removing global boundary/lifetime scans gives a substantial improvement in the
unrelated-boundary probes. The new semantic work still costs about 28% in the
unobserved shared-chain workload relative to stage 48, which does not forward
observation. Within the new policy, caching reduces this workload's time to
0.458 of the uncached implementation in a separate five-pair comparison.

Ordinary timings are not an acceptance pass: memo fan-out is about 6% slower in
the final sample, and bundled signal creation remains about 5% slower. Earlier
bundled creation samples were 11–13% slower, while a seven-pair unbundled diagnostic
was about 5% faster. The cause of this bundle-sensitive variation is unresolved;
unchanged creation code is not a substitute for measuring the production port.
Retained heap for 50,000 signal/accessor pairs is approximately 1,360 bytes each
in both reference versions (three alternating pairs), confirming no observed
per-signal memory increase, not absence of transient allocation or GC costs.

The whole reference adapter bundle grows from 17,420 to 18,725 minified bytes,
and from 5,268 to 5,595 Brotli bytes (+1,305 / +327). This is not a shipped Solid
bundle. Production sources and shipped bundles are unchanged in this stage;
the existing production feature-size deficit and the reference's earlier failure
to match production performance remain open. No threshold has been relaxed.

## Reproduction and artifacts

Artifacts: `results/forwarded-observation-stage49/`. It includes the pre-change
model, initial failures in action removal, the scan-all-boundaries implementation,
the uncached implementation, the final model, all audit timelines, raw timing and
heap data, and final tests. `final-cost/` has the final five-pair cost run.

```sh
UNIFIED=1 node --test experiments/layered-updates/reference/*.test.mjs
node experiments/layered-updates/unanswered-input-audit.mjs \
  /workspace/layered-solid/experiments/layered-updates/reference/scalar-runtime.mjs
FORWARD_SAMPLES=5 node experiments/layered-updates/measure-forwarded-observation.mjs \
  experiments/layered-updates/results/forwarded-observation-stage49/final-cost
node experiments/layered-updates/results/forwarded-observation-stage49/measure-query-cache.mjs
```

The cost runner expects `before.mjs` in its output directory; the retained
`final-cost/before.mjs` is the stage-48 snapshot. Stores and the production
coordinator replacement remain outside this checkpoint.
