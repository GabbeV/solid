import { pathToFileURL } from "node:url";
const { createRoot, createMemo, createRenderEffect, flush } = await import(pathToFileURL(process.argv[2]));
const initial = Promise.withResolvers(), work = Promise.withResolvers();
const shown = { source: null, detail: null }, events = [];
let dispose;
createRoot(d => {
  dispose = d;
  const source = createMemo(() => initial.promise);
  const detail = createMemo(() => { const value = source(); return work.promise.then(() => value); });
  for (const [key, read] of Object.entries({ source, detail }))
    createRenderEffect(read, value => { shown[key] = value; }, { schedule: true });
});
flush(); events.push({ phase: 'initial', ...shown });
initial.resolve(1); await new Promise(r => setTimeout(r, 0)); flush();
events.push({ phase: 'source ready, detail pending', ...shown });
work.resolve(); await new Promise(r => setTimeout(r, 0)); flush();
events.push({ phase: 'detail ready', ...shown });
dispose(); flush(); console.log(JSON.stringify(events, null, 2));
