Title: [2.0 / next] Throwing onCleanup escapes flush and suppresses unrelated lazy cleanup

### Describe the bug

An `onCleanup` inside a pending memo throws when the memo reruns. It escapes
`flush()`. After the caller catches it, scheduling continues without
`REACTIVITY_HALTED`, but disposing an unrelated lazy memo's last observer no
longer runs that memo's cleanup.

This is reactive-scope `onCleanup`, not an effect-returned cleanup. Is this
error supposed to be contained or halt reactivity? Currently work continues
with a leaked global release collector.

### Your Example Website or App

Self-contained JSX component below, verified against unchanged source-built
next@a2743fa2 in Chromium, in development and production.

### Steps to Reproduce the Bug or Issue

Run the component below against `a2743fa2` and click **Run**. The handler catches
and logs `cleanup failed`, then observes and releases a separate lazy memo.
The paragraph updates to **Cleanup count: 0**; its cleanup did not run.
Its own root remains alive.

```tsx
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup
} from "solid-js";
import { render } from "solid-js/web";

function App() {
  const [result, setResult] = createSignal("Not run");

  function run() {
    const [version, setVersion] = createSignal(0);
    createRoot(() => {
      createMemo(() => {
        version();
        onCleanup(() => {
          throw new Error("cleanup failed");
        });
        return new Promise(() => {});
      });
    });
    flush();
    setVersion(1);
    try {
      flush();
    } catch (error) {
      console.log("Caught:", error);
    }

    let cleaned = 0;
    let stop!: () => void;
    createRoot(() => {
      const value = createMemo(() => {
        onCleanup(() => cleaned++);
        return 1;
      }, { lazy: true });
      stop = createRoot(dispose => {
        createRenderEffect(value, () => {});
        return dispose;
      });
    });
    flush();
    stop();
    flush();
    setResult(`Cleanup count: ${cleaned}`);
  }

  return <>
    <button onClick={run}>Run</button>
    <p>{result()}</p>
  </>;
}

render(() => <App />, document.getElementById("root")!);
```

Control: replace `throw new Error("cleanup failed")` with `return`, rebuild,
and run: the count is **1**. Both controls were tested in development and
production. The corresponding standalone public-signals repro also prints 1
with the throw on `a9b9f9e4`, the direct parent of #4164; current source prints 0.

### Expected behavior

The cleanup failure should follow Solid's intended error policy. If fatal,
reactivity should halt explicitly. If the error can be contained or caught and
work may continue, that work should not inherit corrupted release state.

The policy and implementation choice are open; this does not require resuming
the interrupted cleanup walk or swallowing its error.

### Screenshots or Videos

_No response_

### Platform

- Linux, Chromium 154; standalone signals repro on Node 24.19.0
- next@`a2743fa2d26d78f38c42600b91aceddb43a1c3ef` (declares rc.15)
- Also reproduced at `71153bf0` in production, development and observe builds

### Additional context

The unrelated-release regression starts with #4164's collector for #4142.
`recompute` saves `deferredReleases`, installs a temporary array, calls
`disposeChildren`, then restores the previous collector. The cleanup throw
skips restoration before the computation body's error handler is entered.
Later last-observer releases append to the abandoned array instead of releasing.
This describes the mechanism, not a claim that continuation is intended.

Related reports/rulings:

- #2496 directly reports throwing `onCleanup` breaking reactivity.
  [Ryan said it was addressed in 2.0](https://github.com/solidjs/solid/issues/2496#issuecomment-3161714253)
  and subsequently closed it as fixed.
- [#2839's ruling](https://github.com/solidjs/solid/issues/2839#issuecomment-4897650632)
  distinguishes reactive compute errors from imperative effect errors, with
  boundary-or-halt handling for the latter. It does not explicitly classify
  this reactive cleanup path.
- #3601 / #3606 detaches the disposal list to prevent reentrant or repeatedly
  throwing `onCleanup` callbacks; it does not specify this path's error routing.
- #4029 / #4034 contains cleanup throws during server-render abort, reports
  through `onError` and continues outer teardown, a different context.

I am reporting the escaping cleanup error and its consequence rather than
proposing a particular catch/finally change.
