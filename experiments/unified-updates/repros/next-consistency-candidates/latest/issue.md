# [2.0 / next] A memo over latest() publishes ahead of an ordinary memo consuming its output

### Describe the bug

A memo containing `latest(id)` displays its new value while an ordinary memo consuming that same output retains the old value.

```tsx
const [id, setId] = createSignal(1);
const [filter, setFilter] = createSignal(0);
const proposed = createMemo(() => latest(id));
const pair = createMemo(() => `${proposed()} / ${filter()}`);

const run = action(function* () {
  setId(2);
  setFilter(1);
  yield never;
});

// Separate ordinary bindings:
<p>{proposed()}</p>
<p>{pair()}</p>
```

After Run, the screen remains:

```text
Committed ID:       1
Committed filter:   0
Memo of latest ID:   2
The same memo/filter: 1 / 0
```

`latest(id)` showing 2 while `id()` still shows 1 is expected. The problem is that the two ordinary consumers of `proposed` disagree about its published value. The second consumer does not use any explicit deferral boundary.

### Your Example Website or App

https://s.olid.uk/id/TGWeOejGTtm1iey2r2WBtg

### Steps to Reproduce the Bug or Issue

1. Open the linked repro and click Run once.
2. Observe Memo of latest ID: 2 beside The same memo / filter: 1 / 0.
3. The action deliberately stays open, leaving this state visible.

### Expected behavior

Publication should remain consistent downstream of the explicit latest boundary. If the combined reader must wait for the filter update, the memo output it consumes should not independently publish a different version. Alternatively, if that reader can calculate using the committed filter, it could show 2 / 0. Either way, the ordinary consumers should agree about proposed().

### Platform

- Solid: `next` at `bcef1041cb50bf648da5641693b5ebdea1fc5dc2`, development build
- Browser: Chromium 154.0.8037.57
- OS: Debian GNU/Linux 13

### Additional context

A separate signals-level probe replacing `proposed()` in `pair` with an inline `latest(id)` shows `2 / 0` during the same hold. The hosted repro isolates the memo-output disagreement.

Related: #4284 addressed JSX grouping around an explicit latest read. Here the disagreeing reads are ordinary reads downstream of a memo containing latest.

Discovered while exploring [unified ordinary and optimistic update propagation](https://github.com/GabbeV/solid/tree/experiment/unified-updates). The repro uses unmodified `next`.
