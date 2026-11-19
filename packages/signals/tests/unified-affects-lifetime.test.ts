import { it, expect } from "vitest";
import {
  action,
  affects,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending
} from "../src/index.js";

it("mark hands pending over to a later upstream update with async between", async () => {
  const actionEnd = Promise.withResolvers<void>();
  const answer = Promise.withResolvers<number>();
  const app = createRoot(dispose => {
    const [event, emit] = createSignal(0);
    const middle = createMemo(() => (event() === 0 ? 0 : answer.promise));
    let runs = 0;
    const data = createMemo(() => {
      runs++;
      return middle() * 2;
    });
    const pending: boolean[] = [];
    const values: number[] = [];
    createRenderEffect(data, v => void values.push(v));
    createRenderEffect(
      () => isPending(data),
      p => void pending.push(p)
    );
    return { dispose, emit, data, pending, values, runs: () => runs };
  });
  flush();
  const running = action(function* () {
    affects(app.data);
    yield actionEnd.promise;
  })();
  try {
    flush();
    expect(app.pending).toEqual([false, true]);
    expect(app.runs()).toBe(1);
    app.emit(1);
    flush();
    actionEnd.resolve();
    await running;
    flush();
    expect(app.pending).toEqual([false, true]);
    expect(app.values).toEqual([0]);
    answer.resolve(2);
    await new Promise(r => setTimeout(r, 0));
    flush();
    expect(app.pending).toEqual([false, true, false]);
    expect(app.values).toEqual([0, 4]);
  } finally {
    answer.resolve(2);
    actionEnd.resolve();
    await running;
    app.dispose();
    flush();
  }
});

it("a declaration resolving equal changes pending without recalculating values", async () => {
  const end = Promise.withResolvers<void>();
  const app = createRoot(dispose => {
    const [source] = createSignal(1);
    let runs = 0;
    const value = createMemo(() => {
      runs++;
      return source() * 2;
    });
    const pending: boolean[] = [];
    const values: number[] = [];
    createRenderEffect(value, v => void values.push(v));
    createRenderEffect(
      () => isPending(value),
      p => void pending.push(p)
    );
    return { dispose, source, pending, values, runs: () => runs };
  });
  flush();
  const running = action(function* () {
    affects(app.source);
    yield end.promise;
  })();
  try {
    flush();
    expect(app.pending).toEqual([false, true]);
    expect(app.runs()).toBe(1);
    end.resolve();
    await running;
    flush();
    expect(app.pending).toEqual([false, true, false]);
    expect(app.values).toEqual([2]);
    expect(app.runs()).toBe(1);
  } finally {
    end.resolve();
    await running;
    app.dispose();
    flush();
  }
});
