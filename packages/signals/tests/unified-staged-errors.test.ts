import { afterEach, expect, it } from "vitest";
import {
  action,
  createErrorBoundary,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup,
  resetErrorHalt
} from "../src/index.js";

afterEach(() => resetErrorHalt());

it.each([0, 1, 3])(
  "a held error respects %i optimistic boundaries and retires the displayed children at publication",
  async depth => {
    const lifetime = Promise.withResolvers<void>();
    const fail = Promise.withResolvers<void>();
    const [id, setId] = createSignal(1);
    const guesses: ((value: number) => unknown)[] = [];
    const cleaned: number[] = [];
    const screens: (number[] | string)[] = [];
    const dispose = createRoot(dispose => {
      let value = createMemo(() => {
        const n = id();
        if (n === 2) throw new Error("failed");
        return n;
      });
      for (let level = 0; level < depth; level++) {
        const input = value;
        const [output, guess] = createOptimistic(() => input());
        guesses.push(guess);
        value = createMemo(() => output());
      }
      const view = createErrorBoundary(
        () => {
          const owned = createMemo(() => {
            const n = value();
            onCleanup(() => cleaned.push(n));
            return n;
          });
          return [id(), owned()];
        },
        error => (error() as Error).message
      );
      createRenderEffect(view, value => void screens.push(value));
      return dispose;
    });
    let running: Promise<unknown> | undefined;
    try {
      flush();
      expect(screens).toEqual([[1, 1]]);
      running = action(function* () {
        guesses.forEach((guess, level) => guess(10 * (level + 1)));
        yield fail.promise;
        setId(2);
        yield lifetime.promise;
      })();
      flush();
      const displayed = depth ? depth * 10 : 1;
      expect(screens.at(-1)).toEqual([1, displayed]);
      const beforeError = screens.slice();
      const cleanupsBeforeError = cleaned.slice();

      fail.resolve();
      await new Promise(resolve => setTimeout(resolve, 0));
      flush();
      expect(screens).toEqual(beforeError);
      expect(cleaned).toEqual(cleanupsBeforeError);

      lifetime.resolve();
      await running;
      await new Promise(resolve => setTimeout(resolve, 0));
      flush();
      expect(screens.at(-1)).toBe("failed");
      expect(screens.filter(value => value === "failed")).toHaveLength(1);
      expect(cleaned.slice(cleanupsBeforeError.length)).toEqual([displayed]);

      setId(3);
      flush();
      expect(screens.at(-1)).toEqual([3, 3]);
    } finally {
      fail.resolve();
      lifetime.resolve();
      await running;
      dispose();
      flush();
    }
  }
);
