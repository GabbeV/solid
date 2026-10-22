# Standalone Solid 2 bug repros

Both programs import **only the public `@solidjs/signals` API**. They run without
the Bend repository, runtime, adapter, proof checker or test harness. Copy this
directory anywhere and use Node >=22.12.0, npm and Git.

## Published npm package

```sh
npm ci
npm test
npm run repro:empty
```

`repro:empty` intentionally fails an assertion of the expected behavior: an
immediately fulfilled thenable of an immediately empty async iterable produces
the iterable object, where `undefined` is expected. Direct-iterable and
native-Promise controls pass:

```sh
node empty-flatten.mjs direct
node empty-flatten.mjs native
```

## Current next source

The published rc.15 has npm `gitHead`
`4937f0a2bfddd45a65738c189075aff577530073`. The current next source still declares
rc.15, but is **a different commit**:
`d2ad8b288886a5c7171e6746ccc019ad1d08d8ab` (remote head checked 2026-10-19 UTC).
The held-error proposal code needed by the second repro is newer than that npm
release. The published package halts on the original error 99 before reaching
recovery; that is not evidence of the successful-value-as-error bug.

To reproduce both bugs at the exact next commit:

```sh
npm run use:next
npm test
npm run repro:recovery
```

`use:next` downloads the pinned public Solid source, checks the commit and clean
source, bundles the unchanged full signals index with production flags, then
locally installs it as `@solidjs/signals`. It adds no private exports and changes
no source functions. It does not use this repository's build tools. To use an
existing clean Solid checkout at that commit instead:

```sh
npm run use:next -- /absolute/path/to/solid
```

The recovery program uses a real native Promise. Its Node `unhandledRejection`
listener merely logs the failure of Solid's Promise continuation; the Promise
and its handlers are not replaced. An independent console report from Solid is
also visible: `[REACTIVITY_HALTED] 1` (or 7).

| Command | Expected | Observed on pinned next |
| --- | --- | --- |
| `node empty-flatten.mjs` | `undefined` | Empty iterable object |
| `node empty-flatten.mjs direct` | `undefined` | `undefined` |
| `node empty-flatten.mjs native` | `undefined` | `undefined` |
| `node held-error-recovery.mjs` | Renders `[2,3]`, read returns 3 | Renders `[2]`, read throws cause 1 |
| `node held-error-recovery.mjs changed-recovery` | Renders `[2,9]`, read returns 9 | Renders `[2]`, read throws cause 7 |
| `node held-error-recovery.mjs no-error` | Renders `[2,3]`, read returns 3 | Same; control passes |

Each bug command exits 1 because it asserts the intended behavior. `npm test`
runs the programs in separate processes and checks that the specific failures
reproduce and controls pass. It therefore exits 0 when this baseline is confirmed;
it does not claim that Solid satisfies the intended assertions. On the published
package it skips the two recovery failures and explicitly says why.

`npm ci` restores the published package after `use:next`. The lockfile always
pins published dependencies, and generated source/bundles are ignored. An
upstream correction should make the corresponding standalone assertion pass
and the baseline-verification assertion fail, prompting review.

No report has been filed. Observed results and version checks are in
`verification.log`.

## Generic deferred iterator refetch (#4232)

Run `node deferred-sync-iterator.mjs /path/to/source-built/signals.js`.
The bare-result deferred case throws `p.then is not a function`. The ordinary
memo and async-generator controls return 1. This reduction does not use from.
The default entry is the parent project's pinned production bundle. Pass
`--expect-fixed` only when selecting a separately built candidate/fixed version.
