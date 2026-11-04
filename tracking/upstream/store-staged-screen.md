# Untracked staged-store read after latest crashes

Status: reproduced on unchanged current next/rc.21, not filed. No candidate
patch, upstream branch or Bend workaround is active.

The [one-button component](../../repros/playground/store-staged-screen.tsx)
starts with an answered memo. Its button starts an async update and changes a
store in the same event. One expression reads `latest(data)` and then
`untrack(() => state.count)`. It throws
`TypeError: Cannot read properties of undefined (reading '_x')`, reports
REACTIVITY_HALTED and leaves `0 / 0` on screen. Removing only `untrack` passes
and eventually displays `1 / 1`. No manual flush or protocol object is needed.

The exact component and tracked control were tested against clean source-built
production, development and observe runtimes in Chromium 154. All three original
cases crash; all three controls pass. This is a source-only finding: stores and
their node-less staging paths are outside the translated Bend grammar.

## Mechanism and regression boundary

`store/store.ts:readSource` explicitly handles node-less staging (`k === null`).
For a verdict reader it calls `stagedScreen(c)` without a signal argument.
`core/core.ts:stagedScreen` accepts that optional argument, but its new
`holdStagingHook!(c, el!)` call forwards undefined. `core/verdict.ts:holdStaging`
immediately evaluates `el._x?._askedIn`, before any posture guard. A non-null flush
and a reader not born into it reach the dereference.

This starts at merged [#4625](https://github.com/solidjs/solid/pull/4625), commit
`343f007fa7e810feffbcb737b17d58dcb16d7e9d`, the inherited-posture fix for #4544.
The same public-API program passes on its direct parent
`b2442611c32496aa9d72c4f1ea16815033e48be8` and crashes on that commit and
`2105ffb8ca2fced55f5fac0763177fc93f97c2c2`. Only ordinary production build flags
are substituted; no source functions or hooks are rewritten.

## Reproduction and controls

After `npm run build` in this repository:

```sh
node repros/solid-signals/store-staged-screen.mjs --expect-crash
```

This asserts the known source failure rather than crediting it as correct
behavior. For a separately built pre-#4625 full-index module, pass its path in
SOLID_REFERENCE and omit `--expect-crash`. The three passing controls all rerun
their reader: track the store read, use `isPending` instead of `latest`, or keep
the producer synchronous. The same test runs on the direct parent, introducing
commit and current pin; see the [validation record](store-staged-screen-validation.json).

The browser check is:

```sh
cd repros/playground
npm ci --ignore-scripts
node verify-store-staged-screen.mjs /path/to/clean/solid-at-2105ffb8
```

## Related work and scope

Current next was fetched on 2026-11-04 and still equals 2105ffb8. All six open PRs
were checked; none addresses this path. Searches for stagedScreen, holdStaging,
the `_x` TypeError and store/latest/untrack found no matching report. #4426 is a
different born-into/wrong-value issue, not this missing-argument crash. #4625's
description covers inherited posture and AHEAD/liveness, with no note about this
optional store call.

The crash mechanism is clear. The correct store policy should still be reviewed
before choosing between guarding the optional call and supplying store metadata.
The pinned source is preserved. No proof relies on this excluded path succeeding,
and this finding does not require weakening any theorem or patching the reference.
