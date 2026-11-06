import { afterEach, expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup,
  refresh
} from "../src/index.js";

const turn = () => new Promise<void>(resolve => setTimeout(resolve, 0));
function gate() {
  let resolve!: () => void;
  const promise = new Promise<void>(yes => {
    resolve = yes;
  });
  return { promise, resolve };
}
const disposals: (() => void)[] = [];
afterEach(() => {
  for (const dispose of disposals.splice(0)) dispose();
  flush();
});

for (const slow of [false, true])
  for (const initial of [0, 1])
    for (const reverse of [false, true])
      it(`a lower re-guess cannot demote an upper pending derivation (slow=${slow}, initial=${initial}, reverse=${reverse})`, async () => {
        const lowerAnswer = gate(),
          repeat = gate(),
          lowerEnd = gate(),
          upperEnd = gate();
        let lowerGuess!: (value: number) => number, upperGuess!: (value: number) => number;
        const requests: { key: string; resolve(value: string): void }[] = [];
        const shown = { lower: 0, upper: 0, pair: "0:0" };
        createRoot(dispose => {
          disposals.push(dispose);
          const [source, gl] = createOptimistic(() => 0);
          const lower = slow
            ? createMemo(() => {
                const value = source();
                return value === 2 ? lowerAnswer.promise.then(() => value) : value;
              })
            : source;
          const [upper, gu] = createOptimistic(() => lower() * 10);
          lowerGuess = gl;
          upperGuess = gu;
          const pair = createMemo(() => {
            let a: number, b: number;
            if (reverse) {
              b = upper();
              a = lower();
            } else {
              a = lower();
              b = upper();
            }
            const key = `${a}:${b}`;
            return b === 20
              ? new Promise<string>(resolve => {
                  requests.push({ key, resolve });
                })
              : key;
          });
          createRenderEffect(
            lower,
            value => {
              shown.lower = value;
            },
            { schedule: true }
          );
          createRenderEffect(
            upper,
            value => {
              shown.upper = value;
            },
            { schedule: true }
          );
          createRenderEffect(
            pair,
            value => {
              shown.pair = value;
            },
            { schedule: true }
          );
        });
        flush();
        const lowerAction = action(function* () {
          lowerGuess(initial);
          yield repeat.promise;
          lowerGuess(2);
          yield lowerEnd.promise;
        })();
        await turn();
        expect(shown).toEqual({
          lower: initial,
          upper: initial * 10,
          pair: `${initial}:${initial * 10}`
        });
        const upperAction = action(function* () {
          upperGuess(20);
          yield upperEnd.promise;
        })();
        flush();
        try {
          repeat.resolve();
          await turn();
          expect({ ...shown }).toEqual({
            lower: initial,
            upper: initial * 10,
            pair: `${initial}:${initial * 10}`
          });
          for (const request of requests) request.resolve(request.key);
          await turn();
          // The ready lower proposal can publish independently of the upper
          // action lifetime. A still-pending lower proposal remains hidden.
          const publishedLower = slow ? initial : 2;
          expect({ ...shown }).toEqual({
            lower: publishedLower,
            upper: 20,
            pair: `${publishedLower}:20`
          });
          expect(requests.some(request => request.key === "2:20")).toBe(!slow);
        } finally {
          repeat.resolve();
          lowerAnswer.resolve();
          lowerEnd.resolve();
          upperEnd.resolve();
          await Promise.all([lowerAction, upperAction]);
          for (let i = 0; i < 5; i++) {
            for (const request of requests) request.resolve(request.key);
            await turn();
          }
        }
      });

for (const depth of [0, 1, 4])
  it(`an unchanged memo preserves its downstream owned children (optimistic depth=${depth})`, async () => {
    const change = gate(),
      end = gate();
    let write!: (value: number) => number,
      runs = 0,
      cleanups = 0,
      shown = -1;
    const lowerWrites: ((value: number) => number)[] = [];
    createRoot(dispose => {
      disposals.push(dispose);
      let input: () => number;
      [input, write] = createSignal(0);
      for (let i = 0; i < depth; i++) {
        const [view, guess] = createOptimistic(input);
        input = view;
        lowerWrites.push(guess);
        write = guess;
      }
      const parity = createMemo(() => input() % 2);
      const child = createMemo(() => {
        const value = parity();
        runs++;
        onCleanup(() => {
          cleanups++;
        });
        createRenderEffect(
          () => value,
          value => {
            shown = value;
          },
          { schedule: true }
        );
        return value;
      });
      createRenderEffect(child, () => {}, { schedule: true });
    });
    flush();
    const actions: Promise<unknown>[] = [];
    try {
      for (let i = 0; i < depth - 1; i++) {
        actions.push(
          action(function* () {
            lowerWrites[i](0);
            yield end.promise;
          })()
        );
        await turn();
      }
      if (depth) {
        actions.push(
          action(function* () {
            write(1);
            yield change.promise;
            write(3);
            yield end.promise;
          })()
        );
      } else write(1);
      flush();
      expect([runs, cleanups, shown]).toEqual([2, 1, 1]);
      if (depth) change.resolve();
      else write(3);
      await turn();
      expect([runs, cleanups, shown]).toEqual([2, 1, 1]);
    } finally {
      change.resolve();
      end.resolve();
      await Promise.all(actions);
      await turn();
    }
  });

for (const optimistic of [false, true])
  it(`an unchanged memo leaves a downstream refetch independent (optimistic=${optimistic})`, async () => {
    const change = gate(),
      end = gate(),
      answer = gate();
    let guess!: (value: number) => number, detail!: () => number;
    let refetch = false,
      requests = 0;
    const shown = { view: -1, parity: -1, detail: -1 };
    createRoot(dispose => {
      disposals.push(dispose);
      const [view, write] = optimistic ? createOptimistic(() => 0) : createSignal(0);
      guess = write;
      const parity = createMemo(() => view() % 2);
      detail = createMemo(() => {
        const value = parity();
        if (!refetch) return value;
        requests++;
        return answer.promise.then(() => value);
      });
      createRenderEffect(
        view,
        value => {
          shown.view = value;
        },
        { schedule: true }
      );
      createRenderEffect(
        parity,
        value => {
          shown.parity = value;
        },
        { schedule: true }
      );
      createRenderEffect(
        detail,
        value => {
          shown.detail = value;
        },
        { schedule: true }
      );
    });
    flush();
    const running = optimistic
      ? action(function* () {
          guess(1);
          yield change.promise;
          guess(3);
          yield end.promise;
        })()
      : (guess(1), Promise.resolve());
    flush();
    let refreshed: Promise<number> | undefined;
    try {
      expect(shown).toEqual({ view: 1, parity: 1, detail: 1 });
      refetch = true;
      refreshed = refresh(detail);
      await turn();
      expect(requests).toBe(1);
      if (optimistic) change.resolve();
      else guess(3);
      await turn();
      expect(shown).toEqual({ view: 3, parity: 1, detail: 1 });
      expect(requests).toBe(1);
      answer.resolve();
      expect(await refreshed).toBe(1);
    } finally {
      answer.resolve();
      change.resolve();
      end.resolve();
      await running;
      await turn();
    }
  });
