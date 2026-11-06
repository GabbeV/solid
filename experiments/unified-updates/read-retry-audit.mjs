// Run one bounded public-API timeline against an actual production entry.
// Separate processes prevent one implementation's global hooks affecting another.
import { pathToFileURL } from "node:url";
const api = await import(pathToFileURL(process.argv[2]));
const kind = process.argv[3] ?? "isPending";
const asynchronous = process.argv[4] === "async";
const depth = Number(process.argv[5] ?? 1);
const { action, createMemo, createRoot, createRenderEffect, createSignal, flush, onCleanup } = api;
const observe = api[kind];
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const end = Promise.withResolvers();
const [source, write] = createSignal(0);
const bodies = [],
  frames = [],
  owners = [];
let attempts = 0,
  dispose = () => {};
const running = action(function* () {
  write(1);
  yield end.promise;
})();
flush();
const child = remaining => {
  if (!remaining) return observe(source);
  return createMemo(() => {
    const owner = { cleanups: 0 };
    owners.push(owner);
    onCleanup(() => owner.cleanups++);
    return child(remaining - 1);
  })();
};
let report;
try {
  createRoot(cleanup => {
    dispose = cleanup;
    const calculate = () => {
      if (++attempts > 32) {
        dispose();
        return [];
      }
      const first = source();
      const observed = child(depth);
      const last = source();
      const result = [first, observed, last];
      bodies.push(result);
      return result;
    };
    const value = createMemo(asynchronous ? async () => calculate() : calculate);
    createRenderEffect(
      value,
      result => {
        frames.push(result);
      },
      { schedule: true }
    );
  });
  await turn();
  flush();
  report = {
    kind,
    asynchronous,
    depth,
    attempts,
    boundedStop: attempts > 32,
    bodies: [...new Set(bodies.map(JSON.stringify))].map(JSON.parse),
    frames
  };
} finally {
  dispose();
  end.resolve();
  await running;
  await turn();
  flush();
}
report.ownersCreated = owners.length;
report.ownersCleanedOnce = owners.every(owner => owner.cleanups === 1);
console.log(JSON.stringify(report));
