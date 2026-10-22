# Deferred refetch rejects from's buffered first result

Confirmed against unchanged next aece1d448b648d6e946d098f565445d30124b8c2.
This is source-only evidence: public createDeferred and from are not yet admitted
by Bend. No semantic workaround is active and no issue or PR has been filed.

[The minimal component](../../repros/playground/deferred-buffered-from.tsx)
uses createSignal, createDeferred and the new from callback adapter. The callback
immediately publishes the selected source value. Initially the paragraph shows
Value: 0. Click Change source: expected Value: 1; actual Value: 0 and
`p.then is not a function` (normal JSX rendering then halts reactivity).
Replacing createDeferred with createMemo is a passing one-word API control.

The ordinary async consumer intentionally supports a bare first IteratorResult.
from buffers synchronous publications and its next() returns that result directly;
its own documentation and #4218 describe this fast path. After its first committed
answer, createDeferred wraps the iterable, then unconditionally calls p.then on
its first pull. A buffered result has no then method. This is a supported built-in
API composition, not a malformed hand-written iterator. Promise-returning streams
and the ordinary memo control pass. Loading-value and immediate-completion variants
also reproduce the failure.

[The isolated candidate patch](deferred-buffered-from.patch) checks isThenable(p)
on the wrapper's first pull, registers the existing done callback when asynchronous,
and calls done immediately otherwise. It preserves the original return result,
remaining pull behavior and first-yield/end flight lifetime. It reuses an existing
import and closure and does not allocate a Promise wrapper. The vendored reference
is unchanged. Candidate worktree: /workspace/solid-deferred-from-candidate.

Four focused regressions fail before the patch, four controls pass, and all eight
pass afterward. Each candidate builds all three tiers and source declarations;
the complete candidate suite passes 337 files /5,509 tests (three expected failures,
two skips). Real JSX baseline/control and candidate/control runs pass in production,
development and observe: twelve browser cases. The standalone Node script supports
both baseline assertions and an explicit --expect-fixed candidate mode.

Rolldown 1.2.11 focused imports add 10 minified /9 Brotli bytes for createDeferred
alone and 9 /1 bytes for createDeferred+from. All four standard scenarios remain
unchanged; no limits were raised. No timing claim is made.

[#4218](https://github.com/solidjs/solid/pull/4218) introduced from and its deliberate
bare-result optimization. [#4182](https://github.com/solidjs/solid/issues/4182) is the
original helper request by devagrawal09, not a report filed by GabbeV. Targeted
issue/PR searches found no duplicate or landed repair as of this review.
The native baseline full suite passes, demonstrating that its existing tests miss
this composition. See [the validation record](deferred-buffered-from-validation.json)
for exact size rows and browser evidence. Hosted sharing is still being investigated:
released rc.17 does not export from, so a link must retain the source-built runtime.
