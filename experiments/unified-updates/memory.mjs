import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const api = await import(pathToFileURL(process.argv[2]));
const { createRoot, createSignal, createMemo, createRenderEffect, optimistic, action, flush } = api;
const tick = () => new Promise(resolve => setTimeout(resolve, 0));
async function collect() {
  for (let i = 0; i < 8; i++) {
    await tick();
    flush();
    global.gc();
  }
}
function gate() {
  let resolve;
  const promise = new Promise(r => {
    resolve = r;
  });
  return { promise, resolve };
}

// The producer remains live; obsolete readers must not be retained by an
// update record after it publishes. No test-only registries are compiled in.
async function install() {
  const input = createSignal(0),
    body = gate(),
    flight = gate();
  let view, guess, dispose;
  createRoot(d => {
    dispose = d;
    [view, guess] = optimistic(input[0]);
    const derived = createMemo(() => (view() ? flight.promise : 0));
    createRenderEffect(derived, () => {});
  });
  const running = action(function* () {
    guess(1);
    yield body.promise;
    input[1](1);
  })();
  flush();
  const refs = [];
  for (let i = 0; i < 30; i++) {
    const token = { payload: new Array(1024).fill(i) };
    refs.push(new WeakRef(token));
    const disposeReader = createRoot(d => {
      const memo = createMemo(() => {
        view();
        return token;
      });
      createRenderEffect(
        () => !!memo(),
        () => {}
      );
      return d;
    });
    flush();
    disposeReader();
  }
  flight.resolve(1);
  body.resolve();
  await running;
  await tick();
  flush();
  return { refs, dispose, view };
}
const fixture = await install();
await collect();
const retained = fixture.refs.filter(ref => ref.deref() !== undefined).length;
assert.equal(fixture.view(), 1);
fixture.dispose();

await collect();
const before = process.memoryUsage().heapUsed;
let boundaries;
const dispose = createRoot(d => {
  boundaries = Array.from({ length: 20_000 }, () => optimistic(() => 0));
  return d;
});
await collect();
const boundaryBytes = (process.memoryUsage().heapUsed - before) / boundaries.length;
dispose();
boundaries = null;
await collect();
const [commonInput] = createSignal(0);
await collect();
const directBefore = process.memoryUsage().heapUsed;
const disposeDirect = createRoot(d => {
  boundaries = Array.from({ length: 20_000 }, () => optimistic(commonInput));
  return d;
});
await collect();
const directBoundaryBytes = (process.memoryUsage().heapUsed - directBefore) / boundaries.length;
disposeDirect();
boundaries = null;
await collect();
console.log(
  JSON.stringify({
    node: process.version,
    retainedDisposedReaders: retained,
    boundaryBytes,
    directBoundaryBytes
  })
);
assert.equal(retained, 0, "a live boundary retains disposed readers of its completed update");
