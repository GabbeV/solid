# Deferred refresh answers and dormant observation revival

Baseline remains unmodified next `4fe75321`. This stage repairs two scalar
integration gaps without changing the agreed update or optimistic lifetimes.

## Refresh waits for deferred work

The shared refresh waiter read a deferred node's displayed old value, saw no
ordinary pending status, and resolved immediately. Next's waiter consults the
existing deferred-flight hook. Restoring that hook in our waiter makes it wait
for the answer; ordinary readers still receive the deferred value. This needs
no authoritative graph or implementation of `until`.

Seven existing tests change from failing to passing in the first focused run:
three deferred refresh cases and four deferred async-iterator protocol-error
cases. The other 28 failures in that run remain visible, primarily `until` and
separate deferred pending/publication behavior.

Additional public-API tests cover direct refresh and refresh through a memo,
supersession, equal answers, and observable publication. They found an equal
answer through an unchanged intermediate memo can strand the waiter. The same
test fails on unmodified next, so this is also an upstream repair opportunity,
separate from restoring the missing integration hook. The waiter now links
directly to the deferred node whose flight it waits on before throwing its
NotReady. This reuses ordinary pending-source settlement: no new collection,
node field, or ordinary read branch. All four additional cases pass.

`next-refresh-supersession.json` records the upstream comparison. The test was
copied temporarily into the baseline checkout and removed after running it.
No issue or PR was posted. `refresh-expanded-final.json` records 69 passing
tests across the expanded refresh/deferred checks.

## Observation revival discards abandoned proposals

An imperative `isPending(data)` during first load creates a lazy observation
output. After the answer, that output can be reclaimed before its first value
publishes because no reactive reader subscribes to it. Teardown marked it
uninitialized but retained its staged `false`. On revival, the equality check
compared against that abandoned proposal, suppressed the value write, and an
outside read received `undefined` from its never-published slot.

Dormant observation teardown now discards the staged proposal as well as the
selector. Revival calculates and initializes its own output normally. This is
shared by pending and latest outputs; no general outside-read exception is
restored. Four existing tests pass after this repair. The focused 143-test run
has no new failures (three pre-existing failures remain).

Two additional lifecycle tests cover direct and callback pending probes, first
publication, ten update cycles, imperative latest reads, exact rendered values,
and stable source subscriber counts after observation reclamation. Both pass.

Validation receipts are in `results/integration-stage115/`. The early
`signals-complete.json` run is a trial before the direct waiter subscription and
observation teardown repair; the retained full-suite receipt is `signals-final.json`.

## Complete checks

The final signals run has 5,100 passing results, 2,168 failures, and two skips:
11 existing failures fixed, all six new tests passing, and no previously passing
test lost relative to stage 114. Passed counts include expected-failure tests.
The complete web run has 1,579 passing results, 142 failures, and one skip.
Its only difference from stage 112's last complete web run is stage 114's new
passing DOM test. No existing assertions were weakened or marked expected-fail.

All signals tiers build; property mangling, pure checks, and declarations pass.
The standard size harness still measures the ordinary core at 21,153 minified /
7,904 Brotli bytes and ordinary-store imports at 45,222 / 15,513. Both are
unchanged. Pending/latest imports measure 34,458 / 12,383, versus unmodified
next's 33,615 / 12,239. Existing absolute caps still fail; they were not changed.
The until/refresh scenario is not a feature-parity comparison while until is
deferred. No runtime-performance claim is made by these fixes.
