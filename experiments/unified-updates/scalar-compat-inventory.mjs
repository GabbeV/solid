// Select whole, unchanged upstream files with supported public imports. Missing
// APIs are exclusions, not dummy implementations or rewritten test assertions.
import ts from "typescript";
import { readFileSync, readdirSync, mkdirSync, writeFileSync } from "node:fs";
import { resolve, dirname, relative } from "node:path";
import { fileURLToPath } from "node:url";
import { createHash } from "node:crypto";
const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, "../..");
const tests = resolve(root, "packages/signals/tests");
const supported = new Set([
  "action", "createSignal", "createMemo", "createEffect", "createRenderEffect",
  "createRoot", "onCleanup", "flush", "createOptimistic", "isPending", "latest",
  "refresh", "resolve", "createErrorBoundary", "createLoadingBoundary", "untrack", "runWithOwner",
  "isEqual", "getOwner", "getObserver", "isDisposed", "createOwner", "getNextChildId",
  "peekNextChildId", "createContext", "getContext", "setContext", "NotReadyError",
  "NoOwnerError", "ContextNotFoundError", "TimeoutError", "resetErrorHalt",
  "ROOT_ERROR_HOOK", "enforceLoadingBoundary", "configureClientErrors", "DEV", "$REFRESH"
]);
const safeInternal = new Set([
  "core/constants.js", "core/scheduler.js", "core/error.js", "core/dev.js", "core/async.js"
]);
function inspect(path, visited = new Set(), state = { publicEntry: false }) {
  if (visited.has(path)) return [];
  visited.add(path);
  const source = readFileSync(path, "utf8");
  const ast = ts.createSourceFile(path, source, ts.ScriptTarget.Latest, true);
  const reasons = [];
  for (const node of ast.statements) {
    if (!ts.isImportDeclaration(node) || node.importClause?.isTypeOnly) continue;
    const specifier = node.moduleSpecifier.text;
    const names = node.importClause?.namedBindings;
    const symbols = names && ts.isNamedImports(names)
      ? names.elements.filter(e => !e.isTypeOnly).map(e => e.propertyName?.text ?? e.name.text) : [];
    if (specifier.endsWith("/src/index.js")) {
      state.publicEntry = true;
      if (names && !ts.isNamedImports(names)) reasons.push("namespace public import requires audit");
      for (const symbol of symbols) if (!supported.has(symbol)) reasons.push(`unsupported public API: ${symbol}`);
    } else if (specifier.includes("/src/")) {
      const internal = specifier.split("/src/")[1];
      if (!safeInternal.has(internal)) reasons.push(`internal module requires audit: ${internal}`);
    } else if (specifier.startsWith(".")) {
      const target = resolve(dirname(path), specifier.replace(/\.js$/, ".ts"));
      reasons.push(...inspect(target, visited, state));
    }
  }
  function visit(node) {
    if (ts.isCallExpression(node) && node.expression.kind === ts.SyntaxKind.ImportKeyword)
      reasons.push("dynamic import requires audit");
    ts.forEachChild(node, visit);
  }
  visit(ast);
  return [...new Set(reasons)].sort();
}
const records = readdirSync(tests).filter(name => name.endsWith(".test.ts") && !name.startsWith("unified-"))
  .sort().map(name => {
    const path = resolve(tests, name), state = { publicEntry: false }, reasons = inspect(path, new Set(), state);
    if (!state.publicEntry) reasons.push("does not exercise the replacement public entry");
    const baseline = resolve("/workspace/layered-baseline/packages/signals/tests", name);
    if (readFileSync(path, "utf8") !== readFileSync(baseline, "utf8"))
      reasons.push("test file differs from pinned next; excluded from unchanged-suite count");
    return { file: `tests/${name}`, selected: reasons.length === 0, reasons,
      sha256: createHash("sha256").update(readFileSync(path)).digest("hex") };
  });
const out = resolve(process.argv[2] || resolve(here, "results/compat-stage75/inventory.json"));
mkdirSync(dirname(out), { recursive: true });
writeFileSync(out, JSON.stringify({ policy: "whole root-level upstream test files; unchanged assertions; stores and unified-update tests excluded",
  supported: [...supported].sort(), records }, null, 2) + "\n");
console.log(JSON.stringify({ inventory: relative(root, out), selected: records.filter(r => r.selected).length,
  deferred: records.filter(r => !r.selected).length }));
