// A synchronous accumulator calculates for guess=1, but its async consequence
// prevents publication. Guess=2 supersedes that calculation before it settles.
import { pathToFileURL } from "node:url";
const { action, createSignal, createMemo, createOptimistic, createRenderEffect, createRoot, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const reports = {};
for (const asyncPosition of ["downstream", "reducer"]) {
  const stale = Promise.withResolvers(), second = Promise.withResolvers(), end = Promise.withResolvers();
  const calls = [], snapshots = [], publications = [];
  const shown = {};
  let guess, dispose;
  createRoot(cleanup => {
    dispose = cleanup;
    const [source] = createSignal(5);
    const [value, propose] = createOptimistic(source);
    guess = propose;
    const sum = createMemo((previous = 0) => {
      const input = value();
      const result = previous + input;
      calls.push({ previous, input, result });
      return asyncPosition === "reducer" && input === 1 ? stale.promise.then(() => result) : result;
    });
    const settled = createMemo(() => {
      const result = sum();
      return asyncPosition === "downstream" && value() === 1 ? stale.promise.then(() => result) : result;
    });
    for (const [key, read] of Object.entries({ value, sum, settled }))
      createRenderEffect(read, value => { shown[key] = value; publications.push({ key, value }); }, { schedule: true });
  });
  flush();
  const snapshot = phase => snapshots.push({ phase, shown: { ...shown }, calls: calls.map(c => ({ ...c })), publications: publications.slice() });
  snapshot("initial");
  const running = action(function* () {
    guess(1);
    yield second.promise;
    guess(2);
    yield end.promise;
  })();
  await turn();
  snapshot("guess 1 suspended");
  second.resolve();
  await turn();
  snapshot("guess 2 supersedes guess 1");
  stale.resolve();
  await turn();
  snapshot("stale work resolves");
  end.resolve();
  await running;
  await turn();
  snapshot("action ends");
  dispose();
  flush();
  reports[asyncPosition] = snapshots;
}
console.log(JSON.stringify(reports, null, 2));
