Title: [2.0 / next] Throwing cleanup leaves deferred releases active and suppresses unrelated lazy cleanup

### Describe the bug

After catching a cleanup error during an unfinished memo's rerun, disposing an
unrelated lazy memo's last observer no longer runs its cleanup. Its own root is
still alive. Removing the first throw makes that unrelated cleanup run once.

The expected behavior here concerns the unrelated memo; the interrupted cleanup
walk does not need to continue or swallow its error.

### Your Example Website or App

Self-contained public signals repro below. Tested against source-built next at
71153bf0; no Bend runtime, private exports or rewritten source is involved.

### Steps to Reproduce the Bug or Issue

```js
import {
  createMemo, createRenderEffect, createRoot, createSignal, flush, onCleanup
} from '@solidjs/signals';

const [tick, setTick] = createSignal(0);
createRoot(() => {
  createMemo(() => {
    tick();
    onCleanup(() => { throw new Error('cleanup failed'); });
    return new Promise(() => {});
  });
});
flush();
setTick(1);
try { flush(); } catch {} // the first cleanup error has been handled

let cleaned = 0, stop;
createRoot(() => {
  const value = createMemo(() => {
    onCleanup(() => cleaned++);
    return 1;
  }, { lazy: true });
  createRoot(dispose => {
    stop = dispose;
    createRenderEffect(value, () => {});
  });
});
flush();
stop();
flush();
console.log(cleaned); // expected 1, actual 0
```

Control: remove the throwing onCleanup in the first memo. The output is 1.
The direct parent of #4164 also prints 1 with the throw present.

### Expected behavior

Disposing the unrelated memo's last observer releases it and runs its cleanup
once, independently of an earlier caught cleanup error.

### Screenshots or Videos

_No response_

### Platform

- Node 24.19.0, Linux
- Source next@71153bf0dbd1325cf29f81cb1e7a34e380e694d2, still declaring rc.15
- Actual full signals index bundled with esbuild 0.25.12
- Reproduces in production, development and observe tiers, __TEST__=false
- Passing with the throw on a9b9f9e4 (direct parent of #4164) and d2ad8b28

### Additional context

This appears introduced by #4164's deferred-release collection for #4142.
`recompute` sets `deferredReleases`, calls `disposeChildren`, then restores the
previous collection. A cleanup throw skips that restoration, before the body
try/finally has been entered. Later last-reader releases are appended to the
abandoned array and never drained.

A local source experiment putting only disposeChildren/restoration in try/finally
makes both repro controls pass. It preserves the original throw and interrupted
walk. That experiment has not been validated with the full upstream suite or
benchmarked. The unmodified new pin's full signals suite passes (325 files),
so this exception-path control appears uncovered.

Related #4089 concerns cleanup during transaction landing; this repro needs no
action or landing. #4111's comparator-release case concerns another path. I found
no exact duplicate while searching those reports and #4164's discussion.
