import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup
} from "../src/index.js";
import { $REFRESH } from "../src/core/constants.js";
import { boundaries } from "../src/layers/boundary.js";
import { resolveTx, transactions, transactionNodes } from "../src/core/scheduler.js";

it("settled synchronous subtrees do not allocate updates while an unrelated action is open", async () => {
  const end = Promise.withResolvers<void>();
  const [input, setInput] = createSignal(0), [settled] = createSignal(5);
  let shown = -1, cleanups = 0;
  const dispose = createRoot(dispose => {
    createRenderEffect(input, value => { shown = value; });
    return dispose;
  });
  const running = action(function* () {
    setInput(1);
    yield end.promise;
  })();
  try {
    flush();
    expect(shown).toBe(0);
    const live = transactions.length;
    for (let i = 0; i < 500; i++) {
      createRoot(dispose => {
        const doubled = createMemo(() => {
          onCleanup(() => cleanups++);
          return settled() * 2;
        });
        expect(doubled()).toBe(10);
        dispose();
      });
      // No flush between subtrees: empty provisional records must not grow
      // until a later flush happens to collect them.
      expect(transactions.length).toBe(live);
      expect(cleanups).toBe(i + 1);
    }
    expect(shown).toBe(0);
    end.resolve();
    await running;
    flush();
    expect(shown).toBe(1);
  } finally {
    end.resolve();
    await running;
    dispose();
    flush();
  }
});

it("a long-lived optimistic scope retains bounded transaction records across repeated publications", async () => {
  const answer = Promise.withResolvers<number>();
  let start!: () => void, step!: (value: number) => void;
  let inspect!: () => { nodes: number; reruns: number };
  let shown = "0/0";
  const dispose = createRoot(dispose => {
    const [id, setId] = createSignal(0),
      [tick, setTick] = createSignal(0);
    const input = createMemo(() => (id() ? answer.promise : 0));
    const [view, guess] = createOptimistic(input);
    createRenderEffect(input, () => {}, { schedule: true });
    createRenderEffect(
      () => `${view()}/${tick()}`,
      value => {
        shown = value;
      },
      { schedule: true }
    );
    start = () => {
      setId(1);
      guess(5);
    };
    step = value => {
      setTick(value);
      guess(value + 5);
    };
    // The upstream test requires a legacy lane on _transaction. Inspect the
    // equivalent live lifetime here, without pretending that layout survived.
    inspect = () => {
      const layer = boundaries.get((view as any)[$REFRESH])!;
      const scope = resolveTx(layer._scope!);
      return { nodes: Array.from(transactionNodes(scope)).length, reruns: scope._reruns?.size ?? 0 };
    };
    return dispose;
  });
  try {
    flush();
    start();
    flush();
    expect(shown).toBe("5/0");
    step(1);
    flush();
    const before = inspect();
    for (let value = 2; value <= 500; value++) {
      step(value);
      flush();
      expect(shown).toBe(`${value + 5}/${value}`);
      expect(inspect()).toEqual(before);
    }
    answer.resolve(505);
    await new Promise(resolve => setTimeout(resolve, 0));
    expect(shown).toBe("505/500");
  } finally {
    answer.resolve(505);
    dispose();
    flush();
  }
});
