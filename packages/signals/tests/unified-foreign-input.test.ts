import { afterEach, describe, expect, it } from "vitest";
import {
  action,
  createMemo,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup,
  resetErrorHalt
} from "../src/index.js";
import { createPending as createPendingBoundary, isPending } from "../src/layers/pending.js";
const createPending =
  process.env.PENDING_API === "shared"
    ? <T>(input: () => T) => createMemo(() => isPending(input))
    : createPendingBoundary;
import { createLayer } from "../src/layers/layer.js";

function gate<T>() {
  let resolve!: (value: T) => void;
  let reject!: (error: unknown) => void;
  const promise = new Promise<T>((yes, no) => {
    resolve = yes;
    reject = no;
  });
  return { promise, resolve, reject };
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

describe("optimistic publication across a separate ordinary hold", () => {
  for (const reverse of [false, true])
    for (const late of [false, true])
      for (const yFirst of [false, true]) {
        it(`pending uses the committed input (reverse=${reverse}, late=${late}, yFirst=${yFirst})`, async () => {
          const xEnd = gate<void>(),
            yEnd = gate<void>();
          const [x, setX] = createSignal(0),
            [y, setY] = createSignal(0),
            [tick, setTick] = createSignal(0);
          let status!: () => boolean;
          let shownX = 0,
            shownY = 0,
            shownStatus = false,
            label = "unmounted",
            direct = "unmounted";
          root(() => {
            status = createPending(x);
            createRenderEffect(x, value => {
              shownX = value;
            });
            createRenderEffect(y, value => {
              shownY = value;
            });
            createRenderEffect(status, value => {
              shownStatus = value;
            });
          });
          const mount = () =>
            root(() => {
              const combined = createMemo(() => {
                tick();
                if (reverse) {
                  const value = y();
                  return `${status()}:${value}`;
                }
                return `${status()}:${y()}`;
              });
              createRenderEffect(combined, value => {
                label = value;
              });
              createRenderEffect(y, value => {
                direct = String(value);
              });
            });
          if (!late) mount();
          flush();
          const other = action(function* () {
            setY(10);
            yield yEnd.promise;
          })();
          flush();
          const changing = action(function* () {
            setX(1);
            yield xEnd.promise;
          })();
          flush();
          if (late) {
            mount();
            flush();
          }
          expect([shownX, shownY, shownStatus, label, direct]).toEqual([0, 0, true, "true:0", "0"]);
          setTick(1);
          flush();
          expect([shownX, shownY, shownStatus, label, direct]).toEqual([0, 0, true, "true:0", "0"]);
          if (yFirst) {
            yEnd.resolve();
            await other;
            await turn();
            expect([shownX, shownY, shownStatus, label, direct]).toEqual([
              0,
              10,
              true,
              "true:10",
              "10"
            ]);
            xEnd.resolve();
            await changing;
          } else {
            // Pending-false is ordinary work again. It consumes y's proposal,
            // so the two lower updates meet at the memo and finish together.
            xEnd.resolve();
            await changing;
            await turn();
            expect([shownX, shownY, shownStatus, label, direct]).toEqual([
              0,
              0,
              true,
              "true:0",
              "0"
            ]);
            yEnd.resolve();
            await other;
          }
          await turn();
          expect([shownX, shownY, shownStatus, label, direct]).toEqual([
            1,
            10,
            false,
            "false:10",
            "10"
          ]);
        });
      }

  for (const firstSettles of [false, true]) {
    it(`a completing lower input supersedes pending async without tearing (initial answer=${firstSettles})`, async () => {
      const xEnd = gate<void>(),
        yEnd = gate<void>(),
        oldResult = gate<string>(),
        newResult = gate<string>();
      const [x, setX] = createSignal(0),
        [y, setY] = createSignal(0);
      let shownY = 0,
        shownStatus = false,
        label = "false:0";
      const starts: number[] = [],
        cleaned: number[] = [];
      root(() => {
        const status = createPending(x);
        const combined = createMemo(() => {
          const p = status(),
            n = y();
          if (!p) return `false:${n}`;
          starts.push(n);
          onCleanup(() => {
            cleaned.push(n);
          });
          return n === 0 ? oldResult.promise : newResult.promise;
        });
        createRenderEffect(y, value => {
          shownY = value;
        });
        createRenderEffect(status, value => {
          shownStatus = value;
        });
        createRenderEffect(combined, value => {
          label = value;
        });
      });
      flush();
      const other = action(function* () {
        setY(10);
        yield yEnd.promise;
      })();
      flush();
      const changing = action(function* () {
        setX(1);
        yield xEnd.promise;
      })();
      flush();
      expect(starts).toContain(0);
      expect([shownY, shownStatus, label]).toEqual([0, false, "false:0"]);
      if (firstSettles) {
        oldResult.resolve("true:0");
        await turn();
        expect([shownY, shownStatus, label]).toEqual([0, true, "true:0"]);
      }
      yEnd.resolve();
      await other;
      await turn();
      expect(starts.at(-1)).toBe(10);
      expect([shownY, shownStatus, label]).toEqual(
        firstSettles ? [0, true, "true:0"] : [0, false, "false:0"]
      );
      if (!firstSettles) {
        oldResult.resolve("obsolete:0");
        await turn();
        expect([shownY, shownStatus, label]).toEqual([0, false, "false:0"]);
      }
      newResult.resolve("true:10");
      await turn();
      expect([shownY, shownStatus, label]).toEqual([10, true, "true:10"]);
      expect(cleaned).toContain(0);
      xEnd.resolve();
      await changing;
      await turn();
      expect([shownY, shownStatus, label]).toEqual([10, false, "false:10"]);
      expect(cleaned).toContain(10);
    });
  }

  for (const guessFirst of [false, true])
    it(`an action guess over a settled input uses the same rule (guess first=${guessFirst})`, async () => {
      const yEnd = gate<void>(),
        guessEnd = gate<void>();
      const [y, setY] = createSignal(0);
      let guess!: (value: number) => number, view!: () => number;
      let late = "unmounted";
      let shownY = 0,
        shownGuess = 0,
        pair = "0:0";
      root(() => {
        const [value, write] = createLayer(() => 0, { lifetime: "action" });
        guess = write;
        view = value;
        const combined = createMemo(() => `${value()}:${y()}`);
        createRenderEffect(value, n => {
          shownGuess = n;
        });
        createRenderEffect(y, n => {
          shownY = n;
        });
        createRenderEffect(combined, n => {
          pair = n;
        });
      });
      flush();
      const changeY = action(function* () {
        setY(10);
        yield yEnd.promise;
      });
      const makeGuess = action(function* () {
        guess(1);
        yield guessEnd.promise;
      });
      let other: Promise<void>, guessing: Promise<void>;
      if (guessFirst) {
        guessing = makeGuess();
        flush();
        other = changeY();
        flush();
      } else {
        other = changeY();
        flush();
        guessing = makeGuess();
        flush();
      }
      root(() => {
        const pair = createMemo(() => {
          const n = y();
          return `${view()}:${n}`;
        });
        createRenderEffect(pair, value => {
          late = value;
        });
      });
      flush();
      expect(late).toBe("1:0");
      expect([shownY, shownGuess, pair]).toEqual([0, 1, "1:0"]);
      yEnd.resolve();
      await other;
      await turn();
      expect([shownY, shownGuess, pair, late]).toEqual([10, 1, "1:10", "1:10"]);
      guessEnd.resolve();
      await guessing;
      await turn();
      expect([shownY, shownGuess, pair, late]).toEqual([10, 0, "0:10", "0:10"]);
    });
});
