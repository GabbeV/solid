// Compare pending's optimistic publication with an explicit boolean override.
// The explicit lifetime variants are intentionally distinct and reported.
import { pathToFileURL } from "node:url";
const {
  action, createRoot, createSignal, createMemo, createOptimistic,
  createRenderEffect, createLoadingBoundary, isPending, flush
} = await import(pathToFileURL(process.argv[2]));
const scenario = process.argv[3] || "feedback";
const mode = process.argv[4] || "pending";
const order = process.argv[5] || "count-first";
const request = Promise.withResolvers();
const shown = {}, calls = [], frames = [], snapshots = [];
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
let write, guess, dispose, running;
createRoot(cleanup => {
  dispose = cleanup;
  const [count, setCount] = createSignal(0);
  write = setCount;
  let pending;
  const data = createMemo(() => {
    let value, status;
    if (scenario === "feedback" && order === "pending-first") status = pending();
    value = count();
    if (scenario === "feedback" && order === "count-first") status = pending();
    calls.push({ value, status });
    return value === 0 ? 0 : request.promise.then(() => value * 10);
  }, { lazy: true });
  const input = scenario === "feedback" ? count : data;
  if (mode === "pending") pending = () => isPending(input);
  else [pending, guess] = createOptimistic(() => {
    input();
    return false;
  });
  const bindings = scenario === "loading" ? { count } : { count, pending };
  if (scenario === "feedback") bindings.data = data;
  if (scenario === "loading") bindings.content = createLoadingBoundary(
    data, () => "Loading…", { on: pending }
  );
  for (const [key, read] of Object.entries(bindings))
    createRenderEffect(read, value => {
      shown[key] = value;
      frames.push({ key, value });
    }, { schedule: true });
});
const snapshot = phase => snapshots.push({ phase, shown: { ...shown }, calls: [...calls] });
flush(); snapshot("initial");
if (mode === "pending") write(1);
else running = action(function* () {
  write(1);
  guess(true);
  if (mode === "explicit-external") yield request.promise;
})();
flush(); await turn(); snapshot("request held");
request.resolve();
await running;
await turn(); snapshot("request resolved");
dispose(); flush();
console.log(JSON.stringify({ scenario, mode, order, snapshots, frames }, null, 2));
