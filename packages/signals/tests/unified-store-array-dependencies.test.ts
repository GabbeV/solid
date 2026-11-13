import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const settle = async () => {
  await turn();
  flush();
};

it("joins both lifetimes when a setter reads another action's value", async () => {
  const endA = Promise.withResolvers<void>();
  const endB = Promise.withResolvers<void>();
  const [store, set] = createOptimisticStore({ a: 0, b: 0 });
  const [savedA, saveA] = createSignal(false);
  const [savedB, saveB] = createSignal(false);
  let a: Promise<unknown> | undefined;
  let b: Promise<unknown> | undefined;
  try {
    a = action(function* () {
      saveA(true);
      set(d => {
        d.a = 1;
      });
      yield endA.promise;
    })();
    flush();
    b = action(function* () {
      saveB(true);
      set(d => {
        d.b = d.a + 1;
      });
      yield endB.promise;
    })();
    flush();
    expect([store.a, store.b]).toEqual([1, 2]);
    endA.resolve();
    await a;
    await settle();
    expect([store.a, store.b, savedA(), savedB()]).toEqual([1, 2, false, false]);
    endB.resolve();
    await b;
    await settle();
    expect([store.a, store.b, savedA(), savedB()]).toEqual([0, 0, true, true]);
  } finally {
    endA.resolve();
    endB.resolve();
    await Promise.all([a, b]);
    flush();
  }
});

it("literal disjoint writes stay independent despite internal draft cloning", async () => {
  const endA = Promise.withResolvers<void>();
  const endB = Promise.withResolvers<void>();
  const [store, set] = createOptimisticStore({ a: 0, b: 0 });
  let a: Promise<unknown> | undefined;
  let b: Promise<unknown> | undefined;
  try {
    a = action(function* () {
      set(d => {
        d.a = 1;
      });
      yield endA.promise;
    })();
    flush();
    b = action(function* () {
      set(d => {
        d.b = 2;
      });
      yield endB.promise;
    })();
    flush();
    expect([store.a, store.b]).toEqual([1, 2]);
    endA.resolve();
    await a;
    await settle();
    expect([store.a, store.b]).toEqual([0, 2]);
    endB.resolve();
    await b;
    await settle();
    expect([store.a, store.b]).toEqual([0, 0]);
  } finally {
    endA.resolve();
    endB.resolve();
    await Promise.all([a, b]);
    flush();
  }
});

it("reading a locally overwritten value does not consume its earlier owner", async () => {
  const endA = Promise.withResolvers<void>();
  const endB = Promise.withResolvers<void>();
  const [store, set] = createOptimisticStore({ a: 0, b: 0 });
  let a: Promise<unknown> | undefined;
  let b: Promise<unknown> | undefined;
  try {
    a = action(function* () {
      set(d => {
        d.a = 1;
      });
      yield endA.promise;
    })();
    flush();
    b = action(function* () {
      set(d => {
        d.a = 3;
        d.b = d.a + 1;
        d.a = 1;
      });
      yield endB.promise;
    })();
    flush();
    expect([store.a, store.b]).toEqual([1, 4]);
    endB.resolve();
    await b;
    await settle();
    expect([store.a, store.b]).toEqual([1, 0]);
    endA.resolve();
    await a;
    await settle();
    expect([store.a, store.b]).toEqual([0, 0]);
  } finally {
    endA.resolve();
    endB.resolve();
    await Promise.all([a, b]);
    flush();
  }
});

for (const [name, read] of [
  ["presence", (d: Record<string, number>) => "added" in d],
  ["key enumeration", (d: Record<string, number>) => Object.keys(d).includes("added")]
] as const) {
  it(`${name} branches consume the structural edit they inspect`, async () => {
    const endA = Promise.withResolvers<void>();
    const endB = Promise.withResolvers<void>();
    const [store, set] = createOptimisticStore<Record<string, number>>({ result: 0 });
    let a: Promise<unknown> | undefined;
    let b: Promise<unknown> | undefined;
    try {
      a = action(function* () {
        set(d => {
          d.added = 1;
        });
        yield endA.promise;
      })();
      flush();
      b = action(function* () {
        set(d => {
          d.result = read(d) ? 2 : -2;
        });
        yield endB.promise;
      })();
      flush();
      expect(["added" in store, store.result]).toEqual([true, 2]);
      endA.resolve();
      await a;
      await settle();
      expect(["added" in store, store.result]).toEqual([true, 2]);
      endB.resolve();
      await b;
      await settle();
      expect(["added" in store, store.result]).toEqual([false, 0]);
    } finally {
      endA.resolve();
      endB.resolve();
      await Promise.all([a, b]);
      flush();
    }
  });
}

for (const initial of [[], [0, 0]] as number[][]) {
  it(`${initial.length ? "keeps existing-index guesses independent" : "joins index growth and later hole filling"} from ${JSON.stringify(initial)}`, async () => {
    const endA = Promise.withResolvers<void>();
    const endB = Promise.withResolvers<void>();
    const [store, set] = createOptimisticStore([...initial]);
    const shown: number[][] = [];
    const lengths: number[] = [];
    const [savedA, saveA] = createSignal(false);
    const [savedB, saveB] = createSignal(false);
    const saves: boolean[][] = [];
    const dispose = createRoot(dispose => {
      createRenderEffect(
        () => [...store],
        value => {
          shown.push(value);
        }
      );
      createRenderEffect(
        () => store.length,
        value => {
          lengths.push(value);
        }
      );
      createRenderEffect(
        () => [savedA(), savedB()],
        value => {
          saves.push(value);
        }
      );
      return dispose;
    });
    let a: Promise<unknown> | undefined;
    let b: Promise<unknown> | undefined;
    try {
      flush();
      b = action(function* () {
        saveB(true);
        set(d => {
          d[1] = 2;
        });
        yield endB.promise;
      })();
      flush();
      a = action(function* () {
        saveA(true);
        set(d => {
          d[0] = 1;
        });
        yield endA.promise;
      })();
      flush();
      expect([...store]).toEqual([1, 2]);
      expect(shown.at(-1)).toEqual([1, 2]);
      expect(lengths.at(-1)).toBe(2);
      endB.resolve();
      await b;
      await settle();
      const afterB = initial.length ? [1, 0] : [1, 2];
      expect([...store]).toEqual(afterB);
      expect(shown.at(-1)).toEqual(afterB);
      expect(lengths.at(-1)).toBe(afterB.length);
      expect(saves.at(-1)).toEqual(initial.length ? [false, true] : [false, false]);
      endA.resolve();
      await a;
      await settle();
      expect([...store]).toEqual(initial);
      expect(shown.at(-1)).toEqual(initial);
      expect(saves.at(-1)).toEqual([true, true]);
    } finally {
      endA.resolve();
      endB.resolve();
      await Promise.all([a, b]);
      dispose();
      flush();
    }
  });
}

it("retains net growth after deletion and joins later hole filling", async () => {
  const endA = Promise.withResolvers<void>();
  const endB = Promise.withResolvers<void>();
  const [store, set] = createOptimisticStore<number[]>([]);
  const lengths: number[] = [];
  const indices: Array<number | undefined> = [];
  const [savedA, saveA] = createSignal(false);
  const [savedB, saveB] = createSignal(false);
  const saves: boolean[][] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => store.length,
      value => {
        lengths.push(value);
      }
    );
    createRenderEffect(
      () => store[1],
      value => {
        indices.push(value);
      }
    );
    createRenderEffect(
      () => [savedA(), savedB()],
      value => {
        saves.push(value);
      }
    );
    return dispose;
  });
  let a: Promise<unknown> | undefined;
  let b: Promise<unknown> | undefined;
  try {
    flush();
    a = action(function* () {
      saveA(true);
      set(d => {
        d[2] = 3;
        delete d[2];
      });
      yield endA.promise;
    })();
    flush();
    expect([store.length, 2 in store]).toEqual([3, false]);
    expect(lengths.at(-1)).toBe(3);
    b = action(function* () {
      saveB(true);
      set(d => {
        d[1] = 2;
      });
      yield endB.promise;
    })();
    flush();
    expect([store.length, store[1], 2 in store]).toEqual([3, 2, false]);
    expect([lengths.at(-1), indices.at(-1)]).toEqual([3, 2]);
    endA.resolve();
    await a;
    await settle();
    expect([store.length, store[1]]).toEqual([3, 2]);
    expect([lengths.at(-1), indices.at(-1)]).toEqual([3, 2]);
    expect(saves.at(-1)).toEqual([false, false]);
    endB.resolve();
    await b;
    await settle();
    expect([...store]).toEqual([]);
    expect([lengths.at(-1), indices.at(-1)]).toEqual([0, undefined]);
    expect(saves.at(-1)).toEqual([true, true]);
  } finally {
    endA.resolve();
    endB.resolve();
    await Promise.all([a, b]);
    dispose();
    flush();
  }
});

it("reading length consumes prior growth and keeps the optimistic maximum", async () => {
  const endA = Promise.withResolvers<void>();
  const endB = Promise.withResolvers<void>();
  const [store, set] = createOptimisticStore<number[]>([]);
  let a: Promise<unknown> | undefined;
  let b: Promise<unknown> | undefined;
  try {
    a = action(function* () {
      set(d => {
        d[2] = 3;
      });
      yield endA.promise;
    })();
    flush();
    b = action(function* () {
      set(d => {
        d[0] = d.length;
      });
      yield endB.promise;
    })();
    flush();
    expect([store.length, store[0], store[2]]).toEqual([3, 3, 3]);
    endA.resolve();
    await a;
    await settle();
    expect([store.length, store[0], store[2]]).toEqual([3, 3, 3]);
    endB.resolve();
    await b;
    await settle();
    expect([...store]).toEqual([]);
  } finally {
    endA.resolve();
    endB.resolve();
    await Promise.all([a, b]);
    flush();
  }
});

it("a length read and push consume prior growth while push's final length is not an explicit resize", async () => {
  const endA = Promise.withResolvers<void>();
  const endB = Promise.withResolvers<void>();
  const [store, set] = createOptimisticStore<number[]>([]);
  let a: Promise<unknown> | undefined;
  let b: Promise<unknown> | undefined;
  try {
    a = action(function* () {
      set(d => {
        d[1] = 2;
      });
      yield endA.promise;
    })();
    flush();
    b = action(function* () {
      set(d => {
        d.push(3);
      });
      yield endB.promise;
    })();
    flush();
    expect([store.length, store[1], store[2]]).toEqual([3, 2, 3]);
    endA.resolve();
    await a;
    await settle();
    expect([store.length, store[1], store[2]]).toEqual([3, 2, 3]);
    endB.resolve();
    await b;
    await settle();
    expect([...store]).toEqual([]);
  } finally {
    endA.resolve();
    endB.resolve();
    await Promise.all([a, b]);
    flush();
  }
});

it("push growth coordinates a later existing-index edit despite its final no-op length assignment", async () => {
  const endPush = Promise.withResolvers<void>();
  const endIndex = Promise.withResolvers<void>();
  const [store, set] = createOptimisticStore([0, 0]);
  const [savedPush, savePush] = createSignal(false);
  const [savedIndex, saveIndex] = createSignal(false);
  const saves: boolean[][] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => [savedPush(), savedIndex()],
      value => {
        saves.push(value);
      }
    );
    return dispose;
  });
  let push: Promise<unknown> | undefined;
  let index: Promise<unknown> | undefined;
  try {
    push = action(function* () {
      savePush(true);
      set(d => {
        d.push(2);
      });
      yield endPush.promise;
    })();
    flush();
    index = action(function* () {
      saveIndex(true);
      set(d => {
        d[0] = 1;
      });
      yield endIndex.promise;
    })();
    flush();
    expect([...store]).toEqual([1, 0, 2]);
    endPush.resolve();
    await push;
    await settle();
    expect([...store]).toEqual([1, 0, 2]);
    expect(saves.at(-1)).toEqual([false, false]);
    endIndex.resolve();
    await index;
    await settle();
    expect([...store]).toEqual([0, 0]);
    expect(saves.at(-1)).toEqual([true, true]);
  } finally {
    endPush.resolve();
    endIndex.resolve();
    await Promise.all([push, index]);
    dispose();
    flush();
  }
});

it("an effective explicit length resize coordinates existing and later index edits", async () => {
  const endA = Promise.withResolvers<void>();
  const endB = Promise.withResolvers<void>();
  const endC = Promise.withResolvers<void>();
  const [store, set] = createOptimisticStore([0, 0]);
  const shown: number[][] = [];
  const lengths: number[] = [];
  const [savedA, saveA] = createSignal(false);
  const saves: boolean[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => [...store],
      value => {
        shown.push(value);
      }
    );
    createRenderEffect(
      () => store.length,
      value => {
        lengths.push(value);
      }
    );
    createRenderEffect(savedA, value => {
      saves.push(value);
    });
    return dispose;
  });
  let a: Promise<unknown> | undefined;
  let b: Promise<unknown> | undefined;
  let c: Promise<unknown> | undefined;
  try {
    flush();
    a = action(function* () {
      saveA(true);
      set(d => {
        d[0] = 1;
      });
      yield endA.promise;
    })();
    flush();
    b = action(function* () {
      set(d => {
        d.length = 1;
      });
      yield endB.promise;
    })();
    flush();
    c = action(function* () {
      set(d => {
        d[1] = 3;
      });
      yield endC.promise;
    })();
    flush();
    expect([...store]).toEqual([1, 3]);
    expect([shown.at(-1), lengths.at(-1)]).toEqual([[1, 3], 2]);
    endA.resolve();
    await a;
    await settle();
    expect([...store]).toEqual([1, 3]);
    expect([shown.at(-1), lengths.at(-1), saves.at(-1)]).toEqual([[1, 3], 2, false]);
    endB.resolve();
    await b;
    await settle();
    expect([...store]).toEqual([1, 3]);
    expect([shown.at(-1), lengths.at(-1), saves.at(-1)]).toEqual([[1, 3], 2, false]);
    endC.resolve();
    await c;
    await settle();
    expect([...store]).toEqual([0, 0]);
    expect([shown.at(-1), lengths.at(-1), saves.at(-1)]).toEqual([[0, 0], 2, true]);
  } finally {
    endA.resolve();
    endB.resolve();
    endC.resolve();
    await Promise.all([a, b, c]);
    dispose();
    flush();
  }
});

it("holds a nested array setter coherently for async observers and late mounts", async () => {
  const end = Promise.withResolvers<void>();
  const answer = Promise.withResolvers<number>();
  const [store, set] = createOptimisticStore({ rows: [0, 0] });
  const [tick, setTick] = createSignal(0);
  const shown: Array<[number[], number, number]> = [];
  const late: number[][] = [];
  let disposeLate: (() => void) | undefined;
  const dispose = createRoot(dispose => {
    const derived = createMemo(() => (store.rows[0] ? answer.promise : 0));
    createRenderEffect(
      () => [[...store.rows], derived(), tick()] as [number[], number, number],
      value => {
        shown.push(value);
      }
    );
    return dispose;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    running = action(function* () {
      set(d => {
        d.rows[0] = 1;
        d.rows[1] = 2;
      });
      yield end.promise;
    })();
    flush();
    await settle();
    expect(shown.at(-1)).toEqual([[0, 0], 0, 0]);
    setTick(1);
    flush();
    expect(shown.at(-1)).toEqual([[0, 0], 0, 1]);
    disposeLate = createRoot(dispose => {
      createRenderEffect(
        () => [...store.rows],
        value => {
          late.push(value);
        }
      );
      return dispose;
    });
    flush();
    expect(late.at(-1)).toEqual([0, 0]);
    answer.resolve(10);
    await settle();
    expect(shown.at(-1)).toEqual([[1, 2], 10, 1]);
    expect(late.at(-1)).toEqual([1, 2]);
    end.resolve();
    await running;
    await settle();
    expect(shown.at(-1)).toEqual([[0, 0], 0, 1]);
    expect(late.at(-1)).toEqual([0, 0]);
  } finally {
    end.resolve();
    answer.resolve(10);
    await running;
    disposeLate?.();
    dispose();
    flush();
  }
});

it("holds a separate length binding until an inserted element's async consequence settles", async () => {
  const end = Promise.withResolvers<void>();
  const answer = Promise.withResolvers<number>();
  const [store, set] = createOptimisticStore<number[]>([]);
  const lengths: number[] = [];
  const elements: Array<number | undefined> = [];
  const derivedValues: number[] = [];
  const lateLengths: number[] = [];
  let disposeLate: (() => void) | undefined;
  const dispose = createRoot(dispose => {
    const derived = createMemo(() => (store[1] === 2 ? answer.promise : 0));
    createRenderEffect(
      () => store.length,
      value => {
        lengths.push(value);
      }
    );
    createRenderEffect(
      () => store[1],
      value => {
        elements.push(value);
      }
    );
    createRenderEffect(derived, value => {
      derivedValues.push(value);
    });
    return dispose;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    running = action(function* () {
      set(d => {
        d[0] = 1;
        d[1] = 2;
      });
      yield end.promise;
    })();
    flush();
    await settle();
    expect([lengths.at(-1), elements.at(-1), derivedValues.at(-1)]).toEqual([0, undefined, 0]);
    disposeLate = createRoot(dispose => {
      createRenderEffect(
        () => store.length,
        value => {
          lateLengths.push(value);
        }
      );
      return dispose;
    });
    flush();
    expect(lateLengths.at(-1)).toBe(0);
    answer.resolve(20);
    await settle();
    expect([lengths.at(-1), elements.at(-1), derivedValues.at(-1), lateLengths.at(-1)]).toEqual([
      2, 2, 20, 2
    ]);
    end.resolve();
    await running;
    await settle();
    expect([lengths.at(-1), elements.at(-1), derivedValues.at(-1), lateLengths.at(-1)]).toEqual([
      0,
      undefined,
      0,
      0
    ]);
  } finally {
    end.resolve();
    answer.resolve(20);
    await running;
    disposeLate?.();
    dispose();
    flush();
  }
});

it("bounds array publication and reader cleanup through repeated action cycles", async () => {
  const [store, set] = createOptimisticStore([0]);
  for (let cycle = 0; cycle < 24; cycle++) {
    const end = Promise.withResolvers<void>();
    const shown: number[][] = [];
    const dispose = createRoot(dispose => {
      createRenderEffect(
        () => [...store],
        value => {
          shown.push(value);
        }
      );
      return dispose;
    });
    let running: Promise<unknown> | undefined;
    let lateDispose: (() => void) | undefined;
    const late: number[][] = [];
    try {
      flush();
      running = action(function* () {
        set(d => {
          d[0] = cycle + 1;
        });
        yield end.promise;
      })();
      flush();
      expect(shown.at(-1)).toEqual([cycle + 1]);
      const countAtDisposal = shown.length;
      dispose();
      lateDispose = createRoot(dispose => {
        createRenderEffect(
          () => [...store],
          value => {
            late.push(value);
          }
        );
        return dispose;
      });
      flush();
      expect(late.at(-1)).toEqual([cycle + 1]);
      end.resolve();
      await running;
      await settle();
      expect(late.at(-1)).toEqual([0]);
      expect(shown).toHaveLength(countAtDisposal);
      expect(late.length).toBeLessThanOrEqual(3);
    } finally {
      end.resolve();
      await running;
      lateDispose?.();
      dispose();
      flush();
    }
  }
});
