# Action-lifetime experiment

Historical stage-two measurements. Current observation work and outstanding
failures are recorded in [PENDING-RESULTS.md](PENDING-RESULTS.md). Raw data for
this stage is archived in `results/action-lifetime-stage2/`.

The user's working direction is derivation entanglement without rebasing.
The scalar adapter now supports `createLayer(input, { lifetime: "action" })`.
This remains an experimental API, not a complete `createOptimistic` replacement.

An updater runs once. The output can publish its guess ahead of its action;
a later input change retires the override into that action's ordinary update.
Input, corrected output and required async consequences then publish with
the action. Body completion similarly retires remaining overrides before
the common commit machinery judges the update. No new value, child-frame or
async commit path was added.

## Validation

- 15 added tests: 7 baseline/adapter pairs and one adapter repeated-guess
  regression. They exercise matching/differing answers, functional-updater
  call counts, unrelated updates, late readers, async correction, async input
  completion, expiration requiring async restoration and a nested semantic
  difference described below.
- All 21 earlier explicit-lifetime tests still pass, including their normal
  30-seed / 1,800-checkpoint campaign. The earlier expanded 18,000-checkpoint
  run predates this adapter and is not an action-lifetime fuzz campaign.
- Full signals suite: 298 files; 5,207 passed, 22 existing expected failures,
  2 skipped. No new TypeScript diagnostics relative to the baseline.
- Production Chromium reproduction passes with the action-lifetime adapter.
- Production memory check: all five samples collected every disposed reader
  payload after completion while keeping its boundary alive.

After the outside-read clarification, two additional ordinary/layer tests
compare imperative accessor reads with separate rendered bindings and their
combined async derivation at each hold/publication checkpoint. Those and the
15 action tests pass together. The Chromium replay now clicks an actual
inspection button at every checkpoint and compares the event handler's reads
with the DOM; the action-lifetime candidate passes. These tests cover plain
accessors, not replacement `latest`/`isPending` APIs. No runtime changes were
needed for this committed-read contract. Preserving the legacy imperative
flushed-value exception is explicitly deferred; see `MODEL.md`.

## Accepted nested behavior without rebasing

`first` guesses 1; `second`, whose input is `first * 2`, guesses `x => x + 1`.
The rendered values are first 1, second 3. With both actions still open,
the first action guesses 2.

- Existing lanes immediately show first 2, second 4, correcting the child's
  guess without waiting for its action.
- The adapter shows first 1, second 3 until the child's action ends, then
  first 2, second 4. This applies ordinary-input entanglement to an optimistic
  input as well.

Both outcomes are characterized explicitly; neither test permits direct
and combined readers to disagree. The user accepted the adapter's behavior
without rebasing, making this an intentional semantic change rather than
a baseline correctness assertion weakened to pass the adapter. Future
rebasing could instead preserve the child's increment and publish first 2,
second 5 while the child action stays open; no rebasing is implemented here.

Overlapping-action answer provenance, all ordering cases for pre-existing
input holds, observation APIs and stores remain unvalidated. No performance,
size or general correctness acceptance is claimed.

## Measurement update

Production application bundles now instantiate the action-lifetime mode.
Five alternating fresh-process samples, without concurrent test/build work.
Raw data is in `results/`; earlier explicit-lifetime data is archived below it.

| Ordinary operation | Baseline median ns | Candidate median ns |
| --- | ---: | ---: |
| Settled read | 6.85 | 6.31 |
| Write + flush | 213.9 | 211.3 |
| Create signal | 60.1 | 146.0 |
| Chain write | 2594.3 | 2859.3 |
| Diamond write | 869.2 | 927.1 |
| Fan-out write | 15592.8 | 14804.3 |
| Create memo | 578.4 | 677.1 |

Creation is an unresolved regression/noise concern: candidate signal samples
span 59.6–226.0 ns and baseline 59.0–135.9 ns. The current harness cannot
establish acceptance. Ordinary node representation is unchanged, but this
does not excuse measured regressions. Inactive optimism measured reads
6.40 → 6.72 ns and writes 211.3 → 227.4 ns.

Active synchronous writes measured 1523.5 → 1072.9 ns at depth 1,
2714.1 → 2318.4 ns at depth 4, and 6505.4 → 6926.3 ns at depth 16.
Only the first boundary is overridden in this workload; the others are
nested pass-through boundaries. Concurrent holds are not represented.
Retained boundary memory is 555.5 → 1143.0 bytes.

Ordinary bundle: 21918 → 22062 minified bytes; 8116 → 8170 Brotli bytes.
Optimistic bundle: 27250 → 24093 minified bytes; 9864 → 8898 Brotli bytes.
The latter still lacks features of the baseline and is not a feature-equivalent
size win. Size caps and performance expectations have not been changed.
