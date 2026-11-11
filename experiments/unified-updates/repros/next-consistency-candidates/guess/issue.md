# [2.0 / next] A second optimistic guess leaks to an ordinary reader while its async consequence is held

### Describe the bug

Two ordinary readers of the same optimistic output disagree after an action makes a second guess.

The first guess, `1`, publishes successfully. The second guess, `2`, starts downstream async work that never resolves. While that work remains pending, an unrelated signal update reruns another JSX binding, which reads `2` even though the combined value/async-copy memo still displays `1 / 1`.

```tsx
const [view, guess] = createOptimistic(() => 0);
const [tick, setTick] = createSignal(0);
const derived = createMemo(() => view() === 2 ? never : view());
const pair = createMemo(() => `${view()} / ${derived()}`);

// The two JSX bindings:
<p>{pair()}</p>
<p>{`${view()} (tick ${tick()})`}</p>
```

The visible sequence is:

| Time after Run | Value / async copy | Other reader |
| --- | --- | --- |
| Initially | 0 / 0 | 0 (tick 0) |
| Immediately after guess(1) | 1 / 1 | 1 (tick 0) |
| 500 ms: guess(2), downstream suspends | 1 / 1 | 1 (tick 0) |
| 1000 ms: setTick(1) | 1 / 1 | **2 (tick 1)** |

The action stays open throughout. The tick update happens outside the action. There is no `latest`, `createDeferred`, or explicit loading boundary in this repro.

### Your Example Website or App

https://s.olid.uk/id/vV13_EpDRkmxDyr_SxCX5w

### Steps to Reproduce the Bug or Issue

1. Open the linked repro and click Run once.
2. Observe both readers showing 1 after the first guess.
3. After about one second, observe 1 / 1 beside 2 (tick 1).
4. The promises deliberately remain unresolved so the disagreement stays visible.

### Expected behavior

An unrelated rerun should not expose a newer version of the optimistic output than the version that has published with its ordinary consequences. While the second guess is held, both ordinary readers should retain the published value 1. The explicit optimistic boundary may differ from its input; this disagreement is between readers of its output.

### Platform

- Solid: `next` at `bcef1041cb50bf648da5641693b5ebdea1fc5dc2`, development build
- Browser: Chromium 154.0.8037.57
- OS: Debian GNU/Linux 13

### Additional context

Discovered while exploring [unified ordinary and optimistic update propagation](https://github.com/GabbeV/solid/tree/experiment/unified-updates). The repro uses unmodified `next`.
