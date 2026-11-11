import { expect, it } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest,
  untrack
} from "../src/index.js";

const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

it("a superseding request replaces a dormant pending observation's earlier restoration", async () => {
  const [id, setId] = createSignal(0);
  const requests = [
    Promise.withResolvers<number>(),
    Promise.withResolvers<number>(),
    Promise.withResolvers<number>()
  ];
  const restoration = Promise.withResolvers<number>();
  const calculations: (readonly [number, boolean])[] = [];
  const screen: number[] = [];
  let source!: () => number;
  const dispose = createRoot(dispose => {
    source = createMemo(() => requests[id()].promise);
    const frame = createMemo(() => {
      const value = source();
      const pending = untrack(() => isPending(source));
      calculations.push([value, pending]);
      return value === 1 && !pending ? restoration.promise : value;
    });
    createRenderEffect(frame, value => {
      screen.push(value);
    });
    return dispose;
  });
  try {
    flush();
    requests[0].resolve(0);
    await turn();
    setId(1);
    flush();
    requests[1].resolve(1);
    await turn();
    expect(calculations.at(-1)).toEqual([1, false]);
    expect(screen).toEqual([0]);
    // This companion becomes dormant while its false restoration is held.
    isPending(source);
    flush();
    await turn();
    setId(2);
    flush();
    expect(isPending(source)).toBe(true);
    expect(latest(source)).toBe(1);
    expect(screen).toEqual([0]);
    requests[2].resolve(2);
    await turn();
    expect(calculations.at(-1)).toEqual([2, false]);
    expect(screen).toEqual([0, 2]);
    restoration.resolve(1);
    await turn();
    expect(screen).toEqual([0, 2]);
  } finally {
    restoration.resolve(1);
    requests[2].resolve(2);
    dispose();
    await turn();
  }
});
