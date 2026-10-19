# Allocation-free candidate for SOLID-HELD-FUNCTION-VALUE-003

This supersedes the original wrapper candidate, not the pinned runtime. Nothing
has been pushed, filed, or applied to the Bend translation. Solid remains pinned
to d2ad8b288886a5c7171e6746ccc019ad1d08d8ab and active deviations remain empty.

Local worktree: `/workspace/solid-held-function-experiments`. Branch:
`fix/held-function-values-allocation-free`. Commit: `824006e2a9744282179132e72e11f5df2a1077fc`.
The [patch](held-function-value-allocation-free.patch) applies to the pristine pin
with `git apply --unidiff-zero`; it includes the regression tests and changeset.

## Design and order

Keep both public setter function declarations and the existing bound setters.
Factor the old `setSignal` body into a private `writeSignal` helper. The public
two-argument `setSignal` delegates without a mode. `setMemo` keeps its original
held predicate and evaluates a held updater against `_value` at the original
point, then tells the private helper that its argument has already been resolved.

The private flag prevents interpreting a returned function as another updater.
It introduces no wrapper or other per-write allocation, and it does not escape
through the public setter. The public setter's arity and treatment of surplus
JavaScript arguments remain as before. No extra node fields or per-signal closure
environments are introduced.

| Case | Updater runs | Comparator's previous value |
| --- | --- | --- |
| Held writable derivation | Before writeHook, using the committed value | Current pending/committed slot captured after writeHook |
| Ordinary signal or non-held writable memo | After writeHook, using the current slot | Slot captured before running the updater |

The original lane hook, equality gate, snapshot capture, staging, notification,
heap and scheduling order remain in place. In particular, moving the held
updater into an ordinary post-hook normalization would change reentrant behavior;
this candidate does not do that.

The constructor change shares the accessor/bound-setter return used by the data
and function-initializer branches. Both still create their node first, perform
the same branch-specific flag/registration work, create the accessor, then bind
the selected setter. This offsets most of the private helper's byte cost. The
correctness change lives in core; constructor consolidation is a separable size
optimization. Both branches retain native bound setters.

## Validation

The twelve function-value cases and twelve new ordering cases pass. The latter
cover reentrant write hooks, the comparator's captured frame, throwing updaters,
and throwing hooks for plain/writable and held/non-held cases. Against the pin,
three function-value cases fail and the other twenty-one cases pass.

All 315 signals test files pass: 5,371 tests pass, three expected failures and
two skips. Development, production and observe builds, property mangling, purity
checks and source declarations pass. The strict public function-storage snippet
passes. The full test-tree type check reports the same thirty baseline
diagnostics, compared by relative file, code and complete message; none are in
the changed source or regression tests. Formatting, release invariants, the four
signals size comparison gates and applying the patch to a pristine pin all pass.
This validates the signals package, not a repository-wide compiler/examples build.

## Measurements and discarded layouts

[Size results](held-function-allocation-free-size.json) retain the measured
layouts. [Benchmark results](held-function-allocation-free-benchmark.json) retain
raw samples, controls, rejected candidates and later validation runs.

- A direct extra argument on the bound public setter leaked the internal mode
  through surplus JavaScript arguments; the private helper avoids that change.
- Splitting preparation, normalization and value storage cost 80–113 minified
  bytes in the first layouts. An unshared private flag cost 36 bytes.
- Sharing updater classification produced smaller bundles, but moving more work
  into the common setter exposed timing regressions in some microbenchmarks.
- A per-signal arrow entry improved several write measurements but retained 24
  additional bytes per numeric signal pair and slowed the construction stress
  case. It was discarded.
- Some early classification prototypes needed an explicit TypeScript refinement
  after normalization. Production measurements of these discarded prototypes
  are diagnostic evidence, not claims that their source/type checks passed.
- The selected design preserves the original held pre-evaluation and both
  public function declarations. Its conditional normalization also gives
  TypeScript a resolved `T`, without an extra runtime alias.

Selected size delta: **+11 minified bytes**, **+12 with store**, relative to the
pin, compared with +9 for the wrapper candidate. Brotli deltas are +29/+20/+20/+14
bytes for core/store/pending/until respectively. The existing upstream comparison
gate passes all four signals scenarios without changing caps; these are within
its recorded minified allowance, not within every absolute brotli cap. The whole
compiled app size matrix was not run.

In the matched three-process comparison, the median of process medians for
3,000,000 held numeric updater calls was 112.15 ms on the pin, 123.11 ms with the
wrapper (+9.8%), and 114.67 ms with the selected private flag (+2.2%). Ordinary
staged updater/value calls measured approximately 0% / -0.7% relative to the pin;
held raw-value writes measured +1.4%. These small differences are observations,
not evidence of universal neutrality. Seven further cases, including flushed
writes and changing held proposals, are in the raw record.

Three fresh-process numeric-signal construction runs retained approximately
352 bytes per signal pair on both versions. Median construction times varied
between runs (base 6.92/8.92/9.70 ms; candidate 8.18/7.36/6.24 ms per 100,000
pairs); they do not show the extra environment cost found in the rejected
per-signal-arrow design.

These are Node 24.19.0/V8 production microbenchmarks on Linux x64, with one
variant/case per fresh process, CPU affinity, warmup, seven samples, and repeated
processes for the principal cases. The original held numeric updater case
mostly exercises the equal-value fast path after the first write; a separate
alternating-updater case exercises changed proposals. They are not application
benchmarks or a performance-equivalence proof. Some unchanged plain-signal paths
in the wrapper control also show large timing scatter, so isolated large
differences must not be attributed confidently to the source edit. The initial
9% figure was one measurement, not a library-wide performance conclusion.

## Reproduction and translation impact

`repros/solid-signals/held-function-variants.py SOLID_CHECKOUT OUTPUT_DIR` generates
the experimental source snapshots from the immutable pin without editing the
checkout. The selected snapshot is `private-common-resolved`. Build an isolated
checkout's signals package with its existing Rollup/mangling/purity/declaration
pipeline before measuring. Use the pinned upstream Rolldown size harness with
`SIZE_PACKAGES_ROOT` pointing at that checkout.

The saved scripts accept module paths rather than hardcoded worktrees:

```sh
BENCH_CPU=2 node repros/solid-signals/bench-held-setters.mjs results.json \
  base=/absolute/base/packages/signals/dist/prod/index.js \
  fixed=/absolute/fixed/packages/signals/dist/prod/index.js
node --expose-gc repros/solid-signals/bench-signal-construction.mjs \
  /absolute/fixed/packages/signals/dist/prod/index.js
```

`BENCH_CASES` can select comma-separated cases. Omit `BENCH_CPU` where `taskset`
is unavailable. For size comparison run the same four `signals:` scenarios on
both builds and feed their JSON files to upstream `scripts/size/gate.mjs`.

The source-impact report identifies `core/core.ts:setSignal`, `setMemo`, the new
private `writeSignal`, and `signals.ts:createSignal`. The first and last have
partial Bend mappings; setMemo remains unported. A future adoption requires
operation/branch review of those definitions and relevant parity tests. The
existing Bend proofs and twelve preserved source-only bug cases still concern
the unchanged pin. This candidate establishes no TS/Bend equivalence claim.
