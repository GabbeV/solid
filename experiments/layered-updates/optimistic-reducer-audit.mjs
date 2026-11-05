// Observe a synchronous accumulator directly below an optimistic boundary.
import { pathToFileURL } from "node:url";

const { action, createSignal, createMemo, createOptimistic, createRenderEffect, createRoot, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const reports = {};
const initialSource = Number(process.argv[3] ?? 0);

for (const answer of [null, 2, 5]) {
  const second = Promise.withResolvers();
  const finish = Promise.withResolvers();
  const calls = [], snapshots = [];
  const shown = {};
  let guess, setSource, dispose;
  createRoot(cleanup => {
    dispose = cleanup;
    const [source, write] = createSignal(initialSource);
    setSource = write;
    const [value, propose] = createOptimistic(source);
    guess = propose;
    const sum = createMemo((previous = 0) => {
      const input = value();
      const result = previous + input;
      calls.push({ previous, input, result });
      return result;
    });
    for (const [key, read] of Object.entries({ source, value, sum }))
      createRenderEffect(read, value => { shown[key] = value; }, { schedule: true });
  });
  flush();
  const snapshot = phase => snapshots.push({ phase, shown: { ...shown }, calls: calls.map(c => ({ ...c })) });
  snapshot("initial");
  const running = action(function* () {
    guess(1);
    yield second.promise;
    guess(2);
    yield finish.promise;
    if (answer !== null) setSource(answer);
  })();
  await turn();
  snapshot("guess 1 published");
  second.resolve();
  await turn();
  snapshot("guess 2 published");
  finish.resolve();
  await running;
  await turn();
  snapshot("action finished");
  dispose();
  flush();
  reports[answer === null ? "revert" : `answer-${answer}`] = snapshots;
}
console.log(JSON.stringify(reports, null, 2));
