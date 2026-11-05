import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending
} from "../src/index.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>(yes => {
    resolve = yes;
  });
  return { promise, resolve };
}
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("the scalar entry composes nested optimism, a repeated guess and pending publication", async () => {
  const repeat = gate<void>(),
    end = gate<void>(),
    answer = gate<number>();
  const [tick, setTick] = createSignal(0);
  let guess!: (value: number) => number;
  const shown = { value: 0, child: 0, result: 0, pending: false, tick: 0 };
  let dispose!: () => void;
  createRoot(d => {
    dispose = d;
    const [value, write] = createOptimistic(() => 0);
    guess = write;
    const doubled = createMemo(() => value() * 2);
    const [child] = createOptimistic(doubled);
    const result = createMemo(() => (child() === 4 ? answer.promise : child()));
    createRenderEffect(
      () => [tick(), value()] as const,
      ([t, v]) => {
        shown.tick = t;
        shown.value = v;
      }
    );
    createRenderEffect(child, value => {
      shown.child = value;
    });
    createRenderEffect(result, value => {
      shown.result = value;
    });
    createRenderEffect(
      () => isPending(result),
      value => {
        shown.pending = value;
      }
    );
  });
  try {
    flush();
    const running = action(function* () {
      guess(1);
      yield repeat.promise;
      guess(2);
      yield end.promise;
    })();
    flush();
    expect(shown).toEqual({ value: 1, child: 2, result: 2, pending: false, tick: 0 });
    repeat.resolve();
    await turn();
    setTick(1);
    flush();
    expect(shown).toEqual({ value: 1, child: 2, result: 2, pending: true, tick: 1 });
    answer.resolve(4);
    await turn();
    expect(shown).toEqual({ value: 2, child: 4, result: 4, pending: false, tick: 1 });
    end.resolve();
    await running;
    await turn();
    expect(shown).toEqual({ value: 0, child: 0, result: 0, pending: false, tick: 1 });
  } finally {
    end.resolve();
    dispose();
    flush();
  }
});
