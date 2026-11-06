// Retained ordinary allocation, separate from throughput and model counters.
import { pathToFileURL } from 'node:url';
const { createSignal, createMemo, createRoot, flush } = await import(pathToFileURL(process.argv[2]));
const kind = process.argv[3], count = Number(process.argv[4] || 20000);
function allocate(n) {
  const held = [];
  let dispose = () => {};
  if (kind === 'signal') {
    for (let i = 0; i < n; i++) held.push(createSignal(i));
  } else {
    createRoot(cleanup => {
      dispose = cleanup;
      const [source] = createSignal(1);
      for (let i = 0; i < n; i++) {
        const memo = createMemo(() => source() + i);
        memo(); // Materialize dependencies in both implementations.
        held.push(memo);
      }
    });
    flush();
  }
  return { held, dispose };
}
let warm = allocate(1000);
warm.dispose(); warm = null;
await new Promise(resolve => setImmediate(resolve));
global.gc();
const before = process.memoryUsage().heapUsed;
let allocation = allocate(count);
await new Promise(resolve => setImmediate(resolve));
global.gc();
const live = process.memoryUsage().heapUsed;
const value = kind === 'signal' ? allocation.held.at(-1)[0]() : allocation.held.at(-1)();
allocation.dispose(); allocation = null;
await new Promise(resolve => setImmediate(resolve));
global.gc();
const after = process.memoryUsage().heapUsed;
console.log(JSON.stringify({ kind, count, bytesPerNode: (live - before) / count, before, live, after, value }));
