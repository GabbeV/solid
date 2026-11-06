// Build the experimental entry alongside the shipped prod entry, using the
// repository's Rollup plugins and shared property-mangling pass.
import { rollup } from "rollup";
import { execFileSync } from "node:child_process";
import { resolve, dirname } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, "../..");
const pkg = resolve(root, "packages/signals");
process.chdir(pkg);
const { default: configs, scalarConfig } = await import(
  pathToFileURL(resolve(pkg, "rollup.config.js"))
);
const selected = process.argv.includes("--scalar")
  ? [scalarConfig]
  : process.argv.includes("--all-tiers")
    ? configs
    : configs.filter(c => c.output.dir === "dist/prod");
for (const config of selected) {
  const { output, ...input } = config;
  if (output.preserveModules) {
    input.input["experimental/layer"] = "src/experimental/layer.ts";
    input.input["experimental/pending"] = "src/experimental/pending.ts";
  }
  const bundle = await rollup(input);
  await bundle.write(output);
  await bundle.close();
  if (output.preserveModules) {
    execFileSync(process.execPath, ["scripts/mangle-props.mjs", output.dir], { stdio: "inherit" });
    execFileSync(process.execPath, ["scripts/check-pure.mjs", output.dir], { stdio: "inherit" });
  }
}
