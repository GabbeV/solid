// Retention after disposing a whole optimistic subtree whose input never lands.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { createRoot, createSignal, createMemo, createOptimistic, createRenderEffect, action, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));

async function installAndDispose() {
  const payload = new Array(1024).fill(0);
  const ref = new WeakRef(payload);
  const never = new Promise(() => {});
  let dispose, change;
  createRoot(d => {
    dispose = d;
    const [revision, setRevision] = createSignal(0);
    const input = createMemo(() => revision() ? never : payload[0]);
    const [view, guess] = createOptimistic(input);
    createRenderEffect(view, () => {});
    change = action(function* () {
      setRevision(1);
      guess(1);
      yield Promise.resolve();
    });
  });
  await change();
  await turn();
  dispose();
  flush();
  return ref;
}

const refs = [];
for (let i = 0; i < 50; i++) refs.push(await installAndDispose());
for (let i = 0; i < 10; i++) {
  await turn();
  flush();
  global.gc();
}
const retained = refs.filter(ref => ref.deref() !== undefined).length;
console.log(JSON.stringify({ disposed: refs.length, retained }));
if (!process.argv.includes("--record-only"))
  assert.equal(retained, 0, "disposed pending-input scopes retain payloads");
