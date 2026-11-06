// Longer-warmed single-boundary control. The broad chain worker measures this
// shape first, where compiler warm-up can dominate a short timed batch.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { action, optimistic, createSignal, createMemo, createRenderEffect, createRoot, flush } =
  await import(pathToFileURL(process.argv[2]));
const timings = {}, samples = {};
for (const direct of [false, true]) {
  let dispose, guess, shown = 0, value = 1;
  createRoot(cleanup => {
    dispose = cleanup;
    const [source] = createSignal(0);
    const [view, write] = optimistic(direct ? source : () => source());
    guess = write;
    const plusOne = createMemo(() => view() + 1);
    createRenderEffect(plusOne, next => { shown = next; });
  });
  const end = Promise.withResolvers();
  const running = action(function* () { guess(value); yield end.promise; })();
  flush();
  const update = () => guess(++value);
  const run = () => {
    for (let i = 0; i < 50000; i++) flush(update);
    assert.equal(shown, value + 1);
  };
  for (let i = 0; i < 3; i++) run();
  global.gc();
  const values = [];
  for (let i = 0; i < 5; i++) {
    const start = performance.now();
    run();
    values.push((performance.now() - start) * 1e6 / 50000);
  }
  const name = direct ? "single-direct-write-ns" : "single-callback-write-ns";
  samples[name] = values;
  timings[name] = values.toSorted((a, b) => a - b)[2];
  dispose();
  end.resolve();
  await running;
  flush();
}
console.log(JSON.stringify({ timings, samples }));
