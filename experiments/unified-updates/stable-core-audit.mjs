// Public-API timelines for the actual production builds, not the reference VM.
import { pathToFileURL } from "node:url";
const {
  action,
  createRoot,
  createSignal,
  createOptimistic,
  createMemo,
  createRenderEffect,
  flush
} = await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const report = {};
{
  const nextGuess = Promise.withResolvers(),
    end = Promise.withResolvers();
  const flights = new Map(),
    snapshots = [];
  const shown = { reader: [0, 0], pair: [0, 0], late: null };
  let guess, tick, view, dispose, disposeLate;
  createRoot(cleanup => {
    dispose = cleanup;
    const [revision, write] = createSignal(0);
    tick = write;
    [view, guess] = createOptimistic(() => 0);
    const derived = createMemo(() => {
      const value = view();
      if (!value) return value;
      const request = Promise.withResolvers();
      flights.set(value, request);
      return request.promise;
    });
    createRenderEffect(
      () => [revision(), view()],
      value => {
        shown.reader = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      () => [view(), derived()],
      value => {
        shown.pair = value;
      },
      { schedule: true }
    );
  });
  const capture = phase => snapshots.push({ phase, ...structuredClone(shown) });
  const running = action(function* () {
    guess(1);
    yield nextGuess.promise;
    guess(2);
    yield end.promise;
  })();
  flush();
  flights.get(1).resolve(1);
  await turn();
  capture("first proposal published");
  nextGuess.resolve();
  await turn();
  capture("second proposal suspended");
  tick(1);
  flush();
  capture("unrelated reader reruns");
  createRoot(cleanup => {
    disposeLate = cleanup;
    createRenderEffect(
      view,
      value => {
        shown.late = value;
      },
      { schedule: true }
    );
  });
  flush();
  capture("late reader mounts");
  flights.get(2).resolve(2);
  await turn();
  capture("second proposal publishes");
  disposeLate();
  dispose();
  end.resolve();
  await running;
  await turn();
  flush();
  report.repeatedProposal = snapshots;
}
{
  const end = Promise.withResolvers(),
    requests = [];
  const [x, setX] = createSignal(0);
  let guess, dispose, disposeMount;
  createRoot(cleanup => {
    dispose = cleanup;
    const [view, write] = createOptimistic(() => 0);
    guess = write;
    createRenderEffect(view, () => {}, { schedule: true });
  });
  const running = action(function* () {
    guess(10);
    setX(1);
    yield end.promise;
  })();
  flush();
  createRoot(cleanup => {
    disposeMount = cleanup;
    const result = createMemo(() => {
      const value = x();
      requests.push(value);
      return Promise.resolve(value);
    });
    createRenderEffect(result, () => {}, { schedule: true });
  });
  flush();
  report.ordinaryMountRequests = [...requests];
  disposeMount();
  dispose();
  end.resolve();
  await running;
  await turn();
  flush();
}
console.log(JSON.stringify(report, null, 2));
