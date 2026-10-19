# Candidate: synchronous promise of empty iterable publishes the iterable object

Status: reduced upstream bug candidate; no report filed and no workaround active.
The Bend port preserves the pinned TypeScript behavior. This does not block
iterator translation.

Minimal JSX playground, created at the user's request:
[empty-stream repro](https://s.olid.uk/id/2a9vZpFtSnWcRDbIppG0Rw).
It uses one memo in an ordinary component and displays `Value: [object Object]`
instead of `Value: undefined`. Returning the stream directly is a passing
one-line control. Source and browser evidence are in
[`repros/playground`](../../repros/playground/README.md); the share pins
`mizulu/solid2@d2ad8b28`, with Tailwind and SSR disabled.

A standalone public-package repro is now in
[`repros/solid-signals`](../../repros/solid-signals/README.md). It reproduces on
the **published npm** `@solidjs/signals@2.0.0-rc.15` as well as the exact next
source. That npm release's gitHead is 4937f0a2bfddd45a65738c189075aff577530073,
which differs from the next commit below despite the shared version string.
`empty-flatten.mjs` uses an immediately fulfilled thenable for `next()`, so the
standalone case does not depend on tolerance of bare async IteratorResults.
It asserts intended behavior and fails; direct/native controls pass. The project
installs independently and uses no Bend code or adapter.

Observed on Solid `next` d2ad8b288886a5c7171e6746ccc019ad1d08d8ab
(`@solidjs/signals` 2.0.0-rc.15), production full-index bundle. A read-only
`git ls-remote origin refs/heads/next` on 2026-10-18 also returned that commit,
so the pinned source was the current next head when checked.

## Minimal source-only program

```ts
import { createRoot, createMemo } from '@solidjs/signals';

const empty = {
  [Symbol.asyncIterator]() {
    return { next: () => ({ done: true, value: undefined }) };
  }
};
const immediately = value => ({
  then: onfulfilled => onfulfilled?.(value)
});

createRoot(() => {
  const read = createMemo(() => immediately(empty));
  console.log(read() === empty); // true; expected read() === undefined
});
```

The same result occurs if `next()` returns an immediate thenable containing
`{done:true}`. Bare IteratorResult is deliberately supported by the current
source's protocol-tolerance branch. The repro does not depend on Bend, the Bend
host adapter, private helper exports, source-function rewrites, boundaries or
loading seeds.

Run `node tests/upstream/flatten-empty.mjs --json` after building. Eighteen paired
controls cover three outer shapes (direct iterable, immediate thenable, native
promise), three next shapes (bare, immediate thenable, native promise), and empty
versus one-yield streams. After all scheduled microtasks:

| Outer result | Empty bare/immediate next | Empty native-promise next |
| --- | --- | --- |
| Direct iterable | undefined | undefined |
| Immediate thenable of iterable | iterable object | undefined |
| Native promise of iterable | undefined | undefined |

Every one-yield control returns 7. The done-result's `value:99` is not treated as a
yield in any control. These assertions intentionally pin the surprising baseline;
they must change only after reviewing an upstream correction.

## Source operation and likely cause

`core/async.ts:handleAsync` stores the immediate promise fulfillment in its outer
`syncValue` local (lines 732–733). It then calls `flattenIfIterable(syncValue)`
(lines 775 onward). `consumeIterator` sees immediate empty completion and returns
true, but never assigns a yield into `syncValue`. The shared tail clears loading
and returns that unchanged local (line 798): the iterable object from the promise
fulfillment. For a directly returned iterable the same local starts undefined;
for deferred empty completion the callback explicitly calls asyncWrite(undefined).

The port keeps this local alive when entering a live flattened consumption:
`core.afterThen -> consumeIterator(..., initialValue)` seeds StreamState.syncValue
with the fulfilled iterable object. Resetting it to undefined would be a behavioral
change and is deliberately not active.

## Intent and upstream history checks

- `packages/signals/tests/flatten-async-iterable.test.ts` has an explicit deferred
  empty-stream test, "settles undefined when the promise resolves to an empty
  stream" (line 234). Its live-posture tests cover a yield and a pending first
  step, but not immediate empty completion.
- [Issue #2868](https://github.com/solidjs/solid/issues/2868) and merged
  [PR #2870](https://github.com/solidjs/solid/pull/2870) establish empty completion
  settling undefined and distinguish it from a never-settling stream. They concern
  an earlier asynchronous-completion gap, not this immediate flattening case.
- GitHub issue/PR searches for empty + iterable, and issues for sync + iterable,
  found related historical reports; none of the returned titles described this
  exact object leak. This is a bounded search, not proof that no duplicate exists.

The implementation and explicit flattening contract strongly suggest an overlooked
empty live-flatten branch. Maintainer confirmation is still needed; this record
is a bug candidate, not a claim that every intended API contract has been settled.
No fix, source repin, external report or package publication has been performed.

## Tracking / retirement

Affected source unit: `core/async.ts:handleAsync`; affected Bend units:
`runtime/core.bend:afterThen/consumeIterator/afterIterator` and
`runtime/iterator-state.bend:newStream`.
Evidence: 18 source-only controls and the live/deferred flattening histories in
`tests/iterators.mjs`. No new semantic proof is claimed for these executions.
There is no semantic deviation, so tracking/deviations.json remains empty.
On an upstream change, review the exact local/branch change, port it, update the
baseline control to the corrected expectation, rerun all flatten/iterator/promise
checks and add the issue/fix link here. Keep this historical evidence.
