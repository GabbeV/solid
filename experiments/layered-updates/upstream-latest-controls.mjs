// Replay unmodified upstream assertions against the shared observation APIs.
// The temporary adapter changes imports only; normal compatibility tests stay intact.
import { mkdtempSync, readFileSync, writeFileSync, rmSync } from "node:fs";
import { execFileSync } from "node:child_process";
import { dirname, resolve, relative } from "node:path";
import { fileURLToPath } from "node:url";
const here = dirname(fileURLToPath(import.meta.url));
const pkg = resolve(here, "../../packages/signals");
const directory = mkdtempSync(resolve(pkg, "tests/layered-controls-"));
const names =
  process.argv.length > 2
    ? process.argv.slice(2)
    : [
        "latest-async",
        "latest-created-inside-window",
        "latest-plain-write-purity",
        "latest-unobserved-memo",
        "latest-held-till-flush",
        "latest-repeated-writes",
        "latest-shadow-owned-write",
        "latest-lazy-companion-backfill"
      ];
writeFileSync(
  resolve(directory, "api.ts"),
  `export * from "../../src/index.js";
export { latest } from "../../src/experimental/latest.js";
export { isPending } from "../../src/experimental/pending.js";
`
);
for (const name of names) {
  const source = readFileSync(resolve(pkg, `tests/${name}.test.ts`), "utf8");
  writeFileSync(
    resolve(directory, `${name}.test.ts`),
    source.replaceAll('"../src/index.js"', '"./api.js"')
  );
}
try {
  process.stdout.write(
    execFileSync(
      resolve(pkg, "node_modules/.bin/vitest"),
      ["run", relative(pkg, directory), "--testTimeout=10000"],
      {
        cwd: pkg,
        env: { ...process.env, SIGNALS_SCALAR_ONLY: "1" },
        encoding: "utf8",
        stdio: ["ignore", "pipe", "pipe"]
      }
    )
  );
} catch (error) {
  process.stdout.write(error.stdout || "");
  process.stderr.write(error.stderr || "");
  process.exitCode = 1;
} finally {
  rmSync(directory, { recursive: true });
}
