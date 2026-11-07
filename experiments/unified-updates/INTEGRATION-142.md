# Observation failure triage and next consolidation pass

No runtime change in this checkpoint. Twenty-four observation controls now pass.
Ten formerly failing expectations were migrated to the accepted stage-141 rule:
two latest-feedback timelines, six pending/latest context cases, and two async
completion cases. These are test migrations, not ten runtime bug fixes.

Pending controls now assert complete render and user-effect timelines through
`0/true` to the landed `5/false`, including a reader which first probes during
the hold. Latest controls assert its proposal beside committed ordinary reads,
then the final landed pair. Async controls assert request keys `[5, 0, 5]` and
published results `[0, 5]` rather than only replacing a run-count assertion.

Instrumented copies of the two #3884 shapes were run against the experiment and
pinned next 4fe75321. Next starts the replacement directly; the experiment first
completes a calculation over committed `/`, then prepares `/slow2`. The stale A
answer never replaces the current data. Neither probe adds a subscription, but
context selection is no longer inert under untrack. The unchanged assertions in
the retained tests still pin the other tracked/untracked/no-probe controls.

Diagnostic copies of latest-memo-inline-parity and verdict-memo-flight-no-reask
continued beyond their first failed assertions. Original assertions were not
softened. Twelve sync latest cases publish the correct sequence but calculate
three/four times per write instead of once. These remain an implementation
inefficiency, not a semantic waiver. Four mount cases expose a separate bug:
the runEffect hold guard delays synchronous initial render callbacks. The
published rule permits detached setup immediately; queued callbacks must wait.
That runtime correction is the next trial, with DOM attachment controls.

Per the user, finish scalar failure triage before the broader consolidation and
performance/size pass, then do that pass before optimistic-store expansion.
Look for obsolete pending/verdict context and replay bookkeeping made redundant
by shared optimistic coordination. Remove obvious dead code when encountered;
do not add a compatibility exception just to preserve an old expectation.

The focused run is 24/24 passing. The last complete suite remains stage 141's
5,306 passed / 2,113 failed / two skipped; no full suite was rerun for these test
migrations. No performance or size claim. Diagnostic sources, next/experiment
traces, and focused reports are in integration-stage142.tar.xz.
