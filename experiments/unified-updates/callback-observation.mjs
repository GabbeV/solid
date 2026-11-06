// A callback probe observes reads, not its return value; both APIs should agree.
import { pathToFileURL, fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
const here = dirname(fileURLToPath(import.meta.url));
for (const implementation of ["baseline", "candidate"]) {
  const { createSignal, createRoot, createRenderEffect, pending, action, flush } = await import(
    pathToFileURL(resolve(here, "results", `${implementation}-pending.mjs`))
  );
  let finish, dispose;
  const end = new Promise(resolve => {
    finish = resolve;
  });
  const [x, setX] = createSignal(0);
  const shown = { direct: false, callback: false };
  createRoot(d => {
    dispose = d;
    const direct = pending(x);
    const callback = pending(() => {
      x();
      return 0;
    });
    createRenderEffect(direct, value => {
      shown.direct = value;
    });
    createRenderEffect(callback, value => {
      shown.callback = value;
    });
  });
  flush();
  const running = action(function* () {
    setX(1);
    yield end;
  })();
  flush();
  console.log(JSON.stringify({ implementation, ...shown }));
  finish();
  await running;
  flush();
  dispose();
}
