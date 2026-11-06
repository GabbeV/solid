# Preserve resolve's first accepted answer

`resolve` now keeps an already accepted value or error when another calculation
runs before its queued delivery. The previous generation check treated every
answer as a replaceable proposal, making a quiet refresh replace the first
settled answer with a later one. Pinned next returns the first answer here.

A proposal from a foreign pending update still waits for publication and can
be superseded. The watcher records the update in which it sampled the answer
and applies its generation and hold checks to that case. This is one captured
local per queued delivery; no node fields or ordinary-read machinery change.
Context-discovery retries also remain internal control flow, rather than being
delivered as user errors.

Six new regression cases exercise accepted values/errors, superseded foreign
values/errors, and context discovery inside/outside actions. The first four
and the five existing resolve-in-action tests pass on pinned next `4fe75321`.
The two context cases intentionally use the experiment's existing higher
optimistic context rule: read the committed lower source while its update is
held. Next waits instead. These tests do not introduce a new lifetime ruling.
An A/B trial without the retry guard fails the inside-action case.

## Validation

- Full signals: **5,211 passed, 2,115 failed, 2 skipped**. No new failures;
  the existing quiet-refresh resolve failure is fixed and six tests are added.
- Focused web Loading and observation/#4677 regressions: **26 passed**, one
  existing deferred optimistic-store failure. This is not a new full web run;
  the last full web inventory remains 135 failures from stage 130.
- All build tiers, declarations, both production purity checks, and the rules
  index pass. The existing size harness reports unchanged selected scenarios:
  core **21,153 / 7,904**, store **45,222 / 15,513**, pending/latest
  **35,152 / 12,571** minified / Brotli bytes. These imports tree-shake resolve;
  this is not a measurement of resolve's own size. Existing caps still fail.
- No new performance benchmark or acceptance claim.

The failure inventory now has 150 untriaged scalar failures, 10 remaining
#4544 calculation expectations, two known first-proposal implementation
failures, and 1,953 deferred-API failures. Web classification is unchanged.
Optimistic stores and until remain deferred. Next: compound pending callback
behavior and the remaining scalar publication failures.

Receipts, the rejected retry-guard trial, and inventory are archived separately
in `checkpoints/integration-stage131.tar.xz`.
