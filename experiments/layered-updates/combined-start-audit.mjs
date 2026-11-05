import { pathToFileURL } from 'node:url';
const { action, createRoot, createSignal, createOptimistic, createMemo, createRenderEffect, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const traces = [];
for (const flushLower of [false, true]) {
  const end = Promise.withResolvers(), flights = [], runs = [], checkpoints = [];
  const shown = { view: 0, ordinary: 0, label: '0:0' };
  let write, guess, dispose;
  createRoot(cleanup => {
    dispose = cleanup;
    const [ordinary, setOrdinary] = createSignal(0);
    const [view, predict] = createOptimistic(() => 0);
    write = setOrdinary; guess = predict;
    const label = createMemo(() => {
      const key = `${view()}:${ordinary()}`; runs.push(key);
      if (key === '0:0') return key;
      const gate = Promise.withResolvers(); flights.push({ key, ...gate });
      return gate.promise;
    });
    for (const [name, input] of [['view', view], ['ordinary', ordinary], ['label', label]])
      createRenderEffect(input, value => { shown[name] = value; });
  });
  const snapshot = step => { flush(); checkpoints.push({ step, shown: { ...shown }, runs: [...runs] }); };
  write(10);
  if (flushLower) snapshot('ordinary update prepared');
  const running = action(function* () { guess(1); yield end.promise; })();
  snapshot('both writes made');
  for (const f of flights.filter(f => f.key === '1:0')) f.resolve(f.key);
  await turn(); snapshot('optimistic-only answers');
  for (const f of flights.filter(f => f.key === '1:10')) f.resolve(f.key);
  await turn(); snapshot('combined answers');
  dispose(); end.resolve(); await running; await turn(); flush();
  traces.push({ flushLower, checkpoints });
}
console.log(JSON.stringify(traces, null, 2));
