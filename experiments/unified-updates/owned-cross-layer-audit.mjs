import { pathToFileURL } from "node:url";
const { action, createRoot, createSignal, createMemo, createOptimistic,
  createRenderEffect, flush } = await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const initialAnswer = Promise.withResolvers();
const initialPending = process.argv.includes("--initial-pending");
const guessEnd = Promise.withResolvers(), mountEnd = Promise.withResolvers(), answer = Promise.withResolvers();
const [mount, setMount] = createSignal(false);
const shown = { view: initialPending ? null : 0, detail: initialPending ? null : 0, mounted: false, child: null };
const events = [];
let guess, dispose;
createRoot(cleanup => {
  dispose = cleanup;
  const source = createMemo(() => initialPending ? initialAnswer.promise : 0);
  const [view, write] = createOptimistic(source);
  guess = write;
  const detail = createMemo(() => view() ? answer.promise : 0);
  const owner = createMemo(() => {
    const mounted = mount();
    if (mounted) {
      const child = createMemo(() => view());
      createRenderEffect(child, value => { shown.child = value; }, { schedule: true });
    }
    return mounted;
  });
  for (const [key, read] of Object.entries({ view, detail, mounted: owner }))
    createRenderEffect(read, value => { shown[key] = value; }, { schedule: true });
});
flush();
const guessing = action(function* () { guess(1); yield guessEnd.promise; })();
flush();
events.push({ phase: "guess suspended", ...shown });
const mounting = action(function* () { setMount(true); yield mountEnd.promise; })();
flush();
events.push({ phase: "new child proposed", ...shown });
answer.resolve(1);
await turn(); flush();
events.push({ phase: "guess ready; mounting action still open", ...shown });
mountEnd.resolve(); await mounting; await turn(); flush();
events.push({ phase: "mounting action finished", ...shown });
dispose(); guessEnd.resolve(); await guessing; await turn(); flush();
console.log(JSON.stringify(events, null, 2));
