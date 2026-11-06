// Guarded audit: a memo creates and immediately reads a new async owned memo.
// The guard reports recreation rather than allowing an unbounded microtask loop.
import { pathToFileURL } from 'node:url';
const { createRoot, createMemo, createRenderEffect, flush } =
  await import(pathToFileURL(process.argv[2]));
const gate = Promise.withResolvers();
let creations = 0, shown = null, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const parent = createMemo(() => {
    if (++creations > 20) {
      console.log(JSON.stringify({ outcome: 'recreation guard', creations, shown }));
      process.exit(2);
    }
    const child = createMemo(() => gate.promise);
    return child();
  });
  createRenderEffect(parent, value => { shown = value; }, { schedule: true });
});
flush();
gate.resolve(7);
await new Promise(resolve => setTimeout(resolve, 0));
console.log(JSON.stringify({ outcome: 'settled', creations, shown }));
dispose(); flush();
