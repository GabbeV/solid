// Does an unused optimistic wrapper introduce a layer for a later child guess?
import { pathToFileURL } from 'node:url';
const { createRoot, createSignal, createOptimistic, createMemo, createRenderEffect, action, flush } =
  await import(pathToFileURL(process.argv[2]));
const wrapped = process.argv[3] === 'wrapped';
const expired = process.argv[4] === 'expired';
const end = Promise.withResolvers(), qGate = Promise.withResolvers(), bGate = Promise.withResolvers();
const shown = {}, started = [];
let guessA, guessB, guessC, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const [source] = createSignal(0);
  const [a, setA] = createOptimistic(source);
  const [b, setB] = createOptimistic(() => 0);
  const [c, setC] = createOptimistic(wrapped ? a : source);
  [guessA, guessB, guessC] = [setA, setB, setC];
  const holdB = createMemo(() => {
    const value = b(); return value ? bGate.promise.then(() => value) : 0;
  });
  const q = createMemo(() => {
    const value = c() + b();
    if (!value) return 0;
    started.push(value);
    return qGate.promise.then(() => value);
  });
  for (const [name, node] of Object.entries({ a, b, c, holdB, q }))
    createRenderEffect(node, value => { shown[name] = value; }, { schedule: true });
});
flush();
if (expired) {
  // An equal override still has an action lifetime. Finish it before the
  // peer/child experiment; the wrapper is now inactive, not never used.
  const endA = Promise.withResolvers();
  const prior = action(function* () { guessA(0); yield endA.promise; })(); flush();
  endA.resolve(); await prior; flush();
}
const first = action(function* () { guessB(2); yield end.promise; })(); flush();
const second = action(function* () { guessC(10); yield end.promise; })(); flush();
qGate.resolve(); await new Promise(resolve => setTimeout(resolve, 0)); flush();
const held = { ...shown };
bGate.resolve(); await new Promise(resolve => setTimeout(resolve, 0)); flush();
const ready = { ...shown };
end.resolve(); await Promise.all([first, second]);
dispose(); flush();
console.log(JSON.stringify({ wrapped, expired, held, ready, started }, null, 2));
