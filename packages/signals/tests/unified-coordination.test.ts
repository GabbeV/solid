import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";
// Exercise ordinary coordination with the experimental boundary hooks installed.
import "../src/layers/layer.js";
import { flushTransaction, resolveTx, type Transaction } from "../src/core/scheduler.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>(r => {
    resolve = r;
  });
  return { promise, resolve };
}
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("rerun bookkeeping stays bounded during an open action and releases disposed readers", async () => {
  const end = gate<void>();
  const [x, setX] = createSignal(0),
    [tick, setTick] = createSignal(0);
  let holder!: Transaction;
  let shown: readonly number[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => [tick(), x()],
      value => {
        shown = value;
      }
    );
    return dispose;
  });
  const running = action(function* () {
    setX(1);
    holder = flushTransaction!;
    yield end.promise;
  })();
  flush();
  for (let i = 1; i <= 1000; i++) {
    setTick(i);
    flush();
    expect(shown).toEqual([i, 0]);
  }
  expect(resolveTx(holder)._reruns?.size).toBe(1);
  dispose();
  expect(resolveTx(holder)._reruns).toBe(null);
  end.resolve();
  await running;
  await turn();
});

for (const xFirst of [true, false]) {
  it(`a reader of two committed inputs updates when either hold ends (x first ${xFirst})`, async () => {
    const xEnd = gate<void>(),
      yEnd = gate<void>();
    const [x, setX] = createSignal(0),
      [y, setY] = createSignal(0),
      [tick, setTick] = createSignal(0);
    let shown: readonly number[] = [];
    const dispose = createRoot(dispose => {
      createRenderEffect(
        () => [tick(), x(), y()],
        value => {
          shown = value;
        }
      );
      return dispose;
    });
    const a = action(function* () {
      setX(1);
      yield xEnd.promise;
    })();
    flush();
    const b = action(function* () {
      setY(2);
      yield yEnd.promise;
    })();
    flush();
    setTick(1);
    flush();
    expect(shown).toEqual([1, 0, 0]);
    (xFirst ? xEnd : yEnd).resolve();
    await (xFirst ? a : b);
    await turn();
    expect(shown).toEqual(xFirst ? [1, 1, 0] : [1, 0, 2]);
    (xFirst ? yEnd : xEnd).resolve();
    await (xFirst ? b : a);
    await turn();
    expect(shown).toEqual([1, 1, 2]);
    dispose();
    flush();
  });
}

it("peer proposals sharing one async result merge; unrelated output remains independent", async () => {
  const aEnd = gate<void>(),
    bEnd = gate<void>();
  const results = [gate<number>(), gate<number>()];
  const [a, setA] = createSignal(0),
    [b, setB] = createSignal(0);
  const [other, setOther] = createSignal(0);
  const started: number[] = [];
  let shown: readonly number[] = [0, 0, 0];
  let independent = 0;
  const direct = [0, 0, 0];
  const dispose = createRoot(dispose => {
    const sum = createMemo(() => a() + b());
    const label = createMemo(() => {
      const value = sum();
      if (!value) return 0;
      started.push(value);
      return results[value - 1].promise;
    });
    createRenderEffect(
      () => [a(), b(), label()],
      value => {
        shown = value;
      }
    );
    [a, b, label].forEach((read, i) =>
      createRenderEffect(read, value => {
        direct[i] = value;
      })
    );
    createRenderEffect(other, value => {
      independent = value;
    });
    return dispose;
  });
  const first = action(function* () {
    setA(1);
    yield aEnd.promise;
  })();
  flush();
  const second = action(function* () {
    setB(1);
    yield bEnd.promise;
  })();
  flush();
  expect(started).toEqual([1, 2]);
  setOther(9);
  flush();
  expect([independent, shown, direct]).toEqual([9, [0, 0, 0], [0, 0, 0]]);
  aEnd.resolve();
  await first;
  results[0].resolve(1);
  await turn();
  expect([shown, direct]).toEqual([
    [0, 0, 0],
    [0, 0, 0]
  ]);
  results[1].resolve(2);
  await turn();
  expect([shown, direct]).toEqual([
    [0, 0, 0],
    [0, 0, 0]
  ]);
  bEnd.resolve();
  await second;
  await turn();
  expect([shown, direct]).toEqual([
    [1, 1, 2],
    [1, 1, 2]
  ]);
  dispose();
  flush();
});
