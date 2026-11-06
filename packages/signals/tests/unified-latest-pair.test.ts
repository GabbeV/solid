import { expect, it } from "vitest";
import {
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest
} from "../src/index.js";

it("a latest observation and its pending output publish a settled answer coherently", async () => {
  let set!: (value: number) => number, finish!: () => void, dispose!: () => void;
  const shown: [boolean, number][] = [];
  createRoot(cleanup => {
    dispose = cleanup;
    const [id, write] = createSignal(1);
    set = write;
    const data = createMemo(() => {
      const value = id() * 10;
      return new Promise<number>(resolve => {
        finish = () => resolve(value);
      });
    });
    createRenderEffect(data, () => {}, { schedule: true });
    createRenderEffect(
      () => [isPending(() => latest(data)), latest(data)] as [boolean, number],
      value => {
        shown.push(value);
      },
      { schedule: true }
    );
  });
  try {
    flush();
    finish();
    await new Promise(resolve => setTimeout(resolve, 0));
    expect(shown.at(-1)).toEqual([false, 10]);
    set(2);
    flush();
    expect(shown.at(-1)).toEqual([true, 10]);
    finish();
    await new Promise(resolve => setTimeout(resolve, 0));
    expect(shown.at(-1)).toEqual([false, 20]);
    expect(shown).not.toContainEqual([true, 20]);
  } finally {
    dispose();
    flush();
  }
});
