import { expect, it } from "vitest";
import {
  action,
  createMemo,
  createOptimistic,
  createRenderEffect,
  createRoot,
  createSignal,
  flush,
  onCleanup
} from "../src/index.js";

const turn = async () => {
  await new Promise<void>(resolve => setTimeout(resolve, 0));
  flush();
};

// Independent oracle: every published ordinary consequence agrees with its
// input output. No expected execution count or next-specific scheduling order.
for (const depth of [1, 3])
  for (const seed of [11, 29, 71, 137])
    it(`publications stay coherent through nested and sibling guesses (depth=${depth}, seed=${seed})`, async () => {
      let state = seed;
      const random = (n: number) => {
        state = (Math.imul(state, 1664525) + 1013904223) >>> 0;
        return state % n;
      };
      const requests: { resolve: () => void; done: boolean }[] = [];
      const phases: ReturnType<typeof Promise.withResolvers<void>>[][] = [];
      const actions: Promise<unknown>[] = [];
      const values: number[] = [],
        doubles: number[] = [],
        repeated: number[] = [];
      const late: { dispose: () => void; values: (number | undefined)[] }[] = [];
      const history: string[] = [];
      let combined: number[] = [];
      let created = 0,
        cleaned = 0,
        baseVersion = 0;
      let pulse!: () => void, changeBase!: () => void;
      let views: (() => number)[] = [];
      let guesses: ((n: number) => unknown)[] = [];
      const dispose = createRoot(dispose => {
        const [base, setBase] = createSignal(0),
          [tick, setTick] = createSignal(0);
        pulse = () => setTick(n => n + 1);
        changeBase = () => setBase(++baseVersion);
        let input = base;
        for (let i = 0; i < depth; i++) {
          const parent = input;
          const [view, guess] = createOptimistic(() => parent() * 10);
          views.push(view);
          guesses.push(guess);
          input = view;
        }
        const [sibling, guessSibling] = createOptimistic(base);
        views.push(sibling);
        guesses.push(guessSibling);
        views.forEach((view, i) => {
          const double = createMemo(() => {
            const value = view();
            created++;
            onCleanup(() => {
              cleaned++;
            });
            if (!value) return 0;
            const gate = Promise.withResolvers<void>();
            requests.push({ resolve: gate.resolve, done: false });
            return gate.promise.then(() => value * 2);
          });
          const reader = createMemo(() => {
            tick();
            return view();
          });
          createRenderEffect(view, value => {
            values[i] = value;
          });
          createRenderEffect(double, value => {
            doubles[i] = value;
          });
          createRenderEffect(reader, value => {
            repeated[i] = value;
          });
        });
        const total = createMemo(() => views.map(view => view()));
        createRenderEffect(total, value => {
          combined = value;
        });
        return dispose;
      });
      const check = () => {
        expect(doubles, history.join(" / ")).toEqual(values.map(n => n * 2));
        expect(repeated, history.join(" / ")).toEqual(values);
        expect(combined, history.join(" / ")).toEqual(values);
        for (const reader of late)
          reader.values.forEach((value, i) => {
            if (value !== undefined) expect(value, history.join(" / ")).toBe(values[i]);
          });
      };
      try {
        flush();
        check();
        guesses.forEach((guess, i) => {
          phases[i] = Array.from({ length: 3 }, () => Promise.withResolvers<void>());
          actions.push(
            action(function* () {
              for (let step = 0; step < 3; step++) {
                guess((i + 1) * 100 + step + 1);
                yield phases[i][step].promise;
              }
            })()
          );
        });
        await turn();
        check();
        const steps = phases.map(() => 0);
        for (let event = 0; event < 48; event++) {
          const kind = random(6);
          if (kind === 0) {
            const pending = requests.filter(r => !r.done);
            if (pending.length) {
              const request = pending[random(pending.length)];
              request.done = true;
              request.resolve();
              history.push("answer");
            }
          } else if (kind === 1) {
            const i = random(phases.length),
              step = steps[i]++;
            phases[i][step]?.resolve();
            history.push(`advance ${i}:${step}`);
          } else if (kind === 2) {
            pulse();
            history.push("pulse");
          } else if (kind === 3) {
            changeBase();
            history.push(`base ${baseVersion}`);
          } else if (kind === 4 && late.length < 2) {
            const values: (number | undefined)[] = [];
            const dispose = createRoot(dispose => {
              views.forEach((view, i) =>
                createRenderEffect(view, value => {
                  values[i] = value;
                })
              );
              return dispose;
            });
            late.push({ dispose, values });
            history.push("mount");
          } else if (late.length) {
            late.pop()!.dispose();
            history.push("unmount");
          }
          await turn();
          check();
        }
        for (const row of phases) for (const phase of row) phase.resolve();
        await Promise.all(actions);
        for (let round = 0; round < 12; round++) {
          for (const request of requests)
            if (!request.done) {
              request.done = true;
              request.resolve();
            }
          await turn();
          check();
        }
        expect(values).toEqual([
          ...Array.from({ length: depth }, (_, i) => baseVersion * 10 ** (i + 1)),
          baseVersion
        ]);
      } finally {
        for (const reader of late) reader.dispose();
        dispose();
        for (const row of phases) for (const phase of row) phase.resolve();
        for (const request of requests) request.resolve();
        await Promise.all(actions);
        await turn();
        expect(cleaned).toBe(created);
      }
    });

for (const probeFirst of [false, true])
  for (const roots of [0, 2])
    it(`private first callbacks do not make discarded joins irreversible (probe first=${probeFirst}, roots=${roots})`, async () => {
      const aEnd = Promise.withResolvers<void>();
      const bEnd = Promise.withResolvers<void>();
      const guessEnd = Promise.withResolvers<void>();
      const [a, setA] = createSignal(0),
        [b, setB] = createSignal(0);
      let view!: () => number, guess!: (n: number) => unknown;
      let shown = [0, 0],
        pair: number[] | undefined;
      let created = 0,
        cleaned = 0;
      let disposeReader = () => {};
      const disposeInputs = createRoot(dispose => {
        [view, guess] = createOptimistic(0);
        createRenderEffect(view, () => {});
        createRenderEffect(a, n => {
          shown[0] = n;
        });
        createRenderEffect(b, n => {
          shown[1] = n;
        });
        return dispose;
      });
      const aRunning = action(function* () {
        setA(1);
        yield aEnd.promise;
      })();
      flush();
      const bRunning = action(function* () {
        setB(2);
        yield bEnd.promise;
      })();
      flush();
      const guessing = action(function* () {
        guess(3);
        yield guessEnd.promise;
      })();
      flush();
      try {
        disposeReader = createRoot(dispose => {
          const combined = createMemo(() => {
            let optimistic: number;
            if (probeFirst) optimistic = view();
            const x = a(),
              y = b();
            const children = (depth: number): void => {
              if (depth) {
                createRoot(() => children(depth - 1));
                return;
              }
              created++;
              onCleanup(() => {
                cleaned++;
              });
              createRenderEffect(a, () => {});
              createRenderEffect(b, () => {});
            };
            children(roots);
            if (!probeFirst) optimistic = view();
            return [x, y, optimistic!];
          });
          createRenderEffect(
            combined,
            value => {
              pair = value;
            },
            { schedule: true }
          );
          return dispose;
        });
        flush();
        expect(pair).toEqual([0, 0, 3]);
        disposeReader();
        aEnd.resolve();
        await aRunning;
        await turn();
        expect(shown).toEqual([1, 0]);
        bEnd.resolve();
        await bRunning;
        await turn();
        expect(shown).toEqual([1, 2]);
      } finally {
        disposeReader();
        disposeInputs();
        aEnd.resolve();
        bEnd.resolve();
        guessEnd.resolve();
        await Promise.all([aRunning, bRunning, guessing]);
        await turn();
        expect(cleaned).toBe(created);
      }
    });
