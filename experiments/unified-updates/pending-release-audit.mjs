// Actual publications when pending-only observation does not retain a hold.
import { pathToFileURL } from "node:url";
const { createRoot, createSignal, createMemo, createRenderEffect, isPending, flush } =
  await import(pathToFileURL(process.argv[2]));
const wrapped = process.argv.includes("--wrapped");
const answer = Promise.withResolvers();
const changes = { id: [], pending: [], combined: [] };
const shown = {};
let set, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const [id, write] = createSignal(0);
  set = write;
  const data = createMemo(() => id() === 0 ? 0 : answer.promise);
  const pending = () => isPending(wrapped ? () => data() : data);
  const reads = { id, pending, combined: () => `${id()}:${pending()}` };
  for (const [key, read] of Object.entries(reads))
    createRenderEffect(read, value => {
      shown[key] = value;
      changes[key].push(value);
    }, { schedule: true });
});
flush();
set(1); flush();
const held = { ...shown };
answer.resolve(10);
await new Promise(resolve => setTimeout(resolve, 0));
console.log(JSON.stringify({ wrapped, held, settled: shown, changes }, null, 2));
dispose(); flush();
