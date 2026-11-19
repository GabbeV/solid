# Pending feedback: existing metadata audit

**Follow-up:** [stage 81](./PENDING-CANCELLATION-ALTERNATIVES-81.md) tests request
starts and alternatives. The secondary-work example below does **not** establish
that its cancellation is desirable: the candidate repeats the request; splitting
the fetch from presentation avoids that. Pinned next does not prematurely start
the inline request in that experiment. Matching displayed values was insufficient
evidence for the earlier argument against an error policy. The metadata findings
remain useful, but the desirability of the cancellation must be assessed separately.

This stage changes no runtime code or semantics. It investigates the request
for an actionable pending-feedback error without new bookkeeping or ordinary
runtime overhead. Stage 79 remains the implementation checkpoint.

## What is already available

At `notifyLayer(source, reader)`, before `adoptOutput` transfers ownership:

| Fact | Existing representation | Work required |
| --- | --- | --- |
| Reader has an active request | `reader._x._inFlight` | Field lookup |
| Reader's current update | `CONFIG_HELD`, `txOf(reader)` | Existing resolving lookup |
| Notification's update/depth | Source holder and transaction `_level` | Existing resolving lookup |
| Direct source is an observation output | `boundaries.get(source)` | Existing opt-in weak map lookup |
| Observation's input | Boundary `input` | Field lookup |
| Observation's tracked parent | Observation `parent` | Field lookup, but not always populated yet |
| Async sources making an input pending | `_pendingSources` | Existing set, when present |
| Update's currently visible blockers | `blockersOf(update)` | Scan of transaction nodes and subscriber links; allocates an array |
| Pending output behind an intermediate memo | Existing `_deps` links | Graph traversal, not a constant-time test |

No new permanent fields are needed to inspect these facts. They could be
inspected inside a development-only branch in the optional layer engine,
compiled out of production. That would still cost development time proportional
to the inspected graph. An indirect traversal needs temporary cycle protection;
it is not literally allocation-free.

The ownership check must precede adoption: the subsequent recomputation clears
the old request after the node has already moved to the higher update. Checking
only the new owner at cancellation loses useful information. The observation's
`parent` also cannot be the sole source of attribution: status-first preparation
can stage its proposal before that field is populated. Both happened in this
audit.

`_pendingSources` is not a general causal explanation of pending. A held signal
can have a different proposed value, hence `isPending(id) === true`, without any
pending-source set of its own. Its completion depends on the update's blockers.

## A counterexample to the broad error rule

```js
const [id, setId] = createSignal(0);
const primary = createMemo(() => id() === 0 ? 0 : loadPrimary(id()));
const secondary = createMemo(() => {
  const value = id();
  if (isPending(id)) return "waiting";
  return value === 0 ? 0 : loadSecondary(value);
});
// Render id, primary, secondary and isPending(id) separately.
setId(1);
```

Both requests initially start. Pending then replaces the secondary request with
`"waiting"`; primary continues holding the input update. While held, both pinned
next and the candidate show `id: 0`, `primary: 0`, `secondary: waiting`,
`pending: true`, in either read order. The executable audit uses -1 for waiting.

In the candidate, the cancelled secondary request belongs to the same update as
the pending observation's input **and is one of that update's visible blockers**.
All those facts also hold in the problematic self-feedback reproducer. Thus
adding blocker membership to the proposed cancellation warning does not make it
a sound error rule. Suppressing that notification would also suppress an
intentional consequence of pending in this example.

Querying `isPending(primary)` instead of `isPending(id)` also works. Its input
pending-source set correctly identifies primary, whereas the id variant has no
such set. A synchronous status label shows `true:0` without cancelling a request;
an ordinary superseding id write cancels a request without a pending dependency.

Counting only the last blocker would narrow the check, but would not establish
a general rule: action openness also affects readiness; multiple pending
consumers can remove blockers in succession; a replacement's next reads and
async result are not yet known at notification time. This audit does not prove
that no precise narrower rule is possible. It does show that the inexpensive
predicates investigated here are insufficient to classify cancellation as an
application error. A graph path is evidence of dependency, not of an invalid
program or the cause of every queued rerun.

## Recommendation and remaining issue

Do not add a broad cancellation error, an ordinary-read flag, or persistent
notification provenance. Existing metadata is enough for targeted debugging and
experiments; a future precisely specified unsupported cycle could be checked
in development using existing links. No such error predicate has been validated
here. General historical attribution would require information the current
runtime deliberately does not retain.

The self-feedback bug remains: the candidate starts the id=1 request, reruns with
id=0/pending=true, then restores id=1/pending=false and starts another request.
Its pending output remains false while held. Pinned next instead has the earlier
read-order discrepancy. This stage neither fixes that behavior nor approves it.

## Validation and reproduction

- Twelve metadata audit cases: six scenarios in both read orders, controlled
  promise gates, actual render publications and request replacement identities.
- Twelve corresponding public-API timelines against each built runtime. Next
  is pinned at `a24e911ba5e571e7adb1c9b5e5151261f9cf101c`; candidate is stage 79.
- Focused candidate pending tests: 32 passed, six explicitly named baseline
  cases excluded in the no-legacy run. This is not a complete scalar acceptance
  run or proof of diagnostic completeness.
- No production source changed, so this investigation adds no shipped code,
  runtime allocations, or ordinary-path branches. No new timing claim is made.

Metadata test:
`packages/signals/tests/unified-pending-feedback-metadata.test.ts`.
Public audit: `experiments/unified-updates/pending-cancellation-audit.mjs`.
Results: `experiments/unified-updates/results/pending-metadata-stage80/`.

```sh
cd packages/signals
SIGNALS_SCALAR_ONLY=1 PENDING_METADATA_OUT=/tmp/pending-metadata.json \
  node node_modules/vitest/vitest.mjs run unified-pending-feedback-metadata.test.ts
```

From repository root, run the public audit with either built entry:

```sh
node experiments/unified-updates/pending-cancellation-audit.mjs \
  /workspace/layered-baseline/packages/signals/dist/prod/index.js
node experiments/unified-updates/pending-cancellation-audit.mjs \
  packages/signals/dist/scalar/index.js
```
