import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { createSignal, createMemo, createRoot, createRenderEffect, pending, action, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
async function collect() {
  for (let i = 0; i < 8; i++) {
    await turn();
    flush();
    global.gc();
  }
}
async function install() {
  const [x, setX] = createSignal(0);
  let finish, dispose, p;
  const end = new Promise(resolve => {
    finish = resolve;
  });
  createRoot(d => {
    dispose = d;
    p = pending(x);
    createRenderEffect(p, () => {});
  });
  flush();
  const running = action(function* () {
    setX(1);
    yield end;
  })();
  flush();
  assert.equal(p(), true);
  const refs = [];
  for (let i = 0; i < 30; i++) {
    const token = { payload: new Array(1024).fill(i) };
    refs.push(new WeakRef(token));
    const release = createRoot(d => {
      const memo = createMemo(() => {
        p();
        x();
        return token;
      });
      createRenderEffect(
        () => !!memo(),
        () => {}
      );
      return d;
    });
    flush();
    release();
  }
  return { refs, dispose, p, finish, running };
}
const fixture = await install();
await collect();
assert.equal(fixture.p(), true);
const retainedDuringAction = fixture.refs.filter(ref => ref.deref() !== undefined).length;
fixture.finish();
await fixture.running;
await collect();
assert.equal(fixture.p(), false);
const retained = fixture.refs.filter(ref => ref.deref() !== undefined).length;
fixture.dispose();
assert.equal(retained, 0, "a completed pending update retained disposed reader payloads");

async function retainedPerBoundary(make) {
  await collect();
  const before = process.memoryUsage().heapUsed;
  let outputs;
  const dispose = createRoot(d => {
    outputs = Array.from({ length: 20_000 }, make);
    return d;
  });
  flush();
  await collect();
  const bytes = (process.memoryUsage().heapUsed - before) / outputs.length;
  dispose();
  outputs = null;
  await collect();
  return bytes;
}
const boundaryBytes = await retainedPerBoundary(() => pending(() => 0));
const [input] = createSignal(0);
const directBoundaryBytes = await retainedPerBoundary(() => pending(input));
const uniqueBoundaryBytes = await retainedPerBoundary(() => {
  const [source] = createSignal(0);
  return pending(source);
});
console.log(
  JSON.stringify({
    retainedDuringAction,
    retainedDisposedReaders: retained,
    boundaryBytes,
    directBoundaryBytes,
    uniqueBoundaryBytes
  })
);
