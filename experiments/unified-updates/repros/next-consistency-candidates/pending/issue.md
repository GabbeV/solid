# [2.0 / next] Wrapping isPending() in a memo changes the result of an otherwise identical async derivation

### Describe the bug

Two async presentations of `isPending(id)` disagree during the same held update. The only difference in their calculations is whether the pending read is wrapped in a synchronous memo.

```ts
const pending = createMemo(() => isPending(id));
const direct = createMemo(async () => {
  const value = isPending(id);
  await delay(500);
  return String(value);
});
const wrapped = createMemo(async () => {
  const value = pending();
  await delay(500);
  return String(value);
});
```

Both memos have already returned promises and finished their initial work before Run. The button starts an action that sets `id` from 0 to 1 and stays open.

After their 500 ms work has completed, the screen remains:

```text
Committed ID:             0
Pending:                  true
Async direct read:        false
Async memo-wrapped read:  true
```

There is no untrack in either calculation. Both capture their pending input synchronously before awaiting. Loading is used for their initial load, with no `on` reset or explicit deferral on the update.

### Your Example Website or App

https://s.olid.uk/id/qQD8AdR-Q3SrhaZVOyl0gA

### Steps to Reproduce the Bug or Issue

1. Open the linked repro and wait for initialization to finish.
2. Click Run once.
3. Wait at least 500 ms.
4. Observe Pending: true and Async memo-wrapped read: true beside Async direct read: false.
5. The action deliberately stays open, so waiting longer does not make the two presentations agree.

### Expected behavior

Extracting the same tracked pending read into a synchronous memo should preserve the behavior of an otherwise identical async derivation. If this difference is intentional, could you clarify the public contract: why does the wrapper change which pending state the async calculation consumes, and which form should authors use for an async presentation of pending state?

### Platform

- Solid: `next` at `bcef1041cb50bf648da5641693b5ebdea1fc5dc2`, development build
- Browser: Chromium 154.0.8037.57
- OS: Debian GNU/Linux 13

### Additional context

Related to #4677 and the follow-up work in #4717. The upstream [producer-clause description](https://github.com/solidjs/solid/blob/bcef1041cb50bf648da5641693b5ebdea1fc5dc2/documentation/plans/optimism-seam-spike-brief.md#L514-L525) explicitly treats a previously async memo's direct isPending read as part of the held update and answers false there. This report asks about the observable composition consequence: placing the same read in a memo yields true instead. I am not assuming that the direct-reader rule itself was accidental.

Discovered while exploring [unified ordinary and optimistic update propagation](https://github.com/GabbeV/solid/tree/experiment/unified-updates). The repro uses unmodified `next`.
