// Separate open actions exercise shared transaction membership without memo
// entanglement. Every update has a real, independently published render output.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { action, optimistic, createMemo, createRenderEffect, createRoot, flush } =
  await import(pathToFileURL(process.argv[2]));
const timings = {};
for (const width of [1, 16, 128]) {
  const writes = [], shown = [], values = Array(width).fill(1);
  let dispose, cursor = 0;
  createRoot(cleanup => {
    dispose = cleanup;
    for (let i = 0; i < width; i++) {
      const [view, guess] = optimistic(() => 0);
      writes.push(guess);
      const doubled = createMemo(() => view() * 2);
      createRenderEffect(doubled, value => { shown[i] = value; }, { schedule: true });
    }
  });
  flush();
  const end = Promise.withResolvers(), running = [];
  for (let i = 0; i < width; i++) {
    running.push(action(function* () { writes[i](1); yield end.promise; })());
    flush();
  }
  assert.deepEqual(shown, values.map(value => value * 2));
  const update = () => {
    const i = cursor++ % width;
    writes[i](++values[i]);
  };
  const count = Math.ceil(20000 / width);
  const run = () => { for (let i = 0; i < count; i++) flush(update); };
  for (let warm = 0; warm < 3; warm++) run();
  global.gc();
  const start = performance.now();
  run();
  timings[`independent-${width}-write-ns`] = (performance.now() - start) * 1e6 / count;
  assert.deepEqual(shown, values.map(value => value * 2));
  end.resolve();
  await Promise.all(running);
  flush();
  assert.deepEqual(shown, Array(width).fill(0));
  dispose();
  flush();
}
console.log(JSON.stringify({ timings }));
