# Publication across a separate ordinary hold

Historical stage-six results. See [SOURCE-OWNED-RESULTS.md](SOURCE-OWNED-RESULTS.md)
for the source-owned isPending prototype and subsequent validation.

The user approved letting pending-true publish using the committed value of a
separate pending ordinary input. The scalar prototype implements that decision
through the common optimistic-boundary machinery. This does not complete the
original experiment or establish performance/size acceptance.

## Observable behavior

```ts
const status = createMemo(() => isPending(x));
const label = createMemo(() => `${status()}:${y()}`);
```

Starting from x=0, y=0, an action proposes y=10 and stays open. Another action
then proposes x=1 and stays open. The displayed sequence is:

```
both open:       status=true,  y=0,  label="true:0"
y action ends:   status=true,  y=10, label="true:10"
x action ends:   status=false, y=10, label="false:10"
```

The public spelling above describes the intended behavior. Executable candidate
replays still use the private `createPending` helper; public window integration
has not been completed. Legacy lanes initially show true:0 but then also delay
y until x ends. The prototype no longer makes that lifetime connection.

If x ends first, pending-false is ordinary work again. Its shared derivation
consumes y's proposal, so those lower updates entangle and retain true:0 until
y can finish. This retains the existing ordinary coordination policy.

## Mechanism and corrections

An active boundary permits committed reads from separate ordinary holders,
while explicit directed relationships still govern optimistic parents and
siblings. New readers can discover the boundary after reading the held input,
so read order does not change publication. Direct render bindings retain their
existing committed-frame path instead of entering speculative derivation.

A separate holder read this way registers its derivations for re-evaluation
before that holder publishes. If the new result needs async work, it holds the
input. If a pending-true calculation is already running, the next calculation
supersedes it; an obsolete answer cannot publish.

`resumeInput` retires both guesses and pending-true overrides through ordinary
input work. Pending-false cannot retain an optimistic exemption accidentally.
Its retiring latch is keyed to the observed input's change, so joining another
still-open action does not itself restart pending-true.

A guess over a settled input uses its action scope as its input update. The
first implementation created/transferred a child transaction on every guess;
this was correct in the tests but regressed active writes by 1.9–2.8x. A
conservative `hasHeldNodes()` check restores the small path when only empty
action scopes exist. A later ordinary hold enables discovery under already
published overrides. This adds no ordinary-node fields or settled-read lookup.

A generated timeline caught a pending-false correction being routed as a new
optimistic update during the refinement. The ordinary fallback remains ordinary;
the failing coherence assertion was retained. Idle hooks now skip empty loops.

## Validation

- Full signals suite: 302 files, 5,250 passed, 22 existing expected failures,
  two skips. The old public F5b expected failure still belongs to legacy lanes.
- Expanded scalar campaign: 300 scalar seeds, 200 pending seeds in each of two
  configurations, and 100 branch seeds: 38,000 operation checkpoints. The added
  pending configuration observes only x while y remains an ordinary input.
- Twelve new deterministic cases cover both read orders, early/late mounting,
  both completion orders, async supersession before/after the first answer,
  cleanup, and guesses that precede or follow the separate ordinary hold.
- Production Chromium verifies both the synchronous agreed timeline and a
  suspended replacement. Independent DOM bindings and imperative reads agree;
  obsolete answers do not publish. Existing F5b and pending browser replays pass.
- TypeScript retains the same 26 pre-existing diagnostics; no new source or
  experiment-test diagnostics. No consistency assertions were weakened.

Finite tests do not prove all graphs. Persistent explicit-clear harness layers,
general dynamic discovery, overlapping answer provenance, additional lifecycle
cases and stores remain incomplete. Action-owned scalar boundaries are the
surface validated for the new foreign-input rule.

## Performance and size

Baseline: `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, Node 24.19.0. Five alternating
fresh-process samples, with no concurrent builds or tests. Active-write timings
below follow the no-held-nodes refinement, before the subsequent idle-loop guard.
Pending timings and bundles include that final guard.

| Workload, median ns              | Baseline | Candidate |
| -------------------------------- | -------: | --------: |
| Active guess, depth 1            |   1661.6 |    1205.3 |
| Active guess, depth 4            |   2888.2 |    2350.5 |
| Active guess, depth 16           |   7302.0 |    7537.6 |
| Inactive pending, ordinary read  |     6.40 |      6.40 |
| Inactive pending, ordinary write |    218.9 |     224.5 |
| Held input, depth 1              |   1510.8 |    1427.9 |
| Held input, depth 4              |   2416.2 |    2246.8 |
| Held input, depth 16             |   5162.6 |    5292.6 |

The large active-write regression is removed. Deep chains and idle writes still
show small median regressions; timing noise and incomplete workloads prevent
acceptance. Inactive-write ranges in this run remain separated (200.3–220.9 ns
baseline, 224.1–246.0 ns candidate), despite the improvement from the prior
approximately 10% median overhead. No threshold was changed.

Retained bytes per boundary remain high: pending callback 516 vs 1348, direct
source 529 vs 941, action-owned optimistic boundary 555 vs 1355. All five pending
memory samples collect all 30 disposed reader payloads during an open action;
baseline retains all 30 until completion. Both collect them after completion.
The lifecycle improvement does not excuse per-boundary memory. Transient
allocation samples have not been refreshed for this stage.

| Application bytes, minified / Brotli |      Baseline |    Candidate |
| ------------------------------------ | ------------: | -----------: |
| Ordinary                             |  21918 / 8116 | 22237 / 8238 |
| Optimistic                           |  27250 / 9864 | 26463 / 9766 |
| Pending                              | 28812 / 10419 | 27022 / 9913 |

Ordinary imports are still larger. Optimistic/pending comparisons have incomplete
API parity, so their smaller size is feasibility evidence, not acceptance.

## Next public-API decision

`pending-observer-coordination.mjs` characterizes two separate observations of
the same input, with async work derived only from the second. Both legacy and
the prototype currently delay both pending-true outputs until that work finishes.
There is no shared downstream memo between the two observations. Whether public
`isPending(x)` denotes one shared output or independent observation boundaries
matters before choosing caching and ownership for the public API. Existing
coupling alone is not a ruling; the user has not yet chosen that contract.

The callback-window gap remains explicit: `isPending(() => { x(); return 0; })`
probes x under the old API, whereas the private callback helper observes a
producer whose equal result stays settled. It is not advertised as API parity.

## Reproduce

From packages/signals:

```
LAYER_SEEDS=300 PENDING_SEEDS=200 BRANCH_SEEDS=100 ./node_modules/.bin/vitest run tests/unified-experiment.test.ts tests/unified-action.test.ts tests/unified-pending.test.ts tests/unified-foreign-input.test.ts tests/unified-coordination.test.ts tests/unified-outside-reads.test.ts --testTimeout=60000
```

From the repository root, run build.mjs, measure.mjs, measure-optimistic.mjs and
measure-pending.mjs under experiments/unified-updates sequentially. Then run
independent-pending.mjs, foreign-input-browser.mjs, browser.mjs and
pending-browser.mjs. The coordination question has its own executable script.
All work remains local.
