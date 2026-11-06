import { execFileSync } from "node:child_process";
import { writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
const here = dirname(fileURLToPath(import.meta.url));
const out = resolve(here, "results/observation-composition-stage32");
const bundles = {
  baseline: resolve(out, "baseline-latest.mjs"),
  previous: resolve(here, "results/latest-output-stage31/candidate-latest.mjs"),
  candidate: resolve(out, "candidate-latest.mjs")
};
const runs = [];
for (let sample = 0; sample < 5; sample++) {
  const order = sample % 2 ? Object.entries(bundles).reverse() : Object.entries(bundles);
  for (const [name, bundle] of order) {
    const run = JSON.parse(
      execFileSync(
        process.execPath,
        ["--expose-gc", resolve(here, "observation-window-bench.mjs"), bundle],
        { encoding: "utf8" }
      )
    );
    runs.push({ sample, name, ...run });
  }
}
writeFileSync(
  resolve(out, "window-performance.json"),
  JSON.stringify({ node: process.version, runs }, null, 2)
);
for (const key of Object.keys(runs[0].timings)) {
  const result = { benchmark: key };
  for (const name of Object.keys(bundles)) {
    const values = runs
      .filter(r => r.name === name)
      .map(r => r.timings[key])
      .sort((a, b) => a - b);
    result[name] = { median: values[2], min: values[0], max: values[4] };
  }
  console.log(JSON.stringify(result));
}
