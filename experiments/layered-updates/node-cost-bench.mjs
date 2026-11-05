// Same published values and actions at every depth. The padded-next adapter
// adds one ordinary synchronous identity memo per optimistic boundary, matching
// the scalar experiment's node count for this changing-value workload.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { action, optimistic, createMemo, createRoot, createRenderEffect, flush } =
  await import(pathToFileURL(process.argv[2]));
const timings = {}, work = {};
for (const depth of [1, 4, 16]) {
  let guess, value = 1, shown;
  const dispose = createRoot(dispose => {
    let input = () => 0;
    for (let i = 0; i < depth; i++) {
      const [view, write] = optimistic(input);
      if (!i) guess = write;
      input = createMemo(() => view() + 1, process.argv[3] === "sync" ? { sync: true } : undefined);
    }
    createRenderEffect(input, next => { shown = next; }, { schedule: true });
    return dispose;
  });
  flush();
  const end = Promise.withResolvers();
  const running = action(function* () { guess(1); yield end.promise; })();
  flush();
  const update = () => guess(++value);
  const run = count => { for (let i = 0; i < count; i++) flush(update); };
  for (let i = 0; i < 3; i++) run(5000);
  global.gc();
  const samples = [];
  for (let i = 0; i < 3; i++) {
    const start = performance.now();
    run(10000);
    samples.push((performance.now() - start) * 100);
  }
  assert.equal(shown, value + depth);
  if (globalThis.__countEnabled) {
    globalThis.__counts = {};
    flush(update);
    work[depth] = globalThis.__counts;
    globalThis.__counts = undefined;
  }
  timings[`transparent-${depth}-write-ns`] = samples.toSorted((a, b) => a - b)[1];
  end.resolve();
  await running;
  flush();
  assert.equal(shown, depth);
  dispose();
}
console.log(JSON.stringify({ timings, work }));
