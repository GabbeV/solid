import { pathToFileURL } from "node:url";
const { createSignal, createMemo, createRoot, createRenderEffect, flush } = await import(
  pathToFileURL(process.argv[2])
);
let sink = 0;
const timings = {};
function measure(name, count, run) {
  for (let warm = 0; warm < 3; warm++) run(count);
  global.gc();
  const start = performance.now();
  run(count);
  timings[name] = ((performance.now() - start) * 1e6) / count;
}
const [value, setValue] = createSignal(0);
measure("settled-read-ns", 2_000_000, n => {
  for (let i = 0; i < n; i++) sink += value();
});
measure("write-flush-ns", 100_000, n => {
  for (let i = 0; i < n; i++) {
    setValue(i);
    flush();
  }
});
measure("create-signal-ns", 200_000, n => {
  const nodes = [];
  for (let i = 0; i < n; i++) nodes.push(createSignal(i));
  sink += nodes.length;
});
for (const shape of ["chain", "diamond", "fanout"]) {
  let write, dispose;
  createRoot(d => {
    dispose = d;
    const [source, setter] = createSignal(0);
    write = setter;
    let final;
    if (shape === "chain") {
      final = source;
      for (let j = 0; j < 20; j++) {
        const previous = final;
        final = createMemo(() => previous() + 1);
      }
    } else if (shape === "diamond") {
      const left = createMemo(() => source() + 1),
        right = createMemo(() => source() * 2);
      final = createMemo(() => left() + right());
    } else {
      const leaves = Array.from({ length: 100 }, (_, j) => createMemo(() => source() + j));
      final = createMemo(() => leaves.reduce((sum, leaf) => sum + leaf(), 0));
    }
    createRenderEffect(final, v => {
      sink = v;
    });
  });
  measure(`${shape}-write-ns`, 20_000, n => {
    for (let i = 0; i < n; i++) {
      write(i);
      flush();
    }
  });
  dispose();
}
measure("create-memo-ns", 30_000, n => {
  createRoot(dispose => {
    for (let i = 0; i < n; i++) createMemo(() => value() + i);
    dispose();
  });
});
global.gc();
const before = process.memoryUsage().heapUsed;
const nodes = Array.from({ length: 100_000 }, (_, i) => createSignal(i));
global.gc();
const signalBytes = (process.memoryUsage().heapUsed - before) / nodes.length;
let memos, disposeMemos;
const readValue = () => value();
global.gc();
const beforeMemos = process.memoryUsage().heapUsed;
createRoot(dispose => {
  disposeMemos = dispose;
  memos = Array.from({ length: 100_000 }, () => createMemo(readValue));
});
global.gc();
const memoBytes = (process.memoryUsage().heapUsed - beforeMemos) / memos.length;
disposeMemos();
console.log(JSON.stringify({ timings, signalBytes, memoBytes, sink }));
