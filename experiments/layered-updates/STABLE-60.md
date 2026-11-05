# Stable proposal contexts: scalar implementation and cost gate

The user approved implementing stable proposal contexts with local retries.
“Depth” means arbitrarily many layers, not a requirement to use numbers. This
isolated reference currently uses a scalar position as an implementation aid;
the production representation remains an engineering choice.

## Implementation

`reference/stable-scheduler.mjs` is self-contained. `stable-runtime.mjs` exposes
the restricted scalar API. `stable-loader.mjs` redirects the consolidated
scheduler import for comparison with the existing test corpus. Neither the main
production implementation nor the older reference has been replaced.

The engine retains one committed frame and one selected candidate per node.
Signals, ordinary derivations and optimistic outputs use the same frame,
suspension, error, ownership and publication operations. An optimistic selector
chooses its control source or input producer; it has no separate lane value slot.

Changes relative to the prior research engine:

- Each new proposal receives its context once. Removed the dynamic-group
  registry and repeated context assignment from speculative dependencies.
  Explicit lifetime coupling/retirement can still change publication groups.
- An active selector stops hidden input value/context propagation. The separate
  observation edge still forwards demand. Freezing context without this cut
  passed request stability but incorrectly prolonged the peer hold; that failed
  intermediate version is preserved in the checkpoint.
- A new guess may select a new input context; merely discovering dependencies
  later does not relocate that same guess. Inactive selectors remain transparent.
- Read-time RETRY stops an execution when its earlier selections conflict with
  a newly encountered context. Uncommitted owned frames are cleaned up normally.
- Fixed an inherited reference bug for `async` function bodies. JavaScript turns
  a read's WAIT/RETRY throw into a rejected promise. These must remain suspension
  or retry control flow, not become a settled application error. Previously an
  async memo downstream of a pending read could remain stuck after the answer.
- Allocation experiments share empty records, allocate subscriber/dependency/
  dirty sets lazily, reuse singleton publication records, prune links in place,
  and avoid unnecessary propagation traversal sets. These are insufficient to
  make the reference runtime viable; no acceptance threshold was relaxed.

## Observable validation

The four stage-56 request-selection contracts now pass. With view=10 and peer=20,
discovering a hidden deeper dependency no longer changes the selected request.
The separate publication test observes:

```
before discovery                  [0, 0]
after discovery, peer still held   [0, 0]
after the actual peer finishes     [10, 20]
```

This runs with action lifetime and explicit clearing, in both enumeration orders.
It checks both not publishing early and not retaining the unrelated deeper hold.

18 additional tests cover the above timeline, read-order repair in sync and async
functions, cleanup of discarded attempts, and ordinary-versus-layered repeated
proposals at depths 0, 1, 4 and 8. They check unrelated readers during a hold,
late mounts, errors/recovery, stale async answers and disposal. Public accessor
audits compare request histories with pinned next. Existing suites also exercise
sibling joins, action overlap, equal-value owner replacement, observation demand,
pending, and finite conditional/lifecycle campaigns.

Combined run: **232 pass, 4 fail, 236 total**. This includes historical tests of
other models; the count is not 232 independent validations of this implementation.
The four failures are unchanged old expectations (two cases, two orders):

1. A later parent activation promotes an already-pending child and separates it
   from its former peer.
2. A later parent expiration demotes an already-pending child into a peer join.

The candidate instead keeps that child's existing proposal context; a new child
guess can select a new one. These are intentional consequences of the candidate
stable-context policy, not assertions weakened to hide inconsistent publication.
The old assertions remain intact. The public action comparison is recorded in
`{next,stable}-parent-events.json`: next also differs through its existing input
supersession/lifetime rules, so do not describe the four historical failures as
four newly reproduced bugs against next. These timelines remain visible for
review if the stable policy should be narrowed at actual parent events.

Five isolated GC retention samples per runtime retain **zero disposed reader
tokens** with a live boundary. The tests also drain update records and check
cleanup/subscriber bookkeeping. These are bounded tests, not a general proof.

## Performance against pinned next

Baseline: `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`, unmodified prod build.
Node v24.19.0, AMD EPYC 9V74. Sync results use three paired alternating fresh
process samples; worker hashes, bundle hashes, raw samples and CPU information
are retained. Ratios are prototype time / next time:

| Workload | Ratio |
| --- | ---: |
| Settled signal read | 0.606 |
| Settled memo read | 0.504 |
| Equal write | 0.994 |
| Write + flush | 16.221 |
| Memo update | 9.214 |
| Ten queued writes | 10.470 |
| Chain | 8.667 |
| Diamond | 9.478 |
| Memo fan-out | 8.701 |
| Effect fan-out | 9.452 |
| Branch switch | 9.500 |
| Signal creation | 1.395 |
| Memo creation/disposal | 10.192 |

Five-sample active-optimism timings also fail: callback-input depths 1/4/16 take
8.86/26.63/99.92 microseconds versus next's 1.55/2.86/7.43. This workload has one
active override followed by nested transparent optimistic views; it must not be
advertised as a benchmark of sixteen simultaneously active overrides.

V8 sampled allocation for an ordinary memo/effect write is approximately
**11,014 bytes versus 650 bytes** in next. Sampling includes collected objects;
it is not an exact count. An inactive boundary raises the prototype sample to
11,456 versus 634. Callback boundary retained memory is about 2,426 versus 556
bytes; direct-accessor boundary memory 1,646 versus 568. Optimistic-node memory is
secondary here; the ordinary update overhead alone fails acceptance.

The CPU profile identifies collection allocation/GC, publication enumeration,
dependency relinking and general preparation as major costs. Disabling trace
logging is already part of these runs, so this is not merely debug-log overhead.
No layer traversal or version-map lookup is added to settled imperative reads,
but ordinary writes still pay for the reference's allocation-heavy frame/group
representation. Do not infer that the semantics require that cost.

Timing/allocation/retention runs use the exact source snapshot in `final/`,
immediately before the cold async-rejection fix. That fix affects asynchronous
answer handling, not the wholly synchronous workloads. It has full correctness
coverage; the final bundle sizes below were rebuilt after it. Raw pre-fix bundles
are retained so measurements remain reproducible rather than silently relabeled.

## Restricted bundle size

Final minified / Brotli bytes, same export scenarios:

| Imports | next | prototype |
| --- | --- | --- |
| Ordinary + action | 21,918 / 8,116 | 21,798 / 6,307 |
| Plus optimism | 27,250 / 9,864 | 22,120 / 6,398 |
| Plus optimism and pending | 29,220 / 10,496 | 22,260 / 6,436 |

These are **restricted adapter bundles**, not feature-equivalent shipped builds.
The class also retains much of its cold machinery in ordinary imports. The size
result is encouraging evidence for shared machinery, not completed size acceptance.

Implemented here: scalar signals; sync/promise/async-function memos; publication
callbacks; roots/cleanup; generator actions; split optimistic boundaries; nested
and sibling contexts; source-owned accessor-form pending outputs; staged errors.
Still absent: real DOM scheduling, full effect/Loading/ErrorBoundary integration,
callback-form observations, latest, full action forms, stores, until/refresh,
deferred, SSR and other package APIs. Production sources and store work are untouched.

## Decision at this checkpoint

The stable-context direction survives the new targeted scalar falsification
tests. The operational reference **fails performance/allocation acceptance**,
even after profiling and allocation iterations. It should remain an executable
correctness reference, not be promoted as the replacement runtime. No measured
claim that a complete implementation is fast enough is justified yet.

The next implementation should use compact ordinary nodes/links, with pending
context and ownership records allocated only when needed, and apply the stable
boundary cut before ordinary propagation. That is a representation change for
the shared rules, not a return to separate optimistic value/publication engines.
First validate ordinary-to-async escalation, suspension retries, owned frames,
and hidden input demand against this reference; then the complete scalar matrix.
Measure before porting stores or promising that a production version can pass.

## Reproduction

```sh
node --test experiments/layered-updates/reference/stable-context.test.mjs
UNIFIED=1 node --import ./experiments/layered-updates/reference/stable-loader.mjs \
  --test experiments/layered-updates/reference/*.test.mjs \
  experiments/layered-updates/reference/fetch-selection.contract.mjs
SCALAR_CANDIDATE_ENTRY=experiments/layered-updates/reference/stable-runtime.mjs \
  SYNC_SAMPLES=3 node experiments/layered-updates/measure-sync.mjs /tmp/stable-sync
node experiments/layered-updates/measure-stable.mjs /tmp/stable-features
node experiments/layered-updates/measure-allocations.mjs /tmp/stable-features
node experiments/layered-updates/measure-optimistic.mjs /tmp/stable-features
```

Artifacts: `results/stable-context-stage60/`. The broad test command deliberately
still exits nonzero for the four documented historical expectations.
