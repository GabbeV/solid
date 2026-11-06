// Ordinary synchronous actions with one unused optimistic boundary alive.
// This exercises base-depth transaction creation without guesses or async work.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { action, optimistic, createSignal, createMemo, createRenderEffect, createRoot, flush } =
  await import(pathToFileURL(process.argv[2]));
let dispose, set, value = 0, shown = -1;
createRoot(cleanup => {
  dispose = cleanup;
  const [unused] = optimistic(() => 0);
  createRenderEffect(unused, () => {});
  const [source, write] = createSignal(0);
  set = write;
  const doubled = createMemo(() => source() * 2);
  createRenderEffect(doubled, next => { shown = next; }, { schedule: true });
});
flush();
const update = action(function* () { set(++value); });
const run = () => {
  for (let i = 0; i < 20000; i++) { update(); flush(); }
  assert.equal(shown, value * 2);
};
for (let i = 0; i < 3; i++) run();
global.gc();
const samples = [];
for (let i = 0; i < 5; i++) {
  const start = performance.now();
  run();
  samples.push((performance.now() - start) * 1e6 / 20000);
}
dispose();
flush();
console.log(JSON.stringify({ samples, timings: {
  "inactive-sync-action-ns": [...samples].sort((a, b) => a - b)[2]
} }));
