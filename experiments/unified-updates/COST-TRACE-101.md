# Stage 101: trace the remaining optimistic regressions

Baseline: pinned next `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, Node
24.19.0, AMD EPYC 9V74. This pass profiles the real production bundles and
retains three targeted changes. It does not establish performance parity or
acceptance of the full experiment. No semantic ruling changes.

## Where the work goes

The main fixtures reuse mounted graphs; node construction is outside their
measured updates. A complete cycle guesses `1` on several independent
`createOptimistic(() => 0)` outputs in one action, publishes, ends the action,
and publishes their reversals. Each output has its own scheduled render effect.
The chain fixture keeps an action open and repeatedly changes the first guess:

```ts
let input = () => 0;
for (let i = 0; i < depth; i++) {
  const [view, guess] = createOptimistic(input);
  if (i === 0) guessFirst = guess;
  input = createMemo(() => view() + 1);
}
createRenderEffect(input, display, { schedule: true });
```

Separate diagnostic bundles count operations; timings never use instrumentation.
CPU and allocation profiles use exactly the shipped minified/mangled application
bytes. Source maps label profile frames. Allocation sampling includes objects
collected during measurement, so it measures allocation traffic, not retained
heap. The V8 GC trace is an independent cross-check of allocation volume.

### Complete actions: excessive scans, allocations, and correction passes

At width 128, next creates two transaction records: the action and its shared
lane. The experiment creates 129: the action and an independently publishable
output update for each guess. At width 512, those counts are 2 versus 513.
Coalescing every output into the same update would change independent
publication behavior; it is not a free allocation optimization.

Before this pass, each output also left an entry in the ambient pending-node
list, even though its own transaction already held it. Each routed render pass
scanned that growing list. Ending the action repeatedly scanned the remaining
scope members to check their inputs, despite every input being synchronous.

<!-- work-table -->
| Operation count | Next | Entry checkpoint | Retained |
| --- | --- | --- | --- |
| 128 outputs: ambient pending entries checked | — | 16,384 | 128 |
| 128 outputs: repeated scope-input checks | — | 8,256 | 0 |
| 128 outputs: dependency-walk sets | — | 128 | 0 |
| 512 outputs: ambient pending entries checked | — | 262,144 | 512 |
| 512 outputs: repeated scope-input checks | — | 131,328 | 0 |
| 512 outputs: dependency-walk sets | — | 512 | 0 |
| 16 boundaries: full recomputations | 32 | 32 | 32 |
| 16 boundaries: ambient pending entries checked | — | 512 | 32 |

The retirement shortcut replaces repeated checks with one linear input-status scan
(128 or 512 visits). A dash means next has no equivalent common-core operation.
<!-- /work-table -->

Next is not linear everywhere: its `pendingGuessOf` search while collecting
128 guesses visits 8,128 entries (130,816 at width 512). That is an upstream
optimization candidate, separate from this experiment. It was not changed or
credited as closing the experiment's gap.

The additional producer nodes do not rerun in this complete-cycle fixture.
Instead, correction runs a full selector calculation per output, followed by
its render calculation: 256 full recomputations on close versus next's 128.
Next can dissolve its lane slot and notify without that extra selector pass.
This is additional work caused by our representation, but it should not be
confused with doubling the user's input calculations.

### Chains: same calculations, more publication work

At depth 16, both runtimes execute 32 full recomputations and 32 reads per
proposal. Next updates its existing lane slots. The experiment additionally
performs 48 adoptions, 48 holds, and 48 ordinary node commits, with 37 readiness
checks versus next's four. It creates a fresh publication transaction per
proposal; next reuses the still-open lane. These counts remain after this pass.

Transparent selector forwarding also left redundant ambient entries. The same
queue treatment now handles initial guesses and forwarded inputs, allowing the
existing per-calculation scope cleanup to remove the producer's entry as well.
This eliminates another quadratic scan; the computation and publication rules
remain unchanged.

### Allocation and V8

<!-- allocation-table -->
| Sampled allocation per update | Next | Entry checkpoint | Retained |
| --- | --- | --- | --- |
| 128-output complete cycle | 29,664 B | 164,753 B | 127,170 B |
| 16-boundary chain proposal | 1,463 B | 4,000 B | 3,566 B |
<!-- /allocation-table -->

The production heap stacks identified `Set` construction and backing-table work
under `positionProposal`, even when the input producer had no dependencies.
Avoiding that empty walk accounts for most of the allocation reduction in the
wide-cycle fixture. Remaining traffic includes transaction records and their
arrays, array backing growth while nodes are adopted, and calculation/frame
handling. Allocation stacks can attribute inlined allocations to their callers;
these samples do not justify assigning every byte to a particular source line.

The initial steady-state V8 traces showed no repeated deoptimization cycle.
Next had zero steady deopts for the cycle fixture; the candidate had one lazy
deopt. The chain traces had one on-stack-replacement transition each. Initial
GC pause totals were about 1.68 microseconds per 128-output cycle in next and
5.00 microseconds in the experiment, much smaller than the total time gap.
Allocation still costs mutator time outside reported GC pauses. The retained
cycle trace reports about 126 KB allocated and 4.59 microseconds of GC pause
per operation, independently agreeing with the allocation-sampling reduction.

A rejected trial extracted the uncommon unchanged-proposal traversal from
`adoptOutput`. Its bytecode fell from 668 bytes to 460, meeting V8's default
single-function inlining limit. V8 then considered it, but its already-inlined
callees pushed the cumulative budget higher; the target call sites still did
not inline it in the measured trace. The five-sample trial did not improve the
chain: the two variants measured 2.41x and 2.53x next's time. The split is removed.
This is evidence against that particular change, not proof that V8-related
improvements are exhausted.

## Retained changes and their limits

1. `stageSelectedValue` keeps one publication wake, while removing a redundant
   childless selector entry already represented by its held update. This applies
   to guesses and transparent forwarding. The guard still excludes owned children,
   custom comparators, status/error cases, snapshots, and user-code execution.
   Every output remains in its transaction's landing list. Removing every wake
   would lose publication of unobserved/equal guesses; that behavior is tested.
2. The synchronous retirement loop can remember that a scope has **no pending
   inputs**. It does not cache the readiness or observedness of actual flights.
   Every retirement still calls `blocked`; every merge invalidates the shortcut,
   and `finally` clears it before computations run. An open action avoids the
   preflight scan altogether. No per-node state or ordinary-path checks are added.
3. `layerPosition` returns before allocating a recursion set for a non-boundary
   producer with no committed dependencies. Lazy boundaries and saved dependency
   snapshots retain the full path. Active and nested layer selection is unchanged.

These are optimizations of machinery introduced by the experiment. No generic
upstream performance improvement is mixed into the runtime patch.

## Timing and shipped size

Each final timing case rotates seven isolated process triples, pinned to CPU 4.
Both experiment columns divide by the same pinned next result in that triple;
no intermediate prototype is used as the performance baseline. Lower is better.
The single-output cycle gets additional warmup to avoid measuring tier-up as
its main cost. Actual visible output is checked in every measured cycle.

<!-- timing-table -->
| Workload | Entry / next | Retained / next |
| --- | --- | --- |
| One-output complete cycle | 1.344x | 1.385x |
| 128-output complete cycle | 2.792x | 2.107x |
| 512-output complete cycle | 3.603x | 1.834x |
| 16-boundary default chain | 2.389x | 2.314x |
| 16-boundary sync-input chain | 1.705x | 1.603x |
<!-- /timing-table -->

<!-- ordinary-table -->
| Workload | Entry / next | Retained / next |
| --- | --- | --- |
| signal-read | 1.001x | 1.042x |
| memo-read | 1.007x | 0.982x |
| write-flush | 0.952x | 0.956x |
| memo-write | 1.012x | 0.977x |
| chain | 0.980x | 0.981x |
| diamond | 0.978x | 0.948x |
| fanout-memos | 0.947x | 0.925x |
| signal-create | 0.552x | 0.606x |
| memo-create-dispose | 0.895x | 0.940x |
<!-- /ordinary-table -->

All measured ordinary cases are synchronous, without actions or pending nodes.
Ordinary bundle code is identical to stage 100 after canonical renaming of
minified identifiers. There is no new ordinary-node state or synchronous branch.
The paired checkpoint and final samples are useful noise controls: small wins
and losses are reported, but differences between identical ordinary programs
cannot be attributed to these optional-feature changes. These are microbenchmarks,
not application latency estimates.

<!-- size-table -->
| Brotli bytes | Next | Retained |
| --- | --- | --- |
| ordinary | 8116 | 7987 |
| optimistic | 9864 | 11888 |
| pending | 10419 | 11715 |
| latest | 10368 | 11562 |
| refresh | 10117 | 8236 |
| optimistic-refresh | 10208 | 12136 |
<!-- /size-table -->

Brotli quality 11; application bundles include the same exports for each scenario.
The optimistic bundle remains above next, and the added cost of independent
publication records remains unresolved. Size thresholds have not changed.

## Validation and next targets

468 selected scalar tests pass (34 baseline/legacy exclusions); 5,695 normal
suite tests pass (two skips). The unchanged scalar-compatibility corpus remains
618 passes and the same 36 classified failures. A 500-seed overlap campaign
passes 30,000 generated operations. The focused production suite passes 15
checks with two exclusions. Source and touched-test typechecking pass.

Three isolated retained-memory samples report about 1,063 bytes per callback
boundary versus next's 555 (direct accessor: 1,049 versus 568). The two-node
representation remains; this pass reduces temporary update allocation. No
disposed-reader payloads remain in either runtime's weak-reference checks.

The new test publishes 32 unobserved guesses, includes equal writes, rewrites
all of them, checks that only the action lifetime remains, and verifies every
reversal and transaction release. Existing tests cover held/superseded chains,
computed owners, errors, cleanup, nested contexts, correction waterfalls,
observed inputs, equal-value lifecycle changes, and committed dependency frames.
The normal suite retains the existing baseline behavior; it is not evidence
that the entire API has migrated to the new core. Finite tests are not a proof.

The highest-value remaining questions are implementation questions: reduce
per-output transaction/queue allocation while keeping independent publication;
avoid a full correction calculation for a demonstrably plain selector; and
reduce repeated adoption/holding/commit work for transparent producer-selector
pairs. The current counts separate those costs from user calculations. None of
these costs has been declared an unavoidable consequence of consistency.

Artifacts: `results/cost-trace-stage101/` contains source snapshots, the incremental
runtime patch, all bundles, logical counts, CPU/allocation profiles, V8 logs,
paired timing samples, test reports, and reproduction scripts. `candidate/` is
the stage-100 entry checkpoint; `retained/` is the final implementation.
`trial-abc/` and its timing folder preserve the first three optimizations before
forwarding shared the queue cleanup. `trial-d/` preserves the rejected V8 trial.
