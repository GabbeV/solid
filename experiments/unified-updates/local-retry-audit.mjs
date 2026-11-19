import { pathToFileURL } from 'node:url';
const { action, createRoot, createSignal, createOptimistic, createMemo, createRenderEffect, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const scenarios = [];

// A suspended argument prevents the request from starting at all.
{
  const dependency = Promise.withResolvers();
  const requests = [], checkpoints = [];
  let dispose, runs = 0;
  createRoot(cleanup => {
    dispose = cleanup;
    const id = createMemo(() => dependency.promise);
    const result = createMemo(() => {
      runs++;
      const value = id();
      requests.push(value);
      return Promise.resolve(`result:${value}`);
    });
    createRenderEffect(result, () => {});
  });
  flush();
  checkpoints.push({ phase: 'dependency pending', runs, requests: [...requests] });
  dependency.resolve(1); await turn(); flush();
  checkpoints.push({ phase: 'dependency answered', runs, requests: [...requests] });
  dispose(); flush();
  scenarios.push({ scenario: 'local suspension before request', checkpoints });
}

// A first lane read can repair earlier staged reads within the same flush.
for (const optimisticFirst of [false, true]) {
  const end = Promise.withResolvers();
  const requests = [], publications = [], reads = [];
  let dispose, setX, guess;
  createRoot(cleanup => {
    dispose = cleanup;
    const [x, writeX] = createSignal(0);
    const [view, writeView] = createOptimistic(() => 0);
    setX = writeX; guess = writeView;
    const result = createMemo(() => {
      let ordinary, optimistic;
      if (optimisticFirst) { optimistic = view(); ordinary = x(); }
      else { ordinary = x(); optimistic = view(); }
      reads.push({ ordinary, optimistic, ordinaryAgain: x() });
      const key = `${ordinary}:${optimistic}`;
      if (key === '0:0') return key;
      const request = Promise.withResolvers();
      requests.push({ key, ...request });
      return request.promise;
    });
    createRenderEffect(result, value => { publications.push(value); });
  });
  flush();
  const task = action(function* () {
    setX(1); guess(10); yield end.promise;
  })();
  flush();
  const checkpoints = [{ phase: 'write and guess flushed; action open', requests: requests.map(r => r.key), reads: [...reads], publications: [...publications] }];
  for (const request of requests) request.resolve(request.key);
  await turn(); flush();
  checkpoints.push({ phase: 'requests answered; action still open', requests: requests.map(r => r.key), reads: [...reads], publications: [...publications] });
  dispose(); end.resolve(); await task; await turn(); flush();
  scenarios.push({ scenario: 'same-flush read selection', optimisticFirst, checkpoints });
}
console.log(JSON.stringify(scenarios, null, 2));
