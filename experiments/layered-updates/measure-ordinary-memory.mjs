import { execFileSync } from "node:child_process";
import { readFileSync, writeFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
const here = dirname(fileURLToPath(import.meta.url));
const out = resolve(process.argv[2]);
const worker = resolve(here, "ordinary-memory.mjs"), runs = [];
const median = values => values.toSorted((a, b) => a - b)[Math.floor(values.length / 2)];
for (let sample = 0; sample < 5; sample++) {
  for (const name of sample % 2 ? ["candidate", "baseline"] : ["baseline", "candidate"]) {
    const result = JSON.parse(execFileSync(process.execPath,
      ["--expose-gc", worker, resolve(out, `${name}-ordinary.mjs`)], { encoding: "utf8" }));
    runs.push({ sample, name, ...result });
  }
}
const summaries = ["signalBytes", "memoBytes"].map(scenario => ({
  scenario,
  baseline: median(runs.filter(run => run.name === "baseline").map(run => run[scenario])),
  candidate: median(runs.filter(run => run.name === "candidate").map(run => run[scenario]))
}));
writeFileSync(resolve(out, "ordinary-memory.json"), JSON.stringify({ node: process.version,
  workerSha256: createHash("sha256").update(readFileSync(worker)).digest("hex"), runs, summaries }, null, 2));
summaries.forEach(summary => console.log(JSON.stringify(summary)));
