// One active override feeds many ordinary memos and one rendered total.
// Unlike the chain benchmark, this exposes repeated scans of a wide queue.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { action, optimistic, createMemo, createRenderEffect, createRoot, flush } =
  await import(pathToFileURL(process.argv[2]));
const timings = {};
for (const width of [16, 128, 512]) {
  let guess, dispose, shown = 0, value = 1;
  createRoot(cleanup => {
    dispose = cleanup;
    const [view, write] = optimistic(() => 0);
    guess = write;
    const branches = Array.from({ length: width }, (_, i) => createMemo(() => view() + i));
    createRenderEffect(() => {
      let total = 0;
      for (const branch of branches) total += branch();
      return total;
    }, total => { shown = total; }, { schedule: true });
  });
  flush();
  const end = Promise.withResolvers();
  const running = action(function* () { guess(value); yield end.promise; })();
  flush();
  const update = () => guess(++value);
  const run = count => {
    for (let i = 0; i < count; i++) flush(update);
    assert.equal(shown, width * value + width * (width - 1) / 2);
  };
  const count = Math.ceil(100000 / width);
  for (let warm = 0; warm < 3; warm++) run(count);
  global.gc();
  const start = performance.now();
  run(count);
  timings[`fanout-${width}-write-ns`] = (performance.now() - start) * 1e6 / count;
  dispose();
  end.resolve();
  await running;
  flush();
}
console.log(JSON.stringify({ timings }));
