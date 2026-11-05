// Read-only baseline audit: no experimental refresh export is implied.
import { pathToFileURL } from "node:url";
const { action, createRoot, createMemo, createOptimistic, createRenderEffect, flush, refresh } =
  await import(pathToFileURL(process.argv[2]));
const nested = process.argv.includes("--nested");
const nextStep = Promise.withResolvers(), finish = Promise.withResolvers(), firstEnd = Promise.withResolvers();
const tick = () => new Promise(resolve => setTimeout(resolve, 0));
let server = 0, inputRuns = 0, guessFirst, guessSecond, target, dispose;
const shown = { first: 0, second: null }, events = [];
let delivered = null;
createRoot(d => {
  dispose = d;
  const [first, write] = createOptimistic(() => { inputRuns++; return server; });
  guessFirst = write; target = first;
  createRenderEffect(first, value => { shown.first = value; }, { schedule: true });
  if (nested) {
    const doubled = createMemo(() => first() * 2);
    const [second, writeSecond] = createOptimistic(doubled);
    guessSecond = writeSecond; target = second;
    createRenderEffect(second, value => { shown.second = value; }, { schedule: true });
  }
});
flush();
let firstRunning;
if (nested) {
  firstRunning = action(function* () { guessFirst(1); yield firstEnd.promise; })();
  flush();
}
const running = action(function* () {
  if (nested) guessSecond(10); else guessFirst(1);
  yield nextStep.promise;
  server = 2;
  delivered = yield refresh(target);
  yield finish.promise;
})();
flush(); events.push({ phase: "guesses published", ...shown, delivered, inputRuns });
nextStep.resolve(); await tick(); flush(); await tick(); flush();
events.push({ phase: "refresh done; action open", ...shown, delivered, inputRuns });
finish.resolve(); await running; await tick(); flush();
events.push({ phase: "action done", ...shown, delivered, inputRuns });
firstEnd.resolve(); if (firstRunning) await firstRunning;
await tick(); flush();
events.push({ phase: "all actions done", ...shown, delivered, inputRuns });
dispose(); flush(); console.log(JSON.stringify({ nested, events }, null, 2));
