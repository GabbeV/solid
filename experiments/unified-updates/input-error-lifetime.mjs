// Compare input errors using the separately built upstream and scalar runtimes.
import assert from "node:assert/strict";
import { pathToFileURL } from "node:url";
const { action, createErrorBoundary, createMemo, createOptimistic,
  createRenderEffect, createRoot, createSignal, flush } =
  await import(pathToFileURL(process.argv[2]));
const retainOverride = process.argv.includes("--retain-override");
const gate = () => {
  let resolve, reject;
  const promise = new Promise((yes, no) => { resolve = yes; reject = no; });
  return { promise, resolve, reject };
};
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const results = [];
for (const bodyEndsFirst of [false, true]) {
  const end = gate(), answer = gate();
  const [revision, setRevision] = createSignal(0);
  let guess, shown, dispose;
  createRoot(d => {
    dispose = d;
    const input = createMemo(() => revision() === 0 ? 0 : revision() === 1 ? answer.promise : 2);
    const boundary = createErrorBoundary(() => {
      const [view, write] = createOptimistic(input);
      guess = write;
      return view;
    }, error => error().message);
    createRenderEffect(boundary, value => { shown = value; });
  });
  flush();
  const values = [shown];
  const running = action(function* () {
    setRevision(1);
    guess(1);
    yield end.promise;
  })();
  flush();
  values.push(shown);
  if (bodyEndsFirst) { end.resolve(); await running; await turn(); }
  answer.reject(new Error("failed"));
  await turn();
  values.push(shown);
  end.resolve();
  await running;
  await turn();
  values.push(shown);
  setRevision(2);
  flush();
  values.push(shown);
  assert.deepEqual(values, [0, 1, retainOverride && !bodyEndsFirst ? 1 : "failed", "failed", 2]);
  results.push({ bodyEndsFirst, values });
  dispose();
  flush();
}
console.log(JSON.stringify(results));
