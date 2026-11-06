// Compare status-like guesses, guesses around an async producer, ordinary
// optimistic request keys, and latest reads. Count starts and cancellations.
import { pathToFileURL } from "node:url";
const {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest,
  onCleanup
} = await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const results = {};
for (const mode of [
  "guessed-flag",
  "guessed-result",
  "guessed-key",
  "latest-key",
  "incidental-latest"
]) {
  const end = Promise.withResolvers();
  const jobs = [],
    events = [],
    snapshots = [],
    shown = {};
  let start, dispose, running;
  function load(key) {
    if (key === 0) return 0;
    const job = {
      key,
      index: jobs.length,
      gate: Promise.withResolvers(),
      done: false,
      cancelled: false
    };
    jobs.push(job);
    events.push(`start ${key} #${job.index}`);
    onCleanup(() => {
      if (!job.done) {
        job.cancelled = true;
        events.push(`cancel ${key} #${job.index}`);
      }
    });
    return job.gate.promise.then(() => {
      job.done = true;
      events.push(`answer ${key} #${job.index}`);
      return key * 10;
    });
  }
  createRoot(cleanup => {
    dispose = cleanup;
    const [id, setId] = createSignal(0);
    let output, extra;
    if (mode === "guessed-flag") {
      const [busy, guessBusy] = createOptimistic(() => false);
      extra = busy;
      output = createMemo(() => {
        const key = id();
        return busy() ? -1 : load(key);
      });
      start = action(function* () {
        setId(1);
        guessBusy(true);
        yield end.promise;
      });
    } else if (mode === "guessed-result") {
      const [view, guess] = createOptimistic(() => load(id()));
      output = view;
      start = action(function* () {
        setId(1);
        guess(-1);
        yield end.promise;
      });
    } else if (mode === "guessed-key") {
      const [key, guess] = createOptimistic(id);
      extra = key;
      output = createMemo(() => load(key()));
      start = action(function* () {
        guess(1);
        yield end.promise;
        setId(2);
      });
    } else {
      output = createMemo(() => {
        if (mode === "latest-key") return load(latest(id));
        const key = id();
        latest(id); // Incidental observation: not part of the request key.
        return load(key);
      });
      start = () => setId(1);
    }
    for (const [key, read] of Object.entries({ id, output, ...(extra ? { extra } : {}) }))
      createRenderEffect(
        read,
        value => {
          shown[key] = value;
        },
        { schedule: true }
      );
  });
  const snapshot = phase => snapshots.push({ phase, shown: { ...shown }, events: [...events] });
  flush();
  running = start();
  flush();
  await turn();
  snapshot("proposal held");
  end.resolve();
  await turn();
  snapshot("action body ends");
  for (let round = 0; round < 5; round++) {
    for (const job of [...jobs]) if (!job.done) job.gate.resolve();
    await turn();
    snapshot(`answers ${round + 1}`);
  }
  await running;
  results[mode] = {
    jobs: jobs.map(({ key, index, cancelled }) => ({ key, index, cancelled })),
    snapshots
  };
  dispose();
  flush();
}
console.log(JSON.stringify(results, null, 2));
