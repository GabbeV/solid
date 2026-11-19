import { pathToFileURL } from 'node:url';
const { action, createRoot, createSignal, createOptimistic, createMemo, createRenderEffect, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const end = Promise.withResolvers(), lower = Promise.withResolvers();
const flights = [], runs = [], checkpoints = [];
const shown = { view: 0, input: 0, label: '0:0' };
let write, guess, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const [revision, setRevision] = createSignal(0);
  const input = createMemo(() => revision() === 20 ? lower.promise : revision());
  const [view, predict] = createOptimistic(() => 0);
  write = setRevision; guess = predict;
  const label = createMemo(() => {
    const key = `${view()}:${input()}`; runs.push(key);
    if (key === '0:0') return key;
    const gate = Promise.withResolvers(); flights.push({ key, ...gate }); return gate.promise;
  });
  for (const [name, accessor] of [['view', view], ['input', input], ['label', label]])
    createRenderEffect(accessor, value => { shown[name] = value; });
});
const snapshot = step => { flush(); checkpoints.push({ step, shown: { ...shown }, runs: [...runs] }); };
const running = action(function* () { guess(1); yield end.promise; })();
snapshot('first guess');
write(10); snapshot('ready ordinary proposal');
write(20); snapshot('ordinary input suspends again');
guess(2); snapshot('second guess while lower input pending');
for (const f of flights.filter(f => f.key === '2:0' || f.key === '2:10')) f.resolve(f.key);
await turn(); snapshot('optimistic-only answer');
lower.resolve(20); await turn(); snapshot('lower answer');
for (const f of flights.filter(f => f.key === '2:20')) f.resolve(f.key);
await turn(); snapshot('combined answer');
dispose(); end.resolve(); await running; await turn(); flush();
console.log(JSON.stringify(checkpoints, null, 2));
