import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";
import { computed, read, signal } from "../src/core/core.js";
import { txOf } from "../src/core/scheduler.js";
import { positionOf } from "../src/layers/coordination.js";
import { createOptimisticSlot, withOptimisticSlotBatch } from "../src/layers/optimistic.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it.each(["parent-first", "child-first"])(
  "a setter groups a selected parent with its child input (%s)",
  async order => {
    const answer = Promise.withResolvers<number>();
    const end = Promise.withResolvers<void>();
    const parent = createOptimisticSlot(signal(0));
    const child = createOptimisticSlot(parent.output);
    const shown = { parent: -1, child: -1, async: -1 };
    const dispose = createRoot(dispose => {
      const pending = createMemo(() => (read(parent.output) ? answer.promise : 0));
      createRenderEffect(
        () => read(parent.output),
        value => {
          shown.parent = value;
        }
      );
      createRenderEffect(
        () => read(child.output),
        value => {
          shown.child = value;
        }
      );
      createRenderEffect(pending, value => {
        shown.async = value;
      });
      return dispose;
    });
    let running: Promise<void> | undefined;
    try {
      flush();
      running = action(function* () {
        withOptimisticSlotBatch(() => {
          if (order === "parent-first") {
            parent.propose(1);
            child.propose(1);
          } else {
            child.propose(1);
            parent.propose(1);
          }
        });
        yield end.promise;
      })();
      flush();
      await turn();
      expect(shown).toEqual({ parent: 0, child: 0, async: 0 });
      answer.resolve(10);
      await turn();
      flush();
      expect(shown).toEqual({ parent: 1, child: 1, async: 10 });
    } finally {
      answer.resolve(10);
      end.resolve();
      if (running) await running;
      dispose();
      flush();
    }
  }
);

it("overlapping setter groups transitively share one publication update", async () => {
  const answer = Promise.withResolvers<number>();
  const end = Promise.withResolvers<void>();
  const a = createOptimisticSlot(signal(0));
  const b = createOptimisticSlot(a.output);
  const c = createOptimisticSlot(signal(0));
  const shown = { a: -1, b: -1, c: -1, async: -1 };
  const dispose = createRoot(dispose => {
    const pending = createMemo(() => (read(a.output) ? answer.promise : 0));
    createRenderEffect(
      () => read(a.output),
      value => {
        shown.a = value;
      }
    );
    createRenderEffect(
      () => read(b.output),
      value => {
        shown.b = value;
      }
    );
    createRenderEffect(
      () => read(c.output),
      value => {
        shown.c = value;
      }
    );
    createRenderEffect(pending, value => {
      shown.async = value;
    });
    return dispose;
  });
  let running: Promise<void> | undefined;
  try {
    flush();
    running = action(function* () {
      withOptimisticSlotBatch(() => {
        a.propose(1);
        b.propose(1);
      });
      withOptimisticSlotBatch(() => {
        b.propose(1);
        c.propose(1);
      });
      yield end.promise;
    })();
    flush();
    await turn();
    expect(shown).toEqual({ a: 0, b: 0, c: 0, async: 0 });
    answer.resolve(10);
    await turn();
    flush();
    expect(shown).toEqual({ a: 1, b: 1, c: 1, async: 10 });
  } finally {
    answer.resolve(10);
    end.resolve();
    if (running) await running;
    dispose();
    flush();
  }
});

it("cross-dependent setter groups collapse their publication cycle", async () => {
  const answer = Promise.withResolvers<number>();
  const end = Promise.withResolvers<void>();
  const d = createOptimisticSlot(signal(0));
  const b = createOptimisticSlot(signal(0));
  const a = createOptimisticSlot(b.output);
  const c = createOptimisticSlot(d.output);
  const slots = { a, b, c, d };
  const shown = { a: -1, b: -1, c: -1, d: -1, async: -1 };
  const dispose = createRoot(dispose => {
    const pending = createMemo(() => (read(a.output) ? answer.promise : 0));
    for (const key of ["a", "b", "c", "d"] as const)
      createRenderEffect(
        () => read(slots[key].output),
        value => {
          shown[key] = value;
        }
      );
    createRenderEffect(pending, value => {
      shown.async = value;
    });
    return dispose;
  });
  let running: Promise<void> | undefined;
  try {
    flush();
    running = action(function* () {
      withOptimisticSlotBatch(() => {
        a.propose(1);
        d.propose(1);
      });
      withOptimisticSlotBatch(() => {
        c.propose(1);
        b.propose(1);
      });
      yield end.promise;
    })();
    flush();
    await turn();
    expect(shown).toEqual({ a: 0, b: 0, c: 0, d: 0, async: 0 });
    answer.resolve(10);
    await turn();
    flush();
    expect(shown).toEqual({ a: 1, b: 1, c: 1, d: 1, async: 10 });
  } finally {
    answer.resolve(10);
    end.resolve();
    if (running) await running;
    dispose();
    flush();
  }
});

it("a dependent setter group takes the already grouped input's depth", async () => {
  const end = Promise.withResolvers<void>();
  const levels: Record<string, number> = {};
  const seed = createOptimisticSlot(
    signal(0),
    undefined,
    () => (levels.seed = positionOf(txOf(seed.output)))
  );
  const b = createOptimisticSlot(
    seed.output,
    undefined,
    () => (levels.b = positionOf(txOf(b.output)))
  );
  const c = createOptimisticSlot(
    signal(0),
    undefined,
    () => (levels.c = positionOf(txOf(c.output)))
  );
  const a = createOptimisticSlot(
    b.output,
    undefined,
    () => (levels.a = positionOf(txOf(a.output)))
  );
  const d = createOptimisticSlot(
    signal(0),
    undefined,
    () => (levels.d = positionOf(txOf(d.output)))
  );
  let running: Promise<void> | undefined;
  try {
    running = action(function* () {
      seed.propose(1);
      withOptimisticSlotBatch(() => {
        a.propose(1);
        d.propose(1);
      });
      withOptimisticSlotBatch(() => {
        b.propose(1);
        c.propose(1);
      });
      yield end.promise;
    })();
    flush();
    expect(levels).toEqual({ seed: 1, b: 2, c: 2, a: 3, d: 3 });
  } finally {
    end.resolve();
    if (running) await running;
    flush();
  }
});

it("a held second proposal never publishes after both actions retire", async () => {
  const firstEnd = Promise.withResolvers<void>();
  const secondEnd = Promise.withResolvers<void>();
  const secondAnswer = Promise.withResolvers<number>();
  const parent = createOptimisticSlot(signal(0));
  const child = createOptimisticSlot(parent.output);
  const [tick, setTick] = createSignal(0);
  const shown = { parent: -1, child: -1, answer: -1, tick: -1 };
  const late: number[] = [];
  const dispose = createRoot(dispose => {
    const pending = createMemo(() => {
      const value = read(parent.output);
      return value === 2 ? secondAnswer.promise : value;
    });
    createRenderEffect(
      () => read(parent.output),
      value => {
        shown.parent = value;
      }
    );
    createRenderEffect(
      () => [read(child.output), tick()] as const,
      ([value, clock]) => {
        shown.child = value;
        shown.tick = clock;
      }
    );
    createRenderEffect(pending, value => {
      shown.answer = value;
    });
    return dispose;
  });
  let first: Promise<void> | undefined;
  let second: Promise<void> | undefined;
  let disposeLate: (() => void) | undefined;
  try {
    flush();
    first = action(function* () {
      withOptimisticSlotBatch(() => {
        parent.propose(1);
        child.propose(1);
      });
      yield firstEnd.promise;
    })();
    flush();
    expect(shown).toEqual({ parent: 1, child: 1, answer: 1, tick: 0 });
    second = action(function* () {
      withOptimisticSlotBatch(() => {
        child.propose(2);
        parent.propose(2);
      });
      yield secondEnd.promise;
    })();
    flush();
    await turn();
    expect(shown).toEqual({ parent: 1, child: 1, answer: 1, tick: 0 });
    setTick(1);
    flush();
    disposeLate = createRoot(dispose => {
      createRenderEffect(
        () => read(child.output),
        value => {
          late.push(value);
        }
      );
      return dispose;
    });
    flush();
    expect(shown).toEqual({ parent: 1, child: 1, answer: 1, tick: 1 });
    expect(late).toEqual([1]);
    firstEnd.resolve();
    await first;
    secondEnd.resolve();
    await second;
    await turn();
    flush();
    expect(shown).toEqual({ parent: 0, child: 0, answer: 0, tick: 1 });
    secondAnswer.resolve(20);
    await turn();
    flush();
    expect(shown).toEqual({ parent: 0, child: 0, answer: 0, tick: 1 });
    expect(late.at(-1)).toBe(0);
  } finally {
    firstEnd.resolve();
    secondEnd.resolve();
    secondAnswer.resolve(20);
    if (first) await first;
    if (second) await second;
    disposeLate?.();
    dispose();
    flush();
  }
});

it.each(["parent-first", "child-first"])(
  "repeated held mixed-group proposals keep one depth (%s)",
  async order => {
    const ends = Array.from({ length: 4 }, () => Promise.withResolvers<void>());
    const answers = Array.from({ length: 4 }, () => Promise.withResolvers<number>());
    const parent = createOptimisticSlot(signal(0));
    const child = createOptimisticSlot(parent.output);
    const shown = { parent: -1, child: -1, pending: -1 };
    const dispose = createRoot(dispose => {
      const pending = createMemo(() => {
        const value = read(parent.output);
        return value ? answers[value - 1].promise : 0;
      });
      createRenderEffect(
        () => read(parent.output),
        value => {
          shown.parent = value;
        }
      );
      createRenderEffect(
        () => read(child.output),
        value => {
          shown.child = value;
        }
      );
      createRenderEffect(pending, value => {
        shown.pending = value;
      });
      return dispose;
    });
    const running: Promise<void>[] = [];
    const depths: [number, number][] = [];
    try {
      flush();
      for (let value = 1; value <= 4; value++) {
        const end = ends[value - 1];
        running.push(
          action(function* () {
            withOptimisticSlotBatch(() => {
              if (order === "parent-first") {
                parent.propose(value);
                child.propose(value);
              } else {
                child.propose(value);
                parent.propose(value);
              }
            });
            yield end.promise;
          })()
        );
        flush();
        depths.push([positionOf(txOf(parent.output)), positionOf(txOf(child.output))]);
      }
      expect(depths).toEqual([
        [1, 1],
        [1, 1],
        [1, 1],
        [1, 1]
      ]);
      expect(shown).toEqual({ parent: 0, child: 0, pending: 0 });
      for (let i = 0; i < 3; i++) {
        answers[i].resolve((i + 1) * 10);
        await turn();
        flush();
        expect(shown).toEqual({ parent: 0, child: 0, pending: 0 });
      }
      answers[3].resolve(40);
      await turn();
      flush();
      expect(shown).toEqual({ parent: 4, child: 4, pending: 40 });
    } finally {
      for (const answer of answers) answer.resolve(10);
      for (const end of ends) end.resolve();
      await Promise.all(running);
      dispose();
      flush();
    }
  }
);

it.each(["parent-first", "child-first"])(
  "an external held input stays below repeated mixed-group proposals (%s)",
  async order => {
    const externalEnd = Promise.withResolvers<void>();
    const externalAnswer = Promise.withResolvers<number>();
    const ends = Array.from({ length: 3 }, () => Promise.withResolvers<void>());
    const answers = Array.from({ length: 3 }, () => Promise.withResolvers<number>());
    const external = createOptimisticSlot(signal(0));
    const parent = createOptimisticSlot(external.output);
    const child = createOptimisticSlot(parent.output);
    const dispose = createRoot(dispose => {
      const externalPending = createMemo(() =>
        read(external.output) ? externalAnswer.promise : 0
      );
      const pending = createMemo(() => {
        const value = read(parent.output);
        return value ? answers[value - 1].promise : 0;
      });
      createRenderEffect(externalPending, () => {});
      createRenderEffect(pending, () => {});
      createRenderEffect(
        () => read(child.output),
        () => {}
      );
      return dispose;
    });
    const running: Promise<void>[] = [];
    const depths: [number, number][] = [];
    try {
      flush();
      running.push(
        action(function* () {
          external.propose(1);
          yield externalEnd.promise;
        })()
      );
      flush();
      expect(positionOf(txOf(external.output))).toBe(1);
      for (let value = 1; value <= 3; value++) {
        const end = ends[value - 1];
        running.push(
          action(function* () {
            withOptimisticSlotBatch(() => {
              if (order === "parent-first") {
                parent.propose(value);
                child.propose(value);
              } else {
                child.propose(value);
                parent.propose(value);
              }
            });
            yield end.promise;
          })()
        );
        flush();
        depths.push([positionOf(txOf(parent.output)), positionOf(txOf(child.output))]);
      }
      expect(depths).toEqual([
        [2, 2],
        [2, 2],
        [2, 2]
      ]);
    } finally {
      externalAnswer.resolve(10);
      for (const answer of answers) answer.resolve(10);
      externalEnd.resolve();
      for (const end of ends) end.resolve();
      await Promise.all(running);
      dispose();
      flush();
    }
  }
);

it("a computed bridge through a member output does not add a level on each replacement", async () => {
  const ends = Array.from({ length: 3 }, () => Promise.withResolvers<void>());
  const answers = Array.from({ length: 3 }, () => Promise.withResolvers<number>());
  const parent = createOptimisticSlot(signal(0));
  const bridge = computed(() => read(parent.output));
  const child = createOptimisticSlot(bridge);
  const dispose = createRoot(dispose => {
    const pending = createMemo(() => {
      const value = read(parent.output);
      return value ? answers[value - 1].promise : 0;
    });
    createRenderEffect(pending, () => {});
    createRenderEffect(
      () => read(child.output),
      () => {}
    );
    return dispose;
  });
  const running: Promise<void>[] = [];
  const depths: [number, number][] = [];
  try {
    flush();
    for (let value = 1; value <= 3; value++) {
      const end = ends[value - 1];
      running.push(
        action(function* () {
          withOptimisticSlotBatch(() => {
            parent.propose(value);
            child.propose(value);
          });
          yield end.promise;
        })()
      );
      flush();
      depths.push([positionOf(txOf(parent.output)), positionOf(txOf(child.output))]);
    }
    expect(depths).toEqual([
      [1, 1],
      [1, 1],
      [1, 1]
    ]);
  } finally {
    for (const answer of answers) answer.resolve(10);
    for (const end of ends) end.resolve();
    await Promise.all(running);
    dispose();
    flush();
  }
});
