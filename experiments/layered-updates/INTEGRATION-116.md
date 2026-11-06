# An input error supersedes unfinished downstream work

Baseline remains unmodified next `4fe75321`. The existing #4568 signals and JSX
tests exposed an integration bug: a rejection under a fresh Loading reached
Errored only after an obsolete downstream request answered when read through
`latest`. Next delivers the error without waiting for that obsolete work.

The pending-source settlement walk removed the rejected input from an async
dependent's pending sources, but skipped staged-error forwarding because the
dependent still carried its own pending request. That request was asked with
the old input. Its eventual answer unlocked the error, even though the new
input had already rejected.

The walk now forwards the error even when pending sources remain. A dependent
with a live request of its own re-derives through the ordinary cancellation
path. A settled derivation still carries the staged error without rerunning
its body or replacing owned children. The check uses existing request and
pending-source fields; no new state is added to nodes or updates.

This does not bypass optimistic boundaries. New tests at depths one and three
start an unfinished consequence of an override, reject the lower input, and
verify that the override shields that error while active. Ending its lifetime
publishes the correction error without awaiting the obsolete consequence. A
late answer does nothing; subsequent recovery publishes normally. The existing
owned-child/error publication cases also remain passing.

## Validation

The final signals run has 5,103 passing results, 2,167 failures, and two skips.
Compared with stage 115, one existing failure now passes and both new layered
tests pass; no previously passing test fails. Passed counts include upstream
expected-failure tests. The complete web run has 1,580 passing results, 141
failures, and one skip: the existing #4568 JSX regression now passes, with no
other status changes. Unresolved failures remain visible.

All signals tiers build; property mangling, pure checks, and declarations pass.
The standard size harness leaves ordinary core and ordinary-store scenarios
unchanged at 21,153 / 7,904 and 45,222 / 15,513 minified / Brotli bytes. The
pending/latest scenario is 34,483 / 12,384, compared with unmodified next's
33,615 / 12,239. Existing size caps still fail; none were changed. No fresh
runtime-performance claim is made. Receipts are in `results/integration-stage116/`.

## Reassessment before the next repair

These changes close missing integration paths rather than changing the layered
coordination model. That does not establish the model's full correctness.
In particular, fresh Loading mounts and initial observation outputs still need
an audit: the `isPending` guarded-form JSX case can attach an enabled input with
an empty value while its binding is held. That is a real publication gap.
Other mount tests expect next's hold where the experiment instead displays a
complete committed frame beneath `latest`; those are distinct semantic cases,
not evidence that an empty binding is acceptable. Review ownership of the whole
new frame before introducing another special condition.
