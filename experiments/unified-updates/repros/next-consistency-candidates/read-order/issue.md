# [2.0 / next] Two ordinary reads of the same signal return 1 then 0 when latest() is called between them

### Describe the bug

A memo reads the same signal twice, with a `latest` read between them. Without any intervening write or await, its two ordinary reads return different values.

The memo initially returns a synchronous placeholder. An action then sets `id` from 0 to 1 and remains open. After 500 ms, a separate signal enables this calculation:

```ts
const data = createMemo(() => {
  if (!enabled()) return "Not requested";
  const before = id();
  const proposed = latest(id);
  const after = id();
  const request = `before=${before}, latest=${proposed}, after=${after}`;
  requests.push(request);
  return delay(500).then(() => request);
});
```

The arguments captured in that single execution are:

```text
before=1, latest=1, after=0
```

The calculation completes its synchronous body and starts the async work using those arguments. Its result remains held: the result binding still shows `Not requested`. This is an inconsistent-calculation/request-input issue, not a claim that the held result itself reached the DOM.

The repro copies the recorded arguments into a log from the event handler after another 500 ms. That log is only instrumentation; it does not write signals from inside the memo.

### Your Example Website or App

https://s.olid.uk/id/htrvK-9uQ2Sg5fYRAndmSA

### Steps to Reproduce the Bug or Issue

1. Open the linked repro and click Run once.
2. The action proposes id = 1 and stays open.
3. At 500 ms, the event handler enables the memo.
4. At 1000 ms, observe the captured request arguments: before=1, latest=1, after=0. The same arguments are logged to the console when the calculation runs.

### Expected behavior

The two ordinary id() reads within one uninterrupted calculation should agree. latest(id) may intentionally differ from the ordinary reads. If discovering latest requires evaluating the calculation in a different context, it should not finish a mixed-context execution and start async work with inconsistent arguments. Keeping its eventual result off screen does not prevent such work from being started.

### Platform

- Solid: `next` at `bcef1041cb50bf648da5641693b5ebdea1fc5dc2`, development build
- Browser: Chromium 154.0.8037.57
- OS: Debian GNU/Linux 13

### Additional context

There is no write to id between the two reads and all three reads happen before the promise is returned. The delay stands in for a request; a real fetch at that position would already receive the captured arguments.

Discovered while exploring [unified ordinary and optimistic update propagation](https://github.com/GabbeV/solid/tree/experiment/unified-updates). The repro uses unmodified `next`.
