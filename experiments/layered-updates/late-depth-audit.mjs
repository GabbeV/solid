import { pathToFileURL } from "node:url";
const { action, createRoot, createMemo, createOptimistic, createRenderEffect, flush } =
  await import(pathToFileURL(process.argv[2]));
const late = process.argv.includes("--late"), reverse = process.argv.includes("--reverse");
const lowerWork = Promise.withResolvers(), upperWork = Promise.withResolvers();
const lowerEnd = Promise.withResolvers(), upperEnd = Promise.withResolvers();
const tick = () => new Promise(resolve => setTimeout(resolve, 0));
const disposals = [], events = [], shown = { first: 0, second: 0, detail: 0, late: null };
let first, second, guessFirst, guessSecond;
createRoot(dispose => {
  disposals.push(dispose);
  [first, guessFirst] = createOptimistic(() => 0);
  const input = createMemo(() => first() ? lowerWork.promise : 0);
  [second, guessSecond] = createOptimistic(input);
  const detail = createMemo(() => second() ? upperWork.promise : 0);
  for (const [key, read] of Object.entries({ first, second, detail }))
    createRenderEffect(read, value => { shown[key] = value; }, { schedule: true });
});
flush();
const lower = action(function* () { guessFirst(1); yield lowerEnd.promise; })();
flush();
const upper = action(function* () { guessSecond(10); yield upperEnd.promise; })();
flush();
if (late) {
  createRoot(dispose => {
    disposals.push(dispose);
    const pair = createMemo(() => {
      if (reverse) { const b = second(); return `${first()}:${b}`; }
      const a = first(); return `${a}:${second()}`;
    });
    createRenderEffect(pair, value => { shown.late = value; }, { schedule: true });
  });
  flush();
}
events.push({ phase: "both proposals held", ...shown });
upperWork.resolve(10); await tick(); flush();
events.push({ phase: "upper ready; lower still pending", ...shown });
for (const dispose of disposals) dispose();
lowerWork.resolve(1); lowerEnd.resolve(); upperEnd.resolve();
await Promise.all([lower, upper]); await tick(); flush();
console.log(JSON.stringify({ late, reverse, events }, null, 2));
