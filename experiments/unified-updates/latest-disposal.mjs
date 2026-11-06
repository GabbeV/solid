import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { action, createSignal, createMemo, createRoot, createRenderEffect,
  flush, latest, isPending } = await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
async function installAndDispose() {
  const payload = new Array(1024).fill(0), ref = new WeakRef(payload);
  const never = new Promise(() => {});
  let dispose, change;
  createRoot(d => {
    dispose = d;
    const [source, setSource] = createSignal(0);
    const result = createMemo(() => latest(source) ? never : payload[0]);
    createRenderEffect(result, () => {});
    createRenderEffect(() => isPending(() => latest(source)), () => {});
    change = action(function* () { setSource(1); yield Promise.resolve(); });
  });
  flush();
  await change();
  await turn();
  dispose();
  flush();
  return ref;
}
const refs = [];
for (let i = 0; i < 50; i++) refs.push(await installAndDispose());
for (let i = 0; i < 10; i++) { await turn(); flush(); global.gc(); }
const retained = refs.filter(ref => ref.deref() !== undefined).length;
console.log(JSON.stringify({ disposed: refs.length, retained }));
assert.equal(retained, 0);
