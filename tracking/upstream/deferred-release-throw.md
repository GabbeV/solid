# SOLID-DEFERRED-RELEASE-THROW-004

Classification: reproduced suspected upstream regression; not filed. Discovered
while validating the pin update, 2026-10-20 (Europe/Stockholm).

A cleanup throw during the pre-body teardown of an unfinished pass leaves graph's
module-global `deferredReleases` pointing at that pass's array. Catching the throw
and continuing does not repair the pointer. A later, unrelated lazy memo loses its
last observer but is queued into the abandoned array, so its cleanup never runs
while its own owner remains alive.

The observed problem is the subsequent unrelated release. Whether this error
should permit continuation, be routed to a boundary or halt reactivity is an open
policy question; the reproduction does not establish a supported recovery contract.

## Evidence

The actual full package index is bundled without rewriting Source. The reduced
public-API repro is [tests/upstream/deferred-release-throw.mjs](../../tests/upstream/deferred-release-throw.mjs).
It needs no private exports, adapter, DOM, action, timer or pending-read exception
interception. One unresolved promise makes the first pass unfinished. The unrelated
lazy value is synchronous.

| Source/build | First cleanup returns | First cleanup throws 99, caught by caller |
| --- | --- | --- |
| d2ad8b28, original production baseline | later cleanup 1 | later cleanup 1 |
| a9b9f9e4, direct parent of #4164, production | 1 | 1 |
| 71153bf0, production | 1 | **0** |
| 71153bf0, development / observe | 1 | **0** |
| 71153bf0 with only restoration in finally, local source experiment | 1 | 1 |

Node 24.19.0, esbuild 0.25.12, __TEST__=false. Tier flags match production,
development or observe as named. `git ls-remote` confirmed remote next was still
71153bf0 when checked. The committed validation record includes the raw rows.
The local fix experiment used an esbuild onLoad replacement in a separate bundle;
it is not in the vendored Source or active Bend runtime and has not had the full
upstream suite run against it. No performance or code-size claim is made.

The complete unmodified upstream suite passes despite this uncovered case. The
normal #4142 rebuilt-reader case is fixed and its new tests pass; this is a distinct
exception-path regression in the newly introduced collector.

## Source mechanism

#4164 / 6371b910 adds this pre-body segment in `core/core.ts:recompute`:

```ts
const prev = deferredReleases;
deferReleases((released = []));
disposeChildren(el);
deferReleases(prev);
```

A throw in disposeChildren skips restoration and also precedes this pass's body
try/finally. Subsequent graph.unlinkSubs calls append eligible last-reader nodes
to the abandoned array. No pass later iterates it. A local experiment changes only
the disposal/restoration pair to try/finally and makes both repro controls pass.
The pending pass can still abort exactly as it did; restoration does not require
swallowing the original error or completing the interrupted owner walk.

## Port and proof treatment

Bend preserves this behavior. `RestoreDeferredReleases` runs on successful prelude
return and is skipped on unwind, matching Source. Two complete public integration
histories compare returning/throwing controls. The concrete **negative** law
`throwing_teardown_leaks_release_collector` checks the caught 99, active collector,
queued unrelated node, missing cleanup, retained lazy node and restored ordinary
ambient fields. It does not prove desired cleanup behavior.

The mutation suite rejects an unregistered finally-restoration workaround. The
semantic deviation register is empty. A future upstream fix must change the
corresponding unwind rule, flip these regression expectations, and retire this
active counterexample at an audited repin.

## Related reports and search limits

Reviewed #4164's description/discussion and searched open/closed Solid issues for
`deferredReleases`, `cleanup throw` and `lazy memo release`. No exact duplicate was
found in the returned results. Related but different:

- #4142 / #4164: ordinary rebuilt-reader lifetime, the change introducing this collection.
- #4089: cleanup writes resurrecting a landed transaction; its partial-throw note
  concerns that landing, not a leaked global graph collector.
- #4111: comparator/pending handling and a lazy dependent's missed release.
- #2813: repeated throwing effect cleanup; this repro's later victim is unrelated.

These searches are evidence of the review performed, not proof that no duplicate
exists. [Prepared issue text](deferred-release-throw-issue.md); nothing was posted.

## Prepared upstream fix

A tested try/finally restoration experiment is committed as
035e9b2f34f9c160ac708676e242fd594056a509 and pushed to
GabbeV/solid:fix/restore-deferred-releases, based on current next a2743fa2.
It changes only the disposal/restoration pair, adds public-API returning/throwing
controls and a patch changeset. The throwing case fails before the fix; both
controls and the existing #4142 regressions pass afterward. Full signals base
and patched suites pass: 326/327 files, 5409/5411 passing tests, three expected
failures and two skips. Signals JS/declaration builds, Prettier and release
invariants pass.

[Size results](deferred-release-fix-size.json): +13 minified bytes in all four
signals scenarios. Every comparison gate passes; the store scenario warns about
brotli within the existing minified allowance. Caps are unchanged.
[Local performance samples](deferred-release-fix-benchmark.json): five warm-ups
and 11 alternating measured rounds per version for chains, diamonds and pending
frame rebuilds, with GC outside timed regions. Patched medians are within 3% of
the base with no apparent slowdown; noisy local microbenchmarks do not establish
application-performance equivalence.

GitHub accepted the branch push but denied createPullRequest with “Resource not
accessible by integration”. A complete prefilled comparison was opened for user
submission; no PR number exists yet. This candidate fix remains separate from
the pinned reference and active Bend behavior. The negative regression and empty
semantic-deviation register are unchanged.

## Issue replaces proposed PR: reactive cleanup error policy remains open

The user chose an issue rather than submitting the prepared PR. No PR was
created. The pushed candidate remains available as an experiment; it is not an
accepted fix or a requested upstream implementation. Its passing test asserts
continuation after the caught throw, which is not itself evidence that this is
Solid's intended error policy.

This repro throws from `onCleanup` registered inside a pending `createMemo`,
not from a cleanup returned by an effect callback. The throw currently bypasses
the computation body's error handler and does not call `haltReactivity`. Thus
current continuation plus collector corruption is observed, not prescribed.
A catch that routes to boundaries or halts may be the appropriate upstream fix.

Prior issue/ruling review:

- [#2496](https://github.com/solidjs/solid/issues/2496): directly reports throwing
  `onCleanup` breaking reactivity; Ryan said it was addressed in 2.0 and closed
  it as fixed. It does not explicitly settle this path's halt policy.
- [#2839 ruling](https://github.com/solidjs/solid/issues/2839#issuecomment-4897650632):
  reactive compute errors differ from imperative effect errors, whose unhandled
  throws use boundary-or-halt. Reactive cleanup is not explicitly classified.
- [#3601](https://github.com/solidjs/solid/issues/3601): detaching the disposal
  list prevents reentrancy and repeated throws, without defining this error's
  routing policy.
- [#4029](https://github.com/solidjs/solid/issues/4029): server abort contains
  cleanup throws and reports through `onError`, continuing outer teardown; it
  is a different context from client recomputation.

The replacement [issue draft](deferred-release-throw-issue.md) leaves both error
policy and implementation to Ryan. The active Bend pin, baseline-parity tests,
negative law and empty deviation register are unchanged.

The replacement draft includes the full JSX component in
`repros/playground/cleanup-throw.tsx`. Its portable browser verifier checks the
unchanged runtime and compiler at a2743fa2, in production and development. All
four cases reproduce 0 for the caught throw and 1 for the nonthrow control,
with no page exceptions or error reports. See
`repros/playground/cleanup-throw-verification.json`. No verified hosted share
exists: CDN artifacts were unavailable and custom-import-map attempts executed
the older runtime, so those attempts are not claimed as evidence.

## User-provided hosted repro verified

The user supplied https://s.olid.uk/id/Q4l9sDY2RriitepR-nQmfg. Its component
source matches `repros/playground/cleanup-throw.tsx` exactly. In Chromium the
saved share starts at Not run, then Run produces cleanup count 0. A local-only
edit replacing the throw with return and rebuilding gives 1. Reopening the
saved share restores the exact original source and gives 0 again. No page
exceptions or REACTIVITY_HALTED reports occurred; the site logged two unrelated
401 resource responses. No share was saved or overwritten by verification.

The loaded package label is `mizulu/solid2@5a4b2e85`, confirmed by actual CDN
requests. Its source-commit mapping to upstream a2743fa2 is not established;
the issue distinguishes that hosted build from the separate unchanged-source
a2743fa2 browser verification. The earlier unavailable hosted reproduction is
superseded by this verified user-provided share. The issue form is refreshed
with the link, with policy and implementation still left open.

## Finally PR selected for submission

The user chose to return to the finally restoration PR. The direct-parent
comparison establishes that #4164 introduced the unrelated lazy release failure:
the throwing cleanup already escaped without a halt on a9b9f9e4, where the later
cleanup ran once. Restoration in finally addresses this regression without
changing that error propagation policy. Broader cleanup error policy remains
a separate question and does not make the measured regression ambiguous.

The candidate remains 035e9b2f on fix/restore-deferred-releases, with all prior
build/test/size/performance evidence unchanged. Its refreshed prefilled PR
description includes the verified user-provided playground, distinguishes its
package label from local upstream source, and states the before/after regression.
The previously prepared issue is retained for history; it was not submitted.
No actual PR number exists yet; the filled comparison is for manual submission
because the integration previously denied createPullRequest.

## Submitted upstream PR

The user submitted [#4176](https://github.com/solidjs/solid/pull/4176),
fix(signals): restore deferred releases after cleanup throws. Its branch is
fix/restore-deferred-releases and its base is next; the PR is open. The submitted
PR is attached to this task. The pinned Source and active Bend implementation
continue to preserve the upstream collector leak until a reviewed upstream fix
is integrated or a separately registered deviation is authorized and used.
