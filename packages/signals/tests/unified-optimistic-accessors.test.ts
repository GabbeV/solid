import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  flush
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("publishes an accessor descriptor and calls its getter with the proxy receiver", async () => {
  const end = Promise.withResolvers<void>();
  const endBase = Promise.withResolvers<void>();
  const get = function (this: { base: number }) {
    return this.base + 1;
  };
  const [store, set] = createOptimisticStore({ base: 1, total: 0 });
  const shown: number[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => store.total,
      value => {
        shown.push(value);
      }
    );
    return dispose;
  });
  let running: Promise<unknown> | undefined;
  let baseWrite: Promise<unknown> | undefined;
  try {
    flush();
    running = action(function* () {
      set(d => {
        Object.defineProperty(d, "total", { get, enumerable: true, configurable: true });
      });
      yield end.promise;
    })();
    flush();
    expect(store.total).toBe(2);
    expect(shown.at(-1)).toBe(2);
    expect(Object.getOwnPropertyDescriptor(store, "total")).toEqual({
      get,
      set: undefined,
      enumerable: true,
      configurable: true
    });
    baseWrite = action(function* () {
      set(d => {
        d.base = 4;
      });
      yield endBase.promise;
    })();
    flush();
    expect(store.total).toBe(5);
    expect(shown.at(-1)).toBe(5);
    endBase.resolve();
    await baseWrite;
    await turn();
    flush();
    expect(store.total).toBe(2);
    expect(shown.at(-1)).toBe(2);
    end.resolve();
    endBase.resolve();
    await running;
    await baseWrite;
    await turn();
    flush();
    expect(store.total).toBe(0);
    expect(shown.at(-1)).toBe(0);
  } finally {
    end.resolve();
    await running;
    dispose();
    flush();
  }
});

it("replaces an initial getter with data and restores its descriptor", async () => {
  const end = Promise.withResolvers<void>();
  const get = function (this: { base: number }) {
    return this.base + 1;
  };
  const initial = { base: 1, total: 0 };
  Object.defineProperty(initial, "total", { get, enumerable: true, configurable: true });
  const [store, set] = createOptimisticStore(initial);
  const shown: number[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => store.total,
      value => {
        shown.push(value);
      }
    );
    return dispose;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    expect(store.total).toBe(2);
    running = action(function* () {
      set(d => {
        Object.defineProperty(d, "total", {
          value: 9,
          writable: true,
          enumerable: true,
          configurable: true
        });
      });
      yield end.promise;
    })();
    flush();
    expect(store.total).toBe(9);
    expect(shown.at(-1)).toBe(9);
    expect(Object.getOwnPropertyDescriptor(store, "total")).toEqual({
      value: 9,
      writable: true,
      enumerable: true,
      configurable: true
    });
    end.resolve();
    await running;
    await turn();
    flush();
    expect(store.total).toBe(2);
    expect(shown.at(-1)).toBe(2);
    expect(Object.getOwnPropertyDescriptor(store, "total")).toEqual({
      get,
      set: undefined,
      enumerable: true,
      configurable: true
    });
  } finally {
    end.resolve();
    await running;
    dispose();
    flush();
  }
});

it("publishes an immutable data descriptor without losing value or reverting metadata", async () => {
  const end = Promise.withResolvers<void>();
  const [store, set] = createOptimisticStore({ value: 0 });
  let running: Promise<unknown> | undefined;
  try {
    running = action(function* () {
      set(d => {
        Object.defineProperty(d, "value", {
          value: 7,
          writable: false,
          enumerable: false,
          configurable: true
        });
      });
      yield end.promise;
    })();
    flush();
    expect(store.value).toBe(7);
    expect(Object.keys(store)).toEqual([]);
    expect(Object.getOwnPropertyDescriptor(store, "value")).toEqual({
      value: 7,
      writable: false,
      enumerable: false,
      configurable: true
    });
    end.resolve();
    await running;
    await turn();
    flush();
    expect(store.value).toBe(0);
    expect(Object.keys(store)).toEqual(["value"]);
  } finally {
    end.resolve();
    await running;
    flush();
  }
});

it("matches next's partial draft publication when proxy invariants reject a descriptor", async () => {
  const [store, set] = createOptimisticStore({ value: 0 });
  const end = Promise.withResolvers<void>();
  const running = action(function* () {
    expect(() =>
      set(d => {
        d.value = 7;
        Object.defineProperty(d, "value", { value: 8, configurable: false });
      })
    ).toThrow(TypeError);
    yield end.promise;
  })();
  try {
    flush();
    expect(store.value).toBe(8);
  } finally {
    end.resolve();
    await running;
    flush();
  }
  expect(store.value).toBe(0);
});

it("wraps an object returned by a selected getter so nested reads stay reactive", async () => {
  const end = Promise.withResolvers<void>();
  const endChild = Promise.withResolvers<void>();
  const initial = { child: { value: 1 }, view: { value: 0 } };
  const [store, set] = createOptimisticStore(initial);
  const shown: number[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => store.view.value,
      value => {
        shown.push(value);
      }
    );
    return dispose;
  });
  let getter: Promise<unknown> | undefined;
  let child: Promise<unknown> | undefined;
  try {
    flush();
    getter = action(function* () {
      set(d => {
        Object.defineProperty(d, "view", {
          get() {
            return this.child;
          },
          enumerable: true,
          configurable: true
        });
      });
      yield end.promise;
    })();
    flush();
    expect(shown.at(-1)).toBe(1);
    child = action(function* () {
      set(d => {
        d.child.value = 2;
      });
      yield endChild.promise;
    })();
    flush();
    expect(shown.at(-1)).toBe(2);
  } finally {
    end.resolve();
    endChild.resolve();
    await Promise.all([getter, child]);
    dispose();
    flush();
  }
});
