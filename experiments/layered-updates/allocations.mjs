// V8 sampled allocation estimates, including objects collected during the run.
// These are estimates, not counts of JavaScript allocation expressions.
import { Session } from "node:inspector/promises";
import { writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";
const { createSignal, createMemo, createRoot, createRenderEffect, optimistic, action, flush } =
  await import(pathToFileURL(process.argv[2]));
const session = new Session();
session.connect();
const result = {};
let sink;
for (const scenario of ["ordinary", "inactive", "layer-1", "layer-4", "layer-16"]) {
  let dispose, write;
  createRoot(d => {
    dispose = d;
    const [source, setSource] = createSignal(0);
    write = setSource;
    let view = source;
    if (scenario === "inactive") optimistic(() => 0);
    if (scenario.startsWith("layer")) {
      for (let i = 0; i < Number(scenario.split("-")[1]); i++) {
        const input = view;
        const [next, guess] = optimistic(input);
        if (!i) write = guess;
        view = next;
      }
    }
    const derived = createMemo(() => view() * 2);
    createRenderEffect(derived, v => {
      sink = v;
    });
  });
  let finish, running;
  if (scenario.startsWith("layer")) {
    const end = new Promise(resolve => {
      finish = resolve;
    });
    running = action(function* () {
      write(1);
      yield end;
    })();
    flush();
  }
  let value = 0;
  const update = () => write(++value);
  for (let i = 0; i < 2000; i++) flush(update);
  global.gc();
  await session.post("HeapProfiler.startSampling", {
    samplingInterval: 1024,
    includeObjectsCollectedByMajorGC: true,
    includeObjectsCollectedByMinorGC: true
  });
  const count = 10_000;
  for (let i = 0; i < count; i++) flush(update);
  if (sink !== value * 2) throw new Error(`Incorrect ${scenario} result: ${sink}`);
  const { profile } = await session.post("HeapProfiler.stopSampling");
  if (process.env.ALLOCATION_PROFILE_DIR)
    writeFileSync(resolve(process.env.ALLOCATION_PROFILE_DIR, `${scenario}-allocations.json`), JSON.stringify(profile));
  function bytes(node) {
    return node.selfSize + node.children.reduce((sum, child) => sum + bytes(child), 0);
  }
  result[scenario] = bytes(profile.head) / count;
  if (finish) {
    finish();
    await running;
  }
  dispose();
}
session.disconnect();
console.log(JSON.stringify({ sampledAllocatedBytesPerWrite: result, sink }));
