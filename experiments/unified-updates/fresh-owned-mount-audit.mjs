// Compare creation-time holds with a Loading boundary below/around the producer.
// Usage: node fresh-owned-mount-audit.mjs /absolute/runtime/index.js [inside|outside]
import { pathToFileURL } from "node:url";
const { action, createLoadingBoundary, createMemo, createRenderEffect, createRoot,
  createSignal, flush } = await import(pathToFileURL(process.argv[2]));
const placement = process.argv[3] || "outside";
const end = Promise.withResolvers();
const shown = { input: 0, open: false, view: "closed" }, events = [], snapshots = [];
let start, open;
const dispose = createRoot(dispose => {
  const [x, setX] = createSignal(0), [visible, setVisible] = createSignal(false);
  open = () => setVisible(true);
  const branch = createMemo(() => {
    if (!visible()) return () => "closed";
    const producer = placement === "outside" ? createMemo(() => x()) : undefined;
    return createLoadingBoundary(() => {
      const value = producer || createMemo(() => x());
      createRenderEffect(value, value => { events.push(`child:${value}`); }, { schedule: true });
      return "content";
    }, () => "fallback");
  });
  createRenderEffect(x, value => { shown.input = value; }, { schedule: true });
  createRenderEffect(visible, value => { shown.open = value; }, { schedule: true });
  createRenderEffect(() => branch()(), value => { shown.view = value; }, { schedule: true });
  start = action(function* () { setX(1); yield end.promise; });
  return dispose;
});
const snapshot = phase => snapshots.push({ phase, shown: { ...shown }, events: [...events] });
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
flush(); snapshot("initial");
const running = start(); flush();
open(); flush(); await turn(); snapshot("mounted while input held");
end.resolve(); await running; await turn(); snapshot("released");
dispose(); flush();
console.log(JSON.stringify({ placement, snapshots }, null, 2));
