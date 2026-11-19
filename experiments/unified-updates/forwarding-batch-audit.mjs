// The same ordinary program on pinned next, the production experiment and
// the reference adapter. No internal nodes or scheduler choreography.
import { pathToFileURL } from 'node:url';
const { action, createRoot, createOptimistic, createMemo, createRenderEffect, flush, isPending } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const answer = Promise.withResolvers(), end = Promise.withResolvers();
const shown = { first: 0, second: 0, pending: false }, checkpoints = [];
let guessFirst, guessSecond, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const [first, writeFirst] = createOptimistic(() => 0);
  const middle = createMemo(() => first() === 1 ? answer.promise : 0);
  const [second, writeSecond] = createOptimistic(middle);
  guessFirst = writeFirst; guessSecond = writeSecond;
  createRenderEffect(first, value => { shown.first = value; });
  createRenderEffect(second, value => { shown.second = value; });
  createRenderEffect(() => isPending(second), value => { shown.pending = value; });
});
const checkpoint = name => { flush(); checkpoints.push({ name, ...shown }); };
const running = action(function* () {
  guessFirst(1); guessSecond(2); yield end.promise;
})();
checkpoint('both guesses, action open');
end.resolve(); await running; await turn(); checkpoint('action body ended, middle unanswered');
answer.resolve(10); await turn(); checkpoint('middle answered');
dispose(); flush();
console.log(JSON.stringify(checkpoints, null, 2));
