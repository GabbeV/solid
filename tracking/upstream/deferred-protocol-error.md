# Deferred iterator protocol errors can retain an obsolete flight

Confirmed against unchanged next@b9b6f333 (rc.17), production/development/observe.
No issue or PR has been filed for this specific remaining case. A tested candidate
is pushed separately; it is not installed in the pinned reference or Bend runtime.

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


## Current next verification and separate candidate (2026-10-23)

Rechecked live GitHub reports and current `next@cc3ee740`. Your #4112, fixed by
#4158, covers protocol exceptions escaping ordinary memo error handling. Its seven
regression tests pass on this same source. The remaining `createDeferred` case
retains flight/lagging bookkeeping after a synchronous protocol error has reached
the memo. #4231 repairs the function-body catch, but protocol setup and initial
serving were outside that catch. Searches found no exact filed issue/PR.

Fresh builds of production/development/observe reproduce the 120-case native
matrix (six delayed/stuck cases per tier), plus the single-button JSX repro and
async-next control in Chromium: synchronous next leaves Pending:true, whereas
async next clears pending and delivers the original error. Signals sources are
identical between cc3ee740 and the current 225014bf translation pin.

The isolated candidate extends the existing computation try/catch through result
processing, including iterator factory and first pull. It preserves the established
NotReady parking rule; other throws end the flight and rethrow the original error.
It adds no wrapper, Promise allocation or catch block. This also fixes a factory
NotReady case that previously omitted the pending mark.

Candidate branch: `GabbeV:fix/deferred-protocol-flight`, commit
`58d3d52de9c02bff038e8a7ec30823a0e9a4f26b`, based on cc3ee740. It contains only
`src/deferred.ts`, a 26-case regression file and a patch changeset. On the unchanged
base 13 new cases fail and 13 controls pass; the candidate passes all 26 and 100
focused tests. All three builds, declarations, six JSX/browser cases, 120 native
cases and full signals suite pass (342 files /5,573 tests, two expected failures,
two skips). Prettier and release invariant checks pass. Pinned Rolldown 1.2.11:
the four standard signals scenarios are unchanged; focused createDeferred and
createDeferred+createSignal imports each shrink one minified byte (-15/-25 Brotli).
No timing/performance guarantee is claimed from these size results.

The branch is pushed for a prefilled PR form for the user to review and submit;
no PR number exists yet. The translation still preserves the baseline defect,
with no source repin or semantic deviation.
