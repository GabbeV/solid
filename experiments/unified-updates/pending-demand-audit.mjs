import { pathToFileURL } from "node:url";

const {
  createRoot, createSignal, createMemo, createRenderEffect,
  createLoadingBoundary, isPending, flush
} = await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const mode = process.argv[3] || "guard";
const request = Promise.withResolvers();
const shown = {}, frames = [], snapshots = [];
let set, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const [id, setId] = createSignal(0);
  set = setId;
  const data = createMemo(() => {
    const value = id();
    return value === 0 ? "Item 0" : request.promise.then(() => `Item ${value}`);
  });
  const bindings = { id };
  if (mode === "guard" || mode === "guard-callback")
    bindings.disabled = () => isPending(mode === "guard" ? data : () => data());
  else {
    bindings.content = createLoadingBoundary(data, () => "Loading…", {
      on: () => isPending(data)
    });
    if (mode === "loading-guard") bindings.disabled = () => isPending(data);
  }
  for (const [key, read] of Object.entries(bindings)) {
    createRenderEffect(read, value => {
      shown[key] = value;
      frames.push({ key, value });
    }, { schedule: true });
  }
});
const snapshot = phase => snapshots.push({ phase, shown: { ...shown } });
flush(); snapshot("initial");
set(1); flush(); await turn(); snapshot("request held");
request.resolve(); await turn(); snapshot("request resolved");
dispose(); flush();
console.log(JSON.stringify({ mode, snapshots, frames }, null, 2));
