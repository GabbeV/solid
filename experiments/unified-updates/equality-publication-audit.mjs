// The same observable equality/lifetime timelines against actual production builds.
import { pathToFileURL } from "node:url";
const {
  action,
  createMemo,
  createOptimistic,
  createSignal,
  createRoot,
  createRenderEffect,
  onCleanup,
  refresh,
  flush
} = await import(pathToFileURL(process.argv[2]));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
const report = {};
const ordinary = process.argv.includes("--ordinary");
for (const refetch of [false, true]) {
  const change = Promise.withResolvers(),
    end = Promise.withResolvers(),
    answer = Promise.withResolvers();
  let guess,
    detail,
    dispose,
    runs = 0,
    cleanups = 0,
    requests = 0,
    reload = false;
  const shown = { view: -1, detail: -1 };
  createRoot(d => {
    dispose = d;
    const [view, write] = ordinary ? createSignal(0) : createOptimistic(() => 0);
    guess = write;
    const parity = createMemo(() => view() % 2);
    detail = createMemo(() => {
      const value = parity();
      runs++;
      onCleanup(() => {
        cleanups++;
      });
      if (!reload) return value;
      requests++;
      return answer.promise.then(() => value);
    });
    createRenderEffect(
      view,
      value => {
        shown.view = value;
      },
      { schedule: true }
    );
    createRenderEffect(
      detail,
      value => {
        shown.detail = value;
      },
      { schedule: true }
    );
  });
  flush();
  const running = ordinary
    ? (guess(1), Promise.resolve())
    : action(function* () {
        guess(1);
        yield change.promise;
        guess(3);
        yield end.promise;
      })();
  flush();
  let refreshed;
  if (refetch) {
    reload = true;
    refreshed = refresh(detail);
    await turn();
  }
  const before = { ...shown, runs, cleanups, requests };
  if (ordinary) guess(3);
  else change.resolve();
  await turn();
  const after = { ...shown, runs, cleanups, requests };
  answer.resolve();
  if (refreshed) await refreshed;
  end.resolve();
  await running;
  await turn();
  report[refetch ? "pendingChild" : "settledChild"] = { before, after };
  dispose();
  flush();
}
console.log(JSON.stringify(report, null, 2));
