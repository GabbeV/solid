// Diagnostic workload: one depth per process and successive timing windows.
// CPU-profile runs locate work; their timings are not acceptance measurements.
import assert from 'node:assert/strict';
import {pathToFileURL} from 'node:url';
const {action, optimistic, createMemo, createRenderEffect, createRoot, flush} =
  await import(pathToFileURL(process.argv[2]));
const depths = (process.env.NESTED_DEPTHS || '16').split(',').map(Number);
const count = Number(process.env.NESTED_WRITES || 50000);
const measurements = {}, timings = {};
const windows = Number(process.env.NESTED_WINDOWS || 10);
for (const depth of depths) {
const writes = [], shown = [];
let dispose, value = 100;
createRoot(cleanup => {
  dispose = cleanup;
  let input = () => 0;
  for (let i = 0; i < depth; i++) {
    const [view, guess] = optimistic(input);
    writes.push(guess);
    createRenderEffect(view, next => { shown[i] = next; }, {schedule: true});
    input = createMemo(() => view() + 1);
  }
});
flush();
const end = Promise.withResolvers(), running = [];
for (let i = 0; i < depth; i++) {
  running.push(action(function* () { writes[i](value + i); yield end.promise; })());
  flush();
}
const write = () => { writes[depth - 1](++value + depth - 1); };
const run = count => { for (let i = 0; i < count; i++) flush(write); };
for (let i = 0; i < 3; i++) run(5000);
global.gc();
const samples = [];
for (let i = 0; i < windows; i++) {
  const start = performance.now();
  run(count);
  samples.push((performance.now() - start) * 1e6 / count);
}
assert.deepEqual(shown, Array.from({length: depth}, (_, i) =>
  (i === depth - 1 ? value : 100) + i));
dispose(); end.resolve(); await Promise.all(running); flush();
measurements[depth] = samples;
timings[`nested-${depth}`] = [...samples].sort((a,b)=>a-b)[Math.floor(samples.length/2)];
}
console.log(JSON.stringify({depths, count, measurements, timings}));
