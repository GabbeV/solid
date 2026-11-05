// Dispose synchronous subtrees while one stale reader and unrelated actions
// remain open. Exercises whether disposal scales with readers or all updates.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { createSignal, createMemo, createRoot, createRenderEffect, action, flush } =
  await import(pathToFileURL(process.argv[2]));
const timings = {};
let sink = 0;
for (const count of [1, 128]) {
  const signals = Array.from({ length: count }, () => createSignal(0));
  const [tick, setTick] = createSignal(0);
  let shown;
  const dispose = createRoot(d => {
    createRenderEffect(() => [signals[0][0](), tick()], value => { shown = value; });
    return d;
  });
  let finish;
  const gate = new Promise(resolve => { finish = resolve; });
  const actions = signals.map(([, set]) => action(function* () { set(1); yield gate; })());
  flush();
  setTick(1);
  flush();
  assert.deepEqual(shown, [0, 1]);
  const run = n => {
    for (let i = 0; i < n; i++) createRoot(d => { sink += createMemo(() => 1)(); d(); });
  };
  for (let i = 0; i < 3; i++) run(10_000);
  global.gc();
  const samples = [];
  for (let i = 0; i < 5; i++) {
    const start = performance.now();
    run(10_000);
    samples.push((performance.now() - start) * 100);
  }
  timings[`dispose-with-${count}-open-updates-ns`] = samples.toSorted((a,b)=>a-b)[2];
  finish();
  await Promise.all(actions);
  flush();
  assert.deepEqual(shown, [1, 1]);
  dispose();
}
console.log(JSON.stringify({ timings, sink }));
