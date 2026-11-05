// Compare both ends of a performance pass to the same pinned next bundle.
// Each sample rotates process order. The pre-pass bundle is a validated
// checkpoint, not an alternative implementation used as the baseline.
import { execFileSync } from "node:child_process";
import { createHash } from "node:crypto";
import { readFileSync, writeFileSync } from "node:fs";
import { cpus } from "node:os";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const [output, ...paths] = process.argv.slice(2);
if (paths.length !== 3) throw new Error("Usage: output.json next.mjs pre-pass.mjs candidate.mjs");
const bundles = paths.map((path, index) => ({
  name: ["next", "pre-pass", "candidate"][index],
  path: resolve(path),
  sha256: createHash("sha256").update(readFileSync(path)).digest("hex")
}));
const worker = process.env.PERF_WORKER
  ? resolve(process.env.PERF_WORKER)
  : resolve(here, "optimistic-bench.mjs");
const samples = Number(process.env.PERF_SAMPLES || 7);
const median = values => values.toSorted((a, b) => a - b)[Math.floor(values.length / 2)];
const runs = [];
for (let sample = 0; sample < samples; sample++) {
  const order = sample % 2 ? [...bundles].reverse() : [...bundles];
  const shift = Math.floor(sample / 2) % order.length;
  order.push(...order.splice(0, shift));
  for (const bundle of order) {
    const args = ["--expose-gc", worker, bundle.path];
    if (process.env.PERF_CASE) args.push(process.env.PERF_CASE);
    const result = JSON.parse(execFileSync(process.execPath,
      args, { encoding: "utf8" }));
    runs.push({ sample, name: bundle.name, ...result,
      timings: result.timings ?? { [result.scenario]: result.ns } });
  }
}
const summaries = Object.keys(runs[0].timings).map(scenario => ({
  scenario,
  variants: bundles.map(({ name }) => {
    const values = runs.filter(r => r.name === name).map(r => r.timings[scenario]);
    return { name, median: median(values), min: Math.min(...values), max: Math.max(...values),
      ratioToNext: median(Array.from({ length: samples }, (_, sample) =>
        runs.find(r => r.sample === sample && r.name === name).timings[scenario] /
        runs.find(r => r.sample === sample && r.name === "next").timings[scenario])) };
  })
}));
const memory = [];
for (let sample = 0; sample < Number(process.env.MEMORY_SAMPLES || 5); sample++) {
  const order = [bundles[0], bundles[2]];
  if (sample % 2) order.reverse();
  for (const bundle of order) memory.push({ sample, name: bundle.name,
    ...JSON.parse(execFileSync(process.execPath,
      ["--expose-gc", resolve(here, "memory.mjs"), bundle.path], { encoding: "utf8" })) });
}
writeFileSync(output, JSON.stringify({ node: process.version, cpu: cpus()[0].model,
  scenario: process.env.PERF_CASE ?? null,
  workerSha256: createHash("sha256").update(readFileSync(worker)).digest("hex"),
  memoryWorkerSha256: createHash("sha256").update(readFileSync(resolve(here, "memory.mjs"))).digest("hex"),
  bundles, runs, summaries, memory }, null, 2));
for (const summary of summaries) console.log(JSON.stringify(summary));
