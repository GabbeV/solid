import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { createRoot, createSignal, createMemo, createRenderEffect, isPending, flush } =
  await import(pathToFileURL(process.argv[2]));
assert.equal(typeof global.gc, "function", "Run with --expose-gc");
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const [source, setSource] = createSignal(0);
const refs = [], samples = [];
function mount(initial) {
  const payload = { initial, data: new Uint8Array(1024) };
  refs.push(new WeakRef(payload));
  return createRoot(dispose => {
    const input = createMemo(() => source() === payload.initial
      ? payload.data.length
      : new Promise(() => {}));
    createRenderEffect(() => isPending(input), () => {}, { schedule: true });
    return dispose;
  });
}
for (let round = 0; round < 5; round++) {
  let disposals = Array.from({ length: 200 }, () => mount(round));
  flush();
  setSource(round + 1);
  flush();
  disposals.forEach(dispose => dispose());
  disposals = null;
  flush();
  for (let attempt = 0; attempt < 4; attempt++) {
    await turn();
    global.gc();
  }
  const retained = refs.filter(ref => ref.deref()).length;
  samples.push({ created: refs.length, retained });
  assert.equal(retained, 0);
}
console.log(JSON.stringify({ samples }, null, 2));
