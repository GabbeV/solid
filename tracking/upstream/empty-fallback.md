# Successful falsy empty fallbacks are recreated

Originally reproduced in native Solid at unchanged next
0222d684365f08a29dfc1d613e664659f06948c8 (rc.16), 2026-10-21.
The user submitted fix PR [#4211](https://github.com/solidjs/solid/pull/4211).
The repeat helper and typed array payloads now execute and preserve the pinned
bug in paired comparisons; mapArray remains unported. No workaround or
semantic deviation is active.

[Open the saved playground](https://s.olid.uk/id/bC1rrXxASu6tFv0nkDPdcg), pinned
to released rc.16. Saved source and lifecycle output were checked after reloading.

## Minimal application

[JSX component](../../repros/playground/empty-fallback.tsx) uses one rows signal,
`<For>` and an `Empty` component that registers `onCleanup`, logs its lifecycle
and returns the valid rendered value 0. Click **Reload empty rows**: the list
stays empty, but the console adds `Empty cleaned`, then `Empty mounted` again.
Each further empty reload repeats this teardown/recreation. Changing only
`return 0` to `return 1` preserves the existing component across those reloads.
The same behavior occurs with `<Repeat count={rows().length}>`.

A new empty array is a normal changed list input. There is no equals:false,
manual effect, explicit flush, timer, thenable or thrown error in the component.
The fallback result retains its array identity; the visible 0 stays 0. The bug
is an unnecessary component/owner lifecycle reset, not a memory leak: final
root disposal balances every owner created.

## Mechanism and related history

map.ts's updateKeyedMap and updateRepeat both use
`this._fallback && !this._mappings[0]` to detect a fallback that has not completed.
A successful result of 0, false, null, undefined or empty string is falsy too.
The helper disposes its existing fallback owner and invokes the fallback again.
A truthy result skips this branch and retains that owner.

[#2903](https://github.com/solidjs/solid/issues/2903) and
[Ryan's fix explanation](https://github.com/solidjs/solid/issues/2903#issuecomment-5006772768)
establish the staged-commit and aborted-fallback retry policy. That report
concerns throwing/pending mappers, not this successful falsy return. Current
mapArray-notready-safety.test.ts includes fallback-abort owner-balance cases for
both helpers; those tests pass in the full upstream suite. Searches of the user's
fallback reports and repository mapArray/falsy-fallback reports found no duplicate.
The file is unchanged by the latest nine-commit pin update; this is not a claim
that one of the recently merged fixes introduced it.

The separate upstream PR changes both guards to `!this._mappings.length`.
A successful RHS creates slot zero even for undefined; a thrown or suspended
RHS leaves the array empty. The existing failed-attempt cleanup/retry order is
retained without adding state or allocating another object. The pinned reference
and Bend runtime are unchanged.

The PR is committed as ce9572c0 on GabbeV:fix/falsy-empty-fallback, based on
next@a2a5b6f8. Twelve new falsy cases fail before the fix and four truthy controls
pass; all sixteen pass afterward. Together with the existing fallback-abort
regressions, 28 focused tests pass in development, production and observe.
Signals builds/declarations, the full 333-file / 5,455-passing-test suite,
format/release checks and twelve real JSX browser cases pass. The standard size
scenarios are unchanged; focused imports add four minified bytes per helper.
Local production timings showed no clear slowdown (noisy microbenchmarks).
This is validation of the separate candidate, not a baseline repin or a Bend
proof of an unimplemented API.

## Evidence

- `tests/upstream/empty-fallback.mjs`: 14 native source controls across both
  helpers, five falsy results and two truthy controls, using ordinary fresh empty
  array updates. Default mode asserts the reproduced behavior; --expect-fixed
  asserts retention for all values. It is source-only, not a paired Bend history.
- `repros/playground/verify-empty-fallback.cjs`: unchanged source compiler and
  runtime in Chromium 154, production/development/observe, For/Repeat and 0/1
  returns: twelve passing repro/control cases. Every zero case creates twice
  and cleans once after the first click, then creates three times and cleans
  twice after the second. Every one-valued control stays at one creation and
  zero cleanups. No page errors occur.
- `repros/playground/empty-fallback-verification.json` retains the exact browser
  results and source pin. The hosted share uses released rc.16; local source
  verification is against 0222d684. Hosted evidence is recorded separately.

The source snapshots stay unchanged. There is no Bend law for this unimplemented
API, and none of the existing 68 positive closed regressions changes classification.
