# Coherent publication when an owned reader is replaced

This fixes the held-branch tearing confirmed in stage 175. The reference remains
unmodified next `4fe75321d61f9e4f1e1c63edc2087d099a36e9e1`. The experiment is
still incomplete; this checkpoint is not correctness or performance acceptance.

## Observable defect

```tsx
const [key, setKey] = createSignal("a");
const [count, setCount] = createSignal(0);
const answer = Promise.withResolvers<number>();
const data = createMemo(() => (key() === "a" ? 0 : answer.promise));

<>
  <b>{count()}</b>
  <Show when={key()} keyed>
    {captured => <span>{`${captured}:${key()}:${count()}:${isPending(data)}:${data()}`}</span>}
  </Show>
</>;
```

After `setKey("b"); setCount(1)`, the old implementation could display count 1
outside the branch and count 0 inside it. These are ordinary readers of the same
signal; pending observation does not authorize this inconsistency. Next keeps
both counts at 0 until the held update can publish.

The retained implementation keeps those ordinary publications coherent. A
second count write and superseding key write also remain held coherently. On
the current answer, both counts and the replacement branch publish together.
A late answer for the superseded key changes neither binding.

## Mechanism

Two ordering defects were involved:

1. A higher publication replaced the old owned reader which had been holding
   the ordinary update. The same publication sweep immediately judged that
   ordinary update unblocked, before queued replacement readers executed.
   Publication now takes a readiness snapshot of the prepared graph when
   several coordinated updates coexist. Already-ready updates can finish, with
   their readiness rechecked; previously blocked updates are reconsidered only
   after queued work has run. With no queued work, the same sweep can reconsider
   them. Cleanup can still merge transactions during publication.
2. Once that premature commit was prevented, a child could execute the ordinary
   incoming update before its stale creator was prepared for it. It combined
   captured key `a` with a direct key read of `b`, even though this mixed result
   did not necessarily reach the DOM. When the heap reaches a child, an ancestor
   awaiting preparation for that same update now prepares first. If that
   preparation removes the old child, the existing zombie/removal handling
   defers it. The existing waiting-reader registry supplies the information;
   there is no new per-node field or dependency-read journal.

The readiness snapshot allocates only with the optional coordinator active and
multiple pending transactions. Ancestor preparation runs only for coordinated
heap work whose selected update has waiting readers. Ordinary node creation and
settled reads acquire no additional bookkeeping.

## Rejected trials and useful checks

Stopping the entire publication loop whenever a landing queued work fixed the
tearing but stranded a derived-store Loading case. It also delayed other ready
optimistic results until preparation could retire them. The retained rule lets
those already-ready results finish; it only prevents a newly unblocked update
from bypassing its replacement readers.

A targeted merge-time wake repaired final liveness in that rejected trial but
left intermediate Loading behavior wrong. Broadening first-answer observation
selection did not repair it either. Neither change is retained. No observation
lifetime, store semantics, or diagnostic rule was added.

The F13 manual test had one global variable representing every child frame.
Cleanup from an obsolete frame could overwrite the new frame's successful
value. It also registered cleanup from an effect callback with no owner. The
fixture now records values and cleanup per owned frame and inspects the frame
selected by the scheduled render callback. It still tests the same unmount,
remount, action completion and final value, and additionally verifies that the
published frame is live and all frames clean up on disposal. No runtime
consistency assertion was relaxed.

## Validation

The JSX regression has 17 cases: the original case plus direct/memo-derived
children, direct/memo-wrapped pending observation, both read orders, and normal
versus superseding answers. They assert both visible consistency and coherent
completed calculation inputs, reject late stale answers, and check exactly-once
cleanup. The existing derived-store equivalence case also passes.

- Full signals: **5,729 passed, 1,977 failed, 2 skipped**. No new failing
  identities against stage 174; the existing #4010 consistency failure is fixed.
- Full web: **1,731 passed, 125 failed, 1 skipped**. No new failing identities
  against stage 174; all 17 newly added JSX cases pass.
- Mangled-production ownership/retry selection: **136 passed**.
- Builds, types, production/observation purity and diff checks pass.

The remaining failures include **24 non-deferred signals cases** and **10
non-deferred web cases**. The rest remain the deferred optimistic-store/until
inventory. This repair does not resolve those other cases, and these tests are
not a universal proof of nested-update correctness.

## Size against next

Measured shipped scalar import scenarios, bytes:

| Imports                    | next minified / Brotli | experiment minified / Brotli |
| -------------------------- | ---------------------: | ---------------------------: |
| Ordinary core              |         19,825 / 7,421 |               21,503 / 8,065 |
| Scalar optimism            |        30,556 / 11,180 |              37,046 / 13,375 |
| Optimism with observations |        35,643 / 12,920 |              43,140 / 15,228 |

The size gap remains an acceptance issue. No threshold was increased.

## Synchronous performance against next

Five alternating paired processes per campaign, pinned to CPU 4, Node 24.19.0
on AMD EPYC 9V74. These are the existing repository creation/reactivity
benchmarks on the built production packages. No builds or tests ran concurrently.
The ratio is experiment mean time / next mean time, with the median across
process pairs; lower is faster. Pair ranges are not confidence intervals.

| Repository benchmark          | Full campaign median |  Pair range |
| ----------------------------- | -------------------: | ----------: |
| Signal creation               |                0.893 | 0.772–1.086 |
| Zero-dependency memo creation |                1.092 | 1.007–1.731 |
| Render-effect creation, 1:1   |                1.005 | 0.739–1.266 |
| Owner creation                |                0.998 | 0.950–1.072 |
| One-to-one update             |                1.153 | 0.993–1.370 |
| One-to-1,000 update           |                1.192 | 1.008–1.220 |
| Diamond propagation           |                1.016 | 0.969–1.121 |
| Equality-filtered propagation |                1.007 | 0.922–1.071 |

Because the spread was substantial, the four update benchmarks were repeated
in isolation using the same harness and five new alternating pairs:

| Repository benchmark          | Update-only median |  Pair range |
| ----------------------------- | -----------------: | ----------: |
| One-to-one update             |              1.088 | 0.978–1.163 |
| One-to-1,000 update           |              0.936 | 0.919–1.155 |
| Diamond propagation           |              1.005 | 0.946–1.078 |
| Equality-filtered propagation |              0.988 | 0.968–1.059 |

The one-to-one slowdown remains a concern. Fan-out changed direction between
campaigns, so neither a reliable improvement nor a reliable regression is
claimed for it. Signal creation's faster median does not cancel slower update
or creation results. The one-dependency memo and memo-tree creation samples
were especially noisy; all raw results are archived. Store measurements run
with the creation harness but are not acceptance evidence for deferred stores.
This campaign does not measure active optimism or retained memory, and does
not attribute the whole gap against next to this checkpoint's repair.

The first filtered invocation also selected an empty creation benchmark file;
Vitest rejected that invocation. Its log is retained as `empty-creation.log`,
and it is excluded from the completed five-pair confirmation campaign.

## Receipts

`checkpoints/integration-stage176.tar.xz` preserves the ownership/publication
traces, rejected trials, full and focused test reports, build/type checks,
production tests and measurement commands. Temporary tracing, trial build
configuration and alternative observation/merge changes are not shipped.
