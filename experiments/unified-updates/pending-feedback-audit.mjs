// Does an async producer subscribing to its own cause's pending output also
// hold that shared output? Public APIs only, real built runtime.
import { pathToFileURL } from "node:url";
const { createSignal, createMemo, createRoot, createRenderEffect, isPending, latest, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const reports = {};
for (const probe of ["none", "pending", "latest"]) {
  const gate = Promise.withResolvers();
  const calls = [], frames = [], snapshots = [];
  const shown = { count: -1, data: -1, pending: false };
  let write, dispose;
  createRoot(cleanup => {
    dispose = cleanup;
    const [count, setCount] = createSignal(0);
    write = setCount;
    const data = createMemo(() => {
      const value = count();
      const status = probe === "pending" ? isPending(count)
        : probe === "latest" ? latest(count) : undefined;
      calls.push({ value, status });
      return value === 0 ? 0 : gate.promise.then(() => value * 10);
    });
    for (const [key, read] of Object.entries({ count, data, pending: () => isPending(count) }))
      createRenderEffect(read, value => {
        shown[key] = value;
        frames.push({ key, value });
      }, { schedule: true });
  });
  const snapshot = phase => snapshots.push({ phase, shown: { ...shown }, calls: [...calls] });
  flush(); snapshot("initial");
  write(1); flush();
  await turn(); snapshot("request held");
  gate.resolve();
  await turn(); snapshot("request resolved");
  dispose(); flush();
  reports[probe] = { snapshots, frames };
}
console.log(JSON.stringify(reports, null, 2));
