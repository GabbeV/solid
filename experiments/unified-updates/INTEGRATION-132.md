# Complete a pending callback when its answer is already known

An owned `isPending(() => (existing(), initial()))` callback can encounter an
initialized source pending on an update, followed by a source still loading its
first value. The callback already knows its answer is true. Next returns that
answer; the experiment unnecessarily suspended instead.

Restore the existing next catch condition: an owned first-load NotReady still
propagates when no pending source was found, but does not suppress a known true
answer. Internal retry control flow always propagates. The runtime clears its
dev caught-read diagnostic when it consumes the throw, as next does. No early
exit is added: reads continue until the callback completes or throws.

Two public-API regression tests verify both completion orders. The displayed
answer becomes true, stays true while either request remains unfinished, then
returns false. Both tests and the entire caught-reactive-read diagnostic file
pass on pinned next `4fe75321` (20 tests). This does not change direct
`isPending(source)` first-load behavior or introduce a diagnostic.

## Validation

- Full signals: **5,214 passed, 2,114 failed, 2 skipped**. No new failures;
  one existing failure fixed and two regression tests added.
- Focused experiment/observation tests: **618 passed**, five existing deferred
  optimistic-store failures. All unified experiment suites pass.
- Focused web Loading and observation/#4677 regressions: **26 passed**, one
  deferred optimistic-store failure, matching stage 131.
- All build tiers, declarations, production purity checks and rules index pass.
- Ordinary core/store bundle scenarios are unchanged. Pending/latest is
  **35,162 minified / 12,575 Brotli bytes**, +10 / +4 in this pass; pinned next
  is **33,615 / 12,239**. Existing caps still fail; no thresholds changed.
  No new performance measurement or acceptance claim.

There remain 149 untriaged scalar failures, 10 #4544 calculation expectations,
two known first-proposal failures, and 1,953 deferred-API failures. The full web
inventory remains 135 failures from stage 130. Optimistic stores and until are
still deferred. Next investigation: enabling latest's ready first proposal
without splitting a derived store producer from its writes.

Receipts and failure inventory are archived in
`checkpoints/integration-stage132.tar.xz`.
