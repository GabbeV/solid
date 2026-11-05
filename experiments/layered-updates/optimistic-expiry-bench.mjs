// Complete shared-action lifetimes, including publication of guesses and
// correction. Open-action write benchmarks do not exercise readiness at expiry.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { action, optimistic, createRoot, createRenderEffect, flush } =
  await import(pathToFileURL(process.argv[2]));
const timings = {};
for (const width of [1, 16, 128]) {
  const writes = [], shown = [];
  const dispose = createRoot(dispose => {
    for (let i = 0; i < width; i++) {
      const [view, guess] = optimistic(() => 0);
      writes.push(guess);
      createRenderEffect(view, value => { shown[i] = value; }, { schedule: true });
    }
    return dispose;
  });
  flush();
  const perform = action(function* (end) {
    for (const guess of writes) guess(1);
    yield end;
  });
  const run = async count => {
    for (let i = 0; i < count; i++) {
      const end = Promise.withResolvers();
      const running = perform(end.promise);
      flush();
      assert.deepEqual(shown, Array(width).fill(1));
      end.resolve();
      await running;
      flush();
      assert.deepEqual(shown, Array(width).fill(0));
    }
  };
  await run(100);
  global.gc();
  const samples = [];
  for (let i = 0; i < 5; i++) {
    const start = performance.now();
    await run(100);
    samples.push((performance.now() - start) * 10_000);
  }
  timings[`shared-${width}-complete-cycle-ns`] = samples.toSorted((a, b) => a - b)[2];
  dispose();
  flush();
}
console.log(JSON.stringify({ timings }));
