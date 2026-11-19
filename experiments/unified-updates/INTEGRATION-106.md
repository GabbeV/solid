# Observation publication and scalar test migration

Follow-up: [stage 107](INTEGRATION-107.md) fixes the two checkout failures and
the mount-ownership obstacle to propagating observation proposals before retirement.
The results below describe the retained stage-106 checkpoint.

The pending behavior from stage 105 is retained. A ready value that differs
from its published value stays pending while another consequence holds its
publication. An equal answer can clear pending early. This applies equally to
ordinary and optimistic outputs. The user filed next's optimistic early-false
bug as [#4685](https://github.com/solidjs/solid/issues/4685), with the published
[rc.21 reproduction](https://s.olid.uk/id/U6ma1avLRKuXWGhrzWMEkQ).

## Runtime changes

All changes are in the integrated `src/layers/` implementation. Ordinary
signals, memos, reads, writes, and node layouts are unchanged.

1. `latest` recognizes an unheld staged value as a proposal. It does not first
   consume that proposal as ordinary input work and only subsequently establish
   its boundary. That premature ordinary read could irreversibly join an
   independent Loading request to an open action.
2. Observation preparation includes latest's staged values, even for fully
   synchronous updates. Otherwise deferring its proposal to the post-commit
   phase briefly displays `source=true, latest(source)=false`.
3. Observation restoration follows the update currently holding its input
   output, rather than necessarily the lower request remembered when the
   observation became active. In `isPending(() => latest(data))`, a ready
   latest output and its pending=false restoration publish together.
4. That restoration runs through existing scoped recomputation. Actual input
   reads still coordinate updates normally; merely running during a different
   update's flush does not merge them. A diagnostic trace demonstrated the
   unwanted depth-1/depth-0 merge in the old `resumeInput` call to `joinFuture`.

These are changes to proposal preparation and retirement, not new publication
paths. The selector outputs still use ordinary storage, async work, ownership,
effects, and commits. There are no new per-node fields, retained version maps,
caches, or diagnostic bookkeeping. A flag on latest's shared kind descriptor
opts into value preparation; the scoped retirement option is internal work
routing, not a public semantic exception.

## Executable evidence and test changes

The existing `loading-on-rearm-reveal-3540` independent-content test now passes:
an open action holds `dep=1`, `latest(dep)` re-arms Loading immediately, and an
independent content answer displays while ordinary `dep` still displays 0.
The ordinary `on: dep` control still waits for the action.

`latest-loading-independent-update.test.ts` adds six public-entry cases:
zero, one, or three memo-wrapped latest boundaries, with a superseded request
settling before or after its replacement. Each asserts the complete Loading
publication sequence `data 0 -> loading -> data 2`, beside the still-held
ordinary frame. The same six cases pass against pinned next. An initial test
draft also wrote the held frame in the same batch as the replacement request;
both next and the candidate correctly held that batch together. The retained
test issues an independent request instead of incorrectly requiring independence
for writes in the same batch.

The pending regression now checks the later reveal with the action still open,
not just the earlier ready-but-unpublished phase. Both equal and differing
answers are covered, for ordinary and optimistic updates.

The unchanged createMemo assertions caught transient `[true, newValue]` pairs
in two intermediate implementations. These trials were rejected. The retained
implementation passes those assertions, source-owned pending/latest composition,
read retries, errors, and owned-child cases. See the retained verification
results below. An intermediate phase-order trial passed 751 focused tests and
all 68 createOptimistic cases, but failed two late-mount cases when broadened;
it was rejected and those numbers are not acceptance results for retained code.

Test migrations apply previously accepted semantics; none removes a consistency
assertion:

- Ordinary reads of a pending optimistic output retain its published value.
  Async-chain and category tests still check their complete effect histories,
  matching answers, correction, repeated cycles, and overlapping actions.
- A latest output held by its own downstream async reports pending. Independent
  and combined pending readers agree while its value stays old, and false
  publishes with its new value. Wrapping a pending boolean in latest observes
  that boolean rather than changing the source question.
- An unchanged pending=true output suppresses redundant computation through
  equality. The previous-value regression still requires a valid empty-array
  previous value on every actual pass, including pending=false restoration.
- Checkout pending assertions preserve #4685's distinction between an explicit
  latest display and the ordinary output still held by the combined total.
  An incoming config stays masked until the guessing lifetime retires.
- The rapid correction test now saves the old request's resolver before the
  next action. Previously its purported stale-answer step called the newly
  replaced resolver and resolved the current request. The corrected test also
  asserts that the genuine stale answer causes no visible replacement.

## Open implementation bug and rejected trials

Migrating direct-read assertions exposed two checkout cases where
`latest(shippingInfo)` remains stale after shipping resolves, while tax should
hold only the combined ordinary total. The trace shows latest's restoration
being judged ready before preparation has discovered the additional hold.
These cases are implementation bugs, not intentional semantic differences.
Their visible-value assertions remain unchanged.

A trial deferred all observation retirement until newly staged proposals had
propagated. It passed the focused cases and all 68 createOptimistic tests, but
the full suite exposed two previously passing late-mount failures in
`l2-fuzz-existing-rules`: a mount control published while its child binding
remained absent. Those assertions were not changed. Further trials involving
outer phase ordering, per-output queue checks, creator hold propagation, and
uninitialized-reader handling did not solve both problems. All were removed.
The retained implementation fixes the original Loading case without introducing
those mount regressions; the two checkout cases remain open.

The diagnostic snapshots show a newly initialized child moving to another hold
before its first effect callback applies, while the mount control publishes.
This identifies a publication/ownership obligation worth investigating, not a
complete root-cause proof. Do not reinstate the broader delay merely because
its focused tests pass. This is also why a first-failure inventory is not proof
that the rest of a classified test already works.

## Remaining acceptance work

Normal builds, declaration emission, property mangling, and pure-annotation
checks pass. Full-suite and size artifacts are under
`results/integration-stage106/`; final verification uses the `*-retained` files.
The `*-verified` files record the subsequently rejected phase-order trial.
Diagnostic traces are investigation artifacts only; no tracing remains in the
runtime. No code has been pushed or published.

Retained full-suite results:

| Package | Passed | Expected failures | Failed | Skipped |
| --- | ---: | ---: | ---: | ---: |
| signals | 4,041 | 18 | 1,679 | 2 |
| solid | 833 | 0 | 23 | 0 |
| web | 1,225 | 1 | 105 | 0 |

There are no newly failing test names compared with stage 105. Signals has
19 fewer existing failures and eight additional tests (six latest/Loading
cases plus the pending equality matrix expansion). The complete createMemo
file passes; createOptimistic has 66 passing cases and the two checkout bugs.
The retained failure inventory classifies 1,645 first failures as deferred or
unmigrated API cases, 32 as accepted semantic differences awaiting migration,
and two as implementation bugs. This classification does not verify assertions
after the first failure. The until API remains explicitly deferred; its errors
have not been suppressed. This run's JSON reporter does not enumerate unhandled
errors separately, so stage 105's unhandled-error count is not a new measurement.

The normal public API remains the stage-105 scope. Optimistic stores and until
are still explicitly unimplemented. Other legacy semantic pins still need
migration, and their later assertions remain unverified where a prior assertion
stops execution. Full API acceptance is not claimed.

The ordinary import size scenarios remain within their existing caps:

| Scenario | Pinned next Brotli | Retained candidate Brotli | Existing cap |
| --- | ---: | ---: | ---: |
| Core floor | 7,439 | 7,433 | 7,450 |
| + ordinary store | 14,706 | 14,694 | 14,710 |
| + isPending/latest | 9,692 | 11,555 | 9,730 |

The observation scenario is 1,863 bytes larger than next and fails its cap by
1,825 bytes. No limit was raised. No new timing benchmark claim is made in this
correctness pass. The
existing normal-harness comparisons against pinned next remain recorded in
stage 105; correctness coverage here does not close the performance or size
acceptance gates.

The current evidence supports continuing with the shared-output model. The
resolved failures were coordination mistakes during preparation and retirement,
fixed using existing update scopes rather than additional versions or a parallel
optimistic publication engine. The remaining shipping/mount interaction needs
further analysis before expanding this change. This is evidence for the tested
graphs, not a proof of arbitrary feedback or dependency discovery.
