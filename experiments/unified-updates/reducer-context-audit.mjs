// Diagnostic, not a normative contract: separately processed signal writes
// through synchronous reducers, with and without optimism in the reducer.
import { pathToFileURL } from "node:url";
import assert from "node:assert/strict";

const { action, createSignal, createMemo, createOptimistic, createRenderEffect, createRoot, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const reports = {};

for (const mode of ["ordinary", "ordinary-async-tail", "separate", "mixed"]) {
  const second = Promise.withResolvers();
  const lowerEnd = Promise.withResolvers();
  const upperEnd = Promise.withResolvers();
  const derivedEnd = Promise.withResolvers();
  const calls = [], snapshots = [];
  const shown = {};
  let setDelta, guess, dispose;
  createRoot(cleanup => {
    dispose = cleanup;
    const [delta, write] = createSignal(0);
    const [preview, propose] = createOptimistic(() => 0);
    setDelta = write;
    guess = propose;
    const reduced = createMemo((previous = 0) => {
      const d = delta();
      const p = mode === "mixed" ? preview() : 0;
      const value = previous + d + p;
      calls.push({ previous, delta: d, preview: p, value });
      return value;
    });
    const total = mode === "separate" ? createMemo(() => reduced() + preview()) : reduced;
    const settled = mode === "ordinary-async-tail" ? createMemo(() => {
      const value = reduced();
      return value === 0 ? 0 : derivedEnd.promise.then(() => value);
    }) : total;
    for (const [key, read] of Object.entries({ delta, preview, reduced, total, settled }))
      createRenderEffect(read, value => { shown[key] = value; }, { schedule: true });
  });
  flush();
  const snapshot = phase => snapshots.push({ phase, shown: { ...shown }, calls: calls.map(c => ({ ...c })) });
  snapshot("initial");
  const lower = action(function* () {
    setDelta(1);
    yield second.promise;
    setDelta(2);
    yield lowerEnd.promise;
  })();
  await turn();
  snapshot("processed +1, held");
  second.resolve();
  await turn();
  snapshot("processed +2, held");
  assert.deepEqual(calls.map(c => c.value), [0, 1, 3]);
  let upper = Promise.resolve();
  if (mode === "separate" || mode === "mixed") {
    upper = action(function* () {
      guess(10);
      yield upperEnd.promise;
    })();
    await turn();
    snapshot("optimism while lower is held");
  }
  lowerEnd.resolve();
  await lower;
  await turn();
  snapshot("lower action ended");
  derivedEnd.resolve();
  await turn();
  snapshot("downstream work finished");
  upperEnd.resolve();
  await upper;
  await turn();
  snapshot("both actions ended");
  dispose();
  flush();
  reports[mode] = snapshots;
}
console.log(JSON.stringify(reports, null, 2));
