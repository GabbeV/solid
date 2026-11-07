# Separate private calculation, publication, and override lifetime

This implements the proposed coordination experiment in the real core. It is
not acceptance of the larger experiment: the existing deferred/API failures and
performance/size gaps remain. The comparison is unmodified next
`4fe75321d61f9e4f1e1c63edc2087d099a36e9e1`.

## Mechanism

A private child inherits the update which created it. Reading a higher output
does not authorize replacing that output's ready proposal with its older
publication. The special latest-to-parent dependency proof is removed. Private
calculations can consume the proposal without merging the two updates; actual
pending/error reads continue through ordinary status handling. Structural
readers still suspend rather than replacing visible content with a proposal.
The synchronous first render can initialize detached DOM eagerly.

The existing waiting-reader registry records the consumption. Before landing a
lower update, a publication-only check waits for higher outputs still required
by its private children. The upper update does not wait for the lower action.
Ready upper outputs land first using the existing publication ordering hook.
Private recalculation replaces its wait registrations, including untracked
reads, so dropping a dependency removes the obsolete wait. Disposal already
cleans this registry. No node fields, value histories, caches, or separate
transaction-dependency registry are added.

Publication readiness and override lifetime are distinct judgments. A private
request derived from an upper override cannot keep the lower override lifetime
open. Its unfinished result still prevents attachment. Expiration restores the
input through ordinary propagation; correction can hold publication and
supersedes the obsolete request. The pending-source sets already maintained by
the engine identify the requests responsible for a hold. Looking at all of a
reader's dependencies instead was incorrect: reading pending status beside an
ordinary pending request does not make that request optimistic.

The request may also live outside the private child and already belong to a
higher update. Its async work cannot extend the lower lifetime either. A ready
higher publication is different: it can finish this flush before correction,
as in the user's existing ruling for synchronous latest publication before
retirement. The source check distinguishes an actual pending request from a
ready publication wait. It consults higher-update readiness only in increasing
depth order, not through a general cyclic transaction-dependency graph.

A separate cancellation defect was exposed by the new lifetime test, and also
reproduces on the entry runtime. Synchronous replacement of an async first
answer can leave its render effect pending when the replacement equals an
already-staged value. The settle sweep wrongly required initialization even
though a staged first answer was available. It now accepts that staged answer;
it still refuses to settle a source with no answer. This changes no memo equality
rule and does not run scheduled callbacks before publication.

## Observable completion orders

Start at id/latest/slow = 0/0/0. Action A proposes id=1 and stays open; latest's
selected 1 waits for slow. An independent visibility update privately mounts:

```tsx
function Page() {
  const captured = id();
  return <span>{captured}:{id()}:{latest(id)}</span>;
}
```

Its private calculation is now 1:1:1, including a memo wrapper around latest.
It remains detached.

- Slow first: id/latest/slow publishes 0/1/1, with Page still detached. Ending A
  then publishes 1/1/1 and attaches Page=1:1:1.
- A first: the override retires. Its ordinary correction waits for slow, so the
  screen stays 0/0/0 with Page detached. The answer publishes 1/1/1 and Page=1:1:1.

Next passes the inline forms and fails the wrapped forms' calculation assertion.
The test does not prescribe sibling effect ordering.

The cancellation fixture has one action both open a panel and guess 1. A private
child starts async work only for 1. Ending the action must correct to 0 and reveal
the panel with 0 without waiting for that obsolete work. Direct and wrapped
forms, with the request inside or outside the child, pass on next and the
retained candidate. Removing the lifetime distinction
from the candidate makes both fail, even with the staged-answer fix retained.

A dependency-removal fixture switches a private child from a held guess to a
constant after its mounting action ends. While publication is still waiting,
isPending(mounted) must remain true. The mount then publishes the constant
without waiting for the old guess's async work. It caught stale wait registrations
in an intermediate trial. The mounted result and pending=false publish together;
this also passes against the mangled production build.

A JSX fixture makes nested Show structure wait for a ready guess whose
publication is held by an external async derivation. Ending the action must
correct and reveal the zero fallback without waiting for that obsolete work.

## Changed old expectations

Ten variants in `unified-owned-context.test.ts` encode consequences of the old
private-read cut:

- Four expected an independently mounting frame to attach with the optimistic
  output's old value while its new proposal remained held. The new frame consumes
  the proposal and waits to attach. This is an intentional timing change following
  the selected context model, not a new consistency exception. The user previously
  allowed mount entanglement behavior to follow the model naturally. The test
  still asserts coherent DOM at each checkpoint and the independence of the upper
  publication from the lower mounting action and private async consequence.
- Six expected no completed private calculation before an optimistic output's
  first publication. Ready proposals now initialize private children eagerly;
  actual pending derivations still suspend. Their publication, lifetime and
  cleanup assertions remain.

The general eager-read trial without the publication gate actually painted a
new child with 1 beside an existing reader with 0. That trial is rejected and
archived; it was not justified as a permissible mount timing change.

## Validation

The 742 experiment tests pass. The full signals suite has 5,634 passes, 1,972
failures and two skips, with no new failure identities versus the entry checkpoint.
The existing failure inventory remains 1,953 deferred API cases and 19 other
cases. This is not a green full suite.

The first broad candidate regressed six signals tests and two JSX tests for
#4474, plus the generated web regression gate. The request-specific lifetime
check fixes those: the focused 39-case source set and web regression controls
pass, including the 1,500-case generated campaign. No generated baseline is
changed.

The final web suite has **1,720 passes / 119 failures / one skip**, with the same
failure identities as the entry checkpoint. **58 public-API controls** pass
against the mangled production build, followed by all five lifetime/dependency
controls with the strengthened pending assertion. Production and observe builds,
property mangling, purity checks, declarations and diff checks pass.

These finite tests exercise both completion orders,
tentative peer inputs, wrapped observations, nested ownership, cancellation,
dependency removal, errors, cleanup, and previously added seeded publication
timelines. They do not prove arbitrary graphs correct.

## Measurements against next

Five alternating paired processes per workload, pinned to CPU 4, Node 24.19.0,
AMD EPYC 9V74. No tests or builds ran concurrently with the measurements. The
repository creation/reactivity benchmarks and the unchanged supplemental workers
both use the real production packages. Ratios below are experiment time / next
time. Ranges are process-pair minima/maxima, not confidence intervals.

| Repository benchmark | Median ratio | Pair range |
| --- | ---: | ---: |
| Render-effect creation, 1:1 | 0.930 | 0.774–1.070 |
| Owner creation | 0.993 | 0.953–1.098 |
| Zero-dependency memo creation | 1.084 | 1.034–1.289 |
| One-to-one update | 1.042 | 0.998–1.437 |
| One-to-1,000 update | 1.071 | 0.773–1.115 |
| Diamond propagation | 1.020 | 0.963–1.062 |
| Equality-filtered propagation | 1.028 | 0.934–1.072 |

The creation suite's signal, one-dependency memo and memo-tree measurements have
large ranges; their raw results and summaries are retained rather than converted
into a broad creation-performance claim. Store benchmarks run with that harness
but are not acceptance evidence for the deferred store implementation.

| Supplemental synchronous workload | Median ratio | Pair range |
| --- | ---: | ---: |
| Settled signal read | 0.888 | 0.773–0.937 |
| Settled memo read | 0.971 | 0.941–1.034 |
| Ordinary write and flush | 1.012 | 0.953–1.205 |
| Memo write | 0.966 | 0.744–1.092 |
| Chain | 1.001 | 0.903–1.046 |
| Diamond | 1.009 | 0.950–1.019 |
| Effect fan-out | 1.036 | 1.003–1.083 |
| Memo creation/disposal | 1.110 | 0.879–1.173 |
| Inactive optimism, signal read | 0.914 | 0.904–1.021 |
| Inactive optimism, memo write | 0.942 | 0.867–1.022 |

The signal-read improvement is present in every pair. The small effect fan-out
regression and repository zero-dependency creation regression also appear in
every pair and must not be dismissed behind larger optimistic costs. Other
small medians have ranges crossing parity. These are comparisons to next, not
claims attributing all existing differences to this checkpoint's repair.

| Optimistic workload | Depth 1 | Depth 4 | Depth 16 |
| --- | ---: | ---: | ---: |
| Top override update | 1.451 | 1.412 | 1.132 |
| Propagation through transparent boundaries | 1.518 | 1.882 | 2.429 |

Five GC samples retain zero disposed readers in both implementations. Median
boundary heap deltas are about 1,058 versus 556 bytes (callback input), and 1,039
versus 569 bytes (direct input). The split boundary remains substantially more
expensive than next; this pass adds no node fields.

Same production/property-mangling/Rolldown/Brotli pipeline for both:

| Imports | Next minified / Brotli bytes | Experiment minified / Brotli bytes |
| --- | ---: | ---: |
| Ordinary scalar core | 19,825 / 7,421 | 21,303 / 7,959 |
| Scalar optimism | 30,556 / 11,180 | 35,789 / 12,958 |
| Optimism, pending and latest | 35,643 / 12,920 | 41,834 / 14,794 |

Removing the latest relationship proof did not offset the added publication and
lifetime checks. There is a small net size increase from the entry runtime, and
the existing size/performance acceptance gaps against next remain. No threshold
or expectation was relaxed. The earlier benchmark campaign in
`pre-external-bench/` measured an intermediate candidate; the tables above use
the rerun on the retained runtime.

Receipts and rejected trials: `checkpoints/integration-stage171.tar.xz`.
