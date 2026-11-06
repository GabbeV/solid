// Retained heap of synchronous public primitives, including their public handles.
// Run in a fresh process with --expose-gc for each runtime/sample.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { createSignal, createMemo, createRoot, flush } = await import(pathToFileURL(process.argv[2]));
const count = 30_000;
async function collect() {
  for (let i = 0; i < 6; i++) {
    await new Promise(resolve => setTimeout(resolve, 0));
    flush();
    global.gc();
  }
}
async function measure(make, read) {
  let outputs;
  let release = createRoot(dispose => {
    outputs = Array.from({ length: 2_000 }, make);
    for (const output of outputs) assert.equal(read(output), 0);
    return dispose;
  });
  release(); outputs = null; release = null;
  await collect();
  const before = process.memoryUsage().heapUsed;
  release = createRoot(dispose => {
    outputs = Array.from({ length: count }, make);
    for (const output of outputs) assert.equal(read(output), 0);
    return dispose;
  });
  await collect();
  const bytes = (process.memoryUsage().heapUsed - before) / count;
  assert.equal(outputs.length, count);
  release(); outputs = null; release = null;
  await collect();
  return bytes;
}
const signalBytes = await measure(() => createSignal(0), pair => pair[0]());
const [source] = createSignal(0);
const memoBytes = await measure(() => createMemo(source), read => read());
console.log(JSON.stringify({ count, signalBytes, memoBytes }));
