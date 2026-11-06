// Finite nested/sibling audit, fresh process per runtime/order.
// Usage: node coordination-join-audit.mjs ENTRY [pq|qp]
import { pathToFileURL } from 'node:url';
const { createOptimistic, createRoot, createMemo, createRenderEffect, action, flush } =
  await import(pathToFileURL(process.argv[2]));
const order = process.argv[3] || 'pq';
const gates = new Map(), started = [], shown = {}, frames = [];
const end = Promise.withResolvers();
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
function work(name, value) {
  if (value === 0) return 0;
  const key = `${name}:${value}`;
  started.push(key);
  if (!gates.has(key)) gates.set(key, Promise.withResolvers());
  return gates.get(key).promise;
}
let guessA, guessB, guessC, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const [a, setA] = createOptimistic(() => 0);
  const [b, setB] = createOptimistic(() => 0);
  const [c, setC] = createOptimistic(a);
  [guessA, guessB, guessC] = [setA, setB, setC];
  const nodes = { a, b, c };
  for (const name of order) nodes[name] = createMemo(() =>
    work(name, name === 'p' ? a() + b() : c() + b()));
  for (const name of ['a', 'b', 'c', ...order])
    createRenderEffect(nodes[name], value => { shown[name] = value; }, { schedule: true });
});
flush();
const record = phase => frames.push({ phase, shown: { ...shown }, started: [...started] });
record('initial');
const actions = [];
for (const [guess, value, phase] of [[guessA, 1, 'a=1'], [guessB, 2, 'b=2'], [guessC, 10, 'c=10']]) {
  actions.push(action(function* () { guess(value); yield end.promise; })());
  flush(); record(phase);
}
// Resolve the child-only and child-plus-sibling candidates independently.
for (const key of ['q:10', 'q:12', 'p:3', 'q:12']) {
  gates.get(key)?.resolve(Number(key.split(':')[1]));
  await turn(); flush(); record(`resolved ${key}`);
}
// Drain the finite candidate values before ending action scopes.
for (let i = 0; i < 6; i++) {
  for (const [key, gate] of gates) gate.resolve(Number(key.split(':')[1]));
  await turn(); flush();
}
record('all guesses answered');
end.resolve();
await Promise.all(actions);
for (let i = 0; i < 6; i++) {
  for (const [key, gate] of gates) gate.resolve(Number(key.split(':')[1]));
  await turn(); flush();
}
record('actions ended');
dispose(); flush();
console.log(JSON.stringify({ order, frames }, null, 2));
