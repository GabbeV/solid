import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  deep,
  flush,
  snapshot
} from "../src/index.js";
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("adds and removes present-undefined keys with independent value, presence and key-set subscriptions", async () => {
  const gate = Promise.withResolvers<void>();
  const [s, set] = createOptimisticStore<Record<string, number | undefined>>({
    old: undefined,
    value: 0
  });
  const values: unknown[] = [],
    has: boolean[][] = [],
    keys: string[][] = [],
    descriptors: unknown[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => s.added,
      v => {
        values.push(v);
      }
    );
    createRenderEffect(
      () => ["old" in s, "added" in s],
      v => {
        has.push(v);
      }
    );
    createRenderEffect(
      () => Object.keys(s),
      v => {
        keys.push(v);
      }
    );
    createRenderEffect(
      () => Object.getOwnPropertyDescriptor(s, "added"),
      v => {
        descriptors.push(v);
      }
    );
    return dispose;
  });
  try {
    flush();
    const running = action(function* () {
      set(d => {
        delete d.old;
        d.added = undefined;
      });
      set(d => {
        expect("old" in d).toBe(false);
        expect("added" in d).toBe(true);
      });
      yield gate.promise;
    })();
    expect(Object.keys(s)).toEqual(["old", "value"]);
    flush();
    expect(has).toEqual([
      [true, false],
      [false, true]
    ]);
    expect(keys).toEqual([
      ["old", "value"],
      ["value", "added"]
    ]);
    expect(values).toEqual([undefined]);
    expect(descriptors.at(-1)).toEqual({
      value: undefined,
      enumerable: true,
      configurable: true,
      writable: true
    });
    expect(snapshot(s)).toEqual({ value: 0, added: undefined });
    expect(Object.hasOwn(s, "old")).toBe(false);
    expect("added" in s).toBe(true);
    gate.resolve();
    await running;
    await turn();
    flush();
    expect(has.at(-1)).toEqual([true, false]);
    expect(keys.at(-1)).toEqual(["old", "value"]);
    expect(descriptors.at(-1)).toBeUndefined();
  } finally {
    gate.resolve();
    dispose();
    flush();
  }
});

it("enumerates selected descriptor values, non-enumerable keys, symbols and integer ordering", async () => {
  const gate = Promise.withResolvers<void>(),
    symbol = Symbol("field");
  const initial = Object.create(null);
  initial.z = 0;
  initial[8] = 8;
  initial[symbol] = 1;
  Object.defineProperty(initial, "hidden", {
    value: 2,
    enumerable: false,
    writable: true,
    configurable: true
  });
  const [s, set] = createOptimisticStore(initial);
  const keys: PropertyKey[][] = [],
    descriptors: PropertyDescriptorMap[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => Reflect.ownKeys(s),
      v => {
        keys.push(v);
      }
    );
    createRenderEffect(
      () => Object.getOwnPropertyDescriptors(s),
      v => {
        descriptors.push(v);
      }
    );
    return dispose;
  });
  try {
    flush();
    const running = action(function* () {
      set(d => {
        d[2] = 2;
        d[symbol] = 3;
        delete d.z;
        d.z = 4;
        Object.defineProperty(d, "hidden", { enumerable: true, value: 5 });
      });
      yield gate.promise;
    })();
    flush();
    expect(keys.at(-1)).toEqual(["2", "8", "hidden", "z", symbol]);
    expect(Object.keys(s)).toEqual(["2", "8", "hidden", "z"]);
    expect(descriptors.at(-1)![symbol as any]).toEqual({
      value: 3,
      enumerable: true,
      writable: true,
      configurable: true
    });
    expect(Object.getOwnPropertyDescriptor(s, "hidden")!.value).toBe(5);
    expect(snapshot(s).hidden).toBe(5);
    gate.resolve();
    await running;
    await turn();
    flush();
    expect(keys.at(-1)).toEqual(["8", "z", "hidden", symbol]);
    expect(Object.keys(s)).toEqual(["8", "z"]);
    expect(Object.getOwnPropertyDescriptor(s, "hidden")).toEqual({
      value: 2,
      enumerable: false,
      writable: true,
      configurable: true
    });
  } finally {
    gate.resolve();
    dispose();
    flush();
  }
});

it("a structural setter holds values, presence, enumeration and deep output through an async consequence", async () => {
  const gate = Promise.withResolvers<void>(),
    answer = Promise.withResolvers<number>();
  const [s, set] = createOptimisticStore<Record<string, number>>({ a: 0, old: 1 });
  const [tick, setTick] = createSignal(0);
  const shown = {
    a: -1,
    added: undefined as number | undefined,
    has: false,
    keys: [] as string[],
    deep: {},
    async: -1,
    tick: -1
  };
  const dispose = createRoot(dispose => {
    const calculated = createMemo(() => (s.a ? answer.promise : 0));
    createRenderEffect(
      () => s.a,
      v => {
        shown.a = v;
      }
    );
    createRenderEffect(
      () => [s.added, tick()] as const,
      ([v, t]) => {
        shown.added = v;
        shown.tick = t;
      }
    );
    createRenderEffect(
      () => "added" in s,
      v => {
        shown.has = v;
      }
    );
    createRenderEffect(
      () => Object.keys(s),
      v => {
        shown.keys = v;
      }
    );
    createRenderEffect(
      () => ({ ...deep(s) }),
      v => {
        shown.deep = v;
      }
    );
    createRenderEffect(calculated, v => {
      shown.async = v;
    });
    return dispose;
  });
  try {
    flush();
    const before = {
      a: 0,
      added: undefined,
      has: false,
      keys: ["a", "old"],
      deep: { a: 0, old: 1 },
      async: 0,
      tick: 0
    };
    const running = action(function* () {
      set(d => {
        d.a = 1;
        d.added = 2;
        delete d.old;
      });
      yield gate.promise;
    })();
    flush();
    await turn();
    expect(shown).toEqual(before);
    setTick(1);
    flush();
    expect(shown).toEqual({ ...before, tick: 1 });
    answer.resolve(10);
    await turn();
    flush();
    expect(shown).toEqual({
      a: 1,
      added: 2,
      has: true,
      keys: ["a", "added"],
      deep: { a: 1, added: 2 },
      async: 10,
      tick: 1
    });
    gate.resolve();
    await running;
    await turn();
    flush();
    expect(shown).toEqual({ ...before, tick: 1 });
  } finally {
    gate.resolve();
    answer.resolve(10);
    dispose();
    flush();
  }
});

it("deep observation does not merge disjoint existing-key action lifetimes", async () => {
  const endA = Promise.withResolvers<void>(),
    endB = Promise.withResolvers<void>();
  const [s, set] = createOptimisticStore({ a: 0, b: 0 });
  const shown: number[][] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => {
        const v = deep(s);
        return [v.a, v.b];
      },
      v => {
        shown.push(v);
      }
    );
    return dispose;
  });
  try {
    flush();
    const a = action(function* () {
      set(d => {
        d.a = 1;
      });
      yield endA.promise;
    })();
    flush();
    await turn();
    const b = action(function* () {
      set(d => {
        d.b = 2;
      });
      yield endB.promise;
    })();
    flush();
    await turn();
    expect(shown.at(-1)).toEqual([1, 2]);
    endA.resolve();
    await a;
    await turn();
    flush();
    expect(shown.at(-1)).toEqual([0, 2]);
    endB.resolve();
    await b;
    await turn();
    flush();
    expect(shown.at(-1)).toEqual([0, 0]);
  } finally {
    endA.resolve();
    endB.resolve();
    dispose();
    flush();
  }
});

it("enumeration observes later values without taking value dependencies or reviving stale container values", async () => {
  const structure = Promise.withResolvers<void>(),
    value = Promise.withResolvers<void>();
  const [s, set] = createOptimisticStore<Record<string, number>>({ a: 0 });
  const descriptors: PropertyDescriptorMap[] = [],
    present: boolean[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => Object.getOwnPropertyDescriptors(s),
      v => {
        descriptors.push(v);
      }
    );
    createRenderEffect(
      () => "a" in s,
      v => {
        present.push(v);
      }
    );
    return dispose;
  });
  try {
    flush();
    const a = action(function* () {
      set(d => {
        d.extra = 1;
      });
      yield structure.promise;
    })();
    flush();
    await turn();
    expect(descriptors).toHaveLength(2);
    const b = action(function* () {
      set(d => {
        d.a = 5;
      });
      yield value.promise;
    })();
    flush();
    await turn();
    expect(descriptors).toHaveLength(2);
    expect(present).toEqual([true]);
    expect(Object.getOwnPropertyDescriptors(s).a.value).toBe(5);
    structure.resolve();
    await a;
    await turn();
    flush();
    expect(Object.keys(s)).toEqual(["a"]);
    expect(descriptors.at(-1)!.a.value).toBe(5);
    value.resolve();
    await b;
    await turn();
    flush();
    expect(s.a).toBe(0);
  } finally {
    structure.resolve();
    value.resolve();
    dispose();
    flush();
  }
});

it("shared structural outputs entangle action lifetimes even for distinct added keys", async () => {
  const endA = Promise.withResolvers<void>(),
    endB = Promise.withResolvers<void>();
  const [s, set] = createOptimisticStore<Record<string, number>>({});
  const shown: string[][] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => Object.keys(s),
      v => {
        shown.push(v);
      }
    );
    return dispose;
  });
  try {
    flush();
    const a = action(function* () {
      set(d => {
        d.a = 1;
      });
      yield endA.promise;
    })();
    flush();
    await turn();
    const b = action(function* () {
      set(d => {
        d.b = 2;
      });
      yield endB.promise;
    })();
    flush();
    await turn();
    expect(shown.at(-1)).toEqual(["a", "b"]);
    endA.resolve();
    await a;
    await turn();
    flush();
    expect(shown.at(-1)).toEqual(["a", "b"]);
    endB.resolve();
    await b;
    await turn();
    flush();
    expect(shown.at(-1)).toEqual([]);
  } finally {
    endA.resolve();
    endB.resolve();
    dispose();
    flush();
  }
});

it("presence-driven async work holds the entire setter and a superseding deletion cancels it", async () => {
  const gate = Promise.withResolvers<void>(),
    answer = Promise.withResolvers<number>();
  const [s, set] = createOptimisticStore<Record<string, number>>({ value: 0 });
  const shown = { value: -1, keys: [] as string[], calculated: -1 };
  const dispose = createRoot(dispose => {
    const calculated = createMemo(() => ("added" in s ? answer.promise : 0));
    createRenderEffect(
      () => s.value,
      v => {
        shown.value = v;
      }
    );
    createRenderEffect(
      () => Object.keys(s),
      v => {
        shown.keys = v;
      }
    );
    createRenderEffect(calculated, v => {
      shown.calculated = v;
    });
    return dispose;
  });
  try {
    flush();
    const a = action(function* () {
      set(d => {
        d.added = 1;
        d.value = 1;
      });
      yield gate.promise;
    })();
    flush();
    await turn();
    expect(shown).toEqual({ value: 0, keys: ["value"], calculated: 0 });
    const b = action(function* () {
      set(d => {
        delete d.added;
        d.value = 2;
      });
      yield gate.promise;
    })();
    flush();
    await turn();
    expect(shown).toEqual({ value: 2, keys: ["value"], calculated: 0 });
    answer.resolve(10);
    await turn();
    flush();
    expect(shown).toEqual({ value: 2, keys: ["value"], calculated: 0 });
    gate.resolve();
    await Promise.all([a, b]);
    await turn();
    flush();
    expect(shown).toEqual({ value: 0, keys: ["value"], calculated: 0 });
  } finally {
    gate.resolve();
    answer.resolve(10);
    dispose();
    flush();
  }
});

it("validates all descriptor and structural edits before proposing, and detaches returned replacements", async () => {
  const gate = Promise.withResolvers<void>();
  const [s, set] = createOptimisticStore<Record<string, number>>({ value: 0 });
  expect(() =>
    set(d => {
      d.added = 1;
      delete d.value;
      Object.defineProperty(d, "bad", { get: () => 1 });
    })
  ).toThrow(/accessor/);
  expect(() =>
    set(d => {
      d.added = 1;
      Object.defineProperty(d, "value", { writable: false });
    })
  ).toThrow(/immutable/);
  expect(() =>
    set(d => {
      d.added = 1;
      Object.defineProperty(d, "value", { configurable: false });
    })
  ).toThrow(/immutable/);
  flush();
  expect(Object.keys(s)).toEqual(["value"]);
  expect(s.value).toBe(0);
  const replacement = { added: 2 };
  const running = action(function* () {
    set(() => replacement);
    yield gate.promise;
  })();
  replacement.added = 99;
  try {
    flush();
    expect(Object.keys(s)).toEqual(["added"]);
    expect(s.added).toBe(2);
    expect(s.value).toBeUndefined();
    gate.resolve();
    await running;
    await turn();
    flush();
    expect(Object.keys(s)).toEqual(["value"]);
    expect(s.value).toBe(0);
  } finally {
    gate.resolve();
    flush();
  }
});

for (const key of ["toString", "constructor"] as const) {
  it(`adding own undefined shadows inherited ${key} through every read surface`, async () => {
    const end = Promise.withResolvers<void>();
    const [store, guess] = createOptimisticStore<Record<string, unknown>>({});
    const shown: unknown[] = [];
    const dispose = createRoot(dispose => {
      createRenderEffect(
        () => {
          // Prototype methods are untracked; the key set observes own shadowing.
          Object.keys(store);
          return store[key];
        },
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
        guess(draft => {
          draft[key] = undefined;
        });
        yield end.promise;
      })();
      flush();
      expect(Object.hasOwn(store, key)).toBe(true);
      expect(store[key]).toBeUndefined();
      expect(Object.getOwnPropertyDescriptor(store, key)!.value).toBeUndefined();
      expect(shown.at(-1)).toBeUndefined();
      end.resolve();
      await running;
      await turn();
      flush();
      expect(Object.hasOwn(store, key)).toBe(false);
      expect(store[key]).toBe(Object.prototype[key]);
      expect(shown.at(-1)).toBe(Object.prototype[key]);
    } finally {
      end.resolve();
      await running;
      dispose();
      flush();
    }
  });
}

it("deleting an own method reveals its inherited value while removing its descriptor", async () => {
  const own = () => "own";
  const [store, guess] = createOptimisticStore<Record<string, unknown>>({ toString: own });
  const end = Promise.withResolvers<void>();
  const shown: unknown[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => store.toString,
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
      guess(draft => {
        delete draft.toString;
      });
      yield end.promise;
    })();
    flush();
    expect(Object.hasOwn(store, "toString")).toBe(false);
    expect(Object.getOwnPropertyDescriptor(store, "toString")).toBeUndefined();
    expect(store.toString).toBe(Object.prototype.toString);
    expect(shown.at(-1)).toBe(Object.prototype.toString);
    end.resolve();
    await running;
    await turn();
    flush();
    expect(store.toString).toBe(own);
    expect(shown.at(-1)).toBe(own);
  } finally {
    end.resolve();
    await running;
    dispose();
    flush();
  }
});
