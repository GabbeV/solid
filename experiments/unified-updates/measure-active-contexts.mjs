// Actual public APIs: every boundary has a live override, with no async memo.
import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { resolve } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
const script = fileURLToPath(import.meta.url);
if (process.argv[2] === "--worker") {
  const { action, optimistic, createMemo, createRenderEffect, createRoot, flush } =
    await import(pathToFileURL(process.argv[3]));
  const timings = {};
  for (const depth of [1, 4, 16]) {
    let dispose, value = 100;
    const writes = [], shown = [];
    createRoot(cleanup => {
      dispose = cleanup;
      let input = () => 0;
      for (let i = 0; i < depth; i++) {
        const [view, guess] = optimistic(input);
        writes.push(guess);
        createRenderEffect(view, next => { shown[i] = next; }, { schedule: true });
        input = createMemo(() => view() + 1);
      }
    });
    flush(); // Complete the initial scheduled mount before simulating actions.
    const end = Promise.withResolvers();
    // Reveal each input before overriding its child. Replacing an input under
    // an already selected override intentionally couples to that action's
    // lifetime; it is a different publication workload from next.
    const running = [];
    for (let i = 0; i < depth; i++) {
      running.push(action(function* () { writes[i](value + i); yield end.promise; })());
      flush();
    }
    assert.deepEqual(shown, Array.from({ length: depth }, (_, i) => value + i));
    const write = () => {
      value++;
      writes[depth - 1](value + depth - 1);
    };
    const run = count => { for (let i = 0; i < count; i++) flush(write); };
    for (let i = 0; i < 3; i++) run(5000);
    global.gc();
    const start = performance.now(); run(20000);
    timings[`depth-${depth}-top`] = (performance.now() - start) * 1e6 / 20000;
    assert.deepEqual(shown, Array.from({ length: depth }, (_, i) =>
      (i === depth - 1 ? value : 100) + i));
    dispose(); end.resolve(); await Promise.all(running); flush();
  }
  console.log(JSON.stringify(timings));
} else {
  const out = resolve(process.argv[2]), runs = [];
  const median = xs => xs.toSorted((a, b) => a - b)[Math.floor(xs.length / 2)];
  for (let sample = 0; sample < 3; sample++)
    for (const name of sample % 2 ? ["candidate", "baseline"] : ["baseline", "candidate"]) {
      const timings = JSON.parse(execFileSync(process.execPath,
        ["--expose-gc", script, "--worker", resolve(out, `${name}-optimistic.mjs`)], { encoding: "utf8" }));
      runs.push({ sample, name, timings });
    }
  const summaries = Object.keys(runs[0].timings).map(scenario => ({
    scenario,
    baseline: median(runs.filter(r => r.name === "baseline").map(r => r.timings[scenario])),
    candidate: median(runs.filter(r => r.name === "candidate").map(r => r.timings[scenario])),
    pairedRatio: median(Array.from({ length: 3 }, (_, sample) =>
      runs.find(r => r.sample === sample && r.name === "candidate").timings[scenario] /
      runs.find(r => r.sample === sample && r.name === "baseline").timings[scenario]))
  }));
  writeFileSync(resolve(out, "active-contexts.json"), JSON.stringify({ node: process.version,
    workerSha256: createHash("sha256").update(readFileSync(script)).digest("hex"), runs, summaries }, null, 2));
  for (const summary of summaries) console.log(JSON.stringify(summary));
}
