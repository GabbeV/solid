// Compare the queue deletion with the immediately preceding prototype and next.
// Each workload/runtime/sample runs in a fresh process. Do not run beside tests.
import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { cpus } from "node:os";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
const here = dirname(fileURLToPath(import.meta.url));
const out = resolve(here, "results/scalar-queues-stage36");
const worker = resolve(here, "sync-bench.mjs");
const runtimes = {
  baseline: resolve(out, "baseline-ordinary.mjs"),
  previous: resolve(here, "results/stream-publication-stage35/candidate-ordinary.mjs"),
  candidate: resolve(out, "candidate-ordinary.mjs")
};
const scenarios = process.env.SYNC_CASES?.split(",") || [
  "signal-read", "memo-read", "write-flush", "equal-write", "memo-write",
  "batch-10-writes", "chain", "diamond", "fanout-memos", "fanout-effects",
  "branch-switch", "signal-create", "memo-create-dispose"
];
const sampleCount = Number(process.env.SYNC_SAMPLES || 7);
const median = values => [...values].sort((a,b) => a-b)[Math.floor(values.length / 2)];
const metadata = {
  node: process.version, cpu: cpus()[0].model, sampleCount,
  workerSha256: createHash("sha256").update(readFileSync(worker)).digest("hex"),
  bundles: Object.fromEntries(Object.entries(runtimes).map(([name, path]) => [name, {
    path, sha256: createHash("sha256").update(readFileSync(path)).digest("hex")
  }]))
};
const runs = [], summaries = [];
for (const scenario of scenarios) {
  for (let sample = 0; sample < sampleCount; sample++) {
    const names = Object.keys(runtimes);
    const order = [...names.slice(sample % 3), ...names.slice(0, sample % 3)];
    if (sample % 2) order.reverse();
    for (const name of order) {
      const run = JSON.parse(execFileSync(process.execPath,
        ["--expose-gc", worker, runtimes[name], scenario], { encoding: "utf8" }));
      runs.push({ name, sample, ...run });
    }
  }
  const selected = runs.filter(run => run.scenario === scenario);
  const summary = { scenario };
  for (const name of Object.keys(runtimes)) {
    const values = selected.filter(run => run.name === name).map(run => run.ns);
    summary[name] = { median: median(values), min: Math.min(...values), max: Math.max(...values) };
  }
  for (const comparison of ["previous", "baseline"]) {
    const ratios = Array.from({ length: sampleCount }, (_, sample) =>
      selected.find(run => run.name === "candidate" && run.sample === sample).ns /
      selected.find(run => run.name === comparison && run.sample === sample).ns);
    summary[`pairedRatioTo${comparison}`] = median(ratios);
  }
  summaries.push(summary);
  writeFileSync(resolve(out, "performance.json"), JSON.stringify({ ...metadata, runs, summaries }, null, 2));
  console.log(JSON.stringify(summary));
}
