# Rebase onto next's #4677 repair

Baseline: `4fe75321`, fetched 2026-11-05. The three commits since the previous
`f6b6737b` baseline repair #4677's pending/async publication, suppress an
inapplicable shallow/raw store diagnostic, and retain a corrected optimistic
guess's action hold through its own refresh (#4690).

The experiment is rebased locally. `checkpoint/layered-pre-rebase-111` preserves
the preceding `d58db551` checkpoint. No changes were pushed or posted. The only
textual conflict was the generated rules index, resolved by regenerating it.

## Integration adjustment

The new legacy-lane code uses array operations on `_reruns`; these now accept
the experiment's nullable Set. This conversion is confined to legacy paths.

Store imports still evaluate the legacy lane module. Its old landing hook was
effectively inert without lanes; the new hook traversed shared transactions and
installed its separate publication-waiting policy. That broke 25 existing
ownership cases. The walk is now guarded by the existing `LEGACY_LANES` constant,
leaving shared layers responsible for their own coherent publication. Those 25
cases pass again. This guard does not port Ryan's lane repair into shared layers.

## New regression coverage

All 59 cases in the three changed upstream test files pass on unmodified
`4fe75321`. The experiment's focused run has 579 passing results and 36 failures
across 615 cases. Every overlapping case has the same result as stage 110.

The 36 new failures also reproduce against the saved pre-rebase experiment:

- Four #4677 cases: the sampled output remains the initial coherent frame,
  rather than making the progress the test expects. These are unresolved scalar
  failures, not accepted semantic changes. The assertions remain unchanged.
- Two #4690 cases: with two unobserved optimistic outputs owned by one action,
  the first override reverts while the second input's refresh remains pending.
  Upstream retains both until the refresh finishes. This lifetime difference
  still needs analysis against the selected observation rules.
- Thirty #4690 optimistic-store cases hit the existing explicit deferral.
  Thirteen other #4690 cases pass, including the scalar rendering variants.

The pre-rebase comparison runs the newly added tests on `d58db551` as well as
the previously passing ownership tests. Receipts are under
`results/integration-stage111/`: `upstream-new-tests.json`,
`pre-rebase-comparison.json`, and `focused-retained.json`. The earlier
`focused.json` records the rejected unguarded merge.

Signals builds, property mangling, pure checks, declaration compilation, and
the generated rules index check pass. The complete signals run has 5,057 passed
results, 2,197 failed results, and two skips (7,256 total). All 7,205 pre-existing
test results are unchanged; no cases disappeared. Passed results include
expected-failure tests and do not all represent passing correctness assertions.
`signals-complete.json` and `rebase-comparison.json` record this comparison.
The JSX stale-render publication regression also passes using the rc.21 native
compiler (`web-reveal.json`).

No performance or size claim is made in
this rebase pass. Upstream raised several lane bundle caps in its own change;
that does not establish that the experiment meets its acceptance constraints.
Historical measurements remain tied to their recorded baseline.

The previous first-answer/reask semantic question (#4459) remains unanswered.
This rebase does not choose a policy for it. Broader scalar gaps from stage 110,
optimistic stores, and `until` remain unfinished.
