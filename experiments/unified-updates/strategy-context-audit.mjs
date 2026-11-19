// Architecture audit: a disjoint pending observer must not choose the read
// context of this newly mounted computation. Run each mode in a fresh process.
// Usage: node strategy-context-audit.mjs ENTRY [none|same|disjoint|unobserved|idle]
import { pathToFileURL } from "node:url";

const {
  createRoot, createSignal, createMemo, createRenderEffect, action, flush, isPending
} = await import(pathToFileURL(process.argv[2]));
const mode = process.argv[3] || "none";
if (!["none", "same", "disjoint", "unobserved", "idle"].includes(mode))
  throw new Error(`Unknown mode: ${mode}`);
const end = Promise.withResolvers();
const [x, setX] = createSignal(0);
const [y, setY] = createSignal(0);
let disposeObserver, disposeLate;
let display = "waiting", status = "absent";
createRoot(dispose => {
  disposeObserver = dispose;
  if (mode === "same" || mode === "disjoint" || mode === "idle") {
    createRenderEffect(() => isPending(mode === "same" ? x : y), value => {
      status = String(value);
    });
  }
});
flush();

const otherRunning = mode === "disjoint" || mode === "unobserved"
  ? action(function* () { setY(1); yield end.promise; })()
  : Promise.resolve();
flush();
const running = action(function* () { setX(1); yield end.promise; })();
flush();

createRoot(dispose => {
  disposeLate = dispose;
  const text = createMemo(() => {
    const value = x();
    return value === 0 ? `${isPending(x)}:${value}` : `value:${value}`;
  });
  createRenderEffect(text, value => { display = value; }, { schedule: true });
});
flush();
const frames = [{ phase: "held", x: x(), display, status }];
end.resolve();
await Promise.all([running, otherRunning]);
await new Promise(resolve => setTimeout(resolve, 0));
frames.push({ phase: "released", x: x(), display, status });
disposeLate();
disposeObserver();
flush();
console.log(JSON.stringify({ mode, frames }, null, 2));
