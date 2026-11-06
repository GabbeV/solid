import { pathToFileURL } from "node:url";
const { createSignal, createMemo, createRoot, createRenderEffect, flush } = await import(
  pathToFileURL(process.argv[2])
);
const events = [];
let write, dispose;
createRoot(d => {
  dispose = d;
  const [value, setValue] = createSignal(0);
  write = setValue;
  const derived = createMemo(() => value());
  createRenderEffect(derived, n => {
    events.push(`A:${n}`);
  });
  createRenderEffect(value, n => {
    events.push(`B:${n}`);
  });
});
flush();
const mount = events.splice(0);
write(1);
flush();
console.log(JSON.stringify({ mount, update: events }));
dispose();
flush();
