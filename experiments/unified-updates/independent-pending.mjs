import assert from "node:assert/strict";
// Verify the accepted scope of an optimistic observation's committed frame.
import { pathToFileURL } from "node:url";
import { resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
const here = dirname(fileURLToPath(import.meta.url));
const turn = () => new Promise(resolve => setTimeout(resolve, 0));
for (const implementation of ["baseline", "candidate"]) {
  const { createSignal, createMemo, createRoot, createRenderEffect, pending, action, flush } =
    await import(pathToFileURL(resolve(here, "results", `${implementation}-pending.mjs`)));
  let finishX, finishY, dispose;
  const xEnd = new Promise(resolve => {
    finishX = resolve;
  });
  const yEnd = new Promise(resolve => {
    finishY = resolve;
  });
  const [x, setX] = createSignal(0),
    [y, setY] = createSignal(0);
  const screen = { status: false, y: 0, pair: "false:0" };
  createRoot(d => {
    dispose = d;
    const status = pending(x);
    const pair = createMemo(() => `${status()}:${y()}`);
    createRenderEffect(status, value => {
      screen.status = value;
    });
    createRenderEffect(y, value => {
      screen.y = value;
    });
    createRenderEffect(pair, value => {
      screen.pair = value;
    });
  });
  const frames = [];
  const snapshot = step => {
    frames.push([screen.status, screen.y, screen.pair]);
    console.log(JSON.stringify({ implementation, step, ...screen }));
  };
  flush();
  snapshot("initial");
  const other = action(function* () {
    setY(10);
    yield yEnd;
  })();
  flush();
  snapshot("y = 10 held");
  const changing = action(function* () {
    setX(1);
    yield xEnd;
  })();
  flush();
  snapshot("x = 1 also held");
  finishY();
  await other;
  await turn();
  snapshot("y action ends");
  finishX();
  await changing;
  await turn();
  snapshot("x action ends");
  dispose();
  if (implementation === "candidate")
    assert.deepEqual(frames, [
      [false, 0, "false:0"],
      [false, 0, "false:0"],
      [true, 0, "true:0"],
      [true, 10, "true:10"],
      [false, 10, "false:10"]
    ]);
}
