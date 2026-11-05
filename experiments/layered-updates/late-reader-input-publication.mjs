// Compare a late reader of already-published inputs with a late reader of held
// inputs. The optional existing reader determines whether the request holds.
import { pathToFileURL } from "node:url";
const {
  action, createMemo, createRenderEffect, createRoot, createSignal, flush, latest, onCleanup
} = await import(pathToFileURL(process.argv[2]));
const mode = process.argv[3] || "ordinary";
const observed = process.argv[4] === "observed";
const end = Promise.withResolvers(), next = Promise.withResolvers();
const jobs = new Map(), events = [], snapshots = [];
const shown = { input: 0, mounted: false, child: "absent", existing: "absent" };
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
let set, mount;
const dispose = createRoot(dispose => {
  const [source, setSource] = createSignal(0);
  const [mounted, setMounted] = createSignal(false);
  set = setSource; mount = () => setMounted(true);
  const input = mode === "latest" ? () => latest(source) : source;
  const derived = createMemo(() => {
    const value = input();
    if (!value) return 0;
    const job = Promise.withResolvers();
    jobs.set(value, job);
    return job.promise;
  });
  const binding = key => value => { shown[key] = value; events.push({ key, value }); };
  createRenderEffect(input, binding("input"), { schedule: true });
  createRenderEffect(mounted, binding("mounted"), { schedule: true });
  if (observed) createRenderEffect(derived, binding("existing"), { schedule: true });
  createRenderEffect(() => {
    if (mounted()) {
      createRenderEffect(derived, binding("child"), { schedule: true });
      onCleanup(() => { shown.child = "absent"; });
    }
  }, () => {}, { schedule: true });
  return dispose;
});
const snapshot = phase => snapshots.push({ phase, shown: { ...shown } });
flush(); snapshot("initial");
const running = mode === "latest" ? action(function* () {
  set(1); yield next.promise; set(2); yield end.promise;
})() : (set(1), undefined);
flush(); jobs.get(1).resolve(1); await turn(); snapshot("first request ready");
if (mode === "latest") next.resolve(); else set(2);
await turn(); snapshot("second request pending");
mount(); flush(); snapshot("mount attempted");
jobs.get(2).resolve(2); await turn(); snapshot("second request ready");
end.resolve(); await running; await turn(); snapshot("settled");
dispose(); flush();
console.log(JSON.stringify({ mode, observed, snapshots, events }, null, 2));
