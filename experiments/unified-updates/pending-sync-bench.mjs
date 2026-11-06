// Pure synchronous writes with a pending observer. Batch each event through
// flush's synchronous scope, avoiding an ever-growing microtask queue.
import assert from 'node:assert/strict';
import { pathToFileURL } from 'node:url';
const { createSignal, createRoot, createRenderEffect, pending, flush } = await import(pathToFileURL(process.argv[2]));
const [source, setSource] = createSignal(0);
let shown, renders = 0, value = 0;
const dispose = createRoot(d => {
  const status = pending(source);
  createRenderEffect(status, next => { shown = next; renders++; });
  return d;
});
flush();
const update = () => setSource(++value);
const run = n => { for (let i = 0; i < n; i++) flush(update); };
for (let i = 0; i < 3; i++) run(50_000);
global.gc();
const samples=[];
for (let i = 0; i < 5; i++) {
  const start=performance.now(); run(100_000);
  samples.push((performance.now()-start)*10);
}
assert.equal(shown, false);
assert.equal(renders, 1);
assert.equal(source(), value);
dispose();
console.log(JSON.stringify({scenario:'pending-observed-sync-write',ns:samples.toSorted((a,b)=>a-b)[2],samples,value}));
