# Ordinary branch consistency and supported recovery fixtures

The user explicitly overruled #4663's stale-branch behavior. A committed
ordinary condition and its selected branch must agree. In #4661, when the
filter commits `closed`, count commits `-1` and Loading on shows its fallback.
`latest` around the list read does not permit retaining the old filter branch.
No runtime change was needed: the shared model already behaves this way.

The two scalar and two JSX expectations now require that result. JSX also
renders the ordinary filter itself. A new converse control adds an ordinary
async observer outside Loading: while that request holds the update, filter,
count and the on-triggered swap all retain the old page. Once it resolves,
closed/-1/loading publish together while the list request remains pending.
All nine scalar controls and three JSX cases pass.

## Other classified failures

- #4244's old try/catch fixture used an unsupported reactive-read error channel
  (D-42), halting the graph and contaminating later tests. Move the four existing
  public-API Error/Loading recovery regressions from unified-error-first-answer
  into the normal issue file, replacing the two unsupported catching cases.
  Retain the original ordinary error-boundary control and dispose its root.
  Pending/latest still cover rejection before/after a successful value, retained
  error during recovery, final recovery and no fabricated undefined. This
  removes a duplicate experiment-only fixture, not its coverage. Five tests
  in the normal issue file pass on the experiment and pinned next 4fe75321.
- #4504's prior-observer case required an async intermediate optimistic result
  to publish after the input update could complete. Apply the accepted stage
  127 rule: unfinished optimism does not determine its own lifetime. The exact
  sequence is now 20 -> 40 (or 2 -> 4). Two added controls keep an independent
  action open and require the intermediate 30 (or 3) before the correction.
  All 23 cases pass; no request-count assertion was removed.
- #4428 asserted an internal fallback holder flag in addition to its actual
  mount timeline. The shared model may inherit that holder while still
  revealing correctly. Retain the empty-before-release and exact `1:F`
  publication assertions, then add an ordinary replacement to `2:F` and
  exactly-once cleanup at replacement/disposal. Both cases pass on the
  experiment and next. The negative control where the fallback itself reads
  a held value is unchanged.

These are semantic/test-representation migrations, not runtime repairs. The
two unsupported catching tests were replaced by four previously existing
supported observation controls. Their first-load intent and no-undefined
assertions remain covered; no consistency assertion was relaxed to accept a
mixed published frame.

## Validation

- Full signals: **5,329 passed, 2,090 failed, two skipped**, no new failures.
  Seven old failed cases are repaired or replaced as described above. Four
  previously unified-named tests now live in the normal issue fixture.
- Focused error/diagnostic/branch run: 32 passed. All 23 midflight cases and
  both fallback cases pass. Seven compatible recovery/fallback controls pass
  against pinned next. Three updated/added JSX cases pass against the built
  retained runtime.
- Rules index, targeted formatting and diff checks pass. No runtime source
  changed; no additional build, performance or size claim. No full web or
  hydration rerun in this stage.

The refreshed signals inventory has 1,953 deferred API failures, 112 untriaged,
12 calculation expectations, nine accepted lifetime differences awaiting
fixture migration, and four known implementation bugs. The stage-143 semantic
question is settled. Broader cleanup remains after scalar triage and before
optimistic-store expansion. Reports and comparison sources are archived in
integration-stage144.tar.xz.
