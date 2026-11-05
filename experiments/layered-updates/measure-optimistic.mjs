import { execFileSync } from "node:child_process";
import { writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
const here = dirname(fileURLToPath(import.meta.url));
const out = resolve(process.argv[2] || resolve(here, "results"));
const runs = [];
for (let sample = 0; sample < 5; sample++) {
  for (const name of sample % 2 ? ["candidate", "baseline"] : ["baseline", "candidate"]) {
    const bundle = resolve(out, `${name}-optimistic.mjs`);
    const run = script =>
      JSON.parse(
        execFileSync(process.execPath, ["--expose-gc", resolve(here, script), bundle], {
          encoding: "utf8"
        })
      );
    runs.push({ sample, name, ...run("optimistic-bench.mjs"), ...run("memory.mjs") });
  }
}
writeFileSync(
  resolve(out, "optimistic-performance.json"),
  JSON.stringify({ node: process.version, runs }, null, 2)
);
for (const key of [...Object.keys(runs[0].timings), "boundaryBytes", "directBoundaryBytes"]) {
  const summary = {};
  for (const name of ["baseline", "candidate"]) {
    const values = runs
      .filter(r => r.name === name)
      .map(r => r.timings[key] ?? r[key])
      .sort((a, b) => a - b);
    summary[name] = { median: values[2], min: values[0], max: values[4] };
  }
  console.log(JSON.stringify({ benchmark: key, ...summary }));
}
