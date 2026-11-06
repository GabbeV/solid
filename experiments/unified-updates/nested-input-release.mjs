// Characterization: an input flight caused by another guess in the same action.
import { pathToFileURL } from "node:url";
const { action, createMemo, createOptimistic, createRenderEffect,
  createRoot, flush, isPending } = await import(pathToFileURL(process.argv[2]));
const gate = () => {
  let resolve;
  const promise = new Promise(yes => { resolve = yes; });
  return { promise, resolve };
};
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const end = gate(), answer = gate();
let guessFirst, guessSecond, dispose;
const shown = { first: 0, second: 0, pending: false };
const calculated = [];
createRoot(d => {
  dispose = d;
  const [first, g1] = createOptimistic(() => 0);
  const input = createMemo(() => {
    const value = first();
    calculated.push(value);
    return value === 1 ? answer.promise : 0;
  });
  const [second, g2] = createOptimistic(input);
  guessFirst = g1;
  guessSecond = g2;
  createRenderEffect(first, value => { shown.first = value; });
  createRenderEffect(second, value => { shown.second = value; });
  createRenderEffect(() => isPending(second), value => { shown.pending = value; });
});
flush();
const frames = [{ event: "initial", ...shown }];
const running = action(function* () {
  guessFirst(1);
  guessSecond(2);
  yield end.promise;
})();
flush();
frames.push({ event: "guesses", ...shown });
end.resolve();
await running;
await turn();
frames.push({ event: "body ends", ...shown });
answer.resolve(10);
await turn();
frames.push({ event: "old input resolves", ...shown });
dispose();
flush();
console.log(JSON.stringify({ frames, calculated }));
