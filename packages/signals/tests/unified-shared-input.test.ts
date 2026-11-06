import { expect, it } from "vitest";
import {
  action, createEffect, createLoadingBoundary, createMemo, createOptimistic, createRenderEffect,
  createRoot, createSignal, flush, isPending, refresh
} from "../src/index.js";
import { $REFRESH } from "../src/core/constants.js";
import { boundaries } from "../src/layers/boundary.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

it("stream values still pass through the optimistic input's normalization", async () => {
  const steps: ReturnType<typeof Promise.withResolvers<IteratorResult<unknown>>>[] = [];
  const raw = Promise.withResolvers<number>();
  const stream: AsyncIterable<unknown> = {
    [Symbol.asyncIterator]() {
      return {
        next() {
          const step = Promise.withResolvers<IteratorResult<unknown>>();
          steps.push(step);
          return step.promise;
        },
        return: async () => ({ done: true as const, value: undefined })
      };
    }
  };
  let shown: unknown;
  const dispose = createRoot(dispose => {
    const source = createMemo(() => stream);
    const [view] = createOptimistic(source);
    const content = createLoadingBoundary(() => ({ value: view() }), () => ({ value: "loading" }));
    createRenderEffect(content, value => { shown = value.value; });
    return dispose;
  });
  try {
    flush();
    expect(shown).toBe("loading");
    steps[0].resolve({ done: false, value: 0 });
    await turn();
    expect(shown).toBe(0);
    steps[1].resolve({ done: false, value: raw.promise });
    await turn();
    expect(shown).toBe(0);
    raw.resolve(2);
    await turn();
    expect(shown).toBe(2);
  } finally {
    raw.resolve(2);
    dispose();
    flush();
  }
});

it("a raw loading seed retains the boundary's input normalizer", async () => {
  const seed = Promise.withResolvers<string>(), answer = Promise.withResolvers<string>();
  let shown: unknown;
  const dispose = createRoot(dispose => {
    const incoming = createMemo(() => answer.promise);
    const source = createMemo<unknown>(() => incoming(), { sync: true, loadingValue: seed.promise });
    const [view] = createOptimistic(source);
    const content = createLoadingBoundary(view, () => "loading");
    createRenderEffect(content, value => { shown = value; });
    return dispose;
  });
  try {
    flush();
    expect(shown).toBe("loading");
    seed.resolve("placeholder");
    await turn();
    expect(shown).toBe("placeholder");
    answer.resolve("answer");
    await turn();
    expect(shown).toBe("answer");
  } finally {
    seed.resolve("placeholder");
    answer.resolve("answer");
    dispose();
    flush();
  }
});

for (const sync of [false, true])
it(`a direct input refresh preserves the source, including from an effect (sync=${sync})`, async () => {
  let input!: () => number, view!: () => number, runs = 0, shown = 0;
  let request!: (value: number) => number, result!: Promise<number>;
  const [source, setSource] = createSignal(1);
  const dispose = createRoot(dispose => {
    input = createMemo(() => { runs++; return source() * 2; }, { sync });
    [view] = createOptimistic(input);
    createRenderEffect(view, value => { shown = value; });
    const [click, setClick] = createSignal(0);
    request = setClick;
    createEffect(click, value => { if (value) result = refresh(view); });
    return dispose;
  });
  try {
    flush();
    const layer = boundaries.get((view as any)[$REFRESH])!;
    const original = layer._input;
    if (sync) expect(original).toBe((input as any)[$REFRESH]);
    else expect(original).not.toBe((input as any)[$REFRESH]);
    request(1);
    flush();
    expect(await result).toBe(2);
    expect([shown, runs]).toEqual([2, 1]);
    const producer = layer._input;
    expect(producer).not.toBe((input as any)[$REFRESH]);
    if (!sync) expect(producer).toBe(original);
    expect(await refresh(view)).toBe(2);
    expect(layer._input).toBe(producer);
    expect(runs).toBe(1);
    setSource(2);
    flush();
    expect([shown, runs]).toEqual([4, 2]);
  } finally {
    dispose();
    flush();
  }
});

it("a writable computation retains input normalization for raw thenable writes", async () => {
  const answer = Promise.withResolvers<number>(), end = Promise.withResolvers<void>();
  const [source, setSource] = createSignal<unknown>(() => 0, { sync: true });
  let guess!: (value: unknown) => unknown, shown: unknown, pending = false;
  const dispose = createRoot(dispose => {
    const [view, write] = createOptimistic(source);
    guess = write;
    createRenderEffect(view, value => { shown = value; });
    createRenderEffect(() => isPending(view), value => { pending = value; });
    return dispose;
  });
  flush();
  const running = action(function* () {
    setSource(answer.promise);
    guess(1);
    yield end.promise;
  })();
  try {
    flush();
    expect([shown, pending]).toEqual([1, true]);
    end.resolve();
    await running;
    flush();
    expect(shown).toBe(1);
    answer.resolve(2);
    await turn();
    expect([shown, pending]).toEqual([2, false]);
    expect(source()).toBe(answer.promise);
  } finally {
    answer.resolve(2);
    end.resolve();
    await running;
    dispose();
    flush();
  }
});
