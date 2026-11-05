// Keep one unused optimistic output alive while the unchanged sync worker runs.
import { pathToFileURL } from "node:url";
const runtime = await import(pathToFileURL(process.argv[2]));
const disposeInactive = runtime.createRoot(dispose => {
  const [view] = runtime.optimistic(() => 0);
  runtime.createRenderEffect(view, () => {});
  return dispose;
});
await import("./sync-bench.mjs");
disposeInactive();
