import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createErrorBoundary,
  createOptimistic,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  latest,
  refresh,
  isPending,
  untrack
} from "../src/index.js";
const settle = async () => {
  for (let i = 0; i < 10; i++) await Promise.resolve();
  flush();
};
for (const kind of ["signal", "store"] as const)
  it(`an untracked ${kind} sample keeps its selected guess while a tracked memo follows correction`, async () => {
    const [source, setSource] = createSignal(0);
    const fetches: Array<() => void> = [],
      flights: Array<() => void> = [];
    const logs: number[] = [],
      trackedLogs: number[] = [];
    let readValue!: () => number, guess!: (v: number) => void;
    let disposeLate: (() => void) | undefined;
    const dispose = createRoot(dispose => {
      if (kind === "signal") {
        const [read, set] = createOptimistic(() => {
          const v = source();
          return new Promise<number>(resolve => fetches.push(() => resolve(v * 2)));
        });
        readValue = read;
        guess = set;
      } else {
        const [store, set] = createOptimisticStore(
          () => {
            const v = source();
            return new Promise<{ n: number }>(resolve => fetches.push(() => resolve({ n: v * 2 })));
          },
          { n: -1 }
        );
        readValue = () => store.n;
        guess = v =>
          set(d => {
            d.n = v;
          });
      }
      const consequence = createMemo(() => {
        const n = readValue();
        return new Promise<string>(resolve => flights.push(() => resolve(`${n}!`)));
      });
      createRenderEffect(consequence, () => {});
      const tracked = createMemo(readValue);
      createRenderEffect(tracked, value => {
        trackedLogs.push(value);
      });
      return dispose;
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      fetches.shift()!();
      await settle();
      flights.shift()!();
      await settle();
      running = action(function* () {
        setSource(1);
        guess(3);
        yield new Promise<void>(resolve => flights.push(resolve));
      })();
      flush();
      fetches.shift()!();
      await settle();
      expect(readValue()).toBe(0);
      disposeLate = createRoot(dispose => {
        const late = createMemo(() => untrack(readValue));
        createRenderEffect(late, v => {
          logs.push(v);
        });
        return dispose;
      });
      flush();
      expect(logs).toEqual([]);
      expect(trackedLogs).toEqual([0]);
      expect(readValue()).toBe(0);
      flights.splice(0).forEach(resolve => resolve());
      await settle();
      await settle();
      flights.splice(0).forEach(resolve => resolve());
      await settle();
      expect(logs).toEqual([3]);
      expect(trackedLogs).toEqual([0, 2]);
      expect(readValue()).toBe(2);
    } finally {
      flights.splice(0).forEach(resolve => resolve());
      fetches.splice(0).forEach(resolve => resolve());
      await running;
      disposeLate?.();
      dispose();
      flush();
    }
  });

it("materializing a cold store companion preserves an already available committed read", async () => {
  const [source, setSource] = createSignal(0);
  const gate = Promise.withResolvers<void>();
  const [store, dispose] = createRoot(dispose => {
    const [store] = createOptimisticStore(() => ({ n: source() * 10 }), { n: 0 });
    return [store, dispose] as const;
  });
  flush();
  const running = action(function* () {
    setSource(1);
    yield gate.promise;
  })();
  let disposeLate: (() => void) | undefined;
  const frames: number[] = [];
  try {
    await settle();
    expect(store.n).toBe(0);
    disposeLate = createRoot(dispose => {
      createRenderEffect(
        () => store.n,
        value => {
          frames.push(value);
        }
      );
      return dispose;
    });
    flush();
    expect(store.n).toBe(0);
    expect(latest(() => store.n)).toBe(10);
    expect(isPending(() => store.n)).toBe(true);
    gate.resolve();
    await running;
    await settle();
    expect(store.n).toBe(10);
    expect(frames.at(-1)).toBe(10);
  } finally {
    gate.resolve();
    await running;
    disposeLate?.();
    dispose();
    flush();
  }
});

for (const surface of ["property", "length", "keys"] as const)
  it(`a cold ${surface} read keeps an initial discarded proposal and its seed hidden`, async () => {
    type State = { field: number; items: string[]; obj: Record<string, number> };
    const initial = Promise.withResolvers<State>();
    const gate = Promise.withResolvers<void>();
    const frames: unknown[] = [];
    let calls = 0;
    const [store, set, dispose] = createRoot(dispose => {
      const [store, set] = createOptimisticStore(() => initial.promise, {
        field: -1,
        items: ["seed", "seed"],
        obj: { seed: 0 }
      });
      createRenderEffect(
        () =>
          surface === "property"
            ? store.field
            : surface === "length"
              ? store.items.length
              : Object.keys(store.obj),
        value => {
          frames.push(value);
        }
      );
      return [store, set, dispose] as const;
    });
    let running: Promise<unknown> | undefined;
    const truth: State = { field: 2, items: ["a", "b", "c"], obj: { truth: 2 } };
    try {
      flush();
      expect(frames).toEqual([]);
      running = action(function* () {
        set(d => {
          calls++;
          if (surface === "property") d.field = 3;
          else if (surface === "length") d.items = ["guess"];
          else d.obj = { guess: 3 };
        });
        yield gate.promise;
      })();
      flush();
      expect(frames).toEqual([]);
      expect(calls).toBe(1);
      initial.resolve(truth);
      await settle();
      expect(frames).toEqual([]);
      gate.resolve();
      await running;
      await settle();
      expect(frames).toEqual([surface === "property" ? 2 : surface === "length" ? 3 : ["truth"]]);
      expect(
        frames.some(
          value =>
            value === -1 ||
            (value === 2 && surface === "length") ||
            (Array.isArray(value) && value.includes("seed"))
        )
      ).toBe(false);
    } finally {
      initial.resolve(truth);
      gate.resolve();
      await running;
      dispose();
      flush();
    }
  });

it("a discarded first guess cannot start a consequence or publish the unknown input's seed", async () => {
  const initial = Promise.withResolvers<{ field: number }>();
  const consequence = Promise.withResolvers<number>();
  const gate = Promise.withResolvers<void>();
  const frames: number[] = [];
  let consequenceStarts = 0;
  const [set, dispose] = createRoot(dispose => {
    const [store, set] = createOptimisticStore(() => initial.promise, { field: -1 });
    const derived = createMemo(() => {
      if (store.field !== 3) return 0;
      consequenceStarts++;
      return consequence.promise;
    });
    createRenderEffect(derived, () => {});
    createRenderEffect(
      () => store.field,
      value => {
        frames.push(value);
      }
    );
    return [set, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    expect(frames).toEqual([]);
    running = action(function* () {
      set(d => {
        d.field = 3;
      });
      yield gate.promise;
    })();
    flush();
    expect(frames).toEqual([]);
    consequence.resolve(30);
    await settle();
    expect(frames).toEqual([]);
    expect(consequenceStarts).toBe(0);
    initial.resolve({ field: 2 });
    await settle();
    expect(frames).toEqual([]);
    expect(consequenceStarts).toBe(0);
    gate.resolve();
    await running;
    await settle();
    expect(frames).toEqual([2]);
    expect(consequenceStarts).toBe(0);
  } finally {
    initial.resolve({ field: 2 });
    consequence.resolve(30);
    gate.resolve();
    await running;
    dispose();
    flush();
  }
});

it("a cold first-input error remains an error when a companion later selects a guess", async () => {
  const initial = Promise.withResolvers<{ field: number }>();
  const gate = Promise.withResolvers<void>();
  const error = new Error("first input failed");
  const frames: Array<number | string> = [];
  const [set, dispose] = createRoot(dispose => {
    const [store, set] = createOptimisticStore(() => initial.promise, { field: -1 });
    const boundary = createErrorBoundary(
      () => {
        createRenderEffect(
          () => store.field,
          value => {
            frames.push(value);
          }
        );
        return "OK";
      },
      () => "ERR"
    );
    createRenderEffect(boundary, value => {
      if (value === "ERR") frames.push(value);
    });
    return [set, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    expect(frames).toEqual([]);
    initial.reject(error);
    await settle();
    expect(frames).toEqual(["ERR"]);
    running = action(function* () {
      set(d => {
        d.field = 3;
      });
      yield gate.promise;
    })();
    flush();
    expect(frames.at(-1)).toBe(3);
    gate.resolve();
    await running;
    await settle();
    expect(frames.at(-1)).toBe("ERR");
    expect(frames).not.toContain(-1);
  } finally {
    gate.resolve();
    await running;
    dispose();
    flush();
  }
});

for (const preread of [false, true])
  it(`a cold latest index respects the selected array structure (preread=${preread})`, async () => {
    const first = Promise.withResolvers<void>(),
      hold = Promise.withResolvers<void>();
    const answers: Array<(rows: number[]) => void> = [];
    const frames: string[] = [];
    const [rows, set, dispose] = createRoot(dispose => {
      const [rows, set] = createOptimisticStore<number[]>(
        () =>
          new Promise(resolve => {
            answers.push(resolve);
          }),
        []
      );
      createRenderEffect(
        () => {
          if (preread) rows[3];
          return rows.join(",");
        },
        value => {
          frames.push(value);
        }
      );
      return [rows, set, dispose] as const;
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      answers.shift()!([1, 2]);
      await settle();
      running = action(function* () {
        set(d => {
          d.push(3);
        });
        yield first.promise;
        refresh(rows);
        yield hold.promise;
      })();
      flush();
      first.resolve();
      await settle();
      answers.shift()!([1, 2, 3, 4]);
      await settle();
      // A cold property companion cannot expose the lower producer's extra
      // row ahead of this output's selected structural correction.
      expect(latest(() => rows.length)).toBe(3);
      expect(latest(() => rows[3])).toBeUndefined();
      expect(latest(() => rows.join(","))).toBe("1,2,3");
      hold.resolve();
      await running;
      await settle();
      expect(frames.at(-1)).toBe("1,2,3,4");
      expect(latest(() => rows.length)).toBe(4);
      expect(latest(() => rows[3])).toBe(4);
      expect(latest(() => rows.join(","))).toBe("1,2,3,4");
      for (const frame of frames) expect(["1,2", "1,2,3", "1,2,3,4"]).toContain(frame);
    } finally {
      first.resolve();
      hold.resolve();
      answers.splice(0).forEach(resolve => resolve([1, 2, 3, 4]));
      await running;
      dispose();
      flush();
    }
  });

it("a cold companion never reveals the seed of a first answer still held by its source", async () => {
  const initial = Promise.withResolvers<{ field: number }>();
  const gate = Promise.withResolvers<void>();
  const [source, setSource] = createSignal(0);
  const [store, dispose] = createRoot(dispose => {
    const [store] = createOptimisticStore(
      () => {
        source();
        return initial.promise;
      },
      { field: -1 }
    );
    return [store, dispose] as const;
  });
  const running = action(function* () {
    setSource(1);
    yield gate.promise;
  })();
  let disposeReader: (() => void) | undefined;
  const frames: number[] = [];
  try {
    flush();
    disposeReader = createRoot(dispose => {
      createRenderEffect(
        () => store.field,
        value => {
          frames.push(value);
        }
      );
      return dispose;
    });
    flush();
    expect(frames).toEqual([]);
    initial.resolve({ field: 2 });
    await settle();
    expect(frames.every(value => value === 2)).toBe(true);
    expect(latest(() => store.field)).toBe(2);
    let direct: number | "pending";
    try {
      direct = store.field;
    } catch {
      direct = "pending";
    }
    expect(direct).not.toBe(-1);
    gate.resolve();
    await running;
    await settle();
    expect(frames.at(-1)).toBe(2);
  } finally {
    initial.resolve({ field: 2 });
    gate.resolve();
    await running;
    disposeReader?.();
    dispose();
    flush();
  }
});

// These controls require an already published parent: the declared seed is
// commit #0. The unpublished initial-discard matrix above remains distinct.
for (const mount of ["before-held", "while-held"] as const)
  it(`a published whole-parent guess keeps a cold field available with a declared seed commit before the first producer answer (${mount})`, async () => {
    type State = { obj: { field: number; stage: number } };
    const initial = Promise.withResolvers<State>();
    const next = Promise.withResolvers<void>(),
      end = Promise.withResolvers<void>(),
      consequence = Promise.withResolvers<number>();
    const [store, set, dispose] = createRoot(dispose => {
      const [store, set] = createOptimisticStore(
        () => initial.promise,
        {
          obj: { field: -1, stage: -1 }
        },
        { seedLoadingValue: true }
      );
      const derived = createMemo(() => (store.obj.stage === 1 ? consequence.promise : 0));
      createRenderEffect(derived, () => {});
      return [store, set, dispose] as const;
    });
    let running: Promise<unknown> | undefined, disposeReader: (() => void) | undefined;
    const frames: number[] = [];
    try {
      flush();
      running = action(function* () {
        set(d => {
          d.obj = { field: 1, stage: 0 };
        });
        yield next.promise;
        set(d => {
          d.obj = { field: 2, stage: 1 };
        });
        yield end.promise;
      })();
      flush();
      const published = store.obj;
      expect(published.field).toBe(1);
      const mountReader = () => {
        disposeReader = createRoot(dispose => {
          createRenderEffect(
            () => published.field,
            value => {
              frames.push(value);
            }
          );
          return dispose;
        });
        flush();
      };
      if (mount === "before-held") mountReader();
      next.resolve();
      await settle();
      expect(store.obj.field).toBe(1);
      if (mount === "while-held") mountReader();
      expect(published.field).toBe(1);
      expect(store.obj.field).toBe(1);
      expect(frames.every(value => value === 1)).toBe(true);
      consequence.resolve(20);
      await settle();
      initial.resolve({ obj: { field: 10, stage: 0 } });
      await settle();
      end.resolve();
      await running;
      await settle();
      expect(store.obj.field).toBe(10);
    } finally {
      initial.resolve({ obj: { field: 10, stage: 0 } });
      next.resolve();
      end.resolve();
      consequence.resolve(20);
      await running;
      disposeReader?.();
      dispose();
      flush();
    }
  });

for (const surface of ["keys", "descriptor"] as const)
  it(`a cold ${surface} observer preserves a published parent with a declared seed commit while its producer and replacement are pending`, async () => {
    type State = {
      obj: { field: number; stage: number; old?: number; fresh?: number; truth?: number };
    };
    const initial = Promise.withResolvers<State>();
    const next = Promise.withResolvers<void>(),
      end = Promise.withResolvers<void>(),
      consequence = Promise.withResolvers<number>();
    const [store, set, dispose] = createRoot(dispose => {
      const [store, set] = createOptimisticStore(
        () => initial.promise,
        {
          obj: { field: -1, stage: -1 }
        },
        { seedLoadingValue: true }
      );
      const derived = createMemo(() => (store.obj.stage === 1 ? consequence.promise : 0));
      createRenderEffect(derived, () => {});
      return [store, set, dispose] as const;
    });
    let running: Promise<unknown> | undefined, disposeReader: (() => void) | undefined;
    const frames: unknown[] = [];
    try {
      flush();
      running = action(function* () {
        set(d => {
          d.obj = { field: 1, stage: 0, old: 11 };
        });
        yield next.promise;
        set(d => {
          d.obj = { field: 2, stage: 1, fresh: 22 };
        });
        yield end.promise;
      })();
      flush();
      const published = store.obj;
      const read = () =>
        surface === "keys"
          ? Object.keys(published)
          : Object.getOwnPropertyDescriptor(published, "old")?.value;
      const expected = surface === "keys" ? ["field", "stage", "old"] : 11;
      expect(read()).toEqual(expected);
      next.resolve();
      await settle();
      expect(read()).toEqual(expected);
      disposeReader = createRoot(dispose => {
        const value = createMemo(read);
        createRenderEffect(value, frame => {
          frames.push(frame);
        });
        return dispose;
      });
      flush();
      expect(read()).toEqual(expected);
      for (const frame of frames) expect(frame).toEqual(expected);
      consequence.resolve(20);
      await settle();
      initial.resolve({ obj: { field: 10, stage: 0, truth: 33 } });
      await settle();
      end.resolve();
      await running;
      await settle();
      expect(Object.keys(store.obj)).toEqual(["field", "stage", "truth"]);
      expect(Object.getOwnPropertyDescriptor(store.obj, "truth")?.value).toBe(33);
    } finally {
      initial.resolve({ obj: { field: 10, stage: 0, truth: 33 } });
      next.resolve();
      end.resolve();
      consequence.resolve(20);
      await running;
      disposeReader?.();
      dispose();
      flush();
    }
  });
