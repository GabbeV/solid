import { execFileSync } from "node:child_process";
import { copyFileSync, readFileSync, writeFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
const here = dirname(fileURLToPath(import.meta.url));
const out = resolve(process.argv[2]);
for (const file of ["inactive-sync-bench.mjs", "sync-bench.mjs"])
  copyFileSync(resolve(here, file), resolve(out, file));
const bundles = ["baseline", "candidate"].map(name => ({
  name,
  path: resolve(out, `${name}-optimistic.mjs`),
  sha256: createHash("sha256")
    .update(readFileSync(resolve(out, `${name}-optimistic.mjs`)))
    .digest("hex")
}));
const median = values => [...values].sort((a, b) => a - b)[Math.floor(values.length / 2)];
const runs = [],
  summaries = [];
const scenarios = process.env.SYNC_CASES?.split(",") || [
  "memo-read",
  "chain",
  "diamond",
  "memo-create-dispose"
];
const samples = Number(process.env.SYNC_SAMPLES || 7);
for (const scenario of scenarios) {
  for (let sample = 0; sample < samples; sample++) {
    for (const { name, path } of sample % 2 ? [...bundles].reverse() : bundles) {
      const result = JSON.parse(
        execFileSync(
          process.execPath,
          ["--expose-gc", resolve(out, "inactive-sync-bench.mjs"), path, scenario],
          { encoding: "utf8" }
        )
      );
      runs.push({ name, sample, ...result });
    }
  }
  const summary = { scenario };
  for (const name of ["baseline", "candidate"]) {
    const values = runs
      .filter(run => run.name === name && run.scenario === scenario)
      .map(run => run.ns);
    summary[name] = { median: median(values), min: Math.min(...values), max: Math.max(...values) };
  }
  summary.pairedRatio = median(
    Array.from(
      { length: samples },
      (_, sample) =>
        runs.find(
          run => run.name === "candidate" && run.scenario === scenario && run.sample === sample
        ).ns /
        runs.find(
          run => run.name === "baseline" && run.scenario === scenario && run.sample === sample
        ).ns
    )
  );
  summaries.push(summary);
  writeFileSync(
    resolve(out, "inactive-sync.json"),
    JSON.stringify({ node: process.version, bundles, runs, summaries }, null, 2)
  );
  console.log(JSON.stringify(summary));
}
