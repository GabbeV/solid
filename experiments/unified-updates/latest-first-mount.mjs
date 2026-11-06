import { pathToFileURL } from "node:url";
const { createSignal, createRoot, createMemo, createRenderEffect, action, flush, latest } =
  await import(pathToFileURL(process.argv[2]));
for (const sourceFirst of [false, true]) {
  let finish, dispose, memo;
  const end = new Promise(r => {
    finish = r;
  });
  const [x, setX] = createSignal(0);
  const frames = [];
  const running = action(function* () {
    setX(1);
    yield end;
  })();
  flush();
  createRoot(d => {
    dispose = d;
    memo = createMemo(() => {
      if (sourceFirst) {
        const value = x();
        return [value, latest(x)];
      }
      const ahead = latest(x);
      return [x(), ahead];
    });
    createRenderEffect(
      memo,
      value => {
        frames.push([...value]);
      },
      { schedule: true }
    );
  });
  let initial;
  try {
    initial = memo();
  } catch (e) {
    initial = e.constructor.name;
  }
  flush();
  console.log(JSON.stringify({ sourceFirst, event: "mounted during hold", initial, frames }));
  finish();
  await running;
  await new Promise(r => setTimeout(r, 0));
  console.log(JSON.stringify({ sourceFirst, event: "action ends", frames }));
  dispose();
  flush();
}
