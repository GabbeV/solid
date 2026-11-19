# Pending lifetime ruling and publication regressions

The user accepted the stage-126 recommendation: optimistic derivations must
not define the lifetime of their own optimism. This pass retains test changes
for that ruling and a repair to a synthetic renderer in an existing mount
test. It retains **no runtime changes** beyond stage 125.

## Pending badge retirement

The four #4677 scalar tests now select requests by the values they calculate,
instead of assuming next's request order. Both completion orders run with a
direct details binding and with an intervening memo. They assert complete
frames and each binding's callback history:

- Details first: retain `0 / Item 0 / false / 0:false`, immediately request
  the correction, then publish `1 / Item 1 / false / 1:false` when it answers.
  The pending-true request remains unresolved through this commit.
- Pending badge first: publish `0 / Item 0 / true / 0:true`; retain that
  frame while correction is pending; then publish the same final frame.
- Late superseded answers leave every binding unchanged.

Two new JSX tests exercise those timelines with independent bindings and a
normal navigation button. They preserve #4677's no-tearing requirement.
Requiring the obsolete pending frame to finish is deliberately removed.
This is an intentional semantic difference from next, not a runtime repair.
The extra superseded initial badge request recorded in stage 126 remains an
optimization concern; these tests neither assert request-count parity nor
resolve that request to help the update finish.

## Mount test: artificial callback conflict

Both #4275 scalar tests failed because the outer and inner effect callbacks
wrote the same `slot`. Once a function child was mounted, the outer callback
still assigned `undefined`, overwriting the child's value if it ran later.
The JSX version passes on both the experiment and next `4fe75321` in both
read orders. The scalar emulation now leaves the mounted function child's
slot to that child, as insertion does. The existing whole-frame expectations
remain unchanged, and both corrected scalar tests also pass on next.
No callback-order guarantee was introduced.

## Rejected first-proposal trial

The two #4429 failures remain: latest of a synchronous memo created under an
open hold can join that hold instead of exposing its ready first proposal.
Removing the first-answer guard fixed those cases. Extending observation
preparation also let a latest output follow replacements before its input's
first publication, coherently holding its own async consequence.

The full suite exposed three regressions: an imperative latest read returned
a never-published optimistic value (also caught by the visibility oracle),
and #4355's derived-store memo reader briefly published `undefined` before
the actual first answer. Restricting the fallback to held proposals did not
fix these. Keeping only the preparation change still exposed the store seed
and did not fully repair #4429. Both runtime edits were restored from exact
stage-125 copies; the failing additional probe and trial files are archived.
These are implementation problems, not approved semantic changes. The trial
must not be mistaken for a retained repair or performance result.

Receipts are in `results/integration-stage127/`. The temporary comparison
configs are archived; none remain in package directories. JSX checks used
the installed rc.21 native compiler via `SOLID_COMPILER_NATIVE`, consistently
for the experiment and pinned next. No files in the next checkout were changed.

## Validation

The final full signals run records **5,189 passed, 2,125 failed, 2 skipped**,
with no new failures against the stage-125 full run. Thirteen previously
failing cases now pass: seven test migrations already retained in stage 125,
the four pending-lifetime migrations, and the two corrected mount tests.
The two #4429 failures and the rejected trial's regression cases retain their
stage-125 outcomes. The remaining scalar audit is incomplete; unsupported
optimistic stores and until still account for most failures.

The final focused web run passes all eleven tests: the four new JSX cases and
seven existing optimistic input/publication cases. Both JSX mount orders and
both corrected scalar mount cases also pass on pinned next. The full web suite
was not repeated for this test-only retained pass.

All three build tiers and both production purity checks pass after restoring
the runtime. Declaration generation passed during the trial; there are no
retained runtime or declaration changes. Exact file comparisons verify that
latest and observation were restored. Runtime is identical to stage 125, so
this pass adds no shipped code or allocation cost and makes no new performance
claim.
