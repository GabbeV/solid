// Diagnose a suspected regression with the same worker and archived bundles.
// All runtimes execute the same workload, one runtime per fresh process.
import { execFileSync } from "node:child_process";
import { copyFileSync, mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
const here = dirname(fileURLToPath(import.meta.url));
const out = resolve(process.argv[2]);
mkdirSync(out, { recursive: true });
const files = process.argv.slice(3);
const names = ["baseline", "previous", "candidate"];
if (files.length !== 3) throw new Error("Pass output-directory baseline previous candidate");
const bundles = names.map((name, index) => {
  const source = resolve(files[index]);
  const bytes = readFileSync(source);
  const path = resolve(out, `${name}.mjs`);
  copyFileSync(source, path);
  return { name, source, path, sha256: createHash("sha256").update(bytes).digest("hex") };
});
const inactive = process.env.SYNC_INACTIVE === "1";
const worker = resolve(out, "worker.mjs");
copyFileSync(resolve(here, inactive ? "inactive-sync-bench.mjs" : "sync-bench.mjs"), worker);
if (inactive) copyFileSync(resolve(here, "sync-bench.mjs"), resolve(out, "sync-bench.mjs"));
const median = values => [...values].sort((a, b) => a - b)[Math.floor(values.length / 2)];
const scenarios = process.env.SYNC_CASES?.split(",") || ["memo-read", "write-flush"];
const runs = [],
  summaries = [];
for (const scenario of scenarios) {
  for (let sample = 0; sample < 9; sample++) {
    let order = [...bundles.slice(sample % 3), ...bundles.slice(0, sample % 3)];
    if (sample % 2) order.reverse();
    for (const { name, path } of order) {
      const result = JSON.parse(
        execFileSync(process.execPath, ["--expose-gc", worker, path, scenario], {
          encoding: "utf8"
        })
      );
      runs.push({ name, sample, ...result });
    }
  }
  const summary = { scenario };
  for (const name of names) {
    const values = runs
      .filter(run => run.scenario === scenario && run.name === name)
      .map(run => run.ns);
    summary[name] = { median: median(values), min: Math.min(...values), max: Math.max(...values) };
  }
  for (const reference of ["baseline", "previous"]) {
    summary[`candidate/${reference}`] = median(
      Array.from(
        { length: 9 },
        (_, sample) =>
          runs.find(
            run => run.scenario === scenario && run.name === "candidate" && run.sample === sample
          ).ns /
          runs.find(
            run => run.scenario === scenario && run.name === reference && run.sample === sample
          ).ns
      )
    );
  }
  summaries.push(summary);
  writeFileSync(
    resolve(out, "performance.json"),
    JSON.stringify({ node: process.version, inactive, bundles, runs, summaries }, null, 2)
  );
  console.log(JSON.stringify(summary));
}
