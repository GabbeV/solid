# Migrate obsolete observation-answer lifetime assertions

No runtime changes. The six migrated failures require an async optimistic
answer to publish after its input is otherwise finished. This conflicts with
the user's explicit stage-127 decision: optimistic derivations must not define
the lifetime of the input update they observe.

## Controlled comparison

A memo asynchronously derives `${isPending(data)}:${latest(data)}`. Both data
and that output have render observers. Start with data=0; update it to 1.
Resolve the pending badge first, then resolve data, leaving the new badge work
under separate controlled gates.

| Step | No action keeps the input open | Action still keeps the input open |
| --- | --- | --- |
| Initial | false:0 | false:0 |
| Pending badge answers | true:0 | true:0 |
| Data answers; true:1 badge answers | still true:0 | true:1 |
| Action ends and false:1 correction answers | false:1 | false:1 |

The ordinary data observer stays at 0 until correction is ready, then publishes
1. Without the action, resolving obsolete true:1 does not publish it. With the
independent action lifetime, true:1 is useful work and can publish. Both cases
pass on the shared engine. Pinned next passes the action control and fails the
no-action assertion because it publishes true:1 too.

Migrate one own-window pending/latest test, three grouping forms in #4398,
and two inline/memo latest forms in #4393 to the accepted correction behavior.
Keep exact visible sequences, grouping equivalence and final publications.
Keep the pending/latest request sequence assertion unchanged. Duplicate asks,
one-pass counts and cases with other lifetime/observedness complications remain
open; no request-count expectation was relaxed.

All six original cases pass on pinned next with their original expectations.
The changed output is an intentional consequence of the prior ruling, not a
claim that next violates its own declared behavior in these six cases.

## Validation

Full signals: **5,490 passed / 2,040 failed / 2 skipped**, no new failures or
collection errors. Relative to stage 152's full run this includes its two later
Loading controls, two new lifetime controls, and six migrated failures.
The eight focused cases pass against built production artifacts. Runtime is
unchanged from stage 152; no rebuild, web rerun or performance claim is needed.
The separate latest/store ownership problems investigated in stage 153 remain.
