# Deferred iterator protocol errors can retain an obsolete flight

Confirmed against unchanged next@b9b6f333 (rc.17), production/development/observe.
No issue or PR has been filed and no candidate fix or workaround is installed.

After a deferred value has produced a real answer, returning an iterable whose
first next() throws synchronously records the error but leaves isPending true.
Both until and refresh remain pending. Making only next() async changes the
throw into a rejected promise and is a passing control: pending becomes false
and the original error is delivered. Plain memo, function-body throw and throws
after a first bare yield are further passing controls.

The source wrapper calls ask(s), then `p = it.next(v)`. A throw exits before
first=false and the done observer. The function-body catch has already exited,
so merged #4231's land(flight) does not run. The obsolete marked flight remains.
A related factory-throw case occurs before ask(s): if an old unresolved flight
exists, its settlement is still needed before the new protocol error is delivered.
A factory throw without an old flight is a passing control.

`repros/playground/deferred-protocol-error.tsx` is a real component with one Run
button starting the sequence. It uses async/await and a delay helper, logs only
to the console, and does not call flush. The actual JSX and its one-keyword
control pass browser checks in all three unchanged source-built tiers. The
standalone repro `repros/solid-signals/deferred-protocol-error.mjs` checks 120
cases across three tiers, with both until/refresh and old-flight controls.
The translation's stream suite preserves the same bad outcomes rather than
claiming an intended guarantee. Raw thrown payloads are compared by identity.

At investigation time next still pointed at b9b6f333. Open deferred/iterator
error searches found no matching report or fix; open deferred PRs #4128/#4220
did not cover these paths. Related merged work: #4231 repairs synchronous throws
inside fn, #4232 repairs bare first iterator results, and #4112 concerns deferred
protocol behavior. This report concerns the later protocol call boundary.
A maintainer may choose error routing or retirement beyond the minimal symptom;
no particular implementation is claimed here.
