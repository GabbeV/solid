import { pathToFileURL } from 'node:url';
const { createRoot, createOptimistic, createMemo, createRenderEffect, action, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = async () => { await new Promise(resolve => setTimeout(resolve, 0)); flush(); };
const endA = Promise.withResolvers(), nextB = Promise.withResolvers(), endB = Promise.withResolvers();
const calls = [], shown = {};
let guessA, guessB, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const [a, ga] = createOptimistic(() => 4), [b, gb] = createOptimistic(() => 0);
  [guessA, guessB] = [ga, gb];
  const q = createMemo(() => {
    const value = `${a()}/${b()}`;
    if (value === '4/0') return value;
    const gate = Promise.withResolvers(); calls.push({ value, ...gate }); return gate.promise;
  });
  for (const [name, read] of Object.entries({ a, b, q }))
    createRenderEffect(read, value => { shown[name] = value; }, { schedule: true });
});
flush();
const first = action(function* () { guessA(6); yield endA.promise; })();
flush();
const second = action(function* () { guessB(2); yield nextB.promise; guessB(1); yield endB.promise; })();
flush();
calls.findLast(c => c.value === '6/2').resolve('6/2'); await turn();
const revealed = { ...shown };
nextB.resolve(); await turn();
endA.resolve(); await first; await turn();
const afterExpiry = { visible: { ...shown }, started: calls.map(c => c.value) };
calls.findLast(c => c.value === '6/1')?.resolve('6/1'); await turn();
const afterObsolete = { visible: { ...shown }, started: calls.map(c => c.value) };
calls.findLast(c => c.value === '4/1')?.resolve('4/1'); await turn();
const final = { ...shown };
endB.resolve(); await second; await turn(); dispose(); flush();
console.log(JSON.stringify({ revealed, afterExpiry, afterObsolete, final }, null, 2));
