# [2.0 / next] Optimistic array retains an expired guess when another action writes a different index

### Describe the bug

Two overlapping actions write different existing indices of a `createOptimisticStore([0, 0])`. When the first action ends, its guessed value remains until the other action ends. The equivalent object store `{ 0: 0, 1: 0 }` correctly reverts that property independently.

Neither action changes the array's keys or length. There is no refresh or async derivation.

The reproduction writes both stores from the same actions:

```tsx
const [array, setArray] = createOptimisticStore([0, 0]);
const [object, setObject] = createOptimisticStore({ 0: 0, 1: 0 });

const save = action(function* (index: 0 | 1) {
  setArray(draft => { draft[index] = index + 1; });
  setObject(draft => { draft[index] = index + 1; });
  yield delay(1000);
});

async function run() {
  save(1);
  await delay(500);
  save(0);
}
```

### Your Example Website or App

https://s.olid.uk/id/48181e7d-f0eb-4055-83a2-4c4ba66e3d5c

### Steps to Reproduce the Bug or Issue

1. Open the reproduction and click Run once.
2. Both stores show `0, 2`, then `1, 2` after 500 ms.
3. At 1000 ms, the first action ends: the object shows `1, 0`, but the array still shows `1, 2`.
4. At 1500 ms, the second action ends and both show `0, 0`.

### Expected behavior

The array should follow the same sequence as the object: `0, 0` → `0, 2` → `1, 2` → `1, 0` → `0, 0`.

An action that only writes index 0 should not retain another action's expired override on index 1.

### Platform

- Solid next: bcef1041cb50bf648da5641693b5ebdea1fc5dc2 (November 11 build)
- Browser: Chromium, Linux

### Additional context

The [point-of-write ruling recorded in #4724](https://github.com/solidjs/solid/issues/4724#issuecomment-6726820057), implemented by #4729, says that writes with unchanged keys and length belong to the changed indices, rather than the whole array. #2899 and #2912 also concern keeping disjoint override ownership independent.

This case exercises expiration of one guess while a disjoint guess remains active, rather than the refresh/error scenarios in #4724 and its follow-ups.

Discovered while exploring [unified update propagation](https://github.com/GabbeV/solid/tree/experiment/unified-updates); the reproduction runs upstream next.

Structural cases to preserve when fixing this: starting from `[]`, action B writes index 1, then action A writes index 0. If B ends first, removing its override must not reset length to 0 and erase A's still-active value. If those structural writes retire independently, the remaining array should be `[1]`; if they intentionally entangle, their updates should settle together. This report deliberately keeps keys and length unchanged and does not require structural writes to become independent.
