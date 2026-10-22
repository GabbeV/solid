# A synchronous deferred error waits for an obsolete flight

Confirmed at unchanged next aece1d448b648d6e946d098f565445d30124b8c2.
[Open the saved JSX repro](https://s.olid.uk/id/l7LoIOhpS_mHSJwY8p2j8w), using
mizulu/solid2@aece1d44. The failure and passing control were checked again after
reopening the saved share. No issue or PR has been filed.

Click Start request, Fail next request, then Read settled result. The deferred
computation has already thrown `request failed`, but until(result) stays Waiting.
Click Finish old request: only now does the current error reject the waiter.
Control: skip Start request; Fail then Read rejects promptly. The component uses
an owned eager deferred, one input signal, one status signal and four buttons.
It needs no effect, boundary, explicit flush, timer or hand-written thenable.
The same defect affects refresh's truth waiter. It does not require from().

The wrapper retains its old flight while rerunning. Its source-function catch
updates the flight only for an open-window NotReadyError. A real synchronous
error is rethrown without ending the superseded flight or mark. watch explicitly
treats errors as answers, but its authoritative lagging check still finds that
old flight and suspends delivery. If the old request never settles, the current
error's waiter never settles either. The old request's eventual value is ignored;
its obsolete completion still controls delivery of the new error.

The normal promise-rejection path already runs land before the engine's error
callback. [The isolated candidate](deferred-superseded-error.patch) adds
`else land(flight)` to the source-function catch, retaining NotReady parking and
the original throw. land's null guard protects first-load/no-flight errors, and
stale callbacks remain harmless. The pinned source and Bend catch remain unchanged.
No active semantic workaround is installed. Constructor comparisons preserve
the baseline rather than silently applying the candidate.

Related design: [#4067](https://github.com/solidjs/solid/pull/4067) specifies deferred
error propagation and truth-reader waiting; [#4085](https://github.com/solidjs/solid/pull/4085)
implements D-41's error-as-an-answer policy. This differs from #4145's held
error-to-value recovery and the onCleanup policy questions: no cleanup throws
here. Targeted issue/PR searches found no duplicate or landed repair.

Four old-flight regressions fail before the candidate; four no-old-flight controls
pass. All eight pass with it, covering until/refresh, loading seeds and exact
original error identity. Both standalone modes pass. Real JSX baseline/control
and candidate/control pass across production, development and observe: twelve
browser cases. The candidate builds all tiers and declarations and passes
337 files /5,509 tests, with three expected failures and two skips.

Rolldown 1.2.11 adds four minified bytes to the focused deferred import; all four
standard scenarios remain unchanged. No caps changed and no timing claim is made.
The candidate is local only in /workspace/solid-deferred-throw-candidate.
See [the validation record](deferred-superseded-error-validation.json) for the full
size rows, repro paths and exact evidence boundary.
