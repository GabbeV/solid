# [2.0 / next] An ordinary store setter throws NotReadyError on a blind nested write through a pending store

### Describe the bug

An ordinary `createStore` setter throws `NotReadyError` when assigning a nested field through another store that has not received its first answer. The outer derive returns synchronously; reading the child reference in the setter succeeds. The blind assignment fails:

```ts
const first = Promise.withResolvers<{ x: number }>();
const [inner] = createStore(() => first.promise, { x: 0 });
const [outer, setOuter] = createStore(
  () => ({ child: inner }), { child: { x: 0 } }
);

try {
  setOuter(draft => {
    const child = draft.child; // succeeds
    child.x = 9;             // throws NotReadyError
  });
} catch (error) {
  console.log(error.constructor.name); // NotReadyError
}

first.resolve({ x: 2 });
```

The view stays loading until the first answer, then displays `2`. Neither the seed nor `9` is displayed. This uses ordinary stores and a direct setter, with no action or optimistic state.

### Your Example Website or App

https://s.olid.uk/id/6dfe2fc6-e78f-4c39-b13e-caa29592f82f

### Steps to reproduce

1. Open the playground and click **Run reproduction** once.
2. Observe `draft.child returned: true; setter failed: NotReadyError`.
3. After 500 ms, the child resolves to `{ x: 2 }` and the loading view displays `2`.

### Expected behavior

The setter's write path should permit the assignment using its defined write base, consistently with the seed-visibility rule, or document a restriction for nested writes through a pending foreign store.

The ruling on [#3274](https://github.com/solidjs/solid/issues/3274#issuecomment-6188894000) says:

> A function-form setter called before the first value runs immediately against the raw base: `prev` is `undefined` for a signal or optimistic computed, and the draft is the seed (or the `{}` base for a seedless store).

and:

> **Throw:** contradicts that rule. Absolute writes were never gated, and the function form shouldn't be gated either.

[A25 on the tested revision](https://github.com/solidjs/solid/blob/dfb18120a/packages/signals/docs/SPEC-ASYNC-SEMANTICS.md#a25-a-derived-stores-seed-is-a-draft-never-an-observable-value) records the write-path exemption. The newer [#4656](https://github.com/solidjs/solid/pull/4656) restriction concerns **optimistic** writes before loading; this reproduction uses ordinary `createStore` setters.

### Platform

- Solid `next` at `dfb18120a` (package version `2.0.0-rc.21`).
- Reproduced in Chromium on Linux with an embedded development build of unmodified next at that commit.

### Additional context

The same boundary was originally found with two `createOptimisticStore` instances and a setter inside an action: the child reference returns, but the nested assignment rejects the action with `NotReadyError`. That parallel case also reproduces on older `next` at `bcef1041c`. On current `next`, whole-child replacement before the first answer and nested mutation after the first answer work in that optimistic comparison. This report uses ordinary stores to keep the newer optimistic-before-load restriction out of the primary reproduction.

The rejection keeps the seed hidden. This report concerns the setter's write path and does not suggest exposing seeds to ordinary reads.

Discovered while exploring [unified update propagation](https://github.com/GabbeV/solid/tree/experiment/unified-updates); the reproduction runs upstream next.
