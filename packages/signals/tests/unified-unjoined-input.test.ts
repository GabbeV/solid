import { expect, it } from "vitest";
import {
  action,
  createErrorBoundary,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));

for (const depth of [2, 4])
  it(`a lower layer can retire while an upper override remains active (depth=${depth})`, async () => {
    const answer = Promise.withResolvers<number>();
    const lowerSaved = Promise.withResolvers<void>();
    const upperSaved = Promise.withResolvers<void>();
    let guessLower!: (v: number) => void, guessUpper!: (v: number) => void;
    const frames: number[][] = [];
    const dispose = createRoot(dispose => {
      const [first, setFirst] = createOptimistic(() => 0);
      guessLower = setFirst;
      let input = createMemo(() => (first() === 0 ? 0 : answer.promise));
      for (let i = 2; i < depth; i++) {
        const previous = input;
        [input] = createOptimistic(() => previous() * 2);
      }
      const [last, setLast] = createOptimistic(input);
      guessUpper = setLast;
      createRenderEffect(
        () => [first(), last()],
        value => {
          frames.push(value);
        }
      );
      return dispose;
    });
    flush();
    const lower = action(function* () {
      guessLower(1);
      yield lowerSaved.promise;
    })();
    flush();
    expect(frames.at(-1)).toEqual([0, 0]);
    const upper = action(function* () {
      guessUpper(100);
      yield upperSaved.promise;
    })();
    try {
      flush();
      expect(frames.at(-1)).toEqual([1, 100]);
      answer.resolve(2);
      await turn();
      flush();
      expect(frames.at(-1)).toEqual([1, 100]);
      lowerSaved.resolve();
      await lower;
      await turn();
      flush();
      expect(frames.at(-1)).toEqual([0, 100]);
      upperSaved.resolve();
      await upper;
      await turn();
      flush();
      expect(frames.at(-1)).toEqual([0, 0]);
    } finally {
      answer.resolve(2);
      lowerSaved.resolve();
      upperSaved.resolve();
      await Promise.all([lower, upper]);
      dispose();
      flush();
    }
  });

it("an input advances independently while a repeated guess is suspended; correction replaces obsolete work coherently", async () => {
  const saved = Promise.withResolvers<void>();
  const speculative = Promise.withResolvers<number>();
  const correction = Promise.withResolvers<number>();
  const [source, setSource] = createSignal(0);
  const [tick, setTick] = createSignal(0);
  const cleaned: number[] = [];
  let guess!: (v: number) => void;
  let view!: () => number, detail!: () => number;
  let sourceShown = 0,
    directShown = 0;
  let pair: number[] | undefined, late: number[] | undefined;
  const dispose = createRoot(dispose => {
    [view, guess] = createOptimistic(source);
    detail = createMemo(() => {
      const value = view();
      onCleanup(() => {
        cleaned.push(value);
      });
      return value === 3 ? speculative.promise : value === 1 ? correction.promise : value * 10;
    });
    createRenderEffect(source, value => {
      sourceShown = value;
    });
    createRenderEffect(
      () => {
        tick();
        return view();
      },
      value => {
        directShown = value;
      }
    );
    createRenderEffect(
      () => [view(), detail()],
      value => {
        pair = value;
      }
    );
    return dispose;
  });
  flush();
  const running = action(function* () {
    guess(2);
    yield saved.promise;
  })();
  let disposeLate: (() => void) | undefined;
  try {
    flush();
    expect([sourceShown, directShown, pair]).toEqual([0, 2, [2, 20]]);
    cleaned.length = 0;
    guess(3);
    flush();
    setSource(1);
    setTick(1);
    flush();
    expect([sourceShown, directShown, pair]).toEqual([1, 2, [2, 20]]);
    disposeLate = createRoot(dispose => {
      createRenderEffect(
        () => [view(), detail()],
        value => {
          late = value;
        }
      );
      return dispose;
    });
    flush();
    // A fresh reader may wait; if it publishes, it must use the same frame.
    if (late) expect(late).toEqual([2, 20]);
    expect(cleaned).not.toContain(2);
    saved.resolve();
    await running;
    await turn();
    flush();
    expect([sourceShown, directShown, pair]).toEqual([1, 2, [2, 20]]);
    expect(cleaned).not.toContain(2);
    correction.resolve(10);
    await turn();
    flush();
    expect([sourceShown, directShown, pair, late]).toEqual([1, 1, [1, 10], [1, 10]]);
    expect(cleaned.filter(value => value === 2)).toHaveLength(1);
    speculative.resolve(30);
    await turn();
    flush();
    expect([directShown, pair, late]).toEqual([1, [1, 10], [1, 10]]);
  } finally {
    saved.resolve();
    speculative.resolve(30);
    correction.resolve(10);
    await running;
    disposeLate?.();
    dispose();
    flush();
  }
});

for (const asyncInput of [false, true])
  it(`an independent input error stays behind the override until correction (async=${asyncInput})`, async () => {
    const saved = Promise.withResolvers<void>();
    const answer = Promise.withResolvers<number>();
    const [source, setSource] = createSignal(0);
    let guess!: (value: number) => void;
    let sourceShown = -1,
      outputShown = "";
    const cleaned: number[] = [];
    const dispose = createRoot(dispose => {
      const [view, write] = createOptimistic(() => {
        const value = source();
        if (value !== 2) return value;
        if (asyncInput) return answer.promise;
        throw new Error("failed");
      });
      guess = write;
      const boundary = createErrorBoundary(
        () => {
          const owned = createMemo(() => {
            const value = view();
            onCleanup(() => {
              cleaned.push(value);
            });
            return String(value);
          });
          return owned();
        },
        error => (error() as Error).message
      );
      createRenderEffect(source, value => {
        sourceShown = value;
      });
      createRenderEffect(boundary, value => {
        outputShown = value;
      });
      return dispose;
    });
    flush();
    const running = action(function* () {
      guess(10);
      yield saved.promise;
    })();
    try {
      flush();
      expect([sourceShown, outputShown]).toEqual([0, "10"]);
      cleaned.length = 0;
      setSource(2);
      flush();
      if (asyncInput) answer.reject(new Error("failed"));
      await turn();
      flush();
      expect([sourceShown, outputShown]).toEqual([2, "10"]);
      expect(cleaned).not.toContain(10);
      saved.resolve();
      await running;
      await turn();
      flush();
      expect([sourceShown, outputShown]).toEqual([2, "failed"]);
      // Propagating an error does not rerun this settled memo. Its boundary
      // retains the hidden content for recovery, as for ordinary memos in next.
      expect(cleaned).not.toContain(10);
      setSource(3);
      flush();
      expect([sourceShown, outputShown]).toEqual([3, "3"]);
      expect(cleaned.filter(value => value === 10)).toHaveLength(1);
    } finally {
      saved.resolve();
      answer.resolve(2);
      await running;
      dispose();
      flush();
    }
  });
