// Compare a late-discovered join across real runtimes and graph arrangements.
import { pathToFileURL } from 'node:url';
const { createRoot, createSignal, createOptimistic, createMemo, createRenderEffect, action, flush } =
  await import(pathToFileURL(process.argv[2]));
const mode = process.argv[3] || 'pq';
const calls = [], frames = [], shown = {}, end = Promise.withResolvers();
const conditionGate = Promise.withResolvers();
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
function work(name, value) {
  if (!value) return 0;
  if (calls.length > 100) throw new Error('Request growth guard');
  const gate = Promise.withResolvers(); calls.push({ name, value, ...gate });
  return gate.promise;
}
let guessA, guessB, guessC, setEnabled, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const [a, setA] = createOptimistic(() => 0);
  const [b, setB] = createOptimistic(() => 0);
  const [c, setC] = createOptimistic(a);
  const [requested, enable] = createSignal(false);
  const enabled = mode === 'async-condition'
    ? createMemo(() => requested() ? conditionGate.promise : false) : requested;
  [guessA, guessB, guessC, setEnabled] = [setA, setB, setC, enable];
  const holdA = createMemo(() => work('a', a()));
  const holdB = createMemo(() => work('b', b()));
  let condition = enabled;
  if (mode === 'deep-p') for (let i = 0; i < 8; i++) {
    const previous = condition; condition = createMemo(previous);
  }
  const nodes = { a, b, c, enabled, holdA, holdB };
  for (const name of mode === 'qp' ? ['q', 'p'] : ['p', 'q'])
    nodes[name] = createMemo(() => name === 'p'
      ? condition() ? work('p', a() + b()) : 0
      : work('q', c() + b()));
  for (const [name, node] of Object.entries(nodes))
    createRenderEffect(node, value => { shown[name] = value; }, { schedule: true });
});
flush();
const actions = [action(function* () { guessC(0); yield end.promise; })()];
flush();
for (const [guess, value] of [[guessA, 1], [guessB, 2]]) {
  actions.push(action(function* () { guess(value); yield end.promise; })()); flush();
}
actions.push(action(function* () { guessC(10); yield end.promise; })());
setEnabled(true); flush();
if (mode === 'async-condition') {
  frames.push({ phase: 'condition unresolved', shown: { ...shown }, started: calls.map(c => `${c.name}:${c.value}`) });
  conditionGate.resolve(true); await turn(); flush();
  frames.push({ phase: 'condition resolved', shown: { ...shown }, started: calls.map(c => `${c.name}:${c.value}`) });
}
for (let i = 0; i < 6; i++) {
  for (const call of calls) if (call.name !== 'a') call.resolve(call.value);
  await turn(); flush();
}
frames.push({ phase: 'a held', shown: { ...shown }, started: calls.map(c => `${c.name}:${c.value}`) });
for (let i = 0; i < 6; i++) {
  for (const call of calls) call.resolve(call.value);
  await turn(); flush();
}
frames.push({ phase: 'all guesses answered', shown: { ...shown }, started: calls.map(c => `${c.name}:${c.value}`) });
end.resolve(); await Promise.all(actions);
for (let i = 0; i < 6; i++) {
  for (const call of calls) call.resolve(call.value);
  await turn(); flush();
}
frames.push({ phase: 'actions ended', shown: { ...shown } });
dispose(); flush();
console.log(JSON.stringify({ mode, frames }, null, 2));
