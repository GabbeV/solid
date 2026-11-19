import assert from 'node:assert/strict';
import { pathToFileURL } from 'node:url';
const { action, createSignal, createMemo, createOptimistic, createRenderEffect, createRoot, flush } =
  await import(pathToFileURL(process.argv[2]));
const depth = Number(process.argv[3]), count = Number(process.argv[4] || 2000);
const samples = [];
for (let repeat = 0; repeat < 4; repeat++) {
  let guess, dispose, shown;
  createRoot(cleanup => {
    dispose = cleanup;
    let read = createSignal(0)[0];
    for (let i = 0; i < depth; i++) {
      const [value, set] = createOptimistic(read);
      if (!i) guess = set;
      read = createMemo(() => value() + 1);
    }
    createRenderEffect(read, value => { shown = value; });
  });
  flush();
  const end = Promise.withResolvers();
  const running = action(function* () {
    guess(1);
    yield end.promise;
  })();
  flush();
  const start = performance.now();
  for (let value = 2; value <= count + 1; value++) flush(() => guess(value));
  const elapsed = performance.now() - start;
  assert.equal(shown, count + 1 + depth);
  if (repeat) samples.push(elapsed * 1e6 / count);
  end.resolve(); await running; flush();
  assert.equal(shown, depth);
  dispose();
}
console.log(JSON.stringify({ depth, count, samples, ns: [...samples].sort((a,b) => a-b)[1] }));
