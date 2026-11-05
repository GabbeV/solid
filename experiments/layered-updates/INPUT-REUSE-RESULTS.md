# Input reuse, equal answers, and owned publication

This stage keeps the user's provisional upstream pending timing and refines the
scalar implementation. It does not establish mergeable performance, size or API
parity. All work remains local. Baseline runtime:
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`.

## Accepted pending timing

Starting with input=0, a published guess=1 and an unresolved input request:

| Incoming result, action still open | Displayed guess | Pending |
| ---------------------------------- | --------------: | ------- |
| No result yet                      |               1 | true    |
| 0, equal to the old input          |               1 | false   |
| 1, matching the guess              |               1 | false   |
| 2, a differing new input           |               1 | true    |

For the equal-input result 0, correction work begins when the action ends. The
user prefers retaining this upstream behavior while the experiment focuses on
propagation and publication, with permission to reconsider if preservation
needs substantial machinery. No special timing bookkeeping was needed.

An input configured with `equals: false` deliberately reports an equal result
as a change; its correction is pending instead. Both legacy and prototype
comparisons cover direct and wrapped accessors. This is the input's notification
policy, not a different publication mechanism.

Pending-false and its ordinary consequences remain coherent. If an async status
label holds the early false proposal, direct and late readers keep seeing true
until that label can publish with false. The guessing action can remain open
through that independent status publication.

## Implementation refinements

A canonical signal or memo accessor supplies the input node directly. Function
inputs still have a producer. That producer no longer adds a second equality
filter: selection and output equality decide the observable result. A second
filter could hide input notifications, making an accessor wrapper change
behavior. Existing input ownership and observation lifetimes are retained;
removing one boundary does not dispose another boundary's input.

A request starting is not an incoming answer. The selector does not retire an
override merely because its input calculation started running. This distinction
preserves the equal-answer timing when a request starts after the guess has
already published, including the production DOM replay.

The explicit-clear test API detaches the input dependency that its override
makes irrelevant, including retained links from the previous frame. The selector
owns no user child frame; those belong to its producer. Action-owned overrides
keep input notifications because incoming answers can correct them. This fixes
a false join between an override awaiting its own async consequence and an
update arriving through its unused input.

Source-owned pending observations now reuse their Layer record instead of
allocating a separate observation record. Shared evaluation and disposal code
replaces per-observation callbacks; a disposal callback is allocated once per
observed lifetime, not on every evaluation. No ordinary node gets a field,
version map or layer traversal.

## Common ownership correction

A new ordinary reduction, with no optimism, found a real publication mismatch:
an action proposes generation=1, its memo creates a child render effect from
that proposal, and the child displays 1 while the input still displays 0.
The same happens when the memo returns an equal value and only replaces its
owned frame. Baseline fails both reductions; the candidate passes.

The common staged-read path now records ownership when the creator actually
consumes a source proposal in an existing update. New owned children inherit
that hold before the first park. A broader attempt to decide ownership later,
at child creation, accidentally captured holds entered by other children and
was rejected. Generic store backing notifications also do not prove that a
source proposal was consumed; their existing visibility path remains intact.

This exposed two Loading integration regressions: a boundary manufactured a
fallback for a hold inherited from the computation creating the whole mount.
Its synthetic first-pass catch now distinguishes that inherited hold from real
pending work. Real async work still uses the normal status path. The correction
also fixes two pre-existing async-landing expected failures. Those are now
normal regression tests with their assertions unchanged. This is a narrow
integration correction, not a replacement of the Loading implementation.

## Validation and classification

- Expanded scalar campaign: 123 passed plus two legacy expected failures,
  ten files, 38,000 generated operation checkpoints (300 scalar seeds, 200
  pending seeds in each of two configurations, 100 branch seeds).
- Final full shared-adapter suite: **306 files, 5,296 passed, 22 expected
  failures, two skips**. Twenty expected failures predate this stage's input
  work; two characterize the legacy existing-reader/late-reader status tear.
  Two older loading expected failures were promoted to passing regressions.
- Fourteen input/lifetime tests cover lazy input revival and shared ownership,
  equal-answer notification policy, independent async pending-false publication,
  equal input replacements with owned children, and request-after-guess timing.
  Two further tests isolate the ordinary ownership defect without optimism.
- The private pending constructor's 36 targeted tests pass after record reuse.
- TypeScript has the same 26 pre-existing diagnostics, no new diagnostics.
- Production build and annotation checks pass. Chromium F5b, pending,
  foreign-input, equal/matching/differing input-status and ordinary owned-child
  replays pass. The ordinary baseline DOM shows input=0 / child=1 during the
  action; candidate keeps 0 / 0 and then publishes 1 / 1.
- Pending memory samples collect all 30 disposed reader payloads while an action
  remains open. Baseline retains those payloads until completion. The optimistic
  memory fixture collects all disposed reader payloads after completion.

The equal-input timing is an explicitly chosen provisional rule, not a new
consistency exception. Redundant filtering, premature retirement, incorrect
joining through unused input links, premature child publication and the extra
Loading fallback are implementation bugs addressed here. No consistency
assertion was weakened. Public package exports still use the legacy optimistic
and pending implementations; only explicitly adapted tests use the prototype.

Finite campaigns are not universal proofs. Source-owner death with escaped
readers, general callbacks, overlapping-answer provenance, complete Loading
composition, latest/refresh/affects, stores and SSR remain outside complete
validation. The hosted F5b example remains unavailable; the browser replay is a
local reduction. A green legacy suite is not new-API parity.

## Measurements

Node 24.19.0, the repository's production build and property mangling, the same
application bundler for baseline and candidate. Timing and retained-memory
workloads use five alternating fresh processes, without concurrent tests or
builds. Allocation sampling uses three alternating processes and includes
collected objects. Final artifacts are in `results/input-reuse-stage9-final/`;
`input-reuse-stage9/` records the earlier version before record compaction and
the Loading integration fix.

Ordinary imports:

| Median time, ns  | Baseline | Candidate |
| ---------------- | -------: | --------: |
| settled-read-ns  |     6.89 |      7.05 |
| write-flush-ns   |   225.52 |    221.10 |
| create-signal-ns |    63.68 |     64.86 |
| create-memo-ns   |   701.20 |    691.57 |
| chain-write-ns   |  2716.49 |   2865.33 |
| diamond-write-ns |   988.21 |    918.81 |
| fanout-write-ns  | 17384.77 |  15768.54 |

Optimistic updates:

| Median time, ns           | Baseline | Candidate |
| ------------------------- | -------: | --------: |
| Wrapped input, depth 1    |  1706.58 |   1181.74 |
| Wrapped input, depth 4    |  2812.27 |   2554.05 |
| Wrapped input, depth 16   |  7134.28 |   7752.96 |
| Direct accessor, depth 1  |  1654.57 |   1292.98 |
| Direct accessor, depth 4  |  2776.42 |   2175.21 |
| Direct accessor, depth 16 |  6879.22 |   5383.47 |

Pending observation:

| Median time, ns        | Baseline | Candidate |
| ---------------------- | -------: | --------: |
| inactive-read-ns       |     6.95 |      7.30 |
| inactive-write-ns      |   220.41 |    233.24 |
| observed-sync-write-ns |   406.83 |    436.09 |
| held-input-depth-1-ns  |  1680.63 |   1533.67 |
| held-input-depth-4-ns  |  2185.38 |   2516.71 |
| held-input-depth-16-ns |  6010.99 |   5876.11 |

Direct-input optimism improves at depths 1, 4 and 16. Wrapped depth 16 remains
slower. Ordinary and pending timings have overlapping and sometimes wide ranges;
prior batches changed the sign of several small median differences. These data
do not establish zero ordinary overhead or acceptance. Raw min/max samples are
retained rather than selecting the most favorable batch.

| Retained bytes per fixture                 | Baseline | Candidate |
| ------------------------------------------ | -------: | --------: |
| Optimistic boundary over a function        |    555.7 |    1297.1 |
| Optimistic boundary over a common accessor |    568.0 |     946.0 |
| Distinct signal plus observing memo        |    737.3 |    1525.0 |
| Many observing memos sharing one source    |    529.1 |     528.8 |

Record compaction reduces the distinct-source candidate fixture from roughly
1,693 to 1,525 bytes. This is still substantially more than baseline. The
accessor-boundary optimization removes a redundant full producer; arbitrary
function inputs still pay for two full nodes. The prototype additionally exposes
its private clear helper. These are retained-heap estimates, not object counts.

| Sampled allocated bytes/write, median | Baseline | Candidate |
| ------------------------------------- | -------: | --------: |
| ordinary                              |    733.0 |     729.5 |
| inactive                              |    664.8 |     662.5 |
| layer-1                               |   1428.5 |    1599.0 |
| layer-4                               |   1358.2 |    1496.1 |
| layer-16                              |   1349.6 |    1094.2 |

The allocation workload uses direct-accessor layers; it is not the wrapped-input
timing workload. Sampling has uncertainty; source-owned pending allocation is
not separately profiled here.

| Application minified / Brotli bytes |      Baseline |     Candidate |
| ----------------------------------- | ------------: | ------------: |
| ordinary                            |  21918 / 8116 |  22320 / 8238 |
| optimistic                          |  27250 / 9864 |  27084 / 9969 |
| pending                             | 28812 / 10419 | 28469 / 10322 |
| loading                             |  26140 / 9584 |  26616 / 9750 |

Ordinary and Loading imports remain larger. Optimistic minified size is slightly
smaller but Brotli is larger; pending is smaller, with incomplete feature parity.
The ordinary comparison is feature-equivalent; the experimental optimistic and
pending comparisons are feasibility measurements. No size thresholds or
performance expectations were relaxed. **This stage is not mergeable acceptance.**

## Reproduce

From `packages/signals`:

```
PENDING_API=shared LAYER_SEEDS=300 PENDING_SEEDS=200 BRANCH_SEEDS=100 ./node_modules/.bin/vitest run tests/layered-*.test.ts --testTimeout=60000
PENDING_API=shared ./node_modules/.bin/vitest run
```

From the repository root, run serially:

```
node experiments/layered-updates/build.mjs
node experiments/layered-updates/measure.mjs /workspace/layered-baseline
node experiments/layered-updates/measure-optimistic.mjs
node experiments/layered-updates/measure-pending.mjs
node experiments/layered-updates/measure-allocations.mjs
node experiments/layered-updates/optimistic-pending-question.mjs
node experiments/layered-updates/optimistic-pending-browser.mjs
node experiments/layered-updates/owned-proposal-browser.mjs
```

The last two Node tests added to the baseline checkout intentionally fail there;
the baseline runtime remains at the stated commit. Nothing was pushed or posted.


## Follow-up: ordinary signal storage and shared selector (stage 10)

The upstream pending-release choice remains provisional and unchanged. It did
not need special timing bookkeeping. This follow-up reduces retained storage;
it does not add APIs or resolve the remaining acceptance gaps.

Plain signals and store slots no longer carry `_time`, a creation-clock field
that their setters never advanced. Computations retain it for recomputation,
error retries and async-answer provenance. The prototype already uses the
notification epoch for signal inputs. The type now reflects that separation.
The ordinary public signal fixture falls from approximately 352 to 344 retained
bytes in every sample. In this batch median signal creation is 59.27 ns baseline
versus 44.99 ns candidate; other ordinary timings remain mixed, so this does not
establish an overall speedup.

The shared boundary selector now binds a common function instead of retaining
an individual constructor closure and its captured environment. This changes
only boundary construction. Compared with stage 9, retained bytes per candidate
fixture fall from 1297 to 1234 for function-input optimism, 946 to 880 for
common-accessor optimism, and 1525 to 1453 for a distinct signal plus pending
observer. Baseline remains about 556, 568 and 737 respectively. Sharing a pending
source across many observers remains approximately equal to baseline.

The selector extraction adds 54 minified bytes compared with stage 10's
signal-only reduction. Final application minified / Brotli sizes are:

| Scenario | Baseline | Candidate |
| -------- | -------: | --------: |
| ordinary | 21918 / 8116 | 22315 / 8237 |
| optimistic | 27250 / 9864 | 27133 / 9979 |
| pending | 28812 / 10419 | 28518 / 10344 |
| loading | 26140 / 9584 | 26611 / 9750 |

Ordinary imports remain larger than baseline; there is no acceptance claim.
The active depth-16 optimistic median is 5372 ns for direct input versus
6805 ns baseline, but 7419 ns for function input versus 6870 ns baseline.
Pending depth-16 is 6101 ns versus 5500 ns baseline in this batch. The spread
and changing signs across batches remain visible in the saved samples.

`results/signal-storage-stage10/` preserves the signal-only change, including
five ordinary timing/memory samples. `results/selector-storage-stage10/` preserves
the final application bundles, sizes and five alternating optimistic/pending
samples. The latter's ordinary measurements are the signal-only measurements:
the extracted selector is absent from the ordinary bundle. Both memory campaigns
still collect all disposed reader payloads after completion; the candidate
pending campaign also collects them during the open action.

The build script now accepts `--all-tiers` to rebuild dev, observe and production
artifacts together. This matters for the signal literal parity checks: a new
production artifact must not be compared with a stale observe artifact.


Stage 10 validation: all three tiers build; the full suite passes 5,296 tests
with 22 expected failures and two skips across 306 files. TypeScript retains
26 pre-existing diagnostics, none in the prototype. The F5b, pending and
optimistic-input pending Chromium replays pass. Early pending release was tested
with equal, matching and differing incoming results, including late readers.


Further ordinary-node compaction, the scalar build without core legacy lane
branches, and final measurements are in [SCALAR-CORE-RESULTS.md](SCALAR-CORE-RESULTS.md).
