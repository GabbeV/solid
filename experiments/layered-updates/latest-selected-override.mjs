// Upstream characterization for integrating latest with the selected-output model.
import { pathToFileURL } from "node:url";
const { action, createSignal, createOptimistic, createRenderEffect,
  createRoot, createMemo, latest, flush } = await import(pathToFileURL(process.argv[2]));
const gate = () => {
  let resolve;
  const promise = new Promise(yes => { resolve = yes; });
  return { promise, resolve };
};
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const reply = gate(), finish = gate();
const [source, setSource] = createSignal(0);
const shown = { source: 0, view: 0, doubled: 0, latestView: 0, latestDoubled: 0, latestSource: 0 };
let guess, dispose;
createRoot(d => {
  dispose = d;
  const [view, write] = createOptimistic(source);
  guess = write;
  const doubled = createMemo(() => view() * 2);
  const latestView = createMemo(() => latest(view));
  const latestDoubled = createMemo(() => latest(doubled));
  const latestSource = createMemo(() => latest(source));
  for (const [key, read] of Object.entries({ source, view, doubled, latestView, latestDoubled, latestSource }))
    createRenderEffect(read, value => { shown[key] = value; });
});
flush();
const frames = [{ event: "initial", ...shown }];
const running = action(function* () {
  guess(1);
  yield reply.promise;
  setSource(10);
  yield finish.promise;
})();
flush();
frames.push({ event: "guess", ...shown });
reply.resolve();
await turn();
frames.push({ event: "input answer while action remains open", ...shown });
finish.resolve();
await running;
await turn();
frames.push({ event: "action ends", ...shown });
dispose();
flush();
console.log(JSON.stringify(frames));
