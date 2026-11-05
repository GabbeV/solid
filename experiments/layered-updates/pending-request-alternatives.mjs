// Count actual starts/cleanup, not just published values, when pending gates
// secondary work. No production instrumentation and no reused request promise.
import { pathToFileURL } from "node:url";
const { createMemo, createRenderEffect, createRoot, createSignal, flush, isPending, onCleanup } =
  await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const results = {};
for (const mode of ["inline", "split"]) {
  const jobs = [],
    events = [],
    frames = [],
    snapshots = [];
  let write, dispose;
  const shown = {};
  function load(kind, value) {
    if (value === 0) return 0;
    const gate = Promise.withResolvers();
    const job = { kind, value, number: jobs.length, done: false, cancelled: false, gate };
    jobs.push(job);
    events.push(`start ${kind}(${value}) #${job.number}`);
    onCleanup(() => {
      if (!job.done) {
        job.cancelled = true;
        events.push(`cancel ${kind}(${value}) #${job.number}`);
      }
    });
    return gate.promise.then(() => {
      job.done = true;
      events.push(`answer ${kind}(${value}) #${job.number}`);
      return value * 10;
    });
  }
  createRoot(cleanup => {
    dispose = cleanup;
    const [id, setId] = createSignal(0);
    write = setId;
    const primary = createMemo(() => load("primary", id()));
    const secondary = mode === "split" ? createMemo(() => load("secondary", id())) : null;
    const view =
      mode === "split"
        ? createMemo(() => (isPending(id) ? -1 : secondary()))
        : createMemo(() => {
            const value = id();
            return isPending(id) ? -1 : load("secondary", value);
          });
    for (const [key, read] of Object.entries({ id, primary, view, pending: () => isPending(id) }))
      createRenderEffect(
        read,
        value => {
          shown[key] = value;
          frames.push({ key, value });
        },
        { schedule: true }
      );
  });
  const snapshot = phase => snapshots.push({ phase, shown: { ...shown }, events: [...events] });
  flush();
  write(1);
  flush();
  await turn();
  snapshot("requests started");
  for (const job of jobs) if (job.kind === "primary") job.gate.resolve();
  await turn();
  snapshot("primary answered");
  for (let round = 0; round < 3; round++) {
    for (const job of [...jobs]) if (job.kind === "secondary" && !job.done) job.gate.resolve();
    await turn();
    snapshot(`secondary answers ${round + 1}`);
  }
  results[mode] = {
    starts: jobs.map(({ kind, value, number, cancelled }) => ({ kind, value, number, cancelled })),
    snapshots,
    frames
  };
  dispose();
  flush();
}
console.log(JSON.stringify(results, null, 2));
