# Scalar experiment results — explicit-lifetime stage

Local prototype on `experiment/layered-updates`, based on
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`. **Not merge-ready.**

These measurements precede the action-lifetime adapter. Raw data for this
stage is preserved in `results/explicit-lifetime-stage1/`; see
[ACTION-RESULTS.md](ACTION-RESULTS.md) for the current experiment.

## Correctness exercised

- 21 focused tests, including an ordinary/layer equivalence case, repeated
  proposals, unrelated readers, late mounts, nested and sibling boundaries,
  independent parents, supersession, explicit expiration, errors/recovery,
  equal-valued owned-child replacement and 100 cleanup cycles.
- Expanded seeded campaign: 300 seeds × 60 operations = 18,000 observable
  publication checkpoints. Each compares direct output bindings with the
  corresponding values in a shared async derivation. No assertions relaxed.
- Full signals suite: 297 files; 5,192 passed, 22 existing expected failures,
  2 skipped. Existing `createOptimistic` still has its expected F5b failure;
  this tests the experimental adapter separately.
- Production Chromium DOM reproduction: baseline tears on unrelated rerun
  and late mount; candidate retains the last published output until the new
  async result is ready. `results/browser.json` records visible strings.
- Production GC check: 0/30 disposed reader payloads retained by a live
  boundary after the pending update completes, in all five measured samples.
- TypeScript: no candidate-only diagnostics. The package-wide check still
  reports the same 26 pre-existing test diagnostics as the baseline.

Finite tests are not proof for arbitrary graphs. Automatic action/input
lifetimes, overlapping answers, stores, SSR and replacement observation or
loading/deferred primitives are outside this prototype's validation.

## Measurements

Node 24.19.0, production Rollup + shared property mangling + esbuild
application bundles. Five alternating fresh-process samples; no simultaneous
build/test workload. Raw results and environment are in
`results/explicit-lifetime-stage1/`.

| Ordinary operation | Baseline median ns | Candidate median ns |
| --- | ---: | ---: |
| Settled signal read | 6.92 | 6.89 |
| Write + flush | 222.9 | 197.4 |
| Create signal | 54.5 | 63.0 |
| 20-memo chain write | 2765.7 | 2803.0 |
| Diamond write | 980.6 | 987.7 |
| Fan-out 100 write | 15423.0 | 15777.3 |
| Create memo | 605.5 | 678.9 |

These do not establish a performance pass. Creation medians are worse;
several ranges overlap broadly. No node fields or ordinary read lookup were
added, but bundle/layout and callback checks still need investigation.

| Optimistic synchronous write | Baseline ns | Candidate ns |
| --- | ---: | ---: |
| Depth 1 | 1528.5 | 954.2 |
| Depth 4 | 2864.1 | 2027.4 |
| Depth 16 | 7238.1 | 7105.7 |

This workload keeps a guessing action open and repeatedly writes a settled
override. Only the first boundary is overridden; the rest are nested
pass-through boundaries. It does not measure arbitrary concurrent holds.
The initial eager-transfer implementation cost 2743.6 / 5578.7 / 17963.8 ns
at these depths and was rejected. The settled ordinary-propagation path
removes transactions and walks from these updates.

With optimism imported and one inactive boundary, ordinary reads measured
6.53 → 7.06 ns and writes 203.5 → 207.3 ns. Retained boundary memory measured
555.7 → 1086.8 bytes. This two-node cost is measured, not waived.

| Application imports | Baseline min / Brotli bytes | Candidate min / Brotli bytes |
| --- | ---: | ---: |
| Ordinary scalar APIs + actions | 21918 / 8116 | 22041 / 8166 |
| Also optimistic boundary | 27250 / 9864 | 23494 / 8687 |

The ordinary comparison is feature-equivalent: +123 minified / +50 Brotli.
The optimistic comparison is **not feature-equivalent**: explicit lifetime
replaces automatic correction/action handling. Legacy `lanes.ts` is absent
from the candidate application's retained output, but remains in the source
for existing APIs. No size cap has been raised; neither performance nor size
acceptance is claimed.

`*-allocations.json` records V8 sampled allocation bytes, including collected
objects, from one additional run per build. These are estimates rather than
exact allocation counts; retained-heap measurements are separate.
