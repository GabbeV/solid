// Characterize the two nestings of pending/latest, including a memo wrapper.
import { pathToFileURL } from "node:url";
const { action, createSignal, createMemo, createRoot, createRenderEffect,
  flush, latest, isPending } = await import(pathToFileURL(process.argv[2]));
const [x, setX] = createSignal(0);
let finish, dispose;
const end = new Promise(resolve => { finish = resolve; });
const shown = {};
createRoot(d => {
  dispose = d;
  const pending = createMemo(() => isPending(x));
  const reads = {
    x,
    latestX: () => latest(x),
    pending,
    latestPendingDirect: () => latest(() => isPending(x)),
    latestPendingCallback: () => latest(() => isPending(() => x())),
    latestPendingMemo: () => latest(pending),
    pendingLatestDirect: () => isPending(() => latest(x)),
    pendingLatestCallback: () => isPending(() => latest(() => x()))
  };
  for (const [key, read] of Object.entries(reads))
    createRenderEffect(read, value => { shown[key] = value; });
});
flush();
const frames = [{ event: "initial", ...shown }];
const running = action(function* () { setX(1); yield end; })();
flush();
frames.push({ event: "action open", ...shown });
finish();
await running;
await new Promise(resolve => setTimeout(resolve, 0));
frames.push({ event: "action ends", ...shown });
dispose();
flush();
console.log(JSON.stringify(frames, null, 2));
