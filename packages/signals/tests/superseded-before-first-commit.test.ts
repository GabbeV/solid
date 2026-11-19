/**
 * An optimistic input's first answer is held by downstream async. A later
 * action guesses 3, then receives input 2 while remaining open. Neither the
 * initial answer nor the guess has published: an outside reader still has
 * no committed output, and the node is loading rather than pending.
 */
import { describe, expect, it } from "vitest";
import {
  action,
  NotReadyError,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest
} from "../src/index.js";

const settle = async () => {
  await Promise.resolve();
  await Promise.resolve();
  flush();
};

function graph() {
  const holds: Array<() => void> = [];
  const never = () => new Promise<never>(r => holds.push(r as () => void));
  const [value, setValue] = createSignal(0);
  const fetches: Array<() => void> = [];
  const flights: Array<() => void> = [];
  let x!: () => number;
  let setX!: (v: number) => void;
  createRoot(() => {
    [x, setX] = createOptimistic(() => {
      const v = value();
      return new Promise<number>(r => fetches.push(() => r(v * 2)));
    });
    const downstream = createMemo(() => {
      const n = x();
      return new Promise<string>(r => flights.push(() => r(`${n}!`)));
    });
    createRenderEffect(downstream, () => {});
  });
  return {
    x,
    setX,
    setValue,
    fetches,
    flights,
    never,
    async release() {
      for (const r of holds.splice(0)) r();
      for (const f of flights.splice(0)) f();
      await settle();
      await settle();
    }
  };
}

describe("A18 (d) before the first commit", () => {
  it("a never-published output is loading, and an imperative latest read has no value to return", async () => {
    const g = graph();
    flush();
    g.fetches.shift()!(); // x's first landing (0) — held by the downstream reveal, which never lands
    await settle();
    action(function* () {
      g.setValue(1);
      g.setX(3); // accepted, but its downstream work still holds publication
      yield g.never();
    })();
    flush();
    g.fetches.shift()!(); // own source lands 2 ≠ 3
    await settle();
    // Never committed, the node has nothing to serve a direct read (A19
    // exc. 1: loading, not pending); an imperative `latest` read also has
    // no published output to return.
    expect(() => g.x()).toThrow(NotReadyError);
    expect(() => latest(g.x)).toThrow(NotReadyError);
    expect(isPending(g.x)).toBe(false); // loading, not pending (A19 exc. 1)
    await g.release();
  });
});
