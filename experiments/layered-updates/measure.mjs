// Reproducible application bundles and isolated-process microbenchmarks.
// Usage: node experiments/layered-updates/measure.mjs /path/to/baseline
import { build } from "esbuild";
import { brotliCompressSync, gzipSync, constants } from "node:zlib";
import { mkdir, writeFile } from "node:fs/promises";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { execFileSync } from "node:child_process";

const here = dirname(fileURLToPath(import.meta.url));
const candidate = resolve(here, "../..");
const baseline = resolve(process.argv[2] || "/workspace/layered-baseline");
const scalar = process.argv.includes("--scalar");
const out = process.env.MEASURE_OUT
  ? resolve(process.env.MEASURE_OUT)
  : resolve(here, "results", scalar ? "scalar" : "");
await mkdir(out, { recursive: true });
const records = [];
for (const [name, root] of [
  ["baseline", baseline],
  ["candidate", candidate]
]) {
  for (const scenario of scalar
    ? process.argv.includes("--combined")
      ? ["optimistic-pending", "optimistic-latest", "optimistic-observations"]
      : ["ordinary", "optimistic", "pending", "latest", "refresh", "optimistic-refresh"]
    : ["ordinary", "optimistic", "pending", "loading"]) {
    const tree = `${root}/packages/signals/dist/${name === "candidate" && scalar ? "scalar" : "prod"}`;
    const entry = `${tree}/index.js`;
    const exports = [
      "createSignal",
      "createMemo",
      "createRenderEffect",
      "createRoot",
      "flush",
      "action"
    ];
    let contents = `export { ${exports.join(",")} } from ${JSON.stringify(entry)};`;
    if (scenario === "loading")
      contents += `export { createLoadingBoundary } from ${JSON.stringify(entry)};`;
    if (["latest", "optimistic-latest", "optimistic-observations"].includes(scenario))
      contents += `export { latest } from ${JSON.stringify(entry)};`;
    if (scenario === "refresh" || scenario === "optimistic-refresh")
      contents += `export { refresh } from ${JSON.stringify(entry)};`;
    if (scenario === "optimistic" || scenario.startsWith("optimistic-"))
      contents +=
        name === "candidate" && !scalar
          ? `import { createLayer } from ${JSON.stringify(`${tree}/experimental/layer.js`)};
           export const optimistic = input => createLayer(input, { lifetime: "action" });`
          : `export { createOptimistic as optimistic } from ${JSON.stringify(entry)};`;
    if (["pending", "optimistic-pending", "optimistic-observations"].includes(scenario))
      contents +=
        name === "candidate" && !scalar
          ? `import { isPending } from ${JSON.stringify(`${tree}/experimental/pending.js`)};
           import { createMemo } from ${JSON.stringify(entry)};
           export const pending = input => createMemo(() => isPending(input));`
          : `import { createMemo, isPending } from ${JSON.stringify(entry)};
           export const pending = input => createMemo(() => isPending(input));`;
    const outfile = resolve(out, `${name}-${scenario}.mjs`);
    const bundle = await build({
      stdin: { contents, resolveDir: root, loader: "ts" },
      outfile,
      write: false,
      bundle: true,
      format: "esm",
      platform: "node",
      minify: true,
      metafile: true,
      define: { __DEV__: "false", __OBSERVE__: "false", __TEST__: "false" },
      mangleProps: /^_/,
      reserveProps: /^_(name|parent)$/
    });
    const bytes = bundle.outputFiles[0].contents;
    await writeFile(outfile, bytes);
    await writeFile(
      resolve(out, `${name}-${scenario}.meta.json`),
      JSON.stringify(bundle.metafile, null, 2)
    );
    records.push({
      name,
      scenario,
      minified: bytes.length,
      gzip: gzipSync(bytes).length,
      brotli: brotliCompressSync(bytes, { params: { [constants.BROTLI_PARAM_QUALITY]: 11 } }).length
    });
  }
}
await writeFile(resolve(out, "size.json"), JSON.stringify(records, null, 2));
console.log(JSON.stringify({ size: records }));
if (process.argv.includes("--bundle-only")) process.exit(0);
const runs = [];
// Alternate order across samples; every sample is a fresh process.
for (let sample = 0; sample < 5; sample++) {
  for (const name of sample % 2 ? ["candidate", "baseline"] : ["baseline", "candidate"]) {
    const result = JSON.parse(
      execFileSync(
        process.execPath,
        ["--expose-gc", resolve(here, "bench.mjs"), resolve(out, `${name}-ordinary.mjs`)],
        { encoding: "utf8" }
      )
    );
    runs.push({ sample, name, ...result });
  }
}
await writeFile(
  resolve(out, "performance.json"),
  JSON.stringify({ node: process.version, runs }, null, 2)
);
for (const key of Object.keys(runs[0].timings)) {
  const summary = {};
  for (const name of ["baseline", "candidate"]) {
    const values = runs
      .filter(r => r.name === name)
      .map(r => r.timings[key])
      .sort((a, b) => a - b);
    summary[name] = { median: values[2], min: values[0], max: values[4] };
  }
  console.log(JSON.stringify({ benchmark: key, ...summary }));
}
