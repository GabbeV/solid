// Public-API counterpart of unified-pending-feedback-metadata.test.ts.
import { pathToFileURL } from "node:url";
const { createMemo, createRenderEffect, createRoot, createSignal, flush, isPending } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const results = {};
for (const scenario of ["self", "indirect", "secondary", "secondary-id", "sync-label", "supersede"]) {
  for (const order of ["value-first", "pending-first"]) {
    const gates = [Promise.withResolvers(), Promise.withResolvers()];
    const calls = [], publications = [], shown = {};
    let write, dispose;
    createRoot(cleanup => {
      dispose = cleanup;
      const [id, setId] = createSignal(0);
      write = setId;
      const primary = ["secondary", "secondary-id", "sync-label"].includes(scenario)
        ? createMemo(() => id() === 0 ? 0 : gates[0].promise.then(value => value))
        : undefined;
      const pending = () => isPending(scenario === "secondary" ? primary : id);
      const status = scenario === "supersede" ? () => false
        : scenario === "indirect" ? createMemo(pending) : pending;
      const data = createMemo(() => {
        let value, p;
        if (order === "pending-first") { p = status(); value = id(); }
        else { value = id(); p = status(); }
        calls.push({ value, pending: p });
        if (scenario === "sync-label") return `${p}:${value}`;
        if ((scenario === "secondary" || scenario === "secondary-id") && p) return -1;
        return value === 0 ? 0 : gates[value === 2 ? 1 : 0].promise.then(answer => answer);
      });
      for (const [key, read] of Object.entries({ id, data, pending, ...(primary ? { primary } : {}) }))
        createRenderEffect(read, value => {
          shown[key] = value;
          publications.push({ key, value });
        }, { schedule: true });
    });
    flush(); write(1); flush(); await turn();
    const held = { ...shown };
    if (scenario === "supersede") { write(2); flush(); await turn(); }
    gates[0].resolve(10); gates[1].resolve(20); await turn();
    results[`${scenario}/${order}`] = { held, settled: { ...shown }, calls, publications };
    dispose(); flush();
  }
}
console.log(JSON.stringify(results, null, 2));
