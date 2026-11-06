# Restore observations before an unheld input publishes

This follows [stage 121](INTEGRATION-121.md), keeping stage 120's independent
input/override lifetimes. It repairs four existing deferred-arrival assertions
and adds two async reversal/supersession tests. No new semantic ruling was needed.

## Observable behavior

After a deferred refetch resolved, a binding of its value and pending state
could publish `new value / true` followed by `new value / false`. The shared
observation lifecycle prepared restoration only when the input had a live
transaction. A deferred landing is often ready and unheld, so its pending
restoration happened after that landing's publication.

An unheld ready input now prepares the restoration in the ordinary flush.
The value and pending=false can publish together. The same path handles a
memo derived from the deferred value, a normal derived-store leaf, a wrapping
deferred accessor and a stream's first yield. No deferred-specific publication
engine is introduced.

The harder case gives that restoration an async consequence:

```ts
const value = createDeferred(() => id() ? loadValue(id()) : 0);
const status = createMemo(() => {
  if (isPending(value)) return "loading";
  const current = value();
  return current ? loadDetails(current) : "idle";
});
```

Separate bindings display value, `isPending(value)`, and status. Their tested
timeline is:

| Event | Visible value / pending / status |
| --- | --- |
| Initial | `0 / false / idle` |
| Request value 1 | `0 / true / loading` |
| Value 1 answers; details 1 starts | `0 / true / loading` |
| Details 1 answers | `1 / false / ready` |

The input and the restoring false output use ordinary coordination: details
reads the new input proposal, so it holds that proposal until ready. Pending's
published true output remains coherent with its published `loading` derivation.
The test asserts that details starts exactly once.

The unmodified next control (`4fe75321`) instead shows `1 / false / idle` while
details is pending and starts details twice. The pre-stage-122 experiment showed
`1 / true / loading`, with one details request. The new timing is the consequence
of preparing the ordinary restoration before input publication, not a new
observation exception.

## Supersession and lifetime

A second test starts request 2 while details 1 is pending. Pending=true now
describes request 2; completion of the ready value-1 transaction cannot end
that question. The implementation must not restore false simply because that
older transaction becomes ready.

Request 2 immediately cancels details 1's computation and cleans up its scope.
Deferred keeps its ready answer 1 as a stale display, so the screen can become
`1 / true / loading` while request 2 runs. This follows deferred's existing
rule of retaining a ready landing when another question starts. Resolving the
obsolete details-1 promise changes nothing. Value 2 then starts details 2 once;
their completion publishes `2 / false / ready 2` together. The test checks
separate bindings, request counts, immediate cleanup and final disposal.

## Implementation and rejected trial

- `resumeInput` accepts an unheld input context. It uses the normal flush, or
  creates an ordinary transaction when an already-held output needs its
  restoration coordinated. This is the same restoration function used by
  optimistic boundaries.
- If downstream work discovers a hold during restoration, the observation
  retains that transaction in its existing parent slot. Otherwise it can
  misclassify its own new hold as another pending question and restart work.
- A changed input question supersedes an obsolete restoration during
  preparation, before readers replay, rather than only after publication.
- A declared pending question (`createDeferred`/`affects`) does not use a ready
  value transaction as its lifetime owner. Its existing mark determines when
  that question ends. This adds no new lifetime record.

Eagerly staging true directly from every mark notification did not fix the
supersession case and regressed a synchronously resolving thenable assertion.
That trial was removed. The retained fix addresses restoration ownership and
preparation order, with no new notification hook, cache, or node field.

## Validation and limits

Receipts are in `results/integration-stage122/`.

- Complete signals suite: **5,165 passed, 2,143 failed, 2 skipped**. Four existing
  failures are fixed and both new cases pass. No formerly passing case fails.
- The two new tests also pass with strengthened immediate-cancellation and
  cleanup assertions after the complete suite run.
- Built web suite: **1,584 passed, 139 failed, 1 skipped**, with the exact same
  existing failure set as stage 121.
- All build tiers, property mangling, pure-annotation checks and declaration
  build pass.

This does not complete scalar acceptance. The remaining suite failures include
deferred APIs (`until`, optimistic stores) and other implementation/semantic
migration work. No test threshold or size cap was raised. No external issue,
comment, PR or push was created.

## Costs against next

| Import scenario | Next minified / Brotli | Experiment minified / Brotli |
| --- | ---: | ---: |
| Ordinary core | 19,825 / 7,421 B | 21,153 / 7,904 B |
| Ordinary store | 43,868 / 15,089 B | 45,222 / 15,513 B |
| Pending/latest | 33,615 / 12,239 B | 34,770 / 12,468 B |
| Scalar optimism, supplementary | 31,722 / 11,561 B | 34,248 / 12,487 B |

These use the repository's production size harness and the same supplementary
optimistic imports as stages 120–121. Ordinary core/store sizes remain unchanged
by this follow-up. Existing size caps still fail.

The latest runtime checkpoint is the stage-121 built-package benchmark series
against next, before this observation-lifecycle follow-up. It found mixed
results, including a 7.6% slower median for one-to-one updates and a 3.8% faster
diamond. Those measurements are not a performance acceptance result or a claim
about the cost of this follow-up. No ordinary node layout or synchronous
ordinary read/write path changed in stage 122; its additional work is in active
observation restoration. Allocations and retained memory were not measured in
this pass.
