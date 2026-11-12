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

it("property cuts compose drafts, share overlapping actions, and retire disjoint keys independently", async () => {
  const endA = Promise.withResolvers<void>(),
    endB = Promise.withResolvers<void>(),
    endC = Promise.withResolvers<void>();
  const [store, set] = createOptimisticStore({ a: 0, b: 0 });
  const shown: number[][] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => [store.a, store.b],
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
        d.a++;
      });
      set(d => {
        d.a++;
      });
      yield endA.promise;
    })();
    flush();
    expect(shown.at(-1)).toEqual([2, 0]);
    const b = action(function* () {
      set(d => {
        d.a++;
      });
      yield endB.promise;
    })();
    flush();
    const c = action(function* () {
      set(d => {
        d.b = 4;
      });
      yield endC.promise;
    })();
    flush();
    expect(shown.at(-1)).toEqual([3, 4]);
    endA.resolve();
    await turn();
    expect([store.a, store.b]).toEqual([3, 4]);
    endC.resolve();
    await c;
    await turn();
    flush();
    expect([store.a, store.b]).toEqual([3, 0]);
    endB.resolve();
    await Promise.all([a, b]);
    await turn();
    expect(shown.at(-1)).toEqual([0, 0]);
  } finally {
    endA.resolve();
    endB.resolve();
    endC.resolve();
    dispose();
    flush();
  }
});

it("flat read surfaces select published outputs without subscribing enumeration or snapshot to all leaves", async () => {
  const end = Promise.withResolvers<void>();
  const [store, set] = createOptimisticStore({ value: 0 });
  const direct: number[] = [],
    snapshots: number[] = [],
    deeps: number[] = [];
  let enumerations = 0;
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => store.value,
      v => {
        direct.push(v);
      }
    );
    createRenderEffect(
      () => snapshot(store).value,
      v => {
        snapshots.push(v);
      }
    );
    createRenderEffect(
      () => deep(store).value,
      v => {
        deeps.push(v);
      }
    );
    createRenderEffect(
      () => {
        enumerations++;
        return Object.keys(store);
      },
      () => {}
    );
    return dispose;
  });
  try {
    flush();
    const running = action(function* () {
      set(d => {
        d.value = 5;
      });
      yield end.promise;
    })();
    expect(store.value).toBe(0);
    expect(snapshot(store).value).toBe(0);
    flush();
    expect(store.value).toBe(5);
    expect(snapshot(store).value).toBe(5);
    expect(Object.getOwnPropertyDescriptor(store, "value")!.value).toBe(5);
    expect(deeps).toEqual([0, 5]);
    expect(direct).toEqual([0, 5]);
    expect(enumerations).toBe(1);
    expect(snapshots).toEqual([0]);
    end.resolve();
    await running;
    await turn();
    expect(deeps).toEqual([0, 5, 0]);
    expect(direct).toEqual([0, 5, 0]);
  } finally {
    end.resolve();
    dispose();
    flush();
  }
});

it("companions survive creator disposal, first-reader disposal, and late mounts", async () => {
  let store!: { value: number }, set!: (fn: (draft: { value: number }) => void) => void;
  const creator = createRoot(dispose => {
    [store, set] = createOptimisticStore({ value: 0 });
    return dispose;
  });
  creator();
  flush();
  const end = Promise.withResolvers<void>();
  const first: number[] = [],
    late: number[] = [];
  const reader = createRoot(dispose => {
    createRenderEffect(
      () => store.value,
      v => {
        first.push(v);
      }
    );
    return dispose;
  });
  flush();
  const running = action(function* () {
    set(d => {
      d.value = 5;
    });
    yield end.promise;
  })();
  flush();
  expect(first).toEqual([0, 5]);
  reader();
  flush();
  expect(store.value).toBe(5);
  const lateReader = createRoot(dispose => {
    createRenderEffect(
      () => store.value,
      v => {
        late.push(v);
      }
    );
    return dispose;
  });
  try {
    flush();
    expect(late).toEqual([5]);
    end.resolve();
    await running;
    await turn();
    expect(late).toEqual([5, 0]);
  } finally {
    end.resolve();
    lateReader();
    flush();
  }
});

it("repeated proposals keep async consequences coherent beside unrelated reruns", async () => {
  const end = Promise.withResolvers<void>(),
    answer = Promise.withResolvers<number>();
  const [store, set] = createOptimisticStore({ value: 0 });
  const shown: number[][] = [];
  const [unrelated, writeUnrelated] = createSignal(0);
  const dispose = createRoot(dispose => {
    const derived = createMemo(() => (store.value === 2 ? answer.promise : store.value * 10));
    createRenderEffect(
      () => [store.value, derived(), unrelated()],
      v => {
        shown.push(v);
      }
    );
    return dispose;
  });
  try {
    flush();
    const running = action(function* () {
      set(d => {
        d.value = 1;
      });
      yield end.promise;
    })();
    flush();
    expect(shown.at(-1)).toEqual([1, 10, 0]);
    const second = action(function* () {
      set(d => {
        d.value = 2;
      });
      yield end.promise;
    })();
    flush();
    expect(shown.at(-1)).toEqual([1, 10, 0]);
    writeUnrelated(1);
    flush();
    expect(shown.at(-1)).toEqual([1, 10, 1]);
    answer.resolve(20);
    await turn();
    expect(shown.at(-1)).toEqual([2, 20, 1]);
    end.resolve();
    await Promise.all([running, second]);
    await turn();
    expect(shown.at(-1)).toEqual([0, 0, 1]);
  } finally {
    end.resolve();
    answer.resolve(20);
    dispose();
    flush();
  }
});

it("function and Promise leaves remain raw values", async () => {
  const original = () => 0,
    guessed = () => 1,
    promise = Promise.resolve(1),
    replacement = Promise.resolve(2);
  const [store, set] = createOptimisticStore({ fn: original, promise });
  const end = Promise.withResolvers<void>();
  const running = action(function* () {
    set(d => {
      d.fn = guessed;
      d.promise = replacement;
    });
    set(d => {
      expect(d.fn).toBe(guessed);
      expect(d.promise).toBe(replacement);
    });
    yield end.promise;
  })();
  try {
    flush();
    expect(store.fn).toBe(guessed);
    expect(store.promise).toBe(replacement);
    end.resolve();
    await running;
    await turn();
    expect(store.fn).toBe(original);
    expect(store.promise).toBe(promise);
  } finally {
    end.resolve();
    flush();
  }
});

it("unsupported shapes and accessor drafts reject before partial proposals", () => {
  expect(() => createOptimisticStore({ nested: { value: 0 } })).toThrow(/flat plain/);
  expect(() => createOptimisticStore([1, 2])).toThrow(/flat plain/);
  expect(() => createOptimisticStore(() => ({ value: 0 }))).toThrow(/flat plain/);
  const [store, set] = createOptimisticStore({ value: 0 });
  expect(() =>
    set(d => {
      d.value = 7;
      Object.defineProperty(d, "value", { get: () => 1 });
    })
  ).toThrow(/flat plain/);
  expect(store.value).toBe(0);
  flush();
  expect(store.value).toBe(0);
});
