// Characterize the existing APIs before deciding their layered replacements.
// Usage: node experiments/layered-updates/questions.mjs /path/to/baseline/packages/signals/dist/prod/index.js
import { pathToFileURL } from "node:url";
const {
  createSignal,
  createMemo,
  createRenderEffect,
  createRoot,
  createOptimistic,
  isPending,
  action,
  flush
} = await import(pathToFileURL(process.argv[2]));
function gate() {
  let resolve;
  const promise = new Promise(r => {
    resolve = r;
  });
  return { promise, resolve };
}
const records = {};
{
  const end = gate();
  const [source, setSource] = createSignal(0);
  let guess, shown;
  const dispose = createRoot(d => {
    const [view, write] = createOptimistic(source);
    guess = write;
    const doubled = createMemo(() => view() * 2);
    createRenderEffect(
      () => [source(), view(), doubled()],
      value => {
        shown = value;
      }
    );
    return d;
  });
  const run = action(function* () {
    guess(1);
    yield end.promise;
  })();
  flush();
  const guessed = shown;
  setSource(2);
  flush();
  const incoming = shown;
  end.resolve();
  await run;
  flush();
  records.inputAnswer = { guessed, incoming, complete: shown };
  dispose();
}
{
  const end = gate();
  const [x, setX] = createSignal(0);
  let statusShown, pairShown;
  const dispose = createRoot(d => {
    const status = createMemo(() => isPending(x));
    const pair = createMemo(() => [status(), x()]);
    createRenderEffect(status, value => {
      statusShown = value;
    });
    createRenderEffect(pair, value => {
      pairShown = value;
    });
    return d;
  });
  const initial = [statusShown, pairShown];
  const run = action(function* () {
    setX(1);
    yield end.promise;
  })();
  flush();
  const pending = [statusShown, pairShown];
  end.resolve();
  await run;
  flush();
  records.observationScope = { initial, pending, complete: [statusShown, pairShown] };
  dispose();
}
console.log(JSON.stringify(records, null, 2));
