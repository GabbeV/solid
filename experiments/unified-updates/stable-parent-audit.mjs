import { pathToFileURL } from 'node:url';
const { action, createRoot, createSignal, createOptimistic, createMemo, createRenderEffect, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const runs = [];
for (const scenario of ['activate', 'expire']) {
  const calls = [], tasks = [], ends = [], shown = {}, checkpoints = [];
  let dispose, guessA, guessB, guessC;
  const work = (name, value) => {
    if (!value) return 0;
    const gate = Promise.withResolvers(); calls.push({ name, value, ...gate }); return gate.promise;
  };
  createRoot(cleanup => {
    dispose = cleanup;
    const [base] = createSignal(0);
    const [a, writeA] = createOptimistic(base), [b, writeB] = createOptimistic(base);
    const [c, writeC] = createOptimistic(a);
    [guessA, guessB, guessC] = [writeA, writeB, writeC];
    const holdB = createMemo(() => work('b', b()));
    const q = createMemo(() => work('q', c() + b()));
    for (const [name, read] of Object.entries({ a, b, c, q, holdB }))
      createRenderEffect(read, value => { shown[name] = value; });
  });
  const start = (guess, value) => {
    const end = Promise.withResolvers(); ends.push(end);
    const task = action(function* () { guess(value); yield end.promise; })(); tasks.push(task);
    flush(); return { end, task };
  };
  let parent;
  if (scenario === 'expire') parent = start(guessA, 1);
  start(guessB, 2); start(guessC, 10);
  const record = phase => checkpoints.push({ phase, shown: { ...shown }, calls: calls.map(c => `${c.name}:${c.value}`) });
  record('child and peer waiting');
  if (scenario === 'activate') parent = start(guessA, 1);
  else { parent.end.resolve(); await parent.task; await turn(); flush(); }
  record('parent changed; no requests answered');
  for (let pass = 0; pass < 4; pass++) {
    for (const call of calls) if (call.name === 'q') call.resolve(call.value);
    await turn(); flush();
  }
  record('q answered; b still pending');
  for (let pass = 0; pass < 4; pass++) {
    for (const call of calls) call.resolve(call.value);
    await turn(); flush();
  }
  record('all requests answered; remaining actions open');
  dispose(); for (const end of ends) end.resolve(); await Promise.all(tasks); await turn(); flush();
  runs.push({ scenario, checkpoints });
}
console.log(JSON.stringify(runs, null, 2));
