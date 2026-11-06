// Does a higher calculation inherit the previous result of a held lower pass?
import { pathToFileURL } from "node:url";
const {
  action,
  createSignal,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  flush
} = await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const reports = {};
for (const boundary of [false, true]) {
  const lowerEnd = Promise.withResolvers(),
    upperEnd = Promise.withResolvers();
  const calls = [],
    snapshots = [];
  let setBase, guess, dispose;
  const shown = { base: 0, preview: 0, total: 0 };
  createRoot(cleanup => {
    dispose = cleanup;
    const [base, write] = createSignal(0);
    const [preview, propose] = createOptimistic(() => 0);
    setBase = write;
    guess = propose;
    const input = (previous = 0) => {
      const b = base(),
        p = preview();
      calls.push({ previous, base: b, preview: p });
      return previous + b + p;
    };
    const total = boundary ? createOptimistic(input)[0] : createMemo(input);
    for (const [key, get] of Object.entries({ base, preview, total }))
      createRenderEffect(
        get,
        value => {
          shown[key] = value;
        },
        { schedule: true }
      );
  });
  flush();
  const snapshot = phase =>
    snapshots.push({ phase, shown: { ...shown }, calls: calls.map(call => ({ ...call })) });
  snapshot("initial");
  const lower = action(function* () {
    setBase(1);
    yield lowerEnd.promise;
  })();
  await turn();
  snapshot("base=1 is held");
  const upper = action(function* () {
    guess(10);
    yield upperEnd.promise;
  })();
  await turn();
  snapshot("preview=10 publishes while base remains held");
  dispose();
  lowerEnd.resolve();
  upperEnd.resolve();
  await Promise.all([lower, upper]);
  flush();
  reports[boundary ? "inputProducer" : "ordinaryMemo"] = snapshots;
}
console.log(JSON.stringify(reports, null, 2));
