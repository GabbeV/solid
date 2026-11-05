# Single-place self-release assertion

Current decision: the user explicitly deferred this diagnostic. Retain the
existing coherent supersession/reversal behavior without throwing or logging.
This patch is historical investigation, not queued implementation work. Its
readiness-transition check has not established an actionable error condition
without false positives in all relevant propagation cases.

Candidate patch: `assert-self-release.patch`. It was applied to the real scalar
core and tested, then removed from the working source. This preserves the
existing experimental semantics while keeping the proposed restriction directly
reviewable and reproducible. No tests were weakened or changed to accept errors.

The assertion lives entirely in `adoptOutput`, after its existing exclusion
checks. It uses stack-local state for the duration of that synchronous operation:

1. Only consider a node with an active flight held by a different update.
2. Use the existing active-layer records to establish that the incoming
   proposal's lifetime is that old update. An independently owned override is
   excluded. An open action is an immediate exemption.
3. If that lifetime is blocked before transfer, assert that it is still blocked
   after the transfer and its synchronous subscriber propagation.

No saved error candidates, extra node fields, notification history, or later
correction-time matching. This intentionally chooses the simpler restriction:
an optimistic proposal may not synchronously remove its own remaining lifetime
support. It does not wait to learn whether its eventual reversal would suspend.

`latest` is excluded using its existing `statusInput` marker. Its input becoming
ready can leave the same selected value exposed, so input release alone does not
establish a reversal. The first trial included it and failed two supported
latest/composed-observation tests; excluding it restored their previous outcomes.
This exclusion does not fix the separately recorded pure-latest duplicate request.

The check uses the scheduler's existing `blocked` predicate, so it accounts for
visible pending work, open actions, and scoped input holds. It avoids classifying
ordinary dependency-edge origins, including the callback-isPending ambiguity.

## Cost and validation

- Development-only assertion. The production scalar build succeeded and all
  **45 production JS modules were byte-for-byte unchanged** relative to the
  build captured before applying the patch. This is a compile-out check, not a
  new performance comparison.
- No new path in signal reads, writes, memo creation, or ordinary notification.
  The extra development work is restricted to optimistic adoption, with graph
  readiness scans only for eligible active async transfers. Scans are not O(1).
- Full no-legacy scalar run with the narrowed patch: 409 reported passes, six
  failures, 34 baseline/legacy exclusions. The six failures are precisely the
  existing self-feedback audit variants: direct, indirect, and two readers,
  each in both orders. They fail because the new assertion throws; they are not
  six newly passing tests. Existing expected-failure tests retain their status.
- Independent-request, open-action, delayed-spinner, nesting, latest composition,
  and other existing scalar tests retained their previous outcomes.
- The source was restored exactly to its pre-patch bytes after the trial. The
  restored-suite report and guarded report are in `results/lifetime-assert-stage86`.

The candidate is deliberately limited to active-flight takeover through this
single function. It does not claim to detect every deferred subtree disposal or
every possible transient readiness gap. No finite test run proves absence of
false positives in all dynamic graphs. A production-enforced version would need
active-async cost and error-routing validation; it has not been installed.

To reproduce the guard experiment from the repository root:

```sh
git apply experiments/layered-updates/assert-self-release.patch
cd packages/signals
SIGNALS_SCALAR_ONLY=1 node node_modules/vitest/vitest.mjs run layered- \
  -t '^(?!.*(?:baseline|legacy)).*'
```

Reverse only this candidate patch from the repository root afterward:

```sh
git apply --reverse experiments/layered-updates/assert-self-release.patch
```
