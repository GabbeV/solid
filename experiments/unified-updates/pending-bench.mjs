import { pathToFileURL } from "node:url";
const { createSignal, createMemo, createRoot, createRenderEffect, pending, action, flush } =
  await import(pathToFileURL(process.argv[2]));
const timings = {};
let sink = 0;
function measure(name, count, run) {
  for (let i = 0; i < 3; i++) run(count);
  global.gc();
  const start = performance.now();
  run(count);
  timings[name] = ((performance.now() - start) * 1e6) / count;
}
let inactiveDispose;
createRoot(d => {
  inactiveDispose = d;
  const p = pending(() => 0);
  createRenderEffect(p, () => {});
});
flush();
const [plain, setPlain] = createSignal(0);
measure("inactive-read-ns", 2_000_000, n => {
  for (let i = 0; i < n; i++) sink += plain();
});
measure("inactive-write-ns", 100_000, n => {
  for (let i = 0; i < n; i++) {
    setPlain(i);
    flush();
  }
});
inactiveDispose();

let watchedDispose, setWatched;
createRoot(dispose => {
  watchedDispose = dispose;
  const [watched, write] = createSignal(0);
  setWatched = write;
  const status = pending(watched);
  createRenderEffect(status, value => {
    sink = Number(value);
  });
});
flush();
measure("observed-sync-write-ns", 100_000, n => {
  for (let i = 0; i < n; i++) {
    setWatched(i);
    flush();
  }
});
watchedDispose();

for (const depth of [1, 4, 16]) {
  let setX, setTick, finish, dispose;
  createRoot(d => {
    dispose = d;
    const [x, writeX] = createSignal(0),
      [tick, writeTick] = createSignal(0);
    setX = writeX;
    setTick = writeTick;
    const p = pending(x);
    let last = createMemo(() => tick() + (p() ? 1 : 0) + x());
    for (let i = 1; i < depth; i++) {
      const previous = last;
      last = createMemo(() => previous() + x());
    }
    createRenderEffect(last, v => {
      sink = v;
    });
  });
  flush();
  const end = new Promise(resolve => {
    finish = resolve;
  });
  const running = action(function* () {
    setX(1);
    yield end;
  })();
  flush();
  measure(`held-input-depth-${depth}-ns`, 10_000, n => {
    for (let i = 0; i < n; i++) {
      setTick(i);
      flush();
    }
  });
  finish();
  await running;
  flush();
  dispose();
}
console.log(JSON.stringify({ timings, sink }));
