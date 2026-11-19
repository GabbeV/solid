import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  isPending,
  latest,
  onCleanup
} from "../src/index.js";

import { createLayer } from "../src/layers/optimistic.js";

it("reclaims an ownerless memo read then dirtied inside an effect before another request starts", () => {
  const [input, setInput] = createSignal(0);
  const [tick, setTick] = createSignal(0);
  const requests: number[] = [];
  const cleanups: number[] = [];
  const memo = createMemo(() => {
    const value = input();
    requests.push(value);
    onCleanup(() => cleanups.push(value));
    return value === 0 ? 0 : new Promise<number>(() => {});
  });
  const dispose = createRoot(dispose => {
    createRenderEffect(tick, value => {
      if (value) {
        expect(memo()).toBe(0);
        setInput(1);
      }
    });
    return dispose;
  });
  try {
    flush();
    setTick(1);
    flush();
    expect(requests).toEqual([0]);
    expect(cleanups).toEqual([0]);
  } finally {
    dispose();
    flush();
  }
});

it("drains actual signal writes from final unobserved cleanup before flush returns", () => {
  const [tick, setTick] = createSignal(0);
  const [answer, setAnswer] = createSignal(0);
  const events: number[] = [];
  const memo = createMemo(() => {
    onCleanup(() => setAnswer(1));
    return 0;
  });
  const dispose = createRoot(dispose => {
    createRenderEffect(answer, value => {
      events.push(value);
    });
    createRenderEffect(tick, value => {
      if (value) expect(memo()).toBe(0);
    });
    return dispose;
  });
  try {
    flush();
    setTick(1);
    flush();
    expect(answer()).toBe(1);
    expect(events).toEqual([0, 1]);
  } finally {
    dispose();
    flush();
  }
});

it("keeps cleanup reads and nested flush inside the outer drain before publishing writes", () => {
  const [input, setInput] = createSignal(0);
  const [answer, setAnswer] = createSignal(0);
  let shown = 0;
  const events: string[] = [];
  const memo = createMemo(() => {
    input();
    onCleanup(() => {
      events.push(`cleanup:${shown}`);
      setAnswer(1);
      flush();
      events.push(`after nested flush:${shown}`);
    });
    return 0;
  });
  const dispose = createRoot(dispose => {
    createRenderEffect(answer, value => {
      shown = value;
    });
    return dispose;
  });
  try {
    expect(memo()).toBe(0);
    setInput(1);
    flush();
    expect(events).toEqual(["cleanup:0", "after nested flush:0"]);
    expect(shown).toBe(1);
  } finally {
    dispose();
    flush();
  }
});

it("reclaims an ownerless memo read then dirtied by committing child cleanup before another request starts", () => {
  const [input, setInput] = createSignal(0);
  const [branch, setBranch] = createSignal(0);
  const requests: number[] = [];
  const memo = createMemo(() => {
    const value = input();
    requests.push(value);
    return value === 0 ? 0 : new Promise<number>(() => {});
  });
  const dispose = createRoot(dispose => {
    const owner = createMemo(() => {
      const value = branch();
      onCleanup(() => {
        expect(memo()).toBe(0);
        setInput(1);
      });
      return value;
    });
    createRenderEffect(owner, () => {});
    return dispose;
  });
  try {
    flush();
    setBranch(1);
    flush();
    expect(requests).toEqual([0]);
  } finally {
    dispose();
    flush();
  }
});

it("an equal untracked selector admits later observers and retires their next held question", async () => {
  const [source, setSource] = createSignal(0);
  const [trigger, setTrigger] = createSignal(0, {
    equals(previous, next) {
      isPending(source);
      latest(source);
      return Object.is(previous, next);
    }
  });
  const triggerEnd = Promise.withResolvers<void>();
  const sourceEnd = Promise.withResolvers<void>();
  const outerDispose = createRoot(dispose => {
    createRenderEffect(
      () => [trigger(), isPending(trigger)],
      () => {}
    );
    return dispose;
  });
  let innerDispose: (() => void) | undefined;
  let triggerRun: Promise<void> | undefined;
  let sourceRun: Promise<void> | undefined;
  const screen: (readonly [number, boolean, number])[] = [];
  try {
    flush();
    triggerRun = action(function* () {
      setTrigger(1);
      yield triggerEnd.promise;
    })();
    flush();
    // Reuse the source-owned outputs after untracked initialization and dormancy.
    innerDispose = createRoot(dispose => {
      createRenderEffect(
        () => [source(), isPending(source), latest(source)] as const,
        value => {
          screen.push(value);
        }
      );
      return dispose;
    });
    flush();
    expect(screen).toEqual([[0, false, 0]]);
    sourceRun = action(function* () {
      setSource(1);
      yield sourceEnd.promise;
    })();
    flush();
    expect(screen.at(-1)).toEqual([0, true, 1]);
    sourceEnd.resolve();
    await sourceRun;
    await new Promise<void>(resolve => setTimeout(resolve, 0));
    expect(screen.at(-1)).toEqual([1, false, 1]);
    expect(trigger()).toBe(0);
  } finally {
    triggerEnd.resolve();
    sourceEnd.resolve();
    await Promise.all([triggerRun, sourceRun]);
    innerDispose?.();
    outerDispose();
    flush();
  }
});

it("an unobserved optimistic output recovers a shown error with an equal last-good override", () => {
  const failure = new Error("input failed");
  const [failed, setFailed] = createSignal(false);
  let view!: () => number;
  let guess!: (value: number) => number;
  const dispose = createRoot(dispose => {
    [view, guess] = createLayer(() => {
      if (failed()) throw failure;
      return 0;
    });
    return dispose;
  });
  try {
    expect(view()).toBe(0);
    setFailed(true);
    flush();
    expect(view).toThrow("input failed");
    guess(0);
    flush();
    expect(view()).toBe(0);
    let shown = -1;
    createRoot(disposeLate => {
      createRenderEffect(view, value => {
        shown = value;
      });
      expect(shown).toBe(0);
      disposeLate();
    });
  } finally {
    dispose();
    flush();
  }
});

it("a lazy undefined optimistic output initializes before a late reader after an equal override", () => {
  let view!: () => undefined;
  let guess!: (value: undefined) => undefined;
  let calls = 0;
  const dispose = createRoot(dispose => {
    [view, guess] = createLayer(
      () => {
        calls++;
        return undefined;
      },
      { lifetime: "action", node: { lazy: true } }
    );
    return dispose;
  });
  try {
    guess(undefined);
    flush();
    expect(view()).toBeUndefined();
    expect(calls).toBe(1);
    createRoot(disposeLate => {
      const shown: unknown[] = [];
      createRenderEffect(view, value => {
        shown.push(value);
      });
      expect(shown).toEqual([undefined]);
      disposeLate();
    });
  } finally {
    dispose();
    flush();
  }
});

it("unobserved comparator queries quiesce across event-loop turns while the action stays open", async () => {
  const [unrelated] = createSignal(0);
  let armed = false;
  let calls = 0;
  const [source, setSource] = createSignal(0, {
    equals(previous, next) {
      if (armed) {
        if (++calls > 40) {
          armed = false;
          throw new Error("comparator query did not quiesce across turns");
        }
        expect(isPending(unrelated)).toBe(false);
      }
      return Object.is(previous, next);
    }
  });
  const end = Promise.withResolvers<void>();
  const screen: (readonly [number, boolean])[] = [];
  const dispose = createRoot(dispose => {
    createRenderEffect(
      () => [source(), isPending(source)] as const,
      value => {
        screen.push(value);
      }
    );
    return dispose;
  });
  let running: Promise<void> | undefined;
  try {
    flush();
    armed = true;
    running = action(function* () {
      setSource(1);
      yield end.promise;
    })();
    flush();
    const afterFlush = calls;
    await new Promise<void>(resolve => setTimeout(resolve, 0));
    await new Promise<void>(resolve => setTimeout(resolve, 0));
    expect(calls).toBe(afterFlush);
    expect(source()).toBe(0);
    expect(screen).toEqual([
      [0, false],
      [0, true]
    ]);
  } finally {
    armed = false;
    end.resolve();
    await running;
    await new Promise<void>(resolve => setTimeout(resolve, 0));
    dispose();
    flush();
  }
});
