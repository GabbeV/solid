// Creation cost and retained heap for a common normalized memo, with either
// a callback input or the original accessor. No input/source allocation is
// included in the per-boundary measurement.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { optimistic, createMemo, createRoot, flush } =
  await import(pathToFileURL(process.argv[2]));
const collect = async () => {
  for (let i = 0; i < 5; i++) {
    await new Promise(resolve => setTimeout(resolve, 0));
    flush();
    global.gc();
  }
};
const timings = {}, heapBytes = {};
for (const kind of ["callback", "memo-accessor"]) {
  let input;
  const disposeInput = createRoot(dispose => {
    input = createMemo(() => 0, process.argv[3] === "sync" ? { sync: true } : undefined);
    return dispose;
  });
  await collect();
  const before = process.memoryUsage().heapUsed;
  let boundaries;
  const start = performance.now();
  const dispose = createRoot(dispose => {
    boundaries = Array.from({ length: 20000 }, () =>
      optimistic(kind === "callback" ? () => input() : input));
    return dispose;
  });
  timings[`${kind}-create-ns`] = (performance.now() - start) * 50;
  await collect();
  heapBytes[kind] = (process.memoryUsage().heapUsed - before) / boundaries.length;
  assert.equal(boundaries[0][0](), 0);
  assert.equal(boundaries.at(-1)[0](), 0);
  dispose();
  boundaries = null;
  disposeInput();
  await collect();
}
console.log(JSON.stringify({ timings, heapBytes }));
