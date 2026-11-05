// Baseline audit of refresh invalidation versus equality filtering.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { createRoot, createSignal, createMemo, createOptimistic, createRenderEffect, refresh, flush } =
  await import(pathToFileURL(process.argv[2]));
const results = [];
for (const direct of [false, true]) {
  for (const doubleEqualsFalse of [false, true]) {
    for (const optEqualsFalse of [false, true]) {
      let dispose, opt;
      const runs = { doubled: 0, input: 0, downstream: 0, render: 0 };
      createRoot(d => {
        dispose = d;
        const [first] = createSignal(1);
        const doubled = createMemo(() => {
          runs.doubled++;
          return first() * 2;
        }, doubleEqualsFalse ? { equals: false } : undefined);
        [opt] = createOptimistic(direct ? doubled : () => {
          runs.input++;
          return doubled();
        }, optEqualsFalse ? { equals: false } : undefined);
        const downstream = createMemo(() => {
          runs.downstream++;
          return opt();
        });
        createRenderEffect(downstream, () => { runs.render++; }, { schedule: true });
      });
      flush();
      const before = { ...runs };
      const value = await refresh(opt);
      flush();
      const delta = Object.fromEntries(Object.keys(runs).map(k => [k, runs[k] - before[k]]));
      assert.equal(value, 2);
      assert.equal(delta.doubled, 0);
      assert.equal(delta.input, direct ? 0 : 1);
      assert.equal(delta.downstream, optEqualsFalse ? 1 : 0);
      assert.equal(delta.render, 0);
      results.push({ direct, doubleEqualsFalse, optEqualsFalse, value, delta });
      dispose();
      flush();
    }
  }
}
console.log(JSON.stringify(results, null, 2));
