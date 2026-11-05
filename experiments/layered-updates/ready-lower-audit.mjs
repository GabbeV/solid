import { pathToFileURL } from 'node:url';
const { action, createRoot, createSignal, createOptimistic, createMemo, createRenderEffect, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const first = Promise.withResolvers(), combined = Promise.withResolvers(), end = Promise.withResolvers();
const shown = { guess: 0, ordinary: 0, label: '0:0' }, runs = [], checkpoints = [];
let guess, setOrdinary, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const [ordinary, write] = createSignal(0);
  const [view, predict] = createOptimistic(() => 0);
  setOrdinary = write; guess = predict;
  const label = createMemo(() => {
    const value = `${view()}:${ordinary()}`;
    runs.push(value);
    return value === '1:0' ? first.promise : value === '1:10' ? combined.promise : value;
  });
  createRenderEffect(view, value => { shown.guess = value; });
  createRenderEffect(ordinary, value => { shown.ordinary = value; });
  createRenderEffect(label, value => { shown.label = value; });
});
const checkpoint = name => { flush(); checkpoints.push({ name, shown: { ...shown }, runs: [...runs] }); };
const running = action(function* () { guess(1); yield end.promise; })();
checkpoint('guess 1; its label unresolved');
setOrdinary(10); checkpoint('ordinary changes to 10');
first.resolve('1:0'); await turn(); checkpoint('old label answers');
combined.resolve('1:10'); await turn(); checkpoint('combined label answers');
end.resolve(); await running; await turn(); checkpoint('action ended');
dispose(); flush();
console.log(JSON.stringify(checkpoints, null, 2));
