// Equality filtering with observable ownership checks, using production bundles.
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
const script = fileURLToPath(import.meta.url);
if (process.argv[2] === "--worker") {
  const { action, optimistic, createMemo, createRoot, createRenderEffect, flush } = await import(
    pathToFileURL(process.argv[3])
  );
  let dispose,
    guess,
    runs = 0,
    value = 1,
    shown = -1;
  createRoot(d => {
    dispose = d;
    const [view, write] = optimistic(() => 0);
    guess = write;
    const parity = createMemo(() => view() % 2);
    for (let i = 0; i < 100; i++) {
      const child = createMemo(() => {
        runs++;
        return parity() + i;
      });
      createRenderEffect(child, () => {}, { schedule: true });
    }
    createRenderEffect(
      view,
      next => {
        shown = next;
      },
      { schedule: true }
    );
  });
  flush();
  // Publish a changed guess before measuring repeated writes. Next does not
  // retain the same outside-action setter lifetime for an equal initial guess.
  const end = Promise.withResolvers();
  const running = action(function* () {
    guess(1);
    yield end.promise;
  })();
  flush();
  const write = () => guess((value += 2));
  const run = n => {
    for (let i = 0; i < n; i++) flush(write);
  };
  for (let i = 0; i < 3; i++) run(5000);
  global.gc();
  const before = performance.now();
  run(30000);
  const ns = ((performance.now() - before) * 1e6) / 30000;
  assert.equal(runs, 200);
  assert.equal(shown, value);
  dispose();
  end.resolve();
  await running;
  flush();
  console.log(JSON.stringify({ ns, runs }));
} else {
  const out = resolve(process.argv[2]),
    runs = [];
  const median = xs => xs.toSorted((a, b) => a - b)[Math.floor(xs.length / 2)];
  for (let sample = 0; sample < 5; sample++)
    for (const name of sample % 2 ? ["candidate", "baseline"] : ["baseline", "candidate"]) {
      const result = JSON.parse(
        execFileSync(
          process.execPath,
          ["--expose-gc", script, "--worker", resolve(out, `${name}-optimistic.mjs`)],
          { encoding: "utf8" }
        )
      );
      runs.push({ sample, name, ...result });
    }
  const summary = {
    baseline: median(runs.filter(r => r.name === "baseline").map(r => r.ns)),
    candidate: median(runs.filter(r => r.name === "candidate").map(r => r.ns)),
    pairedRatio: median(
      Array.from(
        { length: 5 },
        (_, sample) =>
          runs.find(r => r.name === "candidate" && r.sample === sample).ns /
          runs.find(r => r.name === "baseline" && r.sample === sample).ns
      )
    )
  };
  writeFileSync(
    resolve(out, "equality-stop.json"),
    JSON.stringify({ node: process.version, runs, summary }, null, 2)
  );
  console.log(JSON.stringify(summary));
}
