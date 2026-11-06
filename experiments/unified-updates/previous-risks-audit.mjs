// Non-additive uses of previous, with a completed proposal superseded before
// downstream async work permits it to publish. Diagnostic, not a new contract.
import { pathToFileURL } from "node:url";
const { action, createSignal, createMemo, createOptimistic, createRenderEffect, createRoot, flush } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const reports = {};
for (const mode of ["trend", "identity", "stateless"]) {
  const stale = Promise.withResolvers(), second = Promise.withResolvers(), end = Promise.withResolvers();
  const calls = [], snapshots = [];
  const shown = {};
  let guess, dispose, serial = 0;
  createRoot(cleanup => {
    dispose = cleanup;
    const [source] = createSignal(5);
    const [value, propose] = createOptimistic(source);
    guess = propose;
    const result = createMemo(previous => {
      const input = value();
      const next = mode === "trend"
        ? { input, direction: !previous || input === previous.input ? "same" : input > previous.input ? "up" : "down" }
        : mode === "identity"
          ? previous?.input === input ? previous : { input, identity: ++serial }
          : input * 2;
      calls.push({ previous, input, result: next });
      return next;
    });
    const settled = createMemo(() => {
      const next = result();
      return value() === 1 ? stale.promise.then(() => next) : next;
    });
    for (const [key, read] of Object.entries({ value, result, settled }))
      createRenderEffect(read, value => { shown[key] = value; }, { schedule: true });
  });
  flush();
  const snapshot = phase => snapshots.push({ phase, shown: { ...shown }, calls: calls.slice() });
  snapshot("initial");
  const running = action(function* () {
    guess(1);
    yield second.promise;
    guess(mode === "identity" ? 5 : 2);
    yield end.promise;
  })();
  await turn();
  snapshot("first guess held");
  second.resolve();
  await turn();
  snapshot("replacement guess publishes");
  stale.resolve();
  await turn();
  snapshot("stale result ignored");
  // The tested publication is complete; disposal keeps override expiration out
  // of this particular history/identity observation.
  dispose();
  end.resolve();
  await running;
  flush();
  reports[mode] = snapshots;
}
console.log(JSON.stringify(reports, null, 2));
