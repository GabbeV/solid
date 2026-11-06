# A fresh boundary owns its first binding

Baseline remains unmodified next `4fe75321`. A fresh `Loading` containing a form
could reveal an empty, enabled input while the effect responsible for its value
and disabled state remained held. The effect reads `isPending(data)` and `data()`;
`data` is a memo newly created over a signal whose next value is held by an action.
Next keeps the fallback visible until that binding can initialize.

The old lane condition suppressed first-publication boundary notification whenever
the computation ran inside the held transaction. In the shared engine, a child
computation can enter that update without its creator entering it. Consequently,
that condition does not prove that the whole new subtree is held. The shared path
now lets the boundary inspect its actual creator using its existing check. A held
creator still gates its whole subtree; an independently mounted boundary catches
its unfinished first binding. No new fields, ordinary-read checks, or coordination
rules are introduced.

`layered-mount-frame.test.ts` covers memo placement inside/outside the boundary,
no pending read and both read orders, and independent versus same-action mounts.
All twelve cases pass in both implementations. A same-action mount can prepare
its hidden binding before attachment in next; the test checks that it remains
hidden, rather than requiring an offscreen sync effect to wait.

## Validation

The complete signals run has 5,118 passing results, 2,164 failures, and two skips:
three existing failures fixed, twelve new passes, and no regressions against
stage 116. Passed counts include expected-failure tests. The complete web run
has 1,582 passing results, 139 failures, and one skip: both existing guarded-form
JSX failures now pass, with no regressions. The mount matrix was also run after
refining its hidden-subtree assertion; all twelve pass against both runtimes.

Signals builds, mangling, pure checks and declarations pass. Standard size
measurements are unchanged from stage 116, including the ordinary core and
pending/latest scenarios. Existing caps still fail. No new performance claim.
Receipts are in `results/integration-stage117/` (`signals-trial.json` and
`web-trial.json` are the complete retained-runtime runs).

This closes this particular incomplete-mount defect. It does not establish
full scalar compatibility: the broader integration failures still need triage.
