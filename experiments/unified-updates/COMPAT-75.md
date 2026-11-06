# Stage 75: unchanged upstream tests against the scalar replacement

The replacement is not ready for full API expansion. An unchanged upstream
subset now runs through the experimental entry with legacy lanes disabled.
This exposed real gaps beyond the dedicated unified-update tests, and several fixes
are retained. A pending-observation feedback case needs a semantic decision.

## What the numbers establish

The selected corpus contains **654 tests in 117 unchanged root-level upstream
files**. Every selected file's bytes match pinned next
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`. The baseline run uses those exact file
names under the pinned checkout, with its normal public entry.

| Run | Passed | Existing expected failures | Failed |
| --- | ---: | ---: | ---: |
| Pinned next, selected corpus | 650 | 4 | 0 |
| Replacement, same corpus | 572 | 2 | 80 |

86 of the 117 replacement files pass in full. Two of its reported failures are
upstream `it.fails` assertions that now succeed, including F5b and the #3800
fresh-boundary case. Their modifiers and expectations remain untouched.

The separate normal-entry regression run passes **5,589 tests in 333 files**,
with 22 expected failures and two skips. The dedicated unified-update run passes
416 tests in 37 files, with two expected failures in legacy comparison cases.
These figures must not be substituted for the unchanged-suite migration count.

Selection excludes stores, attribution, missing public APIs, unaudited internal
imports, infrastructure-only tests, and the existing locally changed Loading
fixture. The inventory records 115 other root-level files and a reason for each
exclusion. It selects whole files, not only favorable individual tests. No
missing API is replaced with a placeholder. The adapter explicitly exports
shared ownership/context/error utilities and `resolve` alongside the new scalar
entry; it never falls back wholesale to the legacy index. It also checks that
legacy lanes really are disabled.

## Retained implementation fixes

1. **Error forwarding through latest.** Reading an errored producer through the
   ordinary pull path could retry it before forwarding the error, hiding the
   rejection behind a fresh pending request. The latest boundary now forwards
   the current error while keeping its dependency. Promise/stream, separate
   pending observer, held-action and recovery cases are covered. No ordinary
   read fast path changes for this fix.
2. **Observation allocation from effect callbacks.** The source's lazily created
   companion is internal allocation; its first read must not trip the diagnostic
   against user-created ownerless computations inside an effect callback. A
   shared helper suppresses that dev-only guard only around lazy construction.
   Producer evaluation happens afterward with normal diagnostics restored.
3. **Mainline mount scope.** Dependency discovery used to leak the selected
   transaction into unrelated writes made after a fresh memo's construction.
   The existing scoped recompute helper now covers the entire initial pass,
   including staging. The discovery context stays provisional until accepted,
   so a late reader cannot demote an existing optimistic update. Ordinary
   synchronous nodes with no active coordination allocate no extra transaction.
4. **Pending/latest publication.** A pending output observing latest could lose
   the original request's update after latest published an unchanged value.
   It then rendered `[true, 20]` before `[false, 20]` on completion. Its existing
   parent slot now also follows that incoming request when the immediate output
   has no held update. No new per-node field was added.
5. **Expiration with an equal async correction.** The previous-value rule must
   exclude an abandoned result from callback history without losing it too early
   from equality comparison. Dropping it as soon as the replacement suspended
   let an answer equal to the committed value skip invalidating consumers of
   the abandoned proposal. An upstream timeline rendered `0:1`. The old staged
   value now remains available for comparison while waiting, but a fallback
   commit or real error cannot install it as committed history. The unchanged
   upstream expiration test and previous-value recovery tests pass.
6. **Repeated preparation after a canceled proposal.** Net-zero writes were
   dropped correctly, then a later preparation pass re-enrolled their empty
   queue slots. Later independent writes became held. Canceled entries are now
   removed by stable, linear queue compaction, preserving order and appended
   work. This adds no node properties or cancellation registries.
7. **Refresh diagnostics.** Invalid scalar targets now use the existing dev
   diagnostic code and the upstream production no-op behavior. Stores remain
   outside this export's supported target types.

Two rejected attempts are relevant to review: directly switching discovery to
pass-scoped membership caused infinite retries in nested discovery; treating all
empty un-staged queue entries as canceled broke legitimate status work. Neither
is retained. The final fixes scope the whole computation and remove the actual
canceled entries instead of inferring cancellation from node state.

## Remaining failures: review status

`results/compat-stage75/failure-review.json` records every remaining failure:

- 43 require deferred optimistic constructor forms or ambient guess lifetimes.
- Nine match already accepted differences: outside uninitialized observations,
  shared latest-output pending status, observation composition, or unspecified
  sibling callback ordering.
- Two are successful assertions still marked as expected failures upstream.
- Four expose the pending-observation feedback question below.
- **22 still need individual investigation.** They are not declared intentional,
  and are not all presumed bugs. They include mount/Loading, retained ownership,
  and re-execution count cases. Investigation is incomplete; no assertions were
  changed to hide them.

An initial failure in createMemo halted reactivity and made later cases fail.
Running those cases in fresh processes distinguished genuine mismatches from
contamination. After repairing internal observation allocation and the other
retained fixes, 75 of createMemo's 80 tests pass unchanged; four remaining cases
use the removed outside-read exception and one expects the old latest channel's
special pending treatment.

## Semantic decision: an async computation observes its own pending cause

The standalone `pending-feedback-audit.mjs` runs real built next and candidate
runtimes. It starts at count=0 and data=0, sets count=1, and holds a request whose
answer is 10. Scheduled render effects separately observe count, data, and
`isPending(count)`.

```ts
const [count, setCount] = createSignal(0);
const data = createMemo(() => {
  const value = count();
  isPending(count); // tracked, even though this example ignores the boolean
  return value === 0 ? 0 : request.then(() => value * 10);
});
```

| While the request is held | count shown | data shown | pending shown |
| --- | ---: | ---: | --- |
| Next, with or without the extra read | 0 | 0 | true |
| Candidate, without the extra read | 0 | 0 | true |
| Candidate, with the extra tracked read | 0 | 0 | false |

All finish at count=1, data=10, pending=false. The candidate's calculations with
the read are `(0,false) -> (1,false) -> (0,true) -> (1,false)`: the optimistic
pending pass does read committed count=0 as previously required, but its
restoration rejoins the held request. A tracked latest read produces a related
feedback shape. The comparison's output includes every calculation and actual
render callback, not only final accessor values.

This is distinct from the removed exception for imperative/outside reads: the
extra read is inside the async-producing memo, and the indicator is a reactive
render consumer. With one shared observation output, the request-producing memo
is also its dependent. Keeping next's indicator behavior cannot be justified by
silently restoring per-reader verdict state or claiming all ordinary consequences
of the output may ignore its publication hold.

The choice needs review before calling this intentional. One option is to retain
the ordinary shared-output dependency rule and accept that such a subscription
can hold its own indicator. Preserving next's behavior needs further investigation
of retained lower work or a bounded observation rule. Neither a universal
impossibility nor a requirement for full duplicate graphs has been established.
No new exception or per-context async history has been implemented.

The next behavior is deliberate in the checked-in implementation and derived
rules. `RULES-DERIVED.md` describes #3884: a node whose fetch holds an update
remains that update's work, even if an earlier pass called `isPending` or
`latest`. Core clears its verdict posture while a fetch is pending. The public
[issue #3884](https://github.com/solidjs/solid/issues/3884) reports that a probe
inside a parked memo must not change other readers' pending/latest answers;
the closing comment links fix `f6905dc8` / #3934. The issue is under Ryan's
account, but the closing comment explicitly credits Grok via Cursor; this is
evidence of an intentional upstream fix, not an independent human ruling on
this experiment's shared-output model. The fetched text is archived here.

The current false indicator is an observed implementation outcome, not proof
that shared outputs require it. In particular, the intermediate `(0, true)`
calculation is synchronous in this example. The unresolved design issue is
how that calculation can publish without retiring the pending indication and
rejoining the lower request first. Reinstating next's in-flight-reader exception
would instead calculate using proposed count=1, which needs review against the
earlier committed-input ruling. A mechanism preserving both the lower request
and the upper calculation has not yet been established or measured.

## Validation and artifacts

### Follow-up: next's feedback exception is not a consistency reference

Two production audits now make the read-order issue observable. Each variant
runs in a fresh process, using the same pinned next bundle and separately
scheduled render bindings. With numeric data, reading count before pending
shows `count=0, data=0, pending=true` while the request is held. Swapping those
two reads shows `count=1, data=0, pending=true` at the same held checkpoint.
This is an actual published count/result mismatch, not only an internal pass.
Both eventually settle to `1, 10, false`. No Loading or deferred boundary is
present. The pending-first variant also reproduces with an object result.

The object-result audit includes the pending boolean in the memo's answer.
With count read first, next shows the direct pending output as true while the
memo's stored pending field remains false. That conflicts with this experiment's
requirement that ordinary consequences of a boundary output publish coherently.

Scripts: `pending-numeric-feedback-audit.mjs` and
`pending-visible-feedback-audit.mjs`; pass the built runtime path and either
`count-first` or `pending-first`. Four corresponding `feedback-*-next-*.json`
files record the runs. These are follow-up artifacts, outside the earlier final
checkpoint snapshot. The existing next fix has a reasonable aim (a probe must
not accidentally release a request), but does not establish a coherent general
exception. The earlier question should not frame adopting it as an equally
validated alternative. The prototype's suppressed indicator remains unresolved;
these findings do not validate that behavior either.

The retained normal and migration run logs, exact-source manifest, baseline
report, import inventory, failure review and production timelines are under
`results/compat-stage75/`. Source and focused test typechecks pass. The scalar-only
checks cover new error/publication cases, stable nested contexts and previous
values. Build warnings remain the pre-existing diagnostics in the archived log.

Performance acceptance has not been established by these fixes. Stage 74's
measurements are historical; they are not claimed as measurements of this changed
runtime. The remaining active-throughput and feature-size gates still apply.
Stores and the rest of the public surface remain paused.

To reproduce the unchanged-suite run:

```sh
node experiments/unified-updates/scalar-compat-inventory.mjs
cd packages/signals
node node_modules/vitest/vitest.mjs run --config vite.scalar-compat.config.ts
SCALAR_COMPAT_BASELINE_ROOT=/workspace/layered-baseline/packages/signals SCALAR_COMPAT_REPORT=/tmp/scalar-baseline.json node node_modules/vitest/vitest.mjs run --config vite.scalar-compat.config.ts
```

A nonzero replacement exit is expected while the recorded compatibility
mismatches remain. It must not be represented as a green migration run.
