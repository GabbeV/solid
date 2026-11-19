import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";
const settle = async () => {
  await new Promise(resolve => setTimeout(resolve, 0));
  flush();
};
it("a loadingValue memo keeps its committed seed when its first calculation is held", async () => {
  const [source, setSource] = createSignal(0);
  const gate = Promise.withResolvers<void>();
  const running = action(function* () {
    setSource(10);
    yield gate.promise;
  })();
  flush();
  let read!: () => number;
  const frames: number[] = [];
  const dispose = createRoot(dispose => {
    read = createMemo(source, { loadingValue: 0 });
    createRenderEffect(read, value => {
      frames.push(value);
    });
    return dispose;
  });
  try {
    flush();
    expect(read()).toBe(0);
    gate.resolve();
    await running;
    await settle();
    expect(read()).toBe(10);
    expect(frames.at(-1)).toBe(10);
  } finally {
    gate.resolve();
    await running;
    dispose();
    flush();
  }
});
