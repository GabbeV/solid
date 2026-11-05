import { pathToFileURL } from "node:url";
const { createSignal, createMemo, createRoot, createRenderEffect, optimistic, action, flush } =
  await import(pathToFileURL(process.argv[2]));
let sink = 0;
const timings = {};
function measure(name, count, run) {
  for (let warm = 0; warm < 3; warm++) run(count);
  global.gc();
  const start = performance.now();
  run(count);
  timings[name] = ((performance.now() - start) * 1e6) / count;
}
// Cost of importing optimism and keeping one inactive boundary alive.
let inactiveDispose;
createRoot(d => {
  inactiveDispose = d;
  const [view] = optimistic(() => 0);
  createRenderEffect(view, () => {});
});
const [ordinary, setOrdinary] = createSignal(0);
measure("inactive-ordinary-read-ns", 2_000_000, n => {
  for (let i = 0; i < n; i++) sink += ordinary();
});
let ordinaryValue = 0;
const ordinaryUpdate = () => setOrdinary(++ordinaryValue);
measure("inactive-ordinary-write-ns", 100_000, n => {
  for (let i = 0; i < n; i++) flush(ordinaryUpdate);
});
inactiveDispose();

for (const direct of [false, true])
  for (const depth of [1, 4, 16]) {
    let guess,
      dispose,
      finish,
      value = 1;
    const releases = [];
    createRoot(d => {
      dispose = d;
      const source = createSignal(0)[0];
      let view = source;
      for (let i = 0; i < depth; i++) {
        const input = view;
        const [next, write, clear] = optimistic(direct ? input : () => input());
        if (!i) guess = write;
        if (clear) releases.push(clear);
        view = createMemo(() => next() + 1);
      }
      createRenderEffect(view, v => {
        sink = v;
      });
    });
    const end = new Promise(resolve => {
      finish = resolve;
    });
    const running = action(function* () {
      guess(1);
      yield end;
    })();
    flush();
    const update = () => guess(++value);
    measure(`active-${direct ? "direct-" : ""}depth-${depth}-write-ns`, 20_000, n => {
      for (let i = 0; i < n; i++) flush(update);
    });
    if (sink !== value + depth) throw new Error(`Incorrect result at depth ${depth}: ${sink}`);
    finish();
    await running;
    await new Promise(resolve => setTimeout(resolve, 0));
    for (const clear of releases) clear();
    flush();
    dispose();
  }
console.log(JSON.stringify({ timings, sink }));
