import { pathToFileURL } from "node:url";
const {
  createSignal,
  createRoot,
  createMemo,
  createRenderEffect,
  createLoadingBoundary,
  action,
  flush,
  latest,
  isPending
} = await import(pathToFileURL(process.argv[2]));
let finish, answer, dispose;
const end = new Promise(r => {
  finish = r;
});
const work = new Promise(r => {
  answer = r;
});
const [count, setCount] = createSignal(0);
const frames = [],
  calculated = [];
const observe = process.argv[3] === "pending" ? () => isPending(count) : () => latest(count);
if (process.argv.includes("--revive")) {
  const cleanup = createRoot(d => {
    createRenderEffect(observe, () => {});
    return d;
  });
  flush();
  cleanup();
  flush();
}
const running = action(function* () {
  setCount(1);
  yield end;
})();
flush();
createRoot(d => {
  dispose = d;
  const details = createMemo(() => {
    const n = observe();
    calculated.push(n);
    return !n ? "cached 0" : work;
  });
  const content = createLoadingBoundary(details, () => "loading");
  createRenderEffect(
    content,
    value => {
      frames.push(value);
    },
    { schedule: true }
  );
});
flush();
console.log(
  JSON.stringify({ event: "mount while action open", count: count(), calculated, frames })
);
answer("loaded 1");
await new Promise(r => setTimeout(r, 0));
console.log(
  JSON.stringify({ event: "details ready, action still open", count: count(), calculated, frames })
);
finish();
await running;
await new Promise(r => setTimeout(r, 0));
console.log(JSON.stringify({ event: "action ends", count: count(), calculated, frames }));
dispose();
flush();
