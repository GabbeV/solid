# [2.0 / next] Optimistic setter can consume another action’s guess without entangling its lifetime

### Describe the bug

An optimistic setter can read a guess owned by another action and use it to calculate a different property. The actions do not entangle, so the input guess can revert while the guess calculated from it remains visible.

Starting from `{ a: 0, b: 0 }`:

```tsx
const saveA = action(function* () {
  setState(draft => { draft.a = 1; });
  yield delay(1000);
});

const saveB = action(function* () {
  setState(draft => { draft.b = draft.a + 1; });
  yield delay(1000);
});

async function run() {
  saveA();
  await delay(500);
  saveB();
}
```

B reads A's optimistic `a = 1` and guesses `b = 2`. When A ends, the UI displays `{ a: 0, b: 2 }` while B is still open. If B writes `a = a + 1` instead, the overlapping write entangles the actions. The read dependency in `b = a + 1` does not.

This uses a flat object store, with no array, structural change, refresh, or async derivation.

### Your Example Website or App

https://s.olid.uk/id/8bc8f6d1-4897-4149-8c19-621db513e852

### Steps to Reproduce the Bug or Issue

1. Open the reproduction and click Run once.
2. A immediately guesses `a = 1`: the UI shows `a: 1, b: 0`.
3. At 500 ms, B reads that guess and writes `b = 2`: the UI shows `a: 1, b: 2`.
4. At 1000 ms, A ends: the UI shows `a: 0, b: 2`.
5. At 1500 ms, B ends: both values return to 0.

### Expected behavior

Consuming another action's active override to calculate a guess should preserve their consistency when either action ends.

My expected behavior without rebasing is to entangle both action updates: retain `{ a: 1, b: 2 }` after A's body finishes, then revert both when B finishes. A setter that simply writes `b = 2` without reading A's guess could remain independent.

This is about the lifetime of a guess calculated from another active guess, not asking for setter callbacks to become reactive memos or to rerun automatically. Is the current read/write distinction intentional?

### Platform

- Solid next: bcef1041cb50bf648da5641693b5ebdea1fc5dc2 (November 11 build)
- Browser: Chromium, Linux

### Additional context

#2899 and #2912 establish independent lifetimes for disjoint writes, and #4724 records ownership at the point of write. This case asks whether consuming another action's active override inside a setter should count as a dependency even when the written properties differ.

In a separate controlled check, an ordinary signal written inside A publishes when A ends while B remains open, confirming that the action updates themselves remain independent; this is not merely an action promise resolving before a held update commits.

Discovered while exploring [unified update propagation](https://github.com/GabbeV/solid/tree/experiment/unified-updates). The linked reproduction runs upstream next; the experiment currently behaves the same way.
