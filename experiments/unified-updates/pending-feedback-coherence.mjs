// The same async value+pending derivation, with and without an independent
// reason to keep the input update open. Gates model an async renderer.
import { pathToFileURL } from "node:url";
const {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  onCleanup
} = await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const results = {};
for (const external of ["none", "request", "action"]) {
  for (const order of external === "none"
    ? ["presentation-first"]
    : ["presentation-first", "input-first"]) {
    const end = Promise.withResolvers(),
      primaryAnswer = Promise.withResolvers();
    const jobs = [],
      snapshots = [],
      publications = [],
      shown = {};
    let start, running, dispose;
    createRoot(cleanup => {
      dispose = cleanup;
      const [id, setId] = createSignal(0);
      const primary =
        external === "request"
          ? createMemo(() => (id() === 0 ? 0 : primaryAnswer.promise.then(() => 10)))
          : undefined;
      const caption = createMemo(() => {
        const value = id(),
          pending = isPending(id);
        const text = `${value}:${pending}`;
        if (text === "0:false") return text; // Previously loaded initial frame.
        const job = { text, gate: Promise.withResolvers(), done: false, cancelled: false };
        jobs.push(job);
        onCleanup(() => {
          if (!job.done) job.cancelled = true;
        });
        return job.gate.promise.then(() => {
          job.done = true;
          return text;
        });
      });
      for (const [key, read] of Object.entries({
        id,
        caption,
        pending: () => isPending(id),
        ...(primary ? { primary } : {})
      }))
        createRenderEffect(
          read,
          value => {
            shown[key] = value;
            publications.push({ key, value });
          },
          { schedule: true }
        );
      start =
        external === "action"
          ? action(function* () {
              setId(1);
              yield end.promise;
            })
          : () => setId(1);
    });
    const snapshot = phase =>
      snapshots.push({
        phase,
        shown: { ...shown },
        jobs: jobs.map(({ text, done, cancelled }) => ({ text, done, cancelled }))
      });
    flush();
    running = start();
    flush();
    await turn();
    snapshot("update begins");
    if (order === "input-first") {
      end.resolve();
      primaryAnswer.resolve();
      await turn();
      snapshot("independent cause ends early");
    }
    for (const job of jobs) if (job.text === "0:true") job.gate.resolve();
    await turn();
    snapshot("pending presentation ready");
    end.resolve();
    primaryAnswer.resolve();
    await turn();
    snapshot("independent cause ends");
    for (let round = 0; round < 5; round++) {
      for (const job of [...jobs]) if (!job.done) job.gate.resolve();
      await turn();
      snapshot(`remaining answers ${round + 1}`);
    }
    await running;
    results[`${external}/${order}`] = { snapshots, publications };
    dispose();
    flush();
  }
}
console.log(JSON.stringify(results, null, 2));
