# Minimal JSX repros for Solid 2

These follow the style of the user's recent Solid reports:
[#4110](https://github.com/solidjs/solid/issues/4110),
[#4109](https://github.com/solidjs/solid/issues/4109), and
[#3928](https://github.com/solidjs/solid/issues/3928). Each example is a plain
component with ordinary JSX output and only the primitives needed by the bug.
The examples stay abstract: there is no convincing application scenario that
would make either protocol/held-error failure clearer with fewer moving parts.

## Empty stream

[Open the playground](https://s.olid.uk/id/2a9vZpFtSnWcRDbIppG0Rw).
Source: [empty-stream.tsx](empty-stream.tsx).

The component needs one memo. On Build, it displays
`Value: [object Object]`; it should display `Value: undefined`.

The synchronous thenables are essential to this particular failure. They model
already available results without adding scheduling; replacing them with native
Promises removes the bug. The empty stream's `next()` also returns a thenable,
so the example does not rely on accepting bare async iterator results.

Simple control: change `createMemo(() => immediately(empty))` to
`createMemo(() => empty)`. Rebuild: the paragraph shows `Value: undefined`.

## Recovery while an update is held

[Open the playground](https://s.olid.uk/id/df_wYAiPRlmgfLmezgxTag).
Source: [held-recovery.tsx](held-recovery.tsx).

1. Build. The paragraph shows `Sum: 2`.
2. Click **1. Start update**. `slow` becomes pending and `value` fails. The old
   rendered result remains visible while the update is held.
3. Click **2. Recover**. `value` successfully returns 1 while the request is
   still pending.
4. Click **3. Finish request**. The native Promise resolves to 2.

Expected: `Sum: 3`. Actual: `Sum: 2` remains; Solid reports
`[REACTIVITY_HALTED]` and throws **1**, the successful recovery value, as an error.
Reload or Build to repeat, clicking each button once in order.

This reduction needs one signal and two memos. JSX supplies the combined render
read. Three manual clicks replace the original harness's explicit flushes;
there are no timers, explicit effects, custom Promise wrappers or error observers
inside the example.

Simple control: remove `if (step() === 1) throw new Error("boom");` and rebuild.
The same three clicks produce `Sum: 3` without errors. Another control changes
the final `return 1` to `return step() === 2 ? 7 : 1`: the recovered value 7 is
thrown instead, and the old sum remains 2 instead of becoming 9.

## Verification

Local verification uses the unchanged runtime and JSX compiler at Solid next
`d2ad8b288886a5c7171e6746ccc019ad1d08d8ab`. Six cases in each of development and
production run with compiled JSX and connected Chromium DOM: both failures,
direct/native empty-stream controls, different-value recovery and no-error
recovery. [verification.json](verification.json) records the twelve observations.
These checks preserve the source failures; they do not establish desired behavior
or formal TypeScript/Bend equivalence.

Both public shares pin the same commit through `mizulu/solid2@d2ad8b28`, with
source and a saved build. [hosted.json](hosted.json) records the URLs and initial
hosted observations. [hosted-verification.json](hosted-verification.json) records
fresh-session reloads, source/import-map checks and passing controls edited only
in the local browser copies. `npm run test:hosted` repeats this read/execute check;
it does not create or overwrite shares. If the site filters the network, its
ordinary `/human-verification` Continue form restores access.

To run independently with Node >=22.12.0 and Git:

```sh
npm ci
npx playwright install chromium
npm test
```

`npm test` fetches the exact Solid commit, verifies clean source and compiles its
actual Babel plugin and runtime. The npm Babel plugin dependency supplies compiler
dependencies; it is not the compiler under test. No Bend source or adapter is
used. The test runner exits successfully when the specific baseline failures
reproduce and controls pass.

An existing clean checkout at that exact commit can avoid the fetch. An existing
Chromium executable can also be used:

```sh
CHROMIUM_PATH=/usr/bin/chromium npm test -- /absolute/path/to/solid
```

The TSX files use the playground's default `root` mount element. Tailwind and SSR
are disabled. Tests and generated build output are separate from the repro code.
No GitHub issue has been filed or edited by this work.

## Function returned by an updater during a hold

[Open the playground](https://s.olid.uk/id/eQKgYi1oQrazp_lcVSOgpA).
Source: [held-function.tsx](held-function.tsx).

Click **1. Start update**, then **2. Store callback** while the request is open.
Expected: the second button says `Returned: function`, and the replacement does
not run. Actual: `Returned: string`, and the console logs `Replacement invoked`.
The third button finishes the request. The component needs two signals (one a
writable derivation), one memo, and one combined JSX binding. It adds no explicit
effect, timer or private runtime access.

`CHROMIUM_PATH=/usr/bin/chromium node verify-held-function.mjs /path/to/solid`
compiles this component with the pinned source compiler and tests development /
production in a connected DOM. Removing the hold, or using an ordinary data signal
for the callback, passes. [held-function-verification.json](held-function-verification.json)
records all six cases. [held-function-hosted.json](held-function-hosted.json) records
the separately opened public share, source round-trip, saved pinned build and
three real button clicks. Its saved module was compiled locally with that same
pinned JSX compiler and imports the pinned runtime through its import map.

## Throwing reactive cleanup and unrelated lazy release

Source: [cleanup-throw.tsx](cleanup-throw.tsx). Unlike the historical repros
above, this targets unchanged Solid source at a2743fa2. Click **Run**: the pending
memo's `onCleanup` error is caught, then a separate lazy memo loses its last
observer. Its cleanup count is 0; replacing the throw with `return` produces 1.
The paragraph updates in both cases. This demonstrates current behavior, not
a guarantee that continuation after a cleanup throw is supported. The issue
leaves containment versus halt and implementation choices to upstream.

Run `node verify-cleanup-throw.cjs /path/to/solid-at-a2743fa2` after installing
this directory's dependencies. It verifies the clean runtime/compiler checkout,
compiles the actual source and tests both cases in development and production
in connected Chromium DOM. [cleanup-throw-verification.json](cleanup-throw-verification.json)
records all four observations. No source patches or private exports are used.

There is no verified hosted share for this repro. The CDN lacks a complete build
at the tested commit; attempted custom-import-map shares selected the older
runtime and produced 1, so they were rejected as reproduction evidence. The
[issue draft](../../tracking/upstream/deferred-release-throw-issue.md) includes
the locally verified component directly.
