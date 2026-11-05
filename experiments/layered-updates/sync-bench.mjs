// One wholly synchronous workload per process. No action, pending or optimism.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { createSignal, createMemo, createRoot, createRenderEffect, flush } = await import(
  pathToFileURL(process.argv[2])
);
const scenario = process.argv[3];
const [source, setSource] = createSignal(1);
let sink = 0,
  sequence = 1,
  dispose = () => {},
  verify = () => {};
let run;
if (scenario === "signal-read" || scenario === "memo-read") {
  let read = source;
  if (scenario === "memo-read")
    createRoot(d => {
      dispose = d;
      read = createMemo(() => source() + 1);
    });
  run = n => {
    for (let i = 0; i < n; i++) sink += read();
  };
  verify = () => assert.equal(read(), scenario === "signal-read" ? 1 : 2);
} else if (scenario === "signal-create") {
  run = n => {
    // Bound retained heap; include natural GC instead of growing one giant array.
    for (let start = 0; start < n; start += 2048) {
      const nodes = [];
      for (let i = start; i < Math.min(start + 2048, n); i++) nodes.push(createSignal(i));
      sink += nodes.at(-1)[0]();
    }
  };
} else if (scenario === "memo-create-dispose") {
  const calculate = () => source() + 1;
  run = n => {
    for (let start = 0; start < n; start += 2048)
      createRoot(d => {
        let last;
        for (let i = start; i < Math.min(start + 2048, n); i++) last = createMemo(calculate);
        sink += last();
        d();
      });
  };
} else {
  let shown = 0,
    output = source,
    writes = 1,
    renders = 0;
  const leaves = [];
  createRoot(d => {
    dispose = d;
    if (scenario === "memo-write" || scenario === "equal-write") {
      output = createMemo(() => source() + 1);
    } else if (scenario === "chain") {
      for (let i = 0; i < 20; i++) {
        const previous = output;
        output = createMemo(() => previous() + 1);
      }
    } else if (scenario === "diamond") {
      const left = createMemo(() => source() + 1);
      const right = createMemo(() => source() * 2);
      output = createMemo(() => left() + right());
    } else if (scenario === "fanout-memos") {
      for (let i = 0; i < 100; i++) leaves.push(createMemo(() => source() + i));
      output = createMemo(() => leaves.reduce((sum, leaf) => sum + leaf(), 0));
    } else if (scenario === "fanout-effects") {
      for (let i = 0; i < 100; i++)
        createRenderEffect(
          () => source() + i,
          value => {
            leaves[i] = value;
          }
        );
    } else if (scenario === "branch-switch") {
      const [left] = createSignal(1),
        [right] = createSignal(2);
      output = createMemo(() => (source() % 2 ? left() : right()));
    } else if (scenario === "batch-10-writes") {
      writes = 10;
      output = createMemo(() => source() + 1);
    } else assert.equal(scenario, "write-flush");
    createRenderEffect(output, value => {
      shown = value;
      renders++;
    });
  });
  flush();
  const update =
    scenario === "equal-write"
      ? () => setSource(1)
      : () => {
          for (let j = 0; j < writes; j++) setSource(++sequence);
        };
  // This public synchronous scope suppresses microtask scheduling. Repeated
  // set(); flush() would queue a microtask per iteration until this loop exits.
  run = n => {
    for (let i = 0; i < n; i++) flush(update);
  };
  verify = () => {
    const expected =
      scenario === "chain"
        ? sequence + 20
        : scenario === "diamond"
          ? sequence * 3 + 1
          : scenario === "fanout-memos"
            ? sequence * 100 + 4950
            : scenario === "branch-switch"
              ? sequence % 2
                ? 1
                : 2
              : ["memo-write", "equal-write", "batch-10-writes"].includes(scenario)
                ? sequence + 1
                : sequence;
    assert.equal(shown, expected);
    if (scenario === "equal-write") assert.equal(renders, 1);
    if (scenario === "fanout-effects")
      assert.deepEqual(
        leaves,
        Array.from({ length: 100 }, (_, i) => sequence + i)
      );
    sink = shown;
  };
}

// Calibrate after warmup, then retain all five within-process measurements.
let count = scenario.includes("read") ? 100_000 : 1_000;
for (let i = 0; i < 4; i++) {
  const start = performance.now();
  run(count);
  const elapsed = performance.now() - start;
  count = Math.min(8_000_000, Math.max(100, Math.round((count * 40) / Math.max(1, elapsed))));
}
verify();
global.gc();
const samples = [];
for (let i = 0; i < 5; i++) {
  const start = performance.now();
  run(count);
  samples.push(((performance.now() - start) * 1e6) / count);
  verify();
}
dispose();
console.log(
  JSON.stringify({ scenario, count, samples, ns: [...samples].sort((a, b) => a - b)[2], sink })
);
