// Current-next characterization: another guess after internal correction starts.
import { pathToFileURL } from "node:url";
import assert from "node:assert/strict";
const { action, createSignal, createOptimistic, createMemo, createRoot,
  createRenderEffect, latest, flush } = await import(pathToFileURL(process.argv[2]));
const gate = () => {
  let resolve;
  const promise = new Promise(yes => { resolve = yes; });
  return { promise, resolve };
};
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const results = [];
for (const async of [false, true]) for (const separateAction of [false, true]) {
  const reply = gate(), again = gate(), end = gate(), secondEnd = gate();
  const [source, setSource] = createSignal(0);
  const shown = { source: 0, view: 0, derived: 0, latestView: 0, latestDerived: 0 };
  const calculations = [], flights = [];
  let guess, dispose, updaterBase;
  createRoot(d => {
    dispose = d;
    const [view, write] = createOptimistic(source);
    guess = write;
    const derived = createMemo(() => {
      const value = view();
      calculations.push(value);
      if (async && (value === 10 || value === 2)) {
        const answer = gate();
        flights.push({ value, answer });
        return answer.promise;
      }
      return value * 2;
    });
    const reads = { source, view, derived };
    if (!process.argv.includes("--without-latest")) {
      reads.latestView = createMemo(() => latest(view));
      reads.latestDerived = createMemo(() => latest(derived));
    }
    for (const [key, read] of Object.entries(reads))
      createRenderEffect(read, value => { shown[key] = value; });
  });
  flush();
  const frames = [];
  const record = event => frames.push({ event, ...shown, calculations: [...calculations] });
  const reguess = () => guess(previous => { updaterBase = previous; return previous + 1; });
  const first = action(function* () {
    guess(1);
    yield reply.promise;
    setSource(10);
    if (!separateAction) { yield again.promise; reguess(); }
    yield end.promise;
  })();
  flush();
  record("guess 1 published");
  reply.resolve();
  await turn();
  record("correction to 10 starts");
  let second;
  if (separateAction) second = action(function* () { reguess(); yield secondEnd.promise; })();
  else again.resolve();
  flush();
  await turn();
  record("guess previous + 1");
  if (async) {
    for (const flight of flights.splice(0).sort((a, b) => b.value - a.value)) {
      flight.answer.resolve(flight.value * 2);
      await turn();
      record(`answer for ${flight.value}`);
    }
  }
  end.resolve();
  await first;
  await turn();
  record("first action ends");
  if (second) {
    secondEnd.resolve();
    await second;
    await turn();
    record("second action ends");
  }
  for (let round = 0; flights.length && round < 5; round++) {
    for (const flight of flights.splice(0)) flight.answer.resolve(flight.value * 2);
    await turn();
    record("restoration work resolves");
  }
  assert.equal(updaterBase, 1);
  assert.equal(shown.source, 10);
  assert.equal(shown.view, 10);
  assert.equal(shown.derived, 20);
  results.push({ async, separateAction, updaterBase, frames });
  dispose();
  flush();
}
console.log(JSON.stringify(results, null, 2));
