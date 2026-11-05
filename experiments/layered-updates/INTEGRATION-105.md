# Normal package integration — stage 105

This checkpoint runs the shared engine through the real package entry, builds,
existing Vitest suites, JSX renderer, existing benchmark workloads, and existing
bundle-size gates. It is **not full API or merge acceptance**. Optimistic stores
are not migrated, `until` is deferred, and the observation bundle exceeds its
unchanged cap. No cache or pool has been introduced.

The comparison is pinned next `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`
in `/workspace/layered-baseline`. Its tracked source is unchanged. Raw logs,
JSON reports, and rejected trials are in `results/integration-stage105/`.

## Runtime and build

- Normal `createOptimistic`, `isPending`, `latest`, and `refresh` exports use
  `src/layers`. `LEGACY_LANES` is false in every normal build. The old lane code
  remains in source during store migration; it is not a second working engine.
- The experimental scalar entry, separate build target, and compatibility
  configs are retired. The regression tests import the normal public API.
  Explicit-layer adapter tests still exercise that adapter, backed by the same
  engine. They no longer label the public API as a baseline implementation.
- Plain stores and projections use their existing implementation with shared
  scalar coordination. `createOptimisticStore` throws an explicit migration
  error. Its tests remain visible failures. `until` throws a deferred-API error.
- Rollup now uses the existing `tsconfig.build.json`, excluding tests from the
  package build. This also eliminates the lingering TypeScript watcher seen
  with the broad config. This build fix is independent of runtime performance.
- A clean normal build and property-mangling pass are required. Old generated
  artifacts were moved to `retired/dist-before-clean`, not reused as results.

The workspace originally resolved the public packages into another checkout.
Local dependency links now point at this checkout's package outputs; external
dependencies remain linked to the installed dependency tree. The original link
targets are recorded in `dependency-links.json`.

## Integration fixes retained

- Refreshing a source and disposing it before delivery no longer retries
  forever. The existing root/disposal regression now also awaits the refresh.
- `affects` wakes source-owned pending outputs. Untracked store probes also
  receive declarations covering captured and symbol-keyed descendants.
- Projection observation windows subscribe to the producer's observation
  output, including when the producer is currently settled.
- A new render binding with no committed value holds the memo that returns its
  subtree. This fixes the blank binding exposed by real compiled JSX. Merely
  creating an unused memo still does not consume a proposal.
- Diagnostics and attribution recognize shared observation outputs, including
  strict reads, holds, guesses, and reversions at publication. Loading's dev
  diagnostic recognizes explicit display-ahead dependencies.
- F5b is a passing test, not an expected failure. Sibling callback order is
  still unspecified; the mount regression checks the final view channel.

## Rejected observation preparation trial

The existing `loading-on-rearm-reveal-3540` test identifies excessive joining:
an independent data request remains held after `on: () => latest(dep)` rearms
Loading during a separate open action. Next reveals the ready independent data.

An attempted fix kept staged latest values out of ordinary propagation and
prepared them through the observation layer before commit. It fixed that
Loading case, but wider tests exposed intermediate `[true, newValue]` frames
from `[isPending(() => latest(data)), latest(data)]`. They must not be dismissed
as intentional. A broader status-preparation attempt also exposed a retry at an
unchanged context and was rejected. Retiring pending into latest's new update
then entangled that update with the lower request and prevented early reveal.

`rejected-observation-preparation.patch` preserves the final trial, not an
accepted fix. The retained implementation preserves the earlier coherent,
over-entangled behavior. Next work should examine how observation outputs
detach lower proposals before restoration, rather than add exceptions to
individual Loading cases. The existing atomicity assertions are unchanged.

## Functional setter decision

`functional-guess-held-input.test.ts` reduces an existing createOptimistic
failure. Start with source/view both 0. Action A stages source=10 and stays open.
Action B calls `guess(previous => previous + 1)` and stays open.

The user chose next's behavior: pass previous=0 and publish view=1 beside
source=0. Implemented by removing the fallback to the output's pending input
slot. Existing guesses still compose with their preceding proposal, including
one held by downstream async. This adds no fields or ordinary-read work.

`setter-ruling.json` records 508 passing focused tests, including the two new
functional setter regressions. The normal build, property mangling, pure-annotation checks, and declaration
emission also pass after the fix. The full-suite numbers below predate this fix.

## Ready-but-unpublished pending review

`pending-ready-held-output.test.ts` isolates an existing checkout failure:
two async memos feed one total; the left answer arrives while the right remains
pending. Next displays pending=true for ordinary updates but pending=false for
optimistic updates, although the total still displays its old value in both.
The shared implementation displays true in both cases. Next's verdict code
explicitly checks only the active flight for lane derivations, whereas ordinary
held nodes also check a differing unpublished value. This is a real observable
semantic difference, not merely a computed-but-discarded pending frame.
Final ruling: after the equal-versus-different answer comparison, the user
identified next's unequal-answer early release as a bug. A ready answer that
differs from the displayed value remains pending until publication, equally
for ordinary and optimistic updates. An equal ready answer can clear pending
while a sibling still holds publication. The existing equality comparison
already implements this; no compatibility exception or added machinery is needed.
The user filed the upstream bug as [solidjs/solid#4685](https://github.com/solidjs/solid/issues/4685).
The published rc.21 reproduction is https://s.olid.uk/id/U6ma1avLRKuXWGhrzWMEkQ;
its open action prevents a later reset, while the two answers still resolve in sequence.

The checkout assertion now requires true, including effect callbacks; no value
consistency assertion is weakened. The rejected compatibility trials and their
comparison logs are retained as investigation evidence, not as proof that
compatibility must be expensive. `pending-resolution.json` records 512 passing
focused tests, and the existing checkout test also passes individually.

A separate composition bug was fixed: pending(latest(optimistic)) previously
looked only one boundary down and missed the optimistic input's question.
Pending now follows the existing explicit input-boundary links when sampling,
subscribing, and finding the holding update. No ordinary dependency walk, new
node field, or ordinary read/write branch is introduced. Tests cover several
latest layers and matching/differing incoming answers. Broader validation is
recorded in the subsequent reports; these results do not resolve the independent
latest/Loading over-entanglement described above.

The direct-accessor pending fast path now has the callback window's initial-load
handling: an unowned initial-load probe returns false, while an owned pending
read still suspends its boundary. This fixes A16 and V3 using the existing
context and error type; it does not restore the deferred flushed-value exception.
A rejected broad catch swallowed internal context retries. Narrowing the direct
catch exposed the same existing hole in callback windows; the retry matrix now
covers both direct and wrapped accessors across sync, promise, iterator, and
owned-child variants. The existing retry sentinel is shared with observation
windows, which rethrow it instead of completing a body with mixed input versions.
No new per-node state or ordinary read branch is added. All 538 focused tests in
`pending-retry-retained.json` pass.

Two further test migrations preserve full publication histories:
- The correction/re-guess regression now records the extra callback applying a
  freshly allocated array containing the unchanged visible value. The abandoned
  re-guess must still never publish. This duplicate callback remains a possible
  optimization, not a claimed performance improvement.
- The late-reader correction regression uses the shared memo's already-published
  optimistic output, then follows its correction. It no longer treats a displayed
  output as uninitialized beneath a separate lane slot. Existing-reader,
  untracked-reader, error, and request-count assertions are retained.

Two test migrations now distinguish computation from publication:
`latest-isPending-consistency` no longer requires reapplying an unchanged
pending/data pair, and `loading-value` records effect callbacks instead of
abandoned computations. Their coherence assertions remain enforced.

## Equality clarification

The subsequent equality comparison covers both equal and differing answers
while the sibling still holds publication. With displayed left=0:

| Answer | Update | Next pending | Shared pending |
| --- | --- | --- | --- |
| 0 | ordinary | false | false |
| 0 | optimistic | false | false |
| 10 | ordinary | true | true |
| 10 | optimistic | false | true |

All four assertions pass in each checkout with its characterized expectations
(`pending-ready-equality-{next,candidate}.log`). The shared implementation already
uses the configured equality comparison; retaining equal-answer early release
requires no additional machinery. The differing-answer early release in next's derived-lane branch is now
classified as an upstream bug by the user. The shared rule is settled on that
basis, superseding the earlier provisional complexity argument.

## Retained observation follow-up

The retained build is `build-observation-final.log`; source and declaration
checks, private-property mangling, pure annotation checks, and diff whitespace
checks pass. Normal full-suite reports are `*-observation-final.json/log`:

| Suite | Passed | Expected failures | Failed | Skipped |
| --- | ---: | ---: | ---: | ---: |
| signals | 4,014 | 18 | 1,698 | 2 |
| solid | 833 | 0 | 23 | 0 |
| web | 1,225 | 1 | 105 | 0 |

Compared with the preceding stable integration reports, signals has 15 fewer
failing tests after fixes and explicit migrations, plus 29 additional tests.
None of these three suites has a newly failing test. The signals run still
reports 70 unhandled deferred-until errors. This is not a green full API suite.

`failure-review-observation-final.json` classifies the remaining signals first
failures: 1,645 deferred/unmigrated cases, 52 intentional semantic differences
still awaiting test migration, and one identified implementation bug: the
latest/Loading independent-content reveal described earlier. This counts known
first failures, not all possible failures behind those assertions or a proof
that no other semantic holes remain. The conditional pending compatibility
choice is documented above rather than hidden in a skipped test.

Existing size harness (`size-observation-final.json`), versus pinned next:

| Scenario | This build Brotli | Next Brotli | Existing cap |
| --- | ---: | ---: | ---: |
| Ordinary core | 7,433 | 7,439 | 7,450 |
| + ordinary store | 14,694 | 14,706 | 14,710 |
| + isPending/latest | 11,516 | 9,692 | 9,730 |

Ordinary bundle measurements remain unchanged by these observation fixes.
The feature scenario exceeds the existing cap by 1,786 bytes; no cap was raised.
No new timing claim is made in this follow-up. Pending boundary chains add
subscriptions for the existing input links they must observe; no ordinary node
field, ordinary read branch, origin map, cache, or dependency-wide walk was added.

## Running the existing tooling

From `packages/signals`:

```sh
node node_modules/rollup/dist/bin/rollup -c
node scripts/mangle-props.mjs dist/prod dist/observe
node scripts/check-pure.mjs dist/prod
node scripts/check-pure.mjs dist/observe
node node_modules/typescript/bin/tsc -p tsconfig.build.json --emitDeclarationOnly
node node_modules/vitest/vitest.mjs run --maxWorkers=4
taskset -c 4 node node_modules/vitest/vitest.mjs bench --run tests/core/creation.bench.ts tests/core/reactivity.bench.ts --outputJson bench.json
```

These are the repository's normal config and workload files. Benchmark mode
imports the built production artifact and rejects a stale build. The timing
workloads cover ordinary creation, writes, chains/fan-out/diamonds and plain-store
creation; they do not establish optimistic-update performance or retained-memory
acceptance. No custom experiment workload substitutes for them.

Run the existing size harness from `scripts/size`:

```sh
node size.mjs 'signals:'
SIZE_PACKAGES_ROOT=/workspace/layered-baseline node size.mjs 'signals:'
```

The web tests use the published rc.14 native compiler binary, verified against
the registry integrity value, via `SOLID_COMPILER_NATIVE`. Thirty failures in
element-claims and select-async-value also reproduce with pinned next under this
compiler. That limits renderer validation; it is not evidence against either
reactive engine. Web's local Jest DOM setup file fixes dependency resolution in
this linked workspace. Public package declaration/build checks are also run.

`pnpm` in this environment attempted to reinstall the linked node_modules and
refused it as unsafe. Commands above invoke the installed repository runners
directly; no replacement test or benchmark harness is involved.

## Retained build results

Tests were rerun with stable, fully mangled artifacts, sequentially by package
and with four workers. Running artifact-import tests during the earlier build
produced invalid mixed-file failures; those runs are not the final evidence.
`*-stable.json` and `*-stable.log` are the retained full-suite reports.

| Normal suite | Passed | Expected failures | Failed | Skipped |
| --- | ---: | ---: | ---: | ---: |
| signals | 3,970 | 18 | 1,713 | 2 |
| solid | 833 | 0 | 23 | 0 |
| web | 1,225 | 1 | 105 | 0 |

The signals failure inventory is `failure-review.json`: 1,644 deferred/unmigrated
API cases, 44 explained semantic differences, two instances of the functional
setter question (subsequently resolved above), and 23 cases treated as integration
bugs at that checkpoint, with review continuing above.
Classification describes the first failure; it does not claim that later
assertions in those tests have been exercised. All 70 unhandled rejections in
this run are the explicit deferred-until error. They are not ignored in the
suite result. The imported layered regressions pass through the normal entry.

All 23 Solid failures and 73 web failures use the unmigrated optimistic-store
API. Another 30 web failures reproduce against next with this compiler. The
remaining two web failures are the explicit-latest mount distinction described
in the signals inventory: the newly mounted Loading reads committed lower
content instead of showing fallback. The blank-render-binding bug and the
spurious display-ahead diagnostic are fixed.

Source declarations, normal builds, pure-annotation checks, artifact tests and
cross-package private-field checks pass. This is evidence for the integrated
slice, not a proof of arbitrary graph correctness or a green full API suite.

### Existing production benchmarks versus next

Node 24.19.0, CPU 4, three sequential paired runs of the unchanged repository
creation/reactivity benchmark files. The table gives the median of paired
candidate/next **time** ratios; less than 1 is faster. The range is across the
three pairs, not a confidence interval. Means are included because allocation
and GC dispersion makes some means and medians differ substantially.

| Existing workload | Median time ratio | Pair range | Median mean-time ratio |
| --- | ---: | ---: | ---: |
| createRenderEffects:create1to1 | 1.029 | 0.931–1.588 | 1.074 |
| createOwners | 0.951 | 0.913–1.074 | 0.978 |
| storeWrap:deep 1k records | 0.948 | 0.895–1.047 | 0.919 |
| storeWrap:shallow 1k records | 1.068 | 1.045–1.070 | 0.798 |
| createDispose:memoTree | 0.977 | 0.900–1.521 | 0.957 |
| createSignals | 0.900 | 0.854–0.900 | 0.820 |
| createComputations:create0to1 | 0.969 | 0.947–1.316 | 1.014 |
| createComputations:create1to1 | 0.990 | 0.919–1.005 | 0.830 |
| updateSignals:update1to1 | 1.031 | 0.927–1.050 | 1.013 |
| updateSignals:update1to1000 | 0.993 | 0.822–1.184 | 0.973 |
| propagation:diamond | 0.978 | 0.975–0.999 | 1.000 |
| propagation:avoidable | 0.996 | 0.975–1.002 | 1.008 |

The signal-creation and diamond medians improve in all three pairs. One-to-one
updates have a 3.1% slower central estimate, and shallow store wrapping a 6.8%
slower median despite its lower mean. Those regressions are not dismissed.
Several other cases are noisy enough that three pairs do not establish a win
or parity. Active optimism, allocation counts and retained memory are not
covered by these existing workload files. No broader acceptance is claimed.

### Existing shipped-size scenarios

Bytes from the unchanged size harness, with normal property mangling. No limits
were increased. Optimistic-store bundle sizes are not reported as a feature win
while that API is unimplemented.

| Scenario | Next Brotli | Candidate Brotli | Next minified | Candidate minified | Existing Brotli cap |
| --- | ---: | ---: | ---: | ---: | ---: |
| signals: core floor (createSignal/Memo/Effect/Root/flush) | 7,439 | 7,433 | 20,347 | 20,372 | 7,450 |
| signals: + createStore | 14,706 | 14,694 | 44,678 | 44,758 | 14,710 |
| signals: + isPending/latest | 9,692 | 11,479 | 27,298 | 32,326 | 9,730 |

The observation scenario fails its cap by **1,749 Brotli bytes** and is 1,787
bytes larger than next. Ordinary-only imports remain essentially flat. Feature
size and the unfinished API/semantic work prevent merge acceptance.
