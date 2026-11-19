// Production comparison of the previous-value callback across an override.
import { pathToFileURL } from "node:url";
const { action, createSignal, createOptimistic, createRenderEffect, createRoot, flush, refresh } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const report = {};
for (const refetch of [false, true]) {
  const recalculate = Promise.withResolvers(),
    end = Promise.withResolvers();
  const calls = [],
    snapshots = [];
  let setRevision, view, guess, dispose, shown, answer;
  createRoot(cleanup => {
    dispose = cleanup;
    const [revision, write] = createSignal(0);
    setRevision = write;
    [view, guess] = createOptimistic((previous = 0) => {
      const increment = refetch ? 1 : revision();
      calls.push({ previous, increment });
      return previous + increment;
    });
    createRenderEffect(
      view,
      value => {
        shown = value;
      },
      { schedule: true }
    );
  });
  flush();
  const snapshot = phase =>
    snapshots.push({ phase, shown, calls: calls.map(call => ({ ...call })), answer });
  snapshot("initial");
  const running = action(function* () {
    guess(10);
    yield recalculate.promise;
    if (refetch) answer = yield refresh(view);
    else setRevision(1);
    yield end.promise;
  })();
  await turn();
  snapshot("guess published");
  recalculate.resolve();
  await turn();
  await turn();
  snapshot("input recalculated, action open");
  end.resolve();
  await running;
  await turn();
  snapshot("action ended");
  dispose();
  flush();
  report[refetch ? "refresh" : "dependencyChange"] = snapshots;
}
console.log(JSON.stringify(report, null, 2));
