import { afterEach, describe, expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  resetErrorHalt
} from "../src/index.js";
import { createLayer } from "../src/layers/layer.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  const promise = new Promise<T>(r => {
    resolve = r;
  });
  return { promise, resolve };
}
const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
const disposals: (() => void)[] = [];
function root(fn: () => void) {
  createRoot(dispose => {
    disposals.push(dispose);
    fn();
  });
}
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
  resetErrorHalt();
});

describe("action-owned overrides keep input and output lifetimes separate", () => {
  for (const implementation of ["public API", "explicit layer"] as const) {
    const optimistic = (input: () => number) =>
      implementation === "public API"
        ? createOptimistic(input)
        : createLayer(input, { lifetime: "action" });

    for (const answer of [1, 2]) {
      it(`${implementation}: incoming ${answer} publishes independently; the functional guess is not rebased`, async () => {
        const end = gate<void>();
        const [source, setSource] = createSignal(0);
        const [tick, setTick] = createSignal(0);
        let guess!: (fn: (previous: number) => number) => number;
        let view!: () => number;
        let calls = 0,
          sourceShown = 0,
          viewShown = 0,
          late = -1;
        let pair: readonly number[] = [0, 0];
        root(() => {
          [view, guess] = optimistic(source);
          const doubled = createMemo(() => view() * 2);
          createRenderEffect(source, value => {
            sourceShown = value;
          });
          createRenderEffect(
            () => [tick(), view()],
            value => {
              viewShown = value[1];
            }
          );
          createRenderEffect(
            () => [view(), doubled()],
            value => {
              pair = value;
            }
          );
        });
        const running = action(function* () {
          guess(previous => {
            calls++;
            return previous + 1;
          });
          yield end.promise;
        })();
        flush();
        expect([sourceShown, viewShown, pair]).toEqual([0, 1, [1, 2]]);
        setSource(answer);
        flush();
        setTick(1);
        flush();
        root(() =>
          createRenderEffect(view, value => {
            late = value;
          })
        );
        flush();
        expect([sourceShown, viewShown, pair, late, calls]).toEqual([answer, 1, [1, 2], 1, 1]);
        end.resolve();
        await running;
        await turn();
        expect([sourceShown, viewShown, pair, late, calls]).toEqual([
          answer,
          answer,
          [answer, answer * 2],
          answer,
          1
        ]);
      });
    }

    it(`${implementation}: a correction waits for both the action and its async derivation`, async () => {
      const end = gate<void>(),
        result = gate<number>();
      const [source, setSource] = createSignal(0);
      let guess!: (value: number) => number;
      let sourceShown = 0,
        viewShown = 0;
      let pair: readonly number[] = [0, 0];
      root(() => {
        const [view, write] = optimistic(source);
        guess = write;
        const derived = createMemo(() => (view() === 2 ? result.promise : view() * 2));
        createRenderEffect(source, value => {
          sourceShown = value;
        });
        createRenderEffect(view, value => {
          viewShown = value;
        });
        createRenderEffect(
          () => [view(), derived()],
          value => {
            pair = value;
          }
        );
      });
      const running = action(function* () {
        guess(1);
        yield end.promise;
      })();
      flush();
      setSource(2);
      flush();
      expect([sourceShown, viewShown, pair]).toEqual([2, 1, [1, 2]]);
      end.resolve();
      await running;
      await turn();
      expect([sourceShown, viewShown, pair]).toEqual([2, 1, [1, 2]]);
      result.resolve(4);
      await turn();
      expect([sourceShown, viewShown, pair]).toEqual([2, 2, [2, 4]]);
    });

    it(`${implementation}: expiration also holds on work needed to restore the input`, async () => {
      const end = gate<void>(),
        result = gate<number>();
      let guess!: (value: number) => number,
        restoring = false,
        shown = 0;
      let pair: readonly number[] = [0, 0];
      root(() => {
        const [view, write] = optimistic(() => 0);
        guess = write;
        const derived = createMemo(() => (view() === 0 && restoring ? result.promise : view() * 2));
        createRenderEffect(view, value => {
          shown = value;
        });
        createRenderEffect(
          () => [view(), derived()],
          value => {
            pair = value;
          }
        );
      });
      const running = action(function* () {
        guess(1);
        yield end.promise;
      })();
      flush();
      expect([shown, pair]).toEqual([1, [1, 2]]);
      restoring = true;
      end.resolve();
      await running;
      await turn();
      expect([shown, pair]).toEqual([1, [1, 2]]);
      result.resolve(0);
      await turn();
      expect([shown, pair]).toEqual([0, [0, 0]]);
    });

    it(`${implementation}: an unrelated signal remains independent`, async () => {
      const end = gate<void>();
      const [other, setOther] = createSignal(0);
      let guess!: (value: number) => number;
      let shown: readonly number[] = [0, 0];
      root(() => {
        const [view, write] = optimistic(() => 0);
        guess = write;
        createRenderEffect(
          () => [other(), view()],
          value => {
            shown = value;
          }
        );
      });
      const running = action(function* () {
        guess(1);
        yield end.promise;
      })();
      flush();
      setOther(2);
      flush();
      expect(shown).toEqual([2, 1]);
      end.resolve();
      await running;
      await turn();
      expect(shown).toEqual([2, 0]);
    });

    it(`${implementation}: characterize correction from an optimistic input while the child action stays open`, async () => {
      const next = gate<void>(),
        firstEnd = gate<void>(),
        secondEnd = gate<void>();
      let firstGuess!: (fn: (previous: number) => number) => number;
      let secondGuess!: (fn: (previous: number) => number) => number;
      let firstShown = 0,
        secondShown = 0;
      let pair: readonly number[] = [0, 0];
      root(() => {
        const [first, ga] = optimistic(() => 0);
        firstGuess = ga;
        const doubled = createMemo(() => first() * 2);
        const [second, gb] = optimistic(doubled);
        secondGuess = gb;
        createRenderEffect(first, value => {
          firstShown = value;
        });
        createRenderEffect(second, value => {
          secondShown = value;
        });
        createRenderEffect(
          () => [first(), second()],
          value => {
            pair = value;
          }
        );
      });
      const firstAction = action(function* () {
        firstGuess(x => x + 1);
        yield next.promise;
        firstGuess(x => x + 1);
        yield firstEnd.promise;
      })();
      flush();
      expect([firstShown, secondShown, pair]).toEqual([1, 2, [1, 2]]);
      const secondAction = action(function* () {
        secondGuess(x => x + 1);
        yield secondEnd.promise;
      })();
      flush();
      expect([firstShown, secondShown, pair]).toEqual([1, 3, [1, 3]]);
      next.resolve();
      await turn();
      // A parent proposal can publish while the child's override remains active.
      // The functional guess is not rebased; every reader agrees on each output.
      const pending = [2, 3];
      expect([firstShown, secondShown, pair]).toEqual([pending[0], pending[1], pending]);
      secondEnd.resolve();
      await secondAction;
      await turn();
      expect([firstShown, secondShown, pair]).toEqual([2, 4, [2, 4]]);
      firstEnd.resolve();
      await firstAction;
      await turn();
      expect([firstShown, secondShown, pair]).toEqual([0, 0, [0, 0]]);
    });

    it(`${implementation}: input async settling after the action ends corrects coherently`, async () => {
      const end = gate<void>(),
        answer = gate<number>();
      const [source, setSource] = createSignal(0);
      let guess!: (value: number) => number;
      let inputShown = 0,
        outputShown = 0;
      let pair: readonly number[] = [0, 0];
      root(() => {
        const input = createMemo(() => (source() === 0 ? 0 : answer.promise));
        const [view, write] = optimistic(input);
        guess = write;
        const doubled = createMemo(() => view() * 2);
        createRenderEffect(input, value => {
          inputShown = value;
        });
        createRenderEffect(view, value => {
          outputShown = value;
        });
        createRenderEffect(
          () => [view(), doubled()],
          value => {
            pair = value;
          }
        );
      });
      const running = action(function* () {
        guess(1);
        yield end.promise;
      })();
      flush();
      setSource(1);
      flush();
      expect([inputShown, outputShown, pair]).toEqual([0, 1, [1, 2]]);
      end.resolve();
      await running;
      await turn();
      expect([inputShown, outputShown, pair]).toEqual([0, 1, [1, 2]]);
      answer.resolve(2);
      await turn();
      expect([inputShown, outputShown, pair]).toEqual([2, 2, [2, 4]]);
    });
  }

  it("layer: a repeated functional guess retains its last published output during async work", async () => {
    const next = gate<void>(),
      end = gate<void>(),
      answer = gate<number>();
    const [tick, setTick] = createSignal(0);
    let guess!: (fn: (previous: number) => number) => number, view!: () => number;
    let shown = 0,
      late = -1,
      calls = 0;
    let pair: readonly number[] = [0, 0];
    root(() => {
      [view, guess] = createLayer(() => 0, { lifetime: "action" });
      const derived = createMemo(() => (view() === 2 ? answer.promise : view()));
      createRenderEffect(
        () => [tick(), view()],
        value => {
          shown = value[1];
        }
      );
      createRenderEffect(
        () => [view(), derived()],
        value => {
          pair = value;
        }
      );
    });
    const running = action(function* () {
      guess(x => {
        calls++;
        return x + 1;
      });
      yield next.promise;
      guess(x => {
        calls++;
        return x + 1;
      });
      yield end.promise;
    })();
    flush();
    expect([shown, pair]).toEqual([1, [1, 1]]);
    next.resolve();
    await turn();
    setTick(1);
    flush();
    root(() =>
      createRenderEffect(view, value => {
        late = value;
      })
    );
    flush();
    expect([shown, pair, late, calls]).toEqual([1, [1, 1], 1, 2]);
    answer.resolve(2);
    await turn();
    expect([shown, pair, late, calls]).toEqual([2, [2, 2], 2, 2]);
    end.resolve();
    await running;
    await turn();
    expect([shown, pair, late, calls]).toEqual([0, [0, 0], 0, 2]);
  });
});
