// A guess written by a derivation of an already selected optimistic output.
// Usage: node ambient-nested-lifetime.mjs /absolute/path/to/runtime/index.js [action]
import { pathToFileURL } from "node:url";
const {
  action, createMemo, createOptimistic, createRenderEffect, createRoot,
  createSignal, flush
} = await import(pathToFileURL(process.argv[2]));
const response = Promise.withResolvers(), end = Promise.withResolvers();
const mode = process.argv[3] || "input";
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const shown = {}, snapshots = [], events = [];
let start;
const dispose = createRoot(dispose => {
  const [source, setSource] = createSignal(0);
  const truth = createMemo(() => mode === "action" ? 0 : source() ? end.promise : 0);
  const [first, guessFirst] = createOptimistic(truth);
  const [badge, guessBadge] = createOptimistic("base", { ownedWrite: true });
  const details = createMemo(() => first() ? response.promise : "none");
  const combined = createMemo(() => {
    const detail = details();
    if (detail === "ready") guessBadge("guess");
    return detail;
  });
  for (const [key, read] of Object.entries({ first, details: combined, badge }))
    createRenderEffect(read, value => {
      shown[key] = value;
      events.push({ key, value });
    }, { schedule: true });
  createRenderEffect(truth, () => {}, { schedule: true });
  start = mode === "action"
    ? action(function* () { guessFirst(1); yield end.promise; })
    : () => { setSource(1); guessFirst(1); };
  return dispose;
});
const snapshot = phase => snapshots.push({ phase, shown: { ...shown } });
flush(); snapshot("initial");
const running = start(); flush(); snapshot("details pending");
response.resolve("ready"); await turn(); snapshot("details ready, outer lifetime still open");
end.resolve(1); await running; await turn(); snapshot("outer lifetime ended");
dispose(); flush();
console.log(JSON.stringify({ mode, snapshots, events }, null, 2));
