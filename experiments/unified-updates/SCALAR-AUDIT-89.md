# Stage 89: displayed dependencies survive speculative branch changes

Historical checkpoint: [stage 90](SCALAR-MILESTONES-90.md) fixes the fresh
Loading mount, validates the retained implementation, and records current cost
measurements and the remaining implicit-lifetime ruling.

This checkpoint completes classification of the selected migration corpus. It
does not complete the scalar implementation or meet performance/size acceptance.
Stores remain paused. No external changes were made.

## The timing investigation exposed a consistency defect

The original #3698-derived example used a memo creating an owned child. The
failure reproduced without that child, so ownership was not its essential cause.
Consider the following graph, with separate scheduled bindings for all outputs:

```ts
const [view, guess] = createOptimistic(() => false);
const [moving, setMoving] = createSignal(false);
const condition = createMemo(() => view() ? true : moving());
const details = createMemo(() => view() ? answer.promise : 0);
```

Start an action that guesses true and remains open. While `details` suspends,
both runtimes display `view=false, moving=false, condition=false, details=0`.
Then call `setMoving(true)`.

- Pinned next, and the candidate before this fix, display moving=true but leave
  condition=false. With view still false, condition must equal moving. This is
  tearing through an ordinary memo, without an observation/deferred boundary.
- The retained candidate holds moving with the replacement. When details
  answers, view, moving, condition, and details publish coherently.
- If instead `condition = createMemo(() => view() ? !moving() : view())`, the
  displayed branch does not depend on moving. Moving now publishes independently,
  matching next and resolving the original timing discrepancy.

An always-reading `view() !== moving()` variant also requires coordination.
Next publishes moving alone there; the candidate holds it. The original
upstream test remains unchanged. No consistency assertion was weakened.

Six production comparisons (each run against next and the candidate), with and
without the owned child, are in `results/scalar-stage89`. Pre-change candidate
traces are retained separately. `owned-frame-context-audit.mjs` reproduces them.

## Mechanism

The existing committed-dependency journal already distinguishes the displayed
frame from speculative dependency changes. The optional coordinator now uses it
when a lower update reaches a higher calculation:

1. A replacement dropping an input does not erase that input's obligation to
   the displayed result. Register preparation in the existing transaction rerun
   set, even if the replacement no longer reads that input.
2. Before the lower update publishes, check whether its change reaches the
   reader's committed dependencies. If it does, use the existing preparation
   and join path. If only the unpublished upper branch depends on it, allow the
   lower update to publish and refresh that branch afterward.
3. Active optimistic/observation boundaries stop this dependency walk. Their
   selected output can intentionally differ from their input. A proposal of the
   boundary's output itself still participates as an ordinary changed dependency.

Preparation is not a pending-value read. An initial attempt used `staleReader`,
whose flag also forwards pending demand; that wrongly reinstated holds released
by Loading or pending-only observations. The retained change queues preparation
without that flag. The existing pending/Loading expectations pass unchanged.

No ordinary node fields, ordinary read checks, or persistent maps were added.
The new graph walk and its temporary visited set run during coordination of
held calculations at different depths. Their worst-case cost remains relevant;
the measured ordinary-only bundle eliminates this code entirely.

## Validation

- Candidate suite with legacy lanes disabled: **446 pass, 0 fail**, with 34
  explicitly named baseline/legacy comparison cases excluded.
- The unchanged selected upstream corpus: **616 reported passes, 38 reported
  failures**, unchanged from stage 87. Two reported failures are upstream
  expected-failure assertions that now succeed (F5b and #3800).
- The normal-entry full suite: **5,672 pass, 0 fail, 2 skips**. It ran before the
  final one-test bookkeeping addition, which then passed separately and in the
  final candidate suite. Most normal-entry tests still exercise legacy APIs.
- 300 seeded overlap timelines, 60 operations each: **18,000 steps pass** on the
  retained runtime. This is finite evidence, not proof of graph correctness.
- Ten focused publication tests cover old/new/both-branch dependencies, owned
  children, intermediate memos, direct render readers, late mounts, and repeated
  lower writes. The displayed owner survives its held replacement and every
  created owner is cleaned exactly once.
- A replacement for the removed-lane-layout assertion verifies constant live
  scope `_nodes` and `_reruns` sizes across 500 successive guesses and ordinary
  publications. It does not rely on a legacy `_transaction._lane` existing.
- Paired pending-observer GC probes reclaim all 1,000 disposed payloads in both
  runtimes. These probes do not establish a universal absence of retention.
- Source TypeScript checking, production build, and diff whitespace check pass.
  The build retains the previously documented repository warnings.

Raw reports, rejected diagnostic controls, source hashes, the incremental patch,
production timelines, and measurement inputs/results are saved in
`results/scalar-stage89`.

## Cost against pinned next

Baseline remains a24e911ba5e571e7adb1c9b5e5151261f9cf101c. No benchmark uses an
earlier experiment as its performance baseline.

| Import scenario | Next Brotli bytes | Candidate Brotli bytes |
| --- | ---: | ---: |
| Ordinary/action | 8,116 | 8,057 |
| Optimistic | 9,864 | 11,405 |
| Pending | 10,419 | 12,043 |
| Latest | 10,368 | 11,909 |
| Refresh | 10,117 | 8,284 |
| Optimistic and refresh | 10,208 | 11,608 |

The ordinary and refresh-only bundles are byte-identical to the previously
measured candidate bundles; those paths gained no code from this change. The
stage-87 ordinary benchmarks remain the measurements for those bytes.

With an inactive optimistic primitive present, seven alternating fresh-process
pairs give candidate/next time ratios of 1.001 for memo reads, 0.952 for chains,
0.950 for diamonds, and 1.050 for memo creation/disposal. Run ranges overlap;
these do not establish precise portable speedups or a creation regression.

Three alternating pairs for writes to the deepest active override give ratios
of 2.408, 2.264, and 1.852 at depths 1, 4, and 16. Active optimism and feature
bundle size still fail acceptance. This checkpoint fixes coordination; it does
not solve those costs or justify relaxing the requirements.

## Remaining migration failures and the next coordination problem

`failure-review.json` classifies all 38 reported failures: 28 category 2
(intentional model differences, layout/order assertions, or improved expected
failures), eight category 4 (deferred outside-read behavior), one category 3
(provisional implicit lifetime for a guess made in a derivation), and one
category 1 implementation bug. Classification is not a claim that these tests
pass or that all scalar behavior is covered.

The category 1 bug is the fresh Loading mount. `fresh-owned-mount-audit.mjs`
adds separate scheduled input/open/view bindings to the upstream scenario:

1. An action holds input=1, with input=0 already displayed.
2. An independent update opens a new subtree containing Loading and a memo that
   reads the held input.
3. Next publishes open=true and fallback. The candidate retains open=false and
   the old closed view until the input action ends.
4. Both eventually show input=1, open=true, and content. No child callback fires
   prematurely in the paired production checks.

The discrepancy occurs with the producer both inside and outside Loading. It
is not explained by unusual component placement, sibling callback order, or
detached unscheduled setup.

The candidate's deferred join admission collects creation-time proposal reads
into the enclosing calculation. That prevents irreversible peer merges during
an attempt that later retries in an observation context, but also joins this
mount before Loading can catch its reader. A diagnostic control bypassing
`deferJoin` restores the original fresh-mount assertion. It simultaneously breaks
both observation variants of `unified-deferred-joins.test.ts`, where an abandoned
attempt must not entangle two actions. The bypass was reverted, not retained as
a Loading-specific exception.

This needs a coordination design pass before more API expansion: distinguish
accepting a newly created child's calculation from its owner consuming that
proposal, while preserving deferred irreversible joins until the owner's retry
decision is known. Existing next semantics remain the target for this case; no
new user ruling is required to investigate the implementation. Extra per-node
versions or an unconditional exception around Loading would not resolve that
underlying distinction. Stores and further API expansion remain paused.

### Follow-up probe: separate child transactions were rejected

A further actual-core probe gave each newly created computation a provisional
transaction. It collected its proposed reads separately and deferred their real
joins until the enclosing attempt was accepted. The owner joined that child's
transaction only through a read of its result. Source-owned observation outputs
kept their existing detached allocation behavior.

This restored the original fresh-mount assertion and passed all four deferred-
join cases. The other three tests in the fresh-mount file returned to their
existing result: the two reactive outside-reader cases passed, and the explicitly
deferred imperative observation assertion still failed.

It did not compose with the new owned-frame preparation cases. When the
displayed branch used the changed lower input, preparation repeatedly created
and admitted another child transaction instead of reaching a fixed point. A
temporary diagnostic capped candidate-update traversal and exposed the repeated
child records. The broader run did not terminate before an external timeout.
Those failures were not reclassified or turned into accepted assertions.

The probe and its diagnostic evidence are archived under
`results/scalar-stage89/rejected-child-scopes`. The source was restored byte for
byte to the validated stage-89 implementation; all diagnostic code was removed.
The focused restoration run covers ownership, Loading, deferred joins, and
long-lived bookkeeping. No performance or correctness acceptance claim uses
the rejected probe.

The next design pass should separate provisional read admission from allocating
a transaction for every child. The ordinary scheduler already has a pass-scoped
hold (`joinPassTx`/`passTx`) that does not inherently join the owner. The missing
piece is deferring irreversible joins until context selection is accepted while
still assigning the child's staging to the correct hold. Reusing that machinery
is preferable to treating every creation as a new independently published update.
This is an implementation direction, not a validated replacement or a new
semantic ruling.
