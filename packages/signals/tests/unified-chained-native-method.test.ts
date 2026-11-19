import { expect, it } from "vitest";
import {
  action,
  createOptimisticStore,
  createRenderEffect,
  createRoot,
  createSignal,
  createStore,
  flush,
  refresh
} from "../src/index.js";
const settle = async () => {
  for (let i = 0; i < 6; i++) await Promise.resolve();
  flush();
};

it("a chained own map getter receives the outer selected object exactly once per direct read", async () => {
  let calls = 0;
  const raw: any = [1, 2];
  raw.offset = 0;
  Object.defineProperty(raw, "map", {
    configurable: true,
    get() {
      calls++;
      const offset = this.offset;
      return () => offset;
    }
  });
  const [outer, set, dispose] = createRoot(dispose => {
    const [base] = createStore<any>(raw);
    const [outer, set] = createOptimisticStore<any>(() => base, []);
    createRenderEffect(
      () => outer.map(),
      () => {}
    );
    return [outer, set, dispose] as const;
  });
  const gate = Promise.withResolvers<void>();
  let running: Promise<unknown> | undefined;
  try {
    flush();
    calls = 0;
    expect(outer.map()).toBe(0);
    expect(calls).toBe(1);
    running = action(function* () {
      set((d: any) => {
        d.offset = 7;
      });
      yield gate.promise;
    })();
    flush();
    calls = 0;
    expect(outer.map()).toBe(7);
    expect(calls).toBe(1);
    gate.resolve();
    await running;
    await settle();
    calls = 0;
    expect(outer.map()).toBe(0);
    expect(calls).toBe(1);
  } finally {
    gate.resolve();
    await running;
    dispose();
    flush();
  }
});

for (const chained of [false, true])
  it(`an inherited map is untracked until an own method is actually read (chained=${chained})`, async () => {
    const [source, setSource] = createSignal<any>([1, 2]);
    const [tick, setTick] = createSignal(0);
    const frames: string[] = [];
    const [view, dispose] = createRoot(dispose => {
      const [base] = createOptimisticStore<any>(() => source(), []);
      const [outer] = createOptimisticStore<any>(() => base, []);
      const view = chained ? outer : base;
      createRenderEffect(
        () => {
          tick();
          return view.map((value: number) => value).join(",");
        },
        value => {
          frames.push(value);
        }
      );
      return [view, dispose] as const;
    });
    try {
      flush();
      expect(frames.at(-1)).toBe("1,2");
      const own: any = [1, 2];
      own.map = () => [9];
      setSource(own);
      flush();
      expect(view.map((value: number) => value)).toEqual([9]);
      const afterOwn = frames.slice();
      setTick(1);
      flush();
      expect(frames.at(-1)).toBe("9");
      const next: any = [1, 2];
      next.map = () => [8];
      setSource(next);
      flush();
      expect(frames.at(-1)).toBe("8");
      // Prototype lookup itself is not a dependency on a future own field.
      expect(afterOwn).toEqual(["1,2"]);
    } finally {
      dispose();
      flush();
    }
  });

for (const method of ["own-data", "own-getter", "prototype"] as const)
  it(`a published ${method} map replacement keeps the selected outer receiver`, async () => {
    const answers: Array<(value: any) => void> = [];
    const gate = Promise.withResolvers<void>();
    const frames: string[] = [];
    let getterCalls = 0;
    const [inner, outer, setOuter, dispose] = createRoot(dispose => {
      const [inner] = createOptimisticStore<any>(
        () =>
          new Promise(resolve => {
            answers.push(resolve);
          }),
        []
      );
      const [outer, setOuter] = createOptimisticStore<any>(() => inner, []);
      createRenderEffect(
        () => outer.map((value: number) => value).join(","),
        frame => {
          frames.push(frame);
        }
      );
      return [inner, outer, setOuter, dispose] as const;
    });
    let running: Promise<unknown> | undefined;
    const value: any = [3, 4];
    value.offset = 0;
    const map = function (this: any, fn: (value: number) => number) {
      const offset = this.offset;
      return Array.prototype.map.call(this, (value: number) => fn(value) + offset);
    };
    if (method === "own-data") value.map = map;
    else if (method === "own-getter")
      Object.defineProperty(value, "map", {
        configurable: true,
        get() {
          getterCalls++;
          const offset = this.offset;
          return function (this: any, fn: (value: number) => number) {
            return Array.prototype.map.call(this, (value: number) => fn(value) + offset);
          };
        }
      });
    else {
      const prototype = Object.create(Array.prototype);
      prototype.map = map;
      Object.setPrototypeOf(value, prototype);
    }
    try {
      flush();
      const initial: any = [1, 2];
      initial.offset = 0;
      answers.shift()!(initial);
      await settle();
      expect(frames.at(-1)).toBe("1,2");
      running = action(function* () {
        setOuter((d: any) => {
          d.offset = 7;
        });
        yield gate.promise;
      })();
      flush();
      refresh(inner);
      flush();
      expect(frames.at(-1)).toBe("1,2");
      answers.shift()!(value);
      await settle();
      expect(frames.at(-1)).toBe("10,11");
      getterCalls = 0;
      expect(outer.map((value: number) => value)).toEqual([10, 11]);
      if (method === "own-getter") expect(getterCalls).toBe(1);
      gate.resolve();
      await running;
      await settle();
      expect(frames.at(-1)).toBe("3,4");
    } finally {
      gate.resolve();
      answers.splice(0).forEach(resolve => resolve(value));
      await running;
      dispose();
      flush();
    }
  });

it("a retained whole-array getter keeps the outer receiver after inner truth changes its descriptor", async () => {
  let calls = 0;
  const initial: any = [1, 2];
  initial.offset = 0;
  const [source, setSource] = createSignal<any>({ items: initial });
  const replacement: any = [1, 2];
  replacement.offset = 0;
  Object.defineProperty(replacement, "map", {
    configurable: true,
    get() {
      calls++;
      const offset = this.offset;
      return () => [offset];
    }
  });
  const gate = Promise.withResolvers<void>();
  const [setInner, outer, setOuter, dispose] = createRoot(dispose => {
    const [inner, setInner] = createOptimisticStore<any>(() => source(), { items: initial });
    const [outer, setOuter] = createOptimisticStore<any>(() => inner.items, []);
    createRenderEffect(
      () => outer.map((value: number) => value).join(","),
      () => {}
    );
    return [setInner, outer, setOuter, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    running = action(function* () {
      setInner((d: any) => {
        d.items = replacement;
      });
      setOuter((d: any) => {
        d.offset = 7;
      });
      yield gate.promise;
    })();
    flush();
    const truth: any = [3, 4];
    truth.offset = 0;
    setSource({ items: truth });
    flush();
    calls = 0;
    expect(outer.map((value: number) => value)).toEqual([7]);
    expect(calls).toBe(1);
    gate.resolve();
    await running;
    await settle();
    expect(outer.map((value: number) => value)).toEqual([3, 4]);
  } finally {
    gate.resolve();
    await running;
    dispose();
    flush();
  }
});

it("a held own map replacement keeps the old function until its input publishes", async () => {
  let calls = 0;
  const initial: any = [1, 2];
  initial.offset = 0;
  const [source, setSource] = createSignal<any>(initial);
  const ownEnd = Promise.withResolvers<void>(),
    inputEnd = Promise.withResolvers<void>();
  const frames: string[] = [];
  const [outer, setOuter, dispose] = createRoot(dispose => {
    const [inner] = createOptimisticStore<any>(() => source(), []);
    const [outer, setOuter] = createOptimisticStore<any>(() => inner, []);
    createRenderEffect(
      () => outer.map((value: number) => value).join(","),
      value => {
        frames.push(value);
      }
    );
    return [outer, setOuter, dispose] as const;
  });
  let own: Promise<unknown> | undefined, incoming: Promise<unknown> | undefined;
  try {
    flush();
    own = action(function* () {
      setOuter((d: any) => {
        d.offset = 7;
      });
      yield ownEnd.promise;
    })();
    flush();
    const future: any = [3, 4];
    future.offset = 0;
    Object.defineProperty(future, "map", {
      configurable: true,
      get() {
        calls++;
        const offset = this.offset;
        return function (this: any, fn: (value: number) => number) {
          return Array.prototype.map.call(this, (value: number) => fn(value) + offset);
        };
      }
    });
    incoming = action(function* () {
      setSource(future);
      yield inputEnd.promise;
    })();
    flush();
    expect(frames.at(-1)).toBe("1,2");
    calls = 0;
    expect(outer.map((value: number) => value)).toEqual([1, 2]);
    inputEnd.resolve();
    await incoming;
    await settle();
    expect(frames.at(-1)).toBe("10,11");
    calls = 0;
    expect(outer.map((value: number) => value)).toEqual([10, 11]);
    expect(calls).toBe(1);
    ownEnd.resolve();
    await own;
    await settle();
    expect(frames.at(-1)).toBe("3,4");
  } finally {
    ownEnd.resolve();
    inputEnd.resolve();
    await Promise.all([own, incoming]);
    dispose();
    flush();
  }
});

it("a cold own getter from a published parent keeps the outer receiver after truth loses that getter", async () => {
  let calls = 0;
  const initial: any = [1, 2];
  initial.offset = 0;
  const [source, setSource] = createSignal<any>({ items: initial });
  const replacement: any = [1, 2];
  replacement.offset = 0;
  Object.defineProperty(replacement, "map", {
    configurable: true,
    get() {
      calls++;
      const offset = this.offset;
      return () => [offset];
    }
  });
  const gate = Promise.withResolvers<void>();
  const [setInner, outer, setOuter, dispose] = createRoot(dispose => {
    const [inner, setInner] = createOptimisticStore<any>(() => source(), { items: initial });
    createRenderEffect(
      () => inner.items.length,
      () => {}
    );
    const [outer, setOuter] = createOptimisticStore<any>(() => inner.items, []);
    return [setInner, outer, setOuter, dispose] as const;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    running = action(function* () {
      setInner((d: any) => {
        d.items = replacement;
      });
      setOuter((d: any) => {
        d.offset = 7;
      });
      yield gate.promise;
    })();
    flush();
    const truth: any = [3, 4];
    truth.offset = 0;
    setSource({ items: truth });
    flush();
    calls = 0;
    expect(outer.map((value: number) => value)).toEqual([7]);
    expect(calls).toBe(1);
    gate.resolve();
    await running;
    await settle();
    expect(outer.map((value: number) => value)).toEqual([3, 4]);
  } finally {
    gate.resolve();
    await running;
    dispose();
    flush();
  }
});
