# Observation preparation before retirement

This continues [stage 106](INTEGRATION-106.md). Both checkout/latest failures
are fixed, without waiting for optimistic async work or requiring an optimistic
intermediate value to become visible before correction.

## Flush ordering

Observation preparation previously staged a new latest proposal and could
immediately retire its boundary, before the proposal's synchronous propagation.
Retirement merges the output update back into its input update. In the checkout
cases this took the ready shipping preview back into ordinary work which then
discovered its remaining tax hold.

Preparation now returns to the existing pure-work queue whenever it stages an
observation proposal. Retirement is considered again after that propagation.
There is no timer, promise wait, additional publication phase, or mandatory
intermediate render. In the checkout cases, preparation establishes the
remaining ordinary hold and the latest preview stays independent and publishes.
A suspended optimistic consequence can still be superseded at retirement.

This ordering exposed a separate mount-ownership mistake. A newly created
render binding was the hold protecting `mounted=true`. Its creator was an
effect whose private value was assigned directly, so the existing check for
a staged owner did not recognize the mounting frame. An upper notification
transferred the binding to its own update, leaving the mount control free to
publish without its child. The diagnostic trace records that exact transfer.

The notification path now preserves the binding's current hold when an ancestor
read a staged dependency belonging to that hold. It checks existing ownership,
dependency, initialization, and update fields. A root's initial reader with no
such mounting control can still follow an optimistic first value. Actual reads
retain their existing coordination rules; this guard only rejects adoption by
a notification.

Only `layers/observation.ts` and `layers/coordination.ts` changed in this pass.
Ordinary core and scheduler files are byte-identical to the stage-106 checkpoint.
No per-node fields, caches, delayed diagnostics, or persistent bookkeeping were
added. The extra ownership/dependency scan is restricted to a never-initialized
render binding receiving a higher update while already held.

## Trials and validation

The broad rule "preserve every never-published binding's hold" was rejected.
It also prevented initial root readers from following optimistic first values,
failed nine owned-context tests, and made the posture matrix stop completing.
A temporary attempt to protect input updates for a separate publication round
was also removed. Neither mechanism remains in the runtime.

`latest-retirement-order.test.ts` adds eight tests using the public API:

- A smaller checkout graph with either reader creation order, for scheduled
  and unscheduled effects: shipping preview `15 -> 25`, ordinary total remains
  `123` until tax answers, then becomes `145`.
- A mount whose unpublished child receives another latest notification:
  its control remains false until the child can publish; a stale answer cannot
  replace the child's result.
- A suspended latest consequence is corrected to `2` before its obsolete
  promise answers; that answer subsequently publishes nothing.

Both original late-mount regressions pass unchanged. The complete
createOptimistic file passes all 68 cases, including the two checkout failures.
The full package runs have no newly failing test names compared with stage 106:

| Package | Passed | Expected failures | Failed | Skipped |
| --- | ---: | ---: | ---: | ---: |
| signals | 4,051 | 18 | 1,677 | 2 |
| solid | 833 | 0 | 23 | 0 |
| web | 1,225 | 1 | 105 | 0 |

The first-failure classification now contains 1,645 deferred/unmigrated cases
and 32 accepted semantic differences awaiting migration. This is not proof
that later assertions in those tests pass. Optimistic stores and until remain
deferred; the full API suite is not green.

The eight new tests were also run against pinned next
`a24e911ba5e571e7adb1c9b5e5151261f9cf101c`. The four mount/cancellation cases
pass as written. The checkout cases deliver `[15, 15, 25]` rather than
`[15, 25]`, and clear shipping pending before ordinary publication (#4685).
A temporary baseline copy with those two expectations changed passes all eight;
the exact difference is saved in `next-expectation-differences.patch`. Candidate
assertions were not relaxed. The temporary baseline test was removed.

Builds, declarations, property mangling, and pure-annotation checks pass.
Final results are under `results/integration-stage107/*-retained.*`; earlier
trial reports are investigation artifacts. No diagnostic logging remains in
source. Nothing was pushed or posted.

## Size and remaining work

| Scenario | Pinned next Brotli | Candidate Brotli | Existing cap |
| --- | ---: | ---: | ---: |
| Core floor | 7,439 | 7,433 | 7,450 |
| + ordinary store | 14,706 | 14,694 | 14,710 |
| + isPending/latest | 9,692 | 11,623 | 9,730 |

Ordinary bundle sizes are unchanged. The observation bundle is 1,931 bytes
larger than next and fails its cap by 1,893 bytes. No thresholds were raised.
This pass makes no new timing or allocation measurement claim. Existing
normal-harness comparisons remain in stage 105; the observation size gap and
active-optimism costs remain acceptance work.

The result supports the flush-ordering direction: synchronous propagation
can establish publication obligations before retirement, without extending
optimistic async lifetimes. It does not establish correctness for arbitrary
feedback or dependency discovery. Continue validating subsequent migrations
against the full existing suite, particularly initial publication and ownership.
