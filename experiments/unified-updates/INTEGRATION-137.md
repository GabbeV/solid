# Latest errors use the shared output publication path

Upstream PR https://github.com/solidjs/solid/pull/4705 was filed by the user.
This checkpoint adapts the intended behavior to the experiment's source-owned
latest outputs; it does not transplant the upstream lane implementation.

## Retained mechanism

Latest can select a staged error as an output proposal. A small error-only
wrapper distinguishes throwing an Error from returning an Error as data. The
existing override slot holds it; the same selection reuses its wrapper. There
are no new signal/memo fields, read-time maps, or error caches. Its selector is
chosen at observation creation, so pending and ordinary primitives do not pay
an error-unwrapping dispatch on their reads.

Before selection, the latest output preserves its published outcome. A pending
re-ask keeps the displayed error until an answer replaces it. Comparing only
old successful values is insufficient for recovery: an error-to-value change
is still a new output even when the value equals the value from before the
error. Committed errors with no pending proposal remain transparent; the final
implementation does not leave a permanent override just to retain context.

Error-boundary recovery follows the recovered reader's shared update through
the existing notification/adoption mechanism. Its graph query stops at active
overrides: subscribing to a lower input is not consuming its proposal. The
original error source remains the reset target, but a recovered reader which
no longer consumes it does not wait for that lower update. No separate error
lane or boundary state field was added.

Two error-path details in the common scheduler matter: a recovery replacing a
shown error cannot be discarded as a write which netted to the old successful
value; carrying the same published StatusError into a later update must not
redeliver that error. The former uses the existing shown-error slot and the
latter checks the existing status/error identity at error commit.

## Coverage and differences

- 28 JSX regressions: the upstream 24 value/error timelines and reset test,
  plus late mounting through nested latest outputs and returning an Error as
  data. All pass. The timelines check direct/one/two-memo readers, sync and
  async errors, retained/proposed-removing Show branches, repeated errors,
  pending recovery, ordinary readers, same-value recovery and fallback cleanup.
- Seven existing intermediate expectations intentionally change to value/error
  symmetry: the five from the upstream candidate and two #4403 expectations
  for ahead error/recovery. Added an ordinary counterpart which continues to
  hold recovery. Final recovery assertions are preserved.
- The existing E2 JSX regression now passes. Three old signals failures are
  reconciled by the explicit timing migrations above; this is not a claim of
  three independent implementation fixes.
- Full signals: **5,232 passed, 2,111 failed, 2 skipped**. No new failures
  against stage 132. The 15 added passing signals cases since that inventory
  comprise stage 133's fourteen added store guards and this pass's ordinary
  recovery counterpart. The 28 new JSX cases are counted separately.
- Targeted client web: **171 passed, 10 existing failures**. No new failures
  against stage 130's full web inventory; the E2 case is repaired.
- Targeted hydration: **166 passed, 10 failures**. A separately built unchanged
  stage-136 control reproduces all ten #4375 request-log failures with identical
  actual sequences. They predate this change; no assertions were changed.
- All signals build tiers, declarations, production purity checks, rules index,
  and diff checks pass. Targeted formatting applied without reformatting the
  previously unformatted scheduler. Full web/SSR suites were not rerun.

A broader trial making every computation treat outgoing errors as changed
values regressed the ordinary repeated-async-error boundary case #2701. It was
removed. Another trial kept a committed error selected permanently; it repaired
recovery but unnecessarily preserved a layer after the input settled. The
retained solution compares the latest output's outcome and keeps that logic at
the explicit observation boundary. Instrumentation and rejected-trial receipts
are archived; none remains in shipped sources.

## Size against next

Existing Rolldown harness; next runtime `4fe75321` is identical to `45648f78`,
the upstream fix's base. Minified / Brotli bytes:

| Scenario | next | Experiment |
| --- | ---: | ---: |
| Core | 19,825 / 7,421 | 21,187 / 7,921 |
| Store | 43,868 / 15,089 | 45,256 / 15,528 |
| Pending/latest | 33,615 / 12,239 | 35,648 / 12,731 |
| Simple render | 26,597 / 9,800 | 27,960 / 10,237 |
| Hydrating without stores | 54,085 / 19,013 | 55,858 / 19,589 |
| CSR with boundaries | 37,556 / 13,708 | 39,327 / 14,373 |

All selected experiment scenarios still exceed their existing caps. No caps
were raised. The until/refresh scenario is also recorded but until remains a
stub and is not a feature-complete size comparison.

## Synchronous benchmark check against next

Ran the repository's `tests/core/reactivity.bench.ts` on built production
packages, alternating next and experiment three times, sequentially with no
other tests/builds running. FILTER selected the five rows below. Relative mean
time across the three runs (negative is faster):

| Workload | Experiment vs next |
| --- | ---: |
| Signal creation | +11.0% |
| 1:1 memo creation | -46.4% |
| 1:1 signal updates | +7.2% |
| Notification fan-out | +7.2% |
| Diamond propagation | +0.8% |

These are limited diagnostic runs, not acceptance measurements. Signal
creation varied strongly between processes (next 0.152–0.284 ms per batch;
experiment 0.169–0.252 ms). Memo-creation next runs have high relative margin
of error from GC. The update results also varied: retain all raw runs rather
than treating the table's small differences as settled conclusions. No new
retained-memory measurement, async/optimistic benchmark, or complete benchmark
suite was run. Performance claims here compare only with next.

## Remaining work

Signals inventory: 1,953 deferred-API failures (optimistic stores/until), 146
untriaged, two known first-proposal/store-ownership bugs, and ten calculation
expectations. The full web inventory has not been refreshed by this targeted
run; its existing E2 failure is now known repaired. The ten hydration request
logs require separate triage. Scalar integration and size/performance acceptance
are not complete. No new semantic ruling is required for the retained changes.

Reproduce builds/tests with the archived local compiler/setup configs. The
benchmark logs and JSON, complete signals report, targeted web/hydration reports,
baseline control and size data are in integration-stage137.tar.xz. The native
compiler path used was /workspace/scratch/pending-repro-rc21/node_modules/
@solidjs/compiler-linux-x64-gnu/compiler.linux-x64-gnu.node (one path, no newline).
