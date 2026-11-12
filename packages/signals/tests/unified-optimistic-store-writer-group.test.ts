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

it("one setter's outputs hold together through async consequences, unrelated reruns, and late readers", async () => {
  const gate = Promise.withResolvers<void>(),
    answer = Promise.withResolvers<number>();
  const [s, set] = createOptimisticStore({ a: 0, b: 0 });
  const [tick, setTick] = createSignal(0);
  const shown = { a: -1, b: -1, asyncA: -1, tick: -1 };
  const late: number[] = [];
  let lateDispose: (() => void) | undefined;
  const dispose = createRoot(dispose => {
    const asyncA = createMemo(() => (s.a ? answer.promise : 0));
    createRenderEffect(
      () => s.a,
      v => {
        shown.a = v;
      }
    );
    createRenderEffect(
      () => [s.b, tick()],
      ([b, t]) => {
        shown.b = b;
        shown.tick = t;
      }
    );
    createRenderEffect(asyncA, v => {
      shown.asyncA = v;
    });
    return dispose;
  });
  let running: Promise<unknown> | undefined;
  try {
    flush();
    running = action(function* () {
      set(d => {
        d.a = 1;
        d.b = 1;
      });
      yield gate.promise;
    })();
    flush();
    await turn();
    expect(shown).toEqual({ a: 0, b: 0, asyncA: 0, tick: 0 });
    setTick(1);
    flush();
    expect(shown).toEqual({ a: 0, b: 0, asyncA: 0, tick: 1 });
    lateDispose = createRoot(dispose => {
      createRenderEffect(
        () => s.b,
        v => {
          late.push(v);
        }
      );
      return dispose;
    });
    flush();
    expect(late).not.toContain(1);
    expect(shown.b).toBe(0);
    answer.resolve(10);
    await turn();
    flush();
    expect(shown).toEqual({ a: 1, b: 1, asyncA: 10, tick: 1 });
    expect(late.at(-1)).toBe(1);
    gate.resolve();
    await running;
    await turn();
    flush();
    expect(shown).toEqual({ a: 0, b: 0, asyncA: 0, tick: 1 });
    expect(late.at(-1)).toBe(0);
  } finally {
    gate.resolve();
    answer.resolve(10);
    if (running) await running;
    lateDispose?.();
    dispose();
    flush();
  }
});

it("a superseding setter replaces the grouped proposal and obsolete async work cannot publish it", async () => {
  const first = Promise.withResolvers<number>(),
    second = Promise.withResolvers<number>();
  const endA = Promise.withResolvers<void>(),
    endB = Promise.withResolvers<void>();
  const [s, set] = createOptimisticStore({ a: 0, b: 0 });
  const shown = { a: -1, b: -1, asyncA: -1 };
  const dispose = createRoot(dispose => {
    const asyncA = createMemo(() => (s.a === 1 ? first.promise : s.a === 2 ? second.promise : 0));
    createRenderEffect(
      () => s.a,
      v => {
        shown.a = v;
      }
    );
    createRenderEffect(
      () => s.b,
      v => {
        shown.b = v;
      }
    );
    createRenderEffect(asyncA, v => {
      shown.asyncA = v;
    });
    return dispose;
  });
  let a: Promise<unknown> | undefined, b: Promise<unknown> | undefined;
  try {
    flush();
    a = action(function* () {
      set(d => {
        d.a = 1;
        d.b = 1;
      });
      yield endA.promise;
    })();
    flush();
    expect(shown).toEqual({ a: 0, b: 0, asyncA: 0 });
    b = action(function* () {
      set(d => {
        d.a = 2;
        d.b = 2;
      });
      yield endB.promise;
    })();
    flush();
    expect(shown).toEqual({ a: 0, b: 0, asyncA: 0 });
    first.resolve(10);
    await turn();
    flush();
    expect(shown).toEqual({ a: 0, b: 0, asyncA: 0 });
    second.resolve(20);
    await turn();
    flush();
    expect(shown).toEqual({ a: 2, b: 2, asyncA: 20 });
    endA.resolve();
    await turn();
    flush();
    expect(shown).toEqual({ a: 2, b: 2, asyncA: 20 });
    endB.resolve();
    await Promise.all([a, b]);
    await turn();
    flush();
    expect(shown).toEqual({ a: 0, b: 0, asyncA: 0 });
  } finally {
    first.resolve(10);
    second.resolve(20);
    endA.resolve();
    endB.resolve();
    await Promise.all([a, b]);
    dispose();
    flush();
  }
});

it("a superseding batch can cancel a pending guess back to committed while publishing another changed property", async () => {
  const answer = Promise.withResolvers<number>(),
    endA = Promise.withResolvers<void>(),
    endB = Promise.withResolvers<void>();
  const [s, set] = createOptimisticStore({ a: 0, b: 0 });
  const shown = { a: -1, b: -1, asyncA: -1 };
  const dispose = createRoot(dispose => {
    const asyncA = createMemo(() => (s.a ? answer.promise : 0));
    createRenderEffect(
      () => s.a,
      v => {
        shown.a = v;
      }
    );
    createRenderEffect(
      () => s.b,
      v => {
        shown.b = v;
      }
    );
    createRenderEffect(asyncA, v => {
      shown.asyncA = v;
    });
    return dispose;
  });
  let a: Promise<unknown> | undefined, b: Promise<unknown> | undefined;
  try {
    flush();
    a = action(function* () {
      set(d => {
        d.a = 1;
        d.b = 1;
      });
      yield endA.promise;
    })();
    flush();
    expect(shown).toEqual({ a: 0, b: 0, asyncA: 0 });
    b = action(function* () {
      set(d => {
        d.a = 0;
        d.b = 2;
      });
      yield endB.promise;
    })();
    flush();
    await turn();
    flush();
    expect(shown).toEqual({ a: 0, b: 2, asyncA: 0 });
    answer.resolve(10);
    await turn();
    flush();
    expect(shown).toEqual({ a: 0, b: 2, asyncA: 0 });
    endA.resolve();
    await turn();
    flush();
    expect(shown).toEqual({ a: 0, b: 2, asyncA: 0 });
    endB.resolve();
    await Promise.all([a, b]);
    await turn();
    flush();
    expect(shown).toEqual({ a: 0, b: 0, asyncA: 0 });
  } finally {
    answer.resolve(10);
    endA.resolve();
    endB.resolve();
    await Promise.all([a, b]);
    dispose();
    flush();
  }
});

it("overlapping setter batches share publication through their common output and retain the existing same-key action lifetime", async () => {
  const answer = Promise.withResolvers<number>(),
    endA = Promise.withResolvers<void>(),
    endB = Promise.withResolvers<void>();
  const [s, set] = createOptimisticStore({ a: 0, b: 0, c: 0 });
  const shown = { a: -1, b: -1, c: -1, asyncA: -1 };
  const dispose = createRoot(dispose => {
    const asyncA = createMemo(() => (s.a ? answer.promise : 0));
    createRenderEffect(
      () => s.a,
      v => {
        shown.a = v;
      }
    );
    createRenderEffect(
      () => s.b,
      v => {
        shown.b = v;
      }
    );
    createRenderEffect(
      () => s.c,
      v => {
        shown.c = v;
      }
    );
    createRenderEffect(asyncA, v => {
      shown.asyncA = v;
    });
    return dispose;
  });
  let a: Promise<unknown> | undefined, b: Promise<unknown> | undefined;
  try {
    flush();
    a = action(function* () {
      set(d => {
        d.a = 1;
        d.b = 1;
      });
      yield endA.promise;
    })();
    flush();
    b = action(function* () {
      set(d => {
        d.b = 2;
        d.c = 2;
      });
      yield endB.promise;
    })();
    flush();
    expect(shown).toEqual({ a: 0, b: 0, c: 0, asyncA: 0 });
    answer.resolve(10);
    await turn();
    flush();
    expect(shown).toEqual({ a: 1, b: 2, c: 2, asyncA: 10 });
    endA.resolve();
    await turn();
    flush();
    expect(shown).toEqual({ a: 1, b: 2, c: 2, asyncA: 10 });
    endB.resolve();
    await Promise.all([a, b]);
    await turn();
    flush();
    expect(shown).toEqual({ a: 0, b: 0, c: 0, asyncA: 0 });
  } finally {
    answer.resolve(10);
    endA.resolve();
    endB.resolve();
    await Promise.all([a, b]);
    dispose();
    flush();
  }
});

it("a completed writer publication does not entangle a later disjoint event with the still-open guessing action", async () => {
  const endA = Promise.withResolvers<void>(),
    endC = Promise.withResolvers<void>();
  const [s, set] = createOptimisticStore({ a: 0, b: 0, c: 0 });
  const shown = { a: -1, b: -1, c: -1 };
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => s.a,
      v => {
        shown.a = v;
      }
    );
    createRenderEffect(
      () => s.b,
      v => {
        shown.b = v;
      }
    );
    createRenderEffect(
      () => s.c,
      v => {
        shown.c = v;
      }
    );
    return dispose;
  });
  let a: Promise<unknown> | undefined, c: Promise<unknown> | undefined;
  try {
    flush();
    a = action(function* () {
      set(d => {
        d.a = 1;
        d.b = 1;
      });
      yield endA.promise;
    })();
    flush();
    expect(shown).toEqual({ a: 1, b: 1, c: 0 });
    c = action(function* () {
      set(d => {
        d.c = 3;
      });
      yield endC.promise;
    })();
    flush();
    expect(shown).toEqual({ a: 1, b: 1, c: 3 });
    endC.resolve();
    await c;
    await turn();
    flush();
    expect(shown).toEqual({ a: 1, b: 1, c: 0 });
    endA.resolve();
    await a;
    await turn();
    flush();
    expect(shown).toEqual({ a: 0, b: 0, c: 0 });
  } finally {
    endA.resolve();
    endC.resolve();
    await Promise.all([a, c]);
    dispose();
    flush();
  }
});
