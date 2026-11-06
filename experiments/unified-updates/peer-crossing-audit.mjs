import { pathToFileURL } from 'node:url';
const { createRoot, createSignal, createOptimistic, createMemo, createRenderEffect, action, flush } =
  await import(pathToFileURL(process.argv[2]));
const kind = process.argv[3] || 'signals', order = 'pq';
const split = process.argv[4] === 'split';
const end = Promise.withResolvers(), calls = [], shown = {}, frames = [];
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const work = (name, value) => {
  if (!value || name === 'p' || name === 'q') return value;
  if (calls.length > 150) throw new Error('Request growth guard');
  const gate = Promise.withResolvers(); calls.push({ name, value, ...gate }); return gate.promise;
};
let writeA, writeB, guessC, guessD, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const [a, setA] = kind === 'signals' ? createSignal(0) : createOptimistic(() => 0);
  const [b, setB] = kind === 'signals' ? createSignal(0) : createOptimistic(() => 0);
  const [c, setC] = createOptimistic(a), [d, setD] = createOptimistic(b);
  [writeA, writeB, guessC, guessD] = [setA, setB, setC, setD];
  const nodes = { a, b, c, d,
    holdA: createMemo(() => work('a', a())), holdB: createMemo(() => work('b', b())) };
  for (const name of order) nodes[name] = createMemo(() =>
    name === 'p' ? work('p', c() + b()) : work('q', d() + a()));
  for (const [name, node] of Object.entries(nodes))
    createRenderEffect(node, value => { shown[name] = value; }, { schedule: true });
});
flush();
const running = [];
const start = (write, value) => running.push(action(function* () { write(value); yield end.promise; })());
start(guessC, 10); start(guessD, 20); flush();
start(writeA, 1); start(writeB, 2); flush();
start(guessC, 11);
if (split) { flush();
  for (const call of calls) if (call.name !== 'a' && call.name !== 'b') call.resolve(call.value);
  await turn(); flush();
  frames.push({ phase: 'only c proposed', shown: { ...shown }, requests: calls.map(c => `${c.name}:${c.value}`) }); }
start(guessD, 21); flush();
for (let i = 0; i < 6; i++) {
  for (const call of calls) if (call.name !== 'a' && call.name !== 'b') call.resolve(call.value);
  await turn(); flush();
}
frames.push({ phase: 'parents held', shown: { ...shown }, requests: calls.map(c => `${c.name}:${c.value}`) });
for (let i = 0; i < 6; i++) {
  for (const call of calls) call.resolve(call.value);
  await turn(); flush();
}
frames.push({ phase: 'all calculations ready, actions still open', shown: { ...shown }, requests: calls.map(c => `${c.name}:${c.value}`) });
end.resolve(); await Promise.all(running);
for (let i = 0; i < 6; i++) {
  for (const call of calls) call.resolve(call.value);
  await turn(); flush();
}
frames.push({ phase: 'actions ended', shown: { ...shown } });
dispose(); flush();
console.log(JSON.stringify({ kind, split, frames }, null, 2));
