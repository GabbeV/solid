import { pathToFileURL } from "node:url";
import { performance } from "node:perf_hooks";
const { createSignal, createRoot, createRenderEffect, flush, latest } = await import(
  pathToFileURL(process.argv[2])
);
const [x, setX] = createSignal(1);
const callback = () => x();
let shown = 0,
  dispose;
createRoot(d => {
  dispose = d;
  createRenderEffect(
    () => latest(callback),
    value => {
      shown = value;
    }
  );
});
flush();
let checksum = 0;
const timings = {};
function measure(name, count, fn) {
  for (let i = 0; i < Math.min(count, 20000); i++) fn(i);
  global.gc?.();
  const start = performance.now();
  for (let i = 0; i < count; i++) fn(i);
  timings[name] = ((performance.now() - start) * 1e6) / count;
}
measure("ordinaryReadNs", 1000000, () => {
  checksum += x();
});
measure("directLatestNs", 500000, () => {
  checksum += latest(x);
});
measure("callbackLatestNs", 500000, () => {
  checksum += latest(callback);
});
measure("callbackObservedWriteNs", 30000, i => {
  setX(i);
  flush();
  checksum += shown;
});
dispose();
flush();
console.log(JSON.stringify({ timings, checksum }));
