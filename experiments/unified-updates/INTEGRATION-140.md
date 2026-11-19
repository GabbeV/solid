# Pending callbacks retain the published value during a hold

Fix the stage-139 callback selection gap. The pending callback's existing
value-selection branch now covers a ready answer that is still held, as well
as an unresolved async answer. It reads the published value for control flow;
an uninitialized source with an available first answer retains the existing
first-answer exception. No node fields, allocations, or ordinary-read-path
changes are added. The extra condition runs only in pending callback probes.

Four regressions exercise synchronous/asynchronous replacements, with and
without a separately held enclosing reader. A callback selects a left/right
signal from a property of the input object. Unrelated writes rerun it during
the hold, before and after resolution; the callback must keep selecting the
published branch. After publication it must select the replacement branch.
Render effects assert the source's complete publication sequence. Callback
counts are not specified: every observed callback must select the correct
value. All four fail before the fix and pass afterward and on next 4fe75321.

One experimental internal diagnostic test expected a callback's incidental
ordinary dependency on its held input. The fixed callback no longer creates
that dependency. Update that assertion and add the indicator's observable
publication sequence, `[false, true, false]`, for direct and callback probes.
This is an implementation-bookkeeping change, not a new diagnostic policy.
No existing consistency assertion is removed or weakened.

## Validation

- Full signals: **5,240 passed, 2,111 failed, two skipped**. Compared with
  stage 137's retained full run, the failed-test set is identical. Eight
  passing additions are stage 138's four controls and this stage's four
  regressions. All **590 unified scalar tests** pass in this full run.
- Six final callback tests pass separately. The first broad trial had one
  failure from the internal attribution expectation described above; its
  report is retained alongside the corrected full and focused reports.
- All **35 selected JSX tests** pass: first-value narrowed Show/Match access,
  pending-sample publication, and latest error publication/recovery.
- Four new regression cases pass against unchanged next 4fe75321.
- All signals build tiers, property mangling, purity checks, declarations,
  targeted formatting, rules index, and diff checks pass.
- No full web/hydration suite or benchmark/size measurement was run.

The fix does not introduce an untracked completion rerun or settle that
separate semantic question. Stage 139's initial-flush speculative tracked
callback difference is not addressed here. This checkpoint repairs the
established-hold selection gap, not every pending observation difference.

Reports and the failure-set comparison are archived in
`checkpoints/integration-stage140.tar.xz`. Temporary next comparison tests
were removed; next runtime sources are unchanged.
