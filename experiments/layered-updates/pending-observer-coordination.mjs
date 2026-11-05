// Two calls about one source read one shared pending output.
import { pathToFileURL, fileURLToPath } from "node:url";
import { resolve, dirname } from "node:path";
const here = dirname(fileURLToPath(import.meta.url));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
for (const implementation of ["baseline", "candidate"]) {
  const { createSignal, createMemo, createRoot, createRenderEffect, pending, action, flush } =
    await import(pathToFileURL(resolve(here, "results", `${implementation}-pending.mjs`)));
  let finish, answer, dispose;
  const end = new Promise(resolve => {
    finish = resolve;
  });
  const work = new Promise(resolve => {
    answer = resolve;
  });
  const [x, setX] = createSignal(0);
  const shown = { fast: false, slow: false, label: "idle" };
  createRoot(d => {
    dispose = d;
    const fast = pending(x),
      slow = pending(x);
    const label = createMemo(() => (slow() ? work : "idle"));
    createRenderEffect(fast, value => {
      shown.fast = value;
    });
    createRenderEffect(slow, value => {
      shown.slow = value;
    });
    createRenderEffect(label, value => {
      shown.label = value;
    });
  });
  flush();
  const running = action(function* () {
    setX(1);
    yield end;
  })();
  flush();
  console.log(JSON.stringify({ implementation, step: "input action and label pending", ...shown }));
  answer("pending");
  await turn();
  console.log(JSON.stringify({ implementation, step: "label resolves", ...shown }));
  finish();
  await running;
  await turn();
  dispose();
}
