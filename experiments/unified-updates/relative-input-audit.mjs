// Run the conditional-input timeline through each runtime's scalar accessors.
import { pathToFileURL } from 'node:url';
const { action, createRoot, createSignal, createOptimistic, createMemo, createRenderEffect, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const endA = Promise.withResolvers(), endB = Promise.withResolvers(), endC = Promise.withResolvers();
const hold = Promise.withResolvers();
const shown = {}, frames = [], checkpoints = [];
let guessA, guessB, guessC, setBranch, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const [source] = createSignal(0), [branch, writeBranch] = createSignal(false);
  const [a, writeA] = createOptimistic(source), [b, writeB] = createOptimistic(a);
  const input = createMemo(() => branch() ? b() : 0);
  const [c, writeC] = createOptimistic(input);
  const doubled = createMemo(() => 2 * c()), pair = createMemo(() => c() + b());
  const holdB = createMemo(() => b() === 2 ? hold.promise : b());
  [guessA, guessB, guessC, setBranch] = [writeA, writeB, writeC, writeBranch];
  for (const [name, read] of Object.entries({ branch, a, b, input, c, doubled, pair, holdB }))
    createRenderEffect(read, value => { shown[name] = value; frames.push({ ...shown }); });
});
const checkpoint = name => { flush(); checkpoints.push({ name, ...shown }); };
const a = action(function* () { guessA(1); yield endA.promise; })(); checkpoint('a revealed');
const b = action(function* () { guessB(2); yield endB.promise; })(); checkpoint('b held');
setBranch(true); checkpoint('input switches branch');
const c = action(function* () { guessC(10); yield endC.promise; })(); checkpoint('child override');
hold.resolve(2); await turn(); checkpoint('input work ready, child action open');
endC.resolve(); await c; await turn(); checkpoint('child action ended');
endB.resolve(); endA.resolve(); await Promise.all([a, b]); await turn(); checkpoint('all ended');
dispose(); flush();
console.log(JSON.stringify({ checkpoints, frames }, null, 2));
