// Explanatory fixture: one gate for each async consequence, actions stay open.
import { pathToFileURL } from 'node:url';
const { createRoot, createOptimistic, createMemo, createRenderEffect, action, flush } =
  await import(pathToFileURL(process.argv[2]));
const pGate = Promise.withResolvers(), qGate = Promise.withResolvers(), end = Promise.withResolvers();
const shown = {}, requests = [], frames = [];
let guessA, guessB, guessC, dispose;
function delayed(name, value, gate) {
  if (value === 0) return 0;
  requests.push(`${name}=${value}`);
  return gate.promise.then(() => value);
}
createRoot(cleanup => {
  dispose = cleanup;
  const [a, setA] = createOptimistic(() => 0);
  const [b, setB] = createOptimistic(() => 0);
  const [c, setC] = createOptimistic(a);
  [guessA, guessB, guessC] = [setA, setB, setC];
  const p = createMemo(() => delayed('p', a() + b(), pGate));
  const q = createMemo(() => delayed('q', c() + b(), qGate));
  for (const [name, read] of Object.entries({ a, b, c, p, q }))
    createRenderEffect(read, value => { shown[name] = value; }, { schedule: true });
});
const record = phase => frames.push({ phase, shown: { ...shown }, requests: [...requests] });
flush(); record('initial');
const running = [];
for (const [guess, value] of [[guessA, 1], [guessB, 2], [guessC, 10]]) {
  running.push(action(function* () { guess(value); yield end.promise; })());
  flush();
}
record('three proposals');
qGate.resolve(); await new Promise(resolve => setTimeout(resolve, 0)); flush();
record('q gate open, p gate closed');
pGate.resolve(); await new Promise(resolve => setTimeout(resolve, 0)); flush();
record('both gates open, all actions still open');
end.resolve(); await Promise.all(running);
dispose(); flush();
console.log(JSON.stringify(frames, null, 2));
