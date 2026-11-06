// Audit only: include the deferred refresh implementation in the same module
// instance as the scalar prototype. This does not extend its supported entry.
import { build } from "esbuild";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "../..");
await build({
  stdin: {
    contents: `export * from "./packages/signals/src/experimental/scalar.ts";
      export { refresh } from "./packages/signals/src/signals.ts";`,
    resolveDir: root,
    loader: "ts"
  },
  outfile: resolve(root, "experiments/unified-updates/results/refresh-audit-stage37/candidate-audit.mjs"),
  bundle: true,
  format: "esm",
  platform: "node",
  define: {
    __DEV__: "false",
    __OBSERVE__: "false",
    __TEST__: "false",
    __LEGACY_LANES__: "false"
  },
  logLevel: "silent"
});
