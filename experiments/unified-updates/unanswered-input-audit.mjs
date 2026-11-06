import { pathToFileURL } from 'node:url';
const { action, createRoot, createSignal, createOptimistic, createMemo, createRenderEffect, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const answer = Promise.withResolvers(), endFirst = Promise.withResolvers(), endSecond = Promise.withResolvers();
const shown = { first: 0, second: 0 }, checkpoints = [];
let guessFirst, guessSecond, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const [source] = createSignal(0);
  const [first, writeFirst] = createOptimistic(source);
  const middle = createMemo(() => first() === 0 ? 0 : answer.promise);
  const [second, writeSecond] = createOptimistic(middle);
  guessFirst = writeFirst; guessSecond = writeSecond;
  createRenderEffect(first, value => { shown.first = value; });
  createRenderEffect(second, value => { shown.second = value; });
});
const checkpoint = name => { flush(); checkpoints.push({ name, ...shown }); };
const first = action(function* () { guessFirst(1); yield endFirst.promise; })(); checkpoint('first guess, middle unresolved');
const second = action(function* () { guessSecond(3); yield endSecond.promise; })(); checkpoint('second guess, both actions open');
answer.resolve(2); await turn(); checkpoint('middle answers 2, both actions open');
endSecond.resolve(); await second; await turn(); checkpoint('child action ended, parent action open');
endFirst.resolve(); await first; await turn(); checkpoint('both ended');
dispose(); flush();
console.log(JSON.stringify(checkpoints, null, 2));
