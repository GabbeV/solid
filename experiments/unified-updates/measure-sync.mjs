// Fresh process per workload/runtime/sample, with paired alternating order.
import { build } from "esbuild";
import { execFileSync } from "node:child_process";
import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { createHash } from "node:crypto";
import { cpus } from "node:os";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { brotliCompressSync, constants } from "node:zlib";
const here = dirname(fileURLToPath(import.meta.url));
const out = resolve(process.argv[2] || resolve(here, "results/sync-scope-stage17"));
mkdirSync(out, { recursive: true });
const worker = readFileSync(resolve(here, "sync-bench.mjs"));
const workerSha256 = createHash("sha256").update(worker).digest("hex");
writeFileSync(resolve(out, "worker.mjs"), worker);
const bundles = [];
const retainedExports = ["createSignal", "createMemo", "createRoot", "createRenderEffect", "flush"];
if (process.env.SYNC_KEEP_OPTIMISM === "1") retainedExports.push("createOptimistic");
for (const [name, root, tree] of [
  ["baseline", "/workspace/layered-baseline", "prod"],
  ["candidate", resolve(here, "../.."), "scalar"]
]) {
  const entry = name === "candidate" && process.env.SCALAR_CANDIDATE_ENTRY
    ? resolve(process.env.SCALAR_CANDIDATE_ENTRY)
    : resolve(root, `packages/signals/dist/${tree}/index.js`);
  const result = await build({
    stdin: {
      contents: `export {${retainedExports.join(",")}} from ${JSON.stringify(entry)};`,
      resolveDir: root
    },
    bundle: true,
    format: "esm",
    platform: "node",
    minify: true,
    write: false,
    metafile: true,
    mangleProps: /^_/,
    reserveProps: /^_(name|parent)$/,
    logLevel: "error"
  });
  const bytes = result.outputFiles[0].contents;
  writeFileSync(resolve(out, `${name}.mjs`), bytes);
  writeFileSync(resolve(out, `${name}.meta.json`), JSON.stringify(result.metafile, null, 2));
  bundles.push({
    name,
    entry,
    sha256: createHash("sha256").update(bytes).digest("hex"),
    minified: bytes.length,
    brotli: brotliCompressSync(bytes, { params: { [constants.BROTLI_PARAM_QUALITY]: 11 } }).length
  });
}
const scenarios = process.env.SYNC_CASES?.split(",") || [
  "signal-read",
  "memo-read",
  "write-flush",
  "equal-write",
  "memo-write",
  "batch-10-writes",
  "chain",
  "diamond",
  "fanout-memos",
  "fanout-effects",
  "branch-switch",
  "signal-create",
  "memo-create-dispose"
];
const runs = [],
  summaries = [];
const median = values => [...values].sort((a, b) => a - b)[Math.floor(values.length / 2)];
const sampleCount = Number(process.env.SYNC_SAMPLES || 7);
for (const scenario of scenarios) {
  for (let sample = 0; sample < sampleCount; sample++) {
    for (const name of sample % 2 ? ["candidate", "baseline"] : ["baseline", "candidate"]) {
      const result = JSON.parse(
        execFileSync(
          process.execPath,
          ["--expose-gc", resolve(out, "worker.mjs"), resolve(out, `${name}.mjs`), scenario],
          { encoding: "utf8" }
        )
      );
      runs.push({ name, sample, ...result });
    }
  }
  const selected = runs.filter(r => r.scenario === scenario);
  const summary = { scenario };
  for (const name of ["baseline", "candidate"]) {
    const values = selected.filter(r => r.name === name).map(r => r.ns);
    summary[name] = { median: median(values), min: Math.min(...values), max: Math.max(...values) };
  }
  summary.pairedRatio = median(
    Array.from(
      { length: sampleCount },
      (_, sample) =>
        selected.find(r => r.name === "candidate" && r.sample === sample).ns /
        selected.find(r => r.name === "baseline" && r.sample === sample).ns
    )
  );
  summaries.push(summary);
  writeFileSync(
    resolve(out, "performance.json"),
    JSON.stringify(
      { node: process.version, cpu: cpus()[0]?.model, workerSha256, retainedExports, bundles, runs, summaries },
      null,
      2
    )
  );
  console.log(JSON.stringify(summary));
}
