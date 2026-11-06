// Sampling includes collected objects. Estimates are not exact object counts.
import { execFileSync } from "node:child_process";
import { writeFileSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
const here = dirname(fileURLToPath(import.meta.url));
const out = resolve(process.argv[2] || resolve(here, "results"));
const runs = [];
for (let sample = 0; sample < 3; sample++) {
  for (const name of sample % 2 ? ["candidate", "baseline"] : ["baseline", "candidate"]) {
    const result = JSON.parse(
      execFileSync(
        process.execPath,
        ["--expose-gc", resolve(here, "allocations.mjs"), resolve(out, `${name}-optimistic.mjs`)],
        { encoding: "utf8" }
      )
    );
    runs.push({ sample, name, ...result });
  }
}
writeFileSync(
  resolve(out, "allocations.json"),
  JSON.stringify({ node: process.version, runs }, null, 2)
);
for (const scenario of Object.keys(runs[0].sampledAllocatedBytesPerWrite)) {
  const entry = { scenario };
  for (const name of ["baseline", "candidate"]) {
    const values = runs
      .filter(run => run.name === name)
      .map(run => run.sampledAllocatedBytesPerWrite[scenario])
      .sort((a, b) => a - b);
    entry[name] = { min: values[0], median: values[1], max: values[2] };
  }
  console.log(JSON.stringify(entry));
}
