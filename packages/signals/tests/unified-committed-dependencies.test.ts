import { afterEach, expect, it } from "vitest";
import {
  action,
  createEffect,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup,
  resetErrorHalt
} from "../src/index.js";
import { $REFRESH } from "../src/core/constants.js";
import type { Computed } from "../src/core/types.js";
import {
  committedDependencies,
  layerPosition
} from "../src/layers/committed-dependencies.js";
import { createLayer } from "../src/layers/layer.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
  resetErrorHalt();
});
const node = (accessor: () => unknown) => (accessor as any)[$REFRESH] as Computed<any>;
const inputs = (accessor: () => unknown) => new Set(committedDependencies(node(accessor)));

for (const equal of [false, true]) {
  it(`keeps committed dependencies across superseded held branches (equal=${equal})`, async () => {
    const end = Promise.withResolvers<void>();
    const [branch, setBranch] = createSignal(0);
    const [a] = createSignal(10),
      [b] = createSignal(equal ? 10 : 20),
      [c] = createSignal(30);
    let value!: () => number,
      shown = -1;
    createRoot(dispose => {
      disposals.push(dispose);
      value = createMemo(() => (branch() === 0 ? a() : branch() === 1 ? b() : c()));
      createRenderEffect(value, next => {
        shown = next;
      });
    });
    flush();
    const initial = new Set([node(branch), node(a)]);
    expect(inputs(value)).toEqual(initial);
    const running = action(function* () {
      setBranch(1);
      yield end.promise;
    })();
    flush();
    expect(shown).toBe(10);
    expect(inputs(value)).toEqual(initial);
    setBranch(2);
    flush();
    expect(shown).toBe(10);
    expect(inputs(value)).toEqual(initial);
    end.resolve();
    await running;
    await turn();
    expect(shown).toBe(30);
    expect(inputs(value)).toEqual(new Set([node(branch), node(c)]));
  });
}

for (const owned of [false, true]) {
  it(`publishes equal branch replacement dependencies (owned=${owned})`, async () => {
    const end = Promise.withResolvers<void>();
    const [branch, setBranch] = createSignal(false),
      [a] = createSignal(10),
      [b] = createSignal(10);
    let value!: () => number,
      shown = -1;
    const cleanups: boolean[] = [];
    createRoot(dispose => {
      disposals.push(dispose);
      value = createMemo(() => {
        const next = branch();
        if (owned) onCleanup(() => cleanups.push(next));
        return next ? b() : a();
      });
      createRenderEffect(value, next => {
        shown = next;
      });
    });
    flush();
    const running = action(function* () {
      setBranch(true);
      yield end.promise;
    })();
    flush();
    expect(inputs(value)).toEqual(new Set([node(branch), node(a)]));
    expect(cleanups).toEqual([]);
    end.resolve();
    await running;
    await turn();
    expect(shown).toBe(10);
    expect(inputs(value)).toEqual(new Set([node(branch), node(b)]));
    expect(cleanups).toEqual(owned ? [false] : []);
  });
}

it("preserves a dropped dependency until a held replacement publishes", async () => {
  const end = Promise.withResolvers<void>();
  const [branch, setBranch] = createSignal(false),
    [a] = createSignal(10);
  let value!: () => number,
    shown = -1;
  createRoot(dispose => {
    disposals.push(dispose);
    value = createMemo(() => (branch() ? 0 : a()));
    createRenderEffect(value, next => {
      shown = next;
    });
  });
  flush();
  const running = action(function* () {
    setBranch(true);
    yield end.promise;
  })();
  flush();
  expect(shown).toBe(10);
  expect(inputs(value)).toEqual(new Set([node(branch), node(a)]));
  end.resolve();
  await running;
  await turn();
  expect(shown).toBe(0);
  expect(inputs(value)).toEqual(new Set([node(branch)]));
});

it("preserves dependencies through reordered reads and async supersession", async () => {
  const answer = Promise.withResolvers<number>();
  const obsolete = Promise.withResolvers<number>();
  const [branch, setBranch] = createSignal(0),
    [a] = createSignal(10),
    [b] = createSignal(20);
  let value!: () => number,
    shown = -1;
  createRoot(dispose => {
    disposals.push(dispose);
    value = createMemo(() => {
      const next = branch();
      if (next === 0) return a() + b();
      b();
      a();
      return next === 1 ? obsolete.promise : answer.promise;
    });
    createRenderEffect(value, next => {
      shown = next;
    });
  });
  flush();
  const initial = [...committedDependencies(node(value))];
  setBranch(1);
  flush();
  setBranch(2);
  flush();
  expect(shown).toBe(30);
  expect([...committedDependencies(node(value))]).toEqual(initial);
  answer.resolve(40);
  await turn();
  expect(shown).toBe(40);
  expect([...committedDependencies(node(value))]).toEqual([node(branch), node(b), node(a)]);
  obsolete.resolve(99);
  await turn();
  expect(shown).toBe(40);
});

it("uses committed branches to determine the layer of a pending input", async () => {
  const end = Promise.withResolvers<void>();
  const [branch, setBranch] = createSignal(false),
    [source] = createSignal(0);
  let value!: () => number,
    view!: () => number,
    guess!: (n: number) => number,
    shown = -1;
  createRoot(dispose => {
    disposals.push(dispose);
    [view, guess] = createLayer(source);
    value = createMemo(() => (branch() ? view() : source()));
    createRenderEffect(value, next => {
      shown = next;
    });
  });
  guess(10);
  flush();
  expect(layerPosition(node(view))).toBe(1);
  expect(layerPosition(node(value))).toBe(0);
  const running = action(function* () {
    setBranch(true);
    yield end.promise;
  })();
  flush();
  expect(shown).toBe(0);
  expect(layerPosition(node(value))).toBe(0);
  end.resolve();
  await running;
  await turn();
  expect(shown).toBe(10);
  expect(layerPosition(node(value))).toBe(1);
});

it("keeps proposal positions stable and makes inactive wrappers transparent", () => {
  createRoot(dispose => {
    disposals.push(dispose);
    const [source] = createSignal(0);
    const [a, guessA, clearA] = createLayer(source);
    const [wrapper] = createLayer(a);
    const [b, guessB, clearB] = createLayer(wrapper);
    const first = createMemo(() => a() + b());
    const reversed = createMemo(() => b() + a());
    createRenderEffect(
      () => [first(), reversed()],
      () => {}
    );
    expect(layerPosition(node(b))).toBe(0);
    guessB(2);
    flush();
    expect([layerPosition(node(first)), layerPosition(node(reversed))]).toEqual([1, 1]);
    guessA(1);
    flush();
    // Activating an input boundary does not relocate the existing child guess.
    expect([layerPosition(node(first)), layerPosition(node(reversed))]).toEqual([1, 1]);
    guessB(3);
    flush();
    // A genuine new proposal selects its context from the now-active input.
    expect([layerPosition(node(first)), layerPosition(node(reversed))]).toEqual([2, 2]);
    clearA();
    flush();
    expect([layerPosition(node(first)), layerPosition(node(reversed))]).toEqual([2, 2]);
    clearB();
    flush();
    expect([layerPosition(node(first)), layerPosition(node(reversed))]).toEqual([0, 0]);
  });
});

it("publishes error dependencies together with the error and recovers", async () => {
  const end = Promise.withResolvers<void>();
  const [branch, setBranch] = createSignal(0),
    [a] = createSignal(10),
    [b] = createSignal(20);
  let value!: () => number,
    shown: number | string = -1;
  createRoot(dispose => {
    disposals.push(dispose);
    value = createMemo(() => {
      const next = branch();
      if (next === 1) throw new Error("failed");
      return next === 0 ? a() : b();
    });
    createEffect(value, {
      effect: next => {
        shown = next;
      },
      error: () => {
        shown = "error";
      }
    });
  });
  flush();
  const running = action(function* () {
    setBranch(1);
    yield end.promise;
  })();
  flush();
  expect(shown).toBe(10);
  expect(inputs(value)).toEqual(new Set([node(branch), node(a)]));
  end.resolve();
  await running;
  await turn();
  expect(shown).toBe("error");
  expect(inputs(value)).toEqual(new Set([node(branch)]));
  setBranch(2);
  flush();
  expect(shown).toBe(20);
  expect(inputs(value)).toEqual(new Set([node(branch), node(b)]));
});
