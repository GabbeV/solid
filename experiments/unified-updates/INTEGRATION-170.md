# Adversarial review of owned-frame reads and eager initialization

**Review result: not ready for acceptance.** The input/output split remains
plausible, and new publication tests pass that expose weaknesses in next. But
the owned-frame repair is incomplete: a normal newly mounted JSX component can
still complete a calculation with direct input 1 and latest 0. The current
experiment also exceeds the existing size caps and retains substantial active
optimism overhead. This checkpoint adds tests and evidence, not another runtime
patch. The reviewed runtime is a8c84a5d, compared only with unmodified next
4fe75321d61f9e4f1e1c63edc2087d099a36e9e1.

## Confirmed correctness finding

The minimal JSX test is `packages/web/test/owned-tentative-latest.spec.tsx`.
An action proposes id 1 and stays open. An async derivation of latest(id) holds
that observation's output at 0. An unrelated visibility update mounts this Page:

```tsx
function Page() {
  const captured = id();
  return <span>{`${captured}:${id()}:${latest(id)}`}</span>;
}
```

Its completed binding calculation is **1:1:0**. Its DOM is still detached, so
this test proves an inconsistent calculation, not a painted torn frame. User
code can nevertheless branch or start work using that invalid combination.
Both inline and memo-wrapped latest fail in the experiment. Next passes inline
and fails the wrapped form. The assertion requires latest never to be older
than the direct monotonic input; it does not prescribe sibling callback order.

The scalar test combines two held peer inputs, direct/memo latest, either read
order, zero/two intervening roots, and tracked/untracked creator reads. All 16
experiment cases fail with `[captured sum 3, a 1, b 2, latest(a) 0]`. Next passes
the eight inline cases and fails the eight wrapped ones. Mangled production
reproduces all 16 failures too; this is not dev instrumentation or Vite module
identity.

### Why the last fix missed it

`layers/coordination.ts::frameRead` recognizes a creator's tentative consumed
inputs through `creatingReads` and lets the child's ordinary read use their
proposals. But its higher-observation arm calls `committedUsesUpdate`, whose
input test recognizes only the exact resolved transaction. Before the creator
accepts its peer joins, those are different predicates for the same frame.

Temporary instrumentation recorded:

```text
inputProposal: 1
exactFrame: false
tentativeInput: true
observationRecognized: false
```

That instrumentation was removed. The source is byte-identical to the reviewed
runtime. This is an implementation bug, not a new semantic question, an API
deferral, or an intentional divergence from next. The new tests remain normal
failing tests; no assertion or test status was relaxed to report a green suite.

## Independent adversarial controls

`unified-publication-adversarial.test.ts` uses an independent output oracle:
each published doubled async result must equal twice its published input;
ordinary repeated readers, combined sibling derivations, and late-mounted
readers must agree. It does not copy the runtime's update representation.

- Eight deterministic seeded timelines, at optimism depths one and three with
  an additional sibling, pass. Each has 48 mixed events followed by draining:
  repeated guesses, source corrections, stale async answers, override expiration,
  unrelated writes, late mounts, and removal. Owned calculations are counted
  and every cleanup must run exactly once at disposal.
- Four further cases create first render callbacks while consuming provisional
  peer inputs, then discover optimism before/after those reads. Discarding the
  parent attempt must not leave the input actions entangled. All pass, including
  intervening roots and disposal before the actions finish.
- Both groups pass in mangled production. Next fails the four depth-three
  publication timelines (a doubled result lags its published input), and the two
  late-discovery cases (the result exposes lower proposed inputs). Next is a
  comparison point, not the oracle for these accepted experiment semantics.
- Four JSX tests cover errors, async recovery, override expiration, stale answers
  and owned-child disposal at depths one/three with zero/two intervening roots.
  They pass in both implementations.

An initial error-test oracle incorrectly expected an Errored fallback to keep
holding its input during hidden recovery. D-39 explicitly says otherwise:
`0 | Fetch error for 0` may become `1 | Fetch error for 0` while recovery waits.
The test now respects that explicit boundary while still requiring correct
recovery, cancellation of expired optimistic work, and exactly-once cleanup.
The initial rejected reports are retained; this was a bad test expectation,
not a discovered runtime bug or a new exception introduced for the review.

Final new-test receipts: source **12 pass / 16 fail**, mangled production
**12 pass / 16 fail**, JSX **4 pass / 2 fail**. The 18 failures are variations
of the confirmed owned-frame defect. Prior full-suite results were not rerun:
no runtime implementation changed. Existing 19 non-deferred scalar failures
remain separate. A finite campaign is not a proof; arbitrary dynamic dependency
graphs, all first-mount boundary combinations, and deferred APIs remain outside
this review's demonstrated coverage.

## Performance against next

Production artifacts, ordinary property mangling, Node v24.19.0. Bench workers
were pinned to CPU 4; correctness work used CPUs 0–3. The unchanged repository
`tests/core/creation.bench.ts` and `tests/core/reactivity.bench.ts` were run in
five alternating process pairs. Supplemental existing experiment workers add
settled reads, one flush per propagation, inactive optimism, active overrides,
and retained memory. Supplemental sync cases use seven alternating pairs;
active optimism and memory use five. Their public API fixtures verify results.

The table statistic is the median paired **experiment time / next time**;
below 1 is faster. Ranges are min/max process pairs, not confidence intervals.
Small differences whose ranges straddle 1 remain uncertain. These are costs of
the complete current experiment; they do not isolate the causal cost of the last
two commits. No incorrect predecessor is used as a performance baseline.

### Existing repository workloads

| Workload | Time / next | Process-pair range |
| --- | ---: | ---: |
| createRenderEffects:create1to1 | 1.022 | 0.809–1.135 |
| createOwners | 1.068 | 1.012–1.135 |
| storeWrap:deep 1k records | 0.921 | 0.561–2.149 |
| storeWrap:shallow 1k records | 0.962 | 0.928–1.136 |
| createDispose:memoTree | 1.047 | 0.422–2.170 |
| createSignals | 0.846 | 0.768–1.428 |
| createComputations:create0to1 | 1.050 | 0.929–1.107 |
| createComputations:create1to1 | 0.952 | 0.772–1.060 |
| updateSignals:update1to1 | 1.048 | 0.889–1.217 |
| updateSignals:update1to1000 | 0.986 | 0.912–1.269 |
| propagation:diamond | 0.966 | 0.909–1.038 |
| propagation:avoidable | 1.022 | 0.881–1.037 |

### Supplemental public API workloads

| Worker / workload | Time / next | Process-pair range |
| --- | ---: | ---: |
| sync-bench.mjs / signal-read | 0.909 | 0.799–1.013 |
| sync-bench.mjs / memo-read | 0.928 | 0.854–0.968 |
| sync-bench.mjs / write-flush | 1.016 | 0.817–1.064 |
| sync-bench.mjs / memo-write | 0.984 | 0.794–1.109 |
| sync-bench.mjs / chain | 0.965 | 0.945–1.074 |
| sync-bench.mjs / diamond | 0.968 | 0.887–1.110 |
| sync-bench.mjs / fanout-effects | 1.027 | 0.889–1.168 |
| sync-bench.mjs / memo-create-dispose | 0.949 | 0.899–1.054 |
| inactive-sync-bench.mjs / signal-read | 0.935 | 0.892–1.001 |
| inactive-sync-bench.mjs / memo-write | 0.945 | 0.888–1.090 |
| node-cost-bench.mjs / transparent-1-write-ns | 1.654 | 1.457–2.009 |
| node-cost-bench.mjs / transparent-4-write-ns | 1.863 | 1.580–1.924 |
| node-cost-bench.mjs / transparent-16-write-ns | 2.340 | 1.745–2.558 |
| active-contexts-bench.mjs / depth-1-top | 1.400 | 1.321–1.506 |
| active-contexts-bench.mjs / depth-4-top | 1.468 | 1.344–1.627 |
| active-contexts-bench.mjs / depth-16-top | 1.130 | 1.100–1.247 |

Settled signal reads measure about 9% faster and memo reads about 7% faster;
the memo-read improvement appears in every process pair. Small write/creation
changes are mixed, with substantial noise in some GC-heavy repository cases.
Root creation is about 7% slower in the repository run. Active optimism remains
a serious regression: top-override writes are 1.13–1.47 times next depending on
depth, and propagation through otherwise transparent boundaries is 1.65, 1.86,
and 2.34 times next at depths 1, 4, and 16. These last regressions are consistent
across all paired runs; they should not be described as broadly comparable.

The existing retention worker found zero retained disposed readers in all five
processes for both runtimes. Median bytes per inactive boundary were about
1,057 versus 556 for callback inputs, and 1,043 versus 569 for direct inputs.
That is broadly the expected two-node cost, not evidence of unbounded retention.
It does not prove every temporary creation-context path releases all objects.

By inspection, the last fix adds no ordinary node field and no allocation to
settled synchronous reads. Its ancestry scan, temporary read-set stack and
observation-dependency walks occur in active held/creation paths. That cost
placement is reasonable; the correctness predicate and aggregate measured costs
are not yet acceptable. Do not attribute every measured regression to this fix.

## Shipped size against next

The unchanged repository size gate fails the core and observation scenarios;
no limits were raised. Additional scalar optimism imports use the same bundle
function and minifier, without stores or until. They are supplemental scenarios,
not new gates.

| Scenario | Next minified | Experiment minified | Delta | Next Brotli | Experiment Brotli |
| --- | ---: | ---: | ---: | ---: | ---: |
| signals: core floor (createSignal/Memo/Effect/Root/flush) | 19,825 | 21,255 | +1,430 | 7,421 | 7,940 |
| signals: + createStore | 43,868 | 45,323 | +1,455 | 15,089 | 15,531 |
| signals: + isPending/latest | 33,615 | 37,739 | +4,124 | 12,239 | 13,445 |
| Supplemental scalar optimism | 30,556 | 35,475 | +4,919 | 11,180 | 12,859 |
| Supplemental scalar observed optimism | 35,643 | 41,517 | +5,874 | 12,920 | 14,675 |

The core floor is 510 Brotli bytes over its existing cap; pending/latest is
1,195 bytes over. Approximate module attribution places much of the core-floor
growth in the ordinary scheduler. With optimism included, the new coordinator
is already larger than next's lane module, and the experiment additionally pays
for its selectors and larger scheduler. This is not yet the size simplification
we are trying to achieve. Attribution is apportioned by the harness; it is not
a precise per-function marginal-size measurement.

## Recommendation

Keep the input/output separation and ordinary publication foundation, but do
not endorse the owned-frame fix as complete. The passing publication campaign
supports the direction, including cases next fails. The failing mount shows
that its read-context representation is still split across overlapping rules.

The next implementation step should define **one predicate for whether a
proposal belongs to the current private frame**, including already-consumed
provisional inputs, and use it for both ordinary and observation reads. It must
not irrevocably merge those inputs before the creator accepts its attempt.
`creatingReads` already contains the missing information; this is not a reason
to add provenance fields or version maps to every ordinary node. Preserve the
existing unrelated-mount and discarded-join controls while doing that repair.

After correctness, consolidate the overlapping context checks and measure the
cold-path graph walks and active propagation cost. The present performance and
size gaps require further work; no acceptance claim is justified by this review.

Receipts: checkpoints/integration-stage170.tar.xz. Scripts, commands, process
measurements, artifact hashes, source revision, CPU description, rejected
oracles, and the temporary diagnosis trace are retained there.
