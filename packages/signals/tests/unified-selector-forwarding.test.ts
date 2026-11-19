import { expect, it } from "vitest";
import {
  action, createMemo, createOptimistic, createRenderEffect, createRoot, flush
} from "../src/index.js";
import { transactions } from "../src/core/scheduler.js";

it("an unobserved guess made before an action joins that action's lifetime", async () => {
  const [view, guess] = createOptimistic(0);
  const end = Promise.withResolvers<void>();
  guess(1);
  const running = action(function* () { yield end.promise; })();
  try {
    flush();
    expect(view()).toBe(1);
    for (let i = 0; i < 100; i++) {
      guess(1);
      flush();
      expect(view()).toBe(1);
      expect(transactions).toHaveLength(1); // only the still-open action
    }
    end.resolve();
    await running;
    flush();
    expect(view()).toBe(0);
  } finally {
    end.resolve();
    await running;
    flush();
  }
});

it("a batch publishes every unobserved guess, including equal writes, and retires all of them", async () => {
  const end = Promise.withResolvers<void>();
  let views!: Array<ReturnType<typeof createOptimistic<number>>>;
  const dispose = createRoot(dispose => {
    views = Array.from({ length: 32 }, () => createOptimistic(() => 0));
    return dispose;
  });
  flush();
  const running = action(function* () {
    for (let i = 0; i < views.length; i++) views[i][1](i);
    yield end.promise;
  })();
  try {
    flush();
    expect(views.map(([view]) => view())).toEqual(Array.from({ length: 32 }, (_, i) => i));
    for (const [, guess] of views) guess(2);
    flush();
    expect(views.map(([view]) => view())).toEqual(Array(32).fill(2));
    // Every publication update has landed, leaving only the shared lifetime.
    expect(transactions).toHaveLength(1);
    end.resolve();
    await running;
    flush();
    expect(views.map(([view]) => view())).toEqual(Array(32).fill(0));
    expect(transactions).toHaveLength(0);
  } finally {
    end.resolve();
    await running;
    dispose();
    flush();
  }
});

it("transparent selectors preserve scalar and callable values like an equivalent custom comparator", async () => {
  const end = Promise.withResolvers<void>();
  let guess!: (value: unknown) => unknown;
  let first!: () => unknown;
  let shown: readonly unknown[] = [];
  const dispose = createRoot(dispose => {
    [first, guess] = createOptimistic<unknown>(0);
    const input = createMemo(() => first());
    const [plain] = createOptimistic(() => input());
    const [custom] = createOptimistic(() => input(), { equals: (a, b) => a === b });
    createRenderEffect(() => [first(), plain(), custom()], value => { shown = value; });
    return dispose;
  });
  flush();
  const running = action(function* () { guess(1); yield end.promise; })();
  try {
    flush();
    expect(shown).toEqual([1, 1, 1]);
    const callable = () => { throw new Error("a function value must not be called"); };
    for (const value of [callable, null, { label: "value" }, NaN, -0, 3, 0]) {
      guess(() => value);
      flush();
      for (const actual of shown) expect(Object.is(actual, value)).toBe(true);
    }
    end.resolve();
    await running;
    flush();
    expect(shown).toEqual([0, 0, 0]);
  } finally {
    end.resolve();
    await running;
    dispose();
    flush();
  }
});
